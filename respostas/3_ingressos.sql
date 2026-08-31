-- 1. DDL: ESTRUTURA COM 7 TABELAS
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL
);

CREATE TABLE locais (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    capacidade_maxima INT CHECK (capacidade_maxima > 0) NOT NULL
);

CREATE TABLE categorias_evento (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE eventos (
    id SERIAL PRIMARY KEY,
    categoria_id INT REFERENCES categorias_evento(id),
    local_id INT REFERENCES locais(id),
    titulo VARCHAR(150) NOT NULL,
    preco_base DECIMAL(10,2) CHECK (preco_base > 0) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE cupons (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    percentual_desconto INT CHECK (percentual_desconto BETWEEN 1 AND 90) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE compras (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id),
    cupom_id INT REFERENCES cupons(id),
    data_compra TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Confirmada' CHECK (status IN ('Confirmada', 'Cancelada'))
);

CREATE TABLE ingressos (
    id SERIAL PRIMARY KEY,
    compra_id INT REFERENCES compras(id),
    evento_id INT REFERENCES eventos(id),
    tipo_ingresso VARCHAR(10) CHECK (tipo_ingresso IN ('Inteira', 'Meia')) NOT NULL,
    valor_pago DECIMAL(10,2) CHECK (valor_pago >= 0) NOT NULL
);

-- 2. DML: DADOS INICIAIS DE TESTE
INSERT INTO clientes (nome, email, cpf) VALUES 
('Lucas Ramos', 'lucas@email.com', '11122233344'),
('Mariana Dias', 'mariana@email.com', '22233344455');

INSERT INTO locais (nome, cidade, capacidade_maxima) VALUES 
('Teatro Municipal', 'São Paulo', 2), -- Capacidade reduzida para testar validacao
('Arena Show', 'Rio de Janeiro', 50000);

INSERT INTO categorias_evento (nome) VALUES ('Teatro'), ('Show');

INSERT INTO eventos (categoria_id, local_id, titulo, preco_base, ativo) VALUES 
(1, 1, 'O Fantasma da Ópera', 100.00, TRUE),
(2, 2, 'Festival de Rock', 200.00, FALSE); -- Evento inativo

INSERT INTO cupons (codigo, percentual_desconto, ativo) VALUES ('PROMO10', 10, TRUE);

-- 3. FUNÇÕES (PL/pgSQL)

-- F1: Calculo de Preco com Regras de Negocio
CREATE OR REPLACE FUNCTION fn_calcular_preco_ingresso(
    p_evento_id INT,
    p_tipo_ingresso VARCHAR,
    p_codigo_cupom VARCHAR DEFAULT NULL
) 
RETURNS DECIMAL(10,2) AS $$
DECLARE
    v_preco_base DECIMAL(10,2);
    v_desconto_cupom INT := 0;
    v_preco_final DECIMAL(10,2);
BEGIN
    SELECT preco_base INTO v_preco_base FROM eventos WHERE id = p_evento_id;
    
    IF v_preco_base IS NULL THEN
        RAISE EXCEPTION 'Evento informado não existe.';
    END IF;

    -- Regra Meia-Entrada
    IF p_tipo_ingresso = 'Meia' THEN
        v_preco_final := v_preco_base / 2.0;
    ELSE
        v_preco_final := v_preco_base;
    END IF;

    -- Regra de Cupom de Desconto
    IF p_codigo_cupom IS NOT NULL THEN
        SELECT percentual_desconto INTO v_desconto_cupom
        FROM cupons 
        WHERE codigo = p_codigo_cupom AND ativo = TRUE;
        
        IF FOUND THEN
            v_preco_final := v_preco_final * (1 - (v_desconto_cupom / 100.0));
        END IF;
    END IF;

    RETURN ROUND(v_preco_final, 2);
END;
$$ LANGUAGE plpgsql;

-- F2: Transacao de Emissão de Ingresso com Validacoes
CREATE OR REPLACE FUNCTION fn_emitir_ingresso(
    p_cliente_id INT,
    p_evento_id INT,
    p_tipo_ingresso VARCHAR,
    p_codigo_cupom VARCHAR DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    v_capacidade INT;
    v_vendidos INT;
    v_ativo BOOLEAN;
    v_cupom_id INT := NULL;
    v_compra_id INT;
    v_ingresso_id INT;
    v_valor_pago DECIMAL(10,2);
BEGIN
    -- Validar se evento esta ativo e capacidade do local
    SELECT l.capacidade_maxima, e.ativo INTO v_capacidade, v_ativo
    FROM eventos e
    JOIN locais l ON e.local_id = l.id
    WHERE e.id = p_evento_id;

    IF NOT v_ativo THEN
        RAISE EXCEPTION 'Vendas encerradas: O evento encontra-se inativo.';
    END IF;

    SELECT COUNT(i.id) INTO v_vendidos
    FROM ingressos i
    JOIN compras c ON i.compra_id = c.id
    WHERE i.evento_id = p_evento_id AND c.status = 'Confirmada';

    IF v_vendidos >= v_capacidade THEN
        RAISE EXCEPTION 'Ingressos esgotados para este evento.';
    END IF;

    -- Obter ID do cupom se fornecido
    IF p_codigo_cupom IS NOT NULL THEN
        SELECT id INTO v_cupom_id FROM cupons WHERE codigo = p_codigo_cupom AND ativo = TRUE;
    END IF;

    -- Calcular valor final reutilizando a Função F1
    v_valor_pago := fn_calcular_preco_ingresso(p_evento_id, p_tipo_ingresso, p_codigo_cupom);

    -- Inserir Compra e Ingresso
    INSERT INTO compras (cliente_id, cupom_id, status)
    VALUES (p_cliente_id, v_cupom_id, 'Confirmada')
    RETURNING id INTO v_compra_id;

    INSERT INTO ingressos (compra_id, evento_id, tipo_ingresso, valor_pago)
    VALUES (v_compra_id, p_evento_id, p_tipo_ingresso, v_valor_pago)
    RETURNING id INTO v_ingresso_id;

    RETURN v_ingresso_id;
END;
$$ LANGUAGE plpgsql;

-- F3: Relatorio de Faturamento do Evento
CREATE OR REPLACE FUNCTION fn_relatorio_faturamento_evento(p_evento_id INT)
RETURNS TABLE (
    titulo_evento VARCHAR,
    total_ingressos_vendidos BIGINT,
    faturamento_total DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.titulo,
        COUNT(i.id) AS total_ingressos_vendidos,
        COALESCE(SUM(i.valor_pago), 0.00) AS faturamento_total
    FROM eventos e
    LEFT JOIN ingressos i ON e.id = i.evento_id
    LEFT JOIN compras c ON i.compra_id = c.id AND c.status = 'Confirmada'
    WHERE e.id = p_evento_id
    GROUP BY e.titulo;
END;
$$ LANGUAGE plpgsql;

-- 4. EXEMPLOS DE EXECUÇÃO / TESTES
-- Teste F1 (Preco: 100 base -> Meia 50 -> Cupom 10% = 45.00)
SELECT fn_calcular_preco_ingresso(1, 'Meia', 'PROMO10');

-- Teste F2 (Emitir 2 ingressos para atingir capacidade)
SELECT fn_emitir_ingresso(1, 1, 'Inteira', 'PROMO10'); -- Sucesso (R$ 90.00)
SELECT fn_emitir_ingresso(2, 1, 'Meia', NULL);         -- Sucesso (R$ 50.00)
-- SELECT fn_emitir_ingresso(1, 1, 'Inteira', NULL);   -- Lança EXCEPTION (Esgotado!)

-- Teste F3 (Relatorio do Evento 1)
SELECT * FROM fn_relatorio_faturamento_evento(1);
