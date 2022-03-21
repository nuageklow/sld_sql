/* Exclusion for Meiro events */
CREATE TABLE meiro_exclusion AS

SELECT DISTINCT id 
FROM events
WHERE (name_text like '[Webinar]%' AND date(start_local) < date('2021-04-01' ) )
    OR name_text like 'Meiro%'
    -- OR name_test like '%Dashboard Specialist%'

;


/*
REGISTRATION
*/

CREATE TABLE eventbrite_registration AS

WITH long_table AS (
    SELECT
        attendees.id,
        attendees.profile_email,
        attendees.profile_first_name,
        attendees.profile_last_name,
        attendees.profile_addresses_home_city,
        attendees.profile_addresses_home_country,
        attendees.profile_gender,
        attendees.status,
        attendees.created,
        attendees.changed,
        attendees.event_id,
        answers.question,
        answers.answer
    FROM
        answers
    JOIN
        attendees
            ON answers."JSON_parentId" = attendees.answers),

profile AS (
    SELECT
        id,
        INITCAP(LOWER(profile_first_name)) AS first_name,
        INITCAP(LOWER(profile_last_name)) AS last_name,
        profile_email AS email,
        CASE
            WHEN profile_gender IN ('******', '') THEN NULL
            ELSE profile_gender
        END AS gender,
        INITCAP(LOWER(profile_addresses_home_city)) AS city,
        profile_addresses_home_country AS country_region,
        event_id,
        status,
        created AS registration_timestamp,
        changed AS updated_timestamp
    FROM
        long_table
    GROUP BY
        id,
        first_name,
        last_name,
        profile_email,
        gender,
        city,
        country_region,
        status,
        event_id,
        created,
        changed),

age AS (
    SELECT
        id,
        CASE
            WHEN answer LIKE '%|%' THEN NULL
            WHEN answer LIKE '' THEN NULL
            ELSE answer
        END AS age_group
    FROM
        long_table
    WHERE
        question LIKE '%your age bracket?%'),

role AS (
    SELECT
        id,
        answer AS latest_role
    FROM
        long_table
    WHERE
        question = 'What is your latest job position?'),

industry AS
    (SELECT
        id,
        answer AS current_industry
    FROM
        long_table
    WHERE
        question = 'In which industry do you work?'),

source AS
    (SELECT
        id,
        answer AS event_referred_source
    FROM
        long_table
    WHERE
        question = 'How did you find us?'),

level AS
    (SELECT
        id,
        answer AS current_job_level
    FROM
        long_table
    WHERE
        question = 'At what type of level would you consider your current position?'),
        
company AS 
    (SELECT 
        id,
        answer AS current_company
    FROM
        long_table
    WHERE
        question = 'In which company?')

SELECT
    profile.id,
    profile.first_name,
    profile.last_name,
    profile.email,
    CASE
        WHEN profile.city = '' THEN NULL
        ELSE profile.city
    END AS city,
    CASE
        WHEN profile.country_region = '' THEN NULL
        ELSE profile.country_region
    END AS country_region,
    age.age_group,
    profile.gender,
    industry.current_industry,
    role.latest_role,
    source.event_referred_source,
    level.current_job_level,
    company.current_company,
    profile.event_id,
    null as u_event_id,
    profile.status,
    profile.registration_timestamp::timestamp,
    profile.updated_timestamp::timestamp
FROM
    profile
LEFT JOIN
    age
        ON profile.id = age.id
LEFT JOIN
    industry
        ON profile.id = industry.id
LEFT JOIN
    role
        ON profile.id = role.id
LEFT JOIN
    source
        ON profile.id = source.id
LEFT JOIN
    level
        ON profile.id = level.id
LEFT JOIN 
    company
        ON profile.id = company.id
