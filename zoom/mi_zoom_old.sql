/* Exclusion for Meiro events */
CREATE TABLE meiro_exclusion AS

SELECT DISTINCT id
FROM zoom_webinar_event
WHERE (topic like '[Webinar]%' AND date(start_time) < date('2021-04-01' ) )
    OR topic like 'Meiro%'

UNION

SELECT DISTINCT id
FROM zoom_meeting_event
WHERE (topic like '[Webinar]%' AND date(start_time) < date('2021-04-01' ) )
    OR topic like 'Meiro%'
;

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
        ('syd'),('uae'),('lhr'),('dxb')
;

CREATE TABLE event_type_lookup (
lookup_name text NOT NULL DEFAULT ''::text );

INSERT INTO event_type_lookup
VALUES ('Meet up'),('Hackathon'),('Hands-on workshop'),('Workshop'),('Certification Program'),('Other'),('Podcast'),
('Internal meeting'),('Test'),('Networking'),('Mentoring')
;

/* Zoom webinars */

-- Registration

CREATE TABLE zoom_webinar_registration AS

SELECT
    registrants.id,
    null as u_event_id,
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
    latest_job_position AS latest_role,
    job_level AS current_job_level,
    org AS current_company
FROM
    zoom_webinar_registrants AS registrants
LEFT JOIN
    zoom_webinar_event AS events
        ON registrants.webinar_id = events.id
WHERE events.id not in (select * from meiro_exclusion) -- excluding Meiro events
;

-- Attendance

-- CREATE SEQUENCE id_next START 1;

-- ALTER SEQUENCE id_next RESTART;

CREATE TABLE zoom_webinar_attendance AS

SELECT
    -- nextval('id_next') AS id_sequence,
    md5(concat(
    regexp_replace(lower(webinar_id), '[^\w]+ ','','g'),
    regexp_replace(lower(user_email) , '[^\w]+','','g'),
    regexp_replace(lower(user_id) , '[^\w]+','','g'),
    regexp_replace(cast(date(join_time) as varchar(10)) , '[^\w]+','','g')
    )) as id_sequence,
    null as u_event_id,
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
        ON participants.webinar_id = events.id
WHERE
    user_id NOT IN ('134220800', '33570816', '33574912', '83888128', '134224896', '16787456') AND
    events.id not in (select * from meiro_exclusion) -- excluding Meiro events -- excluding Meiro events
;


-- Events

ALTER TABLE zoom_webinar_event
  RENAME TO zoom_webinar_event_wrangling
;

CREATE TABLE zoom_webinar_event AS

SELECT
    uuid,
    id AS event_id,
    -- md5(concat(regexp_replace(lower(uuid), '[^\w]+ ','','g'),
    -- 					   regexp_replace(lower(event.id), '[^\w]+ ','','g'),
    -- 						 regexp_replace(cast(start_time as varchar(10)) , '[^\w]+','','g'))) as u_event_id,  -- unique_event_id
    md5(concat(regexp_replace(lower(event.id), '[^\w]+ ','','g'),regexp_replace(cast(start_time as varchar(10)) , '[^\w]+','','g'))) as u_event_id,
    topic AS event_name,
    SPLIT_PART(timezone, '/', 2) AS event_city,
    SPLIT_PART(timezone, '/', 1) AS event_country_region,
    SPLIT_PART(timezone, '/', 2) AS organising_chapter,
    case when date(start_time) < current_date and number_of_unique_attendees > 0 then 'Completed'
		when date(start_time) > current_date then 'Scheduled'
		else 'Cancelled'
		end as event_status,
    start_time,
    duration::INTEGER AS duration_minutes,
    number_of_registration::INTEGER,
    number_of_unique_attendees::INTEGER,
    number_of_users::INTEGER,
    number_of_cancelled::INTEGER,
    number_of_pending::INTEGER,
    number_of_newcomers::INTEGER
FROM
    zoom_webinar_event_wrangling AS event
