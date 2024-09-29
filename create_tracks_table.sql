/* Очистка */
drop table if exists veronikanenyuk.t_tracks;

/* Создание таблицы для треков */
create table veronikanenyuk.t_tracks
(
	track_id int generated always as identity not null,
	track_name varchar(100) not null,
	track_len interval,
	link text,
	chart int4 not null, -- для 100 мест хватит
	explicit_content boolean not null,
	monthly_listens_total int8 not null,
	artists_likes_total int8 not null,
	constraint PK_tracks_id PRIMARY KEY(track_id)
);

/* Индекс для поиска по имени артиста */
create index trgm_idx_track_name on veronikanenyuk.t_tracks using gin (track_name gin_trgm_ops);
/* Btree индексы для поиска по "числовым" данным */
CREATE INDEX idx_track_chart ON veronikanenyuk.t_tracks USING BTREE (chart);
CREATE INDEX idx_track_len ON veronikanenyuk.t_tracks USING BTREE (track_len);
CREATE INDEX idx_track_listens ON veronikanenyuk.t_tracks USING BTREE (monthly_listens_total);
CREATE INDEX idx_track_likes ON veronikanenyuk.t_tracks USING BTREE (artists_likes_total);

with track_info as (
	select 
	  track_name
	, LENGTH(REPLACE(track_len,':','~'))-LENGTH(REPLACE(track_len,':','')) len_delimiters
	, track_len
	, link, chart
	, case explicit_content
		when 1 then true
		else false end explicit_content
	, monthly_listens_total, artists_likes_total
	from t_yandex_tracks_top100_raw tyttr
)
insert into veronikanenyuk.t_tracks (track_name, track_len,	link, chart, explicit_content, monthly_listens_total, artists_likes_total)
select
	track_name
	, (repeat('00:', 2 - len_delimiters) || track_len)::interval track_len
	, link, chart, explicit_content, monthly_listens_total, artists_likes_total
from track_info;

select * from t_tracks ;
