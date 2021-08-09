CREATE SCHEMA IF NOT EXISTS test;

/* exclusion_table */
CREATE TABLE test.exclusion_table AS
WITH zoom_combine AS (
  SELECT * FROM webinar_event
  UNION ALL
  SELECT * FROM meeting_event
)
SELECT DISTINCT zoom_combine.id
FROM zoom_combine
LEFT JOIN webinar_participants zwp ON zoom_combine.id = zwp.webinar_id
WHERE (topic LIKE '[Webinar]%' AND date(start_time) < date('2021-04-01'))
  OR topic LIKE 'Meiro'
  OR zwp.user_id NOT IN ('134220800', '33570816', '33574912', '83888128', '134224896', '16787456');

  /* event mapping */
CREATE TABLE test.zoom_event_mapping AS
  WITH mapping_combine AS (
    SELECT * FROM webinar_event_mapping
    UNION
    SELECT * FROM meeting_event_mapping
  )
  SELECT * FROM mapping_combine;

/* zoom webinar event */
CREATE TABLE test.zoom_webinar_event AS
SELECT
  md5(concat(regexp_replace(lower(event.id), '[^\w]+ ','','g'),regexp_replace(cast(start_time as varchar(10)) , '[^\w]+','','g'))) as u_event_id,
  uuid,
  id AS event_id,
  topic AS event_name,
  SPLIT_PART(timezone, '/', 2) AS event_city,
  SPLIT_PART(timezone, '/', 1) AS event_country_region,
  SPLIT_PART(timezone, '/', 2) AS organising_chapter,
  CASE
    WHEN DATE(start_time) < current_date THEN 'Completed'
    WHEN DATE(start_time) > current_date THEN 'Scheduled'
    ELSE 'Cancelled'
  END AS event_status,
  start_time::timestamp,
  duration::INTEGER AS duration_minutes
FROM
  webinar_event event
WHERE id NOT IN (SELECT id FROM test.exclusion_table);


/* zoom webinar registration */
CREATE TABLE test.zoom_webinar_registration AS
SELECT
  zwe.u_event_id,
  registrants.webinar_id AS event_id,
  registrants.id,
  participants.user_id AS attendance_user_id,
  email,
  CASE
    WHEN participants.user_email IS NOT NULL THEN 'registered_attended'
    WHEN registrants.status = 'pending' THEN 'cancelled_registration'
    WHEN zwe.start_time < now() THEN 'registered_not_attended'
    WHEN zwe.start_time >= now() THEN 'registered_for_future_event'
    ELSE 'missing_status'
  END AS status,
  INITCAP(first_name) AS first_name,
  INITCAP(last_name) AS last_name,
  INITCAP(LOWER(city)) AS city,
  country AS country_region,
  CASE
    WHEN age IN ('46 - 50', '51 & above') THEN '46+'
    WHEN age = '' THEN 'Not disclosed'
    WHEN age IS NULL THEN 'Not disclosed'
    ELSE age
  END AS age_group,
  CASE
      WHEN lower(gender) ~~ '%female%'::text THEN 'Female'::text
      WHEN lower(gender) ~~ '%male%'::text THEN 'Male'::text
      ELSE 'Not disclosed'::text
  END AS gender,
  industry AS current_industry,
  job_level AS current_job_level,
  org AS current_company,
  latest_job_position AS latest_role,
  event_referral AS event_referred_source,
  create_time AS registration_timestamp
FROM webinar_registrants registrants
  LEFT JOIN test.zoom_webinar_event zwe ON registrants.webinar_id = zwe.event_id
  INNER JOIN webinar_participants participants ON registrants.id = participants.id
WHERE registrants.webinar_id = zwe.event_id
  AND registrants.id = participants.id
  AND zwe.event_id NOT IN (SELECT id FROM test.exclusion_table);

/* webinar panelist */
CREATE TABLE test.zoom_webinar_panelist AS
SELECT
  id,
  u_event_id,
  email,
  name AS panelist_full_name,
  webinar_id AS event_id
FROM
  webinar_panelist panelist
LEFT JOIN test.zoom_webinar_event events ON panelist.webinar_id = events.event_id;

/* meeting event */
CREATE TABLE test.zoom_meeting_event AS
SELECT
  md5(concat(regexp_replace(lower(event.id), '[^\w]+ ','','g'),regexp_replace(cast(start_time as varchar(10)) , '[^\w]+','','g'))) as u_event_id,
  uuid,
  id AS event_id,
  topic AS event_name,
  SPLIT_PART(timezone,'/',2) AS event_city,
  SPLIT_PART(timezone,'/',1) AS event_country,
  SPLIT_PART(timezone,'/',2) AS organizing_chapter,
  CASE
    WHEN (DATE(start_time)) < current_date THEN 'Cancelled'
    WHEN (DATE(start_time)) > current_date THEN 'Scheduled'
    ELSE 'Completed'
  END AS event_status,
  start_time::TIMESTAMP,
  duration::INTEGER AS duration_minutes
FROM
  meeting_event event
WHERE id NOT IN (SELECT id FROM test.exclusion_table);


/* zoom meeting registration */
CREATE TABLE test.zoom_meeting_registration AS
SELECT
  zme.u_event_id,
  registrants.meeting_id AS event_id,
  registrants.id,
  participants.user_id AS  attendance_user_id,
  email,
  CASE
    WHEN participants.user_email IS NOT NULL THEN 'registered_attended'
    WHEN registrants.status = 'pending' THEN 'cancelled_registration'
    WHEN zme.start_time < now() THEN 'registered_not_attended'
    WHEN zme.start_time >= now() THEN 'registered_for_future_event'
    ELSE 'missing_status'
  END AS status,
  INITCAP(first_name) AS first_name,
  INITCAP(last_name) AS last_name,
  INITCAP(LOWER(city)) AS city,
  country AS country_region,
  CASE
    WHEN age IN ('46 - 50', '51 & above') THEN '46+'
    WHEN age = '' THEN 'Not disclosed'
    WHEN age IS NULL THEN 'Not disclosed'
    ELSE age
  END AS age_group,
  CASE
      WHEN lower(gender) ~~ '%female%'::text THEN 'Female'::text
      WHEN lower(gender) ~~ '%male%'::text THEN 'Male'::text
      ELSE 'Not disclosed'::text
  END AS gender,
  industry AS current_industry,
  job_level AS current_job_level,
  company AS current_company,
  latest_job_position AS latest_role,
  event_referral AS event_referred_source,
  create_time AS registration_timestamp
FROM meeting_registrants registrants
  LEFT JOIN test.zoom_meeting_event zme ON registrants.meeting_id = zme.event_id
  INNER JOIN meeting_participants participants ON registrants.id = participants.id
WHERE registrants.meeting_id = zme.event_id
  AND registrants.id = participants.id
  AND zme.event_id NOT IN (SELECT id FROM test.exclusion_table);
