CREATE TABLE customer(
user_id  TEXT PRIMARY KEY, 
first_name TEXT, 
last_name TEXT, 
email TEXT, 
age INTEGER, 
gender TEXT, 
country TEXT, 
state_province TEXT, 
city TEXT, 
created_at TEXT);

CREATE TABLE subscription(
user_id TEXT PRIMARY KEY,
subscription_plan TEXT, 
subscription_start_date TEXT,
is_active INTEGER, 
monthly_spend REAL, 
primary_device TEXT, 
household_size INTEGER,
FOREIGN KEY (user_id) REFERENCES customer(user_id));

INSERT INTO customer(
user_id, first_name, last_name, 
email, age, gender, country, 
state_province, city, created_at) 
SELECT user_id, first_name, last_name, 
email, age, gender, country, 
state_province, city, created_at 
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY rowid) AS rn
				FROM raw_subscribers)
WHERE rn = 1;

INSERT INTO subscription(
user_id, subscription_plan, subscription_start_date, is_active, monthly_spend, primary_device, household_size)
SELECT user_id, subscription_plan, subscription_start_date, 
CASE WHEN is_active = 'True' THEN 1 ELSE 0 END, 
monthly_spend, primary_device, household_size
FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY rowid) AS rn
				FROM raw_subscribers)
WHERE rn = 1;