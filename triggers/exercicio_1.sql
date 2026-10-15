-- =========================================================================
-- EXERCÍCIO: Controle Rigoroso de Estoque
-- CONTEXTO: Sistema de E-commerce
-- =========================================================================
-- O que o código precisa fazer:
-- 1. Criar a tabela 'estoque' (id, nome_item, quantidade).
-- 2. Criar uma função de trigger BEFORE INSERT OR UPDATE que valide se a 
--    quantidade do item é menor que zero (< 0).
-- 3. Se for menor que zero, interromper a operação com 'RAISE EXCEPTION'.
-- 4. Se for zero ou maior, permitir a operação.
-- =========================================================================

-- Criando a tabela para o exercício
CREATE TABLE estoque (
    id SERIAL PRIMARY KEY,
    nome_item VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL DEFAULT 0
);

-- Função de validação de estoque
CREATE OR REPLACE FUNCTION fn_valida_estoque_minimo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantidade < 0 THEN
        RAISE EXCEPTION 'Operação cancelada! O item "%" não pode ter estoque negativo (Tentativa: % unidade(s)).', 
            NEW.nome_item, NEW.quantidade;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada
CREATE TRIGGER trg_valida_estoque
BEFORE INSERT OR UPDATE ON estoque
FOR EACH ROW
EXECUTE FUNCTION fn_valida_estoque_minimo();

-- TESTES
-- INSERT INTO estoque (nome_item, quantidade) VALUES ('Teclado Mecânico', 10); -- Sucesso
-- UPDATE estoque SET quantidade = -2 WHERE id = 1; -- Deve dar ERRO!