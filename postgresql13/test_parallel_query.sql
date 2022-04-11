-- https://www.postgresql.org/docs/13/when-can-parallel-query-be-used.html
drop table test;

explain analyze
create table test as 
select count(*)
from public.test_data
where lfile_seq = 1297;

--병렬쿼리 (pg13 - ctas)
--Finalize Aggregate  (cost=198662.67..198662.68 rows=1 width=8) (actual time=1195.496..1205.608 rows=1 loops=1)
--  ->  Gather  (cost=198662.45..198662.66 rows=2 width=8) (actual time=1194.512..1205.590 rows=3 loops=1)
--        Workers Planned: 2
--        Workers Launched: 2
--        ->  Partial Aggregate  (cost=197662.45..197662.46 rows=1 width=8) (actual time=1138.576..1138.577 rows=1 loops=3)
--              ->  Parallel Seq Scan on test_data  (cost=0.00..197661.18 rows=509 width=0) (actual time=742.174..1138.382 rows=1849 loops=3)
--                    Filter: (lfile_seq = 1297)
--                    Rows Removed by Filter: 3733652
--Planning Time: 0.071 ms
--JIT:
--  Functions: 14
--  Options: Inlining false, Optimization false, Expressions true, Deforming true
--  Timing: Generation 13.958 ms, Inlining 0.000 ms, Optimization 1.002 ms, Emission 19.643 ms, Total 34.604 ms
--Execution Time: 1222.823 ms

drop table test;

explain analyze
create table test as 
select lfile_seq, count(*)
from public.test_data
group by lfile_seq ;

--병렬쿼리 (pg13 - ctas)
--Finalize GroupAggregate  (cost=210868.92..212696.07 rows=7212 width=12) (actual time=2548.111..2580.071 rows=13662 loops=1)
--  Group Key: lfile_seq
--  ->  Gather Merge  (cost=210868.92..212551.83 rows=14424 width=12) (actual time=2548.087..2567.366 rows=36655 loops=1)
--        Workers Planned: 2
--        Workers Launched: 2
--        ->  Sort  (cost=209868.89..209886.92 rows=7212 width=12) (actual time=2500.572..2502.953 rows=12218 loops=3)
--              Sort Key: lfile_seq
--              Sort Method: quicksort  Memory: 968kB
--              Worker 0:  Sort Method: quicksort  Memory: 945kB
--              Worker 1:  Sort Method: quicksort  Memory: 959kB
--              ->  Partial HashAggregate  (cost=209334.62..209406.74 rows=7212 width=12) (actual time=2489.250..2493.718 rows=12218 loops=3)
--                    Group Key: lfile_seq
--                    Batches: 1  Memory Usage: 1809kB
--                    Worker 0:  Batches: 1  Memory Usage: 1425kB
--                    Worker 1:  Batches: 1  Memory Usage: 1425kB
--                    ->  Parallel Seq Scan on test_data  (cost=0.00..185987.75 rows=4669375 width=4) (actual time=0.020..874.218 rows=3735501 loops=3)
--Planning Time: 0.079 ms
--JIT:
--  Functions: 21
--  Options: Inlining false, Optimization false, Expressions true, Deforming true
--  Timing: Generation 4.359 ms, Inlining 0.000 ms, Optimization 1.113 ms, Emission 31.114 ms, Total 36.585 ms
--Execution Time: 2599.010 ms

drop table test;

explain analyze
select lfile_seq, count(*)
into test
from public.test_data
group by lfile_seq ;

