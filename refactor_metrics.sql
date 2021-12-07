-- eventrite 
select pee.u_event_id as pee_u_event_id, pee.event_id as pee_event_id, tee.u_event_id as tee_u_event_id, tee.event_id as tee_event_id
from public.eventbrite_event pee
full outer join test.eventbrite_event tee on pee.u_event_id = tee.u_event_id
where pee.u_event_id is null or tee.u_event_id is null;


-- zoom events
SELECT pzwe.event_id AS pzwe_event_id, tzwe.event_id AS tzwe_event_id
FROM public.zoom_webinar_event pzwe FULL OUTER JOIN test.zoom_webinar_event tzwe
ON pzwe.event_id = tzwe.event_id
WHERE pzwe.event_id IS NULL or tzwe.event_id IS NULL and DATE(pzwe.start_time) >= DATE('2021-07-01');



select per_reg.per_event_id, per_reg.per_cnt, ter_reg.ter_event_id, ter_reg.ter_cnt
from
(select per.event_id as per_event_id, count(per.email) as per_cnt
from public.eventbrite_registration per
group by per.event_id
) as per_reg
full outer join
(select ter.event_id as ter_event_id, count(ter.email) as ter_cnt
from test.eventbrite_registration ter
group by ter.event_id
) as ter_reg
on per_reg.per_event_id = ter_reg.ter_event_id
where per_reg.per_event_id is null or ter_reg.ter_event_id is null;
