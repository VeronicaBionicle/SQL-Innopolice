/* Очистка */
drop table if exists veronikanenyuk.t_artists;
drop table if exists veronikanenyuk.t_artists_log;

/* Создание таблицы для для артистов */
create table veronikanenyuk.t_artists
(
	artist_id int generated always as identity not null,
	artist_name varchar(100) not null,
	constraint PK_artists_id PRIMARY KEY(artist_id)
);

/* Индекс для поиска по имени артиста */
create index trgm_idx_artist_name on veronikanenyuk.t_artists using gin (artist_name gin_trgm_ops);

/* Создание таблицы для логирования */
CREATE TABLE "veronikanenyuk".t_artists_log (
 artist_id int not null, -- Артист, которого изменяли
 datetime_change timestamp not null, -- Дата изменнеия
 operation varchar(1) not null, -- Операция изменения I/U/D
 artist_name_before varchar(100), -- значение до изменения
 artist_name_after  varchar(100) -- значение после изменения
);


/* Создание триггеров для логирования CRUD-операций */
/* Вставка */
CREATE OR REPLACE FUNCTION artists_insert_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
    INSERT INTO "veronikanenyuk".t_artists_log (artist_id, datetime_change, operation, artist_name_before, artist_name_after)
    VALUES(new.artist_id, now(), 'I', old.artist_name, new.artist_name);
RETURN new;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER artists_insert_trigger
  AFTER INSERT
  ON "veronikanenyuk".t_artists
  FOR EACH ROW
  EXECUTE PROCEDURE artists_insert_trigger_fnc();

/* Обновление */
CREATE OR REPLACE FUNCTION artists_update_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
    INSERT INTO "veronikanenyuk".t_artists_log (artist_id, datetime_change, operation, artist_name_before, artist_name_after)
    VALUES(new.artist_id, now(), 'U', old.artist_name, new.artist_name);
RETURN new;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER artists_update_trigger
  AFTER UPDATE
  ON "veronikanenyuk".t_artists
  FOR EACH ROW
  EXECUTE PROCEDURE artists_update_trigger_fnc();
 
/* Удаление */ 
CREATE OR REPLACE FUNCTION artists_delete_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
    INSERT INTO "veronikanenyuk".t_artists_log (artist_id, datetime_change, operation, artist_name_before, artist_name_after)
    VALUES(new.artist_id, now(), 'D', old.artist_name, new.artist_name);
RETURN new;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER artists_delete_trigger
  AFTER DELETE
  ON "veronikanenyuk".t_artists
  FOR EACH ROW
  EXECUTE PROCEDURE artists_delete_trigger_fnc();
 
/* Вставка данных из "сырых" данных */
with art as (
	select unnest(string_to_array(trim('[]' from artists), ', ')) artist
	from t_yandex_tracks_top100_raw tyttr
)
insert into "veronikanenyuk".t_artists(artist_name)
select distinct trim(''' ' from artist) artist_name from art;
 
select * from t_artists ;
select * from t_artists_log;
