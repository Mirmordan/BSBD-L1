-- Схемы
CREATE SCHEMA app;
CREATE SCHEMA ref;
CREATE SCHEMA audit;
CREATE SCHEMA stg;


-- ref
CREATE TABLE ref.event_types (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type VARCHAR(32) NOT NULL,
    description TEXT,
    CONSTRAINT event_types_type_unique UNIQUE (type),
    CONSTRAINT event_types_type_check CHECK (type <> '')
);

CREATE TABLE ref.device_types (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type VARCHAR(32) NOT NULL,
    description TEXT,
    CONSTRAINT device_types_type_unique UNIQUE (type),
    CONSTRAINT device_types_type_check CHECK (type <> '')
);


-- app: сотрудники
CREATE TABLE app.employees (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    email VARCHAR(254),
    phone VARCHAR(20),
    position VARCHAR(100),
    department VARCHAR(100),
    employee_number VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT employees_email_unique UNIQUE (email),
    CONSTRAINT employees_phone_unique UNIQUE (phone),
    CONSTRAINT employees_number_unique UNIQUE (employee_number),
    CONSTRAINT employees_last_name_check CHECK (last_name <> ''),
    CONSTRAINT employees_first_name_check CHECK (first_name <> '')
);

CREATE INDEX idx_employees_department ON app.employees (department);
CREATE INDEX idx_employees_last_name ON app.employees (last_name);


-- app: учётные записи
CREATE TABLE app.login_users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id BIGINT REFERENCES app.employees(id) ON DELETE SET NULL,
    username VARCHAR(32) NOT NULL,
    password_hash TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT login_users_username_unique UNIQUE (username),
    CONSTRAINT login_users_username_check CHECK (username <> '')
);

CREATE INDEX idx_login_users_employee ON app.login_users (employee_id);
CREATE INDEX idx_login_users_active ON app.login_users (is_active) WHERE is_active = true;


-- app: устройства
CREATE TABLE app.devices (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    device_type_id BIGINT NOT NULL REFERENCES ref.device_types(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_devices_device_type ON app.devices (device_type_id);


-- app: каналы
CREATE TABLE app.channels (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id BIGINT NOT NULL REFERENCES app.devices(id) ON DELETE CASCADE,
    number INTEGER NOT NULL,
    name VARCHAR(64),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT channels_device_number_unique UNIQUE (device_id, number),
    CONSTRAINT channels_number_check CHECK (number > 0)
);


-- app: потоки
CREATE TABLE app.streams (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    channel_id BIGINT NOT NULL REFERENCES app.channels(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_streams_channel ON app.streams (channel_id);


-- app: архив записей
CREATE TABLE app.recordings (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stream_id BIGINT NOT NULL REFERENCES app.streams(id),
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    file_path TEXT NOT NULL,
    size_bytes BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT recordings_interval_check CHECK (ended_at IS NULL OR ended_at > started_at),
    CONSTRAINT recordings_size_check CHECK (size_bytes IS NULL OR size_bytes >= 0)
);

CREATE INDEX idx_recordings_stream_time ON app.recordings (stream_id, started_at);
CREATE INDEX idx_recordings_started_at ON app.recordings (started_at);


-- app: события
CREATE TABLE app.events (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_type_id BIGINT NOT NULL REFERENCES ref.event_types(id),
    device_id BIGINT REFERENCES app.devices(id),
    channel_id BIGINT REFERENCES app.channels(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_events_event_type ON app.events (event_type_id);
CREATE INDEX idx_events_created_at ON app.events (created_at);


-- app: роли
CREATE TABLE app.roles (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(32) NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    CONSTRAINT roles_code_unique UNIQUE (code),
    CONSTRAINT roles_code_check CHECK (code <> '')
);


-- app: связь учётка-роль
CREATE TABLE app.user_roles (
    user_id BIGINT NOT NULL REFERENCES app.login_users(id) ON DELETE CASCADE,
    role_id BIGINT NOT NULL REFERENCES app.roles(id) ON DELETE CASCADE,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id)
);

CREATE INDEX idx_user_roles_role ON app.user_roles (role_id);


-- stg
CREATE TABLE stg.recordings_raw (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source TEXT NOT NULL,
    payload jsonb NOT NULL,
    batch_id uuid NOT NULL,
    received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    processed_at TIMESTAMPTZ,
    error TEXT,
    CONSTRAINT recordings_raw_source_check CHECK (source <> '')
);

CREATE INDEX idx_recordings_raw_unprocessed ON stg.recordings_raw (received_at) WHERE processed_at IS NULL;
CREATE INDEX idx_recordings_raw_batch ON stg.recordings_raw (batch_id);


-- audit
CREATE TABLE audit.login_log (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    username TEXT NOT NULL,
    client_ip INET,
    application_name TEXT,
    session_id TEXT,
    CONSTRAINT login_log_username_check CHECK (username <> '')
);

CREATE INDEX idx_login_log_time ON audit.login_log (login_time DESC);
CREATE INDEX idx_login_log_username ON audit.login_log (username);


-- Комментарии
COMMENT ON SCHEMA app IS 'Бизнес-данные';
COMMENT ON SCHEMA ref IS 'Справочники';
COMMENT ON SCHEMA audit IS 'Журналы аудита';
COMMENT ON SCHEMA stg IS 'Staging: временные и обслуживающие таблицы';

COMMENT ON TABLE app.employees IS 'Сотрудники (люди)';
COMMENT ON TABLE app.login_users IS 'Учётные записи для входа';
COMMENT ON TABLE app.devices IS 'Устройства видеонаблюдения';
COMMENT ON TABLE app.channels IS 'Каналы устройств';
COMMENT ON TABLE app.streams IS 'Потоки видео';
COMMENT ON TABLE app.recordings IS 'Архив записей';
COMMENT ON TABLE app.events IS 'События детекции';
COMMENT ON TABLE app.roles IS 'Роли RBAC';
COMMENT ON TABLE app.user_roles IS 'Связь учётка-роль';
COMMENT ON TABLE ref.event_types IS 'Справочник типов событий';
COMMENT ON TABLE ref.device_types IS 'Справочник типов устройств';
COMMENT ON TABLE audit.login_log IS 'Журнал подключений к БД';
COMMENT ON TABLE stg.recordings_raw IS 'Сырые данные импорта записей';

COMMENT ON COLUMN app.employees.employee_number IS 'Табельный номер. classification: Internal';
COMMENT ON COLUMN app.employees.email IS 'Email. classification: Confidential';
COMMENT ON COLUMN app.employees.phone IS 'Телефон. classification: Confidential';
COMMENT ON COLUMN app.login_users.password_hash IS 'Хеш пароля. classification: Restricted';
COMMENT ON COLUMN app.login_users.employee_id IS 'Владелец учётки. NULL для сервисных учёток';