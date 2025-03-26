# Application main file
from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pythonjsonlogger.json import JsonFormatter
from datetime import datetime
from logger import LogMiddleware

app = FastAPI()
app.add_middleware(LogMiddleware)

@app.get("/")
async def hello_world():
    response = {"message": "I'm sorry, Mario, but your princess is in another castle!"}
    return JSONResponse(content=response, status_code=404)

@app.get("/hello_world")
async def hello_world():
    response = {"message": "Hello World!"}
    return JSONResponse(content=response)

@app.get("/current_time")
async def current_time(name: str):
    response = {"message": f"Hello {name}", "timestamp": datetime.now().timestamp()}
    return JSONResponse(content=response)

@app.get("/healthcheck")
async def healthcheck():
    return JSONResponse(content={})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_config="logging.ini")