WHERE
    profile.email NOT IN ('1077883534@eventbrite.com',
                          '1083148370@eventbrite.com',
                          '1187501320@eventbrite.com',
                          '1270051081@eventbrite.com',
                          '1270051549@eventbrite.com',
                          '1270052829@eventbrite.com',
                          '1273170747@eventbrite.com',
                          '1273171829@eventbrite.com')
    AND profile.status NOT IN ('Deleted',
                               'Uncounted Attending')
    AND profile.event_id != '102333510284'
    AND profile.event_id not in (select * from meiro_exclusion)
;

/*
ATTENDANCE
*/

CREATE TABLE eventbrite_attendance AS

SELECT
    registration.id,
    null as u_event_id,
    registration.email,
    registration.first_name,
    registration.last_name,
    registration.event_id,
    registration.status AS attendance_status,
    registration.updated_timestamp::timestamp AS joined_timestamp,
    events.start_utc::timestamp
FROM
    eventbrite_registration AS registration
LEFT JOIN
    events
        ON registration.event_id = events.id
WHERE
    registration.status IN ('Checked In',
               'Uncounted Checked In')
    AND events.id != '102333510284'
    AND events.id not in (select * from meiro_exclusion)
;

/*
EVENTS
*/

CREATE TABLE eventbrite_event AS

SELECT
    id AS event_id,
    md5(concat(regexp_replace(lower(id), '[^\w]+ ','','g'), regexp_replace(cast(start_local::date as varchar(10)) , '[^\w]+','','g'))) as u_event_id,
    name_text AS event_name,
    start_local::date AS event_date,
    REGEXP_REPLACE(SPLIT_PART(start_timezone, '/', 2), '_', ' ') AS event_city,
    SPLIT_PART(start_timezone, '/', 1) AS event_region,
    case when lower(status) in ('scheduled', 'started') then 'Scheduled'
		when lower(status) in ('completed', 'live', 'ended') then 'Completed'
		when lower(status) in ('canceled', 'cancelled') then 'Cancelled'
		else status
		end as event_status,
    number_of_attendees::integer,
    number_of_registration::integer,
    number_of_cancelled::integer,
    number_of_newcomers::integer
FROM
    events
LEFT JOIN
    (SELECT
        event_id,
        COUNT(id) FILTER (WHERE status IN ('Attending', 'Checked In', 'Not Attending')) AS number_of_registration,
        COUNT(id) FILTER (WHERE status IN ('Checked In', 'Uncounted Checked In')) AS number_of_attendees,
        COUNT(id) FILTER (WHERE status IN ('Not Attending')) AS number_of_cancelled
     FROM
        attendees
     WHERE
        status NOT IN ('Deleted',
                       'Uncounted Attending')
     GROUP BY
        event_id) event_counts
   ON events.id = event_counts.event_id
LEFT JOIN
    (SELECT
        event_id,
        COUNT(CASE
                WHEN new_flag = 1 THEN email
                ELSE NULL
              END) AS number_of_newcomers
     FROM
        (SELECT
            e.id AS event_id,
            a.email,
            CASE
                WHEN a.start_utc::timestamp > min(ap.start_utc::timestamp) then 0
                ELSE 1
            END AS new_flag
        FROM
            events AS e
        LEFT JOIN
            eventbrite_attendance AS a
                on e.id = a.event_id
        LEFT JOIN
            eventbrite_attendance AS ap
                ON a.email = ap.email
                AND ap.event_id <= a.event_id
        GROUP BY
            e.id,
            a.email,
            a.start_utc) AS new_flag
             GROUP BY
                event_id) AS newcomers
         ON events.id = newcomers.event_id
WHERE
    id != '53765820015' -- This is a template which should not be included in the data
    AND status NOT IN ('draft', 'drafts')
    AND id != '102333510284'
    AND id not in (select * from meiro_exclusion)
;

-- 20210116 - adding an missing record manually by Karen SLD
insert into eventbrite_event("event_id", "event_name", "event_city", "event_region", "event_date", "event_status", "number_of_registration", "number_of_attendees")
values (123, 'SheLovesData in Jakarta: Data Engineering Night', 'Jakarta','Asia', '2018-10-15','Completed', 224, 80)
;


