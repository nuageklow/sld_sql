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



-- zoom webinar - registration cnt - inconsistent cnt
WITH
pzwr AS (
SELECT start_time, zwr.event_id, COUNT(email) AS reg_count
FROM public.zoom_webinar_registration zwr
INNER JOIN public.zoom_webinar_event zwe ON zwr.event_id = zwe.event_id
GROUP BY zwr.event_id, start_time
),
tzwr AS (
SELECT event_id, COUNT(email) AS reg_count
FROM test.zoom_webinar_registration_v2
GROUP BY event_id
)
SELECT pzwr.start_time, pzwr.event_id AS p_event_id, pzwr.reg_count AS p_reg, tzwr.event_id AS t_event_id, tzwr.reg_count AS t_reg
FROM pzwr
FULL OUTER JOIN tzwr ON pzwr.event_id = tzwr.event_id
WHERE t_event_id IS NOT NULL
ORDER BY pzwr.start_time asc;
;

-- zoom webinar - attendance cnt - inconsistent cnt
WITH
pzwa AS (
SELECT zwe.start_time, zwe.event_name, zwa.event_id, COUNT(email) AS cnt
FROM public.zoom_webinar_attendance zwa
INNER JOIN public.zoom_webinar_event zwe ON zwa.event_id = zwe.event_id
GROUP BY zwa.event_id, zwe.start_time, zwe.event_name
),
tzwa AS (
SELECT event_id, COUNT(email) AS cnt
FROM test.zoom_webinar_attendance_v2
GROUP BY event_id
)
SELECT pzwa.start_time, pzwa.event_name, pzwa.event_id AS old_event_id, pzwa.cnt AS old_attendance, tzwa.event_id AS new_event_id, tzwa.cnt AS new_attendance
FROM pzwa
FULL OUTER JOIN tzwa ON pzwa.event_id = tzwa.event_id
ORDER BY pzwa.start_time asc;
;



-- zoom meeting - registration cnt - inconsistent cnt
SELECT reg.start_time, reg.pzmr_event_id, reg.pzmr_cnt, reg.tzmr_event_id, reg.tzmr_cnt
FROM (
    SELECT pzmr_reg.start_time, pzmr_reg.pzmr_event_id, pzmr_reg.pzmr_cnt, tzmr_reg.tzmr_event_id, tzmr_reg.tzmr_cnt
    FROM
    (SELECT pzmr.event_id AS pzmr_event_id, COUNT(pzmr.email) AS pzmr_cnt, pzme.start_time
    FROM public.zoom_meeting_registration pzmr
	INNER JOIN public.zoom_meeting_event pzme ON pzmr.event_id = pzme.event_id
    GROUP BY pzmr.event_id, pzme.start_time
    ) AS pzmr_reg
    FULL OUTER JOIN
    (SELECT tzmr.event_id AS tzmr_event_id, COUNT(tzmr.email) AS tzmr_cnt
    FROM test.zoom_meeting_registration tzmr
    GROUP BY tzmr.event_id
    ) AS tzmr_reg
    ON pzmr_reg.pzmr_event_id = tzmr_reg.tzmr_event_id
) reg
ORDER BY reg.start_time ASC;

-- zoom meeting - attendance cnt - inconsistent cnt
WITH
pzma AS (
SELECT zme.start_time, zma.event_id, COUNT(email) AS cnt
FROM public.zoom_meeting_attendance zma
INNER JOIN public.zoom_meeting_event zme ON zma.event_id = zme.event_id
GROUP BY zma.event_id, zme.start_time
),
tzma AS (
SELECT event_id, COUNT(email) AS cnt
FROM test.zoom_meeting_attendance_v2
GROUP BY event_id
)
SELECT pzma.start_time, pzma.event_id AS p_event_id, pzma.cnt AS p_attendance, tzma.event_id AS t_event_id, tzma.cnt AS t_attendance
FROM pzma
FULL OUTER JOIN tzma ON pzma.event_id = tzma.event_id
ORDER BY pzma.start_time asc;
;
