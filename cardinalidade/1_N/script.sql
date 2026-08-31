-- =========================================================================
-- 1. CRIAÇÃO DAS TABELAS (DDL)
-- =========================================================================

-- Tabela Principal (Lado 1)
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Tabela Dependente (Lado N)
-- Atenção: No relacionamento 1:N, a coluna "cliente_id" NÃO pode ter a 
-- restrição UNIQUE, pois o mesmo cliente pode aparecer em vários pedidos.
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL, -- Chave Estrangeira (FK)
    valor_total NUMERIC(10, 2) NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Restrição de relacionamento
    CONSTRAINT fk_cliente FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);


-- =========================================================================
-- 2. GRAVAÇÃO DE DADOS / INSERÇÃO (DML)
-- =========================================================================

-- Inserindo os clientes (IDs gerados automaticamente: 1 e 2)
INSERT INTO clientes (nome, email) 
VALUES 
('Paulo Antunes', 'paulo.antunes@email.com'),
('Ana Souza', 'ana.souza@email.com');

-- Inserindo os pedidos vinculados
-- Note que o cliente 1 (Paulo) possui DOIS pedidos diferentes (Cenário 1:N)
INSERT INTO pedidos (cliente_id, valor_total) 
VALUES 
(1, 150.50), -- Primeiro pedido do Paulo
(1, 89.90),  -- Segundo pedido do Paulo
(2, 340.00); -- Pedido da Ana


-- =========================================================================
-- 3. COMANDOS DE ATUALIZAÇÃO (DML e DDL)
-- =========================================================================

-- Atualizando dados de um pedido específico (Modificando o valor do pedido 1)
UPDATE pedidos 
SET valor_total = 175.00 
WHERE id = 1;

-- Atualizando a estrutura da tabela (Adicionando coluna de status do pedido)
ALTER TABLE pedidos 
ADD COLUMN status VARCHAR(20) DEFAULT 'Pendente';


-- =========================================================================
-- 4. COMANDOS DE EXCLUSÃO (DML e DDL)
-- =========================================================================

-- Excluindo um pedido específico (Apenas o segundo pedido do Paulo sumirá)
DELETE FROM pedidos 
WHERE id = 2;

-- Excluindo o cliente 1 (Paulo)
-- O "ON DELETE CASCADE" entrará em ação e apagará AUTOMATICAMENTE 
-- TODOS os pedidos que pertenciam ao Paulo (id 1) de uma só vez.
DELETE FROM clientes 
WHERE id = 1;

-- Exclusão de tabelas inteiras (Sempre apagar o lado N primeiro)
DROP TABLE pedidos;
DROP TABLE clientes;