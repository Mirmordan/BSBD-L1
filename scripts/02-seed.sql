-- ref
INSERT INTO ref.event_types (type, description) VALUES
    ('motion', 'Детекция движения'),
    ('line_cross', 'Пересечение линии'),
    ('intrusion', 'Вторжение в зону'),
    ('tamper', 'Попытка вскрытия'),
    ('offline', 'Потеря связи с устройством');

INSERT INTO ref.device_types (type, description) VALUES
    ('camera', 'IP-камера'),
    ('nvr', 'Сетевой видеорегистратор'),
    ('dvr', 'Цифровой видеорегистратор'),
    ('encoder', 'Видеокодер');


-- app: сотрудники
INSERT INTO app.employees (last_name, first_name, middle_name, email, phone, position, department, employee_number) VALUES
    ('Админов', 'Иван', 'Иванович', 'admin@vms.local', '+79000000001', 'Системный администратор', 'IT', 'EMP-001'),
    ('Операторов', 'Олег', 'Петрович', 'operator@vms.local', '+79000000002', 'Оператор', 'Служба охраны', 'EMP-002'),
    ('Наблюдаев', 'Виктор', NULL, 'viewer@vms.local', '+79000000003', 'Наблюдатель', 'Служба охраны', 'EMP-003'),
    ('Аудиторова', 'Анна', NULL, 'auditor@vms.local', '+79000000004', 'Внутренний аудитор', 'Служба аудита', 'EMP-004'),
    ('Иванов', 'Сергей', 'Сергеевич', 'ivanov@vms.local', '+79000000005', 'Оператор', 'Служба охраны', 'EMP-005'),
    ('Петров', 'Дмитрий', 'Алексеевич', 'petrov@vms.local', '+79000000006', 'Оператор', 'Служба охраны', 'EMP-006'),
    ('Сидоров', 'Алексей', NULL, 'sidorov@vms.local', '+79000000007', 'Наблюдатель', 'Служба охраны', 'EMP-007'),
    ('Кузнецова', 'Мария', 'Игоревна', 'kuznetsova@vms.local', '+79000000008', 'Наблюдатель', 'Служба охраны', 'EMP-008'),
    ('Смирнов', 'Павел', NULL, 'smirnov@vms.local', '+79000000009', 'Оператор', 'Служба охраны', 'EMP-009'),
    ('Волков', 'Николай', 'Николаевич', 'volkov@vms.local', '+79000000010', 'Оператор', 'Служба охраны', 'EMP-010');


