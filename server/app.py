from fastapi import FastAPI
from user_services.routes import user_route 
from auth_service.routes import auth_engine 
from product_services.routes import product_route
from media_services.routes import image_route
app = FastAPI()

@app.get("/hello")
def hello_world():
    return {
        "messge" : "hello world"
    }

app.include_router(user_route)
app.include_router(auth_engine)
<<<<<<< HEAD
from browsing_services.routes import browse_engine
app.include_router(browse_engine)
=======
app.include_router(product_route)
app.include_router(image_route)
>>>>>>> 65414d2b0314f7f7cdc1616128fc7ad1a5cbbea8
