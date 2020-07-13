-- Strings and labels Part 1
-- Strings are *always* surrounded by single-quotes

-- Let's select Ash from the user table:
\echo 
\echo -------------------------------------------- 
\echo -------------------------------------------- 
\echo -- Selecting the Ash record from the overview.user table.
select * 
  from overview.user
 where surname = 'Williams';
-- 1 record, right?

-- Typing overview is time-consuming
-- Let's set the path that the engine will use to resolve an object
-- This path will be evaluated in order much like the PATH environment
-- variable in Linux/Unix
select pg_sleep(2);
\echo
\echo -------------------------------------------- 
\echo -- Set the schema search path so we do not 
\echo -- have to reference "overview" in every statement
set search_path = overview, public;

-- Let's see overview's tables now!
\echo
\echo -------------------------------------------- 
\echo -- Examine the listing of tables.
\dt

-- Note that user is now visible as is items from the public schema.
-- Select Ash again.
select pg_sleep(2);
\echo
\echo -------------------------------------------- 
\echo -- Now select the Ash record again from the user table. 
select * 
  from user
 where surname = 'Williams';
-- Explain the output
\echo
\echo -- Can you explain the output?
