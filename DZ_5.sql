select * from green_zona gz ;
select * from red_zona rz;

create table t_green_zona as
select device_id, to_timestamp(value_date/1000000) value_date, value  from green_zona gz ;

create table t_red_zona as
select device_id, to_timestamp(date_value/1000000) value_date, value  from red_zona gz ;

create view v_zone_data as
select device_id "№ прибора", value_date "Дата", value "Значение", 'зеленая' "Зона" from t_green_zona gz
union all
select device_id "№ прибора", value_date "Дата", value "Значение", 'красная' "Зона"  from t_red_zona rz;

select * from v_zone_data order by 1, 2, 4, 3;
