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

SELECT
    customer_id,
    product_name
FROM
  (
  SELECT
      s.customer_id, 
      m.product_name,
      ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk 
  FROM dannys_diner.sales s
  INNER JOIN dannys_diner.menu m
      ON s.product_id = m.product_id
  ) a
WHERE rnk = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
	m.product_name,
    count(s.order_date) as num_times_purchased
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
      ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY num_times_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

SELECT
	customer_id,
    product_name
FROM
  (
  SELECT
      customer_id,
      product_name,
      ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY num_times_purchased DESC) as rnk
  FROM
    (
    SELECT
        s.customer_id,
        m.product_name,
        count(*) as num_times_purchased
    FROM dannys_diner.sales s
    INNER JOIN dannys_diner.menu m
          ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
    ) A
  ) B
WHERE rnk = 1; 
