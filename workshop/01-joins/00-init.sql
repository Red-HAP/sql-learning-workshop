-- create joins schema
\echo 
\echo -------------------------------------------- 
\echo -------------------------------------------- 
\echo -- Creating schema "joins"
create schema joins;

-- set search path
\echo 
\echo -------------------------------------------- 
\echo -- Setting search path.
set search_path = joins, public;

-- create a suite of tables for a user and the user's information
\echo 
\echo -------------------------------------------- 
\echo -- Creating an app_user table
create table if not exists "app_user" (
    username text primary key,
    password text not null check (password != ''),
    created timestamptz not null default now(),
    updated timestamptz not null default now(),
    active boolean not null default true
);
comment on table app_user is 'Credentials for a user';

select pg_sleep(2);
-- create a customer table. Primary keys can also be foreign keys
\echo 
\echo -------------------------------------------- 
\echo -- Creating a customer table that will 1:1 link to the user table.
create table if not exists customer (
    username text primary key references app_user (username) on delete cascade on update cascade,
    surname text not null,
    forename text not null,
    created timestamptz not null default now(),
    updated timestamptz not null default now(),
    active boolean not null default true
);
comment on table customer is 'Customer name information';
comment on column customer.username is 'Link to app_user.username';

select pg_sleep(2);
-- create a mapping table for contact information
\echo 
\echo -------------------------------------------- 
\echo -- Create a mapping table that will map to the customer table directly 
\echo -- via a foreign key and will have weak references to contact type tables
\echo -- using a (thing_type, thing_id) link
create table if not exists contact_info (
    id serial primary key,
    username text references customer (username) on delete cascade,
    contact_type text not null,
    contact_id integer not null,
    is_primary boolean not null default false,
    constraint unique_contact unique (username, contact_type, contact_id)
);
comment on table contact_info is 'Map contact information to a customer';
comment on column contact_info.contact_type is 'Identify the table to which contact_id is linked';
comment on column contact_info.contact_id is 'Primary key of linked table from type';
comment on column contact_info.username is 'Link to customer table';

select pg_sleep(2);
\echo 
\echo -------------------------------------------- 
\echo -- Create a table of unique email addresses
create table if not exists email_address (
    id serial primary key,
    type text generated always as ('EMAIL') stored,
    email_address text not null,
    active boolean not null default true,
    created timestamptz not null default now(),
    updated timestamptz not null default now(),
    constraint unique_email unique (email_address)
);
comment on table email_address is 'Store unique email addresses';

select pg_sleep(2);
\echo 
\echo -------------------------------------------- 
\echo -- Create a table of unique telephone numbers
create table if not exists telno (
    id serial primary key,
    type text generated always as ('TELNO') stored,
    telno_type text not null default 'mobile',
    telno text not null,
    active boolean not null default true,
    created timestamptz not null default now(),
    updated timestamptz not null default now(),
    constraint unique_telno unique (telno)
);
comment on table telno is 'Store unique telephone numbers';

select pg_sleep(2);
\echo 
\echo -------------------------------------------- 
\echo -- Create a table of unique addresses
create table if not exists address (
    id serial primary key,
    type text generated always as ('ADDRESS') stored,
    addr_type text not null,
    house_num text not null default '',
    street_name text not null default '',
    directional text not null default '',
    street_type text not null default '',
    addr_2 text not null default '',
    addr_3 text not null default '',
    city text not null default '',
    county text not null default '',
    state text not null default '',
    postal_code text not null default '',
    attention text not null default '',
    constraint unique_address unique (addr_type, house_num, street_name, directional, street_type, addr_2, addr_3, city, county, state, postal_code)
);
comment on table address is 'Store unique addresses';

select pg_sleep(2);
\echo 
\echo -------------------------------------------- 
\echo -- Creating user records
insert 
  into app_user (username, password) 
values 
('eek', md5('eek')),
('ook' ,md5('ook'));

select pg_sleep(2);
-- This may be frowned upon as a slight abuse...
-- But it shows what you can do with CTEs
\echo 
\echo -------------------------------------------- 
\echo -- Now creating all other information within the same transaction
\echo -- utilizing CTEs
with new_customer as (
insert into customer (surname, forename, username)
values
('Pickbooger', 'Henry', 'eek'),
('Human', 'Jack', 'ook')
returning *
),
new_addresses as (
insert into address (
    addr_type,
    house_num,
    street_name,
    street_type,
    addr_2,
    city,
    state,
    postal_code
)
values 
(
  'house',
  '1313',
  'Mockingbird',
  'Ln',
  '',
  'Spookville',
  'IL',
  '00001'
),
(
  'dorm',
  '100',
  'Eek',
  'Ct',
  '#40',
  'Sillyville',
  'FL',
  '00002'
)
returning *
),
new_telno as (
insert into telno (telno) 
select '00055'::text || lpad(x::text, 5, '0')
  from generate_series(1, 99999, 5) as x
returning *
),
limit_new_telno as (
select *
  from new_telno
  limit 3
)
insert 
  into contact_info (
      username,
      contact_type,
      contact_id,
      is_primary
  )
select c.username,
       x.type,
       x.id,
       true
  from new_addresses x
 cross
  join new_customer c
 where x.addr_type = 'house'
   and c.surname = 'Pickbooger'
union
select c.username,
       x.type,
       x.id,
       (x.id = 1)::boolean
  from limit_new_telno x
 cross
  join new_customer c
 where x.telno_type = 'mobile'
   and c.surname = 'Pickbooger';


