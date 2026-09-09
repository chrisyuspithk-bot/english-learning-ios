from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from .config import BASE_DIR
from .database import Base, engine
from .routers import admin, app_api, auth, textbooks
from .seed import seed_if_empty

Base.metadata.create_all(bind=engine)
seed_if_empty()

app = FastAPI(title="English Learning Portal API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(admin.router)
app.include_router(textbooks.router)
app.include_router(app_api.router)


@app.get("/api/health")
def health():
    return {"service": "English Learning Portal API", "status": "ok"}


# Serve the built React admin portal from the same origin (single-server deploy).
FRONTEND_DIST = BASE_DIR.parent / "frontend" / "dist"
if (FRONTEND_DIST / "index.html").exists():
    app.mount("/assets", StaticFiles(directory=FRONTEND_DIST / "assets"), name="assets")

    @app.get("/")
    def index():
        return FileResponse(FRONTEND_DIST / "index.html")

else:

    @app.get("/")
    def root():
        return {"service": "English Learning Portal API", "docs": "/docs", "health": "ok"}
