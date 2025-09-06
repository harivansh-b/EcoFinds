from pydantic import BaseModel, Field
from typing import Literal

class CartAddModel(BaseModel):
    user_id: str = Field(..., description="ID of the user adding the product to cart")
    product_id: str = Field(..., description="ID of the product to add to cart")
    status: Literal["selected", "unselected", "sold"] = Field(
        "selected", description="Status of the cart item"
    )
class CartUpdateModel(BaseModel):
    status: Literal["selected", "unselected", "sold"]