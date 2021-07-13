/* exclusion_table */
CREATE TABLE exclusion_table AS
WITH zoom_combine AS (
  SELECT * FROM webinar_event
  UNION ALL
  SELECT * FROM meeting_event
)
SELECT DISTINCT zoom_combine.id
FROM zoom_combine
LEFT JOIN zoom_webinar_participants zwp ON zoom_combine.id = zwp.webinar_id
WHERE (topic LIKE '[Webinar]%' AND date(start_time) < date('2021-04-01'))
  OR topic LIKE 'Meiro'
  OR zwp.user_id NOT IN ('134220800', '33570816', '33574912', '83888128', '134224896', '16787456');


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
  start_time,
  duration::INTEGER AS duration_minutes
FROM
  webinar_event event
WHERE id NOT IN (SELECT id FROM exclusion_table);


/* zoom webinar registration */
CREATE TABLE zoom_webinar_registration AS
SELECT
  events.u_event_id,
  registrants.id,
  webinar_id AS event_id,
  email,
  INITCAP(first_name) AS first_name,
  INITCAP(last_name) AS last_name,
  INITCAP(LOWER(city)) AS city,
  country AS country_region,
  event_referral AS event_referred_source,
  status,
  create_time::TIMESTAMP AS registration_timestamp,
  age AS age_group,
  gender AS gender,
  industry AS current_industry,
  job_level AS current_job_level,
  org AS current_company,
  latest_job_position AS latest_role
FROM
  webinar_registrants registrants LEFT JOIN
  zoom_webinar_event events ON registrants.webinar_id = events.event_id
WHERE events.id NOT IN (SELECT id FROM exclusion_table)
WHERE registrants.webinar_id = events.event_id
 AND events.event_id NOT IN (SELECT id FROM exclusion_table);

/* zoom webinar attendance */
CREATE SEQUENCE id_next START 1;
ALTER SEQUENCE id_next RESTART;
CREATE TABLE zoom_webinar_attendance AS
SELECT
    nextval('id_next') AS id_sequence,
    events.u_event_id,
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
    zoom_webinar_participants AS participants
LEFT JOIN
    zoom_webinar_event AS events
        ON participants.webinar_id = events.event_id
WHERE participants.webinar_id = events.event_id
  AND events.event_id NOT IN (SELECT id FROM exclusion_table);


/* webinar panelist */
ALTER TABLE zoom_webinar_panelist RENAME TO zoom_webinar_panelist_wrangling;
CREATE TABLE zoom_webinar_panelist AS
SELECT
  id,
  u_event_id,
  email,
  name AS panelist_full_name,
  webinar_id AS event_id
FROM
  zoom_webinar_panelist_wrangling panelist
LEFT JOIN zoom_webinar_event events ON panelist.webinar_id = events.event_id;

/* meeting event */
ALTER TABLE zoom_meeting_event RENAME TO zoom_meeting_event_wrangling;
CREATE TABLE zoom_meeting_event AS
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
  start_time,
  duration::INTEGER AS duration_minutes,
FROM
  zoom_meeting_event_wrangling event
WHERE id NOT IN (SELECT id FROM exclusion_table);

/* zoom meeting registration */
CREATE TABLE zoom_webinar_registration AS
SELECT
  events.u_event_id,
  registrants.id,
  email,
  INITCAP(first_name) AS first_name,
  INITCAP(last_name) AS last_name,
  INITCAP(LOWER(city)) AS city,
  country AS country_region,
  webinar_id AS event_id,
  event_referral AS event_referred_source,
  status,
  create_time::TIMESTAMP AS registration_timestamp,
  age AS age_group,
  gender,
  industry AS current_industry,
  job_level AS current_job_level,
  org AS current_company,
  latest_job_position AS latest_role
FROM
  zoom_meeting_registrants registrants
LEFT JOIN zoom_webinar_event events ON registrants.webinar_id = events.event_id
WHERE registrants.webinar_id = events.event_id
  AND events.id NOT IN (SELECT id FROM exclusion_table);


/* zoom meeting attendance */
CREATE SEQUENCE id_next START 1;
ALTER SEQUENCE id_next RESTART;
CREATE TABLE zoom_meeting_attendance AS
SELECT
    nextval('id_next') AS id_sequence,
    events.u_event_id,
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
    zoom_meeting_participants AS participants
LEFT JOIN
    zoom_meeting_event AS events
        ON participants.webinar_id = events.event_id
WHERE participants.webinar_id = events.event_id
  AND events.event_id NOT IN (SELECT id FROM exclusion_table);

/* zoom meeting panelist */
ALTER TABLE zoom_meeting_panelist RENAME TO zoom_webinar_panelist_wrangling;
CREATE TABLE zoom_meeting_panelist AS
SELECT
  id,
  events.u_event_id,
  webinar_id AS event_id,
  email,
  name AS panelist_full_name
FROM
  zoom_meeting_panelist_wrangling panelists
LEFT JOIN
  zoom_meeting_event events ON panelists.webinar_id = events.event_id
WHERE webinar_id NOT IN (SELECT id FROM exclusion_table);
