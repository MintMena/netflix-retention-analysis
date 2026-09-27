CREATE TABLE customer_subscription AS 
SELECT c.*, s.subscription_plan, s.subscription_start_date, s.is_active, s.monthly_spend, s.primary_device, s.household_size
FROM customer c
JOIN subscription s ON c.user_id = s.user_id;