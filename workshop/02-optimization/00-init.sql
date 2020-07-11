-- create schema
create schema optimization;

-- set schema path
set search_path = optimization, public;

-- make some tables
create table pod_info (
    id serial primary key,
    cluster_id text not null,
    resource_id text not null,
    "namespace" text not null,
    node text not null,
    pod text not null,
    pod_type text not null,
    stats jsonb not null,
    labels jsonb not null default '{}'::jsonb
);

create index ix_pod_namespace on pod_info (namespace);

