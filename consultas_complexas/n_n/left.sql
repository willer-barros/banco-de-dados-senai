SELECT 
    prod.nome AS produto,
    prod.preco_base
FROM produtos prod
LEFT JOIN itens_pedido item ON prod.id = item.produto_id
WHERE item.produto_id IS NULL;

-- voce pode executar esse outro comando tambem

SELECT 
    prod.nome AS produto,
    COALESCE(SUM(item.quantidade), 0) AS quantidade_vendida,
    COALESCE(SUM(item.quantidade * item.preco_unitario), 0) AS faturamento_total
FROM produtos prod
LEFT JOIN itens_pedido item ON prod.id = item.produto_id
GROUP BY prod.id, prod.nome
ORDER BY faturamento_total DESC;

-- Dica de Ouro (COALESCE): Ensine aos alunos que a função COALESCE(valor, 0) substitui valores NULL (como o do produto não vendido) por 0, deixando o relatório muito mais limpo para apresentação.