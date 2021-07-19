/* new csvs - events and attendees */

/* exclusion table */
CREATE TABLE exclusion_table AS
SELECT DISTINCT id
FROM events
WHERE
  (events.name_text LIKE '[Webinar]%' AND DATE(events.start_local) < DATE('2021-04-01'))
  OR events.name_text LIKE 'Meiro%'
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
  AND attendees.status NOT IN ('Deleted', 'Uncounted Attending')



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
  id NOT IN (SELECT id FROM exclusion_table);




"id","profile_email","profile_first_name","profile_last_name","profile_addresses_home_city","profile_addresses_home_country","profile_gender","status","created","changed","event_id","age_group","latest_role","current_industry","event_referred_source","current_job_level","current_company"

CREATE TABLE eventbrite_registration AS
SELECT
  event.u_event_id,
  id,
  event_id,
  profile_email,
  INITCAP(LOWER(profile_first_name)) AS first_name,
  INITCAP(LOWER(profile_last_name)) AS last_name,
  CASE
    WHEN profile_gender IN ('******','') THEN NULL
    ELSE profile_gender
  END AS gender,
  INITCAP(LOWER(profile_addresses_home_city)) AS city,
  profile_addresses_home_city AS country_region,
  profile_addresses_home_country,
  status,
  created AS registration_timestamp,
  changed AS updated_timestamp,
  age_group,
  current_industry,
  latest_role,
  current_company,
  current_job_level,
  event_referred_source
FROM attendees
INNER JOIN eventbrite_event event ON attendess.event_id = event.event_id
WHERE event.id NOT IN (SELECT id FROM exclusion_table);


CREATE TABLE eventbrite_attendance AS
  event.u_event_id,
  registration.id,
  registration.email,
  registration.first_name,
  registration.last_name,
  registration.event_id,
  registration.status AS attendance_status,
  registration.updated_timestamp::timestamp AS joined_timestamp,
  event.start_utc::timestamp
FROM eventbrite_registration registration
INNER JOIN eventbrite_event event ON registration.event_id = event.id
WHERE event.id NOT IN (SELECT id from exclusion_table);
