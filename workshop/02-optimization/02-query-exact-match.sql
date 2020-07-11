-- set schema
set search_path = optimization, public;

-- Analyze this query's plan
explain analyze 
select count(*) 
  from pod_info
 where namespace = 'county';

-- let's observe what happens when we add the text pattern ops
create index ix_namespace_startswith on pod_info (namespace text_pattern_ops);
analyze pod_info;

explain analyze 
select count(*) 
  from pod_info
 where namespace = 'county-1';
-- note which index was used

-- Let's try a like operation matching all 'county' namespaces
explain analyze 
select count(*) 
  from pod_info
 where namespace like '%county%';
-- so why did the execution time go up?
-- note that a parallel seq scan was used.

-- let's try a gin index with trigram ops
create extension pg_trgm schema public;
create index ix_namespace_like on pod_info using gin (namespace gin_trgm_ops);
analyze pod_info;

explain analyze 
select count(*) 
  from pod_info
 where namespace like '%county%';
-- The parallel seq scan is an optimization that postgres uses to try to 
-- be as efficient as possible, but with this query, the trigram index
-- is still faster


select sum((stats->>'cpu_hours')::numeric(30,12))
  from pod_info
 where namespace = 'country'
   and pod_type = 'POD' and labels->>'few' = 'half';

explain analyze select sum((stats->>'cpu_hours')::numeric(30,12))
  from pod_info
 where namespace = 'include'
   and pod_type = 'POD' 
   and labels->>'few' = 'half';

