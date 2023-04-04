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
    
    extra_and_exclusion as (
    SELECT customer_id, order_id, pizza_name, 
           CASE WHEN exclusions != '0' AND extras != '0' THEN 1 
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

**1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)**
 ```
 SELECT runner_id, 
	       CASE WHEN registration_date BETWEEN '2021-01-01' AND '2021-01-08' THEN '1'
             WHEN registration_date BETWEEN '2021-01-08' AND '2021-01-15' THEN '2'
             WHEN registration_date BETWEEN '2021-01-15' AND '2021-01-22' THEN '3'
 			    END AS "signup week", registration_date
FROM pizza_runner.runners 

 ```
 
| runner_id | signup week | registration_date        |
| --------- | ----------- | ------------------------ |
| 1         | 1           | 2021-01-01T00:00:00.000Z |
| 2         | 1           | 2021-01-03T00:00:00.000Z |
| 3         | 1           | 2021-01-08T00:00:00.000Z |
| 4         | 2           | 2021-01-15T00:00:00.000Z |

---

**2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?**

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
**3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**

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
**Answer:** Yes there is. Orders with more than 1 pizza have a longer prep time compared to order with just 1 pizza. <br>

**4. What was the average distance travelled for each customer?**

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
**5. What was the difference between the longest and shortest delivery times for all orders?**

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
**6. What was the average speed for each runner for each delivery and do you notice any trend for these values?**

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
**7. What is the successful delivery percentage for each runner?**

    WITH successful_delivery as (
    SELECT order_id,runner_id ,
           CASE WHEN pickup_time=Null or pickup_time='null' THEN 0
    	   ELSE 1 END AS successful_delivery
    FROM pizza_runner.runner_orders )
    
    SELECT runner_id, SUM(successful_delivery)*100/COUNT(successful_delivery) successful_delivery_percentage
    FROM successful_delivery
    GROUP BY 1
    ORDER BY 1;

| runner_id | successful_delivery_percentage |
| --------- | ------------------------------ |
| 1         | 100                            |
| 2         | 75                             |
| 3         | 50                             |

---



### C. Ingredient Optimisation
---

**1. What are the standard ingredients for each pizza?**

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

| standard_meatlovers_ingredient | standard_vegetarian_ingredient |
| ------------------------------ | ------------------------------ |
| Bacon                          | Cheese                         |
| BBQ Sauce                      | Mushrooms                      |
| Beef                           | Onions                         |
| Cheese                         | Peppers                        |
| Chicken                        | Tomatoes                       |
| Mushrooms                      | Tomato Sauce                   |
| Pepperoni                      |                                |
| Salami                         |                                |

---
**3. What was the most commonly added extra?**

    WITH cleaned_extra AS (
        SELECT c.customer_id,r.order_id,p.pizza_name ,
               CASE 
                    WHEN c.extras = '' THEN '0'
                    WHEN c.extras IS NULL THEN '0' 
                    WHEN c.extras = 'null' THEN '0'
                    ELSE c.extras 
               END AS extras    FROM pizza_runner.runner_orders r
        JOIN pizza_runner.customer_orders c
            ON r.order_id=c.order_id 
        JOIN pizza_runner.pizza_names p
            ON p.pizza_id= c.pizza_id
    ), 
    extra_split AS (
        SELECT SPLIT_PART(extras, ',', 1) AS extra1, SPLIT_PART(extras, ',', 2) AS extra2
        FROM cleaned_extra
        WHERE extras != '0'
    )
    SELECT pt.topping_name AS most_added_extra,
           extra AS extra_id,
           COUNT(extra) AS number_of_times_added 
    FROM (
        SELECT extra1 AS extra FROM extra_split WHERE extra1 != ''
        UNION ALL
        SELECT extra2 AS extra FROM extra_split WHERE extra2 != ''
    ) sub
    JOIN pizza_runner.pizza_toppings pt ON sub.extra::int = pt.topping_id
    GROUP BY 1,2
    ORDER BY 3 DESC 
    LIMIT 1;

| most_added_extra | extra_id | number_of_times_added |
| ---------------- | -------- | --------------------- |
| Bacon            | 1        | 4                     |

