## BEGIN
- Iniciar uma transação (SQL)
Em nível SQL, BEGIN abre um bloco de transação: todas as instruções seguintes são executadas como uma única unidade atômica até um COMMIT ou ROLLBACK. 

BEGIN;
UPDATE contas SET saldo = saldo - 100 WHERE nome = 'Alice';
UPDATE contas SET saldo = saldo + 100 WHERE nome = 'Bob';
COMMIT;

Sem BEGIN, cada instrução roda em autocommit (transação implícita por comando). 
