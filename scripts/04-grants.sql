-- 04_grants.sql

-- Отзыв у PUBLIC
REVOKE ALL ON DATABASE vms FROM PUBLIC;

REVOKE ALL ON SCHEMA app FROM PUBLIC;
REVOKE ALL ON SCHEMA ref FROM PUBLIC;
REVOKE ALL ON SCHEMA audit FROM PUBLIC;
REVOKE ALL ON SCHEMA stg FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM PUBLIC;

-- CONNECT для ролей
GRANT CONNECT ON DATABASE vms TO
    app_owner,
    app_reader,
    app_writer,
    auditor,
    audit_owner,
    ddl_admin,
    dml_admin,
    security_admin,
    u_reader,
    u_writer,
    u_ddl,
    u_dml,
    u_auditor,
    u_sec;

-- Владельцы схем
ALTER SCHEMA app OWNER TO app_owner;
ALTER SCHEMA ref OWNER TO app_owner;
ALTER SCHEMA stg OWNER TO app_owner;
-- audit принадлежит отдельной NOLOGIN-роли, чтобы security_admin не мог писать в журнал
ALTER SCHEMA audit OWNER TO audit_owner;

-- Владельцы существующих таблиц
ALTER TABLE ref.event_types OWNER TO app_owner;
ALTER TABLE ref.device_types OWNER TO app_owner;
ALTER TABLE app.employees OWNER TO app_owner;
ALTER TABLE app.login_users OWNER TO app_owner;
ALTER TABLE app.devices OWNER TO app_owner;
ALTER TABLE app.channels OWNER TO app_owner;
ALTER TABLE app.streams OWNER TO app_owner;
ALTER TABLE app.recordings OWNER TO app_owner;
ALTER TABLE app.events OWNER TO app_owner;
ALTER TABLE app.roles OWNER TO app_owner;
ALTER TABLE app.user_roles OWNER TO app_owner;
ALTER TABLE stg.recordings_raw OWNER TO app_owner;
ALTER TABLE audit.login_log OWNER TO audit_owner;

-- Владельцы последовательностей
ALTER SEQUENCE ref.event_types_id_seq OWNER TO app_owner;
ALTER SEQUENCE ref.device_types_id_seq OWNER TO app_owner;
ALTER SEQUENCE app.employees_id_seq OWNER TO app_owner;
ALTER SEQUENCE app.login_users_id_seq OWNER TO app_owner;
ALTER SEQUENCE app.devices_id_seq OWNER TO app_owner;
ALTER SEQUENCE app.channels_id_seq OWNER TO app_owner;
ALTER SEQUENCE app.streams_id_seq OWNER TO app_owner;
ALTER SEQUENCE app.recordings_id_seq OWNER TO app_owner;
ALTER SEQUENCE app.events_id_seq OWNER TO app_owner;
ALTER SEQUENCE app.roles_id_seq OWNER TO app_owner;
ALTER SEQUENCE stg.recordings_raw_id_seq OWNER TO app_owner;
ALTER SEQUENCE audit.login_log_id_seq OWNER TO audit_owner;

-- USAGE на схемы
GRANT USAGE ON SCHEMA app TO app_owner, app_reader, app_writer, ddl_admin, dml_admin;
GRANT USAGE ON SCHEMA ref TO app_owner, app_reader, app_writer, ddl_admin, dml_admin;
GRANT USAGE ON SCHEMA stg TO app_owner, app_writer, dml_admin;
GRANT USAGE ON SCHEMA audit TO auditor, security_admin;

-- app_reader: только чтение
GRANT SELECT ON ALL TABLES IN SCHEMA app TO app_reader;
GRANT SELECT ON ALL TABLES IN SCHEMA ref TO app_reader;

-- app_writer: чтение и запись
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO app_writer;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ref TO app_writer;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA stg TO app_writer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA app TO app_writer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA ref TO app_writer;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA stg TO app_writer;

-- dml_admin: массовые операции
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA app TO dml_admin;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA ref TO dml_admin;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA stg TO dml_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA app TO dml_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA ref TO dml_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA stg TO dml_admin;

-- ddl_admin: право создавать объекты
GRANT CREATE ON SCHEMA app TO ddl_admin;
GRANT CREATE ON SCHEMA ref TO ddl_admin;
GRANT CREATE ON SCHEMA stg TO ddl_admin;

-- auditor: чтение audit
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO auditor;

-- security_admin: audit только на чтение. Владелец схемы/таблиц — audit_owner.
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO security_admin;

-- DEFAULT PRIVILEGES: app_owner, схема app
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    GRANT SELECT ON TABLES TO app_reader;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_writer;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    GRANT USAGE, SELECT ON SEQUENCES TO app_writer;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    GRANT USAGE, SELECT ON SEQUENCES TO dml_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO dml_admin;

-- DEFAULT PRIVILEGES: app_owner, схема ref
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA ref
    REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA ref
    REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA ref
    GRANT SELECT ON TABLES TO app_reader;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA ref
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_writer;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA ref
    GRANT USAGE, SELECT ON SEQUENCES TO app_writer;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA ref
    GRANT USAGE, SELECT ON SEQUENCES TO dml_admin;

-- DEFAULT PRIVILEGES: app_owner, схема stg
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA stg
    REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA stg
    REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA stg
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_writer;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA stg
    GRANT USAGE, SELECT ON SEQUENCES TO app_writer;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA stg
    GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE ON TABLES TO dml_admin;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA stg
    GRANT USAGE, SELECT ON SEQUENCES TO dml_admin;

-- DEFAULT PRIVILEGES: audit_owner, схема audit
ALTER DEFAULT PRIVILEGES FOR ROLE audit_owner IN SCHEMA audit
    REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE audit_owner IN SCHEMA audit
    REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE audit_owner IN SCHEMA audit
    REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE audit_owner IN SCHEMA audit
    REVOKE ALL ON TYPES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE audit_owner IN SCHEMA audit
    GRANT SELECT ON TABLES TO auditor;
ALTER DEFAULT PRIVILEGES FOR ROLE audit_owner IN SCHEMA audit
    GRANT SELECT ON TABLES TO security_admin;

-- security_admin: админ по ролям и привилегиям 
GRANT app_reader TO security_admin WITH INHERIT FALSE, SET FALSE, ADMIN TRUE;
GRANT app_writer TO security_admin WITH INHERIT FALSE, SET FALSE, ADMIN TRUE;
GRANT auditor    TO security_admin WITH INHERIT FALSE, SET FALSE, ADMIN TRUE;
GRANT ddl_admin  TO security_admin WITH INHERIT FALSE, SET FALSE, ADMIN TRUE;
GRANT dml_admin  TO security_admin WITH INHERIT FALSE, SET FALSE, ADMIN TRUE;