---
**3. What was the most common exclusion?**

    WITH cleaned_exclusions AS (
        SELECT c.customer_id, r.order_id, p.pizza_name,
               CASE 
                    WHEN c.exclusions = '' THEN '0'
                    WHEN c.exclusions IS NULL THEN '0' 
                    WHEN c.exclusions = 'null' THEN '0'
                    ELSE c.exclusions 
               END AS exclusions
        FROM pizza_runner.runner_orders r
        JOIN pizza_runner.customer_orders c 
        ON r.order_id = c.order_id 
        JOIN pizza_runner.pizza_names p 
        ON p.pizza_id = c.pizza_id
    ), 
    exclusion_split AS (
        SELECT SPLIT_PART(exclusions, ',', 1) AS exclusion1, SPLIT_PART(exclusions, ',', 2) AS exclusion2
        FROM cleaned_exclusions
        WHERE exclusions != '0'
    )
    SELECT pt.topping_name AS most_common_exclusion, 
           exclusion AS exclusion_id, 
           COUNT(exclusion) AS number_of_times_excluded
    FROM (
        SELECT exclusion1 AS exclusion FROM exclusion_split WHERE exclusion1 != ''
        UNION ALL
        SELECT exclusion2 AS exclusion FROM exclusion_split WHERE exclusion2 != ''
    ) sub
    JOIN pizza_runner.pizza_toppings pt 
    ON sub.exclusion::int = pt.topping_id
    GROUP BY 1, 2
    ORDER BY 3 DESC
    LIMIT 1;

| most_common_exclusion | exclusion_id | number_of_times_excluded |
| --------------------- | ------------ | ------------------------ |
| Cheese                | 4            | 4                        |

---

### D. Pricing and Ratings
---

**1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**


    WITH cost_per_order_with_no_charges_for_changes as ( 
    SELECT c.customer_id, r.order_id,c.pizza_id, CASE WHEN c.pizza_id = 1 THEN 12 ELSE 10 END AS "price"
    FROM pizza_runner.customer_orders c
    JOIN pizza_runner.runner_orders r
    ON c.order_id=r.order_id
    WHERE r.pickup_time !='null'
    ORDER BY 1,2
    )
    SELECT CONCAT('$',SUM(price)) "total_money_made"
    FROM cost_per_order_with_no_charges_for_changes;

| total_money_made |
| ---------------- |
| $138             |

---
**1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**


    WITH cost_per_order AS (
      SELECT
        c.customer_id,
        r.order_id,
        c.pizza_id,
        CASE 
          WHEN c.extras = '' THEN '0'
          WHEN c.extras IS NULL THEN '0' 
          WHEN c.extras = 'null' THEN '0'
          ELSE c.extras 
        END AS extras,
        CASE WHEN c.pizza_id = 1 THEN 12 ELSE 10 END AS price
      FROM pizza_runner.customer_orders c
      JOIN pizza_runner.runner_orders r
        ON c.order_id = r.order_id
      WHERE r.pickup_time!='null'
      ORDER BY 1, 2
    ),
    cost_of_order_with_charges_for_extra AS (
      SELECT
        *,
        CASE  
          WHEN extras != '0' AND LENGTH(TRIM(extras)) = 1 THEN price + 1
          WHEN extras != '0' AND LENGTH(TRIM(extras)) > 1 THEN price + 2
          ELSE price
        END AS new_price
      FROM cost_per_order
    )
    SELECT CONCAT('$',SUM(new_price)) AS total_amt_made_including_charges_for_extras
    FROM cost_of_order_with_charges_for_extra;

| total_amt_made_including_charges_for_extras |
| ------------------------------------------- |
| $142                                        |

---
**3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.**


    CREATE TABLE IF NOT EXISTS runner_ratings (
      order_id INTEGER,
      runner_id INTEGER,
      rating INTEGER
    );



    INSERT INTO runner_ratings (order_id, runner_id, rating)
    SELECT order_id, runner_id, FLOOR(1 + RANDOM() * 5) AS rating
    FROM pizza_runner.runner_orders
    WHERE pickup_time!= Null or pickup_time != 'null';


    SELECT * 
    FROM runner_ratings;

| order_id | runner_id | rating |
| -------- | --------- | ------ |
| 1        | 1         | 1      |
| 2        | 1         | 3      |
| 3        | 1         | 4      |
| 4        | 2         | 5      |
| 5        | 3         | 4      |
| 7        | 2         | 5      |
| 8        | 2         | 4      |
| 10       | 1         | 1      |

