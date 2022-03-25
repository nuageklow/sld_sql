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
  OR topic LIKE 'Meiro'
  OR topic LIKE 'Certification';

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
    WHEN DATE(start_time) >= current_date THEN 'Scheduled'
    ELSE 'Cancelled'
  END AS event_status,
  start_time::timestamp,
  duration::INTEGER AS duration_minutes
FROM
  webinar_event event;
-- WHERE id NOT IN (SELECT id FROM exclusion_table);

/* zoom_webinar_registration */
CREATE TABLE zoom_webinar_registration AS
SELECT
    zwe.u_event_id,
    webinar_id AS event_id,
    registrants.id AS id,
    email,
    CASE
        WHEN registrants.status = 'pending' THEN 'cancelled_registration'
        WHEN zwe.start_time < now() THEN 'registered_not_attended'
        WHEN zwe.start_time >= now() THEN 'registered_for_future_event'
        WHEN registrants.email IS NOT NULL THEN 'registered_attended'
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
FROM webinar_registrants AS registrants
LEFT JOIN zoom_webinar_event zwe ON registrants.webinar_id = zwe.event_id
    AND zwe.event_id NOT IN (SELECT id FROM exclusion_table);

/*  */
CREATE TABLE zoom_webinar_attendance AS
SELECT
    md5(concat(
    regexp_replace(lower(webinar_id), '[^\w]+ ','','g'),
    regexp_replace(lower(user_email) , '[^\w]+','','g'),
    regexp_replace(lower(user_id) , '[^\w]+','','g'),
    regexp_replace(cast(date(join_time) as varchar(10)) , '[^\w]+','','g')
    )) as id_sequence,
    zwe.u_event_id,
    participants.id AS id,
    participants.user_id,
    participants.user_email AS email,
    INITCAP(LOWER(SPLIT_PART(participants.name, ' ', 1))) AS first_name,
    INITCAP(LOWER(SPLIT_PART(participants.name, ' ', 2))) AS last_name,
    participants.webinar_id AS event_id,
    participants.join_time::TIMESTAMP AS joined_timestamp,
    participants.leave_time::TIMESTAMP AS left_timestamp,
    participants.duration::BIGINT AS duration_second,
    zwe.start_time::TIMESTAMP
FROM
    webinar_participants participants
LEFT JOIN zoom_webinar_event zwe ON participants.webinar_id = zwe.event_id
    AND zwe.event_id NOT IN (SELECT id FROM exclusion_table);

/* webinar panelist */
CREATE TABLE zoom_webinar_panelist AS
SELECT
  distinct(id),
  u_event_id,
  email,
  name AS panelist_full_name,
  webinar_id AS event_id
FROM
  webinar_panelist panelist
LEFT JOIN zoom_webinar_event events ON panelist.webinar_id = events.event_id
WHERE panelist.id != '-vexmGkHRNuKwMYtQfFdlg';
;


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
    WHEN (DATE(start_time)) < current_date THEN 'Completed'
    WHEN (DATE(start_time)) >= current_date THEN 'Scheduled'
    ELSE 'Cancelled'
  END AS event_status,
  start_time::TIMESTAMP,
  duration::INTEGER AS duration_minutes
FROM
  meeting_event event
WHERE id NOT IN (SELECT id FROM exclusion_table);


