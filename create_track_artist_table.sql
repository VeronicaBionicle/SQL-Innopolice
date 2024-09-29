/* Очистка */
drop table if exists veronikanenyuk.t_track_artist;

/* Создание таблицы для связи треков и артистов */
create table veronikanenyuk.t_track_artist
(
	id int generated always as identity not null,
	track_id int,
	artist_id int,
	constraint PK_track_artist_id PRIMARY KEY(id),
	constraint FK_track_artist_track FOREIGN KEY(track_id) REFERENCES veronikanenyuk.t_tracks(track_id),
	constraint FK_track_artist_artist FOREIGN KEY(artist_id) REFERENCES veronikanenyuk.t_artists(artist_id)
);

insert into veronikanenyuk.t_track_artist (track_id, artist_id)
select track_id, artist_id
from t_yandex_tracks_top100_raw y
INNER JOIN t_tracks t USING (track_name, link, chart, monthly_listens_total, artists_likes_total) -- соединяем по нескольким параметрам на всякий пожарный
join t_artists a on (y.artists like '%'''||a.artist_name||'''%');

select * from veronikanenyuk.t_track_artist;

select t.*, a.artist_name
from t_tracks t
inner join t_track_artist ta using(track_id)
inner join t_artists a using(artist_id);