LEFT JOIN
    (
    SELECT
        webinar_id AS event_id,
        COUNT(*) AS number_of_registration,
        COUNT(*) FILTER (WHERE status = 'cancelled') AS number_of_cancelled,
        COUNT(*) FILTER (WHERE status = 'pending') AS number_of_pending
    FROM
        zoom_webinar_registrants
    GROUP BY
        event_id) AS registration
        ON registration.event_id = event.id
LEFT JOIN
    (
    SELECT
        webinar_id AS event_id,
        COUNT(DISTINCT user_email) AS number_of_unique_attendees,
        COUNT(*) AS number_of_users
    FROM
        zoom_webinar_participants
    GROUP BY
        event_id) AS attendance
        ON attendance.event_id = event.id
LEFT JOIN
    (SELECT
        event_id,
        COUNT(CASE
                WHEN new_flag = 1 THEN email
                ELSE NULL
              END) AS number_of_newcomers
     FROM
        (SELECT
            DISTINCT a.email,
            e.id AS event_id,
            CASE
                WHEN a.start_time::timestamp > min(ap.start_time::timestamp) then 0
                ELSE 1
            END AS new_flag
        FROM
            zoom_webinar_event_wrangling AS e
        LEFT JOIN
            zoom_webinar_attendance AS a
                on e.id = a.event_id
        LEFT JOIN
            zoom_webinar_attendance AS ap
                ON a.email = ap.email
                AND ap.event_id <= a.event_id
        GROUP BY
            1,
            e.id,
            a.start_time) AS new_flag
             GROUP BY
                event_id) AS newcomers
         ON event.id = newcomers.event_id
WHERE id not in (select * from meiro_exclusion) -- excluding Meiro events -- excluding Meiro events

;

-- Panelist

ALTER TABLE zoom_webinar_panelist
  RENAME TO zoom_webinar_panelist_wrangling
;

CREATE TABLE zoom_webinar_panelist AS

SELECT
    id,
    null as u_event_id,
    email,
    name AS panelist_full_name,
    webinar_id AS event_id
FROM
    zoom_webinar_panelist_wrangling
;


/* ===================== */


/* Zoom meetings */

-- Registration

CREATE TABLE zoom_meeting_registration AS

SELECT
    registrants.id,
    null as u_event_id,
    email,
    INITCAP(first_name) AS first_name,
    INITCAP(last_name) AS last_name,
    INITCAP(LOWER(city)) AS city,
    country AS country_region,
    meeting_id AS event_id,
    event_referral AS event_referred_source,
    status,
    create_time::TIMESTAMP AS registration_timestamp,
    age AS age_group,
    gender,
    industry AS current_industry,
    latest_job_position AS latest_role,
    job_level AS current_job_level,
    company AS current_company
FROM
    zoom_meeting_registrants AS registrants
LEFT JOIN
    zoom_meeting_event AS events
        ON registrants.meeting_id = events.id
WHERE events.id not in (select * from meiro_exclusion) -- excluding Meiro events
;

-- Attendance

-- CREATE SEQUENCE id_next_meeting START 1;

-- ALTER SEQUENCE id_next_meeting RESTART;


CREATE TABLE zoom_meeting_attendance AS

SELECT
    -- nextval('id_next_meeting') AS id_sequence,
    md5(concat(
    regexp_replace(lower(meeting_id), '[^\w]+ ','','g'),
    regexp_replace(lower(user_email) , '[^\w]+','','g'),
    regexp_replace(lower(user_id) , '[^\w]+','','g'),
    regexp_replace(cast(date(join_time) as varchar(10)) , '[^\w]+','','g')
    )) as id_sequence,
    null AS u_event_id,
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
    zoom_meeting_participants AS participants
LEFT JOIN
    zoom_meeting_event AS events
        ON participants.meeting_id = events.id
WHERE events.id not in (select * from meiro_exclusion) -- excluding Meiro events
;

-- Event

ALTER TABLE zoom_meeting_event
  RENAME TO zoom_meeting_event_wrangling
;

CREATE TABLE zoom_meeting_event AS

