select * from t_artists_log ;
select * from t_genres_log ;

/* Функция для получения логов по имени таблицы */
drop function if exists "veronikanenyuk".get_logs;

create or replace function "veronikanenyuk".get_logs(p_table_name text)
returns table ("id в основной таблице" int, "Дата изменения" timestamp, "Примененная операция" varchar(6), "Данные до изменения" varchar(100), "Данные после изменения" varchar(100)) as $$
declare
  v_log_table text;
  v_table_part_name text;
  v_query text := E'SELECT :v_table_part_name_id
						, datetime_change
						, case operation
							when \'I\' then \'INSERT\'
 							when \'U\' then \'UPDATE\'
							when \'D\' then \'DELETE\'
					        else operation
					      end operation
						, :v_table_part_name_name_before
						, :v_table_part_name_name_after
						FROM veronikanenyuk.:v_log_table
						ORDER BY datetime_change desc, :v_table_part_name_id asc';
begin
  v_log_table := p_table_name || '_log'; -- примем соглашение, что таблица с логами на зывается как "имя таблицы" + "_log"
  -- Если такая таблица с логами есть, запрашиваем
  if exists (SELECT FROM pg_tables WHERE tablename = v_log_table AND schemaname = 'veronikanenyuk') then
  	v_table_part_name := substring(p_table_name, 3, length(p_table_name ) - 3 );	
  	v_query := replace(v_query, ':v_table_part_name', v_table_part_name); 
    v_query := replace(v_query ,':v_log_table', v_log_table); 
  	return query execute v_query;
 end if;
end;
$$ language plpgsql;

select * from get_logs('t_artists');
select * from get_logs('t_genres');
select * from get_logs('x');
