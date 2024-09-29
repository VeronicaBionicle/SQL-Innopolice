/* Очистка */
drop table if exists veronikanenyuk.t_genres;
drop table if exists veronikanenyuk.t_genres_log;

/* Создание таблицы для жанров */
create table veronikanenyuk.t_genres
(
	genre_id int generated always as identity not null,
	genre_name varchar(100) not null,
	constraint PK_genres_id PRIMARY KEY(genre_id)
);

/* Полнотекстовый поиск по =, like, ilike */
create extension pg_trgm;

/* Индекс для поиска по названию жанра */
create index trgm_idx_genre_name on veronikanenyuk.t_genres using gin (genre_name gin_trgm_ops);

/* Создание таблицы для логирования */
CREATE TABLE "veronikanenyuk".t_genres_log (
 genre_id int not null, -- Жанр, который изменяли
 datetime_change timestamp not null, -- Дата изменнеия
 operation varchar(1) not null, -- Операция изменения I/U/D
 genre_name_before varchar(100), -- значение до изменения
 genre_name_after  varchar(100) -- значение после изменения
);


/* Создание триггеров для логирования CRUD-операций */
/* Вставка */
CREATE OR REPLACE FUNCTION genres_insert_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
    INSERT INTO "veronikanenyuk".t_genres_log (genre_id, datetime_change, operation, genre_name_before, genre_name_after)
    VALUES(new.genre_id, now(), 'I', old.genre_name, new.genre_name);
RETURN new;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER genres_insert_trigger
  AFTER INSERT
  ON "veronikanenyuk".t_genres
  FOR EACH ROW
  EXECUTE PROCEDURE genres_insert_trigger_fnc();

/* Обновление */
CREATE OR REPLACE FUNCTION genres_update_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
    INSERT INTO "veronikanenyuk".t_genres_log (genre_id, datetime_change, operation, genre_name_before, genre_name_after)
    VALUES(new.genre_id, now(), 'U', old.genre_name, new.genre_name);
RETURN new;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER genres_update_trigger
  AFTER UPDATE
  ON "veronikanenyuk".t_genres
  FOR EACH ROW
  EXECUTE PROCEDURE genres_update_trigger_fnc();
 
/* Удаление */ 
CREATE OR REPLACE FUNCTION genres_delete_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
    INSERT INTO "veronikanenyuk".t_genres_log (genre_id, datetime_change, operation, genre_name_before, genre_name_after)
    VALUES(new.genre_id, now(), 'D', old.genre_name, new.genre_name);
RETURN new;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER genres_delete_trigger
  AFTER DELETE
  ON "veronikanenyuk".t_genres
  FOR EACH ROW
  EXECUTE PROCEDURE genres_delete_trigger_fnc();
 
/* Вставка данных из "сырых" данных */
insert into veronikanenyuk.t_genres (genre_name)
select distinct genre from t_yandex_tracks_top100_raw tyttr;

select * from t_genres tg ;
select * from t_genres_log;
