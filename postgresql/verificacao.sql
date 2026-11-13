SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

SELECT * FROM tipo_utilizador ORDER BY tipo_utilizador_id;

SELECT * FROM preferencia ORDER BY preferencia_id;
