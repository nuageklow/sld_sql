-- Event Mapping
/* 4 Oct 2021 added in logic to exclude mapping that is already available in event_label_mapping */

CREATE TABLE zoom_event_mapping AS 
WITH 
combined_mapping AS (
    SELECT * , 
    start_time::TIMESTAMP AS start_time,
    'Zoom Webinar' AS registration_source,
    'Online' AS online_offline
    FROM webinar_event_mapping
    UNION
    SELECT *,
    start_time::TIMESTAMP AS start_time,
    'Zoom Meeting' AS registration_source,
    'Online' AS online_offline
     FROM meeting_event_mapping
),
combined_events AS (
    SELECT u_event_id, uuid, event_id, start_time FROM zoom_webinar_event
    UNION ALL 
    SELECT u_event_id, uuid, event_id, start_time FROM zoom_meeting_event
),
interim AS (
    SELECT 
    event.u_event_id,
    map.topic as event_name,
    map.start_time::TIMESTAMP as event_date,
    online_offline,
    registration_source,
    'event_id*start_time' as hash_mechanics,
    '' as event_status,
    '' as long_term_certification_program,
    current_timestamp + '8 hour'::interval as batch_processing_date
    FROM combined_mapping map
    LEFT JOIN combined_events event ON
        map.uuid = event.uuid AND map.id = event.event_id AND map.start_time = event.start_time
    WHERE
        regexp_replace(lower(map.topic), '[^\w]+ ','','g') not like 'internal meeting%'
    AND regexp_replace(lower(map.topic), '[^a-zA-Z0-9]+','','g') not like 'externalmeeting%'
    AND regexp_replace(lower(map.topic), '[^a-zA-Z0-9]+','','g') not like 'test%'  

    UNION ALL 

    /* Manual mapping for Internal Meeting - zoom meeting*/
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

    /* Manual mapping for Internal Meeting - zoom webinar */
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
      AND DATE(db_map.event_date) = DATE(automated_map.event_date)
WHERE db_map.u_event_id IS NULL
;

UPDATE zoom_event_mapping
set event_type = 'Test'
where event_name like 'Test %'
;
