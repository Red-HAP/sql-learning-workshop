-- Strings and labels Part 1
-- Strings are *always* surrounded by single-quotes

-- Let's select Ash from the user table:
select * 
  from overivew.user
 where surname = 'Williams';
-- 1 record, right?

-- Typing overview is time-consuming
-- Let's set the path that the engine will use to resolve an object
-- This path will be evaluated in order much like the PATH environment
-- variable in Linux/Unix
set search_path = overview, public;

-- Let's see overview's tables now!
\dt

-- Note that user is now visible as is items from the public schema.
-- Select Ash again.
select * 
  from user
 where surname = 'Williams';
-- Explain the output