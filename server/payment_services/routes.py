from fastapi import APIRouter, Request, HTTPException, Depends
from starlette.status import HTTP_403_FORBIDDEN
from db.connection import get_db
from payment_services.models import PaymentModel
import os

payment_route = APIRouter(prefix="/payment")

def verify_api(request: Request):
    expected_key = os.getenv("AUTH_API")
    key_name = "x-api-key"
    received_key = request.headers.get(key_name)
    if expected_key != received_key:
        raise HTTPException(
            status_code=HTTP_403_FORBIDDEN,
            detail="Unauthorized access"
        )

@payment_route.post("/add", dependencies=[Depends(verify_api)])
async def add_payment(payment: PaymentModel, db=Depends(get_db)):
    payments_collection = db["payments"]

    payment_dict = payment.model_dump()
    result = await payments_collection.insert_one(payment_dict)

    return {
        "message": "Payment added successfully",
        "payment_id": str(result.inserted_id),
        "payment": payment_dict
    }