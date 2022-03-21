CREATE TABLE sm_facebook_post_insight AS 
WITH
  p_clicks AS (
  SELECT
    parent_id AS parent_id,
    name AS metric,
    value AS counts
  FROM post_insights
  WHERE name = 'post_clicks_unique'
),
p_engaged_users AS (
  SELECT
    parent_id AS parent_id,
   name AS metric,
   value AS counts
  FROM post_insights
  WHERE name = 'post_engaged_users'
),
p_reaction_likes AS (
  SELECT
    parent_id AS parent_id,
   name AS metric,
   value AS counts
  FROM post_insights
  WHERE name = 'post_reactions_like_total'
),
p_impressions AS (
  SELECT
    parent_id AS parent_id,
   name AS metric,
   value AS counts
  FROM post_insights
  WHERE name = 'post_impressions_unique'
),
p_engaged_fan AS (
	SELECT 
		parent_id AS parent_id,
		name AS metric,
		value AS counts
	FROM post_insights
	WHERE name = 'post_engaged_fan'
)
SELECT
distinct(SPLIT_PART(id, '_', 2)) AS id,
created_time::timestamp,
-- replace(message,'\n',' ') as message,
p_clicks.counts AS num_clicks,
p_engaged_users.counts AS num_engaged_users,
p_reaction_likes.counts AS num_reaction_likes,
p_impressions.counts AS num_impressions,
p_engaged_fan.counts AS num_engaged_fans
FROM post_info
LEFT JOIN p_engaged_users ON post_info.id = p_engaged_users.parent_id
LEFT JOIN p_engaged_fan ON post_info.id = p_engaged_fan.parent_id
LEFT JOIN p_reaction_likes ON post_info.id = p_reaction_likes.parent_id
LEFT JOIN p_clicks ON post_info.id = p_clicks.parent_id
LEFT JOIN p_impressions ON post_info.id = p_impressions.parent_id;

