CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    especialidade_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    crm VARCHAR(20) UNIQUE NOT NULL,
    valor_consulta NUMERIC(10, 2) NOT NULL CHECK (valor_consulta > 0),
    
    CONSTRAINT fk_medico_especialidade 
        FOREIGN KEY (especialidade_id) 
        REFERENCES especialidades(id) 
        ON DELETE RESTRICT
);


CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL,
    paciente_id INT NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Realizada', 'Cancelada')),
    
    CONSTRAINT fk_consulta_medico 
        FOREIGN KEY (medico_id) 
        REFERENCES medicos(id) 
        ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_paciente 
        FOREIGN KEY (paciente_id) 
        REFERENCES pacientes(id) 
        ON DELETE CASCADE
);


CREATE TABLE exames_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL,
    nome_exame VARCHAR(100) NOT NULL,
    valor_exame NUMERIC(10, 2) NOT NULL CHECK (valor_exame >= 0),
    
    CONSTRAINT fk_exame_consulta 
        FOREIGN KEY (consulta_id) 
        REFERENCES consultas(id) 
        ON DELETE CASCADE
);

--povoando tabelas

INSERT INTO especialidades (nome) VALUES 
('Cardiologia'),
('Pediatria'),
('Dermatologia');


INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta) VALUES 
(1, 'Dra. Carla Mendes', 'CRM/SP 123456', 350.00),
(2, 'Dr. Roberto Alves', 'CRM/SP 654321', 250.00),
(3, 'Dra. Juliana Lima', 'CRM/SP 789123', 300.00);


INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES 
('Carlos Silva', 'carlos.silva@email.com', '11122233344', '1985-05-12'),
('Mariana Costa', 'mariana.costa@email.com', '55566677788', '2010-08-25'),
('Lucas Pereira', 'lucas.pereira@email.com', '99900011122', '1998-11-03');


INSERT INTO consultas (medico_id, paciente_id, data_hora, status) VALUES 
(1, 1, '2026-03-10 09:00:00', 'Realizada'), -- Consulta 1 (Carlos com Dra. Carla)
(1, 3, '2026-03-10 10:30:00', 'Realizada'), -- Consulta 2 (Lucas com Dra. Carla)
(2, 2, '2026-03-11 14:00:00', 'Realizada'), -- Consulta 3 (Mariana com Dr. Roberto)
(3, 1, '2026-03-12 11:00:00', 'Agendada');  -- Consulta 4 (Carlos com Dra. Juliana)


INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame) VALUES 
(1, 'Eletrocardiograma', 120.00),
(1, 'Ecocardiograma', 250.00),
(2, 'Hemograma Completo', 45.00),
(3, 'Exame de Urina', 30.00);

SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
INNER JOIN especialidades e ON m.especialidade_id = e.id
ORDER BY m.valor_consulta DESC;

SELECT 
    c.id AS consulta_id,
    c.data_hora,
    m.nome AS medico,
    e.nome AS especialidade,
    c.status
FROM consultas c
INNER JOIN pacientes p ON c.paciente_id = p.id
INNER JOIN medicos m ON c.medico_id = m.id
INNER JOIN especialidades e ON m.especialidade_id = e.id
WHERE p.nome = 'Carlos Silva'
ORDER BY c.data_hora ASC;

SELECT 
    c.id AS consulta_id,
    p.nome AS paciente,
    m.nome AS medico,
    m.valor_consulta,
    COALESCE(SUM(ex.valor_exame), 0.00) AS total_exames,
    (m.valor_consulta + COALESCE(SUM(ex.valor_exame), 0.00)) AS valor_total_atendimento
FROM consultas c
INNER JOIN pacientes p ON c.paciente_id = p.id
INNER JOIN medicos m ON c.medico_id = m.id
LEFT JOIN exames_consulta ex ON c.id = ex.consulta_id
GROUP BY c.id, p.nome, m.nome, m.valor_consulta
ORDER BY c.id;

SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
INNER JOIN especialidades e ON m.especialidade_id = e.id
WHERE m.valor_consulta > 300.00;

SELECT 
    e.nome AS especialidade,
    COUNT(c.id) AS quantidade_consultas,
    COALESCE(SUM(m.valor_consulta), 0.00) AS faturamento_consultas
FROM especialidades e
INNER JOIN medicos m ON e.id = m.especialidade_id
LEFT JOIN consultas c ON m.id = c.medico_id AND c.status = 'Realizada'
GROUP BY e.id, e.nome
ORDER BY faturamento_consultas DESC;
