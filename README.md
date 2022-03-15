# postgresql


### 병렬 쿼리
https://www.postgresql.org/docs/13/when-can-parallel-query-be-used.html  
https://www.postgresql.org/docs/10/when-can-parallel-query-be-used.html  

	• 병렬 쿼리가 도는 조건 (pg 13 기준)

		○ max_parallel_workers_per_gather는 0보다 더 큰 수가 되야 함
	
		○  write, lock 발생하는 경우 병렬 처리 안됨(CTAS, SELECT INTO는 병렬 처리 가능)
	
		○ 쿼리가 실행 중인 경우는 병렬 처리 안됨 (declare cursor, for in loop end loop)
	
		○ 사용자 정의 함수 (PARALLEL UNSAFE)
			CREATE FUNCTION이 PARALLEL SAFE로 지정해도 unsafe한 경우는 오동작 가능
	
		○ 시스템 상황에 따라서
			max_worker_processes 관련 
			max_parallel_workers 관련
		
		
	• 병렬 쿼리가 도는 조건 (pg 10 기준)
	
		○ max_parallel_workers_per_gather는 0보다 더 큰 수가 되야 함
		○ dynamic_shared_memory_type must be set to a value other than none
	
		○ write, lock 발생하는 경우는 병렬 처리 안됨
	
		○ 쿼리가 실행 중인 경우는 병렬 처리 안됨 (declare cursor, for in loop end loop)
	
		○ 사용자 정의 함수 (PARALLEL UNSAFE)
	
		○ 시스템 상황에 따라서
			max_worker_processes 관련 
			max_parallel_workers 관련
            isolation level이 serializable