--병렬쿼리 (pg13 - select into)
--Finalize GroupAggregate  (cost=210868.92..212696.07 rows=7212 width=12) (actual time=2094.773..2120.719 rows=13662 loops=1)
--  Group Key: lfile_seq
--  ->  Gather Merge  (cost=210868.92..212551.83 rows=14424 width=12) (actual time=2094.748..2107.902 rows=37131 loops=1)
--        Workers Planned: 2
--        Workers Launched: 2
--        ->  Sort  (cost=209868.89..209886.92 rows=7212 width=12) (actual time=2054.253..2056.116 rows=12377 loops=3)
--              Sort Key: lfile_seq
--              Sort Method: quicksort  Memory: 967kB
--              Worker 0:  Sort Method: quicksort  Memory: 954kB
--              Worker 1:  Sort Method: quicksort  Memory: 973kB
--              ->  Partial HashAggregate  (cost=209334.62..209406.74 rows=7212 width=12) (actual time=2043.748..2048.133 rows=12377 loops=3)
--                    Group Key: lfile_seq
--                    Batches: 1  Memory Usage: 1809kB
--                    Worker 0:  Batches: 1  Memory Usage: 1425kB
--                    Worker 1:  Batches: 1  Memory Usage: 1425kB
--                    ->  Parallel Seq Scan on test_data  (cost=0.00..185987.75 rows=4669375 width=4) (actual time=0.040..731.877 rows=3735501 loops=3)
--Planning Time: 0.059 ms
--JIT:
--  Functions: 21
--  Options: Inlining false, Optimization false, Expressions true, Deforming true
--  Timing: Generation 3.246 ms, Inlining 0.000 ms, Optimization 1.352 ms, Emission 27.172 ms, Total 31.771 ms
--Execution Time: 2133.338 ms


drop table if exists test1;
drop table if exists test2;

select *
into test1
from public.test_data;

explain analyze
create table test2 as 
select lfile_seq, count(*)
from test1
group by lfile_seq ;

--병렬쿼리 (pg13 - ctas from temp table)
--Finalize GroupAggregate  (cost=177738.93..177789.60 rows=200 width=12) (actual time=2436.987..2459.062 rows=13662 loops=1)
--  Group Key: lfile_seq
--  ->  Gather Merge  (cost=177738.93..177785.60 rows=400 width=12) (actual time=2436.970..2448.691 rows=37008 loops=1)
--        Workers Planned: 2
--        Workers Launched: 2
--        ->  Sort  (cost=176738.91..176739.41 rows=200 width=12) (actual time=2385.611..2387.409 rows=12336 loops=3)
--              Sort Key: lfile_seq
--              Sort Method: quicksort  Memory: 973kB
--              Worker 0:  Sort Method: quicksort  Memory: 958kB
--              Worker 1:  Sort Method: quicksort  Memory: 957kB
--              ->  Partial HashAggregate  (cost=176729.26..176731.26 rows=200 width=12) (actual time=2376.086..2380.043 rows=12336 loops=3)
--                    Group Key: lfile_seq
--                    Batches: 1  Memory Usage: 1825kB
--                    Worker 0:  Batches: 1  Memory Usage: 1441kB
--                    Worker 1:  Batches: 1  Memory Usage: 1441kB
--                    ->  Parallel Seq Scan on test1  (cost=0.00..164250.84 rows=2495684 width=4) (actual time=0.085..880.272 rows=3735501 loops=3)
--Planning Time: 0.108 ms
--JIT:
--  Functions: 21
--  Options: Inlining false, Optimization false, Expressions true, Deforming true
--  Timing: Generation 2.524 ms, Inlining 0.000 ms, Optimization 1.015 ms, Emission 22.857 ms, Total 26.396 ms
--Execution Time: 2471.345 ms


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
		group by lfile_seq;
		
		create temporary table test3 as 
		select sum(cnt)
		from test2;	
	
		return 1;
	END;
$function$

--병렬쿼리 안됨 (사용자함수)
-- 3974
explain analyze
select public.fn_test();


CREATE OR REPLACE PROCEDURE public.ps_test2()
	LANGUAGE plpgsql
AS $procedure$
begin
		drop table if exists test1;
		drop table if exists test2;
		drop table if exists test3;
		
		create temporary table test1 as 
		select count(*) cnt
		from public.test_data
		where lfile_seq = 1297;
		
		create temporary table test2 
		as 
		select lfile_seq, count(*) cnt
		from public.test_data
		group by lfile_seq;
		
		create temporary table test3 as 
		select sum(cnt)
		from test2;	
end;
$procedure$

--병렬쿼리 됨 (프로시저)
-- plan은 auto explain으로 확인 가능
-- 3697
call public.ps_test2();


