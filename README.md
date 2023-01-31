# Danny_ma-SQL-Challenge-week-2-soln

![temp](https://8weeksqlchallenge.com/images/case-study-designs/2.png)

## Introduction
Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…) <br>

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!” <br>

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched! <br>

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers. <br>

## Available Data
Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth. <br>

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations. <br>

All datasets exist within the pizza_runner database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions. <br>

## Entity Relation Diagram 

![ERD](ERD1.jpg)
 <br> 
## Case Study Questions
This case study has LOTS of questions - they are broken up by area of focus including:

### A. Pizza Metrics
**1. How many pizzas were ordered?** 


    SELECT COUNT(pizza_id) as "Total number of pizzas ordered" 
    FROM   pizza_runner.customer_orders;

| Total number of pizzas ordered |
| ------------------------------ |
| 14                             |

---
**2. How many unique customer orders were made?**

    SELECT COUNT(Distinct order_id) as " Number of unique orders" 
    FROM   pizza_runner.customer_orders;

|  Number of unique orders |
| ------------------------ |
| 10                       |

---
**3. How many successful orders were delivered by each runner?**

    SELECT runner_id,COUNT(order_id) "number of orders completed "
    FROM pizza_runner.runner_orders
    WHERE pickup_time !='null'
    GROUP BY 1 
    ORDER BY 1;

| runner_id | number of orders completed  |
| --------- | --------------------------- |
| 1         | 4                           |
| 2         | 3                           |
| 3         | 1                           |

---
**4. How many of each type of pizza was delivered?**

    SELECT c.pizza_id,p.pizza_name,count(c.order_id) "number of times delivered "
    FROM pizza_runner.runner_orders r
    JOIN pizza_runner.customer_orders c
    ON r.order_id=c.order_id AND r.pickup_time != 'null'
    JOIN pizza_runner.pizza_names p
    ON p.pizza_id= c.pizza_id
    GROUP BY 1,2
    ORDER BY 1;

| pizza_id | pizza_name | number of times delivered  |
| -------- | ---------- | -------------------------- |
| 1        | Meatlovers | 9                          |
| 2        | Vegetarian | 3                          |

---
**5. How many Vegetarian and Meatlovers were ordered by each customer?**

    WITH meatveg as (
    SELECT c.customer_id, CASE WHEN lower(p.pizza_name) ='meatlovers' THEN 1 
    										ELSE 0 END AS meatlovers,
                                       CASE WHEN lower(p.pizza_name)='vegetarian' THEN 1 
                                       Else 0 END AS vegetarian      
    FROM pizza_runner.customer_orders c
    
    
    
    JOIN pizza_runner.pizza_names p
    ON p.pizza_id= c.pizza_id
    ORDER BY 1)
    
    SELECT customer_id ,SUM(meatlovers) meatlovers ,SUM(vegetarian) vegetarian
    FROM meatveg 
    GROUP BY 1
    ORDER BY 1;

| customer_id | meatlovers | vegetarian |
| ----------- | ---------- | ---------- |
| 101         | 2          | 1          |
| 102         | 2          | 1          |
| 103         | 3          | 1          |
| 104         | 3          | 0          |
| 105         | 0          | 1          |

---
**6. What was the maximum number of pizzas delivered in a single order?**

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

| Max number of pizza per order  |
| ------------------------------ |
| 3                              |

---
**7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**

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
    
    altered_pizza as (SELECT customer_id,order_id ,pizza_name , CASE WHEN exclusions != '0' or extras != '0' THEN 1 
    			 ELSE 0	END AS altered_pizza,
    		CASE WHEN exclusions ='0' AND extras = '0'  THEN 1 
            ELSE 0 END AS unaltered_pizza
    FROM pizza_change 
    ORDER BY 1 )
    
    SELECT customer_id,SUM(altered_pizza) pizza_with_at_least_a_change,SUM(unaltered_pizza) pizza_with_no_change
    FROM altered_pizza 
    GROUP BY 1
    ORDER BY 1;

| customer_id | pizza_with_at_least_a_change | pizza_with_no_change |
| ----------- | ---------------------------- | -------------------- |
| 101         | 0                            | 2                    |
| 102         | 0                            | 3                    |
| 103         | 3                            | 0                    |
| 104         | 2                            | 1                    |
| 105         | 1                            | 0                    |

---
**8. How many pizzas were delivered that had both exclusions and extras?**

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

| number_of_pizza_with_exclusion_and_extra |
| ---------------------------------------- |
| 1                                        |

