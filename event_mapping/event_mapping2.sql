-- Event Mapping
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