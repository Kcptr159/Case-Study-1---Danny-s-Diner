/*


select * from sales
select * from menu
select * from members 

All questions related to the case study

What is the total amount each customer spent at the restaurant?
How many days has each customer visited the restaurant?
What was the first item from the menu purchased by each customer?
What is the most purchased item on the menu and how many times was it purchased by all customers?
Which item was the most popular for each customer?
Which item was purchased first by the customer after they became a member?
Which item was purchased just before the customer became a member?
What is the total items and amount spent for each member before they became a member?
If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?*/

---#1: What is the total amount each customer spent at the restaurant?

SELECT  s.customer_id, 
        SUM(m.price) total_amount
FROM sales AS s
JOIN menu m
 ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_amount DESC


----#2: How many days has each customer visited the restaurant?

SELECT customer_id, 
       COUNT (DISTINCT (order_date)) as num_of_visits
FROM sales
GROUP BY customer_id
ORDER BY num_of_visits DESC

----#3: What was the first item from the menu purchased by each customer?

SELECT customer_id, 
       min (Product_name) as num_of_visits
FROM sales
left join menu
on sales.product_id=menu.product_id
GROUP BY customer_id
ORDER BY num_of_visits DESC


-----#4: What is the most purchased item on the menu, and how many times was it purchased by all customers?

SELECT TOP 1 menu.product_name, COUNT(menu.product_name) AS total_count
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY total_count DESC;

---#5: Which item was the most popular for each customer?
SELECT distinct sales.customer_id,menu.product_name, COUNT(menu.product_name) AS total_count
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id,menu.product_name
ORDER BY total_count DESC;


---#6: Which item was purchased first by the customer after they became a member?

with cte as (SELECT m.customer_id,MIN(s.order_date) AS first_purchase_date, menu.product_name AS first_purchased_item
FROM members  AS m
JOIN sales AS s ON m.customer_id = s.customer_id
JOIN menu ON s.product_id = menu.product_id
WHERE s.order_date >= m.join_date
GROUP BY m.customer_id,menu.product_name )


select * from (select customer_id,first_purchased_item,
row_number() over(partition by customer_id order by first_purchase_date) as rn 
from cte)k
where rn=1


--#7: Which item was purchased just before the customer became a member?


with cte as (SELECT m.customer_id,MIN(s.order_date) AS first_purchase_date, menu.product_name AS first_purchased_item
FROM members  AS m
JOIN sales AS s ON m.customer_id = s.customer_id
JOIN menu ON s.product_id = menu.product_id
WHERE s.order_date <= m.join_date
GROUP BY m.customer_id,menu.product_name )


select * from (select customer_id,first_purchased_item,
row_number() over(partition by customer_id order by first_purchase_date) as rn 
from cte)k
where rn=1



---#8: What are the total items and amounts spent by each member before they became members?

with cte as (SELECT m.customer_id,sum(menu.price) as amount,count( menu.product_name) as item
FROM members  AS m
JOIN sales AS s ON m.customer_id = s.customer_id
JOIN menu ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id )

select * from cte

--#9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

SELECT s.customer_id as customer,
       SUM(CASE WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price ELSE 10 * m.price END) AS total_point
FROM sales s 
JOIN menu m
 ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY total_point DESC

---#10: In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi
--— how many points do customer A and B have at the end of January?



WITH cte4 AS
(
 SELECT s.customer_id as customer, 
        m.product_name,
        m.price,
        mb.join_date,
        s.order_date
 FROM sales S
 JOIN menu m
  ON s.product_id = m.product_id
 JOIN members mb
  ON s.customer_id = mb.customer_id
)  
SELECT customer,
    SUM(CASE 
        WHEN order_date >= join_date AND order_date <= DATEADD(week, 1, join_date) THEN 2 * 10 * price
        WHEN order_date < join_date AND order_date > DATEADD(week, -1, join_date) AND product_name = 'sushi' THEN 2 * 10 * price
        ELSE 10 * price 
    END) as total_point
FROM cte4
WHERE order_date <= '2021-01-31'
GROUP BY customer
ORDER BY total_point DESC;
