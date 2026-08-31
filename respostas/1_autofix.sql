CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mecanicos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(50) NOT NULL,
    valor_hora NUMERIC(10, 2) NOT NULL CHECK (valor_hora > 0)
);

CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    placa VARCHAR(7) UNIQUE NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    ano INT NOT NULL CHECK (ano > 1900),
    
    CONSTRAINT fk_veiculo_cliente 
        FOREIGN KEY (cliente_id) 
        REFERENCES clientes(id) 
        ON DELETE CASCADE
);

CREATE TABLE ordens_servico (
    id SERIAL PRIMARY KEY,
    veiculo_id INT NOT NULL,
    mecanico_id INT NOT NULL,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_mao_obra NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (valor_mao_obra >= 0),
    status VARCHAR(20) DEFAULT 'Em Aberto' CHECK (status IN ('Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada')),
    
    CONSTRAINT fk_os_veiculo 
        FOREIGN KEY (veiculo_id) 
        REFERENCES veiculos(id) 
        ON DELETE RESTRICT,
    CONSTRAINT fk_os_mecanico 
        FOREIGN KEY (mecanico_id) 
        REFERENCES mecanicos(id) 
        ON DELETE RESTRICT
);

CREATE TABLE pecas_os (
    id SERIAL PRIMARY KEY,
    os_id INT NOT NULL,
    nome_peca VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    valor_unitario NUMERIC(10, 2) NOT NULL CHECK (valor_unitario > 0),
    
    CONSTRAINT fk_peca_os 
        FOREIGN KEY (os_id) 
        REFERENCES ordens_servico(id) 
        ON DELETE CASCADE
);

INSERT INTO clientes (nome, email, telefone, cpf) VALUES 
('Fernanda Lima', 'fernanda.lima@email.com', '(48) 99911-2233', '11122233344'),
('Roberto Souza', 'roberto.souza@email.com', '(48) 98822-4455', '55566677788'),
('Amanda Martins', 'amanda.martins@email.com', '(48) 97733-6677', '99900011122');

INSERT INTO mecanicos (nome, especialidade, valor_hora) VALUES 
('Carlos Eduardo', 'Motor e Câmbio', 120.00),
('Marcos Vinicius', 'Suspensão e Freios', 85.00),
('João Pedro', 'Elétrica e Injeção', 100.00);

INSERT INTO veiculos (cliente_id, placa, modelo, marca, ano) VALUES 
(1, 'ABC1D23', 'Civic 2.0', 'Honda', 2020),       -- Veículo 1 (Fernanda)
(1, 'XYZ9K88', 'Fit 1.5', 'Honda', 2018),         -- Veículo 2 (Fernanda)
(2, 'KLR4M55', 'Corolla 2.0', 'Toyota', 2021),    -- Veículo 3 (Roberto)
(3, 'JHG8T77', 'Onix 1.0 Turbo', 'Chevrolet', 2022);-- Veículo 4 (Amanda)

INSERT INTO ordens_servico (veiculo_id, mecanico_id, valor_mao_obra, status) VALUES 
(1, 1, 350.00, 'Concluida'),   -- OS 1 (Civic da Fernanda com Carlos)
(2, 2, 180.00, 'Concluida'),   -- OS 2 (Fit da Fernanda com Marcos)
(3, 1, 500.00, 'Em Andamento'),-- OS 3 (Corolla do Roberto com Carlos)
(4, 3, 200.00, 'Concluida');   -- OS 4 (Onix da Amanda com João)

INSERT INTO pecas_os (os_id, nome_peca, quantidade, valor_unitario) VALUES 
(1, 'Jogo de Velas Iridium', 1, 240.00),
(1, 'Óleo Sintético 5W30 (Litro)', 4, 60.00),
(2, 'Pastilha de Freio Dianteira', 1, 150.00),
(4, 'Bateria 60Ah', 1, 420.00);

SELECT 
    v.marca,
    v.modelo,
    v.placa,
    v.ano,
    c.nome AS proprietario,
    c.telefone
FROM veiculos v
INNER JOIN clientes c ON v.cliente_id = c.id
ORDER BY v.marca ASC, v.modelo ASC;

SELECT 
    os.id AS os_id,
    v.placa,
    v.modelo,
    os.data_abertura,
    m.nome AS mecanico,
    os.status
FROM ordens_servico os
INNER JOIN veiculos v ON os.veiculo_id = v.id
INNER JOIN clientes c ON v.cliente_id = c.id
INNER JOIN mecanicos m ON os.mecanico_id = m.id
WHERE c.nome = 'Fernanda Lima'
ORDER BY os.data_abertura DESC;

SELECT 
    os.id AS os_id,
    v.placa,
    m.nome AS mecanico,
    os.valor_mao_obra,
    COALESCE(SUM(p.quantidade * p.valor_unitario), 0.00) AS total_pecas,
    (os.valor_mao_obra + COALESCE(SUM(p.quantidade * p.valor_unitario), 0.00)) AS valor_total_os
FROM ordens_servico os
INNER JOIN veiculos v ON os.veiculo_id = v.id
INNER JOIN mecanicos m ON os.mecanico_id = m.id
LEFT JOIN pecas_os p ON os.id = p.os_id
GROUP BY os.id, v.placa, m.nome, os.valor_mao_obra
ORDER BY os.id;

SELECT 
    nome AS mecanico,
    especialidade,
    valor_hora
FROM mecanicos
WHERE valor_hora > 90.00
ORDER BY valor_hora DESC;

SELECT 
    m.especialidade,
    COUNT(os.id) AS qtd_servicos_concluidos,
    COALESCE(SUM(os.valor_mao_obra), 0.00) AS faturamento_mao_obra
FROM mecanicos m
LEFT JOIN ordens_servico os ON m.id = os.mecanico_id AND os.status = 'Concluida'
GROUP BY m.especialidade
ORDER BY faturamento_mao_obra DESC;