-- app: учётные записи
INSERT INTO app.login_users (employee_id, username, password_hash) VALUES
    (1, 'admin', '$2b$12$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),
    (2, 'operator', '$2b$12$bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'),
    (3, 'viewer', '$2b$12$cccccccccccccccccccccccccccccccccccccccccccccccccccc'),
    (4, 'auditor', '$2b$12$dddddddddddddddddddddddddddddddddddddddddddddddddddd'),
    (5, 'ivanov', '$2b$12$eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'),
    (6, 'petrov', '$2b$12$ffffffffffffffffffffffffffffffffffffffffffffffffffff'),
    (7, 'sidorov', '$2b$12$gggggggggggggggggggggggggggggggggggggggggggggggggggg'),
    (8, 'kuznetsova', '$2b$12$hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh'),
    (9, 'smirnov', '$2b$12$iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii'),
    (10, 'volkov', '$2b$12$jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj'),
    (NULL, 'backup_bot', '$2b$12$kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk'),
    (NULL, 'monitoring', '$2b$12$llllllllllllllllllllllllllllllllllllllllllllllllllll');


-- app: устройства
INSERT INTO app.devices (name, device_type_id) VALUES
    ('Вход в офис', 1),
    ('Парковка', 1),
    ('Склад №1', 1),
    ('Серверная', 1),
    ('Коридор 1 этаж', 1),
    ('Коридор 2 этаж', 1),
    ('NVR основной', 2),
    ('NVR резервный', 2),
    ('DVR архивный', 3),
    ('Кодер аналоговых камер', 4);


-- app: каналы
INSERT INTO app.channels (device_id, number, name) VALUES
    (1, 1, 'Вход главный'),
    (1, 2, 'Вход служебный'),
    (2, 1, 'Парковка север'),
    (2, 2, 'Парковка юг'),
    (3, 1, 'Склад ворота'),
    (4, 1, 'Серверная дверь'),
    (5, 1, 'Коридор 1 этаж'),
    (6, 1, 'Коридор 2 этаж'),
    (7, 1, 'NVR канал 1'),
    (8, 1, 'NVR канал 2');


-- app: потоки
INSERT INTO app.streams (channel_id) VALUES
    (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);


-- app: записи архива
INSERT INTO app.recordings (stream_id, started_at, ended_at, file_path, size_bytes) VALUES
    (1, now() - interval '1 day', now() - interval '23 hours', '/storage/1/2026-10-08_00.mp4', 524288000),
    (1, now() - interval '2 days', now() - interval '47 hours', '/storage/1/2026-10-07_00.mp4', 512000000),
    (2, now() - interval '1 day', now() - interval '23 hours', '/storage/2/2026-10-08_00.mp4', 498000000),
    (3, now() - interval '3 hours', now() - interval '2 hours', '/storage/3/2026-10-09_12.mp4', 210000000),
    (4, now() - interval '1 hour', now(), '/storage/4/2026-10-09_14.mp4', 105000000),
    (5, now() - interval '6 hours', now() - interval '5 hours', '/storage/5/2026-10-09_09.mp4', 320000000),
    (6, now() - interval '1 day', now() - interval '20 hours', '/storage/6/2026-10-08_03.mp4', 480000000),
    (7, now() - interval '12 hours', now() - interval '11 hours', '/storage/7/2026-10-09_03.mp4', 350000000),
    (8, now() - interval '2 hours', now() - interval '1 hour', '/storage/8/2026-10-09_13.mp4', 180000000),
    (9, now() - interval '30 minutes', now(), '/storage/9/2026-10-09_14.mp4', 90000000);


-- app: события
INSERT INTO app.events (event_type_id, device_id, channel_id, created_at) VALUES
    (1, 1, 1, now() - interval '10 minutes'),
    (1, 1, 2, now() - interval '25 minutes'),
    (2, 2, 3, now() - interval '1 hour'),
    (3, 2, 4, now() - interval '2 hours'),
    (4, 3, 5, now() - interval '3 hours'),
    (1, 4, 6, now() - interval '4 hours'),
    (5, 5, 7, now() - interval '5 hours'),
    (1, 6, 8, now() - interval '6 hours'),
    (2, 7, 9, now() - interval '7 hours'),
    (3, 8, 10, now() - interval '8 hours');


-- app: роли
INSERT INTO app.roles (code, name, description) VALUES
    ('admin', 'Администратор', 'Полный доступ'),
    ('operator', 'Оператор', 'Просмотр и управление PTZ'),
    ('viewer', 'Наблюдатель', 'Только просмотр'),
    ('auditor', 'Аудитор', 'Доступ к журналам аудита');


-- app: роли учётных записей
INSERT INTO app.user_roles (user_id, role_id) VALUES
    (1, 1),
    (1, 2),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 2),
    (6, 2),
    (7, 3),
    (8, 3),
    (9, 2),
    (10, 2);


-- stg
INSERT INTO stg.recordings_raw (source, payload, batch_id) VALUES
    ('nvr-01', '{}'::jsonb, gen_random_uuid()),
    ('nvr-01', '{}'::jsonb, gen_random_uuid()),
    ('nvr-01', '{}'::jsonb, gen_random_uuid()),
    ('nvr-02', '{}'::jsonb, gen_random_uuid()),
    ('nvr-02', '{}'::jsonb, gen_random_uuid()),
    ('cam-02', '{}'::jsonb, gen_random_uuid()),
    ('cam-03', '{}'::jsonb, gen_random_uuid()),
    ('dvr-01', '{}'::jsonb, gen_random_uuid()),
    ('dvr-01', '{}'::jsonb, gen_random_uuid()),
    ('ftp-import', '{}'::jsonb, gen_random_uuid());