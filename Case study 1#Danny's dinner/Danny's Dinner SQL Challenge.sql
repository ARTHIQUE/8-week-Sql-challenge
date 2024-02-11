create database danny_dinner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');




  select * from menu;
  select * from sales;
  select * from members;


  --1 what is the total amount each customer spent at the restaurant?

  select customer_id,sum(price)as total_mount
  from sales
  join menu on sales.product_id=menu.product_id
  group by customer_id;

--2  How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date)as cnt
from sales
group by customer_Id

---- 3. What was the first item from the menu purchased by each customer?

select customer_id,product_name from
(select customer_id,product_name,row_number()over(partition by customer_id order by order_date asc ) as rn
from sales
join menu on sales.product_id=menu.product_id
) a
where rn=1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1 product_name,count(*) as cnt
from sales
join menu on sales.product_id=menu.product_id
group by product_name
order by count(*) desc;

-- 5. Which item was the most popular for each customer?

with cte as(
select distinct customer_id,product_name,
count(product_name)over(partition by  customer_id,product_name )as cnt
from sales
join menu on sales.product_id=menu.product_id
),
cte2 as(
select customer_id,product_name,cnt,rank()over(partition by customer_id order by cnt desc)as rnk
from cte)
select customer_id,product_name
from cte2
where rnk=1
--  6. Which item was purchased first by the customer after they became a member?
with cte as(
select members.customer_id,product_name,ROW_NUMBER()over(partition by members.customer_id order by order_date asc) as rn
from sales
join menu on sales.product_id=menu.product_id
join members on sales.customer_id=members.customer_id
where order_date>=join_date)
select customer_id,product_name
from cte 
where rn= 1

-- 7. Which item was purchased just before the customer became a member?

with cte as(
select members.customer_id,product_name,rank()over(partition by members.customer_id order by order_date desc) as rn
from sales
join menu on sales.product_id=menu.product_id
join members on sales.customer_id=members.customer_id
where order_date<join_date)
select customer_id,product_name
from cte 
where rn= 1;

-- 8. What is the total items and amount spent for each member before they became a member?

select distinct members.customer_id,
sum(price)over(partition by members.customer_id )as tot,
count(price)over(partition by members.customer_id )as cnt
from sales
join menu on sales.product_id=menu.product_id
join members on sales.customer_id=members.customer_id
where order_date<join_date;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


select customer_id,sum(case when product_name <>'sushi' then price*10
else price*20 end) as points
from sales
join menu on sales.product_id=menu.product_id
group by customer_id



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?

select sales.customer_id,
sum(case when order_date between join_date and DATEADD(DAY,6,join_date) then price*10*2
when menu.product_name='sushi' then price*10*2
else price*10 end)
as points
from sales
join menu on sales.product_id=menu.product_id
join members on sales.customer_id=members.customer_id
where month(order_date)=1
group by sales.customer_id





