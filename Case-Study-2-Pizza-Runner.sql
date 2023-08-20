-- 1. How many pizzas were ordered?

SELECT count(*) as num_pizzas_ordered
FROM pizza_runner.customer_orders;

-- 2. How many unique customer orders were made?

SELECT count(distinct order_id) as num_orders
FROM pizza_runner.customer_orders;

-- 3. How many successful orders were delivered by each runner?

SELECT count(distinct order_id) as num_orders_delivered
FROM pizza_runner.runner_orders
WHERE cancellation not like '%Cancellation%' or cancellation is null
