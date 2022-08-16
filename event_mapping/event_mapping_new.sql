CREATE TABLE zoom_event_mapping AS 
WITH
combined_mapping AS (
  SELECT *,
    'Zoom Meeting' as registration_source,
    'Online' as online_offline
  FROM meeting_event_mapping
  WHERE NOT(
      event_type = 'no_event_type'
      AND chapter = 'no_chapter'
      AND event_topic = 'no_event_topic')  
  UNION ALL 
  SELECT *
        , 'Zoom Webinar' as registration_source
        , 'Online' as online_offline
  FROM webinar_event_mapping
  WHERE NOT(event_type = 'no_event_type'
    AND chapter = 'no_chapter'
    AND event_topic = 'no_event_topic')  
),
combined_events AS (
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
),
interim AS (
  SELECT
    DISCINCT(event.u_event_id),
    map.topic AS event_name,
    DATE(map.start_time) AS event_date,
    
)
