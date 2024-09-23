select * from nsi;

select
	nsi."Описание" "Описание прибора"
  , tgz.value "Значение"
  , tgz.value_date "Дата"
  , nsi."Единица измерения"
from t_green_zona tgz 
inner join nsi on nsi."Идентификатор" = tgz.device_id
order by tgz.value_date desc, nsi."Описание" ;

CREATE INDEX idx_nsi_id ON veronikanenyuk.nsi USING BTREE ("Идентификатор");
CREATE INDEX idx_nsi_name ON veronikanenyuk.nsi USING BTREE ("Описание");
CREATE INDEX idx_nsi_id_name ON veronikanenyuk.nsi USING BTREE ("Идентификатор", "Описание");

CREATE INDEX idx_t_green_zona_id ON veronikanenyuk.t_green_zona USING BTREE (device_id);
CREATE INDEX idx_t_green_zona_date ON veronikanenyuk.t_green_zona USING BTREE (value_date);
CREATE INDEX idx_t_green_zona_id_date ON veronikanenyuk.t_green_zona USING BTREE (value_date, device_id );

CREATE STATISTICS stat_nsi_id_name (mcv) ON "Идентификатор", "Описание" FROM veronikanenyuk.nsi;
ANALYZE veronikanenyuk.nsi;

CREATE STATISTICS stat_t_green_zona_id_date (mcv) ON device_id, value_date FROM veronikanenyuk.t_green_zona;
ANALYZE veronikanenyuk.t_green_zona;

select * from pg_stat_user_indexes where relname in ('nsi','t_green_zona');
