Contexto do Desafio

Você foi contratado pela rede de oficinas AutoFix Center. A empresa está expandindo suas unidades e precisa substituir o controle em papel e planilhas por um banco de dados relacional seguro e performático no PostgreSQL.

Sua missão é criar o esquema do banco de dados, aplicar regras de integridade (chaves primárias, estrangeiras, checagens e valores padrão), cadastrar os dados iniciais dos clientes, veículos, mecânicos e ordens de serviço (OS), além de gerar relatórios operacionais e financeiros para a gerência.

Requisitos do Modelo Relacional

O banco de dados deve conter 5 tabelas:

clientes:

id: Chave primária auto-incremento.

nome: Texto obrigatório.

email: Texto único e obrigatório.

telefone: Texto obrigatório.

cpf: Texto de 11 caracteres, único e obrigatório.

data_cadastro: Data com valor padrão da data/hora atual.

mecanicos:

id: Chave primária auto-incremento.

nome: Texto obrigatório.

especialidade: Texto obrigatório (ex: 'Motor', 'Suspensão', 'Injeção Eletrônica', 'Elétrica').

valor_hora: Valor numérico/decimal obrigatório (deve ser maior que zero).

veiculos:

id: Chave primária auto-incremento.

cliente_id: Chave estrangeira referenciando clientes(id).

placa: Texto de 7 caracteres, único e obrigatório.

modelo: Texto obrigatório.

marca: Texto obrigatório.

ano: Número inteiro obrigatório.

ordens_servico:

id: Chave primária auto-incremento.

veiculo_id: Chave estrangeira referenciando veiculos(id).

mecanico_id: Chave estrangeira referenciando mecanicos(id).

data_abertura: Data/hora obrigatória com valor padrão atual.

valor_mao_obra: Valor decimal obrigatório (mínimo zero).

status: Texto (valores permitidos: 'Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada'). Valor padrão: 'Em Aberto'.

pecas_os (Tabela associativa de peças e insumos utilizados na Ordem de Serviço):

id: Chave primária auto-incremento.

os_id: Chave estrangeira referenciando ordens_servico(id).

nome_peca: Texto obrigatório (ex: 'Filtro de Óleo', 'Pastilha de Freio', 'Amortecedor').

quantidade: Número inteiro obrigatório (maior que zero).

valor_unitario: Valor decimal unitário (obrigatório e maior que zero).

Tarefas a Serem Executadas

[DDL] Criação de Tabelas: Escreva o script de criação de todas as 5 tabelas com suas devidas restrições (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT).

[DML] Carga de Dados: Insira no mínimo:

3 Clientes

3 Mecânicos

3 Veículos (vinculados aos clientes)

4 Ordens de Serviço

4 Peças/Insumos associados às ordens de serviço

[DQL] Consultas SQL (Relatórios):

Q1: Listar todos os veículos ordenados por marca e modelo, exibindo o modelo, a marca, a placa, o nome do proprietário (cliente) e seu telefone.

Q2: Buscar todas as Ordens de Serviço do cliente "Fernanda Lima", mostrando o ID da OS, a placa do veículo, o modelo, a data de abertura, o nome do mecânico responsável e o status.

Q3: Calcular o valor total de cada Ordem de Serviço (Valor da Mão de Obra + Soma das Peças utilizandas), exibindo o ID da OS, a placa do veículo, o nome do mecânico, o valor da mão de obra e o valor total final calculado.

Q4: Listar os mecânicos que possuem valor por hora de trabalho superior a R$ 90,00.

Q5: Exibir o total faturado com mão de obra agrupado por especialidade médica/mecânica considerando apenas as Ordens de Serviço com status 'Concluida'.
