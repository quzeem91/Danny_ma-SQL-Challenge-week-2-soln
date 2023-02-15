-- PIZZA METRIC

-- 1 How many pizzas were ordered?

SELECT COUNT(pizza_id) as "Total number of pizzas ordered" 
FROM   pizza_runner.customer_orders;
  
-- 2 How many unique customer orders were made?

SELECT COUNT(Distinct order_id) as " Number of unique orders" 
FROM   pizza_runner.customer_orders;

-- 3 How many successful orders were delivered by each runner?

SELECT runner_id,COUNT(order_id) "number of orders completed "
FROM pizza_runner.runner_orders
WHERE pickup_time !='null'
GROUP BY 1 
ORDER BY 1;
 
-- 4 How many of each type of pizza was delivered?

SELECT c.pizza_id,p.pizza_name,count(c.order_id) "number of times delivered "
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
ON r.order_id=c.order_id AND r.pickup_time != 'null'
JOIN pizza_runner.pizza_names p
ON p.pizza_id= c.pizza_id
GROUP BY 1,2
ORDER BY 1;


-- 5 How many Vegetarian and Meatlovers were ordered by each customer?

WITH meatveg as (
SELECT c.customer_id, CASE WHEN lower(p.pizza_name) ='meatlovers' THEN 1 
										ELSE 0 END AS meatlovers,
                                   CASE WHEN lower(p.pizza_name)='vegetarian' THEN 1 
                                   Else 0 END AS vegetarian      
FROM pizza_runner.customer_orders c
-- JOIN pizza_runner.runner_orders r
-- ON r.order_id=c.order_id AND r.pickup_time != 'null'

JOIN pizza_runner.pizza_names p
ON p.pizza_id= c.pizza_id
ORDER BY 1)

SELECT customer_id ,SUM(meatlovers) meatlovers ,SUM(vegetarian) vegetarian
FROM meatveg 
GROUP BY 1
ORDER BY 1;

-- 6 What was the maximum number of pizzas delivered in a single order?

WITH max_num_pizza as (
SELECT c.order_id ,COUNT(p.pizza_id) pizza_count
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
ON r.order_id=c.order_id AND r.pickup_time != 'null'
JOIN pizza_runner.pizza_names p
ON p.pizza_id= c.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1 )

SELECT  pizza_count "Max number of pizza per order "
FROM max_num_pizza ;

-- 7 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

WITH pizza_change as (
	SELECT c.customer_id,r.order_id,p.pizza_name ,
	       CASE WHEN c.extras ='' THEN '0'
		    WHEN c.extras IS NULL THEN '0' 
                    WHEN c.extras='null' THEN '0'
                    ELSE c.extras END as extras,
		CASE WHEN exclusions ='' THEN '0'
		     WHEN c.exclusions IS NULL THEN '0' 
                     WHEN c.exclusions='null' THEN '0'
                     ELSE c.exclusions END as exclusions
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
ON r.order_id=c.order_id AND r.pickup_time != 'null'
JOIN pizza_runner.pizza_names p
ON p.pizza_id= c.pizza_id
) ,

altered_pizza as (
	SELECT customer_id,order_id ,pizza_name , 
	       CASE WHEN exclusions != '0' or extras != '0' THEN 1 
		    ELSE 0 END AS altered_pizza,
	       CASE WHEN exclusions ='0' AND extras = '0'  THEN 1 
        	    ELSE 0 END AS unaltered_pizza
FROM pizza_change 
ORDER BY 1 )

SELECT customer_id,SUM(altered_pizza) pizza_with_at_least_a_change,SUM(unaltered_pizza) pizza_with_no_change
FROM altered_pizza 
GROUP BY 1
ORDER BY 1;

-- 8 How many pizzas were delivered that had both exclusions and extras?

WITH pizza_change as (SELECT c.customer_id,r.order_id,p.pizza_name ,CASE WHEN c.extras ='' THEN '0'
						  WHEN c.extras IS NULL THEN '0' 
                          WHEN c.extras='null' THEN '0'
                          ELSE c.extras END as extras,
CASE WHEN exclusions ='' THEN '0'
						  WHEN c.exclusions IS NULL THEN '0' 
                          WHEN c.exclusions='null' THEN '0'
                          ELSE c.exclusions END as exclusions
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
ON r.order_id=c.order_id AND r.pickup_time != 'null'
JOIN pizza_runner.pizza_names p
ON p.pizza_id= c.pizza_id
) ,

extra_and_exclusion as (SELECT customer_id,order_id ,pizza_name , CASE WHEN exclusions != '0' AND extras != '0' THEN 1 
			 ELSE 0	END AS extra_and_exclusion
FROM pizza_change 
ORDER BY 1 )

SELECT COUNT(*) number_of_pizza_with_exclusion_and_extra
FROM extra_and_exclusion 
WHERE extra_and_exclusion != 0;



