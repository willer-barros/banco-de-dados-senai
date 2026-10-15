-- =========================================================================
-- EXERCÍCIO: Validação Temporal de Reservas
-- CONTEXTO: Sistema de Hotelaria
-- =========================================================================
-- O que o código precisa fazer:
-- 1. Criar a tabela 'reservas' (id, numero_quarto, data_checkin, data_checkout, valor_diaria, valor_total).
-- 2. Criar uma trigger BEFORE INSERT OR UPDATE na tabela 'reservas'.
-- 3. A função deve aplicar duas regras de negócio:
--    a) 'data_checkout' DEVE ser posterior a 'data_checkin' (se não for, dar RAISE EXCEPTION).
--    b) Calcular automaticamente o 'valor_total' multiplicando a quantidade de diárias 
--       pelo 'valor_diaria' antes de salvar o registro.
-- =========================================================================

-- Tabela de reservas
CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    numero_quarto INT NOT NULL,
    data_checkin DATE NOT NULL,
    data_checkout DATE NOT NULL,
    valor_diaria NUMERIC(10, 2) NOT NULL,
    valor_total NUMERIC(10, 2)
);

-- Função de validação e cálculo automático
CREATE OR REPLACE FUNCTION fn_processa_reserva()
RETURNS TRIGGER AS $$
DECLARE
    dias_estadia INT;
BEGIN
    -- Regra 1: Validação de coerência das datas
    IF NEW.data_checkout <= NEW.data_checkin THEN
        RAISE EXCEPTION 'A data de check-out (%) precisa ser posterior à data de check-in (%)!', 
            NEW.data_checkout, NEW.data_checkin;
    END IF;

    -- Cálculo do total de dias (no Postgres, subtrair DATE resulta em número de dias INT)
    dias_estadia := NEW.data_checkout - NEW.data_checkin;

    -- Regra 2: Preenchimento automático do valor total
    NEW.valor_total := dias_estadia * NEW.valor_diaria;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada
CREATE TRIGGER trg_processa_reserva
BEFORE INSERT OR UPDATE ON reservas
FOR EACH ROW
EXECUTE FUNCTION fn_processa_reserva();

-- TESTE:
-- 1. Teste de Erro de Data:
-- INSERT INTO reservas (numero_quarto, data_checkin, data_checkout, valor_diaria)
-- VALUES (101, '2026-11-10', '2026-11-05', 200.00); -- Deve falhar!

-- 2. Teste de Sucesso e Cálculo Automático (5 diárias):
-- INSERT INTO reservas (numero_quarto, data_checkin, data_checkout, valor_diaria)
-- VALUES (101, '2026-11-01', '2026-11-06', 200.00);
-- SELECT * FROM reservas; -- O valor_total deve ser 1000.00 gerado automaticamente!