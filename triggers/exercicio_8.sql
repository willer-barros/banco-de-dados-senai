-- =========================================================================
-- EXERCÍCIO: Propagação de Status entre Projeto e Tarefas
-- CONTEXTO: Sistema de Gestão de Projetos (Tabelas: projetos e tarefas)
-- =========================================================================
-- O que o código precisa fazer:
-- 1. Criar a tabela 'projetos' (id, nome_projeto, status ['EM ANDAMENTO', 'CANCELADO', 'CONCLUIDO']).
-- 2. Criar a tabela 'tarefas' (id, projeto_id FK, descricao, status ['PENDENTE', 'CANCELADA', 'CONCLUIDA']).
-- 3. Criar uma trigger AFTER UPDATE na tabela 'projetos'.
-- 4. Regra de negócio: Se o status de um projeto for alterado para 'CANCELADO', 
--    a trigger deve atualizar automaticamente todas as tarefas vinculadas a esse projeto 
--    cujo status ainda esteja 'PENDENTE' para o status 'CANCELADA'.
-- =========================================================================

-- Tabela Pai (Projetos)
CREATE TABLE projetos (
    id SERIAL PRIMARY KEY,
    nome_projeto VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'EM ANDAMENTO'
);

-- Tabela Filha (Tarefas)
CREATE TABLE tarefas (
    id SERIAL PRIMARY KEY,
    projeto_id INT REFERENCES projetos(id) ON DELETE CASCADE,
    descricao VARCHAR(200) NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDENTE'
);

-- Função para propagar cancelamento em cascata
CREATE OR REPLACE FUNCTION fn_propaga_cancelamento_projeto()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o projeto mudou para 'CANCELADO'
    IF NEW.status = 'CANCELADO' AND OLD.status IS DISTINCT FROM 'CANCELADO' THEN
        
        -- Atualiza todas as tarefas pendentes daquele projeto para 'CANCELADA'
        UPDATE tarefas
        SET status = 'CANCELADA'
        WHERE projeto_id = NEW.id AND status = 'PENDENTE';
        
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger vinculada
CREATE TRIGGER trg_cancela_tarefas_projeto
AFTER UPDATE ON projetos
FOR EACH ROW
EXECUTE FUNCTION fn_propaga_cancelamento_projeto();

-- TESTE:

-- INSERT INTO projetos (nome_projeto, status) VALUES ('Migração Cloud', 'EM ANDAMENTO'); -- ID 1
-- INSERT INTO tarefas (projeto_id, descricao, status) VALUES (1, 'Configurar AWS RDS', 'PENDENTE');
-- INSERT INTO tarefas (projeto_id, descricao, status) VALUES (1, 'Ajustar variáveis de ambiente', 'PENDENTE');
-- 
-- -- Agora cancela o projeto:
-- UPDATE projetos SET status = 'CANCELADO' WHERE id = 1;
-- 
-- -- Verifique as tarefas para ver se todas mudaram para 'CANCELADA' automaticamente:
-- SELECT * FROM tarefas WHERE projeto_id = 1;