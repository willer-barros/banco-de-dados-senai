## DECLARE

1. Declarar variáveis (PL/pgSQL)
Dentro de funções, procedimentos ou blocos DO, DECLARE introduz a seção de declarações, onde se definem variáveis locais, constantes e cursores:
```bash
CREATE FUNCTION exemplo() RETURNS void AS $$
DECLARE
    contador   INTEGER := 0;
    nome       TEXT DEFAULT 'anonimo';
    taxa       CONSTANT NUMERIC := 0.10;
    user_rec   RECORD;
BEGIN
    -- uso das variáveis
END;
$$ LANGUAGE plpgsql;
```

### Sintaxe geral:

```bash
DECLARE nome [CONSTANT] tipo [NOT NULL] [{ DEFAULT | := } valor];
```

Sem valor inicial → a variável é NULL.
CONSTANT impede reatribuição.
Escopo é por bloco (uma variável declarada em um BEGIN...END interno é local a esse bloco). 
2. Definir um cursor (SQL)
Fora de PL/pgSQL, DECLARE cria um cursor — um ponteiro para o resultado de uma query, permitindo buscar linhas uma a uma com FETCH:

```bash
BEGIN;
DECLARE meu_cursor CURSOR FOR SELECT * FROM filmes;
FETCH NEXT FROM meu_cursor;
FETCH 5 FROM meu_cursor;
CLOSE meu_cursor;
COMMIT;
```

Sintaxe completa:

DECLARE nome [BINARY] [ASENSITIVE | INSENSITIVE] [[NO] SCROLL]
        CURSOR [{WITH | WITHOUT} HOLD] FOR query;

Opção	Efeito
WITH HOLD	Cursor sobrevive ao COMMIT da transação
WITHOUT HOLD (padrão)	Cursor é encerrado no COMMIT
SCROLL	Permite navegar para trás (FETCH PRIOR)
BINARY	Retorna dados em formato binário

Resumindo: DECLARE serve para declarar variáveis locais em código procedural ou criar cursores em SQL, permitindo iterar sobre resultados linha a linha. 
