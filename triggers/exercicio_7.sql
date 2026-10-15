-- =========================================================================
-- EXERCÍCIO: Baixa Cruzada de Estoque na Venda
-- CONTEXTO: Sistema de Loja (Tabelas: produtos e itens_venda)
-- =========================================================================
-- O que o código precisa fazer:
-- 1. Criar a tabela 'produtos' (id, nome, estoque_atual).
-- 2. Criar a tabela 'itens_venda' (id, produto_id FK, quantidade_vendida).
-- 3. Criar uma trigger BEFORE INSERT na tabela 'itens_venda'.
-- 4. A função deve verificar se há estoque suficiente na tabela 'produtos' 
--    para atender a quantidade solicitada na venda.
-- 5. Se não houver, cancelar a venda com 'RAISE EXCEPTION'.
-- 6. Se houver, abater automaticamente a quantidade vendida do estoque do produto relacionado.
-- =========================================================================

-- Tabela de produtos (Estoque central)
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    estoque_atual INT NOT NULL DEFAULT 0
);

-- Tabela de itens vendidos
CREATE TABLE itens_venda (
    id SERIAL PRIMARY KEY,
    produto_id INT REFERENCES produtos(id),
    quantidade_vendida INT NOT NULL,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Função de verificação e baixa de estoque cruzada
CREATE OR REPLACE FUNCTION fn_processa_baixa_estoque()
RETURNS TRIGGER AS $$
DECLARE
    v_estoque_atual INT;
    v_nome_produto VARCHAR(100);
BEGIN
    -- Busca o estoque e o nome do produto na tabela pai/relacionada
    SELECT estoque_atual, nome INTO v_estoque_atual, v_nome_produto
    FROM produtos
    WHERE id = NEW.produto_id;

    -- Valida se o produto existe
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto com ID % não encontrado!', NEW.produto_id;
    END IF;

    -- Valida se há estoque suficiente
    IF v_estoque_atual < NEW.quantidade_vendida THEN
        RAISE EXCEPTION 'Estoque insuficiente para o produto "%". Disponível: %, Solicitado: %.', 
            v_nome_produto, v_estoque_atual, NEW.quantidade_vendida;
    END IF;

    -- Efetua a baixa automática no estoque do produto
    UPDATE produtos
    SET estoque_atual = estoque_atual - NEW.quantidade_vendida
    WHERE id = NEW.produto_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada
CREATE TRIGGER trg_baixa_estoque_venda
BEFORE INSERT ON itens_venda
FOR EACH ROW
EXECUTE FUNCTION fn_processa_baixa_estoque();

-- TESTE:

-- INSERT INTO produtos (nome, estoque_atual) VALUES ('Monitor Ultrawide', 5);
-- INSERT INTO itens_venda (produto_id, quantidade_vendida) VALUES (1, 2); -- Sucesso! Estoque do monitor vai para 3.
-- SELECT * FROM produtos; 
-- INSERT INTO itens_venda (produto_id, quantidade_vendida) VALUES (1, 10); -- Deve dar ERRO de estoque insuficiente!