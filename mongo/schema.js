const turismo = db.getSiblingDB("smart_tourism");

const pontoGeoJSON = {
  bsonType: "object",
  required: ["type", "coordinates"],
  properties: {
    type: { enum: ["Point"] },
    coordinates: {
      bsonType: "array",
      minItems: 2,
      maxItems: 2,
      items: { bsonType: ["double", "int", "long", "decimal"] },
    },
  },
};

const validadores = {
  destinos: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "nome", "pais", "centro"],
      properties: {
        _id: { bsonType: "string" },
        nome: { bsonType: "string", minLength: 1 },
        pais: { bsonType: "string", minLength: 1 },
        regiao: { bsonType: "string" },
        descricao: { bsonType: "string" },
        centro: pontoGeoJSON,
        area: { bsonType: "object", properties: { type: { enum: ["Polygon"] } } },
        tags: { bsonType: "array", items: { bsonType: "string" } },
        melhor_epoca: { bsonType: "array", items: { bsonType: "string" } },
        n_pois: { bsonType: ["int", "long"], minimum: 0 },
        rating_medio: { bsonType: ["double", "int", "long", "decimal", "null"], minimum: 1, maximum: 5 },
        n_reviews: { bsonType: ["int", "long"], minimum: 0 },
        reviews_recentes: { bsonType: "array" },
        atualizado_em: { bsonType: "date" },
      },
    },
  },
  pois: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "destino_id", "nome", "tipo", "localizacao"],
      properties: {
        _id: { bsonType: "string" },
        destino_id: { bsonType: "string" },
        destino_nome: { bsonType: "string" },
        nome: { bsonType: "string", minLength: 1 },
        tipo: { bsonType: "string", minLength: 1 },
        categorias: { bsonType: "array", items: { bsonType: "string" } },
        localizacao: pontoGeoJSON,
        descricao: { bsonType: "string" },
        preco_nivel: { bsonType: ["int", "long"], minimum: 0, maximum: 4 },
        atributos: { bsonType: "array" },
        imagens: { bsonType: "array", items: { bsonType: "string" } },
        rating_medio: { bsonType: ["double", "int", "long", "decimal", "null"], minimum: 1, maximum: 5 },
        n_reviews: { bsonType: ["int", "long"], minimum: 0 },
        reviews_recentes: { bsonType: "array" },
        atualizado_em: { bsonType: "date" },
      },
    },
  },
  reviews: {
    $jsonSchema: {
      bsonType: "object",
      required: ["utilizador_id", "alvo_tipo", "alvo_id", "rating", "comentario", "criado_em", "atualizado_em"],
      properties: {
        utilizador_id: { bsonType: ["int", "long"] },
        utilizador_nome: { bsonType: "string" },
        alvo_tipo: { enum: ["DESTINO", "POI"] },
        alvo_id: { bsonType: "string", minLength: 1 },
        rating: { bsonType: ["int", "long"], minimum: 1, maximum: 5 },
        comentario: { bsonType: "string" },
        criado_em: { bsonType: "date" },
        atualizado_em: { bsonType: "date" },
      },
    },
  },
};

for (const [nome, validator] of Object.entries(validadores)) {
  const existe = turismo.getCollectionInfos({ name: nome }).length > 0;
  if (existe) {
    turismo.runCommand({
      collMod: nome,
      validator,
      validationLevel: "strict",
      validationAction: "error",
    });
  } else {
    turismo.createCollection(nome, {
      validator,
      validationLevel: "strict",
      validationAction: "error",
    });
  }
}

turismo.pois.createIndex({ localizacao: "2dsphere" }, { name: "idx_pois_localizacao" });
turismo.pois.createIndex({ destino_id: 1, tipo: 1 }, { name: "idx_pois_destino_tipo" });
turismo.pois.createIndex({ "atributos.k": 1, "atributos.v": 1 }, { name: "idx_pois_atributos" });
turismo.pois.createIndex({ rating_medio: -1 }, { name: "idx_pois_rating" });
turismo.destinos.createIndex({ centro: "2dsphere" }, { name: "idx_destinos_centro" });
turismo.destinos.createIndex({ nome: 1 }, { unique: true, name: "uq_destinos_nome" });
turismo.reviews.createIndex(
  { utilizador_id: 1, alvo_tipo: 1, alvo_id: 1 },
  { unique: true, name: "uq_reviews_utilizador_alvo" },
);
turismo.reviews.createIndex(
  { alvo_tipo: 1, alvo_id: 1, criado_em: -1 },
  { name: "idx_reviews_alvo_data" },
);
