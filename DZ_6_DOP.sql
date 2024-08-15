/* Поиск пропусков в последовательном id в таблице */
-- Генерация данных
create table t1 as
select s.id from generate_series(1,1000) as s(id)
where mod(s.id, ceil(random()*10)::INTEGER) > 3;

select * from t1;

select * from generate_series(1,1000) as s(id)
where s.id not in (select id from t1);

select * from generate_series(1,1000) as s(id)
where not exists (select 1 from t1 where t1.id = s.id limit 1);

select s.id from generate_series(1,1000) as s(id)
left join lateral (select 1 is_in_t1 from t1 where t1.id = s.id) as l on true
where is_in_t1 is null;

/* Увеличение id на 1 */
-- Генерация данных
create table t2 as
select s.id from generate_series(1,10) as s(id);

select * from t2;

update t2
set id = id+1;

select * from t2;

/* Преобразование данных в дату */
-- Генерация данных 
create table t3 as
select (r."year" * 10000 + r."day" * 100 + r."month")::INTEGER dt_1
from (
	select 2000 + floor(random()*100) * case when mod(floor(random()*10)::INTEGER, 2)=1 then 1 else -1 end "year",
	       1 + floor(random()*12)::INTEGER "month",
	       1 + floor(random()*28)::INTEGER "day"
	from generate_series(0,100000)
) as r;

alter table t3 add column dt_new date;

select distinct * from t3;

update t3
set dt_new = to_date(dt_1::text,'YYYYDDMM');

select distinct * from t3;

update t3
set dt_new = make_date(dt_1/10000, mod(dt_1,100), mod(dt_1/100,100));

select distinct * from t3;
