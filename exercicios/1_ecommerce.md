🛒 Atividade Prática 01: Criação e Consulta de Banco de Dados para E-commerce

Unidade Curricular: Banco de Dados (60h)

Tópicos Cobertos: DDL (CREATE TABLE, Constraints), DML (INSERT), DQL (SELECT, WHERE, JOIN, GROUP BY, ORDER BY)

SGBD: PostgreSQL

Formato: Individual ou em Duplas

📌 PARTE 1: ENUNCIADO PARA OS ALUNOS

Contexto do Desafio

Você foi contratado pela startup ByteStore, uma loja virtual especializada em periféricos e eletrônicos. A empresa está expandindo e precisa abandonar as planilhas manuais para adotar um banco de dados relacional robusto em PostgreSQL.

Sua missão é criar o esquema do banco de dados, aplicar regras de integridade, cadastrar os dados iniciais do catálogo/vendas e gerar relatórios estratégicos para a gerência.

Requisitos do Modelo Relacional

O banco de dados deve conter 5 tabelas:

clientes:

id: Chave primária auto-incremento.

nome: Texto obrigatório.

email: Texto único e obrigatório.

cpf: Texto de 11 caracteres, único e obrigatório.

data_cadastro: Data com valor padrão da data/hora atual.

categorias:

id: Chave primária auto-incremento.

nome: Texto único e obrigatório (ex: 'Periféricos', 'Monitores', 'Hardware').

produtos:

id: Chave primária auto-incremento.

categoria_id: Chave estrangeira referenciando categorias(id).

nome: Texto obrigatório.

preco: Valor numérico/decimal obrigatório (deve ser maior que zero).

quantidade_estoque: Número inteiro obrigatório (mínimo zero).

pedidos:

id: Chave primária auto-incremento.

cliente_id: Chave estrangeira referenciando clientes(id).

data_pedido: Data/hora com padrão atual.

status: Texto (valores permitidos: 'Pendente', 'Pago', 'Enviado', 'Cancelado'). Valor padrão: 'Pendente'.

itens_pedido (Tabela associativa N:N entre Pedidos e Produtos):

pedido_id: Chave estrangeira referenciando pedidos(id).

produto_id: Chave estrangeira referenciando produtos(id).

quantidade: Número inteiro obrigatório (maior que zero).

preco_unitario: Valor decimal do produto no momento da compra (obrigatório e maior que zero).

Chave Primária Composta: (pedido_id, produto_id).

Tarefas a Serem Executadas

[DDL] Criação de Tabelas: Escreva o script de criação de todas as 5 tabelas com suas devidas restrições (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT).

[DML] Carga de Dados: Insira no mínimo:

3 Categorias

5 Produtos

3 Clientes

3 Pedidos (com pelo menos 2 itens por pedido)

[DQL] Consultas SQL (Relatórios):

Q1: Listar todos os produtos ordenados pelo preço do mais caro para o mais barato, exibindo também o nome da categoria.

Q2: Buscar todos os pedidos realizados pelo cliente "Paulo Antunes", mostrando o ID do pedido, a data e o status.

Q3: Calcular o valor total de cada pedido (Quantidade × Preço Unitário), exibindo o ID do pedido, o nome do cliente e o total calculado.

Q4: Listar os produtos que possuem estoque abaixo de 10 unidades.

Q5: Exibir o total faturado por categoria de produto no sistema.
