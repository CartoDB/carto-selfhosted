\ir 01_environment.sql

CREATE USER :db_user with encrypted password :'db_passwd';
GRANT :db_user TO :session_user;

CREATE DATABASE :db_name OWNER :db_user;