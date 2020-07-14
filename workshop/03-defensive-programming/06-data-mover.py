#!/usr/bin/env python3

import datetime
import os
import psycopg2
from psycopg2.extras import NamedTupleCursor


LIMIT = 5000


def connect(db_url):
    conn = psycopg2.connect(db_url, cursor_factory=NamedTupleCursor)
    conn.autocommit = True
    with conn.cursor() as cur:
        cur.execute("set search_path = optimization, public")
    return conn


def get_counts_by_namespace(conn):
    sql = """
select namespace, 
       count(*) as record_count
  from pod_info
 group 
    by 1;
"""
    with conn.cursor() as cur:
        cur.execute(sql)
        res = {rec.namespace: rec.record_count for rec in cur}
    
    return res


def create_destination_table(conn, target_namespace):
    dest_table = f"pod_info_{target_namespace.lower().replace('-', '').replace(' ', '')}"
    sql = f"""
create table "{dest_table}" (
    like pod_info including all
);
"""
    with conn.cursor() as cur:
        cur.execute(sql)
    
    return dest_table

def move_namespace_data(conn, target_namespace):
    dest_table = create_destination_table(conn, target_namespace)
    sql = f"""
with targets as (
delete
  from pod_info
 where id in (
                select id
                  from pod_info
                 where namespace = %(t_ns)s
                   for update
                  skip locked
                 limit %(lim)s
              )
returning *
)
insert 
  into "{dest_table}" (id, cluster_id, resource_id, namespace, node, pod, pod_type, usage_start, stats, labels)
select id, cluster_id, resource_id, namespace, node, pod, pod_type, usage_start, stats, labels
  from targets;
"""
    values = {
        't_ns': target_namespace,
        'lim': LIMIT
    }
    iteration = 0
    start = datetime.datetime.now()
    with conn.cursor() as cur:
        while True:
            iteration += 1
            cur.execute(sql, values)
            rows = cur.rowcount
            if rows == 0:
                break
            print(f"Iteration: {iteration}; Moved {rows} records", flush=True)
    end = datetime.datetime.now()
    print(f"Copy took {(end - start).total_seconds()} seconds")
    print(flush=True)

    return dest_table

def count_table(conn, tablename):
    sql = f"""
select count(*) as record_count
  from "{tablename}";
"""
    with conn.cursor() as cur:
        cur.execute(sql)
        res = cur.fetchone().record_count
    
    return res

def print_ns_counts(ns_counts):
    for ns in sorted(ns_counts):
        print(f"{ns}: {ns_counts[ns]}")
    print(flush=True)

def mover():
    with connect('postgresql://postgres:postgres@ws-db:5432/sql_workshop') as conn:
        ns_counts = get_counts_by_namespace(conn)
        print_ns_counts(ns_counts)
        target_namespace = next(iter(ns_counts))
        print(f"Moving namespace {target_namespace} records to their own table.")
        dest_table = move_namespace_data(conn, target_namespace)
        dest_count = count_table(conn, dest_table)
        print(f"{os.linesep}Destination table = {dest_table}; Count = {dest_count}{os.linesep}")
        print("Remaining namespaces:")
        print_ns_counts(get_counts_by_namespace(conn))

mover()
print("Done.")
