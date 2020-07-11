#!/usr/bin/env python3
import faker
import json
import sys

import psycopg2
from psycopg2.extras import Json


FAKER = faker.Faker()
NUM_RECORDS = 500000

pod_stats_keys = ['cpu_hours', 'memory_gigs_used', 'memory_gigs_requested']
storage_stats_keys = ['storage_gigs_used', 'storage_gigs_requested']

cluster_ids = [FAKER.ean13() for _ in range(5)]
resource_ids = [FAKER.ean13() for _ in range(5)]
nodes = [FAKER.ean13() for _ in range(10)]
pods = [FAKER.ean13() for _ in range(20)]
namespaces = [FAKER.word() for _ in range(10)]
label_keys = [FAKER.word() for _ in range(5)]
label_values = [FAKER.word() for _ in range(5)]
pod_types = ['POD', 'STORAGE']

record_tmpl = {
    'cluster_id': None,
    'resource_id': None,
    'namespace': None,
    'node': None,
    'pod': None,
    'pod_type': None,
    'stats': None,
    'pod_labels': None
}


def db_json_dumps(d):
    """
    Dump json data using str as the default transform
    Args:
        d (dict) : data
    Returns:
        str : json-formatted string form of d
    """
    return json.dumps(d, default=str)


def json_adapter(d):
    """
    Set the psycopg2 Json class for dict data using db_json_dumps as the dump function
    Args:
        d (dict) : data
    Returns:
        Json : data (d) in a Json instance so that the psycopg2 driver can process it
    """
    return Json(d, dumps=db_json_dumps)


def make_record():
    ix = FAKER.random_int(0, len(cluster_ids) - 1)
    rec = record_tmpl.copy()
    rec['cluster_id'] = cluster_ids[ix]
    rec['resource_id'] = resource_ids[ix]
    rec['namespace'] = namespaces[FAKER.random_int(0, len(namespaces) - 1)]
    rec['node'] = nodes[FAKER.random_int(0, len(nodes) - 1)]
    rec['pod'] = pods[FAKER.random_int(0, len(pods) - 1)]
    rec['pod_type'] = pod_types[FAKER.random_int(0, len(pod_types) - 1)]

    if rec['pod_type'] == 'POD':
        stats_keys = pod_stats_keys
    else:
        stats_keys = storage_stats_keys
    stats = dict(zip(stats_keys, [abs(FAKER.pydecimal()) for _ in range(len(stats_keys))]))
    rec['stats'] = json_adapter(stats)

    no_stats_probability = FAKER.random_int(0, 99)
    if no_stats_probability <= 4 or no_stats_probability >= 94:
        #print(no_stats_probability, file=sys.stderr)
        rec['labels'] = json_adapter({})
    else:
        num_labels = FAKER.random_int(0, len(label_keys) - 1)
        ix = 0
        used_ix = set()
        pl_keys = []
        while ix < num_labels:
            i = FAKER.random_int(0, len(label_keys) - 1)
            if i not in used_ix:
                used_ix.add(i)
                pl_keys.append(label_keys[i])
                ix += 1

        ix = 0
        used_ix = set()
        pl_vals = []
        while ix < num_labels:
            i = FAKER.random_int(0, len(label_keys) - 1)
            if i not in used_ix:
                used_ix.add(i)
                pl_vals.append(label_values[i])
                ix += 1
        labels = dict(zip(pl_keys, pl_vals))
        rec['labels'] = json_adapter(labels)
        #print(_, no_stats_probability, labels, file=sys.stderr)
    
    if _ > 0 and (_ % 10000 == 0):
        print(_, file=sys.stderr)

    return rec


conn = psycopg2.connect("postgresql://postgres:postgres@localhost:15444/sql_workshop")
with conn.cursor() as cur:
    cur.execute("set search_path = optimization, public;")
    for _ in range(NUM_RECORDS):
        SQL = """
insert
  into pod_info (
      cluster_id,
      resource_id,
      "namespace",
      node,
      pod,
      pod_type,
      stats,
      labels
  )
values (
    %(cluster_id)s,
    %(resource_id)s,
    %(namespace)s,
    %(node)s,
    %(pod)s,
    %(pod_type)s,
    %(stats)s,
    %(labels)s
);
"""
        cur.execute(SQL, make_record())

conn.commit()

