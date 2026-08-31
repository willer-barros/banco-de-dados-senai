-- Criei esse exemplo apenas para ter dados para restaurar

create TABLE pessoa(
    id serial PRIMARY key,
    nome VARCHAR(150) not null,
    cpf VARCHAR(11) not null unique
);

insert into pessoa(nome, cpf) values 
('willer', '00011122277'),
('clovis', '00011122266'),
('elisa', '00011122255'),
('valentina', '00011122244'),
('paulo', '00011122233');

-- Aqui de fato começará o processo de backup

