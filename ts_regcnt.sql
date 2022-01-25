/* 
92333707438
95469613756
*/

-- get both data
SELECT * FROM public.zoom_meeting_registration 
WHERE event_id = '92333707438' OR event_id = '95469613756';

SELECT * FROM test.zoom_meeting_registration 
WHERE event_id = '92333707438' OR event_id = '95469613756';
