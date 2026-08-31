Contexto do Desafio

Você foi contratado pela rede de clínicas MedCare. A empresa está expandindo suas operações e precisa substituir o controle em planilhas por um banco de dados relacional confiável no PostgreSQL.

Sua missão é criar o esquema do banco de dados, aplicar regras de integridade (chaves primárias, estrangeiras, checagens e valores padrão), cadastrar os dados iniciais do corpo médico, pacientes e atendimentos, e gerar relatórios estratégicos para a gestão hospitalar.

Requisitos do Modelo Relacional

O banco de dados deve conter 5 tabelas:

pacientes:

id: Chave primária auto-incremento.

nome: Texto obrigatório.

email: Texto único e obrigatório.

cpf: Texto de 11 caracteres, único e obrigatório.

data_nascimento: Data obrigatória.

data_cadastro: Data com valor padrão da data/hora atual.

especialidades:

id: Chave primária auto-incremento.

nome: Texto único e obrigatório (ex: 'Cardiologia', 'Pediatria', 'Dermatologia').

medicos:

id: Chave primária auto-incremento.

especialidade_id: Chave estrangeira referenciando especialidades(id).

nome: Texto obrigatório.

crm: Texto único e obrigatório.

valor_consulta: Valor numérico/decimal obrigatório (deve ser maior que zero).

consultas:

id: Chave primária auto-incremento.

medico_id: Chave estrangeira referenciando medicos(id).

paciente_id: Chave estrangeira referenciando pacientes(id).

data_hora: Data/hora obrigatória.

status: Texto (valores permitidos: 'Agendada', 'Realizada', 'Cancelada'). Valor padrão: 'Agendada'.

exames_consulta (Tabela associativa/dependente de exames solicitados na consulta):

id: Chave primária auto-incremento.

consulta_id: Chave estrangeira referenciando consultas(id).

nome_exame: Texto obrigatório (ex: 'Hemograma Completo', 'Eletrocardiograma').

valor_exame: Valor decimal do exame (obrigatório e maior ou igual a zero).

Tarefas a Serem Executadas

[DDL] Criação de Tabelas: Escreva o script de criação de todas as 5 tabelas com suas devidas restrições (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT).

[DML] Carga de Dados: Insira no mínimo:

3 Especialidades

3 Médicos

3 Pacientes

4 Consultas

4 Exames associados às consultas

[DQL] Consultas SQL (Relatórios):

Q1: Listar todos os médicos ordenados pelo valor da consulta do mais caro para o mais barato, exibindo o nome do médico, CRM, especialidade e o valor.

Q2: Buscar todas as consultas do paciente "Carlos Silva", mostrando o ID da consulta, a data/hora, o nome do médico, a especialidade e o status.

Q3: Calcular o valor total gasto em cada consulta (Valor da Consulta + Soma dos Valores dos Exames), exibindo o ID da consulta, o nome do paciente, o nome do médico e o valor total calculado.

Q4: Listar os médicos que possuem valor de consulta superior a R$ 300,00.

Q5: Exibir o total faturado por especialidade médica considerando apenas as consultas com status 'Realizada'.

