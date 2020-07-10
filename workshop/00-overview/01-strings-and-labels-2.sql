-- Lables are *always* sourrounded by double-quotes
-- The statement did not work because user is also a 
-- keyword and is a specialized lookup in PostgreSQL to 
-- get the current user.
-- So we have to tell PostgreSQL that we're interested in the user table
-- And that is done by enclosing user in double-quotes.
select * 
  from "user"
 where surname = 'Williams';

-- So labels are used to identify objects. They are only required with 
-- double-quotes when ambiguity arises as a bareword.
