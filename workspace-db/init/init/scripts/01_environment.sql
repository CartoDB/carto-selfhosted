\set session_user `echo ${POSTGRES_LOGIN_USER:-postgres}`
\set db_name `echo $WORKSPACE_POSTGRES_DB`
\set db_user `echo $WORKSPACE_POSTGRES_USER`
\set db_passwd `echo $WORKSPACE_POSTGRES_PASSWORD`
