-- Only use double-quotes for labels. Single-quotes are for 
-- string constants.
-- The statement did not work because user is also a 
-- keyword and is a specialized lookup in PostgreSQL to 
-- get the current user.
-- So we have to tell PostgreSQL that we're interested in the user table
-- And that is done by enclosing user in double-quotes.
\echo 
\echo -------------------------------------------- 
\echo -------------------------------------------- 
\echo -- Only use double-quotes for labels. String contats must be enclosed
\echo -- by single-quote characters.
\echo -- Because our user table has the same name as a keyword 
\echo -- and a special lookup table, we need to use a label 
\echo -- to distinguish this as our user-defined table "user"
select * 
  from "user"
 where surname = 'Williams';

\echo -- So labels are used to identify objects. 
\echo -- The double-quotes are only /required/ when there is 
\echo -- a name collision, case sensitivity, or spaces in the label.
