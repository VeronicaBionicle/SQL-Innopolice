/* Создание таблицы */
DROP TABLE IF EXISTS "veronikanenyuk".main_table;

CREATE TABLE "veronikanenyuk".main_table (
 id INT NOT NULL,
 name VARCHAR(100) NOT NULL,
 s_date DATE
);

CREATE OR REPLACE FUNCTION "veronikanenyuk".main_table_on_ins() RETURNS trigger AS $$
DECLARE
  v_new_table TEXT;
BEGIN
  v_new_table := 'main_table_' || TO_CHAR(NEW.s_date, 'YYYYMMDD');
  IF NOT EXISTS (SELECT FROM pg_tables WHERE tablename = v_new_table AND schemaname = 'veronikanenyuk') THEN
     -- Создаем новую таблицу
     EXECUTE 'CREATE TABLE "veronikanenyuk".'|| v_new_table || '() INHERITS ("veronikanenyuk".main_table)';
  END IF;
  
  -- Подставляем данные
  EXECUTE 'INSERT INTO "veronikanenyuk".' || v_new_table  || ' SELECT '
		  || NEW.id || ', ''' || NEW.name || ''', TO_DATE(''' || TO_CHAR(NEW.s_date,'DD.MM.YYYY') || ''', ''DD.MM.YYYY'')';
  
  RETURN NULL; -- Чтобы не вставлялось в main_table
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER main_table_ins BEFORE INSERT ON "veronikanenyuk".main_table
FOR EACH ROW EXECUTE PROCEDURE "veronikanenyuk".main_table_on_ins();

/* Тесты */
INSERT INTO "veronikanenyuk".main_table(id, name, s_date) VALUES (1, 'Иван', '2024-01-01');
INSERT INTO "veronikanenyuk".main_table(id, name, s_date) VALUES (2, 'Анна', '2024-01-02');
INSERT INTO "veronikanenyuk".main_table(id, name, s_date) VALUES (3, 'Сергей', '2024-01-03');
INSERT INTO "veronikanenyuk".main_table(id, name, s_date) VALUES (4, 'Екатерина', '2024-01-02');

/* SQL запрос ниже должен вернуть 0 строк! */
SELECT count(*) FROM ONLY "veronikanenyuk".main_table;

SELECT * FROM "veronikanenyuk".main_table_20240101;
SELECT * FROM "veronikanenyuk".main_table_20240102;
SELECT * FROM "veronikanenyuk".main_table_20240103;