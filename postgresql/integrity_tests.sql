
BEGIN;

DO $$
DECLARE
    v_tipo_id SMALLINT;
    v_preferencia_id SMALLINT;
    v_utilizador_id INT;
    v_email VARCHAR(255);
    v_nome_preferencia VARCHAR(50);
    v_teste BOOLEAN;
BEGIN

    -- Obter um perfil existente
    SELECT MIN(tipo_utilizador_id)
    INTO v_tipo_id
    FROM tipo_utilizador;

    IF v_tipo_id IS NULL THEN
        RAISE EXCEPTION
            'É necessário inserir pelo menos um tipo de utilizador antes dos testes.';
    END IF;

    -- Criar identificadores temporários
    v_email := 'teste.integridade.' || pg_backend_pid() || '@exemplo.pt';
    v_nome_preferencia := 'Teste_' || pg_backend_pid();

    -- Criar uma preferência temporária
    INSERT INTO preferencia (nome)
    VALUES (v_nome_preferencia)
    RETURNING preferencia_id INTO v_preferencia_id;

    -- Criar um utilizador temporário
    INSERT INTO utilizador (
        tipo_utilizador_id,
        nome,
        email,
        password_hash,
        pais_origem
    )
    VALUES (
        v_tipo_id,
        'Utilizador de Teste',
        v_email,
        'hash_ficticio_apenas_para_teste',
        'PT'
    )
    RETURNING utilizador_id INTO v_utilizador_id;


    --------------------------------------------------
    -- TESTE 1: UNIQUE - email duplicado
    --------------------------------------------------

    v_teste := FALSE;

    BEGIN
        INSERT INTO utilizador (
            tipo_utilizador_id,
            nome,
            email,
            password_hash
        )
        VALUES (
            v_tipo_id,
            'Outro Utilizador',
            v_email,
            'hash_ficticio'
        );

    EXCEPTION
        WHEN unique_violation THEN
            v_teste := TRUE;
    END;

    IF NOT v_teste THEN
        RAISE EXCEPTION
            'FALHA: foi permitido inserir um email duplicado.';
    END IF;

    RAISE NOTICE 'PASSOU: não permite emails duplicados.';


    --------------------------------------------------
    -- TESTE 2: NOT NULL - nome obrigatório
    --------------------------------------------------

    v_teste := FALSE;

    BEGIN
        INSERT INTO utilizador (
            tipo_utilizador_id,
            nome,
            email,
            password_hash
        )
        VALUES (
            v_tipo_id,
            NULL,
            'null.nome.' || pg_backend_pid() || '@exemplo.pt',
            'hash_ficticio'
        );

    EXCEPTION
        WHEN not_null_violation THEN
            v_teste := TRUE;
    END;

    IF NOT v_teste THEN
        RAISE EXCEPTION
            'FALHA: foi permitido inserir um nome NULL.';
    END IF;

    RAISE NOTICE 'PASSOU: o nome é obrigatório.';


    --------------------------------------------------
    -- TESTE 3: FOREIGN KEY - perfil inexistente
    --------------------------------------------------

    v_teste := FALSE;

    BEGIN
        INSERT INTO utilizador (
            tipo_utilizador_id,
            nome,
            email,
            password_hash
        )
        VALUES (
            -32768,
            'Perfil Inválido',
            'perfil.invalido.' || pg_backend_pid() || '@exemplo.pt',
            'hash_ficticio'
        );

    EXCEPTION
        WHEN foreign_key_violation THEN
            v_teste := TRUE;
    END;

    IF NOT v_teste THEN
        RAISE EXCEPTION
            'FALHA: foi permitido utilizar um perfil inexistente.';
    END IF;

    RAISE NOTICE 'PASSOU: rejeita perfis inexistentes.';


    --------------------------------------------------
    -- TESTE 4: PRIMARY KEY - preferência duplicada
    --------------------------------------------------
    v_teste := FALSE;

    BEGIN
        INSERT INTO preferencia (
            preferencia_id,
            nome
        )
        OVERRIDING SYSTEM VALUE
        VALUES (
            v_preferencia_id,
            'Outra Preferência'
        );

    EXCEPTION
        WHEN unique_violation THEN
            v_teste := TRUE;
    END;

    IF NOT v_teste THEN
        RAISE EXCEPTION
            'FALHA: foi permitida uma chave primária duplicada.';
    END IF;

    RAISE NOTICE 'PASSOU: não permite chaves primárias duplicadas.';


    --------------------------------------------------
    -- TESTE 5: CHECK - peso fora do intervalo 1 a 5
    --------------------------------------------------

    v_teste := FALSE;

    BEGIN
        INSERT INTO utilizador_preferencia (
            utilizador_id,
            preferencia_id,
            peso
        )
        VALUES (
            v_utilizador_id,
            v_preferencia_id,
            6
        );

    EXCEPTION
        WHEN check_violation THEN
            v_teste := TRUE;
    END;

    IF NOT v_teste THEN
        RAISE EXCEPTION
            'FALHA: foi permitido um peso superior a 5.';
    END IF;

    RAISE NOTICE 'PASSOU: o peso respeita o intervalo permitido.';


    --------------------------------------------------
    -- TESTE 6: FOREIGN KEY - preferência inexistente
    --------------------------------------------------

    v_teste := FALSE;

    BEGIN
        INSERT INTO utilizador_preferencia (
            utilizador_id,
            preferencia_id,
            peso
        )
        VALUES (
            v_utilizador_id,
            -32768,
            3
        );

    EXCEPTION
        WHEN foreign_key_violation THEN
            v_teste := TRUE;
    END;

    IF NOT v_teste THEN
        RAISE EXCEPTION
            'FALHA: foi permitida uma preferência inexistente.';
    END IF;

    RAISE NOTICE 'PASSOU: rejeita preferências inexistentes.';


    --------------------------------------------------
    -- TESTE 7: CHECK - tipo de atividade inválido
    --------------------------------------------------

    v_teste := FALSE;

    BEGIN
        INSERT INTO historico_atividade (
            utilizador_id,
            tipo,
            alvo_tipo,
            alvo_id
        )
        VALUES (
            v_utilizador_id,
            'INVALIDO',
            'DESTINO',
            'destino_teste'
        );

    EXCEPTION
        WHEN check_violation THEN
            v_teste := TRUE;
    END;

    IF NOT v_teste THEN
        RAISE EXCEPTION
            'FALHA: foi permitido um tipo de atividade inválido.';
    END IF;

    RAISE NOTICE 'PASSOU: rejeita tipos de atividade inválidos.';


    --------------------------------------------------
    -- TESTE 8: PRIMARY KEY composta - favorito duplicado
    --------------------------------------------------

    INSERT INTO favorito (utilizador_id, destino_id)
    VALUES (v_utilizador_id, 'destino_teste_integridade');

    v_teste := FALSE;

    BEGIN
        INSERT INTO favorito (utilizador_id, destino_id)
        VALUES (v_utilizador_id, 'destino_teste_integridade');

    EXCEPTION
        WHEN unique_violation THEN
            v_teste := TRUE;
    END;

    IF NOT v_teste THEN
        RAISE EXCEPTION
            'FALHA: foi permitido repetir o mesmo favorito.';
    END IF;

    RAISE NOTICE 'PASSOU: não permite favoritos duplicados para o mesmo utilizador.';


    --------------------------------------------------
    -- TESTE 9: ON DELETE CASCADE
    --------------------------------------------------

    -- Criar relações para testar a eliminação em cascata
    INSERT INTO utilizador_preferencia (
        utilizador_id,
        preferencia_id,
        peso
    )
    VALUES (
        v_utilizador_id,
        v_preferencia_id,
        3
    );

    INSERT INTO historico_atividade (
        utilizador_id,
        tipo,
        alvo_tipo,
        alvo_id
    )
    VALUES (
        v_utilizador_id,
        'VISTA',
        'DESTINO',
        'destino_teste_cascade'
    );

    -- Eliminar o utilizador temporário
    DELETE FROM utilizador
    WHERE utilizador_id = v_utilizador_id;

    -- Verificar se as relações foram eliminadas
    IF EXISTS (
        SELECT 1 FROM utilizador_preferencia
        WHERE utilizador_id = v_utilizador_id
    ) OR EXISTS (
        SELECT 1 FROM favorito
        WHERE utilizador_id = v_utilizador_id
    ) OR EXISTS (
        SELECT 1 FROM historico_atividade
        WHERE utilizador_id = v_utilizador_id
    ) THEN

        RAISE EXCEPTION
            'FALHA: ON DELETE CASCADE não eliminou todos os registos relacionados.';

    END IF;

    RAISE NOTICE 'PASSOU: ON DELETE CASCADE funciona corretamente.';

    RAISE NOTICE 'TODOS OS TESTES FORAM CONCLUÍDOS COM SUCESSO.';

END $$;

-- Desfazer os registos temporários
ROLLBACK;