SELECT
    uuid,
    id AS event_id,
    -- md5(concat(regexp_replace(lower(uuid), '[^\w]+ ','','g'),
    -- 					   regexp_replace(lower(event.id), '[^\w]+ ','','g'),
    -- 						 regexp_replace(cast(start_time as varchar(10)) , '[^\w]+','','g'))) as u_event_id,  -- unique_event_id
    md5(concat(regexp_replace(lower(event.id), '[^\w]+ ','','g'), regexp_replace(cast(start_time as varchar(10)) , '[^\w]+','','g'))) as u_event_id,  -- unique_event_id
    topic AS event_name,
    SPLIT_PART(timezone, '/', 2) AS event_city,
    SPLIT_PART(timezone, '/', 1) AS event_country_region,
    SPLIT_PART(timezone, '/', 2) AS organising_chapter,
    case when (date(start_time) < current_date and (number_of_unique_attendees = 0) or number_of_registration = 0) then 'Cancelled'
		when date(start_time) > current_date then 'Scheduled'
		else 'Completed'
		end as event_status,
    start_time,
    duration::INTEGER AS duration_minutes,
    number_of_registration::INTEGER,
    number_of_users::INTEGER,
    number_of_unique_attendees::INTEGER,
    number_of_cancelled::INTEGER,
    number_of_pending::INTEGER,
    number_of_newcomers::INTEGER
FROM
    zoom_meeting_event_wrangling AS event
LEFT JOIN
    (
    SELECT
        event_id,
        COUNT(DISTINCT email) AS number_of_unique_attendees,
        COUNT(*) AS number_of_users
    FROM
        zoom_meeting_attendance
    GROUP BY
        event_id) AS attendance
        ON attendance.event_id = event.id
LEFT JOIN
    (
    SELECT
        meeting_id AS event_id,
        COUNT(*) AS number_of_registration,
        COUNT(*) FILTER (WHERE status = 'cancelled') AS number_of_cancelled,
        COUNT(*) FILTER (WHERE status = 'pending') AS number_of_pending
    FROM
        zoom_meeting_registrants
    GROUP BY
        event_id) AS registration
        ON registration.event_id = event.id
LEFT JOIN
    (SELECT
        event_id,
        COUNT(CASE
                WHEN new_flag = 1 THEN email
                ELSE NULL
              END) AS number_of_newcomers
     FROM
        (SELECT
            DISTINCT a.email,
            e.id AS event_id,
            CASE
                WHEN a.start_time::timestamp > min(ap.start_time::timestamp) then 0
                ELSE 1
            END AS new_flag
        FROM
            zoom_meeting_event_wrangling AS e
        LEFT JOIN
            zoom_meeting_attendance AS a
                on e.id = a.event_id
        LEFT JOIN
            zoom_meeting_attendance AS ap
                ON a.email = ap.email
                AND ap.event_id <= a.event_id
        GROUP BY
            1,
            e.id,
            a.start_time) AS new_flag
             GROUP BY
                event_id) AS newcomers
         ON event.id = newcomers.event_id
WHERE id not in (select * from meiro_exclusion) -- excluding Meiro events
;


-- 20210116 manually adding 4 missing events by Karen SLD
insert into zoom_webinar_event("uuid","event_id","event_name","event_city","event_country_region","organising_chapter","start_time","duration_minutes","event_status","number_of_registration","number_of_unique_attendees")
values ('tJYscuCqrDouE9dlbEDLOxI7bel4uRmL0tYo',118,'Data Analysis with Python','Melbourne','Australia', 'Melbourne', '2020-08-08 14:00:00',180,'Completed', 886, 350),
('tJAlcemsqzgpHtevTt_vx2i23J4h6roXC-NS',119,'SLD Jakarta – Managing Relationships and Communications Remotely','Jakarta','Asia','Jakarta','2020-08-15 10:00:00',90,'Completed', 112, 35),
('tJcudu-gqTssHtbBU-F-2lX-U88Oxg7dNXzx',121,'She Loves Data LA: Intermediate Python','Los Angeles','North America','Los Angeles','2020-09-19 11:00:00',150,'Completed', 141, 50),
('tJ0qf-Crqz0rHt2slikvWsiydFYFuZa3nFMP',120,'She Loves Data LA: Introduction to Python','Los Angeles','North America','Los Angeles','2020-09-12 11:00:00',150,'Completed', 215,49)

