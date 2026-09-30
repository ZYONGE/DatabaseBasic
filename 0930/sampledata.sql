-- ============================================================
-- sampledata.sql
-- userCreate.sql로 만든 사용자(KIM 등)로 접속해서 실행하는 스크립트.
-- 부서(DEPARTMENT)·사원(EMPLOYEE) 테이블과 기획부 사원 뷰(EMP_PLANNING)를 만든다.
-- EMPLOYEE가 DEPARTMENT를 참조하므로 DEPARTMENT를 먼저 만들고 데이터를 넣어야 한다.
-- ============================================================

-- DEPARTMENT 테이블 생성
--   DEPTNO   : 부서번호. NOT NULL + PRIMARY KEY → 중복 불가, 비워둘 수 없음
--   DEPTNAME : 부서이름. CHAR(10)은 고정 길이라 남는 자리를 공백으로 채움
--   FLOOR    : 부서가 있는 층
CREATE TABLE DEPARTMENT (
	DEPTNO	NUMBER	NOT NULL,
	DEPTNAME	CHAR(10),
	FLOOR		NUMBER,
	PRIMARY KEY(DEPTNO)
);

-- 부서 데이터 4건 입력: VALUES(부서번호, 부서이름, 층)
INSERT INTO DEPARTMENT VALUES(1, '영업', 8);
INSERT INTO DEPARTMENT VALUES(2, '기획', 10);
INSERT INTO DEPARTMENT VALUES(3, '개발', 9);
INSERT INTO DEPARTMENT VALUES(4, '총무', 7);

-- EMPLOYEE 테이블 생성
--   EMPNO   : 사원번호 (기본키)
--   EMPNAME : 사원이름. UNIQUE → 같은 이름을 두 번 넣을 수 없음
--   TITLE   : 직급. 값을 주지 않으면 DEFAULT로 '사원'이 들어감
--   MANAGER : 직속 상사의 사원번호. 같은 테이블의 EMPNO를 참조하는 자기 참조 외래키
--   SALARY  : 급여. CHECK 제약으로 600만 원 미만만 허용
--   DNO     : 소속 부서번호. 기본값 1, CHECK로 1~4만 허용, DEPARTMENT(DEPTNO)를 참조
--   ON DELETE CASCADE : 부서를 삭제하면 그 부서 소속 사원 행도 함께 삭제됨
CREATE TABLE EMPLOYEE (
	EMPNO	NUMBER	NOT NULL,
	EMPNAME	CHAR(10)	UNIQUE,
	TITLE	CHAR(10)	DEFAULT '사원',
	MANAGER	NUMBER,
	SALARY NUMBER	CHECK (SALARY < 6000000),
	DNO	NUMBER DEFAULT 1 CHECK (DNO IN (1,2,3,4)),
	PRIMARY KEY(EMPNO),
  FOREIGN KEY(MANAGER) REFERENCES EMPLOYEE(EMPNO),
	FOREIGN KEY(DNO) REFERENCES DEPARTMENT(DEPTNO) ON DELETE CASCADE
);

-- 사원 데이터 7건 입력: VALUES(사원번호, 이름, 직급, 상사번호, 급여, 부서번호)
-- MANAGER 외래키 때문에 상사가 먼저 들어가 있어야 함
--   → 상사가 없는 사장(4377, MANAGER=NULL)을 가장 먼저 넣고,
--     그 다음 사장을 상사로 둔 사원, 그 아래 사원 순서로 입력
INSERT INTO EMPLOYEE VALUES(4377, '이성래', '사장', NULL, 5000000, 2);
INSERT INTO EMPLOYEE VALUES(3426, '박영권', '과장', 4377, 3000000, 1);
INSERT INTO EMPLOYEE VALUES(3011, '이수민', '부장', 4377, 4000000, 3);
INSERT INTO EMPLOYEE VALUES(3427, '최종철', '사원', 3011, 1500000, 3);
INSERT INTO EMPLOYEE VALUES(1003, '조민희', '과장', 4377, 3000000, 2);
INSERT INTO EMPLOYEE VALUES(2106, '김창섭', '대리', 1003, 2500000, 2);
INSERT INTO EMPLOYEE VALUES(1365, '김상원', '사원', 3426, 1500000, 1);

-- EMP_PLANNING 뷰 생성
-- 기획부 사원의 이름·직급·급여만 보여주는 가상 테이블.
-- EMPLOYEE(E)와 DEPARTMENT(D)를 부서번호(E.DNO = D.DEPTNO)로 조인한 뒤
-- 부서이름이 '기획'인 행만 골라냄 → 결과: 이성래, 조민희, 김창섭
-- 뷰는 데이터를 따로 저장하지 않고 조회할 때마다 이 SELECT를 실행한다.
-- (실행하려면 CREATE VIEW 권한이 필요 → userCreate.sql에서 부여)
CREATE VIEW EMP_PLANNING
AS
SELECT E.EMPNAME, E.TITLE, E.SALARY
FROM EMPLOYEE E, DEPARTMENT D
WHERE E.DNO=D.DEPTNO AND D.DEPTNAME='기획';
