from fastapi import FastAPI,APIRouter,Request,HTTPException,Depends,status
from pydantic import BaseModel, EmailStr
from auth_service.models import LoginModel,SignupModel,User,EmailRequest,OtpModel
from db.connection import db
import os
from starlette.status import HTTP_403_FORBIDDEN
from fastapi_mail import FastMail,MessageSchema,ConnectionConfig
from datetime import datetime,timezone
from utils import auth_util
from pathlib import Path
from fastapi_mail import MessageSchema, MessageType

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

from pathlib import Path

mail_config = ConnectionConfig(
    MAIL_USERNAME="ecofinds55@gmail.com",
    MAIL_PASSWORD="ogftsmmrquuazmka", 
    MAIL_FROM="ecofinds55@gmail.com",
    MAIL_PORT=587,
    MAIL_SERVER="smtp.gmail.com",
    MAIL_STARTTLS=True,     
    MAIL_SSL_TLS=False,      
    USE_CREDENTIALS=True,
    TEMPLATE_FOLDER=Path(__file__).resolve().parent.parent / "static" / "templates"
)


@auth_engine.post("/email/login", dependencies=[Depends(verify_auth_api)])
async def login_api(request: LoginModel):
    try:
        user_doc = await db.user.find_one({"email": request.email})
        if not user_doc:
            return {"success": False, "message": "User not found"}
        
        user = User(**user_doc)
        
        is_password_valid = auth_util.verify_password(request.pwd, user.pwd)
        
        if not is_password_valid:
            return {"success": False, "message": "Password does not match"}

        
        return {
            "success": True,
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

@auth_engine.post("/email/signup", dependencies=[Depends(verify_auth_api)])
async def signup_api(response: SignupModel):
    try:
        print(response)
        email = response.email
        username = response.username
        existing_user = await db.user.find_one({"email": email})
        print(f"Existing user: {existing_user}")
        if existing_user:
            return {
                "success": False,
                "message": "User already found"
            }
        return {
            "success": True,
            "session_details": {
                "email": response.email,
                "username": response.username,
                "hashed_password": auth_util.get_password_hash(response.pwd)
            }
        }
    except Exception as e:
        print(f"Error during signup: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Invalid user data"
        )
        
@auth_engine.post("/email/signup/sendotp", dependencies=[Depends(verify_auth_api)])
async def sendotp_api(request: EmailRequest):
    email = request.email
    otp = auth_util.generate_otp()
    
    await db.otp_store.update_one(
        {"email": email}, 
        {
            "$set": {
                "otp": otp,
                "createdAt": datetime.now(timezone.utc)
            }
        },
        upsert=True
    )

    now = datetime.now(timezone.utc)


    import os

    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    logo_path = os.path.join(BASE_DIR, "..", "static", "images", "logo.png")

    message = MessageSchema(
        subject="Your OTP Code",
        recipients=[email],
        template_body={
        "otp": otp,
        "purpose": "To complete your signup",
        "date": now.strftime("%d-%B-%Y")
        },
        subtype=MessageType.html,
        attachments=[{
            "file": logo_path,
            "headers": {"Content-ID": "<logo>"}   # 👈 CID for inline
        }]
)


    
    fm = FastMail(mail_config)
    await fm.send_message(message, template_name="otp_template.html")
    
    return {"message": "OTP sent successfully"}


@auth_engine.post("/email/verifyotp", dependencies=[Depends(verify_auth_api)])
async def verifyotp_api(request: OtpModel):
    try:
        email = request.email
        otp = request.otp
        username=request.username
        
        otp_entry = await db.otp_store.find_one({"email": email, "otp": otp})
        
        if not otp_entry:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid OTP or email mismatch"
            )
        
        expiry_minutes = 10
        current_time = datetime.now(timezone.utc)
        created_at = otp_entry["createdAt"]
        
        if created_at.tzinfo is None:
            created_at = created_at.replace(tzinfo=timezone.utc)
        
        if (current_time - created_at).total_seconds() > expiry_minutes * 60:
            await db.otp_store.delete_one({"email": email, "otp": otp})
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="OTP expired"
            )
        
        return {
            "success": True,
            "message": "OTP verified successfully",
            "otp": otp,
            "email": email,
            "userid":await auth_util.generate_userid(username,db)
        }
        
    except HTTPException as he:
        raise he
    except Exception as e:
        print(f"OTP verification error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"OTP verification failed: {str(e)}")