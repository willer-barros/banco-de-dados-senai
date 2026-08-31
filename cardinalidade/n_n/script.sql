-- =========================================================================
-- 1. CRIAÇÃO DAS TABELAS (DDL)
-- =========================================================================

-- Tabela Entidade 1
CREATE TABLE alunos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Tabela Entidade 2
CREATE TABLE turmas (
    id SERIAL PRIMARY KEY,
    nome_turma VARCHAR(50) NOT NULL
);

-- Tabela Associativa / Junção (Coração do Relacionamento N:N)
-- Unimos as chaves das duas tabelas anteriores para formar uma Chave Primária Composta.
CREATE TABLE matriculas (
    aluno_id INT NOT NULL,
    turma_id INT NOT NULL,
    data_matricula TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Chave Primária Composta (Impede que o mesmo aluno se matricule duas vezes na mesma turma)
    PRIMARY KEY (aluno_id, turma_id),
    
    -- Restrições de Chave Estrangeira com deleção em cascata
    CONSTRAINT fk_aluno FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE CASCADE,
    CONSTRAINT fk_turma FOREIGN KEY (turma_id) REFERENCES turmas(id) ON DELETE CASCADE
);


-- =========================================================================
-- 2. GRAVAÇÃO DE DADOS / INSERÇÃO (DML)
-- =========================================================================

-- Inserindo os Alunos (IDs gerados: 1 e 2)
INSERT INTO alunos (nome, email) 
VALUES 
('Paulo Antunes', 'paulo.antunes@email.com'),
('Ana Souza', 'ana.souza@email.com');

-- Inserindo as Turmas (IDs gerados: 1 e 2)
INSERT INTO turmas (nome_turma) 
VALUES 
('3º Ano - Desenvolvimento de Sistemas'),
('Inglês Instrumental');

-- Inserindo as Matrículas (Criando os vínculos N:N)
INSERT INTO matriculas (aluno_id, turma_id) 
VALUES 
(1, 1), -- Paulo está no 3º Ano
(1, 2), -- Paulo também está no Inglês (O aluno 1 está em várias turmas)
(2, 1); -- Ana também está no 3º Ano (A turma 1 tem vários alunos)


-- =========================================================================
-- 3. COMANDOS DE ATUALIZAÇÃO (DML e DDL)
-- =========================================================================

-- Atualizando dados estruturais (Ex: Adicionando uma coluna de nota/conceito final na tabela de junção)
ALTER TABLE matriculas 
ADD COLUMN nota_final NUMERIC(4, 2);

-- Atualizando dados de um vínculo específico (Dando nota para o Paulo na turma de Inglês)
UPDATE matriculas 
SET nota_final = 9.5 
WHERE aluno_id = 1 AND turma_id = 2;


-- =========================================================================
-- 4. COMANDOS DE EXCLUSÃO (DML e DDL)
-- =========================================================================

-- Cancelando uma matrícula específica (Removendo o Paulo apenas da turma de Inglês)
DELETE FROM matriculas 
WHERE aluno_id = 1 AND turma_id = 2;

-- Excluindo o Aluno 1 (Paulo) por completo
-- O "ON DELETE CASCADE" vai disparar na tabela "matriculas" e apagará 
-- automaticamente todas as linhas onde o aluno_id era 1, sem afetar as turmas.
DELETE FROM alunos 
WHERE id = 1;

-- Exclusão de tabelas inteiras (A tabela associativa DEVE ser apagada primeiro)
DROP TABLE matriculas;
DROP TABLE turmas;
DROP TABLE alunos;