# 1º Prática SAEP — Banco de Dados

### Tema: Sistema de Gestão e Agendamento de Lista de Tarefas
### SGBD: PostgreSQLValor 
### Total: Estudos
---

### CONTEXTUALIZAÇÃO

Uma empresa de consultoria e gestão de projetos enfrenta sérias dificuldades em sua rotina de trabalho devido à ausência de um repositório centralizado e estruturado para o acompanhamento de demandas. O controle manual das listas de tarefas, projetos e atribuições aos colaboradores tem ocasionado perda de prazos, duplicidade de informações e ausência de histórico das atividades. Para resolver essa situação, a diretoria contratou você como especialista em Banco de Dados para projetar, criar e automatizar uma arquitetura de dados relacional segura no PostgreSQL. O sistema de banco de dados deve ser capaz de gerenciar a autenticação segura de usuários, proteger dados sensíveis com criptografia, automatizar regras de negócio via Triggers e Stored Functions, e disponibilizar visões otimizadas (Views) para os painéis de agendamento e relatórios de prazos.

---

### REGRAS DE NEGÓCIO (REQUISITOS TÉCNICOS)
Após a reunião com o gestor do projeto, foram definidas as seguintes regras de negócio obrigatórias para o banco de dados:
- Massa de Dados Inicial: 
O script do banco de dados deve conter a inserção mínima de 3 registros para cada tabela criada, respeitando as restrições de chaves primárias (PRIMARY KEY), chaves estrangeiras (FOREIGN KEY), obrigatoriedade (NOT NULL), unicidade (UNIQUE) e checagem (CHECK).Autenticação via Stored Function: Criar uma função em PL/pgSQL (fn_autenticar_usuario) que receba e-mail e senha, validando se as credenciais conferem. A função deve retornar o status da autenticação e tratar tentativas com e-mail ou senha inválidos.Segurança e LGPD (Criptografia): Os dados sensíveis dos colaboradores (como senha de acesso e CPF) não podem ser armazenados em texto puro. As senhas devem ser gravadas com algoritmo de hash (digest/md5/sha256 ou pgcrypto) e o CPF deve ser armazenado em formato criptografado/mascarado.Painel Principal (View): Criar uma View chamada vw_painel_principal que funcione como alimentação para a tela inicial do sistema, exibindo o nome do colaborador, título da tarefa, categoria, prazo de entrega e status da atividade.Busca de Colaboradores (Function de Consulta): Criar uma função em PL/pgSQL (fn_buscar_colaboradores) que receba um termo de busca (texto) e retorne uma tabela com os colaboradores cujo nome ou e-mail coincidam com o parâmetro informado.Vínculo e Validação de Tarefas (Trigger): Criar um gatilho (trg_validar_tarefa) disparado antes da inserção de uma nova tarefa para garantir que ela seja obrigatoriamente vinculada a um colaborador ativo. Além disso, o gatilho deve registrar automaticamente a data de criação e criar um log no historico_tarefas.Agendamento e Cronograma de Prazos (View Ordenada): Criar uma View chamada vw_cronograma_prazos que liste todas as atividades cadastradas ordenadas estritamente pela data de agendamento/entrega (da mais urgente para a mais distante), exibindo o status da tarefa, os dias restantes até o prazo final e o nome do responsável.

### DESAFIO
Você, como Desenvolvedor de Banco de Dados / DBA, deverá projetar o modelo conceitual/lógico (DER) e escrever os scripts em linguagem SQL (DDL, DML e PL/pgSQL) que implementem a estrutura relacional, a segurança dos dados e as automações solicitadas pela empresa.

### QUADRO DE ENTREGAS
- Entrega => Nome do Arquivo;
- Formato => Tempo Estimado;
- 1 Diagrama Entidade-Relacionamento (DER) => der_sistema_tarefas.png;
- Script SQL — Criação das Tabelas, inserção de dados, consultas, views, funções e triggers e gestao_tarefas_db.sql;
