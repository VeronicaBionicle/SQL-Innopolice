/* Очистка */
drop table if exists veronikanenyuk.t_track_genre;

/* Создание таблицы для связи треков и жанров */
create table veronikanenyuk.t_track_genre
(
	id int generated always as identity not null,
	track_id int,
	genre_id int,
	constraint PK_track_genre_id PRIMARY KEY(id),
	constraint FK_track_genre_track FOREIGN KEY(track_id) REFERENCES veronikanenyuk.t_tracks(track_id),
	constraint FK_track_genre_genre FOREIGN KEY(genre_id) REFERENCES veronikanenyuk.t_genres(genre_id)
);

insert into veronikanenyuk.t_track_genre(track_id, genre_id)
select track_id, genre_id
from t_yandex_tracks_top100_raw y
INNER JOIN t_tracks t USING (track_name, link, chart, monthly_listens_total, artists_likes_total) -- соединяем по нескольким параметрам на всякий пожарный
join t_genres g on g.genre_name = y.genre;

select * from t_track_genre;

select t.*, g.genre_name 
from t_tracks t
inner join t_track_genre tg using(track_id)
inner join t_genres g using(genre_id);
