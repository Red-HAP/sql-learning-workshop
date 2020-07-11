-- set schema path
set search_path = optimization, public;

analyze pod_info;

select distinct cluster_id from pod_info;
select distinct namespace from pod_info;
select distinct key from pod_info, jsonb_each_text(labels);
select distinct value from pod_info, jsonb_each_text(labels);
