/* OTHERS */
ALTER TABLE tmp.reg_table
ADD COLUMN meeting_id CHAR;

UPDATE tmp.reg_table 
SET meeting_id = '92333707438';


/* meeting event */
CREATE TABLE tmp.zoom_meeting_registration AS
SELECT
  -- nextval('id_next_meeting') AS id_sequence,
  md5(concat(
  regexp_replace(lower(registrants.meeting_id), '[^\w]+ ','','g'),
  regexp_replace(lower(email) , '[^\w]+','','g'),
  regexp_replace(cast(date(create_time) as varchar(10)) , '[^\w]+','','g')
)) as id,
  zme.u_event_id,
  registrants.meeting_id AS event_id,
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
FROM tmp.reg_table registrants
  LEFT JOIN test.zoom_meeting_event zme ON registrants.meeting_id = zme.event_id
WHERE registrants.meeting_id = zme.event_id
  AND registrants.id = participants.id
  AND zme.event_id NOT IN (SELECT id FROM exclusion_table)
GROUP BY email, participants.user_email, registrant_id, attendance_user_id, create_time, zme.start_time, u_event_id, registrants.status, registrants.meeting_id, first_name, last_name, age, city, country_region, gender, industry, job_level, company, latest_job_position, event_referral;
