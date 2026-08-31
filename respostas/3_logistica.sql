-- 1. DDL: ESTRUTURA COM 7 TABELAS
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf_cnpj VARCHAR(18) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE motoristas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnh VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    motorista_id INT REFERENCES motoristas(id),
    placa VARCHAR(7) UNIQUE NOT NULL,
    capacidade_peso_kg DECIMAL(10,2) CHECK (capacidade_peso_kg > 0) NOT NULL,
    ano INT CHECK (ano >= 2010) NOT NULL
);

CREATE TABLE regioes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL,
    taxa_base DECIMAL(10,2) CHECK (taxa_base > 0) NOT NULL,
    prazo_dias INT CHECK (prazo_dias > 0) NOT NULL
);

CREATE TABLE entregas (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id),
    motorista_id INT REFERENCES motoristas(id),
    regiao_id INT REFERENCES regioes(id),
    data_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Em Transito', 'Entregue', 'Cancelada'))
);

CREATE TABLE pacotes (
    id SERIAL PRIMARY KEY,
    entrega_id INT REFERENCES entregas(id),
    descricao VARCHAR(150) NOT NULL,
    peso_kg DECIMAL(10,2) CHECK (peso_kg > 0) NOT NULL,
    valor_declarado DECIMAL(10,2) CHECK (valor_declarado >= 0) NOT NULL
);

CREATE TABLE historico_rastreio (
    id SERIAL PRIMARY KEY,
    entrega_id INT REFERENCES entregas(id),
    status_atual VARCHAR(50) NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacao TEXT
);

-- 2. DML: CARGA INICIAL DE TESTES
INSERT INTO clientes (nome, email, cpf_cnpj, telefone) VALUES
('Tech Corp', 'contato@techcorp.com', '12345678000199', '1140028922'),
('Comércio Silva', 'vendas@silva.com', '98765432000188', '1133334444');

INSERT INTO motoristas (nome, cnh, telefone, disponivel) VALUES
('Roberto Alves', '12345678901', '11911112222', TRUE),
('Marcos Souza', '98765432100', '11933334444', TRUE);

INSERT INTO veiculos (motorista_id, placa, capacidade_peso_kg, ano) VALUES
(1, 'ABC1D23', 500.00, 2021),  -- Veiculo do Roberto (500kg)
(2, 'XYZ9K88', 100.00, 2019);  -- Veiculo do Marcos (100kg - limite menor p/ testes)

INSERT INTO regioes (nome, taxa_base, prazo_dias) VALUES
('Sudeste', 50.00, 2),
('Sul', 75.00, 4);

INSERT INTO entregas (cliente_id, regiao_id, status) VALUES
(1, 1, 'Pendente'),
(2, 2, 'Pendente');

INSERT INTO pacotes (entrega_id, descricao, peso_kg, valor_declarado) VALUES
(1, 'Lote de Notebooks', 150.00, 10000.00),
(1, 'Acessórios Eletrônicos', 50.00, 2000.00),
(2, 'Maquinário Industrial', 300.00, 15000.00);

-- 3. FUNÇÕES (PL/pgSQL)

-- F1: Calculo do Valor Total do Frete
CREATE OR REPLACE FUNCTION fn_calcular_frete(p_entrega_id INT)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    v_taxa_base DECIMAL(10,2);
    v_peso_total DECIMAL(10,2);
    v_valor_total DECIMAL(10,2);
    v_frete_total DECIMAL(10,2);
BEGIN
    SELECT r.taxa_base INTO v_taxa_base
    FROM entregas e
    JOIN regioes r ON e.regiao_id = r.id
    WHERE e.id = p_entrega_id;

    IF v_taxa_base IS NULL THEN
        RAISE EXCEPTION 'Entrega não encontrada ou sem região vinculada.';
    END IF;

    SELECT COALESCE(SUM(peso_kg), 0), COALESCE(SUM(valor_declarado), 0)
    INTO v_peso_total, v_valor_total
    FROM pacotes
    WHERE entrega_id = p_entrega_id;

    -- Formula: Taxa Base + (Peso * R$5) + (1% do Valor Declarado)
    v_frete_total := v_taxa_base + (v_peso_total * 5.00) + (v_valor_total * 0.01);

    RETURN ROUND(v_frete_total, 2);
