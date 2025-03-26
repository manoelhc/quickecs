FROM python:3.13.2-slim-bookworm AS stage

COPY ./gentle_api /app
WORKDIR /app
RUN pip install uv
RUN uv sync
RUN useradd -ms /bin/sh -d /app apprunner
USER apprunner

FROM python:3.13.2-slim-bookworm AS prepare
COPY --from=stage /app /app
COPY --from=stage /etc/passwd /etc/passwd
COPY --from=stage /etc/group /etc/group

FROM scratch AS final
COPY --from=prepare / /
USER apprunner
EXPOSE 8000
CMD [ \
      "/app/.venv/bin/uvicorn", \
        "--app-dir",    "/app",  \
        "--host",       "0.0.0.0", \ 
        "--port",       "8000", \
        "--log-config", "/app/logging.ini", \
        "main:app" \
    ]