-- 1. DDL: CRIACAO DE TABELAS
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    cnh VARCHAR(11) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL,
    valor_diaria_base DECIMAL(10,2) CHECK (valor_diaria_base > 0) NOT NULL
);

CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    categoria_id INT REFERENCES categorias(id),
    modelo VARCHAR(100) NOT NULL,
    placa VARCHAR(7) UNIQUE NOT NULL,
    ano_fabricacao INT CHECK (ano_fabricacao >= 2018) NOT NULL,
-- 1. DDL: CRIACAO DE TABELAS
CREATE TABLE hospedes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias_quarto (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL,
    valor_diaria_base DECIMAL(10,2) CHECK (valor_diaria_base > 0) NOT NULL
);

CREATE TABLE quartos (
    id SERIAL PRIMARY KEY,
    categoria_id INT REFERENCES categorias_quarto(id),
    numero VARCHAR(10) UNIQUE NOT NULL,
    andar INT CHECK (andar >= 0) NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    hospede_id INT REFERENCES hospedes(id),
    data_checkin TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Confirmada' CHECK (status IN ('Confirmada', 'Finalizada', 'Cancelada'))
);

CREATE TABLE itens_reserva (
    id SERIAL PRIMARY KEY,
    reserva_id INT REFERENCES reservas(id),
    quarto_id INT REFERENCES quartos(id),
    dias_hospedagem INT CHECK (dias_hospedagem > 0) NOT NULL,
    valor_diaria_aplicado DECIMAL(10,2) CHECK (valor_diaria_aplicado > 0) NOT NULL,
    taxa_limpeza DECIMAL(10,2) CHECK (taxa_limpeza >= 0) DEFAULT 0.00
);

-- 2. DML: INSERCAO DE DADOS
INSERT INTO categorias_quarto (nome, valor_diaria_base) VALUES 
('Suíte Luxo', 350.00), 
('Chalé', 250.00), 
('Quarto Standard', 150.00);

INSERT INTO quartos (categoria_id, numero, andar, disponivel) VALUES 
(1, '101', 1, TRUE),
(2, '201', 2, TRUE),
(3, '001', 0, TRUE);

INSERT INTO hospedes (nome, email, cpf, telefone) VALUES 
('Carlos Silva', 'carlos@email.com', '11122233344', '11999990000'),
('Ana Lima', 'ana@email.com', '22233344455', '11988880000'),
('Beatriz Costa', 'bea@email.com', '33344455566', '11977770000');

INSERT INTO reservas (hospede_id, status) VALUES 
(1, 'Finalizada'), 
(1, 'Confirmada'), 
(2, 'Finalizada'), 
(3, 'Cancelada');

INSERT INTO itens_reserva (reserva_id, quarto_id, dias_hospedagem, valor_diaria_aplicado, taxa_limpeza) VALUES 
(1, 1, 4, 350.00, 80.00),
(2, 2, 2, 250.00, 50.00),
(3, 3, 3, 150.00, 40.00),
(4, 1, 1, 350.00, 80.00);

-- 3. DQL / VIEWS
-- Q1
CREATE VIEW vw_quartos_custo_estimado AS
SELECT 
    q.numero AS quarto, 
    q.andar, 
    c.nome AS categoria, 
    ROUND(c.valor_diaria_base * 1.10, 2) AS diaria_com_taxa
FROM quartos q
JOIN categorias_quarto c ON q.categoria_id = c.id
ORDER BY diaria_com_taxa DESC;

-- Q2
CREATE VIEW vw_reservas_ativas AS
SELECT 
    h.nome AS hospede, 
    h.telefone, 
    q.numero AS quarto, 
    c.nome AS categoria, 
    ir.dias_hospedagem, 
    r.data_checkin
FROM reservas r
JOIN hospedes h ON r.hospede_id = h.id
JOIN itens_reserva ir ON r.id = ir.reserva_id
JOIN quartos q ON ir.quarto_id = q.id
JOIN categorias_quarto c ON q.categoria_id = c.id
WHERE r.status = 'Confirmada';

-- Q3
CREATE VIEW vw_hospedes_vip AS
SELECT 
    h.nome AS hospede, 
    COUNT(r.id) AS total_reservas, 
    SUM((ir.valor_diaria_aplicado * ir.dias_hospedagem) + ir.taxa_limpeza) AS total_gasto
FROM hospedes h
JOIN reservas r ON h.id = r.hospede_id
JOIN itens_reserva ir ON r.id = ir.reserva_id
WHERE r.status = 'Finalizada'
GROUP BY h.id, h.nome
HAVING SUM((ir.valor_diaria_aplicado * ir.dias_hospedagem) + ir.taxa_limpeza) > 1200.00;

-- Q4 (Consulta direta)
SELECT q.*, c.nome AS categoria, c.valor_diaria_base
FROM quartos q
JOIN categorias_quarto c ON q.categoria_id = c.id
WHERE q.andar >= 1 
  AND c.nome IN ('Suíte Luxo', 'Chalé') 
  AND c.valor_diaria_base > 200.00 
  AND q.disponivel = TRUE;

-- Q5
CREATE VIEW vw_faturamento_medio_categoria AS
SELECT 
    c.nome AS categoria, 
    SUM((ir.valor_diaria_aplicado * ir.dias_hospedagem) + ir.taxa_limpeza) AS faturamento_total,
    ROUND(AVG(ir.valor_diaria_aplicado), 2) AS media_diaria_aplicada
FROM itens_reserva ir
JOIN reservas r ON ir.reserva_id = r.id
JOIN quartos q ON ir.quarto_id = q.id
JOIN categorias_quarto c ON q.categoria_id = c.id
WHERE r.status = 'Finalizada'
GROUP BY c.nome;