END;
$$ LANGUAGE plpgsql;

-- F2: Atribuicao de Motorista com Validacao de Carga e Atualizacao de Status
CREATE OR REPLACE FUNCTION fn_atribuir_motorista_e_iniciar(
    p_entrega_id INT,
    p_motorista_id INT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_disponivel BOOLEAN;
    v_capacidade DECIMAL(10,2);
    v_peso_entrega DECIMAL(10,2);
    v_status_entrega VARCHAR(20);
BEGIN
    -- Validar disponibilidade do motorista
    SELECT disponivel INTO v_disponivel FROM motoristas WHERE id = p_motorista_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Motorista informado não cadastrado.';
    END IF;
    IF NOT v_disponivel THEN
        RAISE EXCEPTION 'Motorista indisponível para novos despachos.';
    END IF;

    -- Validar status da entrega
    SELECT status INTO v_status_entrega FROM entregas WHERE id = p_entrega_id;
    IF v_status_entrega <> 'Pendente' THEN
        RAISE EXCEPTION 'Apenas entregas com status Pendente podem ser iniciadas.';
    END IF;

    -- Validar capacidade de carga do veiculo associado
    SELECT capacidade_peso_kg INTO v_capacidade FROM veiculos WHERE motorista_id = p_motorista_id LIMIT 1;
    IF v_capacidade IS NULL THEN
        RAISE EXCEPTION 'O motorista não possui veículo associado.';
    END IF;

    SELECT COALESCE(SUM(peso_kg), 0) INTO v_peso_entrega FROM pacotes WHERE entrega_id = p_entrega_id;

    IF v_peso_entrega > v_capacidade THEN
        RAISE EXCEPTION 'Peso total dos pacotes (%.2f kg) excede a capacidade do veículo (%.2f kg).', v_peso_entrega, v_capacidade;
    END IF;

    -- Atualizar Entrega e Motorista
    UPDATE entregas SET motorista_id = p_motorista_id, status = 'Em Transito' WHERE id = p_entrega_id;
    UPDATE motoristas SET disponivel = FALSE WHERE id = p_motorista_id;

    -- Registrar Rastreio
    INSERT INTO historico_rastreio (entrega_id, status_atual, observacao)
    VALUES (p_entrega_id, 'Em Transito', 'Carga despachada com o motorista atribuído.');

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- F3: Relatório de Desempenho do Motorista
CREATE OR REPLACE FUNCTION fn_relatorio_desempenho_motorista(p_motorista_id INT)
RETURNS TABLE (
    nome_motorista VARCHAR,
    total_entregas_concluidas BIGINT,
    peso_total_transportado DECIMAL,
    faturamento_gerado DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.nome,
        COUNT(DISTINCT e.id) AS total_entregas_concluidas,
        COALESCE(SUM(p.peso_kg), 0.00) AS peso_total_transportado,
        COALESCE(SUM(fn_calcular_frete(e.id)), 0.00) AS faturamento_gerado
    FROM motoristas m
    LEFT JOIN entregas e ON m.id = e.motorista_id AND e.status = 'Entregue'
    LEFT JOIN pacotes p ON e.id = p.entrega_id
    WHERE m.id = p_motorista_id
    GROUP BY m.nome;
END;
$$ LANGUAGE plpgsql;

-- 4. TESTES E EXECUÇÃO

-- Teste F1: Calculo de Frete da Entrega 1 (50 base + 200kg*5 + 12000*0.01 = R$ 1170.00)
SELECT fn_calcular_frete(1);

-- Teste F2: Atribuicao bem-sucedida (Roberto suporta 500kg, entrega 1 tem 200kg)
SELECT fn_atribuir_motorista_e_iniciar(1, 1);

-- Teste F2 (Falha de Capacidade): Marcos tenta pegar a entrega 2 (300kg, mas seu veiculo suporta 100kg)
-- SELECT fn_atribuir_motorista_e_iniciar(2, 2); -- Lança EXCEPTION!

-- Finalizar Entrega 1 para testar relatório
UPDATE entregas SET status = 'Entregue' WHERE id = 1;

-- Teste F3: Relatorio de Desempenho do Motorista 1
SELECT * FROM fn_relatorio_desempenho_motorista(1);