-- 9 What was the total volume of pizzas ordered for each hour of the day?

SELECT DATE_PART('hour',order_time) hour_of_the_day, COUNT(order_id) volume_of_pizzas_ordered_by_hour
FROM pizza_runner.customer_orders
GROUP BY 1 
ORDER BY 2 DESC;


-- 10 What was the volume of orders for each day of the week?

SELECT to_char(order_time,'Day') weekday ,COUNT(order_id) volume_of_pizzas_ordered
FROM pizza_runner.customer_orders
GROUP BY 1 
ORDER BY 2 DESC;

-- B. Runner and Customer Experience

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH mins_taken_to_pickup as (
SELECT Distinct r.runner_id ,r.order_id,Date_part('minutes',(TO_TIMESTAMP(r.pickup_time, 'YYYY/MM/DD/HH24:MI:ss')- c.order_time)) time_diff
FROM pizza_runner.runner_orders r
JOIN  pizza_runner.customer_orders c
ON c.order_id=r.order_id
WHERE r.pickup_time!= Null or r.pickup_time != 'null'
ORDER BY 2)


SELECT runner_id , ROUND(AVG(time_diff)) "avg_time_of_getting_to_HQ(mins)"
FROM mins_taken_to_pickup
GROUP BY 1
ORDER BY 1;

-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH pizza_per_order as (SELECT c.order_id ,COUNT(p.pizza_id) pizza_count
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
ON r.order_id=c.order_id AND r.pickup_time != 'null'
JOIN pizza_runner.pizza_names p
ON p.pizza_id= c.pizza_id
GROUP BY 1 ) ,

mins_taken_to_pickup as (
SELECT Distinct r.runner_id ,r.order_id,Date_part('minutes',(TO_TIMESTAMP(r.pickup_time, 'YYYY/MM/DD/HH24:MI:ss')- c.order_time)) time_diff
FROM pizza_runner.runner_orders r
JOIN  pizza_runner.customer_orders c
ON c.order_id=r.order_id
WHERE r.pickup_time!= Null or r.pickup_time != 'null'
ORDER BY 2)

SELECT pp.order_id ,pp.pizza_count, ROUND(mp.time_diff) order_prep_time
FROM pizza_per_order pp
JOIN mins_taken_to_pickup mp
ON pp.order_id=mp.order_id ;

-- What was the average distance travelled for each customer?

WITH distance_travelled  AS (SELECT   Distinct c.customer_id ,r.order_id,
                             CASE  WHEN POSITION('k' IN distance) =0 THEN COALESCE(distance,'0') :: float
			 ELSE SUBSTRING(distance,1,position('k' IN distance)-1) :: float END AS distance_km
FROM pizza_runner.runner_orders r 
JOIN pizza_runner.customer_orders c
ON c.order_id=r.order_id
WHERE r.pickup_time!= Null or r.pickup_time != 'null')

SELECT customer_id ,ROUND(AVG(distance_km)) avg_distance_travelled_for_km
FROM distance_travelled 
GROUP By 1 
ORDER BY 1 ;

-- What was the difference between the longest and shortest delivery times for all orders?

WITH delivery_duration  AS (SELECT   Distinct c.customer_id ,r.order_id,LEFT(duration,2):: int duration_in_mins
FROM pizza_runner.runner_orders r 
JOIN pizza_runner.customer_orders c
ON c.order_id=r.order_id
WHERE r.pickup_time!= Null or r.pickup_time != 'null')

SELECT MAX(duration_in_mins)-MIN(duration_in_mins)  difference_between_the_longest_and_shortest_delivery_duration
FROM delivery_duration ;


-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH distance_time as (SELECT   Distinct  r.runner_id ,r.order_id,LEFT(duration,2):: float duration,LEFT(distance,2):: float distance 
FROM pizza_runner.runner_orders r 
JOIN pizza_runner.customer_orders c
ON c.order_id=r.order_id
WHERE r.pickup_time!= Null or r.pickup_time != 'null'
)
SELECT *, ROUND((distance*60/(duration))::numeric,1) "avg_speed_km/hr"
FROM distance_time
ORDER BY 1 ,2;

-- What is the successful delivery percentage for each runner?
WITH successful_delivery as (
SELECT order_id,runner_id ,CASE WHEN pickup_time=Null or pickup_time='null' THEN 0
								ELSE 1 END AS successful_delivery
FROM pizza_runner.runner_orders )

SELECT runner_id ,SUM(successful_delivery)*100/COUNT(successful_delivery) successful_delivery_percentage
FROM successful_delivery
GROUP BY 1
ORDER BY 1;

-- What are the standard ingredients for each pizza?

