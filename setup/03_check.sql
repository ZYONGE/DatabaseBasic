-- ============================================================
-- setup/03_check.sql
-- 02_sample_data.sql 실행 후 테이블 구조와 데이터가 제대로 들어갔는지 확인하는 스크립트.
-- 출처: 0930 실습
-- ============================================================

-- [DESC] 테이블의 애트리뷰트 이름·데이터 타입·NOT NULL 여부 확인 (SQL*Plus / SQL Developer 명령)
desc DEPARTMENT;
desc EMPLOYEE;

-- [SELECT *] 입력된 투플 전체 확인
select * from DEPARTMENT;
select * from EMPLOYEE;
