SET lc_numeric TO 'ru_RU';

DROP VIEW "veronikanenyuk".sales CASCADE;

CREATE VIEW "veronikanenyuk".sales AS
SELECT month, quarter, shop_id, class_of_good, to_number(average_bill, '9999999D99999') average_bill, bill_count
FROM "veronikanenyuk".sales_csv;

/*
return: набор строк со всеми столбцами из внешней таблицы
логика функции: вывести строки, со значение поля “Средний чек, тыс. руб.” больше ( >) p_average рублей
*/

CREATE OR REPLACE FUNCTION "veronikanenyuk".get_data_by_avg_cheque(p_average NUMERIC = NULL) 
RETURNS SETOF "veronikanenyuk".sales AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM "veronikanenyuk".sales
    WHERE average_bill > COALESCE(p_average, average_bill-1);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM "veronikanenyuk".get_data_by_avg_cheque(NULL) LIMIT 20;
SELECT * FROM "veronikanenyuk".get_data_by_avg_cheque(10) LIMIT 20;
select * FROM "veronikanenyuk".get_data_by_avg_cheque() LIMIT 20;

/*
return: набор строк со всеми столбцами из внешней
таблицы
логика функции: вывести строки из данных с переданными фильтрами по месяцу (p_month) и по магазину (p_shop). 
Если передается пустое значение для p_month - то выводить все месяцы, 
если передается пустое значение для p_shop - то выводить все магазины. 
Если передаются оба параметры пустыми - то выводить все из таблицы.
Результат упорядочить по категории
*/
CREATE OR REPLACE FUNCTION "veronikanenyuk".get_data_by_month_shop(p_month VARCHAR = NULL, p_shop INTEGER = NULL) 
RETURNS SETOF "veronikanenyuk".sales AS $$
    SELECT * FROM "veronikanenyuk".sales
    WHERE month   = COALESCE(p_month, month) AND
          shop_id = COALESCE(p_shop, shop_id)
    ORDER BY class_of_good;
$$ LANGUAGE sql;

SELECT * FROM  "veronikanenyuk".get_data_by_month_shop('январь', 1)  LIMIT 10;

SELECT * FROM  "veronikanenyuk".get_data_by_month_shop('январь',NULL) LIMIT 10;
SELECT * FROM  "veronikanenyuk".get_data_by_month_shop('январь')  LIMIT 10;

SELECT * FROM  "veronikanenyuk".get_data_by_month_shop(NULL, 1) LIMIT 10;
SELECT * FROM  "veronikanenyuk".get_data_by_month_shop(p_shop => 1)  LIMIT 10;

SELECT * FROM "veronikanenyuk".get_data_by_month_shop(NULL,NULL) LIMIT 10;
SELECT * FROM "veronikanenyuk".get_data_by_month_shop() LIMIT 10;
