-- https://www.postgresql.org/docs/10/when-can-parallel-query-be-used.html
drop table test;

explain analyze
create table test as 
select count(*)
from public.test_data
where lfile_seq = 1297;

--병렬쿼리 안됨 (pg10 - write)
--Aggregate  (cost=279313.16..279313.17 rows=1 width=8) (actual time=1872.833..1872.834 rows=1 loops=1)
--  ->  Seq Scan on test_data  (cost=0.00..279310.12 rows=1216 width=0) (actual time=0.010..1872.156 rows=5547 loops=1)
--        Filter: (lfile_seq = 1297)
--        Rows Removed by Filter: 11200956
--Planning time: 0.054 ms
--Execution time: 1873.552 ms

drop table test;

explain analyze
create table test as 
select lfile_seq, count(*)
from public.test_data
group by lfile_seq ;

--병렬쿼리 안됨 (pg10 - write)
--HashAggregate  (cost=307313.35..307385.67 rows=7232 width=12) (actual time=3940.522..3944.531 rows=13662 loops=1)
--  Group Key: lfile_seq
--  ->  Seq Scan on test_data  (cost=0.00..251306.90 rows=11201290 width=4) (actual time=0.011..1467.370 rows=11206503 loops=1)
--Planning time: 0.041 ms
--Execution time: 3952.666 ms

drop table test;

explain analyze
select lfile_seq, count(*)
into test
from public.test_data
group by lfile_seq ;

--병렬쿼리 안됨 (pg10 - write)
--HashAggregate  (cost=307313.35..307385.67 rows=7232 width=12) (actual time=5124.282..5127.680 rows=13662 loops=1)
--  Group Key: lfile_seq
--  ->  Seq Scan on test_data  (cost=0.00..251306.90 rows=11201290 width=4) (actual time=0.013..1946.368 rows=11206503 loops=1)
--Planning time: 0.046 ms
--Execution time: 5136.887 ms


CREATE OR REPLACE FUNCTION public.fn_test()
	RETURNS int4
	LANGUAGE plpgsql
AS $function$
	begin
		
		drop table if exists test1;
		drop table if exists test2;
		drop table if exists test3;
		
		create temporary table test1 as 
		select count(*) cnt
		from public.test_data
		where lfile_seq = 1297;
		
		
		create temporary table test2 as 
		select lfile_seq, count(*) cnt
		from public.test_data
		group by lfile_seq ;	
	
	
		create temporary table test3 as 
		select sum(cnt)
		from test2;		
	
		return 1;
	END;
$function$

-- 5913
explain analyze
select public.fn_test();

--병렬 쿼리 안됨 (사용자 함수)
--Result  (cost=0.00..0.26 rows=1 width=4) (actual time=6585.230..6585.231 rows=1 loops=1)
--Planning time: 0.025 ms
--Execution time: 6585.246 ms

-- 사용자 함수는 기본 적으로 parallel unsafe임 (병렬 쿼리 안됨)
-- alter문으로 parallel safe로 변경 가능하지만, unsafe한 경우 오동작할 수 있음
select proparallel 
from pg_catalog.pg_proc
where proname = 'fn_test';

