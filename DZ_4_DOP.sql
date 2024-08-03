/*
Напишите SQL запрос, используя любую CTE конструкцию для вывода имен студентов и названия курсов в одном списке,
но с указанием категории выводимой строки
*/
WITH students AS (
	SELECT name, 'студент' category FROM "veronikanenyuk".student
),
courses AS (
	SELECT name, 'курс' category FROM "veronikanenyuk".course
)
SELECT * FROM students
UNION ALL
SELECT * FROM courses;

/* Таблица вершин-городов */
CREATE TABLE "veronikanenyuk".city (
	id int PRIMARY KEY,
	name TEXT
);

INSERT INTO "veronikanenyuk".city (id, name) 
VALUES
	(1, 'A'),
	(2, 'B'),
	(3, 'C'),
	(4, 'D');

/* Таблица с ребрами графа */
CREATE TABLE "veronikanenyuk".city_edge (
	id serial PRIMARY KEY,
	from_city int,
	to_city int,
	distance int
);

/* Данные по ребрам */
INSERT INTO "veronikanenyuk".city_edge (from_city, to_city, distance) 
VALUES
	(1, 2, 10), (2, 1, 10), -- A-B 10
	(1, 3, 15), (3, 1, 15), -- A-C 15
	(1, 4, 20), (4, 1, 20), -- A-D 20
	(2, 3, 35), (3, 2, 35), -- B-C 35
	(2, 4, 25), (4, 2, 25), -- B-D 25
	(3, 4, 30), (4, 3, 30) -- C-D 30
;

/* Рекурсивный запрос */
WITH RECURSIVE search_city_edge(from_city, to_city, total_distance, route, named_route, is_cycle) AS (
    SELECT t.from_city, t.to_city, t.distance total_distance,
	ARRAY[t.from_city],
	ARRAY[cf.name, ct.name],
	false is_cycle
    FROM "veronikanenyuk".city_edge t
	JOIN "veronikanenyuk".city cf ON cf.id=t.from_city
	JOIN "veronikanenyuk".city ct ON ct.id=t.to_city
  UNION ALL
    SELECT t.from_city, t.to_city,
	st.total_distance + t.distance total_distance,
	route || t.from_city route,
	CASE WHEN st.to_city = t.from_city -- чтобы не двоились именования
		then named_route || ct.name
		else named_route || cf.name || ct.name
	END named_route,
	t.from_city = ANY(route) is_cycle
    FROM "veronikanenyuk".city_edge t, search_city_edge st, "veronikanenyuk".city cf, "veronikanenyuk".city ct 
    WHERE t.from_city = st.to_city AND NOT is_cycle
	AND cf.id=t.from_city AND ct.id=t.to_city
)
SELECT total_distance, named_route
FROM search_city_edge
WHERE named_route[1]='A' AND named_route[array_upper(named_route,1)]='A' -- начинается и кончается в А
ORDER BY 2;

/* Оформление запроса в виде функции */
CREATE OR REPLACE FUNCTION "veronikanenyuk".get_route(p_first_city_name text = NULL, p_last_city_name text = NULL)  
RETURNS SETOF RECORD AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE search_city_edge(from_city, to_city, total_distance, route, named_route, is_cycle) AS (
		SELECT t.from_city, t.to_city, t.distance total_distance,
		ARRAY[t.from_city],
		ARRAY[cf.name, ct.name],
		false is_cycle
		FROM "veronikanenyuk".city_edge t
		JOIN "veronikanenyuk".city cf ON cf.id=t.from_city
		JOIN "veronikanenyuk".city ct ON ct.id=t.to_city
	  UNION ALL
		SELECT t.from_city, t.to_city,
		st.total_distance + t.distance total_distance,
		route || t.from_city route,
		CASE WHEN st.to_city = t.from_city -- чтобы не двоились именования
			then named_route || ct.name
			else named_route || cf.name || ct.name
		END named_route,
		t.from_city = ANY(route) is_cycle
		FROM "veronikanenyuk".city_edge t, search_city_edge st, "veronikanenyuk".city cf, "veronikanenyuk".city ct 
		WHERE t.from_city = st.to_city AND NOT is_cycle
		AND cf.id=t.from_city AND ct.id=t.to_city
	)
	SELECT total_distance, named_route
	FROM search_city_edge
	WHERE (p_first_city_name IS NULL OR named_route[1]=p_first_city_name)
	  AND (p_last_city_name IS NULL OR named_route[array_upper(named_route,1)]=p_last_city_name)
	ORDER BY 2;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM "veronikanenyuk".get_route('C','B') AS (total_distance int, named_route text[]); -- от C до B
SELECT * FROM "veronikanenyuk".get_route('D') AS (total_distance int, named_route text[]); -- от D... куда-нибудь
SELECT * FROM "veronikanenyuk".get_route(p_last_city_name => 'A') AS (total_distance int, named_route text[]); -- от куда-нибудь в А
SELECT * FROM "veronikanenyuk".get_route() AS (total_distance int, named_route text[]); -- все пути

/* Найти самую минимальную цену тура и сам тур из города B в город C */
WITH ranked_tours AS (
	SELECT res.*, RANK() OVER(ORDER BY total_distance ASC) rnk
	FROM "veronikanenyuk".get_route('B','C') AS res(total_distance int, named_route text[])
)
SELECT total_distance, named_route FROM ranked_tours WHERE rnk=1;