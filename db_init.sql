-- EvolutionGo Database Initialization for PostgreSQL 18
-- Segregates authentication/Noise protocol keys from application messaging
SET client_min_messages = WARNING;

SELECT format('CREATE DATABASE evogo_auth OWNER %I', COALESCE(NULLIF(:'app_user', ''), current_user))
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'evogo_auth')\gexec

SELECT format('CREATE DATABASE evogo_users OWNER %I', COALESCE(NULLIF(:'app_user', ''), current_user))
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'evogo_users')\gexec

SELECT format('ALTER DATABASE evogo_auth OWNER TO %I', COALESCE(NULLIF(:'app_user', ''), current_user))\gexec
SELECT format('ALTER DATABASE evogo_users OWNER TO %I', COALESCE(NULLIF(:'app_user', ''), current_user))\gexec

-- Anti-Starvation Shield: Hard-caps & Idle Session Reaping (Issue #106 / #118)
ALTER DATABASE evogo_auth WITH CONNECTION LIMIT 4;
ALTER DATABASE evogo_users WITH CONNECTION LIMIT 4;
ALTER DATABASE evogo_auth SET idle_session_timeout = '2min';
ALTER DATABASE evogo_users SET idle_session_timeout = '2min';
ALTER DATABASE evogo_auth SET idle_in_transaction_session_timeout = '30s';
ALTER DATABASE evogo_users SET idle_in_transaction_session_timeout = '30s';

\c evogo_auth;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
SELECT format('ALTER SCHEMA public OWNER TO %I', COALESCE(NULLIF(:'app_user', ''), current_user))\gexec
SELECT format('GRANT ALL PRIVILEGES ON SCHEMA public TO %I', COALESCE(NULLIF(:'app_user', ''), current_user))\gexec

\c evogo_users;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
SELECT format('ALTER SCHEMA public OWNER TO %I', COALESCE(NULLIF(:'app_user', ''), current_user))\gexec
SELECT format('GRANT ALL PRIVILEGES ON SCHEMA public TO %I', COALESCE(NULLIF(:'app_user', ''), current_user))\gexec
