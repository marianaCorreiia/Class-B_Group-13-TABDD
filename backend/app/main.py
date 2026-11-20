import os
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Literal

from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException, Query, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from pymongo import MongoClient
from pymongo.errors import PyMongoError

from app.mediators import MongoMediator

PROJECT_ROOT = Path(__file__).resolve().parents[2]
FRONTEND_DIR = PROJECT_ROOT / "frontend"
load_dotenv(PROJECT_ROOT / "mongo" / "atlas-credentials.env")


@asynccontextmanager
async def lifespan(application: FastAPI):
    uri = os.getenv("MONGODB_URI")
    application.state.mongo_client = MongoClient(uri) if uri else None
    try:
        yield
    finally:
        client = application.state.mongo_client
        if client is not None:
            client.close()


app = FastAPI(title="Smart Tourism", lifespan=lifespan)


def get_mongo_mediator(request: Request) -> MongoMediator:
    client = request.app.state.mongo_client
    if client is None:
        raise HTTPException(status_code=503, detail="MONGODB_URI não está configurada.")
    database_name = os.getenv("MONGODB_DATABASE", "smart_tourism")
    return MongoMediator(client[database_name])


@app.exception_handler(PyMongoError)
async def handle_mongo_error(request: Request, error: PyMongoError) -> JSONResponse:
    return JSONResponse(
        status_code=503,
        content={"detail": "Não foi possível comunicar com o MongoDB."},
    )


@app.get("/api/health")
def health(request: Request) -> dict[str, str]:
    client = request.app.state.mongo_client
    if client is None:
        raise HTTPException(status_code=503, detail="MONGODB_URI não está configurada.")
    client.admin.command("ping")
    return {"status": "ok"}


@app.get("/api/destinations")
def destinations(
    mediator: MongoMediator = Depends(get_mongo_mediator),
) -> list[dict]:
    return mediator.obter_destinos()


@app.get("/api/pois/near")
def nearby_pois(
    latitude: float = Query(ge=-90, le=90),
    longitude: float = Query(ge=-180, le=180),
    raio_m: int = Query(default=2000, gt=0, le=50000),
    tipo: str | None = Query(default=None, max_length=50),
    limite: int = Query(default=50, ge=1, le=100),
    mediator: MongoMediator = Depends(get_mongo_mediator),
) -> list[dict]:
    return mediator.pois_perto(latitude, longitude, raio_m, tipo, limite)


@app.get("/api/pois")
def pois(
    destino_id: str | None = Query(default=None, max_length=64),
    tipo: str | None = Query(default=None, max_length=50),
    termo: str | None = Query(default=None, min_length=2, max_length=100),
    limite: int = Query(default=50, ge=1, le=100),
    mediator: MongoMediator = Depends(get_mongo_mediator),
) -> list[dict]:
    return mediator.obter_pois(destino_id, None, tipo, termo, limite)


@app.get("/api/pois/{poi_id}")
def poi(
    poi_id: str,
    mediator: MongoMediator = Depends(get_mongo_mediator),
) -> dict:
    resultado = mediator.obter_poi(poi_id)
    if resultado is None:
        raise HTTPException(status_code=404, detail="POI não encontrado.")
    return resultado


@app.get("/api/reviews")
def reviews(
    alvo_tipo: Literal["POI", "DESTINO"],
    alvo_id: str = Query(min_length=1, max_length=64),
    limite: int = Query(default=20, ge=1, le=50),
    mediator: MongoMediator = Depends(get_mongo_mediator),
) -> list[dict]:
    return mediator.reviews_do_alvo(alvo_tipo, alvo_id, limite)


app.mount("/", StaticFiles(directory=FRONTEND_DIR, html=True), name="frontend")
