-- =====================================================
-- Consultas SQL para a base de dados do projeto TABDD
-- =====================================================

--- Consultar os utilizadores e os seus tipos
SELECT
    u.utilizador_id,
    u.nome,
    u.email,
    t.nome AS tipo_utilizador
FROM utilizador u
JOIN tipo_utilizador t
    ON u.tipo_utilizador_id = t.tipo_utilizador_id;


--- Consultar as preferências de um utilizador específico
SELECT
    p.nome AS preferencia,
    up.peso
FROM utilizador_preferencia up
JOIN preferencia p
    ON up.preferencia_id = p.preferencia_id
WHERE up.utilizador_id = 1
ORDER BY up.peso DESC;

--- Consultar os destinos favoritos de um utilizador específico
SELECT
    destino_id,
    criado_em
FROM favorito
WHERE utilizador_id = 1
ORDER BY criado_em DESC;

--- Consultar o histórico de atividade de um utilizador específico
SELECT
    tipo,
    alvo_tipo,
    alvo_id,
    termo_pesquisa,
    criado_em
FROM historico_atividade
WHERE utilizador_id = 1
ORDER BY criado_em DESC 
LIMIT 50;

--- Consultar o número total de atividades por utilizador
SELECT
    u.nome,
    COUNT(h.atividade_id) AS total_atividades
FROM utilizador u
LEFT JOIN historico_atividade h
    ON u.utilizador_id = h.utilizador_id
GROUP BY u.utilizador_id, u.nome
ORDER BY total_atividades DESC;

--- Consultar os utilizadores com base nas suas preferências
SELECT
    u.nome,
    p.nome AS preferencia,
    up.peso
FROM utilizador u
JOIN utilizador_preferencia up
    ON u.utilizador_id = up.utilizador_id
JOIN preferencia p
    ON up.preferencia_id = p.preferencia_id
WHERE p.nome = 'História e Património';