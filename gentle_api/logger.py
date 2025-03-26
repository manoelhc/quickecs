import json
import logging
from logging import Formatter
from starlette.middleware.base import BaseHTTPMiddleware
import time

class JsonFormatter(Formatter):
    def __init__(self):
        super(JsonFormatter, self).__init__()

    def format(self, record):
        json_record = {}
        json_record["timestamp"] = time.time()
        json_record["message"] = record.getMessage()
        if "req" in record.__dict__:
            json_record["req"] = record.__dict__["req"]
        if "res" in record.__dict__:
            json_record["res"] = record.__dict__["res"]
        if record.levelno == logging.ERROR and record.exc_info:
            json_record["err"] = self.formatException(record.exc_info)
        return json.dumps(json_record)

class Logger:
    @classmethod
    def get_logger(cls):
        if not hasattr(cls, "_logger"):
            cls._logger = logging.root
            handler = logging.StreamHandler()
            handler.setFormatter(JsonFormatter())
            cls._logger.handlers = [handler]
            cls._logger.setLevel(logging.DEBUG)

            logging.getLogger("uvicorn.access").disabled = True

        return cls._logger

class LogMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        Logger.get_logger().info(
            "Incoming request",
            extra={
                "req": { "method": request.method, "url": str(request.url) },
                "res": { "status_code": response.status_code, },
            },
        )
        return response
