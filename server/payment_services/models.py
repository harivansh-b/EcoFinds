from pydantic import BaseModel, Field
from typing import Literal

class PaymentModel(BaseModel):
    order_id: str = Field(..., description="order_id must be of type string")
    amount: float = Field(..., ge=0, description="amount must be a non-negative number")
    status: Literal["pending", "completed", "failed", "refunded"] = Field(
        ..., description="status must be one of: pending, completed, failed, refunded"
    )
