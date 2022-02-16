-- zoom registration - inconsistent email
WITH 
api_webinar AS (
SELECT zwe.start_time, zwr.event_id, email
FROM public.zoom_webinar_registration zwr
INNER JOIN public.zoom_webinar_event zwe ON zwr.event_id = zwe.event_id
),
),
gui AS (
SELECT event_id, email
FROM zoom.clean_registration 
)
SELECT api.start_time, api.event_id AS api_event_id, api.email AS api_email, gui.event_id AS gui_event_id, gui.email AS gui_email
FROM api 
FULL OUTER JOIN gui USING (event_id, email)
WHERE api.event_id IS NOT NULL AND gui.event_id
ORDER BY api.start_time ASC;


