from pydantic import BaseModel,Field,EmailStr
from datetime import datetime
from bson import Int64


class User(BaseModel):
    id: str = Field(..., alias="_id", description="User unique id")
    name: str = Field(..., description="Username")
    pwd: str = Field(..., description="Password")
    email: EmailStr = Field(..., description="Email")
    location: str = Field(..., description="Location")
    createdAt: datetime = Field(..., description="User signup time")
    phoneno: str = Field(..., description="Phone number")
    profilePic: str = Field(..., description="Profile picture URL")

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True

class LoginModel(BaseModel):
    email: str
    pwd: str

class SignupModel(BaseModel):
    email: str
    username: str
    pwd: str

class UserModel(BaseModel):
    email: str
    username: str
    pwd: str
    otp: str

class EmailRequest(BaseModel):
    email: str

class UpdatePassword(BaseModel):
    email:str
    pwd:str
    otp:str
    
class OtpModel(BaseModel):
    email: str
    otp: str