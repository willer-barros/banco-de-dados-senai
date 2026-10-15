-- =========================================================================
-- EXERCÍCIO: Recálculo de Pedido Mestre-Detalhe
-- CONTEXTO: Sistema de Vendas (Tabelas: pedidos e itens_pedido)
-- =========================================================================
-- O que o código precisa fazer:
-- 1. Criar a tabela 'pedidos' (id, cliente, valor_total DEFAULT 0).
-- 2. Criar a tabela 'itens_pedido' (id, pedido_id FK, produto_nome, quantidade, preco_unitario).
-- 3. Criar uma trigger (ou triggers) na tabela de 'itens_pedido' que seja disparada 
--    AFTER INSERT, UPDATE ou DELETE.
-- 4. Sempre que um item for inserido, alterado ou removido, a função deve recalcular 
--    o 'valor_total' do pedido correspondente somando (quantidade * preco_unitario) 
--    de todos os seus itens e atualizar a tabela 'pedidos'.
-- =========================================================================

-- Tabela Pai (Mestre)
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela Filha (Detalhe)
CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_nome VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario NUMERIC(10, 2) NOT NULL
);

-- Função unificada para recalcular o total do pedido
CREATE OR REPLACE FUNCTION fn_recalcula_total_pedido()
RETURNS TRIGGER AS $$
DECLARE
    v_pedido_id INT;
BEGIN
    -- Descobre qual pedido foi afetado (funciona para INSERT/UPDATE com NEW e DELETE com OLD)
    IF (TG_OP = 'DELETE') THEN
        v_pedido_id := OLD.pedido_id;
    ELSE
        v_pedido_id := NEW.pedido_id;
    END IF;

    -- Atualiza o valor total na tabela 'pedidos' somando os itens restantes
    UPDATE pedidos
    SET valor_total = COALESCE((
        SELECT SUM(quantidade * preco_unitario) 
        FROM itens_pedido 
        WHERE pedido_id = v_pedido_id
    ), 0.00)
    WHERE id = v_pedido_id;

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada a múltiplos eventos na tabela filha
CREATE TRIGGER trg_atualiza_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON itens_pedido
FOR EACH ROW
EXECUTE FUNCTION fn_recalcula_total_pedido();

-- TESTE:

-- INSERT INTO pedidos (cliente) VALUES ('Ana Souza'); -- ID 1
-- INSERT INTO itens_pedido (pedido_id, produto_nome, quantidade, preco_unitario) VALUES (1, 'Mouse Gamer', 2, 150.00);
-- INSERT INTO itens_pedido (pedido_id, produto_nome, quantidade, preco_unitario) VALUES (1, 'Mousepad', 1, 50.00);
-- SELECT * FROM pedidos; -- O valor_total deve ser 350.00 automaticamente!
-- DELETE FROM itens_pedido WHERE id = 2;
-- SELECT * FROM pedidos; -- O valor_total deve cair para 300.00!