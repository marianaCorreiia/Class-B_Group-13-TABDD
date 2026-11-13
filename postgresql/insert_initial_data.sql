-- =====================================================
-- Tipos de utilizador e preferências
-- =====================================================

INSERT INTO tipo_utilizador (nome, descricao)
VALUES
('Turista', 'Utilizador que explora destinos e utiliza as funcionalidades turísticas.'),
('Administrador','Responsável pela administração e gestão da plataforma.'),
('Gestor de conteúdos','Responsável pela gestão e atualização dos conteúdos turísticos.');

INSERT INTO preferencia (nome)
VALUES
('História e Património'),
('Museus e Arte'),
('Natureza'),
('Gastronomia'),
('Arquitetura'),
('Praias e Lazer'),
('Cultura e Entretenimento'),
('Desporto e Atividades'),
('Religião'),
('Miradouros e Paisagens');