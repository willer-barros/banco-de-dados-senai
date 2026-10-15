-- =========================================================================
-- EXERCÍCIO: Soft Delete (Exclusão Lógica) de Clientes
-- CONTEXTO: Sistema de CRM / Proteção de Dados
-- =========================================================================
-- O que o código precisa fazer:
-- 1. Criar a tabela 'clientes' (id, nome, email, ativo BOOLEAN DEFAULT TRUE).
-- 2. Criar a tabela 'clientes_deletados_log' (id, cliente_id, nome, email, data_remocao).
-- 3. Criar uma trigger BEFORE DELETE na tabela 'clientes'.
-- 4. Quando alguém tentar executar 'DELETE FROM clientes', a trigger deve:
--    a) Copiar os dados para a tabela 'clientes_deletados_log'.
--    b) Atualizar o registro original para 'ativo = FALSE' ao invés de deletá-lo fisicamente.
--    c) Retornar NULL para CANCELAR o comando DELETE original do banco.
-- =========================================================================

-- Tabela de clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de log de desativação
CREATE TABLE clientes_deletados_log (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    nome VARCHAR(100),
    email VARCHAR(100),
    data_remocao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Função para interceptar e transformar a exclusão em desativação (Soft Delete)
CREATE OR REPLACE FUNCTION fn_soft_delete_cliente()
RETURNS TRIGGER AS $$
BEGIN
    -- Registrar na tabela de auditoria
    INSERT INTO clientes_deletados_log (cliente_id, nome, email)
    VALUES (OLD.id, OLD.nome, OLD.email);

    -- Desativar o cliente fisicamente
    UPDATE clientes SET ativo = FALSE WHERE id = OLD.id;

    -- Retornar NULL cancela a instrução DELETE original!
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada
CREATE TRIGGER trg_soft_delete_cliente
BEFORE DELETE ON clientes
FOR EACH ROW
EXECUTE FUNCTION fn_soft_delete_cliente();

-- TESTES:
-- INSERT INTO clientes (nome, email) VALUES ('Arthur Melzi', 'carlos@email.com');
-- DELETE FROM clientes WHERE id = 1;
-- SELECT * FROM clientes; -- O registro ainda está lá, mas 'ativo' virou FALSE!
-- SELECT * FROM clientes_deletados_log; -- O registro de log foi gerado.