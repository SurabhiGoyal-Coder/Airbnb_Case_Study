create database airbnb;
use airbnb;
select * from countries;
select * from sessions_data;
select * from users;
describe users;
describe sessions_data;

/* Problem statement
Find the count of iphone users from all users*/
select count(*) from users where first_device_type = 'iphone';    -- 252 are iphone users

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
Who spend more time 1) Mac users 2) Windows 3) Iphone user? */
select device_type, sum(secs_elapsed) as total_time from sessions_data where device_type in 
 ("Windows Desktop", "mac desktop", "iphone") group by 1 order by 2 desc;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
Identify the top 5 most active users who have spent more than 10,000 seconds on at least one session. 
'Most active' is defined as having the highest number of sessions. 
This will help you analyze user session data to find a potential correlation between session duration and user activity.*/
select user_id from (select user_id, count(*) as session_count, max(secs_elapsed) as high_value from sessions_data 
group by user_id having high_value > 10000 order by session_count desc) temp limit 5;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
Using the users data table, determine which country_destination appears most frequently.*/
select country_destination, count(*) as country_count from users where country_destination <> 'NDF' group by 1 order by 2 desc limit 1;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
determine the most frequently used signup method for each Gender category, considering only users who have made a booking (as indicated by a 
non-null value in the Date_first_booking column).
This exploration will help us understand if certain demographic factors are associated with specific signup preferences among users who follow through
with bookings.*/
select gender, signup_method, count(*) from users where Date_first_booking is not null and country_destination <> 'NDF'
 group by 1,2;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
Using the user data table, identify the most frequently used signup method among users categorized as female who have made a booking. */
select signup_method, count(*) from users where gender = 'Female' and  country_destination <> 'NDF'
group by 1 order by 2 desc limit 1;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
Determine the average age of users by destination country, considering only those with a booking and available age data. 
Sort the results from the youngest to the oldest users.
This will help you understand the destination country preferences for different age of users. */
select country_destination, avg(age) as average_age from users where age is not null and date_first_booking is not null and 
country_destination <> 'NDF' group by 1order by 2;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
Identify the anomalies in the age column, specifically the unusually large values. 
Determine the number of records where the age is greater than 100.*/
select count(*) from users where age > 100;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
We want to analyze how user sessions impact bookings. Write a query to find users with fewer than 5 sessions who made a booking to the destination "US". 
Sort the results by the number of sessions in descending order.*/
select s.user_id , count(s.user_id) as session_count from sessions_data s join users u on s.user_id = u.id 
 where u.country_destination = 'US' group by 1 having count(s.user_id) < 5 order by 2 desc;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
We want to analyze the activity of organic users, defined as those with "direct" listed as their affiliate provider. 
Specifically, we are interested in the total number of clicks made by these users. 
Please write a query to calculate the total clicks made by organic users.*/
select count(s.user_id) from sessions_data s join users u on s.user_id = u.id where s.action_type = 'click' 
 and u.affiliate_provider = 'direct';

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
Write a SQL query to identify the top 5 most common actions performed by users who made a booking (i.e., country_destination is not 'NDF') 
and the devices they use for these actions.
This information can help in optimizing the user experience and tailoring the interface to common user behaviors.*/
select s.action, s.device_type, count(s.action)  as action_count from sessions_data s join users u on u.id = s.user_id where u.country_destination <> 'NDF' 
and u.date_first_booking is not null group by 1,2 order by 3 desc limit 5;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
To understand user engagement better, calculate the average time of users who have made a booking spend on different actions. 
Check the results across action type and device type. This will help identify which actions and devices are associated with longer 
engagement times, potentially indicating more complex or interesting tasks.
Write a SQL query to determine the average time spent on actions by users who have made a booking (i.e., country_destination is not 'NDF'), 
cross action type and device type. Sort the results by average time spent in descending order. */

select s.action_type, s.device_type, avg(s.secs_elapsed) as average_time_spent from sessions_data s join users u 
on s.user_id = u.id where u.country_destination <> 'NDF' and u.date_first_booking is not null group by 
1,2 order by 3 desc;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
To further understand user behavior, identify the most frequent combinations of two actions performed by users who have made a booking, 
specifically on Windows Desktop devices. Determine which pairs of actions (performed sequentially) result in the most time spent. 
This insight can help optimize the user journey by focusing on significant action pairs on Windows Desktop.

Write a SQL query to find the most frequent combinations of two actions (performed by the same user on Windows Desktop devices) where the most time is spent, 
for users who have made a booking (i.e., country_destination is not 'NDF'). 
Consider the top 10 combinations from the resulting table which will be considered as most frequent.*/

select s1.action as first_action, s2.action as second_action , count(*) as action_pair_count , sum(s1.secs_elapsed + s2.secs_elapsed) as total_time_spent 
from sessions_data s1 join sessions_data s2 on s1.user_id = s2.user_id and s1.action <> s2.action join users u on s1.user_id = u.id 
where s1.device_type = "Windows desktop" and s2.device_type = "Windows desktop" and u.country_destination <> 'NDF' 
group by s1.action , s2.action order by 4 desc limit 10;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
To understand which affiliate channels are most effective, analyze the number of bookings made through each first affiliate channel and calculate 
their conversion rates. Write an SQL query to find the number of bookings and the conversion rate for each first affiliate channel. 
Consider a booking as made if country_destination is not 'NDF'.*/
SELECT first_affiliate_tracked AS affiliate_channel, COUNT(*) AS total_users, SUM(country_destination <> 'NDF') AS bookings, 
(SUM(country_destination <> 'NDF') / COUNT(*)) * 100 AS conversion_rate
FROM users GROUP BY first_affiliate_tracked ORDER BY conversion_rate DESC;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
To further understand the effectiveness of different affiliate providers and signup methods, determine the conversion rate for each combination.
Write a SQL query to calculate the conversion rate for each combination of affiliate provider and signup method. Consider a booking as made 
if country_destination is not 'NDF'. */
select affiliate_provider, signup_method, count(*) as total_users, sum(country_destination <> 'NDF') as bookings , 
(sum(country_destination <> 'NDF')/count(*))*100 as conversion_rate from users group by 1,2 order by 5 desc;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Problem statement
To understand which marketing channels are driving the most bookings, assess the effectiveness of different marketing channels by calculating 
the conversion rate for each channel.
Write a SQL query to assess the effectiveness of different marketing channels by calculating the conversion rate for each affiliate channel. 
Consider a booking as made if country_destination is not 'NDF'.*/
select affiliate_channel, count(*) as total_users, sum(country_destination <> 'NDF') as bookings , 
(sum(country_destination <> 'NDF')/count(*))*100 
as conversion_rate from users group by 1 order by 4 desc;    -- SEO is the affiliate channel which has the highest conversion rate.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
