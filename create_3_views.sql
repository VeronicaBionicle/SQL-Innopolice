--Статистика по жанрам
create materialized view v_genre_statistics as
select g.genre_name
, sum(t.monthly_listens_total) total_listens
, sum(t.artists_likes_total) total_likes
, count(distinct ta.artist_id)
, sum(case when explicit_content then 1 else 0 end) explicit_content_count
from t_tracks t
inner join t_track_artist ta using(track_id)
inner join t_track_genre tg using(track_id)
inner join t_genres g using(genre_id)
group by g.genre_name
order by g.genre_name asc
with data;

-- Статистика по исполнителям
create materialized view v_artist_statistics as
select a.artist_name
, sum(t.monthly_listens_total) total_listens
, sum(t.artists_likes_total) total_likes
, count(t.track_id) top100_tracks
, string_agg(distinct g.genre_name, ', ') genres
from t_tracks t
inner join t_track_artist ta using(track_id)
inner join t_artists a using(artist_id)
inner join t_track_genre tg using(track_id)
inner join t_genres g using(genre_id)
group by a.artist_name
order by a.artist_name asc
with data;

-- Статистика по длительности треков
create materialized view v_chart_and_length as
select EXTRACT (EPOCH from t.track_len) track_len, g.genre_name 
from t_tracks t
inner join t_track_genre tg using(track_id)
inner join t_genres g using(genre_id)
with data;
