#!/usr/bin/env bash

OUTFILE=./workshop/__init_all.sql
rm -f $OUTFILE

docker exec -it ws_db psql -d postgres -U postgres -c "drop database sql_workshop;"

for sqlfile in $(find ./workshop -name '*init.sql' | sort)
do
    sed -e 's/select pg_sleep\(.*\);//g' ${sqlfile} >>${OUTFILE}
done

docker exec -it ws_db psql -d postgres -U postgres -f /opt/workshop/__init_all.sql
docker exec -it ws_db /opt/workshop/02-optimization/00-load.sh

rm -f $OUTFILE
