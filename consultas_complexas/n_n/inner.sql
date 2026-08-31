SELECT 
    ped.id AS numero_pedido,
    ped.cliente_nome,
    prod.nome AS produto,
    item.quantidade,
    item.preco_unitario,
    (item.quantidade * item.preco_unitario) AS subtotal
FROM pedidos ped
INNER JOIN itens_pedido item ON ped.id = item.pedido_id
INNER JOIN produtos prod     ON prod.id = item.produto_id;

-- voce pode executar esse comando tambem

SELECT 
    ped.id AS numero_pedido,
    ped.cliente_nome,
    SUM(item.quantidade * item.preco_unitario) AS total_do_pedido
FROM pedidos ped
INNER JOIN itens_pedido item ON ped.id = item.pedido_id
GROUP BY ped.id, ped.cliente_nome
ORDER BY ped.id;