from fastapi import APIRouter, HTTPException, Depends, Request
from pydantic import BaseModel
from typing import List
from datetime import datetime
from db.connection import db
import uuid

order_router = APIRouter(prefix="/orders")

class OrderRequest(BaseModel):
    user_id: str
    product_ids: List[str]
    location: str

@order_router.post("/confirm")
async def confirm_order(order_req: OrderRequest):
    try:
        user = await db.user.find_one({"_id": order_req.user_id})
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        products = await db.products.find(
            {"_id": {"$in": order_req.product_ids}, "status": "available"}
        ).to_list(length=len(order_req.product_ids))

        if len(products) != len(order_req.product_ids):
            raise HTTPException(status_code=400, detail="Some products are not available")
        total_amount = sum([p["price"] for p in products])

        order_doc = {
            "order_id": str(uuid.uuid4()),
            "user_id": order_req.user_id,
            "timestamp": datetime.utcnow(),
            "total_amount": str(total_amount),  
            "status": "confirmed",
            "location": order_req.location,
        }
        await db.orders.insert_one(order_doc)

        await db.products.update_many(
            {"_id": {"$in": order_req.product_ids}},
            {"$set": {"status": "unavailable"}}
        )

        await db.cart.update_many(
            {"user_id": order_req.user_id, "product_id": {"$in": order_req.product_ids}},
            {"$set": {"status": "sold"}}
        )

        return {"success": True, "order": order_doc}

    except Exception as e:
        print(f"Error confirming order: {e}")
        raise HTTPException(status_code=500, detail="Failed to confirm order")


@order_router.get("/user/{user_id}")
async def get_user_orders(user_id: str):
    try:
        orders_cursor = db.orders.find({"user_id": user_id}).sort("timestamp", -1)
        orders = await orders_cursor.to_list(length=100)

        if not orders:
            raise HTTPException(status_code=404, detail="No orders found for this user")

        for order in orders:
            order["_id"] = str(order["_id"])
            if isinstance(order.get("timestamp"), datetime):
                order["timestamp"] = order["timestamp"].isoformat()

        return {"success": True, "count": len(orders), "orders": orders}

    except Exception as e:
        print(f"Error fetching orders: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch orders")