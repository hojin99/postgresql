-- https://www.postgresql.org/docs/10/runtime-config-resource.html
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
--HashAggregate  (cost=20133.16..20135.16 rows=200 width=12) (actual time=491.584..491.947 rows=1114 loops=1)
--  Group Key: lfile_seq
--  Buffers: local read=12239 written=1024
--  ->  Seq Scan on test2  (cost=0.00..17501.77 rows=526277 width=4) (actual time=0.023..180.483 rows=985797 loops=1)
--        Buffers: local read=12239 written=1024
--Planning time: 0.129 ms
--Execution time: 493.012 ms

--HashAggregate  (cost=20133.16..20135.16 rows=200 width=12) (actual time=351.997..352.187 rows=1114 loops=1)
--  Group Key: lfile_seq
--  Buffers: local read=12239 written=1024
--  ->  Seq Scan on test2  (cost=0.00..17501.77 rows=526277 width=4) (actual time=0.020..136.469 rows=985797 loops=1)
--        Buffers: local read=12239 written=1024
--Planning time: 0.102 ms
--Execution time: 352.846 ms

--# temp_buffers 200MB
--HashAggregate  (cost=20133.16..20135.16 rows=200 width=12) (actual time=1173.277..1173.592 rows=1114 loops=1)
--  Group Key: lfile_seq
--  Buffers: local hit=12239
--  ->  Seq Scan on test2  (cost=0.00..17501.77 rows=526277 width=4) (actual time=0.008..408.029 rows=985797 loops=1)
--        Buffers: local hit=12239
--Planning time: 0.126 ms
--Execution time: 1174.583 ms

--HashAggregate  (cost=20133.16..20135.16 rows=200 width=12) (actual time=365.154..365.420 rows=1114 loops=1)
--  Group Key: lfile_seq
--  Buffers: local hit=12239
--  ->  Seq Scan on test2  (cost=0.00..17501.77 rows=526277 width=4) (actual time=0.006..125.951 rows=985797 loops=1)
--        Buffers: local hit=12239
--Planning time: 0.150 ms
--Execution time: 366.387 ms


----------------------------2백만건-----------------------------------------------

--# temp_buffers 8MB

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=944.106..944.814 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Buffers: local read=26309 written=1024
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.032..385.158 rows=2117767 loops=1)
--        Buffers: local read=26309 written=1024
--Planning time: 0.206 ms
--Execution time: 946.549 ms

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=753.886..754.328 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Buffers: local read=26309 written=1024
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.037..287.179 rows=2117767 loops=1)
--        Buffers: local read=26309 written=1024
--Planning time: 0.095 ms
--Execution time: 755.707 ms

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=784.079..784.702 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Buffers: local read=26309 written=1024
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.026..295.716 rows=2117767 loops=1)
--        Buffers: local read=26309 written=1024
--Planning time: 0.115 ms
--Execution time: 786.772 ms

--# temp_buffers 600MB

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=676.457..676.878 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Buffers: local hit=26309
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.007..228.928 rows=2117767 loops=1)
--        Buffers: local hit=26309
--Planning time: 0.140 ms
--Execution time: 678.091 ms

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=612.072..612.691 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Buffers: local hit=26309
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.005..207.588 rows=2117767 loops=1)
--        Buffers: local hit=26309
--Planning time: 0.090 ms
--Execution time: 613.946 ms

--HashAggregate  (cost=43278.31..43280.31 rows=200 width=12) (actual time=691.236..691.843 rows=2494 loops=1)
--  Group Key: lfile_seq
--  Buffers: local hit=26309
--  ->  Seq Scan on test2  (cost=0.00..37621.87 rows=1131287 width=4) (actual time=0.007..230.686 rows=2117767 loops=1)
--        Buffers: local hit=26309
--Planning time: 0.132 ms
--Execution time: 693.304 ms
