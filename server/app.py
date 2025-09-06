from fastapi import FastAPI
from user_services.routes import user_route 
from auth_service.routes import auth_engine 
app = FastAPI()

@app.get("/hello")
def hello_world():
    return {
        "messge" : "hello world"
    }

app.include_router(user_route)
app.include_router(auth_engine)
from browsing_services.routes import browse_engine
app.include_router(browse_engine)