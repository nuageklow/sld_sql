/* event_mapping */

ALTER TABLE event_mapping
RENAME TO raw_event_mapping;

CREATE TABLE event_mapping AS 
SELECT 
    *,
    '' AS registration_source,
    '' AS online_offline
FROM raw_event_mapping







