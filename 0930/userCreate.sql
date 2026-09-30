-- ============================================================
-- userCreate.sql
-- 관리자 계정(system 등)으로 접속해서 실행하는 스크립트.
-- 실습용 사용자 KIM, LEE를 만들고 필요한 권한을 준다.
-- ============================================================

-- KIM, LEE 사용자 생성하기
-- CREATE USER 사용자명 IDENTIFIED BY 비밀번호
--   DEFAULT TABLESPACE   : 이 사용자가 만드는 테이블·인덱스가 저장될 기본 공간 (users)
--   TEMPORARY TABLESPACE : 정렬(ORDER BY)·해시 조인 등 임시 작업에 쓰는 공간 (temp)
CREATE USER KIM IDENTIFIED BY bluesky
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp;

CREATE USER LEE IDENTIFIED BY redsun
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp;

-- Grant 명령으로 접속, 사용 권한 주기
--   connect        : 접속용 롤 (CREATE SESSION 포함)
--   resource       : 테이블·시퀀스·프로시저 등 객체를 만들 수 있는 롤
--   create session : DB에 로그인할 수 있는 시스템 권한 (connect에 이미 들어 있지만 명시적으로 한 번 더 부여)
--   create view    : 뷰 생성 권한. resource 롤에는 없어서 따로 줘야 sampledata.sql의 CREATE VIEW가 성공함
-- 참고: Oracle 12c 이상에서는 resource 롤이 테이블스페이스 사용량(quota)을 주지 않는다.
--       INSERT 시 ORA-01950 오류가 나면 아래처럼 quota를 추가로 부여한다.
--       ALTER USER KIM QUOTA UNLIMITED ON users;
grant connect, resource, create session, create view to KIM;
grant connect, resource, create session, create view to LEE;
