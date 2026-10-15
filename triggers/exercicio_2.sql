-- =========================================================================
-- EXERCÍCIO: Atualização de Saldo Bancário por Transação
-- CONTEXTO: Sistema de Conta Corrente
-- =========================================================================
-- O que o código precisa fazer:
-- 1. Criar a tabela 'contas' (id, cliente, saldo).
-- 2. Criar a tabela 'movimentacoes' (id, conta_id, tipo ['D' para Debito, 'C' para Credito], valor).
-- 3. Criar uma trigger AFTER INSERT na tabela 'movimentacoes'.
-- 4. A função deve atualizar o saldo da tabela 'contas' somando se for 'C' ou subtraindo se for 'D'.
-- =========================================================================

-- Tabela de contas bancárias
CREATE TABLE contas (
    id SERIAL PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    saldo NUMERIC(10, 2) NOT NULL DEFAULT 0.00
);

-- Tabela de histórico de movimentações
CREATE TABLE movimentacoes (
    id SERIAL PRIMARY KEY,
    conta_id INT REFERENCES contas(id),
    tipo VARCHAR(1) CHECK (tipo IN ('C', 'D')),
    valor NUMERIC(10, 2) NOT NULL,
    data_movimentacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Função para atualizar o saldo da conta
CREATE OR REPLACE FUNCTION fn_atualiza_saldo_conta()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo = 'C' THEN
        UPDATE contas SET saldo = saldo + NEW.valor WHERE id = NEW.conta_id;
    ELSIF NEW.tipo = 'D' THEN
        UPDATE contas SET saldo = saldo - NEW.valor WHERE id = NEW.conta_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada
CREATE TRIGGER trg_atualiza_saldo
AFTER INSERT ON movimentacoes
FOR EACH ROW
EXECUTE FUNCTION fn_atualiza_saldo_conta();

-- TESTES:
-- INSERT INTO contas (cliente, saldo) VALUES ('João Silva', 500.00);
-- INSERT INTO movimentacoes (conta_id, tipo, valor) VALUES (1, 'D', 150.00);
-- SELECT * FROM contas WHERE id = 1; -- Saldo deve passar para 350.00!