CREATE OR REPLACE PROCEDURE public.ps_test()
	LANGUAGE plpgsql
AS $procedure$
begin
		drop table if exists test1;
		drop table if exists test2;
		drop table if exists test3;
		
		create temporary table test1 as 
		select count(*) cnt
		from public.test_data
		where lfile_seq = 1297;
		commit;
		
		create temporary table test2 
		as 
		select lfile_seq, count(*) cnt
		from public.test_data
		group by lfile_seq;
		commit;
		
		create temporary table test3 as 
		select sum(cnt)
		from test2;	
end;
$procedure$

-- 2655
call public.ps_test();


---------------------------------------------------------------------------------------
-- # CTAS stating 처리 방법 별 성능 비교
-- unlogged(병렬) > logged(병렬) > temporary(단일)
-- temporary 테이블에서 select는 병렬 쿼리가 안 됨

drop table if exists test1;
drop table if exists test3;

create temporary table test1 as
select *
from public.test_data;
	
explain analyze	
		create temporary table test3 as 
		select lfile_seq, count(*) cnt
		from test1
		group by lfile_seq;	
	
-- HashAggregate  (cost=229138.63..229140.63 rows=200 width=12) (actual time=5336.762..5339.981 rows=13662 loops=1)
--   Group Key: lfile_seq
--   Batches: 1  Memory Usage: 2081kB
--   ->  Seq Scan on test1  (cost=0.00..199190.42 rows=5989642 width=4) (actual time=0.029..1998.098 rows=11206503 loops=1)
-- Planning Time: 0.117 ms
-- JIT:
--   Functions: 6
--   Options: Inlining false, Optimization false, Expressions true, Deforming true
--   Timing: Generation 1.090 ms, Inlining 0.000 ms, Optimization 1.496 ms, Emission 4.542 ms, Total 7.128 ms
-- Execution Time: 5347.380 ms


drop table if exists test1;
drop table if exists test3;

create table test1 as
select *
from public.test_data;
	
explain analyze	
		create temporary table test3 as 
		select lfile_seq, count(*) cnt
		from test1
		group by lfile_seq;	

-- Finalize GroupAggregate  (cost=177738.93..177789.60 rows=200 width=12) (actual time=4043.748..4063.862 rows=13662 loops=1)
--   Group Key: lfile_seq
--   ->  Gather Merge  (cost=177738.93..177785.60 rows=400 width=12) (actual time=4043.732..4055.343 rows=33226 loops=1)
--         Workers Planned: 2
--         Workers Launched: 2
--         ->  Sort  (cost=176738.91..176739.41 rows=200 width=12) (actual time=3948.072..3949.774 rows=11075 loops=3)
--               Sort Key: lfile_seq
--               Sort Method: quicksort  Memory: 913kB
--               Worker 0:  Sort Method: quicksort  Memory: 883kB
--               Worker 1:  Sort Method: quicksort  Memory: 916kB
--               ->  Partial HashAggregate  (cost=176729.26..176731.26 rows=200 width=12) (actual time=3940.279..3943.450 rows=11075 loops=3)
--                     Group Key: lfile_seq
--                     Batches: 1  Memory Usage: 1441kB
--                     Worker 0:  Batches: 1  Memory Usage: 1441kB
--                     Worker 1:  Batches: 1  Memory Usage: 1441kB
--                     ->  Parallel Seq Scan on test1  (cost=0.00..164250.84 rows=2495684 width=4) (actual time=0.047..1531.142 rows=3735501 loops=3)
-- Planning Time: 0.154 ms
-- JIT:
--   Functions: 21
--   Options: Inlining false, Optimization false, Expressions true, Deforming true
--   Timing: Generation 13.250 ms, Inlining 0.000 ms, Optimization 1.169 ms, Emission 35.617 ms, Total 50.036 ms
-- Execution Time: 4117.144 ms

drop table if exists test1;
drop table if exists test3;

create unlogged table test1 as
select *
from public.test_data;
	
explain analyze	
		create temporary table test3 as 
		select lfile_seq, count(*) cnt
		from test1
		group by lfile_seq;	

