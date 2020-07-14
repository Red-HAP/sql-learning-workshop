#!/usr/bin/env python3

import csv
import faker
import hashlib
import sys

try:
    MAX_RECS = int(sys.argv[1])
except:
    MAX_RECS = 10000

FAKER = faker.Faker()

with open("app_user_data.csv", "wt") as outfile:
    writer = csv.DictWriter(outfile, ['username', 'password'])
    writer.writeheader()
    for _ in range(MAX_RECS):
        username = FAKER.name()
        writer.writerow({
            'username': username,
            'password': hashlib.md5(username.encode('utf-8')).hexdigest()
        })

print("Done.")
