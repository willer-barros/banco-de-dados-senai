CREATE TABLE leitores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE livros (
    id SERIAL PRIMARY KEY,
    categoria_id INT REFERENCES categorias(id),
    titulo VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    taxa_diaria DECIMAL(10,2) CHECK (taxa_diaria > 0) NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE emprestimos (
    id SERIAL PRIMARY KEY,
    leitor_id INT REFERENCES leitores(id),
    data_emprestimo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Devolvido', 'Atrasado'))
);

CREATE TABLE itens_emprestimo (
    id SERIAL PRIMARY KEY,
    emprestimo_id INT REFERENCES emprestimos(id),
    livro_id INT REFERENCES livros(id),
    quantidade INT CHECK (quantidade > 0) NOT NULL,
    valor_diaria DECIMAL(10,2) CHECK (valor_diaria >= 0) NOT NULL
);

INSERT INTO categorias (nome) VALUES ('Ficção'), ('História'), ('Tecnologia');

INSERT INTO livros (categoria_id, titulo, isbn, taxa_diaria, disponivel) VALUES 
(1, 'O Senhor dos Anéis', '9780007525546', 7.50, TRUE),
(1, '1984', '9780451524935', 4.00, TRUE),
(3, 'Entendendo Algoritmos', '9788575225639', 6.00, TRUE);

INSERT INTO leitores (nome, email, cpf, telefone) VALUES 
('Carlos Silva', 'carlos@email.com', '11122233344', '11999990000'),
('Ana Lima', 'ana@email.com', '22233344455', '11988880000'),
('Beatriz Costa', 'bea@email.com', '33344455566', '11977770000');

INSERT INTO emprestimos (leitor_id, status) VALUES 
(1, 'Devolvido'), (1, 'Ativo'), (2, 'Devolvido'), (3, 'Atrasado');

INSERT INTO itens_emprestimo (emprestimo_id, livro_id, quantidade, valor_diaria) VALUES 
(1, 1, 2, 7.50),
(2, 2, 1, 4.00),
(3, 3, 3, 6.00),
(4, 1, 1, 7.50);

CREATE VIEW vw_acervo_ordenado AS
SELECT l.titulo AS livro, l.isbn, c.nome AS categoria, l.taxa_diaria
FROM livros l
JOIN categorias c ON l.categoria_id = c.id
ORDER BY l.taxa_diaria DESC;

-- Q2
CREATE VIEW vw_emprestimos_carlos AS
SELECT emp.id AS emprestimo_id, emp.data_emprestimo, liv.titulo AS livro, ie.quantidade, emp.status
FROM emprestimos emp
JOIN leitores lei ON emp.leitor_id = lei.id
JOIN itens_emprestimo ie ON emp.id = ie.emprestimo_id
JOIN livros liv ON ie.livro_id = liv.id
WHERE lei.nome = 'Carlos Silva';

-- Q3
CREATE VIEW vw_total_emprestimos AS
SELECT emp.id AS emprestimo_id, lei.nome AS leitor, SUM(ie.quantidade * ie.valor_diaria) AS valor_total
FROM emprestimos emp
JOIN leitores lei ON emp.leitor_id = lei.id
JOIN itens_emprestimo ie ON emp.id = ie.emprestimo_id
GROUP BY emp.id, lei.nome;

-- Q4 (Consulta direta)
SELECT l.* 
FROM livros l
JOIN categorias c ON l.categoria_id = c.id
WHERE c.nome = 'Ficção' AND l.taxa_diaria > 5.00 AND l.disponivel = TRUE;

-- Q5
CREATE VIEW vw_faturamento_por_categoria AS
SELECT c.nome AS categoria, SUM(ie.quantidade * ie.valor_diaria) AS faturamento_total
FROM itens_emprestimo ie
JOIN emprestimos emp ON ie.emprestimo_id = emp.id
JOIN livros l ON ie.livro_id = l.id
JOIN categorias c ON l.categoria_id = c.id
WHERE emp.status = 'Devolvido'
GROUP BY c.nome;