-- Finalize GroupAggregate  (cost=177738.93..177789.60 rows=200 width=12) (actual time=2549.194..2590.327 rows=13662 loops=1)
--   Group Key: lfile_seq
--   ->  Gather Merge  (cost=177738.93..177785.60 rows=400 width=12) (actual time=2549.178..2574.802 rows=36343 loops=1)
--         Workers Planned: 2
--         Workers Launched: 2
--         ->  Sort  (cost=176738.91..176739.41 rows=200 width=12) (actual time=2483.265..2485.960 rows=12114 loops=3)
--               Sort Key: lfile_seq
--               Sort Method: quicksort  Memory: 959kB
--               Worker 0:  Sort Method: quicksort  Memory: 946kB
--               Worker 1:  Sort Method: quicksort  Memory: 953kB
--               ->  Partial HashAggregate  (cost=176729.26..176731.26 rows=200 width=12) (actual time=2466.044..2472.832 rows=12114 loops=3)
--                     Group Key: lfile_seq
--                     Batches: 1  Memory Usage: 1825kB
--                     Worker 0:  Batches: 1  Memory Usage: 1441kB
--                     Worker 1:  Batches: 1  Memory Usage: 1441kB
--                     ->  Parallel Seq Scan on test1  (cost=0.00..164250.84 rows=2495684 width=4) (actual time=0.034..932.413 rows=3735501 loops=3)
-- Planning Time: 0.123 ms
-- JIT:
--   Functions: 21
--   Options: Inlining false, Optimization false, Expressions true, Deforming true
--   Timing: Generation 4.205 ms, Inlining 0.000 ms, Optimization 1.151 ms, Emission 28.188 ms, Total 33.544 ms
-- Execution Time: 2600.815 ms


---------------------------------------------------------------------------------------
-- # cursor, loop 병렬 처리 확인
-- The query might be suspended during execution. In any situation in which the system thinks that partial or incremental execution might occur, 
-- no parallel plan is generated. For example, a cursor created using DECLARE CURSOR will never use a parallel plan. Similarly, 
-- a PL/pgSQL loop of the form FOR x IN query LOOP .. END LOOP will never use a parallel plan, because the parallel query system is unable 
-- to verify that the code in the loop is safe to execute while parallel query is active.
-- 해당 문구가 loop 내부 쿼리가 병렬 쿼리가 안되는 게 아니라 declare의 쿼리가 병렬 쿼리가 안되는 것으로 판단됨 (테스트 결과 loop 내 병렬 쿼리 됨)
-- auto explain으로 확인

-- 테스트 용
create table list (
	num int 
);
insert into list values(1);
insert into list values(2);
insert into list values(3);


-- 단순 loop
do $$
begin 
for r in 1..3 loop

	drop table if exists test1;
	drop table if exists test3;
	
	create table test1 as
	select *
	from public.test_data;
		
	create temporary table test3 as 
	select lfile_seq, count(*) cnt
	from test1
	group by lfile_seq;


end loop;
end;
$$;	
	
-- for in loop
do $$
declare rec record;
begin

	FOR rec IN 
		select num from list
	LOOP

		Raise Notice 'rec : %', rec.num;

		drop table if exists test1;
		drop table if exists test3;
		
		create table test1 as
		select *
		from public.test_data;
			
		create temporary table test3 as 
		select lfile_seq, count(*) cnt, rec.num
		from test1
		group by lfile_seq;	
	
	
	END LOOP;

end;
$$;	

-- cursor loop
do $$
	declare rec record;
	DECLARE _REF_CURSOR2 refcursor;
begin

	OPEN _REF_CURSOR2 FOR
		select num from list;

	FETCH NEXT FROM _REF_CURSOR2 INTO rec;
        			
	WHILE FOUND
	loop

		Raise Notice 'rec : %', rec.num;

		drop table if exists test1;
		drop table if exists test3;
		
		create table test1 as
		select *
		from public.test_data;
			
		create temporary table test3 as 
		select lfile_seq, count(*) cnt, rec.num
		from test1
		group by lfile_seq;	

		FETCH NEXT FROM _REF_CURSOR2 INTO rec;
	end loop;
	close _REF_CURSOR2;
	
end;
$$;	

