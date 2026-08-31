Requisitos do Modelo Relacional: Sistema de Gestão Hoteleira
O banco de dados de um sistema de gestão hoteleira (pousada) deve conter 5 tabelas:

1. Hóspedes
id: Chave primária auto-incremento.
nome: Texto obrigatório.
email: Texto único e obrigatório.
cpf: Texto de 11 caracteres, único e obrigatório.
telefone: Texto obrigatório.
data_cadastro: Data/hora com valor padrão da data/hora atual.
2. Categorias Quarto
id: Chave primária auto-incremento.
nome: Texto único e obrigatório (ex: 'Suíte Luxo', 'Chalé', 'Quarto Standard').
valor_diaria_base: Valor numérico/decimal obrigatório (deve ser maior que zero).
3. Quartos
id: Chave primária auto-incremento.
categoria_id: Chave estrangeira referenciando categorias_quarto(id).
numero: Texto único e obrigatório (ex: '101', '102').
andar: Inteiro obrigatório (deve ser maior ou igual a 0).
disponivel: Booleano com valor padrão TRUE.
4. Reservas
id: Chave primária auto-incremento.
hospede_id: Chave estrangeira referenciando hospedes(id).
data_checkin: Data/hora com valor padrão da data/hora atual.
status: Texto (valores permitidos: 'Confirmada', 'Finalizada', 'Cancelada'). Valor padrão: 'Confirmada'.
5. Itens Reserva
id: Chave primária auto-incremento.
reserva_id: Chave estrangeira referenciando reservas(id).
quarto_id: Chave estrangeira referenciando quartos(id).
dias_hospedagem: Valor inteiro obrigatório (deve ser maior que zero).
valor_diaria_aplicado: Valor decimal praticado no contrato (obrigatório e maior que zero).
taxa_limpeza: Valor decimal de taxa fixa (deve ser maior ou igual a zero, padrão 0.00).
Tarefas a Serem Executadas
[DDL] Criação de Tabelas
Escreva o script de criação de todas as 5 tabelas com suas devidas restrições (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT).

[DML] Carga de Dados
Insira no mínimo:

3 Categorias de Quarto
3 Quartos
3 Hóspedes
4 Reservas
4 Itens associados às reservas
[DQL / Views] Visões e Consultas Avançadas
Q1 (View com Expressão Matemática)
Criar a View vw_quartos_custo_estimado exibindo:

Número do quarto
Andar
Nome da categoria
Valor total da diária ajustado com a taxa de turismo (+10% sobre a diária base)
Ordenado da diária mais alta para a mais baixa.
Q2 (View com Filtro de Múltiplos Joins)
Criar a View vw_reservas_ativas listando:

Nome do hóspede
Telefone
Número do quarto
Nome da categoria
Dias de hospedagem
Data de check-in
Filtro: Apenas reservas com status 'Confirmada'.
Q3 (View com Agrupamento e HAVING)
Criar a View vw_hospedes_vip calculando o valor total gasto em reservas 'Finalizada' (Soma de $(\text{valor_diaria_aplicado} \times \text{dias_hospedagem}) + \text{taxa_limpeza}$).

Exibir: Nome do hóspede, total de reservas finalizadas e o valor total gasto.
Filtro (HAVING): Apenas hóspedes com gasto superior a R$ 1.200,00.
Q4 (Consulta com Condições Compostas)
Listar os quartos que atendam simultaneamente a:

Localizados no andar 1 ou superior.
Pertencentes às categorias 'Suíte Luxo' ou 'Chalé'.
Valor de diária base superior a R$ 200,00.
Marcados como disponíveis.
Q5 (View com Média e Agrupamento por Categoria)
Criar a View vw_faturamento_medio_categoria exibindo:

Nome da categoria do quarto
Faturamento total bruto arrecadado
Média do valor diário aplicado
Filtro: Reservas com status 'Finalizada'.

