-- Habilitar extensao para funcoes de criptografia (LGPD)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- -----------------------------------------------------------------------------
-- 1. DDL: ESTRUTURA DO BANCO DE DADOS
-- -----------------------------------------------------------------------------

CREATE TABLE colaboradores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf_criptografado BYTEA NOT NULL,
    senha_hash VARCHAR(64) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE tarefas (
    id SERIAL PRIMARY KEY,
    categoria_id INT REFERENCES categorias(id),
    colaborador_id INT REFERENCES colaboradores(id),
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    data_agendamento DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Em Andamento', 'Concluida', 'Cancelada')),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE historico_tarefas (
    id SERIAL PRIMARY KEY,
    tarefa_id INT REFERENCES tarefas(id) ON DELETE CASCADE,
    observacao VARCHAR(200) NOT NULL,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 2. DML: CARGA DE DADOS INICIAIS (MÍNIMO 3 POR TABELA)
-- -----------------------------------------------------------------------------

INSERT INTO colaboradores (nome, email, cpf_criptografado, senha_hash) VALUES
('Carlos Eduardo', 'carlos@consultoria.com', pgp_sym_encrypt('11122233344', 'chave_lgpd'), encode(digest('senha123', 'sha256'), 'hex')),
('Mariana Silva', 'mariana@consultoria.com', pgp_sym_encrypt('22233344455', 'chave_lgpd'), encode(digest('admin321', 'sha256'), 'hex')),
('Roberto Rocha', 'roberto@consultoria.com', pgp_sym_encrypt('33344455566', 'chave_lgpd'), encode(digest('mudar123', 'sha256'), 'hex'));

INSERT INTO categorias (nome) VALUES 
('Desenvolvimento'), 
('Consultoria LGPD'), 
('Gestão de Projetos');

INSERT INTO tarefas (categoria_id, colaborador_id, titulo, descricao, data_agendamento, status) VALUES
(1, 1, 'Modelagem do Banco de Dados', 'Criar DER e scripts DDL/DML para o cliente', CURRENT_DATE + INTERVAL '2 days', 'Em Andamento'),
(2, 2, 'Auditoria de Segurança LGPD', 'Mapear dados sensíveis e implementar criptografia', CURRENT_DATE + INTERVAL '5 days', 'Pendente'),
(3, 3, 'Reunião de Alinhamento com Cliente', 'Apresentar cronograma do projeto', CURRENT_DATE + INTERVAL '1 day', 'Pendente');

-- -----------------------------------------------------------------------------
-- 3. REQUISITO: AUTENTICAÇÃO E SEGURANÇA (LGPD)
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_autenticar_usuario(
    p_email VARCHAR,
    p_senha VARCHAR
)
RETURNS TABLE (
    autenticado BOOLEAN,
    colaborador_id INT,
    nome VARCHAR,
    mensagem VARCHAR
) AS $$
DECLARE
    v_hash VARCHAR(64);
    v_id INT;
    v_nome VARCHAR(100);
    v_ativo BOOLEAN;
BEGIN
    v_hash := encode(digest(p_senha, 'sha256'), 'hex');

    SELECT id, c.nome, ativo INTO v_id, v_nome, v_ativo
    FROM colaboradores c
    WHERE c.email = p_email AND c.senha_hash = v_hash;

    IF v_id IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::INT, NULL::VARCHAR, 'Usuário ou senha inválidos.'::VARCHAR;
    ELSIF NOT v_ativo THEN
        RETURN QUERY SELECT FALSE, NULL::INT, NULL::VARCHAR, 'Acesso negado: Colaborador inativo.'::VARCHAR;
    ELSE
        RETURN QUERY SELECT TRUE, v_id, v_nome, 'Autenticação realizada com sucesso!'::VARCHAR;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 4. REQUISITO: PAINEL PRINCIPAL (VIEW)
-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_painel_principal AS
SELECT 
    t.id AS tarefa_id,
    c.nome AS colaborador_responsavel,
    cat.nome AS categoria,
    t.titulo AS tarefa,
    t.data_agendamento,
    t.status
FROM tarefas t
JOIN colaboradores c ON t.colaborador_id = c.id
JOIN categorias cat ON t.categoria_id = cat.id;

-- -----------------------------------------------------------------------------
-- 5. REQUISITO: GERENCIAMENTO E BUSCA DE COLABORADORES
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_buscar_colaboradores(p_termo VARCHAR)
RETURNS TABLE (
    id INT,
    nome VARCHAR,
    email VARCHAR,
    cpf_descriptografado TEXT,
    ativo BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.nome,
        c.email,
        pgp_sym_decrypt(c.cpf_criptografado, 'chave_lgpd')::TEXT,
        c.ativo
    FROM colaboradores c
    WHERE LOWER(c.nome) LIKE LOWER('%' || p_termo || '%')
       OR LOWER(c.email) LIKE LOWER('%' || p_termo || '%');
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 6. REQUISITO: TRIGGER DE AUTOMAÇÃO E VÍNCULO DE TAREFAS
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_trg_validar_e_logar_tarefa()
RETURNS TRIGGER AS $$
DECLARE
    v_ativo BOOLEAN;
BEGIN
    -- Validar se o colaborador esta ativo
    SELECT ativo INTO v_ativo FROM colaboradores WHERE id = NEW.colaborador_id;
    
    IF v_ativo IS NULL OR NOT v_ativo THEN
        RAISE EXCEPTION 'Não é possível atribuir tarefas a um colaborador inativo ou inexistente.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_tarefa
BEFORE INSERT ON tarefas
FOR EACH ROW
EXECUTE FUNCTION fn_trg_validar_e_logar_tarefa();

-- Trigger AFTER INSERT para gravar no historico
CREATE OR REPLACE FUNCTION fn_trg_historico_tarefa()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historico_tarefas (tarefa_id, observacao)
    VALUES (NEW.id, 'Tarefa criada e atribuída com status: ' || NEW.status);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_historico_tarefa
AFTER INSERT ON tarefas
FOR EACH ROW
EXECUTE FUNCTION fn_trg_historico_tarefa();

-- -----------------------------------------------------------------------------
-- 7. REQUISITO: AGENDAMENTO E CRONOGRAMA DE PRAZOS (VIEW ORDENADA)
-- -----------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_cronograma_prazos AS
SELECT 
    t.id AS tarefa_id,
    t.titulo AS tarefa,
    c.nome AS colaborador_responsavel,
    t.data_agendamento,
    (t.data_agendamento - CURRENT_DATE) AS dias_restantes,
    t.status
FROM tarefas t
JOIN colaboradores c ON t.colaborador_id = c.id
ORDER BY t.data_agendamento ASC;

-- -----------------------------------------------------------------------------
-- 8. TESTES E VALIDAÇÃO DOS REQUISITOS
-- -----------------------------------------------------------------------------

-- Teste de Autenticacao com Sucesso:
SELECT * FROM fn_autenticar_usuario('carlos@consultoria.com', 'senha123');

-- Teste de Autenticacao com Erro:
SELECT * FROM fn_autenticar_usuario('carlos@consultoria.com', 'senha_errada');

-- Teste de Busca de Colaboradores (LGPD Descriptografado):
SELECT * FROM fn_buscar_colaboradores('Mariana');

-- Teste das Views:
SELECT * FROM vw_painel_principal;
SELECT * FROM vw_cronograma_prazos;
