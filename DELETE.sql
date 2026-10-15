-- ============================================================
-- DELETE.sql
-- DML - 삭제
--
-- 목차
--   1. DELETE ... WHERE
--   2. ON DELETE CASCADE
-- ============================================================


-- ############################################################
-- 1. DELETE ... WHERE
-- DELETE ... WHERE: 조건을 만족하는 투플 삭제
-- (참조 투플까지 연쇄 삭제는 2번 섹션, 테이블 자체 제거는 DROP.sql)
-- 출처: 1014 강의 (교재 4.2 그림 4.4, 4.5)
-- ############################################################

-- ===== DELETE문 형식 =====
-- [형식] WHERE 조건을 만족하는 투플을 삭제, WHERE를 생략하면 모든 투플 삭제
--   투플만 지워지고 릴레이션 정의는 남음 (릴레이션 자체를 없애는 DROP TABLE과 다름)
DELETE FROM 릴레이션
WHERE  조건;

-- ===== 4.2 그림 4.4 예 =====
-- [DELETE] DEPARTMENT에서 DEPTNAME이 '총무'인 투플을 삭제 (WHERE 절을 생략하면 모든 투플이 삭제됨)
DELETE FROM DEPARTMENT WHERE DEPTNAME = '총무';

-- ===== 4.5 예) 4번 부서 삭제 =====
-- [DELETE] DEPTNO가 4인 투플 삭제 (이 부서를 참조하는 투플이 있으면 참조 무결성 옵션에 따라 거부 또는 연쇄 처리)
DELETE FROM DEPARTMENT
WHERE  DEPTNO = 4;


-- ############################################################
-- 2. ON DELETE CASCADE
-- ON DELETE CASCADE에 의한 연쇄 삭제
-- (EMPLOYEE의 DNO 외래 키가 ON DELETE CASCADE로 정의되어 있어야 함
--  → setup/02_sample_data.sql 또는 CREATE.sql 3번)
-- 출처: 1014 강의 (교재 4.3)
-- ############################################################

-- [DELETE] 3번 부서 투플 삭제 → ON DELETE CASCADE 때문에 DNO = 3인 EMPLOYEE 투플(이수민, 최종철)도 연쇄 삭제
--   FROM 생략은 Oracle에서 허용되는 형태, 표준 SQL은 DELETE FROM DEPARTMENT
DELETE DEPARTMENT
WHERE DEPTNO = 3;
