-- Получить студентов, их курсы и учебные заведения. Выбирать большие ВУЗы и курсы с высокой оценкой у студента
SELECT s.name student_name, cr.name course_name, c.name student_college, soc.student_rating 
FROM student s
JOIN college c ON c.id = s.college_id 
JOIN student_on_course soc ON soc.student_id = s.id 
JOIN course cr ON cr.id = soc.course_id 
WHERE c.size > 5000
AND soc.student_rating > 50
ORDER BY 1, 2;

-- Найти студентов и курсы, которые "находятся" в одном учебном заведении. Использовать NATURAL JOIN
with students as (
	select name student_name, college_id from student s 
)
select student_name, c.name course_name from students
natural join course c
order by 1;

-- Найти студентов из одного города и вывести уникальными парами ([Иван Иванов, Петр Петров] это та же пара, что и [Петр Петров, Иван Иванов]) 
select s1.name student_1, l.name student_2, l.city
from student s1 
inner join lateral (
 select s2.name, s2.city from student s2 where s1.city = s2.city and s1.id < s2.id
) as l on true
order by 1;