---
**4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas**

    WITH pizza_per_order_table AS (
    SELECT c.customer_id, c.order_id ,COUNT(p.pizza_id) pizza_count
    FROM pizza_runner.runner_orders r
    JOIN pizza_runner.customer_orders c
    ON r.order_id=c.order_id AND r.pickup_time != 'null'
    JOIN pizza_runner.pizza_names p
    ON p.pizza_id= c.pizza_id
    GROUP BY 1,2
    ORDER BY 1,2),
    
    average_speed_table AS (
    WITH distance_time as (SELECT   Distinct  r.runner_id ,r.order_id,LEFT(duration,2):: float duration,LEFT(distance,2):: float distance
    FROM pizza_runner.runner_orders r 
    JOIN pizza_runner.customer_orders c
    ON c.order_id=r.order_id
    WHERE r.pickup_time!= Null or r.pickup_time != 'null'
    )
    SELECT *, ROUND((distance*60/(duration))::numeric,1) "avg_speed"
    FROM distance_time
    ORDER BY 1,2
    )
    SELECT 
    	DISTINCT pt.customer_id, pt.order_id, sp.runner_id, rr.rating, c.order_time, r.pickup_time, 
    	ROUND(EXTRACT(EPOCH FROM age(to_timestamp(r.pickup_time, 'YYYY-MM-DD HH24:MI:SS'), c.order_time))/60) AS time_diff_minutes,
        sp.duration, sp.avg_speed, pt.pizza_count
    FROM pizza_per_order_table pt
    JOIN average_speed_table sp
    ON sp.order_id=pt.order_id
    JOIN  pizza_runner.runner_orders r
    ON sp.order_id=r.order_id
    JOIN pizza_runner.customer_orders c
    ON r.order_id=c.order_id 
    JOIN runner_ratings rr
    ON rr.runner_id=r.runner_id AND rr.order_id=r.order_id
    ORDER BY 2;

| customer_id | order_id | runner_id | rating | order_time               | pickup_time         | time_diff_minutes | duration | avg_speed | pizza_count |
| ----------- | -------- | --------- | ------ | ------------------------ | ------------------- | ----------------- | -------- | --------- | ----------- |
| 101         | 1        | 1         | 1      | 2020-01-01T18:05:02.000Z | 2020-01-01 18:15:34 | 11                | 32       | 37.5      | 1           |
| 101         | 2        | 1         | 3      | 2020-01-01T19:00:52.000Z | 2020-01-01 19:10:54 | 10                | 27       | 44.4      | 1           |
| 102         | 3        | 1         | 4      | 2020-01-02T23:51:23.000Z | 2020-01-03 00:12:37 | 21                | 20       | 39.0      | 2           |
| 103         | 4        | 2         | 5      | 2020-01-04T13:23:46.000Z | 2020-01-04 13:53:03 | 29                | 40       | 34.5      | 3           |
| 104         | 5        | 3         | 4      | 2020-01-08T21:00:29.000Z | 2020-01-08 21:10:57 | 10                | 15       | 40.0      | 1           |
| 105         | 7        | 2         | 5      | 2020-01-08T21:20:29.000Z | 2020-01-08 21:30:45 | 10                | 25       | 60.0      | 1           |
| 102         | 8        | 2         | 4      | 2020-01-09T23:54:33.000Z | 2020-01-10 00:15:02 | 20                | 15       | 92.0      | 1           |
| 104         | 10       | 1         | 1      | 2020-01-11T18:34:49.000Z | 2020-01-11 18:50:20 | 16                | 10       | 60.0      | 2           |

---
**5. IIf a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?**


    WITH cost_per_order_with_no_charges_for_changes AS (
    SELECT 
        c.order_id,
        CASE WHEN c.pizza_id = 1 THEN 12 ELSE 10 END AS price
    FROM pizza_runner.customer_orders c
    JOIN pizza_runner.runner_orders r
    ON c.order_id = r.order_id
    WHERE r.pickup_time != 'null'
    ORDER BY 1
    ),
    distance_per_order AS (
    SELECT r.order_id,
    ROUND(SUM(CASE
    WHEN POSITION('k' IN distance) = 0
    THEN COALESCE(distance, '0')::float
    ELSE SUBSTRING(distance, 1, POSITION('k' IN distance) - 1)::float
    END)) AS distance_km
    FROM pizza_runner.runner_orders r
    WHERE r.pickup_time != 'null'
    GROUP BY 1
    )
    SELECT CONCAT('$',SUM(c.price) - (SUM(d.distance_km) * 0.3)) AS money_left_over
    FROM cost_per_order_with_no_charges_for_changes c
    JOIN distance_per_order d
    ON c.order_id = d.order_id;

| money_left_over |
| --------------- |
| $74.1           |

---

