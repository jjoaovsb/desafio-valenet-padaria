/* DESAFIO ANALISTA DE DADOS - VALENET
   METRICAS DO PRIMEIRO TRIMESTRE - PADARIA PÃO & PÃO
*/

USE PaoEPao;

-- 1. Qual o total gasto por cada cliente da padaria?
SELECT cliente_nome, SUM(m.preco) AS total_gasto
FROM vendas v 
JOIN menu m ON v.produto_id = m.item_id
GROUP BY cliente_nome;

-- 2. Quantos dias cada cliente realizou ao menos um pedido na padaria?
SELECT cliente_nome, COUNT(DISTINCT CAST(data_venda AS DATE)) AS dias_com_pedido
FROM vendas 
GROUP BY cliente_nome;

-- 3. Qual foi o primeiro pedido de cada cliente da padaria?
SELECT cliente_nome, MIN(data_venda) AS data_primeiro_pedido
FROM vendas 
GROUP BY cliente_nome;

-- 4. Qual é o item mais pedido do cardápio? Quantas vezes esse item foi pedido?
SELECT TOP 1 m.produto, COUNT(*) AS total_pedidos
FROM vendas v 
JOIN menu m ON v.produto_id = m.item_id
GROUP BY m.produto 
ORDER BY total_pedidos DESC;

-- 5. Qual é o item mais pedido por cada cliente?
SELECT cliente_nome, produto, total
FROM (
    SELECT cliente_nome, m.produto, COUNT(*) AS total,
           RANK() OVER(PARTITION BY cliente_nome ORDER BY COUNT(*) DESC) AS rnk
    FROM vendas v 
    JOIN menu m ON v.produto_id = m.item_id
    GROUP BY cliente_nome, m.produto
) t WHERE rnk = 1;

-- 6. Qual foi o primeiro item que cada cliente pediu após se tornar um membro?
SELECT cliente_nome, produto, data_venda
FROM (
    SELECT v.cliente_nome, m.produto, v.data_venda,
           RANK() OVER(PARTITION BY v.cliente_nome ORDER BY v.data_venda ASC) AS rnk
    FROM vendas v 
    JOIN menu m ON v.produto_id = m.item_id
    JOIN clientes c ON v.cliente_nome = c.nome
    JOIN membros mb ON c.id = mb.cliente_id
    WHERE v.data_venda >= mb.dt_inicio_assinatura
) t WHERE rnk = 1;

-- 7. Qual foi o último item pedido por cada cliente logo antes de se tornar membro?
SELECT cliente_nome, produto, data_venda
FROM (
    SELECT v.cliente_nome, m.produto, v.data_venda,
           RANK() OVER(PARTITION BY v.cliente_nome ORDER BY v.data_venda DESC) AS rnk
    FROM vendas v 
    JOIN menu m ON v.produto_id = m.item_id
    JOIN clientes c ON v.cliente_nome = c.nome
    JOIN membros mb ON c.id = mb.cliente_id
    WHERE v.data_venda < mb.dt_inicio_assinatura
) t WHERE rnk = 1;

-- 8. Qual é o total de itens pedidos por cada cliente antes de se tornar membro?
SELECT v.cliente_nome, COUNT(*) AS total_itens
FROM vendas v 
JOIN clientes c ON v.cliente_nome = c.nome
JOIN membros mb ON c.id = mb.cliente_id
WHERE v.data_venda < mb.dt_inicio_assinatura
GROUP BY v.cliente_nome;

-- 9. Qual é o total gasto por cada cliente antes de se tornar membro?
SELECT v.cliente_nome, SUM(m.preco) AS total_gasto_pre_membro
FROM vendas v 
JOIN menu m ON v.produto_id = m.item_id
JOIN clientes c ON v.cliente_nome = c.nome
JOIN membros mb ON c.id = mb.cliente_id
WHERE v.data_venda < mb.dt_inicio_assinatura
GROUP BY v.cliente_nome;

-- 10. Dado que cada R$1,00 gasto vale 10 pontos e o "Pão de Queijo un." tem um multiplicador 2x, quantos pontos cada cliente teria?
SELECT v.cliente_nome,
       SUM(CASE 
             WHEN m.produto = 'Pão de Queijo un.' THEN (m.preco * 10 * 2)
             ELSE (m.preco * 10) 
           END) AS total_pontos
FROM vendas v 
JOIN menu m ON v.produto_id = m.item_id
GROUP BY v.cliente_nome;

-- 11. Bônus 7 dias Samuel e Daniel em Fevereiro (2x pontos em todos os itens)
SELECT v.cliente_nome,
       SUM(CASE 
             WHEN v.data_venda BETWEEN mb.dt_inicio_assinatura AND DATEADD(day, 7, mb.dt_inicio_assinatura)
             THEN (m.preco * 10 * 2) 
             ELSE (m.preco * 10) 
           END) AS pontos_fevereiro
FROM vendas v 
JOIN menu m ON v.produto_id = m.item_id
JOIN clientes c ON v.cliente_nome = c.nome
JOIN membros mb ON c.id = mb.cliente_id
WHERE v.cliente_nome IN ('Samuel', 'Daniel') 
  AND v.data_venda BETWEEN '2025-02-01' AND '2025-02-28'
GROUP BY v.cliente_nome;