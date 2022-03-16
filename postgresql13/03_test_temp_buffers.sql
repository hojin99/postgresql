-- https://www.postgresql.org/docs/13/runtime-config-resource.html
--set temp_buffers to '600MB';
--show temp_buffers;

drop table if exists test1;
drop table if exists test2;
drop table if exists test3;

create temporary table test2 as 
select *
from public.test_data
where lfile_seq < 20000;	

explain (analyze, buffers)
create temporary table test3 as 
select lfile_seq, count(*) cnt
from test2
group by lfile_seq;	

-- temp buffers를 늘려서, temp table의 cache hit를 유도해서 성능 개선을 예상
-- 의도한 대로, cache hit가 되었지만, 처리시간은 평균 적으로 오히려 늘어나거나 비슷함

----------------------------1백만건-----------------------------------------------

--# temp_buffers 8MB
--HashAggregate  (cost=20133.16..20135.16 rows=200 width=12) (actual time=402.684..402.872 rows=1114 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 209kB
--  Buffers: local read=12239 written=1024
--  ->  Seq Scan on test2  (cost=0.00..17501.77 rows=526277 width=4) (actual time=0.023..133.893 rows=985797 loops=1)
--        Buffers: local read=12239 written=1024
--Planning:
--  Buffers: shared hit=43
--Planning Time: 0.165 ms
--Execution Time: 403.672 ms

--HashAggregate  (cost=20133.16..20135.16 rows=200 width=12) (actual time=417.042..417.320 rows=1114 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 209kB
--  Buffers: local read=12239 written=1024
--  ->  Seq Scan on test2  (cost=0.00..17501.77 rows=526277 width=4) (actual time=0.027..147.389 rows=985797 loops=1)
--        Buffers: local read=12239 written=1024
--Planning:
--  Buffers: shared hit=43
--Planning Time: 0.485 ms
--Execution Time: 418.411 ms


--# temp_buffers 200MB
--HashAggregate  (cost=20133.16..20135.16 rows=200 width=12) (actual time=482.206..482.486 rows=1114 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 209kB
--  Buffers: local hit=12239
--  ->  Seq Scan on test2  (cost=0.00..17501.77 rows=526277 width=4) (actual time=0.007..176.401 rows=985797 loops=1)
--        Buffers: local hit=12239
--Planning:
--  Buffers: shared hit=30
--Planning Time: 0.092 ms
--Execution Time: 489.104 ms

--HashAggregate  (cost=20133.16..20135.16 rows=200 width=12) (actual time=511.349..511.622 rows=1114 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 209kB
--  Buffers: local hit=12239
--  ->  Seq Scan on test2  (cost=0.00..17501.77 rows=526277 width=4) (actual time=0.009..156.869 rows=985797 loops=1)
--        Buffers: local hit=12239
--Planning:
--  Buffers: shared hit=43
--Planning Time: 0.148 ms
--Execution Time: 512.912 ms


----------------------------2백만건-----------------------------------------------

--# temp_buffers 8MB

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=786.291..786.824 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 385kB
--  Buffers: local read=26309 written=1024
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.017..278.477 rows=2117767 loops=1)
--        Buffers: local read=26309 written=1024
--Planning:
--  Buffers: shared hit=30
--Planning Time: 0.085 ms
--Execution Time: 788.537 ms

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=711.861..712.267 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 385kB
--  Buffers: local read=26309 written=1024
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.020..238.433 rows=2117767 loops=1)
--        Buffers: local read=26309 written=1024
--Planning:
--  Buffers: shared hit=30
--Planning Time: 0.079 ms
--Execution Time: 713.314 ms

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=804.226..804.791 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 385kB
--  Buffers: local read=26309 written=1024
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.015..286.509 rows=2117767 loops=1)
--        Buffers: local read=26309 written=1024
--Planning:
--  Buffers: shared hit=30
--Planning Time: 0.130 ms
--Execution Time: 806.299 ms

--# temp_buffers 600MB

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=794.280..794.842 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 385kB
--  Buffers: local hit=26309
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.006..239.186 rows=2117767 loops=1)
--        Buffers: local hit=26309
--Planning:
--  Buffers: shared hit=30
--Planning Time: 0.079 ms
--Execution Time: 796.205 ms

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=795.681..796.082 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 385kB
--  Buffers: local hit=26309
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.006..244.388 rows=2117767 loops=1)
--        Buffers: local hit=26309
--Planning:
--  Buffers: shared hit=30
--Planning Time: 0.098 ms
--Execution Time: 797.179 ms

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=730.969..731.629 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Batches: 1  Memory Usage: 385kB
--  Buffers: local hit=26309
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.008..218.069 rows=2117767 loops=1)
--        Buffers: local hit=26309
--Planning:
--  Buffers: shared hit=30
--Planning Time: 0.123 ms
--Execution Time: 733.157 ms