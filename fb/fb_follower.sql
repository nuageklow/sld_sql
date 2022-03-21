CREATE sm_facebook_follower_profile AS 
WITH 
f_gender AS (
	SELECT 
		id AS id,
		SPLIT_PART(name, '.', 1) AS gender,
		SPLIT_PART(name, '.', 2) AS age,
		
	FROM fb
	WHERE page = 'page_fans_gender_age'
), 
f_country AS (
	SELECT
		id AS id,
		name AS country,
		fan_count AS country_counts
	FROM fb
	WHERE page = 'page_fans_country'
),
