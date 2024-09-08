drop table if exists veronikanenyuk.test ;

create table veronikanenyuk.test as
select (random()*10000)::integer A, (random()*10000)::integer B, (random()*10000)::integer C from generate_series(0,1000);

select * from veronikanenyuk.test limit 10;

CREATE INDEX idx_test_A ON veronikanenyuk.test USING BTREE (A);
CREATE INDEX idx_test_B ON veronikanenyuk.test USING BTREE (B);
CREATE INDEX idx_test_C ON veronikanenyuk.test USING BTREE (C);
CREATE INDEX idx_test_AB ON veronikanenyuk.test USING BTREE (A, B);
CREATE INDEX idx_test_AC ON veronikanenyuk.test USING BTREE (A, C);
CREATE INDEX idx_test_BA ON veronikanenyuk.test USING BTREE (B, A);
CREATE INDEX idx_test_BC ON veronikanenyuk.test USING BTREE (B, C);
CREATE INDEX idx_test_CA ON veronikanenyuk.test USING BTREE (C, A);
CREATE INDEX idx_test_CB ON veronikanenyuk.test USING BTREE (C, B);
CREATE INDEX idx_test_ABC ON veronikanenyuk.test USING BTREE (A, B, C);
CREATE INDEX idx_test_ACB ON veronikanenyuk.test USING BTREE (A, C, B);
CREATE INDEX idx_test_BAC ON veronikanenyuk.test USING BTREE (B, A, C);
CREATE INDEX idx_test_BCA ON veronikanenyuk.test USING BTREE (B, C, A);
CREATE INDEX idx_test_CAB ON veronikanenyuk.test USING BTREE (C, A, B);
CREATE INDEX idx_test_CBA ON veronikanenyuk.test USING BTREE (C, B, A);

CREATE STATISTICS stat_abc (mcv) ON a, b, c FROM veronikanenyuk.test;
ANALYZE veronikanenyuk.test;

explain analyze
SELECT min(A) OVER(PARTITION BY B,C ORDER BY B,C)
FROM test
WHERE A = 2076
ORDER BY C,B;

/*** Bench ***/
do $$
declare
	v_A integer;
begin
	for i in 1..10000 loop
		SELECT min(A) OVER(PARTITION BY B,C ORDER BY B,C) into v_A
		FROM test WHERE A = 3569
		ORDER BY C,B;
	end loop;
end;
$$;

select * from pg_stat_user_indexes where relname='test';
