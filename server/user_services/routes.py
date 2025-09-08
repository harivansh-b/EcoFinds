from fastapi import APIRouter, Request, HTTPException, Depends
from starlette.status import HTTP_403_FORBIDDEN
from pymongo.collection import Collection
from db.connection import get_db
from user_services.models import UserModel , UpdateUserModel
import os

user_route = APIRouter(prefix="/user")

def verify_api(request: Request):
    expected_key = os.getenv('AUTH_API')
    key_name = "x-api-key"
    received_key = request.headers.get(key_name)
    print(f"Expected API key: {expected_key} | Received API key: {received_key}")
    if expected_key != received_key:
        raise HTTPException(
            status_code=HTTP_403_FORBIDDEN,
            detail="Unauthorized access"
        )

@user_route.put("/createuser", dependencies=[Depends(verify_api)])
async def create_user(user: UserModel, db=Depends(get_db)):
    users_collection = db["user"]

    existing_user = await users_collection.find_one({"_id": user.id})
    print("Existing user found in DB:", existing_user)

    if existing_user:
        raise HTTPException(status_code=400, detail="User already exists")

    user_dict = user.model_dump(by_alias=True)
    print("Inserting user into DB:", user_dict)

    await users_collection.insert_one(user_dict)
    return {"message": "User created successfully", "user": user_dict}


@user_route.patch("/updateuser", dependencies=[Depends(verify_api)])
async def update_user(user: UpdateUserModel, db=Depends(get_db)):
    users_collection = db["user"]

    existing_user = await users_collection.find_one({"_id": user.id})
    if not existing_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user_dict = user.model_dump(by_alias=True)
    
    user_dict.pop("_id", None)

    await users_collection.update_one(
        {"_id": user.id},
        {"$set": user_dict}
    )

    updated_user = await users_collection.find_one({"_id": user.id})

    return {"message": "User updated successfully", "user": updated_user}



@user_route.get("/getuser/{user_id}", dependencies=[Depends(verify_api)])
async def get_user(user_id: str, db=Depends(get_db)):
    users_collection = db['user']
    user_data = await users_collection.find_one({"_id": user_id})

    if not user_data:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )
    
    return user_data

@user_route.get("/user/{user_id}/confirmed-items", dependencies=[Depends(verify_api)])
async def get_confirmed_items(user_id: str, db=Depends(get_db)):
    orders_collection = db["orders"]

    count = await orders_collection.count_documents({
        "user_id": user_id,
        "status": "confirmed"
    })

    return {"user_id": user_id, "confirmed_items": count}
