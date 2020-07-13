\echo 
\echo -------------------------------------------- 
\echo -------------------------------------------- 
\echo Resetting statistics
select pg_stat_statements_reset();

\echo 
\echo -------------------------------------------- 
\echo -- Set schema
set search_path = optimization, public;
\echo 
\echo Pausing 10 seconds for you to switch back to the query monitor
select pg_sleep(10);

\echo 
\echo -------------------------------------------- 
\echo Running some queries...

select namespace, 
       pod_type, 
       count(*) as "count"
  from pod_info
 group
    by namespace,
       pod_type
 order 
    by 3 desc
\g /dev/null

select c.username,
       c.surname,
       c.forename,
       t.telno_type,
       t.telno
  from joins.customer c
  join joins.contact_info ci
    on ci.username = c.username
  join joins.telno t
    on t.type = ci.contact_type
   and t.id = ci.contact_id
 where ci.is_primary
\g /dev/null

       
select cluster_id, 
       namespace,
       node,
       pod, 
       array_agg(distinct usage_start order by usage_start) as "active_days"
  from pod_info
 where labels ? 'song'
 group 
    by cluster_id, 
       namespace,
       node,
       pod
 order 
    by cluster_id, 
       namespace,
       node,
       pod
\g /dev/null


select cluster_id, 
       namespace,
       node,
       pod, 
       array_agg(distinct usage_start order by usage_start) as "active_days"
  from pod_info
 where labels ? 'song'
 group 
    by cluster_id, 
       namespace,
       node,
       pod
 order 
    by cluster_id, 
       namespace,
       node,
       pod
\g /dev/null

select cluster_id, 
       namespace,
       node,
       pod, 
       array_agg(distinct usage_start order by usage_start) as "active_days"
  from pod_info
 where labels ? 'song'
 group 
    by cluster_id, 
       namespace,
       node,
       pod
 order 
    by cluster_id, 
       namespace,
       node,
       pod
\g /dev/null

select cluster_id, 
       namespace,
       node,
       pod, 
       array_agg(distinct usage_start order by usage_start) as "active_days"
  from pod_info
 where labels ? 'song'
 group 
    by cluster_id, 
       namespace,
       node,
       pod
 order 
    by cluster_id, 
       namespace,
       node,
       pod
\g /dev/null

select cluster_id, 
       namespace,
       node,
       pod, 
       array_agg(distinct usage_start order by usage_start) as "active_days"
  from pod_info
 where labels ? 'song'
 group 
    by cluster_id, 
       namespace,
       node,
       pod
 order 
    by cluster_id, 
       namespace,
       node,
       pod
\g /dev/null

select cluster_id, 
       namespace,
       node,
       pod, 
       array_agg(distinct usage_start order by usage_start) as "active_days"
  from pod_info
 where labels ? 'well'
 group 
    by cluster_id, 
       namespace,
       node,
       pod
 order 
    by cluster_id, 
       namespace,
       node,
       pod
\g /dev/null

select cluster_id, 
       namespace,
       node,
       pod, 
       array_agg(distinct usage_start order by usage_start) as "active_days"
  from pod_info
 where labels ?| '{song,property,lay}'::text[]
 group 
    by cluster_id, 
       namespace,
       node,
       pod
 order 
    by cluster_id, 
       namespace,
       node,
       pod
\g /dev/null

select cluster_id, 
       namespace,
       node,
       usage_start, 
       array_agg(distinct pod order by pod) as "active_pods",
       sum(coalesce(stats->>'cpu_hours', '0.0')::numeric(30,15)) filter (where pod_type = 'POD') as "total_cpu_utilization",
       sum(coalesce(stats->>'storage_gigs_used', '0.0')::numeric(30,15)) filter (where pod_type = 'STORAGE') as "total_storage_utilization"
  from pod_info
 where labels ?| '{song,property,lay}'::text[]
 group 
    by grouping sets (
         (
           cluster_id,
           namespace,
           node,
           usage_start
         ),
         (
           usage_start
         )
       )
\g /dev/null

update pod_info
   set stats = jsonb_set(stats, '{eek}', '500')
 where labels->>'well' = 'oil'
   and usage_start >= '2020-05-03'::date
   and usage_start < '2020-05-11'::date;

delete
  from pod_info
 where cluster_id = '9234875050353';

insert 
  into joins.app_user (username, password)
select 'aretha' || extract(epoch from current_timestamp)::int::text, md5('i-am-diva');

