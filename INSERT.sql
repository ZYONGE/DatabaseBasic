-- ============================================================
-- INSERT.sql
-- DML - 삽입
--
-- 목차
--   1. INSERT ... VALUES
--   2. INSERT ... SELECT
-- ============================================================


-- ############################################################
-- 1. INSERT ... VALUES
-- INSERT ... VALUES: 투플 1개 삽입
-- (질의 결과로 여러 투플 삽입은 2번 섹션)
-- 출처: 1014 강의 (교재 4.2 그림 4.4, 4.5)
-- ############################################################

-- ===== INSERT문 형식 (한 투플) =====
-- [형식] 나열한 애트리뷰트에 VALUES의 값을 순서대로 대응시켜 투플 1개 삽입
--   애트리뷰트 목록을 생략하면 릴레이션의 모든 애트리뷰트에 정의된 순서대로 값을 줘야 함
INSERT INTO 릴레이션(애트리뷰트1, ..., 애트리뷰트n)
VALUES (값1, ..., 값n);

-- ===== 4.2 그림 4.4 예 =====
-- [INSERT] 애트리뷰트 목록을 생략했으므로 CREATE TABLE에 정의된 순서(DEPTNO, DEPTNAME, FLOOR)대로 값을 넣어 투플 1개 삽입
INSERT INTO DEPARTMENT VALUES (5, '연구', 9);

-- ===== 4.5 예) DEPARTMENT에 (5, 연구, NULL) 삽입 =====
-- [INSERT ... VALUES] 값을 모르는 FLOOR에는 NULL을 명시해 널값 삽입
INSERT INTO DEPARTMENT VALUES (5, '연구', NULL);


-- ############################################################
-- 2. INSERT ... SELECT
-- INSERT ... SELECT: 질의 결과의 여러 투플을 한 번에 삽입
-- 출처: 1014 강의 (교재 4.5)
-- ############################################################

-- ===== INSERT문 형식 (여러 투플) =====
-- [형식] VALUES 대신 SELECT문을 쓰면 질의 결과의 모든 투플이 한 번에 삽입됨
INSERT INTO 릴레이션(애트리뷰트1, ..., 애트리뷰트n)
SELECT ... FROM ... WHERE ...;

-- 예) 급여 300만 이상 사원을 HIGH_SALARY에 삽입 (HIGH_SALARY는 이미 생성되어 있다고 가정)
-- [INSERT ... SELECT] SELECT 결과의 EMPNAME, TITLE, SALARY가 각각 ENAME, TITLE, SAL에 순서대로 들어감
INSERT INTO HIGH_SALARY(ENAME, TITLE, SAL)
SELECT EMPNAME, TITLE, SALARY
FROM   EMPLOYEE
WHERE  SALARY >= 3000000;
