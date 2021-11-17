\ir 01_environment.sql
\c :db_name

INSERT INTO providers VALUES 
  ('bigquery', 'bigquery provider'), 
  ('snowflake', 'snowflake provider'), 
  ('postgres', 'postgres provider'), 
  ('redshift', 'redshift provider');