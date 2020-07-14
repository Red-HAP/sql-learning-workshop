#!/usr/bin/env python3
import csv
import datetime
import os
import psycopg2
from psycopg2.extras import NamedTupleCursor
import sys


def connect(db_url):
    return psycopg2.connect(db_url, cursor_factory=NamedTupleCursor)

def insert_user(conn, rec):
    sql = """
insert into joins.app_user (username, password)
values (%(username)s, %(password)s);
"""
    with conn.cursor() as cur:
        cur.execute(sql, rec)

def get_users(conn):
    sql = """
select username
  from joins.app_user;
"""
    with conn.cursor() as cur:
        cur.execute(sql)
        return set(cur.fetchall())

def delete_inserted_records(conn, new_users):
    sql = """
delete
  from joins.app_user
 where username = any(%s);
"""
    with conn.cursor() as cur:
        cur.execute(sql, [new_users])

def process_file():
    path = os.path.abspath(os.path.dirname(__file__))
    filename = os.path.join(path, 'app_user_data.csv')
    num_recs = 0
    with open(filename, "rt") as infile, \
         connect('postgresql://postgres:postgres@ws-db:5432/sql_workshop') as conn:
        existing_users = get_users(conn)
        new_users = set()
        reader = csv.DictReader(infile, quoting=csv.QUOTE_MINIMAL)
        start = datetime.datetime.now()
        for rec in reader:
            num_recs += 1
            if rec['username'] not in existing_users:
                insert_user(conn, rec)
                existing_users.add(rec['username'])
                new_users.add(rec['username'])
        conn.commit()
        end = datetime.datetime.now()
        print(f"Inserted {len(new_users)} users from {num_recs} records")
        print(f"Total time: {(end - start).total_seconds()} seconds")
        delete_inserted_records(conn, list(new_users))

process_file()

print("Done.")
    

