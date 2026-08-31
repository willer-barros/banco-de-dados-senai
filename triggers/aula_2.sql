-- STREAMING_CHUNK:Creating tables for 1:N trigger scenario...
-- =========================================================================
-- CENÁRIO 1:N - CLIENTES (1) E PEDIDOS (N)
-- Objetivo da Trigger: Sempre que um pedido for INSERIDO, ALTERADO ou DELETADO,
-- a trigger atualizará automaticamente o campo 'total_compras' na tabela 'clientes'.
-- =========================================================================

-- 1. Tabela Principal (Lado 1) com a coluna de acúmulo
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    total_compras NUMERIC(10, 2) DEFAULT 0.00
);

-- 2. Tabela Dependente (Lado N)
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);

-- STREAMING_CHUNK:Creating trigger function for recalculating totals...
-- =========================================================================
-- FUNÇÃO DA TRIGGER (PL/pgSQL)
-- Recalcula o somatório de pedidos do cliente afetado pela operação
-- =========================================================================
CREATE OR REPLACE FUNCTION fn_atualiza_total_cliente()
RETURNS TRIGGER AS $$
DECLARE
    v_cliente_id INT;
BEGIN
    -- Se for exclusão (DELETE), o ID do cliente está no registro OLD
    IF (TG_OP = 'DELETE') THEN
        v_cliente_id := OLD.cliente_id;
    -- Se for inserção (INSERT), o ID está no registro NEW
    ELSE
        v_cliente_id := NEW.cliente_id;
    END IF;

    -- Atualiza o saldo acumulado do cliente recalculando a soma dos pedidos atuais
    UPDATE clientes
    SET total_compras = COALESCE((
        SELECT SUM(valor_total) 
        FROM pedidos 
        WHERE cliente_id = v_cliente_id
    ), 0.00)
    WHERE id = v_cliente_id;

    -- Tratamento caso o pedido tenha trocado de cliente no UPDATE
    IF (TG_OP = 'UPDATE' AND OLD.cliente_id IS DISTINCT FROM NEW.cliente_id) THEN
        UPDATE clientes
        SET total_compras = COALESCE((
            SELECT SUM(valor_total) 
            FROM pedidos 
            WHERE cliente_id = OLD.cliente_id
        ), 0.00)
        WHERE id = OLD.cliente_id;
    END IF;

    RETURN NULL; -- Triggers AFTER FOR EACH ROW não precisam retornar registros
END;
$$ LANGUAGE plpgsql;

-- STREAMING_CHUNK:Creating trigger binding on pedidos table...
-- =========================================================================
-- CRIAÇÃO DA TRIGGER VINCULADA À TABELA 'PEDIDOS'
-- Dispara DEPOIS de qualquer INSERÇÃO, ATUALIZAÇÃO ou EXCLUSÃO em 'pedidos'
-- =========================================================================
CREATE TRIGGER trg_atualiza_total_pedidos
AFTER INSERT OR UPDATE OR DELETE ON pedidos
FOR EACH ROW
EXECUTE FUNCTION fn_atualiza_total_cliente();

-- STREAMING_CHUNK:Testing trigger execution with INSERT, UPDATE, and DELETE...
-- =========================================================================
-- TESTES PRÁTICOS (RODE PASSO A PASSO NO PGADMIN)
-- =========================================================================

-- Passo 1: Inserindo clientes iniciais (total_compras iniciará em 0.00)
INSERT INTO clientes (nome) VALUES ('Paulo Antunes'), ('Ana Souza');

-- Conferindo saldo inicial (Ambos zerados)
SELECT * FROM clientes;

-- Passo 2: Inserindo o primeiro pedido do Paulo (R$ 150.00) -> Trigger em Ação!
INSERT INTO pedidos (cliente_id, valor_total) VALUES (1, 150.00);

-- Passo 3: Inserindo o segundo pedido do Paulo (R$ 50.00) -> Trigger soma R$ 200.00!
INSERT INTO pedidos (cliente_id, valor_total) VALUES (1, 50.00);

-- Passo 4: Inserindo um pedido para a Ana (R$ 300.00)
INSERT INTO pedidos (cliente_id, valor_total) VALUES (2, 300.00);

-- Conferindo atualização automática na tabela de clientes
SELECT * FROM clientes;

-- Passo 5: Alterando o valor do pedido 2 do Paulo de R$ 50.00 para R$ 100.00
UPDATE pedidos SET valor_total = 100.00 WHERE id = 2;

-- Conferindo saldo do Paulo (Agora deve ser R$ 250.00)
SELECT * FROM clientes WHERE id = 1;

-- Passo 6: Excluindo o pedido 1 do Paulo (R$ 150.00)
DELETE FROM pedidos WHERE id = 1;

-- Conferindo saldo final do Paulo (Agora deve ter recuado para R$ 100.00)
SELECT * FROM clientes WHERE id = 1;