FROM postgis/postgis:13-master

# 기본 패키지 설치 
RUN apt-get update
RUN apt-get -y install vim
RUN apt-get -y install net-tools
RUN apt-get -y install iputils-ping
RUN apt-get -y install netcat

# 환경 변수 설정
ENV POSTGRES_DB=postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=1234

# EXTENSION 추가 작업
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-extension.sh /docker-entrypoint-initdb.d/00_extension.sh

# 초기화 sh, sql 실행
COPY ./init*.sql /docker-entrypoint-initdb.d/
