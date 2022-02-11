-- write sql script to compare zoom webiste vs zoom api

WITH email_list AS (
SELECT pzwe.start_time, pzwr.event_id AS p_event_id, pzwr.email AS p_email, tzwr.event_id AS t_event_id, tzwr.email AS t_email
FROM public.zoom_webinar_registration pzwr
INNER JOIN public.zoom_webinar_event pzwe ON pzwr.event_id = pzwe.event_id
LEFT JOIN test.zoom_webinar_registration tzwr ON pzwr.event_id = tzwr.event_id
WHERE pzwr.event_id = tzwr.event_id AND tzwr.event_id IS NOT NULL
ORDER BY pzwe.start_time ASC)
SELECT *
FROM email_list
WHERE t_event_id IS NOT NULL AND t_email IS NOT NULL
ORDER BY start_time ASC
;
