select * from sales

insert into sales values   ('B', '2021-06-18', '1'),
  ('B', '2021-07-19', '1'),

select * from menu

select * from members

-- 1. What is the total amount each customer spent at the restaurant?

select
    s.customer_id, sum(m.price) as total_amount
from sales as s
inner join menu as m on s.product_id = m.product_id
group by s.customer_id

-- 2. How many days has each customer visited the restaurant?

    select
        customer_id, count(*) as total_days
        from
             (
             select distinct  customer_id, order_date from sales
             ) as t
    group by customer_id


    -- 3. What was the first item from the menu purchased by each customer?

        select
            distinct customer_id, product_name
            from
                 (
                 select
    s.customer_id,m.product_id, m.product_name, s.order_date,
                  dense_rank() over (partition by customer_id order by order_date , m.product_id) as rnk
from sales as s
inner join menu as m on s.product_id = m.product_id
                 ) as t
where rnk = 1



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select
    m.product_name, count(*)
from sales as s
        inner join menu as m on m.product_id = s.product_id
group by product_name
order by count(*) desc
limit 1

select
    s.customer_id,
    count(*) as purchased_item
        from
(
select
    product_id, count(*)
from sales
group by product_id
order by count(*) desc
limit 1
) as t
inner join sales as s on s.product_id = t.product_id
group by  s.customer_id


-- 5. Which item was the most popular for each customer?

select
   customer_id, product_name
    from
(
        select
            *,
            rank() over(partition by customer_id order by product_purchased desc ) as rnk
            from
        (
        select
        s.customer_id, m.product_name, count(*) as product_purchased
        from sales as s
        inner join menu as m on s.product_id = m.product_id
        group by  s.customer_id, m.product_name
        order by s.customer_id asc
        ) as t
        ) as t2
where t2.rnk = 1


-- 6. Which item was purchased first by the customer after they became a member?
select
    customer_id,
    product_name
    from
(
select s.customer_id,
        f.product_name,
        dense_rank() over (partition by s.customer_id order by s.order_date asc) as r
 from sales as s
          inner join members as m on s.customer_id = m.customer_id
          inner join menu as f on f.product_id = s.product_id
 where s.order_date > m.join_date
 ) as t
where r = 1


-- 7. Which item was purchased just before the customer became a member?


select
    customer_id,
    order_date,
    product_name
    from
(
select s.customer_id,
        f.product_name,
        s.order_date,
        dense_rank() over (partition by s.customer_id order by s.order_date desc) as r
 from sales as s
          inner join members as m on s.customer_id = m.customer_id
          inner join menu as f on f.product_id = s.product_id
 where s.order_date < m.join_date
 ) as t
where r = 1


-- 8. What is the total items and amount spent for each member before they became a member?

select
    s.customer_id, count(s.product_id), sum(f.price)
from sales as s
inner join members as m on s.customer_id = m.customer_id
inner join menu as f on f.product_id = s.product_id
where s.order_date < m.join_date
group by  s.customer_id


-- 9. If each 1 Taka spent equates to 10 points and kacchi has a 2x points multiplier - how many points would each customer have?

1 Taka -> 10 points
kacchi-> 1 Taka -> 20 points

select
    customer_id,
    sum(case
        when product_name = 'kacchi' then total_spent * 20 else total_spent * 10
    end)as total_points
    from
(
    select
        s.customer_id,
        m.product_name,
        sum(m.price) as total_spent
    from sales as s
    inner join menu as m on s.product_id = m.product_id
    group by     s.customer_id, m.product_name
) as t
group by customer_id


-- 10. In the 3 days after a customer joins the program( (including their join date)
    1. they earn 2x points on all items, not just Kacchi(Only for first 3 days)
    2. After 3 days - If each 1 Taka spent equates to 10 points and kacchi has a 2x points multiplier
    how many points do customer A and B have at the end of January, 2021?

    select
     customer_id,
    sum( case
         when days >=1 and days < 4 then price*20
         when days >= 4 and product_name = 'kacchi' then price * 20
         else price * 10
     end) as total_points
        from
 (
             select
    s.*,m.product_name,m.price, row_number() over (partition by s.customer_id order by s.order_date asc) as days
from sales as s
inner join menu as m on s.product_id = m.product_id
inner join members as b on b.customer_id = s.customer_id
where s.order_date >= b.join_date
and s.order_date like '2021-01%'
 ) as t
    group by customer_id