/* event_mapping */

ALTER TABLE event_mapping
RENAME TO raw_event_mapping;

CREATE TABLE event_mapping AS
SELECT
*,
'' AS registration_source,
'' AS online_offline
FROM raw_event_mapping


CREATE TABLE event_mapping AS














u_event_id text NOT NULL DEFAULT ''::text,
event_name text NULL DEFAULT ''::text,
event_date text NULL DEFAULT '1984-11-17'::date,
chapter text NULL DEFAULT ''::text,
event_type text NULL DEFAULT ''::text,
event_topic text NULL DEFAULT ''::text,
"level" text NULL DEFAULT ''::text,
online_offline text NULL DEFAULT ''::text,
registration_source text NULL DEFAULT ''::text,
event_focus_skill text NULL DEFAULT ''::text,
hash_mechanics text NULL DEFAULT ''::text,
event_status text NULL DEFAULT ''::text,
long_term_certification_program text NULL,

map event db_map


-- eventbrite
CREATE TABLE event_mapping AS
SELECT
event.u_event_id,
map.name_text AS event_name,
DATE(event.start_local) AS event_date,
map.chapter,
map.event_type,
map.event_topic,
map.level




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