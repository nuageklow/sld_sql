

CREATE TABLE eventbrite_event AS
SELECT
  id AS event_id,
  u_event_id,
  name_text AS event_name,
  start_local::date AS event_date,
  REGEXP_REPLACE(SPLIT_PART(start_timezone,'/',2),'_',' ') AS event_city,
  SPLIT_PART(start_timezone,'/',1) AS event_region,
  CASE 
    WHEN lower(status) IN ('scheduled','started') THEN 'Scheduled'
    WHEN lower(status) IN ('completed','live','ended') THEN 'Completed'
    WHEN lower(status) IN ('canceled','cancelled') THEN 'Cancelled'
    ELSE status
    END AS event_status,
FROM 
  events
WHERE
  id NOT IN (SELECT id FROM exclusion_table):

CREATE TABLE eventbrite_registration AS
SELECT 
  event.u_event_id,
  id,
  profile_email,
  profile_first_name,
  profile_last_name,
  profile_addresses_home_city,
  profile_addresses_home_country,
  profile_gender,
  status,
  created,
  changed,
  event_id,
  
