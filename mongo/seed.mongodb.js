use('smart_tourism');

const agora = new Date();

db.destinos.updateOne(
  { _id: 'dest_porto' },
  { $set: {
    nome: 'Porto',
    pais: 'Portugal',
    regiao: 'Norte',
    descricao: 'Uma cidade de ruas históricas, miradouros e vida junto ao Douro.',
    centro: { type: 'Point', coordinates: [-8.6109, 41.1496] },
    tags: ['cidade', 'cultura', 'gastronomia'],
    melhor_epoca: ['primavera', 'outono'],
    n_pois: 3,
    atualizado_em: agora,
  } },
  { upsert: true },
);

db.pois.updateOne(
  { _id: 'poi_clerigos' },
  { $set: {
    destino_id: 'dest_porto',
    destino_nome: 'Porto',
    nome: 'Torre dos Clérigos',
    tipo: 'monumento',
    categorias: ['arquitetura', 'história', 'miradouro'],
    localizacao: { type: 'Point', coordinates: [-8.614, 41.1456] },
    morada: { cidade: 'Porto' },
    descricao: 'Torre barroca com vista panorâmica sobre o centro histórico do Porto.',
    preco_nivel: 2,
    atributos: [{ k: 'acesso', v: 'escadas' }],
    imagens: [],
    atualizado_em: agora,
  } },
  { upsert: true },
);

db.pois.updateOne(
  { _id: 'poi_lello' },
  { $set: {
    destino_id: 'dest_porto',
    destino_nome: 'Porto',
    nome: 'Livraria Lello',
    tipo: 'livraria',
    categorias: ['livros', 'arquitetura', 'cultura'],
    localizacao: { type: 'Point', coordinates: [-8.6146, 41.1468] },
    morada: { cidade: 'Porto' },
    descricao: 'Livraria histórica conhecida pela escadaria e pela arquitetura neogótica.',
    preco_nivel: 2,
    atributos: [{ k: 'reserva', v: true }],
    imagens: [],
    atualizado_em: agora,
  } },
  { upsert: true },
);

db.pois.updateOne(
  { _id: 'poi_bolhao' },
  { $set: {
    destino_id: 'dest_porto',
    destino_nome: 'Porto',
    nome: 'Mercado do Bolhão',
    tipo: 'mercado',
    categorias: ['gastronomia', 'comércio', 'cultura'],
    localizacao: { type: 'Point', coordinates: [-8.6048, 41.1497] },
    morada: { cidade: 'Porto' },
    descricao: 'Mercado tradicional para descobrir produtos e sabores do Porto.',
    preco_nivel: 0,
    atributos: [{ k: 'entrada', v: 'gratuita' }],
    imagens: [],
    atualizado_em: agora,
  } },
  { upsert: true },
);

db.reviews.updateOne(
  { utilizador_id: 1001, alvo_tipo: 'POI', alvo_id: 'poi_clerigos' },
  { $set: {
    utilizador_nome: 'Inês',
    rating: 5,
    comentario: 'A vista compensa a subida. Vale a pena ir com tempo.',
    atualizado_em: new Date('2026-10-12T10:00:00Z'),
  }, $setOnInsert: { criado_em: new Date('2026-10-12T10:00:00Z') } },
  { upsert: true },
);

db.reviews.updateOne(
  { utilizador_id: 1002, alvo_tipo: 'POI', alvo_id: 'poi_bolhao' },
  { $set: {
    utilizador_nome: 'Miguel',
    rating: 4,
    comentario: 'Bom sítio para provar produtos locais e observar o movimento da cidade.',
    atualizado_em: new Date('2026-10-18T12:30:00Z'),
  }, $setOnInsert: { criado_em: new Date('2026-10-18T12:30:00Z') } },
  { upsert: true },
);

console.log('Dados de demonstração de smart_tourism preparados.');