WITH meat_pizza as (SELECT topping_name ,row_number() over() as id 
FROM pizza_runner.pizza_toppings
WHERE topping_id  IN (1, 2, 3, 4, 5, 6, 8, 10)) ,

veg_pizza as (
SELECT topping_name,row_number() over() as id
FROM pizza_runner.pizza_toppings
WHERE topping_id IN  (4, 6, 7, 9, 11, 12))

SELECT mp.topping_name standard_meatlovers_ingredient,Coalesce(vp.topping_name,'') standard_vegetarian_ingredient
FROM meat_pizza mp 
FULL OUTER JOIN veg_pizza vp 
ON mp.id=vp.id ;


-- What was the most commonly added extra?
WITH cleaned_extra AS (SELECT c.customer_id,r.order_id,p.pizza_name ,
                        CASE WHEN c.extras ='' THEN '0'
			     WHEN c.extras IS NULL THEN '0' 
                             WHEN c.extras='null' THEN '0'
                             ELSE c.extras END as extras,
                        CASE WHEN exclusions ='' THEN '0'
						  WHEN c.exclusions IS NULL THEN '0' 
                          WHEN c.exclusions='null' THEN '0'
                          ELSE c.exclusions END as exclusions
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
ON r.order_id=c.order_id AND r.pickup_time != 'null'
JOIN pizza_runner.pizza_names p
ON p.pizza_id= c.pizza_id) , 

extra_split as (SELECT *,CASE  WHEN POSITION(',' IN extras) =0 THEN extras             
			 ELSE SUBSTRING(extras,1,position(',' IN extras)-1) END AS extra1,
             case  when POSITION(',' IN extras)= 0 then '-'
        else SUBSTRING(extras, POSITION(',' IN extras) + 1, LENGTH(extras)) END AS extra2
FROM cleaned_extra
WHERE extras != '0')

SELECT pt.topping_name most_added_extra ,extra extra_id , COUNT(extra) number_of_times_added 
FROM (SELECT extra1 extra
FROM extra_split

UNION ALL
SELECT extra2 extra
FROM extra_split) sub
JOIN pizza_runner.pizza_toppings pt
ON sub.extra=(pt.topping_id)::text

Where extra!='-'
GROUP BY 1,2
ORDER BY 3 DESC 
LIMIT 1;


-- What was the most common exclusion?
WITH cleaned_extra AS (SELECT c.customer_id,r.order_id,p.pizza_name ,CASE WHEN c.extras ='' THEN '0'
						  WHEN c.extras IS NULL THEN '0' 
                          WHEN c.extras='null' THEN '0'
                          ELSE c.extras END as extras,
CASE WHEN exclusions ='' THEN '0'
						  WHEN c.exclusions IS NULL THEN '0' 
                          WHEN c.exclusions='null' THEN '0'
                          ELSE c.exclusions END as exclusions
FROM pizza_runner.runner_orders r
JOIN pizza_runner.customer_orders c
ON r.order_id=c.order_id AND r.pickup_time != 'null'
JOIN pizza_runner.pizza_names p
ON p.pizza_id= c.pizza_id) , 

exclusion_split as (SELECT *,CASE  WHEN POSITION(',' IN exclusions) =0 THEN exclusions             
			 ELSE SUBSTRING(exclusions,1,position(',' IN exclusions)-1) END AS exclusion1,
             case  when POSITION(',' IN exclusions)= 0 then '-'
        else SUBSTRING(exclusions, POSITION(',' IN exclusions) + 1, LENGTH(exclusions)) END AS exclusion2
FROM cleaned_extra
WHERE exclusions != '0')

SELECT pt.topping_name most_common_exclusion ,exclusion exclusion_id , COUNT(exclusion) number_of_times_excluded
FROM (SELECT exclusion1 exclusion
FROM exclusion_split

UNION ALL
SELECT exclusion2 exclusion
FROM exclusion_split) sub
JOIN pizza_runner.pizza_toppings pt
ON sub.exclusion=(pt.topping_id)::text
Where exclusion!='-'
GROUP BY 1,2
ORDER BY 3 DESC 
LIMIT 1;

-- Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH cleaned_exclusion AS (
	SELECT c.customer_id,c.order_id,p.pizza_name ,
	       CASE WHEN exclusions ='' THEN '0'
		    WHEN c.exclusions IS NULL THEN '0' 
                    WHEN c.exclusions='null' THEN '0'
                    ELSE c.exclusions END as exclusions,
               CASE WHEN c.extras ='' THEN '0'
		    WHEN c.extras IS NULL THEN '0' 
                    WHEN c.extras='null' THEN '0'
                    ELSE c.extras END as extras
FROM pizza_runner.customer_orders c
JOIN pizza_runner.pizza_names p
ON p.pizza_id= c.pizza_id) , 

