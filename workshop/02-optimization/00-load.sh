#!/usr/bin/env sh
if [ ! -f ./001-pod_info_data.sql.gz ]
then
    cd /opt/workshop/02-optimization
fi
gzip -dc ./001-pod_info_data.sql.gz | psql -d sql_workshop -U postgres $@
exit $?
