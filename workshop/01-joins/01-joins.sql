-- Find only the information for a primary phone number
-- This will use an inner join
\echo 
\echo -------------------------------------------- 
\echo -------------------------------------------- 
set search_path = joins, public;

\echo -- This is an example of an inner join.
\echo -- The output will be a linking of the customer to matching telno data only.
\echo -- This will work like set intersection.
\echo -- "   _     _    "
\echo -- "  /  \  /  \  "
\echo -- " /     X    \ "
\echo -- "|     |*|    |"
\echo -- " \     X    / "
\echo -- "  \  /  \  /  "
\echo -- "    -     -   "
select c.username,
       c.surname,
       c.forename,
       t.telno_type,
       t.telno
  from customer c
  join contact_info ci
    on ci.username = c.username
  join telno t
    on t.type = ci.contact_type
   and t.id = ci.contact_id
 where ci.is_primary;

-- Find all addresses and all customers attached to them
-- This will use a right join
select pg_sleep(10);
\echo 
\echo -------------------------------------------- 
\echo -- This query will return all addresses and any associated customer.
\echo -- This is an example of a right join.
\echo -- "   _     _    "
\echo -- "  /  \  /**\  "
\echo -- " /     X****\ "
\echo -- "|     |*|****|"
\echo -- " \     X****/ "
\echo -- "  \  /  \**/  "
\echo -- "    -     -   "
select c.username,
       c.surname,
       c.forename,
       a.id,
       a.addr_type,
       a.house_num,
       a.street_name,
       a.directional,
       a.street_type,
       a.city,
       a.state,
       a.postal_code,
       ci.is_primary
  from customer c
  join contact_info ci
    on ci.username = c.username
 right 
  join address a
    on a.type = ci.contact_type
   and a.id = ci.id;

-- verify the address table data
\echo 
\echo -- Verify the address table data.
select * 
  from address;
-- note that there are 2 rows in the address table

select pg_sleep(10);
-- Find any customers and any telnos associated with them
-- This will use a left join
\echo 
\echo -------------------------------------------- 
\echo -- This query will return all customers and any associated telno data.
\echo -- This is an example of a left join.
\echo -- "   _     _    "
\echo -- "  /**\  /  \  "
\echo -- " /*****X    \ "
\echo -- "|*****|*|    |"
\echo -- " \*****X    / "
\echo -- "  \**/  \  /  "
\echo -- "    -     -   "
select c.surname,
       c.forename,
       t.telno_type,
       t.telno,
       t.active
  from customer c
  left
  join contact_info ci
    on ci.username = c.username
   and ci.contact_type = 'TELNO' 
  left 
  join telno t
    on t.type = ci.contact_type
   and t.id = ci.contact_id;


-- Note that this version looks like it will do much of the same
-- but the result set will be different from moving the condidion 
-- from the join step to the where step
-- This will use a left join
select pg_sleep(10);
\echo 
\echo -------------------------------------------- 
\echo -- This query is mostly the same as the last left join
\echo -- query. But one of the conditions was moved from 
\echo -- the join clause to the where clause. Note the difference
\echo -- in the output. 
\echo -- You must take care where you put conditions as they will 
\echo -- affect output based on when they are evaluated.
\echo -- (Join time vs filter time)
select c.surname,
       c.forename,
       t.telno_type,
       t.telno,
       t.active
  from customer c
  left
  join contact_info ci
    on ci.username = c.username
  left 
  join telno t
    on t.type = ci.contact_type
   and t.id = ci.contact_id
 where ci.contact_type = 'TELNO';
\echo -- Note that the "Jack Human" record is missing.
-- note that the record for Jack Human is now missing. 
-- care must be taken as to where conditions are placed
-- in order to get the correct intended result

-- Finally, let's get a full permutation of customers and telnos
-- This will use a cross join (sometimes known as a full join)
select pg_sleep(10);
\echo 
\echo -------------------------------------------- 
\echo -- This query will output all permutations of customer and telno.
\echo -- This is an example of a cross join.
\echo -- "   _     _    "
\echo -- "  /**\  /**\  "
\echo -- " /*****X****\ "
\echo -- "|*****|*|****|"
\echo -- " \*****X****/ "
\echo -- "  \**/  \**/  "
\echo -- "    -     -   "
select c.username,
       c.surname,
       t.id as telno_id,
       t.telno
  from customer c
 cross
  join telno t;


\echo 
\echo -------------------------------------------- 
\echo -- To see the tables, use "\dt+"
\echo -- To describe the table structure, use "\d+ <table_name>"
\echo -- Explore the data in the tables using select statements.
\echo -- Try adding or deleting data to see changes in the sql statements

