from fastapi import FastAPI
from user_services.routes import user_route 

app = FastAPI()

@app.get("/hello")
def hello_world():
    return {
        "messge" : "hello world"
    }

app.include_router(user_route)
