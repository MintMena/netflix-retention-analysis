/* We first perform analysis on Netflix userbase data
Data quality check
*/

SELECT COUNT(*) AS total, COUNT(monthly_spend) AS non_null_spend
FROM subscription;

/*
Revenue segtion
*/

/*
Churn rate by plan : how many customers gone inactive
*/

SELECT subscription_plan,
COUNT(*) AS total_customers,
SUM(CASE  WHEN is_active = 0 THEN 1 ELSE 0 END) AS churned,
ROUND(100.0 * SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END)  / COUNT(*), 1) AS churn_ratebyplan
FROM subscription
GROUP BY subscription_plan;

/*
Average spend and customer count by country (USA and Canada)
*/

SELECT c.country, COUNT(*) AS customer_count, 
AVG(s.monthly_spend) AS avg_spend
FROM customer c
JOIN subscription s ON c.user_id = s.user_id
GROUP BY c.country;

/*
Customer analysis section
*/

/*
Age distribution customer count by plan
*/

SELECT
	CASE
		WHEN age <25 THEN '18-24'
		WHEN age <40 THEN '25-39'
		WHEN age <60 THEN '40-59'
		ELSE '60+'
	END AS age_bracket, subscription_plan,
	COUNT(*) AS customer_count
FROM customer c
JOIN subscription s ON c.user_id = s.user_id
GROUP BY age_bracket, subscription_plan
ORDER BY age_bracket;

/*
Rank Top 10 user within each plan by monthly spend
*/

WITH ranking AS (SELECT *, 
									RANK() OVER (PARTITION BY subscription_plan 
									ORDER BY monthly_spend DESC) AS rank_by_plan
									FROM subscription)
SELECT *
FROM ranking
WHERE rank_by_plan <= 10;

/*
Customer spending  by plan vs. average spending
*/

WITH plan_avg AS (SELECT subscription_plan, AVG(monthly_spend) AS avg_spend
										FROM subscription
										GROUP BY subscription_plan)
SELECT s.user_id, s.subscription_plan, s.monthly_spend, p.avg_spend
FROM subscription s
JOIN plan_avg p ON s.subscription_plan = p.subscription_plan
ORDER BY s.subscription_plan, s.monthly_spend DESC;

/*
Customer spending metrics (above/below/near average) by subscription plan
*/

WITH plan_avg AS (SELECT subscription_plan, AVG(monthly_spend) AS avg_spend
										FROM subscription
										GROUP BY subscription_plan),
			vs_avg AS (SELECT s.subscription_plan, s.monthly_spend, p.avg_spend,
										CASE
											WHEN s.monthly_spend > p.avg_spend * 1.1 THEN 'above'
											WHEN s.monthly_spend < p.avg_spend * 0.9 THEN 'below'
											ELSE 'near_average'
										END AS spend_int
									FROM subscription s
									JOIN plan_avg p ON s.subscription_plan = p.subscription_plan)
SELECT subscription_plan, MAX(avg_spend) AS avg_spend, 
				SUM(CASE WHEN spend_int = 'above' THEN 1 ELSE 0 END) AS above_avg_count,
				SUM(CASE WHEN spend_int = 'below' THEN 1 ELSE 0 END) AS below_avg_count,
				SUM(CASE WHEN spend_int = 'near_average' THEN 1 ELSE 0 END) AS near_avg_count
FROM vs_avg
GROUP BY subscription_plan;

/*
Joining 2 users that share the same city and subscription plan
rank by subscription plan and city names
*/

SELECT a.user_id AS customer_a, b.user_id AS customer_b,
				a.city, suba.subscription_plan
FROM customer a
JOIN customer b ON a.city = b.city AND a.user_id < b.user_id
JOIN subscription suba ON a.user_id = suba.user_id
JOIN subscription subb ON b.user_id = subb.user_id
WHERE suba.subscription_plan = subb.subscription_plan
ORDER BY suba.subscription_plan, a.city;

