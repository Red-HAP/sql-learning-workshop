#!/usr/bin/env sh
psql -d sql_workshop -U postgres -e -f ./00-init.sql
gzip -dc ./00-pod_info_data.sql.gz | psql -d sql_workshop -U postgres $@
psql -d sql_workshop -U postgres -f ./01-distinct-values.sql
exit $?

