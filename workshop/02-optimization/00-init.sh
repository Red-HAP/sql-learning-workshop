#!/usr/bin/env sh
psql -d sql_workshop -U postgres -e -f ./000-init.sql
gzip -dc ./001-pod_info_data.sql.gz | psql -d sql_workshop -U postgres $@
psql -d sql_workshop -U postgres -f ./002-distinct-values.sql
exit $?

