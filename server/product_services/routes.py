import uuid
from fastapi import APIRouter, Request, HTTPException, Depends
from starlette.status import HTTP_403_FORBIDDEN
from db.connection import get_db
from product_services.models import ProductModel, ProductUpdateModel
import os

product_route = APIRouter(prefix="/product")

def verify_auth_api(request: Request):
    expected_key = os.getenv('AUTH_API')
    received_key = request.headers.get("x-api-key")
    print(f"Expected API key: {expected_key} | Received API key: {received_key}")
    if expected_key != received_key:
        raise HTTPException(status_code=HTTP_403_FORBIDDEN, detail="Unauthorized access")

@product_route.put("/createproduct", dependencies=[Depends(verify_auth_api)])
async def create_product(product_data: ProductModel, db=Depends(get_db)):
    products_collection = db["products"]

    if not product_data.id:
        product_data.id = str(uuid.uuid4())

    product_dict = product_data.model_dump(by_alias=True)
    
    existing_product = await products_collection.find_one({"_id": product_data.id})
    if existing_product:
        raise HTTPException(status_code=400, detail="Product already exists")

    await products_collection.insert_one(product_dict)

    return {"message": "Product created successfully", "product": product_dict}


@product_route.delete("/deleteproduct/{product_id}", dependencies=[Depends(verify_auth_api)])
async def delete_product(product_id: str, db=Depends(get_db)):
    products_collection = db["products"]

    existing_product = await products_collection.find_one({"_id": product_id})
    if not existing_product:
        raise HTTPException(status_code=404, detail="Product not found")

    result = await products_collection.delete_one({"_id": product_id})
    
    if result.deleted_count == 1:
        return {"message": "Product deleted successfully", "product_id": product_id}
    else:
        raise HTTPException(status_code=500, detail="Failed to delete product")


@product_route.patch("/updateproduct/{product_id}", dependencies=[Depends(verify_auth_api)])
async def update_product(product_id: str, product_data: ProductUpdateModel, db=Depends(get_db)):
    products_collection = db["products"]

    existing_product = await products_collection.find_one({"_id": product_id})
    if not existing_product:
        raise HTTPException(status_code=404, detail="Product not found")

    update_dict = product_data.model_dump(exclude_unset=True)  # Only include provided fields

    if not update_dict:
        raise HTTPException(status_code=400, detail="No fields provided for update")

    await products_collection.update_one(
        {"_id": product_id},
        {"$set": update_dict}
    )

    updated_product = await products_collection.find_one({"_id": product_id})
    return {"message": "Product updated successfully", "product": updated_product}


