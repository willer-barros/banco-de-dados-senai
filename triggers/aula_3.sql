-- STREAMING_CHUNK:Criando tabelas para o cenário N:N de controle de estoque...
-- =========================================================================
-- CENÁRIO N:N - PRODUTOS (N) E VENDAS (N)
-- Tabela associativa: itens_venda
-- Objetivo da Trigger: Controlar o estoque automaticamente na tabela de 
-- produtos sempre que um item for vendido, alterado ou removido de uma venda.
-- =========================================================================

-- 1. Tabela Entidade 1 (Lado N)
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0
);

-- 2. Tabela Entidade 2 (Lado N)
CREATE TABLE vendas (
    id SERIAL PRIMARY KEY,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cliente_nome VARCHAR(100) NOT NULL
);

-- 3. Tabela Associativa / Junção (Onde a Trigger vai atuar)
CREATE TABLE itens_venda (
    venda_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    
    PRIMARY KEY (venda_id, produto_id),
    CONSTRAINT fk_venda FOREIGN KEY (venda_id) REFERENCES vendas(id) ON DELETE CASCADE,
    CONSTRAINT fk_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
);

-- STREAMING_CHUNK:Criando a função da trigger para ajuste de estoque...
-- =========================================================================
-- FUNÇÃO DA TRIGGER (PL/pgSQL)
-- Regra: 
-- INSERT: Diminui o estoque.
-- DELETE: Devolve ao estoque.
-- UPDATE: Calcula a diferença entre a quantidade antiga e a nova.
-- =========================================================================
CREATE OR REPLACE FUNCTION fn_controle_estoque()
RETURNS TRIGGER AS $$
BEGIN
    -- Se for INSERÇÃO (Nova venda do produto)
    IF (TG_OP = 'INSERT') THEN
        UPDATE produtos 
        SET quantidade_estoque = quantidade_estoque - NEW.quantidade 
        WHERE id = NEW.produto_id;
        
    -- Se for EXCLUSÃO (Produto removido da venda ou venda cancelada)
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE produtos 
        SET quantidade_estoque = quantidade_estoque + OLD.quantidade 
        WHERE id = OLD.produto_id;
        
    -- Se for ATUALIZAÇÃO (Alterou a quantidade do produto já vendido)
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Retorna a quantidade antiga para o estoque e abate a nova quantidade
        IF OLD.produto_id = NEW.produto_id THEN
            UPDATE produtos 
            SET quantidade_estoque = (quantidade_estoque + OLD.quantidade) - NEW.quantidade 
            WHERE id = NEW.produto_id;
        ELSE
            -- Caso bizarro onde o usuário trocou o produto na mesma linha de venda
            UPDATE produtos SET quantidade_estoque = quantidade_estoque + OLD.quantidade WHERE id = OLD.produto_id;
            UPDATE produtos SET quantidade_estoque = quantidade_estoque - NEW.quantidade WHERE id = NEW.produto_id;
        END IF;
    END IF;

    RETURN NULL; -- Triggers AFTER retornam NULL
END;
$$ LANGUAGE plpgsql;

-- STREAMING_CHUNK:Vinculando a Trigger à tabela associativa...
-- =========================================================================
-- CRIAÇÃO DA TRIGGER
-- Ela "escuta" apenas a tabela do meio (itens_venda)
-- =========================================================================
CREATE TRIGGER trg_atualiza_estoque
AFTER INSERT OR UPDATE OR DELETE ON itens_venda
FOR EACH ROW
EXECUTE FUNCTION fn_controle_estoque();

-- STREAMING_CHUNK:Executando testes práticos para a validação da Trigger...
-- =========================================================================
-- TESTES PRÁTICOS (RODE PASSO A PASSO NO PGADMIN)
-- =========================================================================

-- Passo 1: Cadastrando Produtos com estoque inicial
INSERT INTO produtos (nome, quantidade_estoque) VALUES 
('Notebook Dell', 50),
('Mouse Sem Fio', 100);

-- Verificando o estoque inicial (50 e 100)
SELECT * FROM produtos;

-- Passo 2: Criando uma Venda
INSERT INTO vendas (cliente_nome) VALUES ('Escola SENAI'); -- ID 1

-- Passo 3: Inserindo itens na venda (Isso dispara a Trigger!)
-- Vamos vender 5 Notebooks e 10 Mouses
INSERT INTO itens_venda (venda_id, produto_id, quantidade) VALUES 
(1, 1, 5),  -- Vende 5 Notebooks
(1, 2, 10); -- Vende 10 Mouses

-- Conferindo o estoque (Notebook caiu para 45, Mouse para 90)
SELECT * FROM produtos;

-- Passo 4: Atualizando a venda (Trigger de UPDATE em ação!)
-- O cliente ligou e disse que precisa de 8 Notebooks em vez de 5.
UPDATE itens_venda SET quantidade = 8 WHERE venda_id = 1 AND produto_id = 1;

-- Conferindo o estoque do Notebook (Deve cair de 45 para 42, pois tirou mais 3)
SELECT * FROM produtos WHERE id = 1;

-- Passo 5: Removendo um item da venda (Trigger de DELETE devolve ao estoque!)
-- O cliente cancelou a compra dos Mouses.
DELETE FROM itens_venda WHERE venda_id = 1 AND produto_id = 2;

-- Conferindo o estoque do Mouse (Deve voltar a ser 100)
SELECT * FROM produtos WHERE id = 2;