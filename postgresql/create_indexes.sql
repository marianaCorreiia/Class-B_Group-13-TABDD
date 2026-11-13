-- =====================================================
-- Índices adicionais para otimizar consultas
-- =====================================================

-- Histórico recente de um utilizador
CREATE INDEX idx_hist_user_data
ON historico_atividade (
    utilizador_id,
    criado_em DESC
);

-- Pesquisa por preferência
CREATE INDEX idx_up_preferencia
ON utilizador_preferencia(preferencia_id);

-- Pesquisa de favoritos por destino
CREATE INDEX idx_favorito_destino
ON favorito(destino_id);