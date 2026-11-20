SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

SELECT * FROM tipo_utilizador ORDER BY tipo_utilizador_id;

SELECT * FROM preferencia ORDER BY preferencia_id;

SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.constraint_schema = kcu.constraint_schema
    AND tc.table_name = kcu.table_name
WHERE tc.table_schema = 'public'
  AND tc.table_name IN (
      'tipo_utilizador',
      'utilizador',
      'preferencia',
      'utilizador_preferencia',
      'favorito',
      'historico_atividade'
  )
ORDER BY tc.table_name, tc.constraint_type;

--- Verificar se depois de executar os testes de integridade, as tabelas estão vazias
--- Verificar utilizadores
SELECT *
FROM utilizador
ORDER BY utilizador_id;

--- Verificar preferências dos utilizadores
SELECT u.nome, p.nome AS preferencia, up.peso
FROM utilizador_preferencia up
JOIN utilizador u
    ON u.utilizador_id = up.utilizador_id
JOIN preferencia p
    ON p.preferencia_id = up.preferencia_id
ORDER BY u.nome;

--- Verificar favoritos
SELECT *
FROM favorito
ORDER BY utilizador_id, criado_em DESC;

--- Verificar histórico de atividades
SELECT *
FROM historico_atividade
ORDER BY criado_em DESC;