-- ============================================================
-- CREATE.sql
-- DDL - 객체 생성
--
-- 목차
--   1. 스키마 생성
--   2. 테이블 정의
--   3. 제약조건을 포함한 테이블 정의
--   4. 인덱스
--   5. 트리거
--   6. 주장(assertion)
-- ============================================================


-- ############################################################
-- 1. 스키마 생성
-- 스키마 생성 (제거는 DROP.sql)
-- 출처: 1014 강의 (교재 4.3)
-- ############################################################

-- [CREATE SCHEMA] MY_DB 스키마를 생성하고, AUTHORIZATION 절로 스키마의 소유자를 kim으로 지정
CREATE SCHEMA MY_DB AUTHORIZATION kim;


-- ############################################################
-- 2. 테이블 정의
-- 기본 릴레이션(테이블) 정의 — 애트리뷰트 이름 + 데이터 타입 + 키
-- 제약조건 위주의 정의는 3번 섹션 참고
-- 출처: 1014 강의 (교재 그림 4.6), 0930 실습 (PROJECT)
-- ############################################################

-- ===== 릴레이션 정의 (그림 4.6) =====
-- [CREATE TABLE] EMPLOYEE 릴레이션 정의. 각 항목은 "애트리뷰트 이름 + 데이터 타입 [+ 제약조건]" 형식
--   NUMBER: 숫자형 / CHAR(n): 길이 n의 고정길이 문자열
--   NOT NULL: EMPNO에 널값을 허용하지 않음
--   PRIMARY KEY (EMPNO): EMPNO를 기본 키로 지정 → 각 투플을 유일하게 식별
--   FOREIGN KEY (MANAGER) REFERENCES EMPLOYEE(EMPNO): MANAGER는 같은 릴레이션의 EMPNO를 참조 (자기 참조 외래 키)
--   FOREIGN KEY (DNO) REFERENCES DEPARTMENT(DEPTNO): DNO에는 DEPARTMENT의 DEPTNO에 존재하는 값(또는 널)만 허용
CREATE TABLE EMPLOYEE
 (EMPNO    NUMBER NOT NULL,
  EMPNAME  CHAR(10),
  TITLE    CHAR(10),
  MANAGER  NUMBER,
  SALARY   NUMBER,
  DNO      NUMBER,
  PRIMARY KEY (EMPNO),
  FOREIGN KEY (MANAGER) REFERENCES EMPLOYEE(EMPNO),
  FOREIGN KEY (DNO) REFERENCES DEPARTMENT(DEPTNO));

-- ===== PROJECT 테이블 (0930 실습) =====
-- [CREATE TABLE] 키 없이 NOT NULL 제약만 있는 간단한 테이블 (컬럼 추가·삭제 실습은 ALTER.sql 1번)
CREATE TABLE PROJECT
(
    Projno NUMBER NOT NULL,
    Projname CHAR(15) NOT NULL,
    Budget NUMBER
);

-- [DESC] 방금 만든 PROJECT의 애트리뷰트 이름·데이터 타입·NOT NULL 여부를 출력해 정의가 맞는지 확인
--   DESC(DESCRIBE)는 표준 SQL이 아닌 SQL*Plus / SQL Developer 명령이라 세미콜론 없이도 실행됨
desc PROJECT;


-- ############################################################
-- 3. 제약조건을 포함한 테이블 정의
-- CREATE TABLE 시점에 무결성 제약조건 지정
-- (기존 테이블에 제약조건 추가·삭제는 ALTER.sql 2번)
-- 출처: 1014 강의 (교재 그림 4.7)
-- ############################################################

-- ===== 제약조건 (그림 4.7) =====
-- [CREATE TABLE + 제약조건]
--   애트리뷰트 단위 제약조건: "이름 타입 [DEFAULT 값] [제약조건]" 순서로 애트리뷰트 정의 바로 뒤에 기술
--   릴레이션 단위 제약조건: PRIMARY KEY, FOREIGN KEY처럼 모든 애트리뷰트 정의 뒤에 별도 항목으로 기술
--   DEFAULT: INSERT 시 값을 주지 않으면 널 대신 지정한 기본값이 들어감
--   CHECK (조건): 조건을 만족하지 않는 값의 삽입·수정을 거부
--   ON DELETE CASCADE: 참조되는 DEPARTMENT 투플이 삭제되면 그 부서를 참조하는 EMPLOYEE 투플도 함께 삭제
--                      (실제 삭제 예는 DELETE.sql 2번)
CREATE TABLE EMPLOYEE
 (EMPNO    NUMBER   NOT NULL,                              -- (1) 널 금지
  EMPNAME  CHAR(10) UNIQUE,                                -- (2) 중복 금지
  TITLE    CHAR(10) DEFAULT '사원',                         -- (3) 기본값
  MANAGER  NUMBER,
  SALARY   NUMBER   CHECK (SALARY < 6000000),              -- (4) 값 범위 체크
  DNO      NUMBER   DEFAULT 1 CHECK (DNO IN (1,2,3,4,5,6)), -- (5) 기본값 + 체크 (DEFAULT가 제약조건보다 앞)
  PRIMARY KEY (EMPNO),                                     -- (6) 기본 키
  FOREIGN KEY (MANAGER) REFERENCES EMPLOYEE(EMPNO),        -- (7) 외래 키(자기 참조)
  FOREIGN KEY (DNO) REFERENCES DEPARTMENT(DEPTNO)          -- (8) 외래 키
        ON DELETE CASCADE);                                -- (9) 참조 무결성 유지 옵션

