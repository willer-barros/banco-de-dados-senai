SELECT 
    prod.nome AS produto,
    item.pedido_id,
    item.quantidade,
    item.preco_unitario
FROM itens_pedido item
RIGHT JOIN produtos prod ON item.produto_id = prod.id;