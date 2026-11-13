-- =====================================================
-- Criação das tabelas do banco de dados para o projeto TABDD
-- =====================================================
-- =====================================================
-- 1. TABELA: TIPO_UTILIZADOR
-- =====================================================

CREATE TABLE tipo_utilizador (
    tipo_utilizador_id SMALLINT
        GENERATED ALWAYS AS IDENTITY,

    nome VARCHAR(50) NOT NULL,
    descricao TEXT,

    CONSTRAINT pk_tipo_utilizador
        PRIMARY KEY (tipo_utilizador_id),

    CONSTRAINT uq_tipo_utilizador_nome
        UNIQUE (nome)
);


-- =====================================================
-- 2. TABELA: UTILIZADOR
-- =====================================================

CREATE TABLE utilizador (
    utilizador_id INT
        GENERATED ALWAYS AS IDENTITY,

    tipo_utilizador_id SMALLINT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    pais_origem CHAR(2),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pk_utilizador
        PRIMARY KEY (utilizador_id),

    CONSTRAINT uq_utilizador_email
        UNIQUE (email),

    CONSTRAINT fk_utilizador_tipo
        FOREIGN KEY (tipo_utilizador_id)
        REFERENCES tipo_utilizador(tipo_utilizador_id),

    CONSTRAINT chk_pais_origem
        CHECK (
            pais_origem IS NULL
            OR pais_origem ~ '^[A-Z]{2}$'
        )
);


-- =====================================================
-- 3. TABELA: PREFERENCIA
-- =====================================================

CREATE TABLE preferencia (
    preferencia_id SMALLINT
        GENERATED ALWAYS AS IDENTITY,

    nome VARCHAR(50) NOT NULL,

    CONSTRAINT pk_preferencia
        PRIMARY KEY (preferencia_id),

    CONSTRAINT uq_preferencia_nome
        UNIQUE (nome)
);


-- =====================================================
-- 4. TABELA: UTILIZADOR_PREFERENCIA
-- =====================================================

CREATE TABLE utilizador_preferencia (
    utilizador_id INT NOT NULL,
    preferencia_id SMALLINT NOT NULL,
    peso SMALLINT NOT NULL DEFAULT 3,

    CONSTRAINT pk_utilizador_preferencia
        PRIMARY KEY (utilizador_id, preferencia_id),

    CONSTRAINT fk_up_utilizador
        FOREIGN KEY (utilizador_id)
        REFERENCES utilizador(utilizador_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_up_preferencia
        FOREIGN KEY (preferencia_id)
        REFERENCES preferencia(preferencia_id),

    CONSTRAINT chk_preferencia_peso
        CHECK (peso BETWEEN 1 AND 5)
);


-- =====================================================
-- 5. TABELA: FAVORITO
-- =====================================================

CREATE TABLE favorito (
    utilizador_id INT NOT NULL,
    destino_id VARCHAR(64) NOT NULL,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pk_favorito
        PRIMARY KEY (utilizador_id, destino_id),

    CONSTRAINT fk_favorito_utilizador
        FOREIGN KEY (utilizador_id)
        REFERENCES utilizador(utilizador_id)
        ON DELETE CASCADE
);


-- =====================================================
-- 6. TABELA: HISTORICO_ATIVIDADE
-- =====================================================

CREATE TABLE historico_atividade (
    atividade_id BIGINT
        GENERATED ALWAYS AS IDENTITY,

    utilizador_id INT NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    alvo_tipo VARCHAR(10),
    alvo_id VARCHAR(64),
    termo_pesquisa TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT pk_historico_atividade
        PRIMARY KEY (atividade_id),

    CONSTRAINT fk_historico_utilizador
        FOREIGN KEY (utilizador_id)
        REFERENCES utilizador(utilizador_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_historico_tipo
        CHECK (
            tipo IN (
                'VISTA',
                'PESQUISA',
                'FAVORITO',
                'REVIEW'
            )
        ),

    CONSTRAINT chk_historico_alvo_tipo
        CHECK (
            alvo_tipo IS NULL
            OR alvo_tipo IN ('DESTINO', 'POI')
        ),

    CONSTRAINT chk_historico_dados
        CHECK (
            (
                tipo = 'PESQUISA'
                AND termo_pesquisa IS NOT NULL
                AND alvo_tipo IS NULL
                AND alvo_id IS NULL
            )
            OR
            (
                tipo <> 'PESQUISA'
                AND termo_pesquisa IS NULL
                AND alvo_tipo IS NOT NULL
                AND alvo_id IS NOT NULL
            )
        )
);

