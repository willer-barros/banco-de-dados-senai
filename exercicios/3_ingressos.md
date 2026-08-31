#Requisitos do Modelo Relacional (7 Tabelas)
1. Clientes
id: Chave primária auto-incremento.
nome: Texto obrigatório (NOT NULL).
email: Texto único e obrigatório (UNIQUE NOT NULL).
cpf: Texto de 11 caracteres, único e obrigatório (UNIQUE NOT NULL).

2. Locais
id: Chave primária auto-incremento.
nome: Texto obrigatório (NOT NULL).
cidade: Texto obrigatório (NOT NULL).
capacidade_maxima: Inteiro obrigatório maior que zero (CHECK > 0).

3. Categorias Evento
id: Chave primária auto-incremento.
nome: Texto único e obrigatório (UNIQUE NOT NULL, ex: 'Show', 'Teatro', 'Stand-up').

4. Eventos
id: Chave primária auto-incremento.
categoria_id: Chave estrangeira referenciando categorias_evento(id).
local_id: Chave estrangeira referenciando locais(id).
titulo: Texto obrigatório (NOT NULL).
preco_base: Decimal obrigatório maior que zero (CHECK > 0).
ativo: Booleano com valor padrão TRUE.

5. Cupons
id: Chave primária auto-incremento.
codigo: Texto único e obrigatório (UNIQUE NOT NULL).
percentual_desconto: Inteiro entre 1 e 90 (CHECK BETWEEN 1 AND 90).
ativo: Booleano com valor padrão TRUE.

6. Compras
id: Chave primária auto-incremento.
cliente_id: Chave estrangeira referenciando clientes(id).
cupom_id: Chave estrangeira referenciando cupons(id) (Opcional).
data_compra: Timestamp com valor padrão atual (DEFAULT NOW).
status: Texto com verificação de valores (CHECK: 'Confirmada', 'Cancelada').

7. Ingressos
id: Chave primária auto-incremento.
compra_id: Chave estrangeira referenciando compras(id).
evento_id: Chave estrangeira referenciando eventos(id).
tipo_ingresso: Texto com verificação (CHECK: 'Inteira', 'Meia').
valor_pago: Decimal maior ou igual a zero (CHECK >= 0).
Tarefas de Funções (PL/pgSQL)
F1 (Função Escalar - Regra de Preço)
Criar a função fn_calcular_preco_ingresso(p_evento_id INT, p_tipo_ingresso VARCHAR, p_codigo_cupom VARCHAR) que retorna o valor final do ingresso.

###Regras:
Se for 'Meia', aplica 50% de desconto sobre o preco_base.
Se houver cupom válido, aplica o percentual extra sobre o resultado.
F2 (Função Transacional - Inserção com Validação)
Criar a função fn_emitir_ingresso(p_cliente_id INT, p_evento_id INT, p_tipo_ingresso VARCHAR, p_codigo_cupom VARCHAR) que executa a venda.

###Regras:
Lança exceção (RAISE EXCEPTION) se o evento estiver inativo.
Lança exceção se o local já atingiu a capacidade máxima de ingressos vendidos.
Registra a compra, gera o ingresso usando a F1 e retorna o ID do novo ingresso.
F3 (Função Geradora de Tabela - Relatório)
Criar a função fn_relatorio_faturamento_evento(p_evento_id INT) que retorna uma tabela (RETURNS TABLE) contendo:

Título do evento.
Total de ingressos vendidos.
Faturamento bruto obtido.
