-- set schema path
set search_path = optimization, public;

analyze pod_info;

select cluster_id, count(*) from pod_info group by 1 order by 1;
select namespace, count(*) from pod_info group by 1 order by 1;
select key, count(*) from pod_info, jsonb_each_text(labels) group by 1 order by 1;
select value, count(*) from pod_info, jsonb_each_text(labels) group by 1 order by 1;
