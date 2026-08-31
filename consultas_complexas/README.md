# Consultas complexas 

Agora nos vamos além do SELECT * FROM nome_da_tabela;

Vamos conhecemos sobre os famosos JOIN's
INNER JOIN -> Pega a intersecção das tabelas
LEFT JOIN -> Pega todo lado esquerdo
RIGHT JOIN -> Pega todo lado direito
FULL JOIN -> Pega TUDO.

### Para treinar isso, vamos usar o relacionamento de 1:n e n:n

1 - Exemplo 1:n:

```bash
    -- Criando as tabelas
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(id),
    valor NUMERIC(10, 2) NOT NULL
);

-- Inserindo dados de teste
INSERT INTO clientes (nome) VALUES 
('Paulo Antunes'), -- id 1 (tem pedidos)
('Ana Souza'),     -- id 2 (tem pedidos)
('Carlos Lima');   -- id 3 (NÃO tem pedidos)

INSERT INTO pedidos (cliente_id, valor) VALUES 
(1, 150.00), -- Pedido do Paulo
(1, 80.00),  -- Segundo pedido do Paulo
(2, 200.00), -- Pedido da Ana
(NULL, 50.00); -- Pedido sem cliente associado (ex: venda balcão anônima)
```



```bash
-- 1. Tabela de Produtos
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco_base NUMERIC(10, 2) NOT NULL
);

-- 2. Tabela de Pedidos
CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_nome VARCHAR(100) NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tabela Associativa N:N (Itens do Pedido)
CREATE TABLE itens_pedido (
    pedido_id INT REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_id INT REFERENCES produtos(id) ON DELETE CASCADE,
    quantidade INT NOT NULL,
    preco_unitario NUMERIC(10, 2) NOT NULL,
    PRIMARY KEY (pedido_id, produto_id)
);

-- Inserindo Produtos
INSERT INTO produtos (nome, preco_base) VALUES 
('Notebook Gamer', 4500.00), -- id 1
('Mouse Sem Fio', 120.00),   -- id 2
('Teclado Mecânico', 350.00), -- id 3
('Monitor 27"', 1300.00);    -- id 4 (NUNCA VENDIDO)

-- Inserindo Pedidos
INSERT INTO pedidos (cliente_nome) VALUES 
('Paulo Antunes'), -- Pedido 1
('Ana Souza');     -- Pedido 2

-- Inserindo os Itens (Conectando Produtos e Pedidos)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES 
(1, 1, 1, 4500.00), -- Paulo comprou 1 Notebook
(1, 2, 2, 120.00),  -- Paulo comprou 2 Mouses
(2, 2, 1, 120.00),  -- Ana comprou 1 Mouse
(2, 3, 1, 350.00);  -- Ana comprou 1 Teclado

```
