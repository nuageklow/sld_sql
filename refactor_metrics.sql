/* 
METRICS to Validate Refactored Productions
- numbers of events
- numbers of registrations
- registration lists

Eventbrite - 
89949227561 / 20200218 / MNL - cancelled -> need to backfill
123 / 2016 / JKT - fb event  -> need to backfill


*/

/* EVENTBRITE*/
-- eventrite - inconsistent event_id
SELECT pee.u_event_id AS pee_u_event_id, pee.event_id AS pee_event_id, tee.u_event_id AS tee_u_event_id, tee.event_id AS tee_event_id
FROM public.eventbrite_event pee
FULL OUTER JOIN test.eventbrite_event tee ON pee.u_event_id = tee.u_event_id
WHERE pee.u_event_id IS null OR tee.u_event_id IS null;

-- eventbrite - total events cnt
SELECT COUNT(pee.u_event_id) AS pee_event_cnt, COUNT(tee.u_event_id) AS tee_event_cnt
FROM public.eventbrite_event pee
FULL OUTER JOIN test.eventbrite_event tee ON pee.u_event_id = tee.u_event_id;

-- eventbrite -- registration cnt - no record
SELECT per_reg.per_event_id, per_reg.per_cnt, ter_reg.ter_event_id, ter_reg.ter_cnt
FROM
	(SELECT per.event_id AS per_event_id, COUNT(per.email) AS per_cnt
	FROM public.eventbrite_registration per
	GROUP BY per.event_id
	) AS per_reg
FULL OUTER JOIN
	(SELECT ter.event_id AS ter_event_id, COUNT(ter.email) AS ter_cnt
	FROM test.eventbrite_registration ter
	GROUP BY ter.event_id
	) AS ter_reg
ON per_reg.per_event_id = ter_reg.ter_event_id
WHERE per_reg.per_event_id IS null OR ter_reg.ter_event_id IS null;

-- evenrbrite - registration cnt - inconsistent cnt
SELECT reg.per_event_id, reg.per_cnt, reg.ter_event_id, reg.ter_cnt
FROM 
(SELECT per_reg.per_event_id, per_reg.per_cnt, ter_reg.ter_event_id, ter_reg.ter_cnt
FROM
	(SELECT per.event_id AS per_event_id, COUNT(per.email) AS per_cnt
	FROM public.eventbrite_registration per
	GROUP BY per.event_id
	) AS per_reg
FULL OUTER JOIN
	(SELECT ter.event_id AS ter_event_id, COUNT(ter.email) AS ter_cnt
	FROM test.eventbrite_registration ter
	GROUP BY ter.event_id
	) AS ter_reg
ON per_reg.per_event_id = ter_reg.ter_event_id) reg
WHERE reg.per_event_id = reg.ter_event_id AND reg.per_cnt != reg.ter_cnt 



/* zoom */
-- zoom events
SELECT pzwe.event_id AS pzwe_event_id, tzwe.event_id AS tzwe_event_id
FROM public.zoom_webinar_event pzwe FULL OUTER JOIN test.zoom_webinar_event tzwe
ON pzwe.event_id = tzwe.event_id
WHERE pzwe.event_id IS NULL or tzwe.event_id IS NULL and DATE(pzwe.start_time) >= DATE('2021-07-01');

-- zoom meeting events
SELECT pzme.event_id AS pzme_event_id, tzme.event_id AS tzme_event_id
FROM public.zoom_meeting_event pzme FULL OUTER JOIN test.zoom_meeting_event tzme
ON pzme.event_id = tzme.event_id
WHERE pzme.event_id IS NULL or tzme.event_id IS NULL and DATE(pzme.start_time) >= DATE('2021-07-01');



-- eventbrite 



-- zoom
WITH 
pzwr AS (
SELECT event_id, COUNT(email) AS reg_count
FROM public.zoom_webinar_registration
GROUP BY event_id
),
tzwr AS (
SELECT event_id, COUNT(email) AS reg_count
FROM test.zoom_webinar_registration
GROUP BY event_id
)
SELECT pzwr.event_id AS p_event_id, pzwr.reg_count AS p_reg, tzwr.event_id AS t_event_id, tzwr.reg_count AS t_reg
FROM pzwr 
FULL OUTER JOIN tzwr ON pzwr.event_id = tzwr.event_id
WHERE pzwr.event_id IS NULL or tzwr.event_id IS NULL;
