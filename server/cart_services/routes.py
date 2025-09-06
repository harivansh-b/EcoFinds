from fastapi import APIRouter, Request, HTTPException, Depends
from starlette.status import HTTP_403_FORBIDDEN
from db.connection import get_db
from cart_services.models import CartAddModel, CartUpdateModel 
import os

cart_route = APIRouter(prefix="/cart")

def verify_auth_api(request: Request):
    expected_key = os.getenv("AUTH_API")
    received_key = request.headers.get("x-api-key")
    print(f"Expected API key: {expected_key} | Received API key: {received_key}")
    if expected_key != received_key:
        raise HTTPException(status_code=HTTP_403_FORBIDDEN, detail="Unauthorized access")

@cart_route.post("/add", dependencies=[Depends(verify_auth_api)])
async def add_item(item: CartAddModel, db=Depends(get_db)):
    cart_collection = db["cart"]

    existing_item = await cart_collection.find_one({
        "user_id": item.user_id,
        "product_id": item.product_id
    })
    if existing_item:
        raise HTTPException(status_code=400, detail="Product already in cart")

    await cart_collection.insert_one(item.model_dump())
    return {"message": "Product added to cart successfully", "cart_item": item.model_dump()}

@cart_route.patch("/update/{user_id}/{product_id}", dependencies=[Depends(verify_auth_api)])
async def update_item(user_id: str, product_id: str, update_data: CartUpdateModel, db=Depends(get_db)):
    cart_collection = db["cart"]

    existing_item = await cart_collection.find_one({"user_id": user_id, "product_id": product_id})
    if not existing_item:
        raise HTTPException(status_code=404, detail="Cart item not found")

    await cart_collection.update_one(
        {"user_id": user_id, "product_id": product_id},
        {"$set": {"status": update_data.status}}
    )

    return {"message": "Cart item status updated successfully"}

@cart_route.delete("/delete/{user_id}/{product_id}", dependencies=[Depends(verify_auth_api)])
async def delete_item(user_id: str, product_id: str, db=Depends(get_db)):
    cart_collection = db["cart"]

    existing_item = await cart_collection.find_one({"user_id": user_id, "product_id": product_id})
    if not existing_item:
        raise HTTPException(status_code=404, detail="Cart item not found")

    result = await cart_collection.delete_one({"user_id": user_id, "product_id": product_id})
    if result.deleted_count == 1:
        return {"message": "Cart item deleted successfully", "user_id": user_id, "product_id": product_id}
    else:
        raise HTTPException(status_code=500, detail="Failed to delete cart item")
    

@cart_route.get("/getcart/{user_id}", dependencies=[Depends(verify_auth_api)])
async def get_items(user_id: str, db=Depends(get_db)):
    cart_collection = db["cart"]
    product_collection = db["products"]

    cursor = cart_collection.find({"user_id": user_id}, {"_id": 0})  # exclude _id
    items = await cursor.to_list(length=None)

    if not items:
        raise HTTPException(status_code=404, detail="No items found in cart")

    return {"user_id": user_id, "cart_items": items}
