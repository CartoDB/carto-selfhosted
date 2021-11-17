\ir 01_environment.sql
\c :db_name

-- Accounts

CREATE TABLE accounts(
  id TEXT PRIMARY KEY,
  name TEXT UNIQUE,
  config JSONB
);
ALTER TABLE accounts OWNER TO :db_user;

-- Users

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  account_id TEXT REFERENCES accounts(id) ON DELETE CASCADE
);
ALTER TABLE users OWNER TO :db_user;

-- Providers

CREATE TABLE providers (
  id TEXT PRIMARY KEY,
  name TEXT
);
ALTER TABLE providers OWNER TO :db_user;

-- Connections

CREATE TABLE connections(
  id serial PRIMARY KEY,
  name TEXT,
  provider_id TEXT REFERENCES providers(id),
  config JSONB,
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_name UNIQUE(name, account_id)
);
ALTER TABLE connections OWNER TO :db_user;

CREATE INDEX connections_provider_id_idx ON connections(provider_id);

-- Listed apps

CREATE TABLE listed_apps  (
  id serial PRIMARY KEY,
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  title text,
  description text,
  url text,
  thumbnail_url text,
  account_id TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
ALTER TABLE listed_apps OWNER TO :db_user;
