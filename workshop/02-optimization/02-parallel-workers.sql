-- set schema
set search_path = optimization, public;

\echo Examine the optimization based on cost here.
\echo
\echo Set the min_parallel_table_scan_size threshold high so that parallel workers are not considered.
\echo This sill simulate a smaller table size based on this threshold value.
set min_parallel_table_scan_size = 100000;

-- Let's look at this baseline (no index on labels)
\echo
\echo Now examine this plan
explain analyze 
select usage_start,
       sum((stats->>'cpu_hours')::numeric(30,12))
  from pod_info
 where usage_start >= '2020-05-01'::date
   and usage_start < '2020-05-31'::date
   and labels->>'attack' = 'the-block'
 group 
    by 1
 order
    by 1;

\echo Set an index on the pod_labels
create index ix_pod_info_labels on pod_info using gin (labels);
analyze pod_info;

\echo
\echo Observe the plan now.
explain analyze 
select usage_start,
       sum((stats->>'cpu_hours')::numeric(30,12))
  from pod_info
 where usage_start >= '2020-05-01'::date
   and usage_start < '2020-05-31'::date
   and labels->>'attack' = 'the-block'
 group 
    by 1
 order
    by 1;

\echo 
\echo We can try to mitigate this by adding an index condition
explain analyze 
select usage_start,
       sum((stats->>'cpu_hours')::numeric(30,12))
  from pod_info
 where usage_start >= '2020-05-01'::date
   and usage_start < '2020-05-31'::date
   and labels ? 'attack'
   and labels->>'attack' = 'the-block'
 group 
    by 1
 order
    by 1;

\echo
\echo And if you run these two queries a few times, it looks like the 
\echo change has made an improvement.

\echo
\echo Now simulate table growth by resetting the parameter back to default.
\echo You can see the settings record for this parameter by executing:
\echo select * from pg_settings where name = 'min_parallel_table_scan_size';
set min_parallel_table_scan_size = 1024;

\echo 
\echo Now run the query with the extra check
explain analyze 
select usage_start,
       sum((stats->>'cpu_hours')::numeric(30,12))
  from pod_info
 where usage_start >= '2020-05-01'::date
   and usage_start < '2020-05-31'::date
   and labels ? 'attack'
   and labels->>'attack' = 'the-block'
 group 
    by 1
 order
    by 1;

\echo 
\echo and now run the query without the extra check
explain analyze 
select usage_start,
       sum((stats->>'cpu_hours')::numeric(30,12))
  from pod_info
 where usage_start >= '2020-05-01'::date
   and usage_start < '2020-05-31'::date
   and labels->>'attack' = 'the-block'
 group 
    by 1
 order
    by 1;

\echo So note that the performance can change as the data size changes.
\echo Query optimization cannot be a one-and-done thing if data are
\echo allowed to be continuously accumulating in a table.

