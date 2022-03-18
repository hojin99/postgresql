# postgresql

## 환경

* WSL 환경에서 docker 컨테이너로 DB 실행  
	- WSL 한계로 인하여 윈도우즈 디렉토리로 볼륨 mount는 안되며, docker volume으로 구성됨  
* Dockerbuild.sh를 하면 DB 초기 상태까지 만들어지며, test*.sql을 이용해서 테스트  
* 단, postgresql.conf는 빌드 시 포함이 안되기 때문에 현재는 직접 복사해 줘야 함
	- 위치 : /var/lib/postgresql/data/postgresql.conf  

## 실행

* docker 이미지 생성
`./Dockerbuild.sh`  

* docker 컨테이너 실행
`./docker-compose up -d`  

* docker 컨테이너 종료
`./docker-compose stop`  

* docker 컨테이너 삭제
`./docker-compose rm -fsv`  

## 참조

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

### temp_buffers 설정
https://postgresqlco.nf/doc/en/param/temp_buffers/#:~:text=Sets%20the%20maximum%20amount%20of,is%20BLCKSZ%20bytes%2C%20typically%208kB  
https://madusudanan.com/blog/understanding-postgres-caching-in-depth/  
https://www.sites.google.com/site/itmyshare/database-tips-and-examples/postgres/postgresql-buffering  

	* temp table에서 사용 가능한 최대 메모리를 설정함  
	* 세션 별로 메모리가 사용되기 때문의 주의 필요  
	* set temp_buffers = '100MB' - 세션 별로도 지정 가능  
	* 초기값은 8MB  
	* 최대 메모리를 넘어가면, disk read가 일어남  
	* 단, 테스트 결과 대부분 OS cache hit가 되어 성능 상 큰 차이 없었음  
	* 적용 후 효과가 입증 되는 경우 세션 별로 필요할 경우 신중히 사용 필요하다고 판단됨  