;



/* backfill attendance 20210808
-- create backfill table

CREATE SEQUENCE user_id START 1;
ALTER SEQUENCE user_id RESTART;
CREATE TABLE backfill_attendance AS
SELECT
--   nextval('id_next') AS id_sequence,
  md5(concat(
  regexp_replace(lower(event_id), '[^\w]+ ','','g'),
  regexp_replace(lower(email) , '[^\w]+','','g'),
  regexp_replace(cast(nextval('user_id') as text), '[^\w]+','','g'),
  regexp_replace(cast(date(joined_timestamp) as varchar(10)) , '[^\w]+','','g')
  )) as id_sequence,
  null as id,
  nextval('user_id') as user_id,
  null as u_event_id,
  email,
  first_name,
  last_name,
  event_id,
  to_date(joined_timestamp, 'YYYY-MM-DD h:m:s') as joined_timestamp,
  to_date(left_timestamp, 'YYYY-MM-DD h:m:s') as left_timestamp,
  CAST(duration_second AS bigint) AS duration_second
FROM backfill_participants
WHERE to_date(joined_timestamp, 'YYYY-MM-DD h:m:s') > date('2016-01-01')
;

-- -- update backfill id and u_event_id
-- UPDATE backfill_attendance ba
-- SET id = md5(concat
--   regexp_replace(lower(event_id), '[^\w]+ ','','g'),
--   regexp_replace(lower(email) , '[^\w]+','','g'),
--   regexp_replace(cast(date(joined_timestamp) as varchar(10)) , '[^\w]+','','g')
--   ))
-- WHERE id is null;

-- merge backfill attendance table record back to zoom_webinar_attendance
INSERT INTO zoom_webinar_attendance (
  id_sequence,
  id,
  user_id,
  u_event_id,
  email,
  first_name,
  last_name,
  event_id,
  joined_timestamp,
  left_timestamp,
  duration_second)
  SELECT
  id_sequence,
  id,
  user_id,
  u_event_id,
  email,
  first_name,
  last_name,
  event_id,
  joined_timestamp,
  left_timestamp,
  duration_second
   FROM backfill_attendance;

-- merge backfill attendance table record back to zoom_webinar_attendance
INSERT INTO zoom_webinar_attendance (
  id_sequence,
  id,
  user_id,
  u_event_id,
  email,
  first_name,
  last_name,
  event_id,
  joined_timestamp,
  left_timestamp,
  duration_second)
  SELECT
  md5(concat(
  regexp_replace(lower(event_id), '[^\w]+ ','','g'),
  regexp_replace(lower(email) , '[^\w]+','','g'),
  regexp_replace(cast(nextval('user_id') as text) , '[^\w]+','','g'),
  regexp_replace(cast(date(joined_timestamp) as varchar(10)) , '[^\w]+','','g')
  )) as id_sequence,
  id,
  user_id,
  u_event_id,
  email,
  first_name,
  last_name,
  event_id,
  to_date(joined_timestamp, 'YYYY-MM-DD h:m:s') as joined_timestamp,
  to_date(left_timestamp, 'YYYY-MM-DD h:m:s') as left_timestamp,
  CAST(duration_second AS bigint) AS duration_second
   FROM backfill_from_db;
*/

UPDATE zoom_webinar_event zwe
SET u_event_id = md5(concat(
    					   regexp_replace(lower(event_id), '[^\w]+ ','','g'),
    						 regexp_replace(cast(date(start_time) as varchar(10)) , '[^\w]+','','g')))
WHERE u_event_id is null

;


UPDATE zoom_meeting_event zme
SET u_event_id = md5(concat(
    					   regexp_replace(lower(event_id), '[^\w]+ ','','g'),
    						 regexp_replace(cast(date(start_time) as varchar(10)) , '[^\w]+','','g')))
WHERE u_event_id is null

;


