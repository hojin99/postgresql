-- 사용하지 않는 인덱스 조회
SELECT
    schemaname AS schema_name,
    relname AS table_name,
    indexrelname AS index_name,
    pg_size_pretty(pg_relation_size(indexrelid::regclass)) AS index_size,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
where 1=1
and indexrelname not like '%인덱스명%'
ORDER BY idx_scan ASC;

-- 테이블 용량 확인
SELECT relname, relkind, reltuples, relpages
FROM pg_class
WHERE relname LIKE '테이블명%';

-- 테이블 선택도 확인
SELECT attname, n_distinct
FROM pg_stats
WHERE tablename = '테이블명';

-- 테이블에 대한 쿼리 Access 패턴 확인
select *
from pg_stat_statements
where query like '%tm_model_param_xml%'
and query like '%select%';