/* zoom meeting registration */
CREATE TABLE zoom_meeting_registration AS
SELECT
--   md5(concat(
--   regexp_replace(lower(registrants.meeting_id), '[^\w]+ ','','g'),
--   regexp_replace(lower(email) , '[^\w]+','','g'),
--   regexp_replace(lower(registrants.id) , '[^\w]+','','g'),
--   regexp_replace(cast(date(create_time) as varchar(10)) , '[^\w]+','','g')
-- )) as id_sequence,
  zme.u_event_id,
  registrants.meeting_id AS event_id,
  registrants.id AS id,
  email,
    CASE
        WHEN registrants.status = 'pending' THEN 'cancelled_registration'
        WHEN zme.start_time < now() THEN 'registered_not_attended'
        WHEN zme.start_time >= now() THEN 'registered_for_future_event'
        WHEN registrants.email IS NOT NULL THEN 'registered_attended'
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
  create_time::TIMESTAMP AS registration_timestamp
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
    participants.id AS id,
    participants.user_id,
    participants.user_email AS email,
    INITCAP(LOWER(SPLIT_PART(participants.name, ' ', 1))) AS first_name,
    INITCAP(LOWER(SPLIT_PART(participants.name, ' ', 2))) AS last_name,
    participants.meeting_id AS event_id,
    participants.join_time::TIMESTAMP AS joined_timestamp,
    participants.leave_time::TIMESTAMP AS left_timestamp,
    participants.duration::BIGINT AS duration_second,
    zme.start_time::TIMESTAMP
FROM
    meeting_participants participants
LEFT JOIN zoom_meeting_event zme ON participants.meeting_id = zme.event_id
WHERE zme.event_id NOT IN (SELECT id FROM exclusion_table);


UPDATE
zoom_webinar_event zwe
SET event_status = 'Cancelled'
WHERE (SELECT COUNT(DISTINCT(email)) FROM zoom_webinar_registration zwr where zwe.u_event_id = zwr.u_event_id) = 0
AND DATE(start_time) < current_date;

UPDATE
zoom_meeting_event zme
SET event_status = 'Cancelled'
WHERE
(SELECT COUNT(DISTINCT(email)) FROM zoom_meeting_registration zmr where zme.u_event_id = zmr.u_event_id) = 0
AND DATE(start_time) < current_date;





-- Event Mapping
/* 4 Oct 2021 added in logic to exclude mapping that is already available in event_label_mapping */

    /*lookup table for event mapping */
CREATE TABLE event_focus_skill_lookup (
lookup_name text NOT NULL DEFAULT ''::text );


INSERT INTO event_focus_skill_lookup
VALUES ('Python'),('Power BI'),('Tableau'),('Data Storytelling'),('Leadership'),('Google Analytics'),('R'),
('SQL'),('Machine Learning'),('Google Data Studio'),('Yellowfin'),('Qlik'),('Social Media'),('Hiring'), ('Data Basics'),('AI')

;

CREATE TABLE level_lookup (
lookup_name text NOT NULL DEFAULT ''::text );

INSERT INTO level_lookup
VALUES ('Beginner'),('Intermediate'),('Advanced')

;

CREATE TABLE event_topic_lookup (
lookup_name text NOT NULL DEFAULT ''::text );

INSERT INTO event_topic_lookup
VALUES ('Visualization'),('Programming'),('Soft Skills'),('Digital Marketing'),('Other'),('Intro to Data'),('Data')

;

CREATE TABLE chapter_lookup (
lookup_name text NOT NULL DEFAULT ''::text );

INSERT INTO chapter_lookup
VALUES ('abv'),('akl'),('evn'),('sgn'),('hkg'),('cgk'),('jnb'),
        ('kul'),('lax'),('mnl'),('mel'),('prg'),('rep'),('sin'),
        ('syd'),('uae'),('lhr'),('dxb'),('del')
;

CREATE TABLE event_type_lookup (
lookup_name text NOT NULL DEFAULT ''::text );

INSERT INTO event_topic_lookup
VALUES ('Visualization'),('Programming'),('Soft Skills'),('Digital Marketing'),('Other'),('Intro to Data'),('Data')
;



