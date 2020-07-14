#!/usr/bin/env python3
import csv
import datetime
from operator import itemgetter
import os
import psycopg2
from psycopg2.extras import NamedTupleCursor
import sys

MAX_ROWS = 100
MAX_COLS = 2

GET_USER_VALS = itemgetter('username', 'password')


def connect(db_url):
    return psycopg2.connect(db_url, cursor_factory=NamedTupleCursor)

def append_user_record(recs, user):
    recs.extend(GET_USER_VALS(user))

def multi_insert_user(conn, recs):
    if len(recs) == 0:
        return
    
    # recs is a single-dimension list. To make it work for 
    # the record, we have to break it up in to sets of 2 values
    # which is how recs was constructed.
    # This is necessary because we are using positional placeholders.
    # If we had used named placeholders, we'd have to come up with a unique
    # key for every value needing to be inserted. And that is a solution
    # that some ORMs use under the hood.
    values = ',\n'.join(['(%s,%s)'] * (len(recs) // MAX_COLS))
    sql = f"""
insert into joins.app_user (username, password)
values {values};
"""
    with conn.cursor() as cur:
        cur.execute(sql, recs)

def get_users(conn):
    sql = """
select username
  from joins.app_user;
"""
    with conn.cursor() as cur:
        cur.execute(sql)
        return set(cur.fetchall())

# This func just removes what we inserted so we
# can run the same file multiple times.
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
    num_recs = inserted = insert_calls = 0
    with open(filename, "rt") as infile, \
         connect('postgresql://postgres:postgres@ws-db:5432/sql_workshop') as conn:
        existing_users = get_users(conn)
        new_users = set()
        reader = csv.DictReader(infile, quoting=csv.QUOTE_MINIMAL)
        start = datetime.datetime.now()
        recs = []
        for rec in reader:
            num_recs += 1
            if rec['username'] not in existing_users:
                append_user_record(recs, rec)
                existing_users.add(rec['username'])
                new_users.add(rec['username'])
                inserted += 1
                if inserted > 0 and (inserted % MAX_ROWS) == 0:
                    insert_calls += 1
                    multi_insert_user(conn, recs)
                    recs = []
        insert_calls += 1
        multi_insert_user(conn, recs)
        conn.commit()
        end = datetime.datetime.now()
        print(f"Inserted {len(new_users)} users from {num_recs} records (num insert calls = {insert_calls})")
        print(f"Total time: {(end - start).total_seconds()} seconds")
        delete_inserted_records(conn, list(new_users))

process_file()

print("Done.")
    

