Requisitos do Modelo Relacional
O banco de dados de um sistema de gestão de academia de ginástica deve conter 5 tabelas:

1. Alunos
id: Chave primária auto-incremento.
nome: Texto obrigatório.
email: Texto único e obrigatório.
cpf: Texto de 11 caracteres, único e obrigatório.
telefone: Texto obrigatório.
data_cadastro: Data/hora com valor padrão da data/hora atual.
2. Planos
id: Chave primária auto-incremento.
nome: Texto único e obrigatório (ex: 'VIP Premium', 'Fitness Standard', 'Basic Fit').
valor_mensal_base: Valor numérico/decimal obrigatório (deve ser maior que zero).
3. Modalidades
id: Chave primária auto-incremento.
plano_id: Chave estrangeira referenciando planos(id).
nome: Texto obrigatório (ex: 'Crossfit Pro', 'Pilates Avançado', 'Musculação Livre').
sala: Texto obrigatório (ex: 'Arena 01', 'Studio 02').
capacidade_maxima: Inteiro obrigatório (deve ser maior que zero).
disponivel: Booleano com valor padrão TRUE.
4. Matrículas
id: Chave primária auto-incremento.
aluno_id: Chave estrangeira referenciando alunos(id).
data_inicio: Data/hora com valor padrão da data/hora atual.
status: Texto (valores permitidos: 'Ativa', 'Cancelada', 'Trancada'). Valor padrão: 'Ativa'.
5. Itens Matrícula
id: Chave primária auto-incremento.
matricula_id: Chave estrangeira referenciando matriculas(id).
modalidade_id: Chave estrangeira referenciando modalidades(id).
duracao_meses: Valor inteiro obrigatório (deve ser maior que zero).
valor_mensal_aplicado: Valor decimal praticado no contrato (obrigatório e maior que zero).
taxa_adesao: Valor decimal de taxa inicial (deve ser maior ou igual a zero, padrão 0.00).
Tarefas a Serem Executadas
[DDL] Criação de Tabelas
Escreva o script de criação de todas as 5 tabelas com suas devidas restrições (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT).

[DML] Carga de Dados
Insira no mínimo:

3 Planos
3 Modalidades
3 Alunos
4 Matrículas
4 Itens associados às matrículas
[DQL / Views] Visões e Consultas Avançadas
Q1 (View com Expressão Matemática)
Criar a View vw_modalidades_custo_estimado exibindo o nome da modalidade, a sala, o nome do plano associado e o valor mensal ajustado com a taxa de manutenção de equipamentos (+10% sobre o valor base do plano), ordenado da mensalidade mais alta para a mais baixa.

Q2 (View com Filtro de Múltiplos Joins)
Criar a View vw_matriculas_ativas listando o nome do aluno, CPF, nome da modalidade, sala, duração em meses do contrato e data de início, considerando apenas matrículas com status 'Ativa'.

Q3 (View com Agrupamento e HAVING)
Criar a View vw_alunos_vip calculando o valor total contratado em matrículas 'Ativa' (Soma de $(\text{valor_mensal_aplicado} \times \text{duracao_meses}) + \text{taxa_adesao}$). Exibir o nome do aluno, quantidade de contratos ativos e o valor total investido, filtrando via HAVING apenas alunos cujo total investido seja superior a R$ 1.000,00.

Q4 (Consulta com Condições Compostas)
Listar as modalidades com capacidade máxima igual ou superior a 15 alunos, vinculadas a planos com valor mensal base superior a R$ 100,00 e que estejam marcadas como disponíveis.

Q5 (View com Média e Agrupamento por Plano)
Criar a View vw_faturamento_medio_plano exibindo o nome do plano, o faturamento total acumulado das matrículas ativas e a média da duração dos contratos (em meses).
