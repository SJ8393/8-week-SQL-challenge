-- 1. What is the total amount each customer spent at the restaurant?

SELECT
  	s.customer_id,
    SUM(m.price) AS total_amount
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_amount desc;

-- 2. How many days has each customer visited the restaurant?

SELECT
	s.customer_id,
    count(distinct s.order_date) as num_days_visited
FROM dannys_diner.sales s
GROUP BY s.customer_id
ORDER BY num_days_visited desc;

-- 3. What was the first item from the menu purchased by each customer?
