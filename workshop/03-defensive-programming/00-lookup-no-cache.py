#!/usr/bin/env python3

import datetime
import psycopg2
from psycopg2.extras import NamedTupleCursor

def connect(db_url):
    return psycopg2.connect(db_url, cursor_factory=NamedTupleCursor)

def lookup_telno(conn, telno):
    sql = """
select exists 
       (
           select 1 
             from joins.telno
            where telno = %s
       )::boolean as telno_exists;
"""
    with conn.cursor() as cur:
        cur.execute(sql, [telno])
        res = cur.fetchone()
    
    return res.telno_exists if res else False

def validate_telnos(conn):
    start = datetime.datetime.now()
    for _ in range(10):
        for num in range(25000):
            telno = f"00055{num:>05}"
            lookup_telno(conn, telno)
    end = datetime.datetime.now()
    print(f"Total time: {(end - start).total_seconds()} seconds")

with connect('postgresql://postgres:postgres@ws-db:5432/sql_workshop') as conn:
    validate_telnos(conn)

