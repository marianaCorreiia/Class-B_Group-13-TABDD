-- =====================================================
-- Dados de teste para a base de dados do projeto TABDD
-- =====================================================

-- Criar utilizadores de teste
INSERT INTO utilizador
    (tipo_utilizador_id, nome, email, password_hash, pais_origem)
VALUES
(
    (SELECT tipo_utilizador_id
     FROM tipo_utilizador
     WHERE nome = 'Turista'),
    'Ana Silva',
    'ana.teste@example.com',
    'HASH_DE_TESTE_ANA',
    'PT'
),
(
    (SELECT tipo_utilizador_id
     FROM tipo_utilizador
     WHERE nome = 'Administrador'),
    'João Costa',
    'joao.teste@example.com',
    'HASH_DE_TESTE_JOAO',
    'PT'
),
(
    (SELECT tipo_utilizador_id
     FROM tipo_utilizador
     WHERE nome = 'Gestor de conteúdos'),
    'Maria Santos',
    'maria.teste@example.com',
    'HASH_DE_TESTE_MARIA',
    'ES'
);

--- Associar preferências aos utilizadores de teste
INSERT INTO utilizador_preferencia(utilizador_id, preferencia_id, peso)
SELECT
    u.utilizador_id,
    p.preferencia_id,
    5
FROM utilizador u
CROSS JOIN preferencia p
WHERE u.email = 'ana.teste@example.com'
  AND p.nome IN (
      'História e Património',
      'Museus e Arte'
  );

--- Associar destinos favoritos aos utilizadores de teste
INSERT INTO favorito (utilizador_id, destino_id)
SELECT utilizador_id, 'DESTINO_TESTE_001'
FROM utilizador
WHERE email = 'ana.teste@example.com';

--- Inserir histórico de atividade para os utilizadores de teste
INSERT INTO historico_atividade(utilizador_id, tipo, alvo_tipo, alvo_id)
SELECT
    utilizador_id,
    'VISTA',
    'DESTINO',
    'DESTINO_TESTE_001'
FROM utilizador
WHERE email = 'ana.teste@example.com';

--- Inserir histórico de pesquisa para os utilizadores de teste
INSERT INTO historico_atividade(utilizador_id, tipo, termo_pesquisa)
SELECT
    utilizador_id,
    'PESQUISA',
    'Museus no Porto'
FROM utilizador
WHERE email = 'ana.teste@example.com';