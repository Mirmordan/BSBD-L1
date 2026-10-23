-- 05_audit_login.sql
-- Функция логирования
CREATE OR REPLACE FUNCTION audit.log_login_event()
RETURNS event_trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'audit, pg_catalog'
AS $$
BEGIN
    -- Пишем данные подключения
    INSERT INTO audit.login_log (
        login_time,
        username,
        client_ip,
        application_name,
        session_id
    )
    VALUES (
        now(),
        session_user,
        inet_client_addr(),
        current_setting('application_name', true),
        pg_backend_pid()::text
    );
END;
$$;

-- Права
ALTER FUNCTION audit.log_login_event() OWNER TO audit_owner;
REVOKE ALL ON FUNCTION audit.log_login_event() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION audit.log_login_event() TO PUBLIC;

-- Триггер
DROP EVENT TRIGGER IF EXISTS trg_log_login;
CREATE EVENT TRIGGER trg_log_login
ON login
EXECUTE FUNCTION audit.log_login_event();
