WITH 
zoom_api AS (
    SELECT start_time, zwr.event_id, email









    SELECT start_time, zwr.event_id, COUNT(email) AS reg_count
    FROM public.zoom_webinar_registration zwr
    INNER JOIN public.zoom_webinar_event zwe ON zwr.event_id = zwe.event_id
    GROUP BY zwr.event_id, start_time
),
zoom_gui AS (
    SELECT 
)