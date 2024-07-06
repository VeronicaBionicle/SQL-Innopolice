SELECT version(), user; -- Тест подключения

CREATE SCHEMA veronikanenyuk; -- Моя схема

/* Создание таблицы */
DROP TABLE IF EXISTS "veronikanenyuk".users;

CREATE TABLE "veronikanenyuk".USERS (
 user_id int generated always as identity not null,
 user_name varchar(100) not null
) PARTITION by hash (user_id);

/* Делаем четыре партиции */
CREATE TABLE users_p1
PARTITION OF "veronikanenyuk".USERS
FOR VALUES WITH (modulus 4, remainder 0);
CREATE TABLE users_p2
PARTITION OF "veronikanenyuk".USERS
FOR VALUES WITH (modulus 4, remainder 1);
CREATE TABLE users_p3
PARTITION OF "veronikanenyuk".USERS
FOR VALUES WITH (modulus 4, remainder 2);
CREATE TABLE users_p4
PARTITION OF "veronikanenyuk".USERS
FOR VALUES WITH (modulus 4, remainder 3);

/* Генерация данных */
INSERT INTO "veronikanenyuk".USERS (user_name)
 -- Формат user-[число до 10000][символ]
 SELECT 'user-' || round(random()*10000)::text || chr(ascii('B') + (random() * 25)::integer)
 FROM generate_series(1, 10000);

/* Таблица с итогом */
WITH partitions_of_users AS (
    SELECT child.relname, child.reltuples
    FROM pg_inherits
        JOIN pg_class parent            ON pg_inherits.inhparent = parent.oid
        JOIN pg_class child             ON pg_inherits.inhrelid  = child.oid
        JOIN pg_namespace nmsp_parent   ON nmsp_parent.oid  = parent.relnamespace
        JOIN pg_namespace nmsp_child    ON nmsp_child.oid   = child.relnamespace
        WHERE parent.relname = 'users'
)
SELECT relname "Имя партиции", reltuples "Количество строк" FROM partitions_of_users
UNION ALL
SELECT 'ИТОГО:' "Имя партиции", SUM(reltuples) "Количество строк" FROM partitions_of_users;