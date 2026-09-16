## Coalesce

Imagine que o COALESCE é um robozinho de "Plano B" para quando você está com fome.

Você chega da escola e diz para o robô: "Eu quero lanchar! Olha aí pra mim nessa ordem..."

- Bolo de chocolate 🍫

- Maçã 🍎

- Bolacha 🍪

O robô vai olhar a sua lista exatamente nessa ordem:

Ele abre a caixa de bolo: está vazia (NULL).

Ele olha a fruteira: tem uma maçã!

Pronto! O robô para de procurar na mesma hora e te entrega a maçã. Ele nem perde tempo olhando a bolacha, porque já encontrou a primeira opção que não estava vazia.

Como ele funciona no banco de dados:
O banco de dados usa o COALESCE exatamente para nunca ficar de mãos vazias. Ele varre uma lista de colunas da esquerda para a direita e pega a primeira informação de verdade que encontrar, ignorando o que estiver em branco:

```bash
COALESCE(apelido, nome, 'Visitante Anônimo')
```
Se o aluno não tiver um apelido cadastrado, o robô tenta usar o nome. Se por acaso o nome também estiver em branco, ele entrega a palavra 'Visitante Anônimo'. É o salvador oficial contra campos vazios!



