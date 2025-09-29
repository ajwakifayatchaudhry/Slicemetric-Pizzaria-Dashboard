create table pizzas(
pizza_id Varchar(50) primary key,
pizza_type_id varchar(50),
size varchar(20),
price numeric(10,2)
);

select * from pizzas;

create table orders(
orderid int primary key,
date date,
time time
);
select * from orders;

create table order_details(
order_details_id int primary key,
order_id int,
pizza_id varchar(50),
quantity int
);

select * from order_details;

create table pizza_types(
pizza_type_id varchar(50),
name varchar(100),
category varchar(50),
ingredients varchar(500)
);

select * from pizza_types;

-- Retrieve the total number of orders placed.
select count(orderid) from orders;

-- Calculate the total revenue generated from pizza sales.
select round(SUM(quantity*price),2) as total_revenue 
from order_details o
left join pizzas p
on o.pizza_id=p.pizza_id;

-- Identify the highest-priced pizza.
select name
from pizzas p
left join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
order by price desc
limit 1;

-- Identify the most common pizza size ordered.
select size,count(order_id)
from order_details o
join pizzas p
on o.pizza_id=p.pizza_id
group by size
order by count(order_id) desc 
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.
select name,sum(quantity)
from pizza_types pt
join pizzas p
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by name
order by sum(quantity) desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select category,sum(quantity)
from pizza_types pt
join pizzas p
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by category
order by sum(quantity) desc;

-- Determine the distribution of orders by hour of the day.
select count(orders) as total_orders,extract (hours from time) as hours
from orders
group by hours
order by hours desc;

select extract (hours from time) as hours, count(orderid)
from orders
group by hours
order by hours;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(*)
from pizza_types
group by category

-- Group the orders by date and calculate the average number of pizzas ordered per day.
with pizzas_per_day as (select sum(quantity) as total_pizzas,date
from orders o
join order_details od
on o.orderid=od.order_id
group by date
order by  date)
select round(avg(total_pizzas),0) as average_pizzas_ordered_per_day
from pizzas_per_day;

-- Determine the top 3 most ordered pizza types based on revenue.
select name,sum(quantity *price) as revenue
from order_details od
join pizzas p 
on od.pizza_id=p.pizza_id
join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by name
order by revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select pt.category,round((sum(quantity *price)/(select sum(quantity*price) 
from order_details od
join pizzas p
on od.pizza_id=p.pizza_id)) * 100,0) as percentage
from order_details od
join pizzas p 
on od.pizza_id=p.pizza_id
join pizza_types pt
on p.pizza_type_id=pt.pizza_type_id
group by category;

-- Analyze the cumulative revenue generated over time.
select date,
sum(sum(quantity*price)) over(order by date ) as cummulative_revenue 
from orders o
join order_details od
on o.orderid=od.order_id
join pizzas p
on od.pizza_id=p.pizza_id
group by date
order by date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name,category ,sum(quantity *price) as revenue
from pizza_types pt
join pizzas p
on pt.pizza_type_id=p.pizza_type_id
join order_details od
on p.pizza_id=od.pizza_id
group by category,name
order by revenue desc
limit 3;
