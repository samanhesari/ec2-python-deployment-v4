from fastapi import FastAPI


app = FastAPI(
    title="V4 FastAPI CRUD Application",
    description="A simple FastAPI application for learning DevOps and CRUD development.",
    version="4.0.0",
)


@app.get("/")
def root():
    return {
        "message": "Hello, World!",
        "version": "4.0.0",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy",
    }