from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class ProductModel(BaseModel):
    id: Optional[str] = Field(default=None, alias="_id", description="ID must be a string")
    name: str = Field(..., description="Product name must be a string")
    seller_id: str = Field(..., description="Seller ID must be a string")
    category: str = Field(..., description="Category must be a string")
    price: float = Field(..., description="Price must be a float/double")
    status: str = Field(..., description="Status must be a string")
    description: str = Field(..., description="Description must be a string")
    created_at: datetime = Field(..., description="Created_at must be a timestamp/date")
    updated_at: datetime = Field(..., description="Updated_at must be a timestamp/date")
    images: List[str] = Field(..., description="Images must be an array of strings")

    class Config:
        allow_population_by_field_name = True
        
class ProductUpdateModel(BaseModel):
    name: Optional[str] = None
    seller_id: Optional[str] = None
    category: Optional[str] = None
    price: Optional[float] = None
    status: Optional[str] = None
    description: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    images: Optional[List[str]] = None

