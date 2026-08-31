-- 1. DDL: CRIACAO DE TABELAS
CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE planos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL,
    valor_mensal_base DECIMAL(10,2) CHECK (valor_mensal_base > 0) NOT NULL
);

CREATE TABLE modalidades (
    id SERIAL PRIMARY KEY,
    plano_id INT REFERENCES planos(id),
    nome VARCHAR(100) NOT NULL,
    sala VARCHAR(20) NOT NULL,
    capacidade_maxima INT CHECK (capacidade_maxima > 0) NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE matriculas (
    id SERIAL PRIMARY KEY,
    aluno_id INT REFERENCES alunos(id),
    data_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativa' CHECK (status IN ('Ativa', 'Cancelada', 'Trancada'))
);

CREATE TABLE itens_matricula (
    id SERIAL PRIMARY KEY,
    matricula_id INT REFERENCES matriculas(id),
    modalidade_id INT REFERENCES modalidades(id),
    duracao_meses INT CHECK (duracao_meses > 0) NOT NULL,
    valor_mensal_aplicado DECIMAL(10,2) CHECK (valor_mensal_aplicado > 0) NOT NULL,
    taxa_adesao DECIMAL(10,2) CHECK (taxa_adesao >= 0) DEFAULT 0.00
);

-- 2. DML: INSERCAO DE DADOS
INSERT INTO planos (nome, valor_mensal_base) VALUES 
('VIP Premium', 220.00), 
('Fitness Standard', 140.00), 
('Basic Fit', 90.00);

INSERT INTO modalidades (plano_id, nome, sala, capacidade_maxima, disponivel) VALUES 
(1, 'Crossfit Pro', 'Arena 01', 15, TRUE),
(2, 'Pilates Avançado', 'Studio 02', 10, TRUE),
(3, 'Musculação Livre', 'Salão Principal', 50, TRUE);

INSERT INTO alunos (nome, email, cpf, telefone) VALUES 
('Carlos Silva', 'carlos@email.com', '11122233344', '11999990000'),
('Ana Lima', 'ana@email.com', '22233344455', '11988880000'),
('Beatriz Costa', 'bea@email.com', '33344455566', '11977770000');

INSERT INTO matriculas (aluno_id, status) VALUES 
(1, 'Ativa'), 
(1, 'Ativa'), 
(2, 'Ativa'), 
(3, 'Cancelada');

INSERT INTO itens_matricula (matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao) VALUES 
(1, 1, 6, 220.00, 50.00),
(2, 2, 3, 140.00, 30.00),
(3, 3, 12, 90.00, 0.00),
(4, 1, 1, 220.00, 50.00);

-- 3. DQL / VIEWS
-- Q1
CREATE VIEW vw_modalidades_custo_estimado AS
SELECT 
    m.nome AS modalidade, 
    m.sala, 
    p.nome AS plano, 
    ROUND(p.valor_mensal_base * 1.10, 2) AS mensalidade_com_taxa
FROM modalidades m
JOIN planos p ON m.plano_id = p.id
ORDER BY mensalidade_com_taxa DESC;

-- Q2
CREATE VIEW vw_matriculas_ativas AS
SELECT 
    a.nome AS aluno, 
    a.cpf, 
    mod.nome AS modalidade, 
    mod.sala, 
    im.duracao_meses, 
    mat.data_inicio
FROM matriculas mat
JOIN alunos a ON mat.aluno_id = a.id
JOIN itens_matricula im ON mat.id = im.matricula_id
JOIN modalidades mod ON im.modalidade_id = mod.id
WHERE mat.status = 'Ativa';

-- Q3
CREATE VIEW vw_alunos_vip AS
SELECT 
    a.nome AS aluno, 
    COUNT(mat.id) AS total_matriculas, 
    SUM((im.valor_mensal_aplicado * im.duracao_meses) + im.taxa_adesao) AS total_investido
FROM alunos a
JOIN matriculas mat ON a.id = mat.aluno_id
JOIN itens_matricula im ON mat.id = im.matricula_id
WHERE mat.status = 'Ativa'
GROUP BY a.id, a.nome
HAVING SUM((im.valor_mensal_aplicado * im.duracao_meses) + im.taxa_adesao) > 1000.00;

-- Q4 (Consulta direta)
SELECT m.*, p.nome AS plano, p.valor_mensal_base
FROM modalidades m
JOIN planos p ON m.plano_id = p.id
WHERE m.capacidade_maxima >= 15 
  AND p.valor_mensal_base > 100.00 
  AND m.disponivel = TRUE;

-- Q5
CREATE VIEW vw_faturamento_medio_plano AS
SELECT 
    p.nome AS plano, 
    SUM((im.valor_mensal_aplicado * im.duracao_meses) + im.taxa_adesao) AS faturamento_total,
    ROUND(AVG(im.duracao_meses), 1) AS media_meses_contratados
FROM itens_matricula im
JOIN matriculas mat ON im.matricula_id = mat.id
JOIN modalidades m ON im.modalidade_id = m.id
JOIN planos p ON m.plano_id = p.id
WHERE mat.status = 'Ativa'
GROUP BY p.nome;
