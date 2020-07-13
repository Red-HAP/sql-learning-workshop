-- set schema
\echo 
\echo -------------------------------------------- 
\echo -------------------------------------------- 
\echo -- Set search path
set search_path = optimization, public;

\echo 
\echo -------------------------------------------- 
\echo -- We are starting with 2 indexes on the pod_info table.
\echo -- One btree index on usage_start (date) 
\echo -- and one btree index on namespace (text)

-- Analyze this query's plan
\echo 
\echo -------------------------------------------- 
\echo -- Observe the query plan here.
explain analyze 
select count(*) 
  from pod_info
 where namespace = 'enjoy';

select pg_sleep(10);
-- let's observe what happens when we add the text pattern ops
\echo 
\echo -------------------------------------------- 
\echo -- Now create a new index on namespace using text_pattern_ops
create index ix_pod_info_namespace_startswith on pod_info (namespace text_pattern_ops);
analyze pod_info;

\echo 
\echo -------------------------------------------- 
\echo -- Note which index is used here with a starting match:
explain analyze 
select count(*) 
  from pod_info
 where namespace like 'enjoy%';
-- note which index was used

select pg_sleep(10);
-- Let's try a like operation matching all 'county' namespaces
\echo 
\echo -------------------------------------------- 
\echo -- Now we try a contains match
explain analyze 
select count(*) 
  from pod_info
 where namespace like '%enjoy%';
-- note that a parallel seq scan was used.

select pg_sleep(10);
-- let's try a gin index with trigram ops
\echo 
\echo -------------------------------------------- 
\echo -- Creating trigram index
create extension pg_trgm schema public;
create index ix_pod_info_namespace_like on pod_info using gin (namespace gin_trgm_ops);
analyze pod_info;

\echo 
\echo -------------------------------------------- 
\echo -- Trying the query again. Note the index used and the timing.
explain analyze 
select count(*) 
  from pod_info
 where namespace like '%enjoy%';
-- The parallel seq scan is an optimization that postgres uses to try to 
-- be as efficient as possible, but with this query, the trigram index
-- can be faster. Of course, this plan and execution may change with data scale.