-- ===== 여러 애트리뷰트에 걸친 CHECK =====
-- [CREATE TABLE + 릴레이션 단위 CHECK] 두 애트리뷰트를 비교하는 조건은 한 애트리뷰트에 붙일 수 없으므로
--   애트리뷰트 정의 뒤에 별도의 CHECK (조건)로 기술 → MANAGER_SALARY > SALARY인 투플만 삽입·수정 허용
CREATE TABLE EMPLOYEE (
  ID NUMBER,
  NAME CHAR(10),
  SALARY NUMBER,
  MANAGER_SALARY NUMBER,
  CHECK (MANAGER_SALARY > SALARY));


-- ############################################################
-- 4. 인덱스
-- 인덱스 생성
-- 출처: 1014 강의 (교재 4.3)
-- ############################################################

-- [CREATE INDEX] EMPLOYEE의 DNO 애트리뷰트에 EMPDNO_IDX 인덱스 생성 → DNO를 조건으로 하는 검색 속도 향상
CREATE INDEX EMPDNO_IDX ON EMPLOYEE(DNO);    -- 인덱스 생성


-- ############################################################
-- 5. 트리거
-- 트리거: 이벤트-조건-동작(ECA) 규칙
-- 출처: 1014 강의 (교재 4.6)
-- ############################################################

-- ===== SQL3 트리거 형식 =====
-- [형식] 트리거는 이벤트-조건-동작(ECA) 규칙
--   이벤트(INSERT, DELETE, UPDATE)가 발생하고 WHEN 조건이 참이면 BEGIN ~ END 안의 동작을 자동 수행
CREATE TRIGGER <트리거 이름>
AFTER <OR로 연결된 이벤트 리스트> ON <릴레이션>   -- 이벤트
[WHEN <조건>]                                   -- 조건
BEGIN <SQL문(들)> END                           -- 동작

-- ===== 트리거 예 =====
-- [CREATE TRIGGER] 신입 사원의 급여가 150만 미만이면 자동으로 10% 인상
--   AFTER INSERT ON EMPLOYEE: EMPLOYEE에 투플이 삽입된 후에 동작
--   REFERENCING NEW AS newEmployee: 새로 삽입된 투플을 newEmployee라는 이름으로 참조
--   FOR EACH ROW: 삽입된 투플마다 한 번씩 수행 (행 단위 트리거, 생략하면 문장 단위)
--   WHEN (...): 조건이 참일 때만 동작 수행
--   UPDATE ...: 동작. SET 왼쪽에는 갱신할 릴레이션의 애트리뷰트 이름만 올 수 있으므로 SALARY로 기술
--   동작이 SQL문 1개뿐이라 BEGIN ~ END 생략
CREATE TRIGGER RAISE_SALARY
AFTER INSERT ON EMPLOYEE
REFERENCING NEW AS newEmployee
FOR EACH ROW
WHEN (newEmployee.SALARY < 1500000)
UPDATE EMPLOYEE
SET    SALARY = SALARY * 1.1
WHERE  EMPNO = newEmployee.EMPNO;


-- ############################################################
-- 6. 주장(assertion)
-- 주장(assertion): 여러 릴레이션에 걸친 제약조건
-- 출처: 1014 강의 (교재 4.6)
-- ############################################################

-- ===== 주장(assertion) 형식 =====
-- [형식] 여러 릴레이션에 걸친 제약조건을 정의, CHECK 조건은 항상 참이어야 하며 이를 위배하는 갱신은 거부됨
CREATE ASSERTION 이름
CHECK 조건;

-- ===== 주장 예 =====
-- STUDENT(STNO, STNAME, EMAIL, ADDRESS, PHONE)
-- ENROLL(STNO, COURSENO, GRADE)
-- [CREATE ASSERTION] "ENROLL의 학번 중 STUDENT에 없는 학번이 존재하지 않는다" → 참조 무결성을 주장으로 표현
--   NOT EXISTS: 중첩 질의 결과가 공집합이어야 참 / NOT IN: STUDENT의 STNO 목록에 없는 값
--   표준 SQL 문법이며 Oracle, MySQL 등 대부분의 DBMS는 지원하지 않음
CREATE ASSERTION EnrollStudentIntegrity
CHECK (NOT EXISTS
        (SELECT *
         FROM   ENROLL
         WHERE  STNO NOT IN (SELECT STNO FROM STUDENT)));
