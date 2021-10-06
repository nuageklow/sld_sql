/* new csvs - events and attendees */

/* exclusion table */
CREATE TABLE exclusion_table AS
SELECT DISTINCT events.id
FROM events
INNER JOIN attendees ON events.id = attendees.event_id
WHERE
  (events.name_text LIKE '[Webinar]%' AND DATE(events.start_local) < DATE('2021-04-01'))
  OR events.name_text LIKE 'Meiro%'
  OR events.name_text LIKE '%Dashboard%'
  OR events.status IN ('draft', 'drafts')
  OR events.id IN ('102333510284', '53765820015')
  OR attendees.profile_email IN ('1077883534@eventbrite.com',
                        '1083148370@eventbrite.com',
                        '1187501320@eventbrite.com',
                        '1270051081@eventbrite.com',
                        '1270051549@eventbrite.com',
                        '1270052829@eventbrite.com',
                        '1273170747@eventbrite.com',
                        '1273171829@eventbrite.com')
  AND attendees.status NOT IN ('Deleted', 'Uncounted Attending');

/*  */
CREATE TABLE event_mapping AS
SELECT * FROM eventbrite_event_mapping;


CREATE TABLE eventbrite_event AS
SELECT
  id AS event_id,
  md5(concat(regexp_replace(lower(events.id), '[^\w]+ ','','g'),regexp_replace(cast(start_local as varchar(10)) , '[^\w]+','','g'))) as u_event_id,
  name_text AS event_name,
  start_local::date AS event_date,
  REGEXP_REPLACE(SPLIT_PART(start_timezone,'/',2),'_',' ') AS event_city,
  SPLIT_PART(start_timezone,'/',1) AS event_region,
  CASE
    WHEN lower(status) IN ('scheduled','started') THEN 'Scheduled'
    WHEN lower(status) IN ('completed','live','ended') THEN 'Completed'
    WHEN lower(status) IN ('canceled','cancelled') THEN 'Cancelled'
    ELSE status
    END AS event_status
FROM
  events
WHERE
  id NOT IN (SELECT id FROM exclusion_table);


CREATE TABLE eventbrite_registration AS
SELECT
  ee.u_event_id,
  id,
  attendees.event_id,
  profile_email as email,
  INITCAP(LOWER(profile_first_name)) AS first_name,
  INITCAP(LOWER(profile_last_name)) AS last_name,
  CASE
    WHEN profile_gender IN ('******','') THEN NULL
    ELSE profile_gender
  END AS gender,
  profile_addresses_home_city AS city
  profile_addresses_home_country AS country_region,
  CASE
    WHEN attendees.profile_email IS NOT NULL THEN 'registered_attended'
    WHEN attendees.status = 'Not Attending' THEN 'cancelled_registration'
    WHEN ee.event_date < now() THEN 'registered_not_attended'
    WHEN ee.event_date >= now() THEN 'registered_for_future_event'
    ELSE 'missing_status'
  END AS status,
  created AS registration_timestamp,
  changed AS updated_timestamp,
  age_group,
  current_industry,
  latest_role,
  current_company,
  current_job_level,
  event_referred_source
FROM attendees
INNER JOIN eventbrite_event ee ON attendees.event_id = ee.event_id
WHERE ee.event_id NOT IN (SELECT id FROM exclusion_table);
