from fastapi import APIRouter, Request, HTTPException, Depends
from starlette.status import HTTP_403_FORBIDDEN
from pymongo.collection import Collection
from db.connection import get_db
from user_services.models import UserModel
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
def create_user(user: UserModel, db=Depends(get_db)):
    users_collection = db["user"]
    if users_collection.find_one({"_id": user._id}):
        raise HTTPException(status_code=400, detail="User already exists")
    user_dict = user.model_dump(by_alias=True)
    users_collection.insert_one(user_dict)
    return {"message": "User created successfully", "user": user_dict}


@user_route.patch("/updateuser", dependencies=[Depends(verify_api)])
def update_user(user: UserModel, db=Depends(get_db)):
    users_collection = db["user"]
    existing_user = users_collection.find_one({"_id": user._id})
    if not existing_user:
        raise HTTPException(status_code=404, detail="User not found")

    user_dict = user.model_dump()

    user_dict.pop("_id", None)

    users_collection.update_one(
        {"_id": user._id},
        {"$set": user_dict}
    )

    updated_user = users_collection.find_one({"_id": user._id})
    return {"message": "User updated successfully", "user": updated_user}
