/* zoom_webinar_registration */

/* exclusion_table */
CREATE TABLE exclusion_table AS
WITH zoom_combine AS (
  SELECT * FROM webinar_event
  UNION ALL
  SELECT * FROM meeting_event
)
SELECT DISTINCT zoom_combine.id
FROM zoom_combine
LEFT JOIN webinar_participants zwp ON zoom_combine.id = zwp.webinar_id
WHERE (topic LIKE '[Webinar]%' AND date(start_time) < date('2021-04-01'))
  OR topic LIKE 'Meiro';

  /* event mapping */
CREATE TABLE zoom_event_mapping AS
  WITH mapping_combine AS (
    SELECT * FROM webinar_event_mapping
    UNION
    SELECT * FROM meeting_event_mapping
  )
  SELECT * FROM mapping_combine;

/* zoom webinar event */
CREATE TABLE zoom_webinar_event AS
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
  webinar_event event;
-- WHERE id NOT IN (SELECT id FROM exclusion_table);

/* zoom_webinar_registration */
CREATE TABLE zoom_webinar_registration_v2 AS 
SELECT
    md5(concat(
    regexp_replace(lower(registrants.webinar_id), '[^\w]+ ','','g'),
    regexp_replace(lower(email) , '[^\w]+','','g'),
    regexp_replace(lower(registrants.id) , '[^\w]+','','g'),
    regexp_replace(cast(date(create_time) as varchar(10)) , '[^\w]+','','g')
    )) as id_sequence,  
    zwe.u_event_id,
    webinar_id AS event_id,
    registrants.id AS registrant_id,
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
    INITCAP(LOWER(city)) AS city,
    country AS country_region,
    event_referral AS event_referred_source,
    industry AS current_industry,
    latest_job_position AS latest_role,
    job_level AS current_job_level,
    org AS current_company,
    create_time::TIMESTAMP AS registration_timestamp
FROM zoom_webinar_registrants AS registrants
LEFT JOIN zoom_webinar_event zwe ON registrants.webinar_id = zwe.event_id
    AND zwe.event_id NOT IN (SELECT id FROM exclusion_table);

/*  */
CREATE TABLE zoom_webinar_attendance AS 
SELECT
    md5(concat(
    regexp_replace(lower(webinar_id), '[^\w]+ ','','g'),
    regexp_replace(lower(user_email) , '[^\w]+','','g'),
    regexp_replace(lower(id) , '[^\w]+','','g'),
    regexp_replace(cast(date(join_time) as varchar(10)) , '[^\w]+','','g')
    )) as id_sequence,
    zwe.u_event_id,
    participants.id,
    participants.user_id,
    participants.user_email AS email,
    INITCAP(LOWER(SPLIT_PART(participants.name, ' ', 1))) AS first_name,
    INITCAP(LOWER(SPLIT_PART(participants.name, ' ', 2))) AS last_name,
    participants.webinar_id AS event_id,
    participants.join_time::TIMESTAMP AS joined_timestamp,
    participants.leave_time::TIMESTAMP AS left_timestamp,
    participants.duration::BIGINT AS duration_second,
    events.start_time::TIMESTAMP
FROM
    zoom_webinar_participants participants
LEFT JOIN zoom_webinar_event zwe ON participants.webinar_id = zwe.event_id
    AND zwe.event_id NOT IN (SELECT id FROM exclusion_table);

/* webinar panelist */
CREATE TABLE zoom_webinar_panelist AS
SELECT
  id,
  u_event_id,
  email,
  name AS panelist_full_name,
  webinar_id AS event_id
FROM
  webinar_panelist panelist
LEFT JOIN zoom_webinar_event events ON panelist.webinar_id = events.event_id;


/* meeting event */
CREATE TABLE zoom_meeting_event AS
SELECT
  md5(concat(regexp_replace(lower(event.id), '[^\w]+ ','','g'),regexp_replace(cast(start_time as varchar(10)) , '[^\w]+','','g'))) as u_event_id,
  uuid,
  id AS event_id,
  topic AS event_name,
  SPLIT_PART(timezone,'/',2) AS event_city,
  SPLIT_PART(timezone,'/',1) AS event_country_region,
  SPLIT_PART(timezone,'/',2) AS organising_chapter,
  CASE
    WHEN (DATE(start_time)) < current_date THEN 'Cancelled'
    WHEN (DATE(start_time)) > current_date THEN 'Scheduled'
    ELSE 'Completed'
  END AS event_status,
  start_time::TIMESTAMP,
  duration::INTEGER AS duration_minutes
FROM
  meeting_event event
WHERE id NOT IN (SELECT id FROM exclusion_table);


/* zoom meeting registration */
CREATE TABLE zoom_meeting_registration_v2 AS
SELECT
  md5(concat(
  regexp_replace(lower(registrants.meeting_id), '[^\w]+ ','','g'),
  regexp_replace(lower(email) , '[^\w]+','','g'),
  regexp_replace(lower(registrants.id) , '[^\w]+','','g'),
  regexp_replace(cast(date(create_time) as varchar(10)) , '[^\w]+','','g')
)) as id_sequence,
  zme.u_event_id,
  registrants.meeting_id AS event_id,
  registrants.id AS registrant_id,
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
  LEFT JOIN zoom_meeting_event zme ON registrants.meeting_id = zme.event_id
WHERE registrants.meeting_id = zme.event_id
  AND zme.event_id NOT IN (SELECT id FROM exclusion_table);

/* zoom meeting attendance */
CREATE TABLE zoom_meeting_attendance AS 
SELECT 
    md5(concat(
    regexp_replace(lower(meeting_id), '[^\w]+ ','','g'),
    regexp_replace(lower(user_email) , '[^\w]+','','g'),
    regexp_replace(lower(user_id) , '[^\w]+','','g'),
    regexp_replace(cast(date(join_time) as varchar(10)) , '[^\w]+','','g')
    )) as id_sequence,
    zme.u_event_id,
    participants.id,
    participants.user_id,
    participants.user_email AS email,
    INITCAP(LOWER(SPLIT_PART(participants.name, ' ', 1))) AS first_name,
    INITCAP(LOWER(SPLIT_PART(participants.name, ' ', 2))) AS last_name,
    participants.meeting_id AS event_id,
    participants.join_time::TIMESTAMP AS joined_timestamp,
    participants.leave_time::TIMESTAMP AS left_timestamp,
    participants.duration::BIGINT AS duration_second,
    events.start_time::TIMESTAMP
FROM 
    meeting_participants participants
LEFT JOIN zoom_meeting_event zme ON participants.meeting_id = zme.event_id
WHERE zme.event_id NOT IN (SELECT id FROM exclusion_table);


