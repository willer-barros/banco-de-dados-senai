-- Tabela Clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela Categorias
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

-- Tabela Produtos
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    categoria_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    preco NUMERIC(10, 2) NOT NULL CHECK (preco > 0),
    quantidade_estoque INT NOT NULL DEFAULT 0 CHECK (quantidade_estoque >= 0),
    
    CONSTRAINT fk_produto_categoria 
        FOREIGN KEY (categoria_id) 
        REFERENCES categorias(id) 
        ON DELETE RESTRICT
);

-- Tabela Pedidos
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Pago', 'Enviado', 'Cancelado')),
    
    CONSTRAINT fk_pedido_cliente 
        FOREIGN KEY (cliente_id) 
        REFERENCES clientes(id) 
        ON DELETE CASCADE
);

-- Tabela Associativa Itens_Pedido (N:N)
CREATE TABLE itens_pedido (
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario NUMERIC(10, 2) NOT NULL CHECK (preco_unitario > 0),
    
    PRIMARY KEY (pedido_id, produto_id),
    CONSTRAINT fk_item_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    CONSTRAINT fk_item_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT
);

-- =========================================================================
-- 2. INSERÇÃO DE DADOS DE TESTE (DML)
-- =========================================================================

-- Inserindo Categorias
INSERT INTO categorias (nome) VALUES 
('Periféricos'),
('Monitores'),
('Hardware');

-- Inserindo Produtos
INSERT INTO produtos (categoria_id, nome, preco, quantidade_estoque) VALUES 
(1, 'Mouse Gamer Redragon', 150.00, 25),
(1, 'Teclado Mecânico Logitech', 350.00, 8),
(2, 'Monitor LG 29 UltraWide', 1200.00, 5),
(3, 'SSD NVMe 1TB Kingston', 450.00, 15),
(3, 'Memória RAM 16GB Corsair', 280.00, 4);

-- Inserindo Clientes
INSERT INTO clientes (nome, email, cpf) VALUES 
('Paulo Antunes', 'paulo.antunes@email.com', '12345678901'),
('Ana Souza', 'ana.souza@email.com', '98765432100'),
('Carlos Eduardo', 'carlos.eduardo@email.com', '45678912300');

-- Inserindo Pedidos
INSERT INTO pedidos (cliente_id, status) VALUES 
(1, 'Pago'),      -- Pedido 1 (Paulo)
(2, 'Pendente'),  -- Pedido 2 (Ana)
(1, 'Enviado');   -- Pedido 3 (Paulo)

-- Inserindo Itens dos Pedidos
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES 
-- Pedido 1
(1, 1, 2, 150.00), -- 2 Mouses
(1, 2, 1, 350.00), -- 1 Teclado
-- Pedido 2
(2, 3, 1, 1200.00),-- 1 Monitor
(2, 4, 1, 450.00), -- 1 SSD
-- Pedido 3
(3, 5, 2, 280.00); -- 2 Memórias RAM

-- =========================================================================
-- 3. RESOLUÇÃO DOS RELATÓRIOS E CONSULTAS (DQL)
-- =========================================================================

-- Q1: Produtos ordenados do mais caro para o mais barato com o nome da categoria
SELECT 
    p.nome AS produto,
    c.nome AS categoria,
    p.preco,
    p.quantidade_estoque
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY p.preco DESC;

-- Q2: Pedidos do cliente "Paulo Antunes"
SELECT 
    ped.id AS pedido_id,
    cli.nome AS cliente,
    ped.data_pedido,
    ped.status
FROM pedidos ped
INNER JOIN clientes cli ON ped.cliente_id = cli.id
WHERE cli.nome = 'Paulo Antunes';

-- Q3: Calcular o valor total de cada pedido
SELECT 
    ped.id AS pedido_id,
    cli.nome AS cliente,
    SUM(item.quantidade * item.preco_unitario) AS valor_total_pedido
FROM pedidos ped
INNER JOIN clientes cli ON ped.cliente_id = cli.id
INNER JOIN itens_pedido item ON ped.id = item.pedido_id
GROUP BY ped.id, cli.nome
ORDER BY ped.id;

-- Q4: Produtos com estoque baixo (menos de 10 unidades)
SELECT 
    nome AS produto,
    quantidade_estoque
FROM produtos
WHERE quantidade_estoque < 10
ORDER BY quantidade_estoque ASC;

-- Q5: Total faturado por categoria de produto
SELECT 
    cat.nome AS categoria,
    COALESCE(SUM(item.quantidade * item.preco_unitario), 0.00) AS total_faturado
FROM categorias cat
LEFT JOIN produtos prod ON cat.id = prod.categoria_id
LEFT JOIN itens_pedido item ON prod.id = item.produto_id
GROUP BY cat.id, cat.nome
ORDER BY total_faturado DESC;

