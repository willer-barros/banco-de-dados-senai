-- Tabela principal de produtos
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco NUMERIC(10, 2) NOT NULL
);

-- Tabela de histórico (auditoria) para registrar alterações de preço
CREATE TABLE historico_precos (
    id SERIAL PRIMARY KEY,
    produto_id INT NOT NULL,
    preco_antigo NUMERIC(10, 2),
    preco_novo NUMERIC(10, 2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 1. Criando a função que será disparada pela Trigger
CREATE OR REPLACE FUNCTION fn_log_alteracao_preco()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o preço antigo é diferente do preço novo
    IF OLD.preco IS DISTINCT FROM NEW.preco THEN
        INSERT INTO historico_precos (produto_id, preco_antigo, preco_novo)
        VALUES (NEW.id, OLD.preco, NEW.preco);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Criando a Trigger propriamente dita vinculada à tabela 'produtos'
CREATE TRIGGER trg_log_preco
AFTER UPDATE ON produtos
FOR EACH ROW
EXECUTE FUNCTION fn_log_alteracao_preco();

-- =========================================================================
-- TESTANDO O FUNCIONAMENTO DA TRIGGER
-- =========================================================================

-- Inserindo um produto inicial
INSERT INTO produtos (nome, preco) VALUES ('Notebook Gamer', 4500.00);

-- Atualizando o preço do produto (Isso vai disparar a Trigger automaticamente!)
UPDATE produtos SET preco = 4200.00 WHERE id = 1;

-- Consultando a tabela de histórico para ver a Trigger em ação
SELECT * FROM historico_precos;