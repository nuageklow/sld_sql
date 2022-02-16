DROP TABLE IF EXISTS zoom.clean_registration;

CREATE TABLE zoom.clean_registration AS 
  SELECT 
    _id AS _id, 
    event_id AS event_id,
    email,
    approval_status AS status,
    INITCAP(first_name) AS first_name,
    INITCAP(last_name) AS last_name,
    CASE
        WHEN whats_your_age_bracket IN ('46 - 50', '51 & above') THEN '46+'
        WHEN whats_your_age_bracket = '' THEN 'Not disclosed'
        WHEN whats_your_age_bracket IS NULL THEN 'Not disclosed'
        ELSE whats_your_age_bracket
    END AS age_group,    
    gender,
    INITCAP(LOWER(city)) AS city,
    countryregion AS country_region,
    in_which_industry_do_you_work AS current_industry,
    what_is_your_job_level AS current_job_level,
    organization AS current_company,
    what_is_the_functional_role_of_your_latest_job_position AS latest_role,
    registration_time AS registration_timestamp
  FROM 
  zoom.registration_raw;


DROP TABLE IF EXISTS zoom.clean_attendance;

CREATE TABLE zoom.clean_attendance AS 
  SELECT 
  _id,
  event_id,
  email,
  INITCAP(LOWER(first_name)) AS first_name,
  INITCAP(LOWER(last_name)) AS last_name,
  join_time AS joined_timestamp,
  leave_time AS left_timestamp,
  time_in_session_minutes AS duration_second
  FROM 
  zoom.attendee_raw;


DROP TABLE IF EXISTS zoom.registration_raw;
DROP TABLE IF EXISTS zoom.attendee_raw;



