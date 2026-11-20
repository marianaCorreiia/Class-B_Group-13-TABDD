import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.mediators.mongo_mediator import MongoMediator


class MongoMediatorTests(unittest.TestCase):
    def setUp(self) -> None:
        self.database = MagicMock()
        self.mediator = MongoMediator(self.database)

    def test_pois_filtra_tipo_termo_e_destino(self) -> None:
        cursor = self.database.pois.find.return_value.sort.return_value
        cursor.limit.return_value = [{"_id": "poi_1", "nome": "Museu"}]

        resultado = self.mediator.obter_pois(
            destino_id="dest_porto",
            tipo="museu",
            termo="arte",
        )

        self.database.pois.find.assert_called_once_with(
            {
                "destino_id": "dest_porto",
                "tipo": "museu",
                "$or": [
                    {"nome": {"$regex": "arte", "$options": "i"}},
                    {"descricao": {"$regex": "arte", "$options": "i"}},
                    {"tipo": {"$regex": "arte", "$options": "i"}},
                ],
            }
        )
        self.assertEqual(resultado, [{"id": "poi_1", "nome": "Museu"}])

    def test_pois_perto_usa_geojson_longitude_latitude(self) -> None:
        self.database.pois.find.return_value.limit.return_value = []

        self.mediator.pois_perto(41.15, -8.61, 2000, "museu")

        self.database.pois.find.assert_called_once_with(
            {
                "localizacao": {
                    "$near": {
                        "$geometry": {
                            "type": "Point",
                            "coordinates": [-8.61, 41.15],
                        },
                        "$maxDistance": 2000,
                    }
                },
                "tipo": "museu",
            }
        )

    def test_reviews_sao_ordenadas_da_mais_recente(self) -> None:
        self.database.reviews.find.return_value.sort.return_value.limit.return_value = []

        self.mediator.reviews_do_alvo("POI", "poi_1")

        self.database.reviews.find.return_value.sort.assert_called_once_with("criado_em", -1)


if __name__ == "__main__":
    unittest.main()