exclusion_split as (
	SELECT *,
	CASE  WHEN POSITION(',' IN extras) =0 THEN extras             
	      ELSE SUBSTRING(extras,1,position(',' IN extras)-1) END AS extra1,
        CASE  WHEN POSITION(',' IN extras)= 0 then '0'
              ELSE TRIM(SUBSTRING(extras, POSITION(',' IN extras) + 1, LENGTH(extras))) END AS extra2,
        CASE  WHEN POSITION(',' IN exclusions) =0 THEN exclusions             
	      ELSE SUBSTRING(exclusions,1,position(',' IN exclusions)-1) END AS exclusion1,
        CASE  WHEN POSITION(',' IN exclusions)= 0 then '0'
              ELSE TRIM(SUBSTRING(exclusions, POSITION(',' IN exclusions) + 1, LENGTH(exclusions))) END AS exclusion2
	FROM cleaned_exclusion
),


no_changes as (
  	SELECT e.Customer_id,e.order_id,e.extras,e.exclusions , e.pizza_name  as order_item
	FROM exclusion_split e
	WHERE extras='0' and exclusions='0'
), 
extra1 as (
  SELECT 
		e.Customer_id,e.order_id,e.extras,e.exclusions , 
        CONCAT(e.pizza_name,' extra - ',pt.topping_name ) as order_item
FROM exclusion_split e
LEFT JOIN pizza_runner.pizza_toppings pt 
ON (pt.topping_id)::text = e.extra1
WHERE extra1 !='0' and extra2 = '0' )
,
exclusion1 as (
SELECT 
		e.Customer_id,e.order_id,e.extras,e.exclusions , 
        CONCAT(e.pizza_name,' exclude - ',pt.topping_name ) as order_item
FROM exclusion_split e
LEFT JOIN pizza_runner.pizza_toppings pt 
ON (pt.topping_id)::text = e.exclusion1
WHERE exclusion1 !='0' and exclusion2 = '0'  and extras= '0' ),
extra1_of_2 as (
SELECT 
		e.Customer_id,e.order_id,e.pizza_name,e.extras,e.exclusions , 
        pt.topping_name as extra
FROM exclusion_split e
LEFT JOIN pizza_runner.pizza_toppings pt 
ON (pt.topping_id)::text = e.extra1
WHERE extra2 !='0' ),
extra2_of_2 as (SELECT 
		e.Customer_id,e.order_id,e.pizza_name,e.extras,e.exclusions , 
        pt.topping_name as extra
FROM exclusion_split e
LEFT JOIN pizza_runner.pizza_toppings pt 
ON (pt.topping_id)::text = e.extra2
WHERE extra2 !='0' ),
extras as (
SELECT e1.Customer_id,e1.order_id,e1.extras,e1.exclusions ,CONCAT(' Extra - ' ,e1.extra,' ,',e2.extra) order_item
FROM extra1_of_2 e1
JOIN extra2_of_2 e2
ON e1.extras=e2.extras),

exclusion1_of_2 as (
SELECT 
		e.Customer_id,e.order_id,e.pizza_name,e.extras,e.exclusions , 
        pt.topping_name as exclusion
FROM exclusion_split e
LEFT JOIN pizza_runner.pizza_toppings pt 
ON (pt.topping_id)::text = e.exclusion1
WHERE extra2 !='0' ),
exclusion2_of_2 as (
SELECT e.Customer_id,e.order_id,e.pizza_name,e.extras,e.exclusions , 
        pt.topping_name as exclusion
FROM exclusion_split e
LEFT JOIN pizza_runner.pizza_toppings pt 
ON (pt.topping_id)::text = e.exclusion2
WHERE exclusion2 !='0' ),
exclusion1_of_none as(
SELECT 
		e.Customer_id,e.order_id,e.pizza_name,e.extras,e.exclusions , 
        pt.topping_name as exclusion
FROM exclusion_split e
LEFT JOIN pizza_runner.pizza_toppings pt 
ON (pt.topping_id)::text = e.exclusion1
WHERE exclusions !='0' and extras!='0' and exclusion2='0' ),

exclusions as(
SELECT e1.Customer_id,e1.order_id,e1.extras,e1.exclusions ,CONCAT(e1.pizza_name,' Exclude - ' ,e1.exclusion,' ,',e2.exclusion) order_item
FROM exclusion1_of_2 e1
LEFT JOIN exclusion2_of_2 e2
ON e1.extras=e2.extras) 

SELECT * 
FROM no_changes

UNION ALL

SELECT * 
FROM extra1 

UNION ALL 

SELECT * 
FROM exclusion1

UNION ALL

SELECT et.Customer_id,et.Order_id,et.extras ,et.exclusions ,CONCAT (ec.order_item,' ',et.order_item) order_item 
FROM extras et
JOIN exclusions ec
ON et.extras=ec.extras 
ORDER BY 1,2;
