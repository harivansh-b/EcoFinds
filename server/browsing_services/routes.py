from fastapi import APIRouter, Request, HTTPException, Depends, Query
from db.connection import db
from starlette.status import HTTP_403_FORBIDDEN
import os
from datetime import datetime
from browsing_services.models import haversine  # your haversine util

browse_engine = APIRouter(prefix="/browse")

# 🔹 API Key verification
def verify_auth_api(request: Request):
    expected_key = os.getenv('BROWSE_API')
    key_name = "x-api-key"
    response_key = request.headers.get(key_name)
    if expected_key != response_key:
        raise HTTPException(status_code=HTTP_403_FORBIDDEN, detail="Unauthorized access")


# 🔹 Products Browsing API
@browse_engine.get("/products", dependencies=[Depends(verify_auth_api)])
async def browse_products(
    user_id: str = Query(..., description="Current user ID"),
    name: str = Query(None, description="Search by product name"),
    category: str = Query("all", description="Category filter: all, fashion, electronic, furniture, home_and_garden, books, sports"),
    limit: int = Query(10, description="Number of items to retrieve"),
    sort_by: str = Query("nearest", description="Sort by: nearest, newest, oldest, price_low, price_high"),
    min_price: float = Query(0, description="Minimum price filter"),
    max_price: float = Query(1_000_000, description="Maximum price filter"),
):
    try:
        user_doc = await db.user.find_one({"_id": user_id})
        if not user_doc:
            raise HTTPException(status_code=404, detail="User not found")

        user_lat = float(user_doc["lattitude"])
        user_lon = float(user_doc["longitude"])

        query = {"status": "available"}

        if name:
            query["name"] = {"$regex": name, "$options": "i"}  

        if category.lower() != "all":
            query["category"] = category

        query["price"] = {"$gte": min_price, "$lte": max_price}

        products_cursor = db.products.find(query)
        products_list = await products_cursor.to_list(length=1000)

        products_with_distance = []
        for product in products_list:
            seller_doc = await db.user.find_one({"_id": product["seller_id"]})
            if not seller_doc:
                continue

            seller_lat = float(seller_doc["lattitude"])
            seller_lon = float(seller_doc["longitude"])

            distance_km = haversine(user_lat, user_lon, seller_lat, seller_lon)
            product_copy = product.copy()
            product_copy["distance_km"] = round(distance_km, 2)
            products_with_distance.append(product_copy)

        if sort_by in ["latest", "newest"]:
            products_with_distance.sort(key=lambda x: x.get("created_at", datetime.min), reverse=True)
        elif sort_by == "oldest":
            products_with_distance.sort(key=lambda x: x.get("created_at", datetime.min))
        elif sort_by == "price_low":
            products_with_distance.sort(key=lambda x: x.get("price", float("inf")))
        elif sort_by == "price_high":
            products_with_distance.sort(key=lambda x: x.get("price", 0), reverse=True)
        else:  # default nearest
            products_with_distance.sort(key=lambda x: x["distance_km"])

        result = products_with_distance[:limit]

        return {"success": True, "count": len(result), "products": result}

    except Exception as e:
        print(f"Error fetching products: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch products")
