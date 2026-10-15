-- ============================================================
-- ALTER.sql
-- DDL - 객체 변경
--
-- 목차
--   1. 컬럼 추가·삭제
--   2. 제약조건 추가·삭제
-- ============================================================


-- ############################################################
-- 1. 컬럼 추가·삭제
-- 기존 테이블에 애트리뷰트(컬럼) 추가·삭제
-- 출처: 1014 강의 (교재 4.3), 0930 실습 (PROJECT)
-- ############################################################

-- [ALTER TABLE ... ADD] 기존 EMPLOYEE에 CHAR(13) 타입의 PHONE 애트리뷰트 추가 (기존 투플의 PHONE 값은 널)
ALTER TABLE EMPLOYEE ADD PHONE CHAR(13);     -- 애트리뷰트 추가

-- ===== PROJECT 테이블 (0930 실습, CREATE.sql 2번에서 생성) =====
-- [ALTER TABLE ... ADD] PROJECT에 NUMBER 타입의 Manager 애트리뷰트 추가
--   형식: ALTER TABLE 릴레이션 ADD 애트리뷰트 데이터타입 / 이미 있는 투플의 Manager 값은 널로 채워짐
ALTER TABLE PROJECT
ADD Manager NUMBER;

-- [ALTER TABLE ... DROP COLUMN] 방금 추가한 Manager 애트리뷰트를 정의와 저장된 값까지 함께 삭제
--   형식: ALTER TABLE 릴레이션 DROP COLUMN 애트리뷰트 / 다른 제약조건이 참조 중인 컬럼은 삭제가 거부됨
ALTER TABLE PROJECT DROP COLUMN Manager;


-- ############################################################
-- 2. 제약조건 추가·삭제
-- 기존 테이블에 무결성 제약조건 추가·삭제
-- (테이블 생성 시점의 제약조건은 CREATE.sql 3번)
-- 출처: 1014 강의 (교재 4.3)
-- ############################################################

-- [ALTER TABLE ... ADD CONSTRAINT] 기존 STUDENT에 STUDENT_PK라는 이름으로 기본 키 제약조건(STNO) 추가
ALTER TABLE STUDENT ADD CONSTRAINT STUDENT_PK PRIMARY KEY (STNO);
-- [ALTER TABLE ... DROP CONSTRAINT] 이름(STUDENT_PK)으로 제약조건 삭제 → 제약조건에 이름을 붙여 두어야 나중에 지정해서 삭제 가능
ALTER TABLE STUDENT DROP CONSTRAINT STUDENT_PK;