/* add u_event_id from zoom_webinar_event onto other zoom_webinar tables */
UPDATE zoom_webinar_registration zwr
SET u_event_id = zwe.u_event_id
FROM zoom_webinar_event zwe
WHERE zwr.event_id = zwe.event_id
;

UPDATE public.zoom_webinar_attendance zwa
SET u_event_id = zwe.u_event_id
FROM public.zoom_webinar_event zwe
WHERE zwa.event_id = zwe.event_id
;

UPDATE zoom_webinar_panelist zwp
SET u_event_id = zwe.u_event_id
FROM zoom_webinar_event zwe
WHERE zwp.event_id = zwe.event_id

;

UPDATE zoom_meeting_registration zmr
SET u_event_id = zme.u_event_id
FROM zoom_meeting_event zme
WHERE zmr.event_id = zme.event_id

;

UPDATE zoom_meeting_attendance zma
SET u_event_id = zme.u_event_id
FROM zoom_meeting_event zme
WHERE zma.event_id = zme.event_id

;

-- Event Mapping
CREATE TABLE zoom_event_mapping AS
WITH combined_mapping as (
    SELECT *
         , 'Zoom Meeting' as registration_source
         , 'Online' as online_offline
    FROM zoom_meeting_event_mapping
    WHERE NOT(event_type = 'no_event_type'
      AND chapter = 'no_chapter'
      AND event_topic = 'no_event_topic')
    --   AND level != 'no_level'
    --   AND event_focus_skill !='no_event_focus_skill'

    UNION ALL

    SELECT *
         , 'Zoom Webinar' as registration_source
         , 'Online' as online_offline
    FROM zoom_webinar_event_mapping
    WHERE NOT(event_type = 'no_event_type'
      AND chapter = 'no_chapter'
      AND event_topic = 'no_event_topic')
)
, combined_events as (
    SELECT u_event_id
         , uuid
         , event_id
         , start_time
    FROM zoom_meeting_event

    UNION ALL

    SELECT u_event_id
         , uuid
         , event_id
         , start_time
    FROM zoom_webinar_event
)

SELECT event.u_event_id
     , map.topic as event_name
     , date(map.start_time) as event_date
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
    AND map.start_time = event.start_time
LEFT JOIN event_type_lookup et ON lower(map.event_type) = replace(lower(et.lookup_name),' ','')
LEFT JOIN chapter_lookup c ON lower(map.chapter) = replace(lower(c.lookup_name),' ','')
LEFT JOIN event_topic_lookup eto ON lower(map.event_topic) = replace(lower(eto.lookup_name),' ','')
LEFT JOIN level_lookup l ON lower(map.level) = replace(lower(l.lookup_name),' ','')
LEFT JOIN event_focus_skill_lookup ef ON lower(map.event_focus_skill) = replace(lower(ef.lookup_name),' ','')
WHERE regexp_replace(lower(map.topic), '[^\w]+ ','','g') not like 'internal meeting%' and regexp_replace(lower(map.topic), '[^a-zA-Z0-9]+','','g') not like 'externalmeeting%' and regexp_replace(lower(map.topic), '[^a-zA-Z0-9]+','','g') not like 'test%'
/*
WHERE lower(event_type) in (select replace(lower(lookup_name),' ','') from event_type_lookup)
  and lower(chapter) in (select replace(lower(lookup_name),' ','') from chapter_lookup)
  and lower(event_topic) in (select replace(lower(lookup_name),' ','') from event_topic_lookup)
  and lower(level) in (select replace(lower(lookup_name),' ','') from level_lookup)
  and lower(event_focus_skill) in (select replace(lower(lookup_name),' ','') from event_focus_skill_lookup)
*/
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

;

UPDATE zoom_event_mapping
set event_type = 'Test'
where event_name like 'Test %'
;

/* INVESTIGATION : for identification on u_event_id duplication */

CREATE TABLE zoom_webinar_event_duplicated as
SELECT *
     , current_timestamp + '8 hour'::interval as batch_processing_date
FROM zoom_webinar_event
;

CREATE TABLE zoom_meeting_event_duplicated as
SELECT *
     , current_timestamp + '8 hour'::interval as batch_processing_date
FROM zoom_meeting_event
;