---
**9. What was the total volume of pizzas ordered for each hour of the day?**

    SELECT DATE_PART('hour',order_time) hour_of_the_day, COUNT(order_id) volume_of_pizzas_ordered_by_hour
    FROM pizza_runner.customer_orders
    GROUP BY 1 
    ORDER BY 2 DESC;

| hour_of_the_day | volume_of_pizzas_ordered_by_hour |
| --------------- | -------------------------------- |
| 18              | 3                                |
| 23              | 3                                |
| 21              | 3                                |
| 13              | 3                                |
| 11              | 1                                |
| 19              | 1                                |

---
**10. What was the volume of orders for each day of the week?**

    SELECT to_char(order_time,'Day') weekday ,COUNT(order_id) volume_of_pizzas_ordered
    FROM pizza_runner.customer_orders
    GROUP BY 1 
    ORDER BY 2 DESC;

| weekday   | volume_of_pizzas_ordered |
| --------- | ------------------------ |
| Saturday  | 5                        |
| Wednesday | 5                        |
| Thursday  | 3                        |
| Friday    | 1                        |

---

### B. Runner and Customer Experience

How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

**What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**

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

| runner_id | avg_time_of_getting_to_HQ(mins) |
| --------- | ------------------------------- |
| 1         | 14                              |
| 2         | 20                              |
| 3         | 10                              |

---
**Is there any relationship between the number of pizzas and how long the order takes to prepare?**

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

| order_id | pizza_count | order_prep_time |
| -------- | ----------- | --------------- |
| 1        | 1           | 10              |
| 2        | 1           | 10              |
| 3        | 2           | 21              |
| 4        | 3           | 29              |
| 5        | 1           | 10              |
| 7        | 1           | 10              |
| 8        | 1           | 20              |
| 10       | 2           | 15              |

---
**What was the average distance travelled for each customer?**

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

| customer_id | avg_distance_travelled_for_km |
| ----------- | ----------------------------- |
| 101         | 20                            |
| 102         | 18                            |
| 103         | 23                            |
| 104         | 10                            |
| 105         | 25                            |

---
**What was the difference between the longest and shortest delivery times for all orders?**

    WITH delivery_duration  AS (SELECT  Distinct c.customer_id ,r.order_id,LEFT(duration,2):: int duration_in_mins
    FROM pizza_runner.runner_orders r 
    JOIN pizza_runner.customer_orders c
    ON c.order_id=r.order_id
    WHERE r.pickup_time!= Null or r.pickup_time != 'null')
    
    SELECT MAX(duration_in_mins)-MIN(duration_in_mins)  difference_between_the_longest_and_shortest_delivery_duration
    FROM delivery_duration ;

| difference_between_the_longest_and_shortest_delivery_duration |
| ------------------------------------------------------------- |
| 30                                                            |

---
**What was the average speed for each runner for each delivery and do you notice any trend for these values?**

    WITH distance_time as (SELECT   Distinct  r.runner_id ,r.order_id,LEFT(duration,2):: float duration,LEFT(distance,2):: float distance 
    FROM pizza_runner.runner_orders r 
    JOIN pizza_runner.customer_orders c
    ON c.order_id=r.order_id
    WHERE r.pickup_time!= Null or r.pickup_time != 'null'
    )
    SELECT *, ROUND((distance*60/(duration))::numeric,1) "avg_speed_km/hr"
    FROM distance_time
    ORDER BY 1 ,2;

| runner_id | order_id | duration | distance | avg_speed_km/hr |
| --------- | -------- | -------- | -------- | --------------- |
| 1         | 1        | 32       | 20       | 37.5            |
| 1         | 2        | 27       | 20       | 44.4            |
| 1         | 3        | 20       | 13       | 39.0            |
| 1         | 10       | 10       | 10       | 60.0            |
| 2         | 4        | 40       | 23       | 34.5            |
| 2         | 7        | 25       | 25       | 60.0            |
| 2         | 8        | 15       | 23       | 92.0            |
| 3         | 5        | 15       | 10       | 40.0            |

---
**What is the successful delivery percentage for each runner?**

    WITH successful_delivery as (
    SELECT order_id,runner_id ,CASE WHEN pickup_time=Null or pickup_time='null' THEN 0
    								ELSE 1 END AS successful_delivery
    FROM pizza_runner.runner_orders )
    
    SELECT runner_id ,SUM(successful_delivery)*100/COUNT(successful_delivery) successful_delivery_percentage
    FROM successful_delivery
    GROUP BY 1
    ORDER BY 1;

| runner_id | successful_delivery_percentage |
| --------- | ------------------------------ |
| 1         | 100                            |
| 2         | 75                             |
| 3         | 50                             |

---
