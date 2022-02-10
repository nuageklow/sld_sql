-- zoom webinar - registration email cnts
WITH
pzwr AS (
SELECT zwe.start_time, zwr.event_id, zwr.email
FROM public.zoom_webinar_registration zwr
INNER JOIN public.zoom_webinar_event zwe ON zwr.event_id = zwe.event_id
GROUP BY zwr.event_id, zwe.start_time, zwr.email
),
tzwr AS (
SELECT zwr.event_id, zwr.email
FROM test.zoom_webinar_registration_v2 zwr
GROUP by event_id, zwr.email
)
SELECT pzwr.start_time, pzwr.event_id AS p_event_id, pzwr.email, tzwr.event_id AS t_event_id, tzwr.email
FROM pzwr
FULL OUTER JOIN tzwr on pzwr.event_id = tzwr.event_id
WHERE pzwr.event_id = tzwr.event_id
GROUP BY pzwr.start_time, pzwr.event_id, tzwr.event_id, pzwr.email, tzwr.email
ORDER BY pzwr.start_time ASC;



WITH email_list AS (
SELECT pzwe.start_time, pzwr.event_id AS p_event_id, pzwr.email AS p_email, tzwr.event_id AS t_event_id, tzwr.email AS t_email
FROM public.zoom_webinar_registration pzwr
INNER JOIN public.zoom_webinar_event pzwe ON pzwr.event_id = pzwe.event_id
LEFT JOIN test.zoom_webinar_registration tzwr ON pzwr.event_id = tzwr.event_id
WHERE pzwr.event_id = tzwr.event_id AND tzwr.event_id IS NOT NULL
ORDER BY pzwe.start_time ASC)
SELECT *
FROM email_list
WHERE t_event_is IS NOT NULL AND t_email IS NOT NULL
ORDER BY start_time ASC
;
