\echo 
\echo -------------------------------------------- 
\echo -------------------------------------------- 
\echo -- Set search path
set search_path = optimization, public;

\echo 
\echo -------------------------------------------- 
\echo Check the record count of optimization.pod_info
select count(*) from pod_info;

\echo 
\echo -------------------------------------------- 
\echo Now altering cluster_id, resource_id, pod to be bigint type from text type
\echo Note the statement execution time
\timing on
alter table pod_info
      alter column cluster_id set data type int8 using resource_id::int8,
      alter column resource_id set data type int8 using resource_id::int8,
      alter column pod set data type int8 using pod::int8;
\timing off
