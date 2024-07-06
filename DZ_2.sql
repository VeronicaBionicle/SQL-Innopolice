/* Для работы с числами в "русском" формате 1111,1111 */
SET lc_numeric TO 'ru_RU';

/* Установить расширение */
CREATE EXTENSION file_fdw;

/* Создать сервер */
CREATE SERVER sales FOREIGN DATA WRAPPER file_fdw;

/* Создать таблицу под csv */
--drop foreign table "veronikanenyuk".sales_csv;
CREATE FOREIGN TABLE "veronikanenyuk".sales_csv (
    month text,
    quarter integer,
    shop_id integer,
    class_of_good text,
    average_bill text, -- не вышло определить , как разделитель целой и дробной части
    bill_count integer,
    dummy text -- из-за того, что в конце строки лишний знак ';'
) SERVER sales
OPTIONS ( filename '/opt/lab2.csv', format 'csv', header 'true', delimiter ';');

/* Проверить валидность таблицы */
SELECT * FROM "veronikanenyuk".sales_csv LIMIT 20;

/* Цивильная вьюшка для работы с данными */
CREATE VIEW "veronikanenyuk".sales AS
SELECT month, quarter, shop_id, class_of_good, to_number(average_bill, '9999999D99999'), bill_count
FROM "veronikanenyuk".sales_csv;
SELECT * FROM "veronikanenyuk".sales LIMIT 20;

/* Количество строк в месяце */
CREATE VIEW v_month_count AS
SELECT month, COUNT(1) row_count FROM "veronikanenyuk".sales_csv
GROUP BY month
ORDER BY CASE   WHEN month = 'январь' THEN 1
                WHEN month = 'февраль' THEN 2
                WHEN month = 'март' THEN 3
                WHEN month = 'апрель' THEN 4
                WHEN month = 'май' THEN 5
                WHEN month = 'июнь' THEN 6
                WHEN month = 'июль' THEN 7
                WHEN month = 'август' THEN 8
                WHEN month = 'сентябрь' THEN 9
                WHEN month = 'октябрь' THEN 10
                WHEN month = 'ноябрь' THEN 11
                WHEN month = 'декабрь' THEN 12 END ASC;

SELECT * FROM v_month_count;

/* Количество строк, в которых средний чек больше 1,5 т.р. */
CREATE VIEW v_big_bill_count AS
SELECT COUNT(1) big_bill_count FROM "veronikanenyuk".sales_csv
WHERE to_number(average_bill, '9999999D99999') > 1.5;

SELECT * FROM v_big_bill_count;

/* Общая сумма произведений "среднего чека, т.р." на "количество чеков, т.ч."  */
CREATE VIEW v_bill_sum AS
SELECT SUM(to_number(average_bill, '9999999D99999') * bill_count * 1000) sum_bills
FROM "veronikanenyuk".sales_csv;

SELECT * FROM v_bill_sum;