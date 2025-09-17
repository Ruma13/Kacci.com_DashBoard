-- 1.How many pizzas were ordered?

select count(*) from customer_orders

-- 2.How many unique customer orders were made?

select count(distinct customer_id) from customer_orders

-- 3.How many successful orders were delivered by each runner?

select count(*)
from customer_orders as c
inner join  runner_orders as r on c.order_id = r.order_id
where r.cancellation is  null

-- 4.How many of each type of pizza was delivered?

select p.pizza_name, count(*)
from customer_orders as c
inner join pizza_names as p on c.pizza_id = p.pizza_id
inner join  runner_orders as r on c.order_id = r.order_id
where r.cancellation is  null
group by p.pizza_name

-- 5.How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id,p.pizza_name, count(*)
from customer_orders as c
inner join pizza_names as p on c.pizza_id = p.pizza_id
group by c.customer_id,p.pizza_name


-- 6.What was the maximum number of pizzas delivered in a single order?

select substring(order_time,1,10), count(*)
    from customer_orders
group by substring(order_time,1,10)
order by count(*) desc
limit 1


-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select
    customer_id,
    count(case when exclusions is not null or  extras is not null then 1 end) as one_change,
    count(case when exclusions is null and extras is null then 1 end) as no_change
    from customer_orders as c
    inner join  runner_orders as r on c.order_id = r.order_id
   where r.cancellation is  null
group by customer_id


-- 8.How many pizzas were delivered that had both exclusions and extras?

select
  count(c.customer_id)
    from customer_orders as c
    inner join  runner_orders as r on c.order_id = r.order_id
   where r.cancellation is  null
and exclusions is not null and   extras is not null

-- 9.What was the total volume of pizzas ordered for each hour of the day?

select
    substring(order_time,1,10), hour(order_time), count(*)
from customer_orders
group by substring(order_time,1,10), hour(order_time)


-- 10.What was the volume of orders for each day of the week?

select
    weeks,
    week_days,
    count(*)
    from
(
select
    *,
    dense_rank() over (partition by  weeks order by days) as week_days
    from
(
select
    *,
    dense_rank() over (order by order_time) as days,
    ceiling(dense_rank() over (order by order_time) / 3) as weeks
from customer_orders
    ) as t
        ) as t2
group by 1, 2