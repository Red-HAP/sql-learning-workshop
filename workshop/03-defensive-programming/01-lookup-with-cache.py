#!/usr/bin/env python3

import datetime
import psycopg2
from psycopg2.extras import NamedTupleCursor

CACHE = {}

def connect(db_url):
    return psycopg2.connect(db_url, cursor_factory=NamedTupleCursor)

def lookup_telno(conn, telno):
    if telno in CACHE:
        return CACHE[telno], 1
    else:
        sql = """
select exists 
       (
           select 1 
             from joins.telno
            where telno = %s
       )::boolean as telno_exists;
"""
        res = None
        with conn.cursor() as cur:
            cur.execute(sql, [telno])
            res = cur.fetchone()

        CACHE[telno] = (res and res.telno_exists)
        return CACHE[telno], 0

def validate_telnos(conn):
    cache_hits = 0
    total = 0
    exists = 0
    start = datetime.datetime.now()
    for _ in range(10):
        for num in range(25000):
            total += 1
            telno = f"00055{num:>05}"
            res = lookup_telno(conn, telno)
            exists += res[0]
            cache_hits += res[1]
    end = datetime.datetime.now()
    print(f"Total iterations {total}; cache hits {cache_hits}; db lookups {total - cache_hits}")
    print(f"Total time: {(end - start).total_seconds()} seconds")

with connect('postgresql://postgres:postgres@ws-db:5432/sql_workshop') as conn:
    validate_telnos(conn)

