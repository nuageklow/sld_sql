-- zoom registration - inconsistent email
WITH 
api AS (
SELECT zwe.start_time, zwr.event_id, email
FROM public.zoom_webinar_registration zwr
INNER JOIN public.zoom_webinar_event zwe ON zwr.event_id = zwe.event_id
UNION
SELECT zme.start_time, zmr.event_id, email
FROM public.zoom_meeting_registration zmr
INNER JOIN public.zoom_meeting_event zme ON zmr.event_id = zme.event_id
),
gui AS (
SELECT zwe.start_time, r.event_id, email
FROM zoom.clean_registration r
INNER JOIN public.zoom_webinar_event zwe ON r.event_id = zwe.event_id
INNER JOIN public.zoom_meeting_event zme ON r.event_id = zme.event_id
)
SELECT api.start_time, api.event_id AS api_event_id, api.email AS api_email, gui.event_id AS gui_event_id, gui.email AS gui_email
FROM api 
FULL OUTER JOIN gui USING (event_id, email)
WHERE api.email is null or gui.email is null and api.start_time > '2021-09-01'
ORDER BY api.start_time ASC;


select * from zoom.clean_registration;