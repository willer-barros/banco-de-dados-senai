SELECT 
    c.nome,
    p.id AS pedido_id,
    p.valor
FROM clientes c
FULL JOIN pedidos p ON c.id = p.cliente_id;