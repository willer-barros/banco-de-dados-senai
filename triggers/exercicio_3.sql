-- =========================================================================
-- EXERCÍCIO: Trilha de Auditoria de Promoções e Salários
-- CONTEXTO: Sistema de RH
-- =========================================================================
-- O que o código precisa fazer:
-- 1. Criar a tabela 'funcionarios' (id, nome, cargo, salario).
-- 2. Criar a tabela 'historico_carreira' (id, funcionario_id, cargo_antigo, cargo_novo, salario_antigo, salario_novo, data_alteracao).
-- 3. Criar uma trigger AFTER UPDATE na tabela 'funcionarios'.
-- 4. Se o cargo OU o salário mudarem, registrar o estado antigo (OLD) e o novo (NEW) no histórico.
-- =========================================================================

-- Tabela principal de funcionários
CREATE TABLE funcionarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    salario NUMERIC(10, 2) NOT NULL
);

-- Tabela de histórico de alterações de carreira
CREATE TABLE historico_carreira (
    id SERIAL PRIMARY KEY,
    funcionario_id INT NOT NULL,
    cargo_antigo VARCHAR(50),
    cargo_novo VARCHAR(50),
    salario_antigo NUMERIC(10, 2),
    salario_novo NUMERIC(10, 2),
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Função de auditoria de RH
CREATE OR REPLACE FUNCTION fn_log_alteracao_carreira()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.cargo IS DISTINCT FROM NEW.cargo OR OLD.salario IS DISTINCT FROM NEW.salario THEN
        INSERT INTO historico_carreira (funcionario_id, cargo_antigo, cargo_novo, salario_antigo, salario_novo)
        VALUES (OLD.id, OLD.cargo, NEW.cargo, OLD.salario, NEW.salario);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada
CREATE TRIGGER trg_log_carreira
AFTER UPDATE ON funcionarios
FOR EACH ROW
EXECUTE FUNCTION fn_log_alteracao_carreira();

-- TESTE:
-- INSERT INTO funcionarios (nome, cargo, salario) VALUES ('Maria Santos', 'Desenvolvedora Jr', 3500.00);
-- UPDATE funcionarios SET cargo = 'Desenvolvedora Pleno', salario = 5500.00 WHERE id = 1;
-- SELECT * FROM historico_carreira;