/* 4 Oct 2021 added in logic to exclude mapping that is already available in event_label_mapping */
CREATE TABLE zoom_event_mapping AS
WITH combined_mapping as (
    SELECT *
         , 'Zoom Meeting' as registration_source
         , 'Online' as online_offline
    FROM meeting_event_mapping
    WHERE NOT(event_type = 'no_event_type'
      AND chapter = 'no_chapter'
      AND event_topic = 'no_event_topic')
    --   AND level != 'no_level'
    --   AND event_focus_skill !='no_event_focus_skill'

    UNION ALL

    SELECT *
         , 'Zoom Webinar' as registration_source
         , 'Online' as online_offline
    FROM webinar_event_mapping
    WHERE NOT(event_type = 'no_event_type'
      AND chapter = 'no_chapter'
      AND event_topic = 'no_event_topic')
)

, combined_events as (
    SELECT u_event_id
         , uuid
         , event_id
         , DATE(start_time) AS start_time
    FROM zoom_meeting_event

    UNION ALL

    SELECT u_event_id
         , uuid
         , event_id
         , DATE(start_time) AS start_time
    FROM zoom_webinar_event
)

, interim as (
SELECT DISTINCT(event.u_event_id)
     , map.topic as event_name
     , DATE(map.start_time) as event_date
     , case
        when lower(chapter) = 'abv' then 'Abuja'
        when lower(chapter) = 'akl' then 'Auckland'
        when lower(chapter) = 'evn' then 'Yerevan'
        when lower(chapter) = 'sgn' then 'Ho Chi_Minh'
        when lower(chapter) = 'hkg' then 'Hong Kong'
        when lower(chapter) = 'cgk' then 'Jakarta'
        when lower(chapter) = 'jnb' then 'Johannesburg'
        when lower(chapter) = 'kul' then 'Kuala Lumpur'
        when lower(chapter) = 'lax' then 'Los Angeles'
        when lower(chapter) = 'mnl' then 'Manila'
        when lower(chapter) = 'mel' then 'Melbourne'
        when lower(chapter) = 'prg' then 'Prague'
        when lower(chapter) = 'rep' then 'Siem Reap'
        when lower(chapter) = 'sin' then 'Singapore'
        when lower(chapter) = 'syd' then 'Sydney'
        when lower(chapter) = 'uae' then 'UAE'
        when lower(chapter) = 'lhr' then 'London'
        when lower(chapter) = 'dxb' then 'Dubai'
        when lower(chapter) = 'del' then 'India'
      else ''
      end as chapter
     , et.lookup_name as event_type
     , eto.lookup_name as event_topic
     , l.lookup_name as level
     , online_offline
     , registration_source
     , ef.lookup_name as event_focus_skill
     , 'event_id*start_time' as hash_mechanics
     , '' as event_status
     , '' as long_term_certification_program
     , current_timestamp + '8 hour'::interval as batch_processing_date
FROM combined_mapping as map
LEFT JOIN combined_events event
    ON map.uuid = event.uuid
    AND map.id = event.event_id
    AND DATE(map.start_time) = DATE(event.start_time)
LEFT JOIN event_type_lookup et ON lower(map.event_type) = replace(lower(et.lookup_name),' ','')
LEFT JOIN chapter_lookup c ON lower(map.chapter) = replace(lower(c.lookup_name),' ','')
LEFT JOIN event_topic_lookup eto ON lower(map.event_topic) = replace(lower(eto.lookup_name),' ','')
LEFT JOIN level_lookup l ON lower(map.level) = replace(lower(l.lookup_name),' ','')
LEFT JOIN event_focus_skill_lookup ef ON lower(map.event_focus_skill) = replace(lower(ef.lookup_name),' ','')
WHERE
        regexp_replace(lower(map.topic), '[^\w]+ ','','g') not like 'internal meeting%'
    AND regexp_replace(lower(map.topic), '[^a-zA-Z0-9]+','','g') not like 'externalmeeting%'
    AND regexp_replace(lower(map.topic), '[^a-zA-Z0-9]+','','g') not like 'test%'

UNION ALL

/* Manual mapping for Internal Meeting */
SELECT u_event_id
     , event_name
     , date(start_time) as event_date
     , organising_chapter as chapter
     , case when regexp_replace(lower(event_name), '[^\w]+ ','','g') like 'internal meeting%' then  'Internal meeting'
            when regexp_replace(lower(event_name), '[^a-zA-Z0-9]+','','g') like 'externalmeeting%' then 'External meeting'
      end as event_type
     , 'Other' as event_topic
     , '' as level
     , 'Online' as online_offline
     , 'Zoom Meeting' as registration_source
     , '' as event_focus_skill
     , 'event_id*start_time' as hash_mechanics
     , '' as event_status
     , '' as long_term_certification_program
     , current_timestamp + '8 hour'::interval as batch_processing_date
FROM zoom_meeting_event
WHERE regexp_replace(lower(event_name), '[^\w]+ ','','g') like 'internal meeting%' or regexp_replace(lower(event_name), '[^a-zA-Z0-9]+','','g') like 'externalmeeting%'

UNION ALL

/* Manual mapping for Internal Meeting */
SELECT u_event_id
     , event_name
     , date(start_time) as event_date
     , organising_chapter as chapter
     , case when regexp_replace(lower(event_name), '[^\w]+ ','','g') like 'internal meeting%' then  'Internal meeting'
            when regexp_replace(lower(event_name), '[^a-zA-Z0-9]+','','g') like 'externalmeeting%' then 'External meeting'
      end as event_type
     , 'Other' as event_topic
     , '' as level
     , 'Online' as online_offline
     , 'Zoom Webinar' as registration_source
     , '' as event_focus_skill
     , 'event_id*start_time' as hash_mechanics
     , '' as event_status
     , '' as long_term_certification_program
     , current_timestamp + '8 hour'::interval as batch_processing_date
FROM zoom_webinar_event
WHERE regexp_replace(lower(event_name), '[^\w]+ ','','g') like 'internal meeting%' or regexp_replace(lower(event_name), '[^a-zA-Z0-9]+','','g') like 'externalmeeting%'

UNION ALL

/* Manual mapping for Test */
SELECT u_event_id
     , event_name
     , date(start_time) as event_date
     , organising_chapter as chapter
     , 'Test' event_type
     , 'Other' as event_topic
     , '' as level
     , 'Online' as online_offline
     , 'Zoom Webinar' as registration_source
     , '' as event_focus_skill
     , 'event_id*start_time' as hash_mechanics
     , '' as event_status
     , '' as long_term_certification_program
     , current_timestamp + '8 hour'::interval as batch_processing_date
FROM zoom_webinar_event
WHERE regexp_replace(lower(event_name), '[^\w]+ ','','g') like 'test%'

UNION ALL

/* Manual mapping for Test */
SELECT u_event_id
     , event_name
     , date(start_time) as event_date
     , organising_chapter as chapter
     , 'Test' event_type
     , 'Other' as event_topic
     , '' as level
     , 'Online' as online_offline
     , 'Zoom Meeting' as registration_source
     , '' as event_focus_skill
     , 'event_id*start_time' as hash_mechanics
     , '' as event_status
     , '' as long_term_certification_program
     , current_timestamp + '8 hour'::interval as batch_processing_date
FROM zoom_meeting_event
WHERE regexp_replace(lower(event_name), '[^\w]+ ','','g') like 'test%'
)

SELECT automated_map.*
FROM interim as automated_map
LEFT JOIN event_label_mapping as db_map
      ON db_map.u_event_id = automated_map.u_event_id
      AND REGEXP_REPLACE(lower(db_map.event_name),'[^\w|\t|\s]+','','g') = REGEXP_REPLACE(lower(automated_map.event_name),'[^\w|\t|\s]+','','g')
      AND db_map.u_event_id != '978+46523'
      AND DATE(db_map.event_date) = DATE(automated_map.event_date)
WHERE db_map.u_event_id IS NULL 
;

UPDATE zoom_event_mapping
set event_type = 'Test'
where event_name like 'Test %'
;