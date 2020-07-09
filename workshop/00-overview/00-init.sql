-- DDL: Create a new database
create database sql_workshop;

-- This is a psql command. 
-- Connect to the new database as current user
\c sql_workshop

-- DDL: Create a table
create table items (
    item_type text not null,
    item_name text not null,
    quantitiy int not null,
    created timestamptz not null default now(),
    updated timestamptz not null default now()
);

-- DDL: Create a new schema
create schema overview;

-- DDL: Create a table
create table overview.user (
    id serial primary key,
    surname text not null,
    forename text not null,
    email_address text not null,
    constraint user_unique_email unique (email_address),
);

-- DDL: Let's document!
comment on table overview.user is 'Holds the user information';
comment on column overview.user.email_address is 'This must be unique as it is the username';

-- DML: insert one user
insert into overview.user (surname, forename, email_address)
values ('Who', 'Doctor', 'doctor@gallefrey.fake');

-- DML: insert multiple users
insert into overview.user (surname, forename, email_address)
values
('Chrichton', 'John', 'jchrichton@iasa.fake'),
('Williams', 'Ash', 'boomstick@cabininthewoods.fake'),
('Ochako', 'Uraraka', 'uravity@ua.fake');

-- Execute these psql commands yourself!
-- List databases
-- \l
-- List schemata (namespaces)
-- \dn
-- List tables in the current schema
-- \dt
-- Can you explain the output?
-- List tables in a specified schema
-- \dt+ overview.*
-- List a table definition
-- \d overview.user
-- Get a full table listing
-- \d+ overview.user
