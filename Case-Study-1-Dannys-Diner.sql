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

-- 6. Which item was purchased first by the customer after they became a member?

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
  INNER JOIN dannys_diner.members mb
      ON s.customer_id = mb.customer_id
      AND s.order_date >= mb.join_date
  ) a
WHERE rnk = 1;


-- 7. Which item was purchased just before the customer became a member?

SELECT
	customer_id,
    product_name
FROM
  (
  SELECT
      s.customer_id,
      m.product_name,
      ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date desc) AS rnk
  FROM dannys_diner.sales s
  INNER JOIN dannys_diner.menu m
      ON s.product_id = m.product_id
  INNER JOIN dannys_diner.members mb
      ON s.customer_id = mb.customer_id
      AND s.order_date < mb.join_date
  ) a
WHERE rnk = 1;


-- 8. What is the total items and amount spent for each member before they became a member?


  SELECT
      s.customer_id,
      count(m.product_name) as tot_items,
      sum(m.price) as amount_spent
  FROM dannys_diner.sales s
  INNER JOIN dannys_diner.menu m
      ON s.product_id = m.product_id
  INNER JOIN dannys_diner.members mb
      ON s.customer_id = mb.customer_id
      AND s.order_date < mb.join_date
  GROUP BY s.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
	s.customer_id,
	sum((case when m.product_name = 'sushi' then 20 else 10 end) * m.price) as tot_points
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
INNER JOIN dannys_diner.members mb
	ON s.customer_id = mb.customer_id
    AND s.order_date >= mb.join_date
GROUP BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT
	s.customer_id,
	sum(case when extract(week from s.order_date) = extract(week from mb.join_date) then 20 * m.price
   		else
       		(case when m.product_name = 'sushi' then 20 else 10 end) * m.price 
	   end) as tot_points_jan
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
INNER JOIN dannys_diner.members mb
	ON s.customer_id = mb.customer_id
    AND s.order_date >= mb.join_date
WHERE extract(month from s.order_date) = 1
GROUP BY s.customer_id;


--- 11. Join all the things

SELECT
    s.customer_id,
    cast(s.order_date as varchar(10)) as order_date,
    m.product_name,
    m.price,
    case when mb.customer_id is not null then 'Y' else 'N' end as member
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
LEFT JOIN dannys_diner.members mb
    ON s.customer_id = mb.customer_id;
    

--- 12. Rank all the things

SELECT
    s.customer_id,
    cast(s.order_date as varchar(10)) as order_date,
    m.product_name,
    m.price,
    case when mb.customer_id is not null then 'Y' else 'N' end as member,
    case when mb.customer_id is NULL then NULL
         else DENSE_RANK() OVER (PARTITION BY mb.customer_id ORDER BY s.order_date) 
    end AS ranking
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
    ON s.product_id = m.product_id
LEFT JOIN dannys_diner.members mb
    ON s.customer_id = mb.customer_id
    AND s.order_date >= mb.join_date
ORDER BY s.customer_id, order_date, m.product_name
