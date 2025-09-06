from fastapi import FastAPI,APIRouter,Request,HTTPException,Depends,status
from pydantic import BaseModel, EmailStr
from auth_service.models import LoginModel,SignupModel,User
from db.connection import db
import os
from starlette.status import HTTP_403_FORBIDDEN
from datetime import datetime,timezone
from utils import auth_util

auth_engine = APIRouter(prefix="/auth")

def verify_auth_api(request: Request):
    expected_key = os.getenv('AUTH_API')
    key_name = "x-api-key"
    print(f"Expected API key: {expected_key} | Received API key: {request.headers.get(key_name)}")
    response_key = request.headers.get(key_name)
    if expected_key != response_key:
        raise HTTPException(
            status_code=HTTP_403_FORBIDDEN,
            detail="Unauthorized access"
        )

@auth_engine.post("/email/login", dependencies=[Depends(verify_auth_api)])
async def login_api(request: LoginModel):
    try:
        user_doc = await db.user.find_one({"email": request.email})
        if not user_doc:
            return {"success": False, "message": "User not found"}
        
        user = User(**user_doc)
        
        await db.user.update_one(
            {"_id": user.id},
            {"$set": {"lastAccessed": datetime.now(timezone.utc)}}
        )
        
        is_password_valid = auth_util.verify_password(request.pwd, user.pwd)
        
        if not is_password_valid:
            return {"success": False, "message": "Password does not match"}

        token = auth_util.generate_token({
            "id": user.id,
            "name": user.name,
            "email": user.email
        })
        
        return {
            "success": True,
            "token": token,
            "session_details": {
                "id": user.id,
                "username": user.name,
                "email": user.email
            }
        }
        
    except Exception as e:
        print(f"Login error: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

