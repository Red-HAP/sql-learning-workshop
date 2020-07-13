-- DDL: Create a new database
\echo 
\echo -------------------------------------------- 
\echo -------------------------------------------- 
\echo -- This is a DDL that will create a database.
create database sql_workshop;

-- This is a psql command. 
-- Connect to the new database as current user
\echo 
\echo -------------------------------------------- 
\echo -- Now connecting to the "sql_workshop" database. This is a special psql command.
\c sql_workshop

\echo
\echo -------------------------------------------- 
\echo Make sure monitoring extension is enabled.
create extension if not exists pg_stat_statements;


-- DDL: Create a table
\echo 
\echo -------------------------------------------- 
\echo -- DDL statement: Create a table called "items".
create table items (
    item_type text not null,
    item_name text not null,
    quantitiy int not null,
    created timestamptz not null default now(),
    updated timestamptz not null default now()
);

-- DDL: Create a new schema
select pg_sleep(5);
\echo 
\echo -------------------------------------------- 
\echo -- DDL statement to create a schema named "overview". You can list schemata in psql by using "\dn".
create schema overview;

-- DDL: Create a table
\echo 
\echo -------------------------------------------- 
\echo -- DDL statement to create a table in the overview schema.
create table overview.user (
    id serial primary key,
    surname text not null,
    forename text not null,
    email_address text not null,
    constraint user_unique_email unique (email_address)
);

-- DDL: Let's document!
select pg_sleep(5);
\echo 
\echo -------------------------------------------- 
\echo -- DDL adding comments. PostgreSQL can store comments on various objects.
comment on table overview.user is 'Holds the user information';
comment on column overview.user.email_address is 'This must be unique as it is the username';

-- DML: insert one user
select pg_sleep(5);
\echo 
\echo -------------------------------------------- 
\echo -- DML inserting one record.
insert into overview.user (surname, forename, email_address)
values ('Who', 'Doctor', 'doctor@gallefrey.fake');

-- DML: insert multiple users
select pg_sleep(5);
\echo 
\echo -------------------------------------------- 
\echo -- DML with one insert statement inserting multiple records.
insert into overview.user (surname, forename, email_address)
values
('Chrichton', 'John', 'jchrichton@iasa.fake'),
('Williams', 'Ash', 'boomstick@cabininthewoods.fake'),
('Ochako', 'Uraraka', 'uravity@ua.fake');

\echo 
\echo -------------------------------------------- 
\echo -- Execute these psql commands yourself!
\echo -- Get session connection information "\conninfo"
\echo -- List databases: "\l"
\echo -- List schemata (namespaces) "\dn"
\echo -- List tables in the current schema "\dt". Can you explain the output?
\echo -- List tables in a specified schema "\dt overview.*".
\echo -- Describe a table (show its definition) "\d overview.user".
\echo -- Get a full table listing "\d+ overview.user".
