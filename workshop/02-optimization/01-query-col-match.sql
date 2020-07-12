-- set schema
set search_path = optimization, public;

\echo We are starting with 2 indexes on the pod_info table.
\echo One btree index on usage_start (date) 
\echo and one btree index on namespace (text)
\echo

-- Analyze this query's plan
\echo Observe the query plan here.
explain analyze 
select count(*) 
  from pod_info
 where namespace = 'house-1';

-- let's observe what happens when we add the text pattern ops
\echo
\echo Now create a new index on namespace using text_pattern_ops
create index ix_namespace_startswith on pod_info (namespace text_pattern_ops);
analyze pod_info;

\echo 
\echo Note which index is used here with a starting match:
explain analyze 
select count(*) 
  from pod_info
 where namespace like 'house%';
-- note which index was used

-- Let's try a like operation matching all 'county' namespaces
\echo
\echo Now we try a contains match
explain analyze 
select count(*) 
  from pod_info
 where namespace like '%house%';
-- so why did the execution time go up?
-- note that a parallel seq scan was used.

-- let's try a gin index with trigram ops
create extension pg_trgm schema public;
create index ix_pod_info_namespace_like on pod_info using gin (namespace gin_trgm_ops);
analyze pod_info;

explain analyze 
select count(*) 
  from pod_info
 where namespace like '%house%';
-- The parallel seq scan is an optimization that postgres uses to try to 
-- be as efficient as possible, but with this query, the trigram index
-- can be faster




