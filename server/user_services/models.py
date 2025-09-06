from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional

class UserModel(BaseModel):
    id: str = Field(..., alias="_id", description="id must be of type string")
    name: str = Field(..., description="name must be of type string")
    pwd: str = Field(..., description="password must be of type string")
    email: EmailStr = Field(..., description="email must be of type string")
    location: str = Field(..., description="location must be of type string")
    lattitude: str = Field(..., description="lattitude must be of type string")
    longitude: str = Field(..., description="longitude must be of type string")  
    createdAt: datetime = Field(..., description="createdAt must be of type date")
    phoneno: str = Field(..., description="phoneno must be of type string")
    profilePic: str = Field(..., description="GridFS file ObjectId as string")  

class UpdateUserModel(BaseModel):
    id: str = Field(..., alias="user_id")  # <-- required
    address: Optional[str] = None
    latitude: Optional[str] = None
    longitude: Optional[str] = None

    class Config:
        populate_by_name = True  # lets you send "id" or "user_id"