#LogEstu

1. Clientes
  id: Chave primária auto-incremento.
  nome: Texto obrigatório (NOT NULL).
  email: Texto único e obrigatório (UNIQUE NOT NULL).
  email: Texto único e obrigatório (UNIQUE NOT NULL).
  telefone: Texto obrigatório (NOT NULL).
  data_cadastro: Timestamp com valor padrão atual (DEFAULT NOW).

2. Motoristas
  id: Chave primária auto-incremento.
  nome: Texto obrigatório (NOT NULL).
  cnh: Texto único e obrigatório (UNIQUE NOT NULL).
  telefone: Texto obrigatório (NOT NULL).
  disponivel: Booleano com valor padrão TRUE.

3. Veículos
  id: Chave primária auto-incremento.
  motorista_id: Chave estrangeira referenciando motoristas(id).
  placa: Texto único de 7 caracteres (UNIQUE NOT NULL).
  capacidade_peso_kg: Decimal obrigatório maior que zero (CHECK > 0).
  ano: Inteiro maior ou igual a 2010 (CHECK >= 2010).

4. Regiões
  id: Chave primária auto-incremento.
  nome: Texto único e obrigatório (UNIQUE NOT NULL, ex: 'Sudeste', 'Sul').
  nome: Texto obrigatório (NOT NULL).
  prazo_dias: Inteiro obrigatório maior que zero (CHECK > 0).

5. Entregas
  id: Chave primária auto-incremento.
  cliente_id: Chave estrangeira referenciando clientes(id).
  motorista_id: Chave estrangeira referenciando motoristas(id) (Opcional).
  regiao_id: Chave estrangeira referenciando regioes(id).
  data_registro: Timestamp com valor padrão atual (DEFAULT NOW).
  status: Texto com verificação (CHECK: 'Pendente', 'Em Transito', 'Entregue', 'Cancelada'). Valor padrão: 'Pendente'.

6. Pacotes
  id: Chave primária auto-incremento.
  entrega_id: Chave estrangeira referenciando entregas(id).
  descricao: Texto obrigatório (NOT NULL).
  peso_kg: Decimal obrigatório maior que zero (CHECK > 0).
  valor_declarado: Decimal maior ou igual a zero (CHECK >= 0).

7. Histórico Rastreio
  id: Chave primária auto-incremento.
  entrega_id: Chave estrangeira referenciando entregas(id).
  status_atual: Texto obrigatório (NOT NULL).
  data_hora: Timestamp com valor padrão atual (DEFAULT NOW).
  observacao: Texto (TEXT).

#Tarefas de Funções (PL/pgSQL)
###F1 (Função Escalar - Cálculo de Frete)
Criar a função fn_calcular_frete(p_entrega_id INT) que retorna o valor total do frete.

Fórmula: $\text{Taxa Base da Região} + (\text{Soma do Peso dos Pacotes} \times 5.00) + (0.01 \times \text{Soma do Valor Declarado})$.

###F2 (Função Transacional com Validação de Carga)
Criar a função fn_atribuir_motorista_e_iniciar(p_entrega_id INT, p_motorista_id INT) para despachar uma entrega.

###Regras de Validação (Lançar RAISE EXCEPTION se):
O motorista estiver indisponível (disponivel = FALSE).
O status da entrega não for 'Pendente'.
A soma do peso dos pacotes exceder a capacidade_peso_kg do veículo do motorista.

##Ações (Se válido):
Atribuir o motorista à entrega.
Alterar status da entrega para 'Em Transito'.
Marcar o motorista como indisponível.
Inserir registro na tabela historico_rastreio.
F3 (Função Geradora de Tabela - Desempenho do Motorista)
Criar a função fn_relatorio_desempenho_motorista(p_motorista_id INT) que retorna uma tabela (RETURNS TABLE) com:

Nome do motorista.
Total de entregas concluídas (Status = 'Entregue').
Peso total acumulado transportado.
Faturamento total gerado (soma dos fretes calculados ou valores declarados, conforme regra de negócio adotada).
