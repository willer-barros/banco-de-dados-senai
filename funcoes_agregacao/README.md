# Funções de agregação

### Crie uma tabela chamada funcionarios();

```bash
CREATE TABLE funcionarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) NOT NULL,
    valor_salario DECIMAL(10, 2) NOT NULL
);
```
### Após isso, insira dados fictícios nela

```bash
INSERT INTO funcionarios (nome, cpf, valor_salario)
VALUES
('Carlos Silva', '11122233344', 3500.00),
('Ana Souza', '22233344455', 4200.50),
('Roberto Lima', '33344455566', 2800.00),
('Fernanda Costa', '44455566677', 5100.75),
('João Pereira', '55566677788', 3100.00),
('Mariana Oliveira', '66677788899', 6500.00),
('Pedro Santos', '77788899900', 2950.25),
('Juliana Alves', '88899900011', 4800.00),
('Ricardo Mendes', '99900011122', 3300.50),
('Patricia Rocha', '10011122233', 7200.00),
('Lucas Ferreira', '20022233344', 2600.00),
('Camila Dias', '30033344455', 3900.90),
('Bruno Cardoso', '40044455566', 5500.00),
('Amanda Teixeira', '50055566677', 3250.00),
('Felipe Martins', '60066677788', 4100.00),
('Beatriz Gomes', '70077788899', 2750.80),
('Gustavo Ribeiro', '80088899900', 6100.00),
('Larissa Cunha', '90099900011', 3600.00),
('Thiago Barbosa', '10101010101', 4950.25),
('Vanessa Araújo', '20202020202', 3050.00);   
```

## As principais funções de agração são:
SUM() -> Soma todos os dados de uma coluna
COUNT() -> Conta todas as linhas não nulas de uma coluna
MAX() -> Retorna o valor máximo de uma coluna
MIN() -> Retorna o valor mínimo de uma coluna
AVG() -> Retorna a média aritmética