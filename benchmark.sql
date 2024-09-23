do $$
declare
	v_rec record;
begin
	for i in 1..10000 loop
		/*SELECT min(A) OVER(PARTITION BY B,C ORDER BY B,C) into v_A
		FROM test WHERE A = 3569
		ORDER BY C,B;*/
		select
			nsi."Описание" "Описание прибора"
		  , tgz.value "Значение"
		  , tgz.value_date "Дата"
		  , nsi."Единица измерения"
		  into v_rec
		from t_green_zona tgz 
		inner join nsi on nsi."Идентификатор" = tgz.device_id
		order by tgz.value_date desc, nsi."Описание" ;
	end loop;
end;
$$;