UPDATE eventbrite_event ee
SET u_event_id = md5(concat(regexp_replace(lower("event_id"), '[^\w]+ ','','g'), regexp_replace(cast("event_date" as varchar(10)) , '[^\w]+','','g')))
where u_event_id is null;


/* add u_event_id from eventbrite_event onto other eventbrite_webinar tables */

UPDATE eventbrite_attendance ea
SET u_event_id = ee.u_event_id
FROM eventbrite_event ee
WHERE ea.event_id = ee.event_id

;

UPDATE eventbrite_registration er
SET u_event_id = ee.u_event_id
FROM eventbrite_event ee
WHERE er.event_id = ee.event_id

;

UPDATE eventbrite_event set number_of_attendees = 9 WHERE event_id ='62230050757';

-- /* 2020-02-18 Manila event - assign u_event_id */
-- UPDATE eventbrite_registration er
-- SET u_event_id = md5(concat(regexp_replace(lower("event_id"), '[^\w]+ ','','g'), regexp_replace(cast("event_date" as varchar(10)) , '[^\w]+','','g')))
-- WHERE event_id = '89949227561';


CREATE TABLE eventbrite_event_mapping_clean AS
    SELECT event.u_event_id
         , map.name_text as event_name
         , date(map.start_local) as event_date
         , map.chapter
         , map.event_type
         , map.event_topic
         , map.level
         , 'Offline' as online_offline
         , 'Eventbrite' as registration_source
         , map.event_focus_skill
         , 'event_id*event_date' as hash_mechanics
         , '' as event_status
         , '' as long_term_certification_program
         , current_timestamp + '8 hour'::interval as batch_processing_date
    FROM eventbrite_event_mapping map
    LEFT JOIN eventbrite_event event 
        ON map.id = event.event_id
        AND date(start_local) = event.event_date
    LEFT JOIN event_label_mapping as db_map
       ON db_map.u_event_id = event.u_event_id
       AND REGEXP_REPLACE(lower(db_map.event_name),'[^\w|\t|\s]+','','g') = REGEXP_REPLACE(lower(event.event_name),'[^\w|\t|\s]+','','g')
       AND DATE(db_map.event_date) = DATE(event.event_date)
    WHERE db_map.u_event_id IS NULL

UNION ALL

/*for manual mapping on internal meeting */

SELECT event.u_event_id
     , event.event_name
     , event.event_date
     , event.event_city as chapter
     , case when regexp_replace(lower(event.event_name), '[^\w]+ ','','g') like 'internal meeting%' then  'Internal meeting' 
            when regexp_replace(lower(event.event_name), '[^\w]+ ','','g') like '[external meeting%' then 'External meeting'
       end as event_type
     , 'Other' as event_topic
     , '' as level
     , 'Offline' as online_offline
     , 'Eventbrite' as registration_source
     , '' as event_focus_skill
     , 'uuid*event_id*start_time' as hash_mechanics
     , '' as event_status
     , '' as long_term_certification_program
     , current_timestamp + '8 hour'::interval as batch_processing_date
FROM eventbrite_event as event
LEFT JOIN event_label_mapping as db_map
       ON db_map.u_event_id = event.u_event_id
       AND REGEXP_REPLACE(lower(db_map.event_name),'[^\w|\t|\s]+','','g') = REGEXP_REPLACE(lower(event.event_name),'[^\w|\t|\s]+','','g')
       AND DATE(db_map.event_date) = DATE(event.event_date)
WHERE (regexp_replace(lower(event.event_name), '[^\w]+ ','','g') like 'internal meeting%' or regexp_replace(lower(event.event_name), '[^\w]+ ','','g') like '[external meeting%')
    AND db_map.u_event_id is NULL
;

UPDATE eventbrite_event_mapping_clean
set event_type = 'Test'
where event_name like 'Test%'
;