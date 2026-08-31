SELECT 
    ped.id AS pedido_id,
    ped.cliente_nome,
    prod.nome AS produto,
    item.quantidade
FROM pedidos ped
FULL JOIN itens_pedido item ON ped.id = item.pedido_id
FULL JOIN produtos prod     ON prod.id = item.produto_id;