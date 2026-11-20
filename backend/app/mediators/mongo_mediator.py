import re
from typing import Any


class MongoMediator:
    def __init__(self, database: Any) -> None:
        self._database = database

    @staticmethod
    def _document(document: dict[str, Any]) -> dict[str, Any]:
        result = dict(document)
        result["id"] = str(result.pop("_id"))
        return result

    def obter_destinos(self, limite: int = 100) -> list[dict[str, Any]]:
        documentos = self._database.destinos.find({}).sort("nome", 1).limit(limite)
        return [self._document(documento) for documento in documentos]

    def obter_destino(self, destino_id: str) -> dict[str, Any] | None:
        documento = self._database.destinos.find_one({"_id": destino_id})
        if documento is None:
            return None
        return self._document(documento)

    def obter_pois(
        self,
        ids: list[str] | None = None,
        destino_id: str | None = None,
        tipo: str | None = None,
        termo: str | None = None,
        limite: int = 100,
    ) -> list[dict[str, Any]]:
        filtro: dict[str, Any] = {}
        if ids is not None:
            filtro["_id"] = {"$in": ids}
        if destino_id:
            filtro["destino_id"] = destino_id
        if tipo:
            filtro["tipo"] = tipo
        if termo:
            expressao = {"$regex": re.escape(termo), "$options": "i"}
            filtro["$or"] = [{"nome": expressao}, {"descricao": expressao}, {"tipo": expressao}]
        documentos = self._database.pois.find(filtro).sort("nome", 1).limit(limite)
        return [self._document(documento) for documento in documentos]

    def obter_poi(self, poi_id: str) -> dict[str, Any] | None:
        documento = self._database.pois.find_one({"_id": poi_id})
        if documento is None:
            return None
        return self._document(documento)

    def pois_perto(
        self,
        latitude: float,
        longitude: float,
        raio_m: int,
        tipo: str | None = None,
        limite: int = 100,
    ) -> list[dict[str, Any]]:
        filtro: dict[str, Any] = {
            "localizacao": {
                "$near": {
                    "$geometry": {
                        "type": "Point",
                        "coordinates": [longitude, latitude],
                    },
                    "$maxDistance": raio_m,
                }
            }
        }
        if tipo:
            filtro["tipo"] = tipo
        documentos = self._database.pois.find(filtro).limit(limite)
        return [self._document(documento) for documento in documentos]

    def reviews_do_alvo(
        self,
        alvo_tipo: str,
        alvo_id: str,
        limite: int = 20,
    ) -> list[dict[str, Any]]:
        filtro = {"alvo_tipo": alvo_tipo, "alvo_id": alvo_id}
        documentos = self._database.reviews.find(filtro).sort("criado_em", -1).limit(limite)
        return [self._document(documento) for documento in documentos]
