CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);


CREATE TABLE detalhes_usuarios (
    usuario_id INT PRIMARY KEY, -- É a Chave Primária e garante o 1:1 (única e obrigatória)
    cpf VARCHAR(11) UNIQUE NOT NULL,
    endereco TEXT,
    CONSTRAINT fk_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);


INSERT INTO usuarios (nome, email) 
VALUES 
('Paulo Antunes', 'paulo.antunes@email.com'),
('Ana Souza', 'ana.souza@email.com');

-- 2. Inserindo detalhes vinculados exatamente aos IDs correspondentes da tabela usuarios
INSERT INTO detalhes_usuarios (usuario_id, cpf, endereco) 
VALUES 
(1, '12345678901', 'Rua das Flores, 123'),
(2, '98765432100', 'Av. Central, 456');

-- 2. UPDATE DE DADOS

UPDATE usuarios 
SET email = 'paulo.antunes.novo@email.com' 
WHERE id = 1;

-- Modifica o endereço nos detalhes do usuário número 2
UPDATE detalhes_usuarios 
SET endereco = 'Av. Central, 999 - Apartamento 102' 
WHERE usuario_id = 2;


-- 2. UPDATE DE ESTRUTURA (DDL - ALTER TABLE)
-- Caso precise adicionar uma nova coluna de "telefone" na tabela de detalhes posteriormente
ALTER TABLE detalhes_usuarios 
ADD COLUMN telefone VARCHAR(15);

-- Caso precise alterar o tipo de dado ou tamanho de uma coluna existente
ALTER TABLE usuarios 
ALTER COLUMN nome TYPE VARCHAR(150);


-- =========================================================================
-- COMANDOS DE EXCLUSÃO (DELETE / DROP)
-- =========================================================================

-- 1. DELETE DE REGISTROS (DML)
-- Remove o usuário com ID 1. 
-- Como configuramos "ON DELETE CASCADE", o PostgreSQL vai apagar 
-- AUTOMATICAMENTE o registro correspondente na tabela "detalhes_usuarios".
DELETE FROM usuarios 
WHERE id = 1;

-- Se quiser apagar apenas os detalhes de um usuário, mantendo o cadastro principal dele ativo:
DELETE FROM detalhes_usuarios 
WHERE usuario_id = 2;


-- 2. EXCLUSÃO DE ESTRUTURAS INTEIRAS (DDL - DROP)
-- Atenção: O DROP apaga a tabela e todos os dados permanentemente!
-- Devemos apagar primeiro a tabela que tem a chave estrangeira (detalhes_usuarios)
-- para depois conseguir apagar a tabela principal (usuarios).

DROP TABLE detalhes_usuarios;
DROP TABLE usuarios;