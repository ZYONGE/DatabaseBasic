-- ===== 4.2 그림 4.4 (검색 + 조작) =====
-- [UPDATE] DEPARTMENT에서 WHERE 조건(DEPTNO = 1)을 만족하는 투플의 FLOOR 값을 SET 절의 내용대로 10으로 변경
UPDATE DEPARTMENT SET FLOOR = 10 WHERE DEPTNO = 1;
-- [DELETE] DEPARTMENT에서 DEPTNAME이 '총무'인 투플을 삭제 (WHERE 절을 생략하면 모든 투플이 삭제됨)
DELETE FROM DEPARTMENT WHERE DEPTNAME = '총무';
-- [INSERT] 애트리뷰트 목록을 생략했으므로 CREATE TABLE에 정의된 순서(DEPTNO, DEPTNAME, FLOOR)대로 값을 넣어 투플 1개 삽입
INSERT INTO DEPARTMENT VALUES (5, '연구', 9);
-- [SELECT] DEPTNO가 1 또는 3인 투플에서 DEPTNAME, FLOOR만 추출 (OR: 두 조건 중 하나라도 참이면 선택)
SELECT DEPTNAME, FLOOR FROM DEPARTMENT WHERE DEPTNO = 1 OR DEPTNO = 3;

-- ===== 4.3 스키마 생성과 제거 =====
-- [CREATE SCHEMA] MY_DB 스키마를 생성하고, AUTHORIZATION 절로 스키마의 소유자를 kim으로 지정
CREATE SCHEMA MY_DB AUTHORIZATION kim;

-- [DROP SCHEMA ... RESTRICT] 스키마 안에 테이블 등 객체가 하나도 없을 때만 제거, 남아 있으면 제거를 거부
DROP SCHEMA MY_DB RESTRICT;  -- 스키마가 비어 있을 때만 제거
-- [DROP SCHEMA ... CASCADE] 스키마 안의 모든 객체(테이블, 뷰 등)까지 연쇄적으로 함께 제거
DROP SCHEMA MY_DB CASCADE;   -- 안의 모든 객체까지 함께 제거

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

-- ===== 릴레이션 제거 / 변경 / 인덱스 =====
-- [DROP TABLE] DEPARTMENT 릴레이션의 정의와 데이터를 모두 제거
--   다른 릴레이션(EMPLOYEE)이 외래 키로 참조 중이면 거부됨 → Oracle은 DROP TABLE DEPARTMENT CASCADE CONSTRAINTS 사용
DROP TABLE DEPARTMENT;                       -- 릴레이션 제거
-- [ALTER TABLE ... ADD] 기존 EMPLOYEE에 CHAR(13) 타입의 PHONE 애트리뷰트 추가 (기존 투플의 PHONE 값은 널)
ALTER TABLE EMPLOYEE ADD PHONE CHAR(13);     -- 애트리뷰트 추가
-- [CREATE INDEX] EMPLOYEE의 DNO 애트리뷰트에 EMPDNO_IDX 인덱스 생성 → DNO를 조건으로 하는 검색 속도 향상
CREATE INDEX EMPDNO_IDX ON EMPLOYEE(DNO);    -- 인덱스 생성

-- ===== 제약조건 (그림 4.7) =====
-- [CREATE TABLE + 제약조건]
--   애트리뷰트 단위 제약조건: "이름 타입 [DEFAULT 값] [제약조건]" 순서로 애트리뷰트 정의 바로 뒤에 기술
--   릴레이션 단위 제약조건: PRIMARY KEY, FOREIGN KEY처럼 모든 애트리뷰트 정의 뒤에 별도 항목으로 기술
--   DEFAULT: INSERT 시 값을 주지 않으면 널 대신 지정한 기본값이 들어감
--   CHECK (조건): 조건을 만족하지 않는 값의 삽입·수정을 거부
--   ON DELETE CASCADE: 참조되는 DEPARTMENT 투플이 삭제되면 그 부서를 참조하는 EMPLOYEE 투플도 함께 삭제
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

-- ===== ON DELETE CASCADE 예 =====
-- [DELETE] 3번 부서 투플 삭제 → ON DELETE CASCADE 때문에 DNO = 3인 EMPLOYEE 투플(이수민, 최종철)도 연쇄 삭제
--   FROM 생략은 Oracle에서 허용되는 형태, 표준 SQL은 DELETE FROM DEPARTMENT
DELETE DEPARTMENT
WHERE DEPTNO = 3;

-- ===== 무결성 제약조건의 추가 및 삭제 =====
-- [ALTER TABLE ... ADD CONSTRAINT] 기존 STUDENT에 STUDENT_PK라는 이름으로 기본 키 제약조건(STNO) 추가
ALTER TABLE STUDENT ADD CONSTRAINT STUDENT_PK PRIMARY KEY (STNO);
-- [ALTER TABLE ... DROP CONSTRAINT] 이름(STUDENT_PK)으로 제약조건 삭제 → 제약조건에 이름을 붙여 두어야 나중에 지정해서 삭제 가능
ALTER TABLE STUDENT DROP CONSTRAINT STUDENT_PK;

-- ===== 4.4 SELECT문 기본 형식 (그림 4.9) =====
-- [형식] [ ] 안은 생략 가능한 부분
--   SELECT: 결과에 나타낼 애트리뷰트, DISTINCT를 붙이면 중복 투플 제거
--   FROM: 질의에 사용할 릴레이션
--   WHERE: 투플을 고르는 조건 (조건 안에 또 다른 SELECT문, 즉 중첩 질의 사용 가능)
--   GROUP BY: 같은 값을 갖는 투플끼리 그룹으로 묶음
--   HAVING: 그룹 중 조건을 만족하는 그룹만 선택
--   ORDER BY: 결과 정렬 (ASC 오름차순이 기본, DESC 내림차순)
--   개념적 처리 순서: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
SELECT    [DISTINCT] 애트리뷰트(들)      -- (1) 필수
FROM      릴레이션(들)                   -- (2) 필수
[WHERE    조건 [중첩 질의]]              -- (3)(4) 선택
[GROUP BY 애트리뷰트(들)]                -- (5) 선택
[HAVING   조건]                         -- (6) 선택
[ORDER BY 애트리뷰트(들) [ASC|DESC]];    -- (7) 선택

-- ===== 별칭 =====
-- [형식] "릴레이션이름.애트리뷰트": 여러 릴레이션에 같은 이름의 애트리뷰트가 있을 때 어느 릴레이션 것인지 구분
-- [형식] FROM 절에서 릴레이션 뒤에 별칭(투플 변수)을 주면 질의 안에서 E.DNO처럼 짧게 참조 가능
--   표준 SQL은 AS 사용 가능, Oracle은 AS 없이 EMPLOYEE E 형태만 허용
EMPLOYEE.DNO                          -- 릴레이션 이름으로 구분
FROM EMPLOYEE AS E, DEPARTMENT AS D   -- 투플 변수(별칭) 지정

-- ===== 모든 / 일부 애트리뷰트 검색 =====
-- [SELECT *] '*'는 모든 애트리뷰트를 의미, WHERE 절이 없으므로 모든 투플 검색
SELECT * FROM DEPARTMENT;                 -- 모든 애트리뷰트
-- [SELECT 애트리뷰트 목록] 나열한 애트리뷰트만 결과에 포함 (관계 대수의 추출 연산)
SELECT DEPTNO, DEPTNAME FROM DEPARTMENT;  -- 원하는 애트리뷰트만

-- ===== DISTINCT =====
-- [SELECT] 아무것도 붙이지 않으면 ALL이 기본값 → 중복 투플이 결과에 그대로 남음
SELECT TITLE FROM EMPLOYEE;           -- 대리, 과장, 부장, 과장, 사원, 사원, 사장 (중복 O)
-- [SELECT DISTINCT] 결과에서 중복 투플을 제거
SELECT DISTINCT TITLE FROM EMPLOYEE;  -- 대리, 과장, 부장, 사원, 사장 (중복 X)

-- ===== WHERE =====
-- [SELECT ... WHERE] 비교 연산자(=)로 DNO가 2인 투플만 골라 모든 애트리뷰트 출력 (관계 대수의 실렉션 연산)
SELECT * FROM EMPLOYEE WHERE DNO = 2;   -- 조민희, 김창섭, 이성래

-- ===== LIKE =====
-- [LIKE] 문자열 패턴 비교. '%'는 0개 이상의 임의 문자, '_'는 정확히 1개의 문자
--   '이%' → '이'로 시작하는 모든 문자열
SELECT EMPNAME, TITLE, DNO
FROM   EMPLOYEE
WHERE  EMPNAME LIKE '이%';              -- 이수민, 이성래

-- ===== 다수의 검색 조건 (잘못된 질의) =====
-- [AND] 두 조건이 한 투플에서 동시에 참이어야 함 → DEPTNAME이 '영업'이면서 '개발'인 투플은 없으므로 결과는 항상 공집합
--   의도대로 하려면 OR 또는 DEPTNAME IN ('영업', '개발') 사용
SELECT FLOOR FROM DEPARTMENT
WHERE  DEPTNAME = '영업' AND DEPTNAME = '개발';

-- ===== 부울 연산자 / 부정 검색 =====
-- 부울 연산자: 직급이 과장이면서 1번 부서 → 박영권 3000000
-- [AND] TITLE = '과장' 조건과 DNO = 1 조건을 모두 만족하는 투플만 선택
SELECT EMPNAME, SALARY FROM EMPLOYEE
WHERE  TITLE = '과장' AND DNO = 1;

-- 부정 검색: 직급이 과장이면서 1번 부서가 아닌 → 조민희 3000000
-- [<>] '같지 않다' 비교 연산자 → DNO가 1이 아닌 투플 선택
SELECT EMPNAME, SALARY FROM EMPLOYEE
WHERE  TITLE = '과장' AND DNO <> 1;

-- ===== BETWEEN =====
-- [BETWEEN a AND b] a ≤ 값 ≤ b 인 투플 선택 (양 끝값 포함)
SELECT EMPNAME, TITLE, SALARY FROM EMPLOYEE
WHERE  SALARY BETWEEN 3000000 AND 4500000;
-- BETWEEN은 양 끝값 포함 → 아래 질의와 결과 동일
-- [>=, <=, AND] BETWEEN을 비교 연산자 두 개와 AND로 풀어 쓴 형태
SELECT EMPNAME, TITLE, SALARY FROM EMPLOYEE
WHERE  SALARY >= 3000000 AND SALARY <= 4500000;

-- ===== IN =====
-- [IN (값 목록)] 애트리뷰트 값이 목록 중 하나와 같으면 참 → DNO = 1 OR DNO = 3 과 같음
SELECT * FROM EMPLOYEE WHERE DNO IN (1, 3);   -- 김상원, 이수민, 박영권, 최종철

-- ===== SELECT절의 산술 연산자 =====
-- [산술 연산 + AS] SELECT 절에서 SALARY * 1.1을 계산해 NEWSALARY라는 이름으로 출력
--   결과에만 나타나는 값이며 릴레이션에 저장된 SALARY는 변하지 않음
SELECT EMPNAME, SALARY, SALARY * 1.1 AS NEWSALARY
FROM   EMPLOYEE
WHERE  TITLE = '과장';

-- ===== 널값 =====
-- [IS NULL] 널값과의 비교는 = 로 할 수 없음 (DNO = NULL의 결과는 참이 아닌 unknown) → IS NULL 사용
SELECT EMPNO, EMPNAME FROM EMPLOYEE
WHERE  DNO IS NULL;
-- [IS NOT NULL] DNO 값이 널이 아닌(부서가 지정된) 투플 선택
SELECT EMPNO, EMPNAME FROM EMPLOYEE
WHERE  DNO IS NOT NULL;

-- ===== ORDER BY =====
-- [ORDER BY] 결과를 SALARY 기준으로 정렬, ASC/DESC를 생략하면 오름차순
SELECT   SALARY, TITLE, EMPNAME
FROM     EMPLOYEE
WHERE    DNO = 2
ORDER BY SALARY;     -- 2500000 김창섭 → 3000000 조민희 → 5000000 이성래

-- ===== 집단 함수 =====
-- [AVG, MAX] 집단 함수는 여러 투플의 값을 하나의 값으로 요약 (널값은 제외하고 계산)
--   AS로 결과 애트리뷰트에 이름 지정
SELECT AVG(SALARY) AS AVGSAL, MAX(SALARY) AS MAXSAL
FROM   EMPLOYEE;      -- AVGSAL 2928571, MAXSAL 5000000

-- ===== GROUP BY (잘못된 질의) =====
-- [오류] GROUP BY 없이 집단 함수를 쓰면 결과는 한 행인데, EMPNO는 투플마다 값이 달라 한 행에 대응시킬 수 없음
--   → SELECT 절에 집단 함수와 함께 쓰는 애트리뷰트는 반드시 GROUP BY 절에 있어야 함
SELECT EMPNO, AVG(SALARY) FROM EMPLOYEE;

-- ===== GROUP BY (부서별 평균·최대 급여) =====
-- [GROUP BY] DNO 값이 같은 투플끼리 그룹을 만들고, 그룹마다 AVG, MAX를 계산해 그룹당 한 행 출력
SELECT   DNO, AVG(SALARY) AS AVGSAL, MAX(SALARY) AS MAXSAL
FROM     EMPLOYEE
GROUP BY DNO;

-- ===== HAVING =====
-- [HAVING] GROUP BY로 만든 그룹 중 조건을 만족하는 그룹만 남김
--   WHERE는 그룹을 만들기 전 투플을, HAVING은 그룹을 걸러냄 → 집단 함수 조건은 HAVING에만 쓸 수 있음
SELECT   DNO, AVG(SALARY) AS AVGSAL, MAX(SALARY) AS MAXSAL
FROM     EMPLOYEE
GROUP BY DNO
HAVING   AVG(SALARY) >= 2500000;   -- 2번, 3번 부서만 남음

-- ===== 집합 연산 =====
-- [UNION] 두 질의 결과의 합집합, 중복은 자동 제거 (중복을 유지하려면 UNION ALL)
--   두 결과의 애트리뷰트 개수와 도메인이 같아야 함 (합병 가능)
(SELECT DNO    FROM EMPLOYEE   WHERE EMPNAME  = '김창섭')
UNION
(SELECT DEPTNO FROM DEPARTMENT WHERE DEPTNAME = '개발');   -- 2, 3

-- ===== 조인 일반 형식 =====
-- [형식] FROM 절에 두 릴레이션을 나열하고 WHERE 절에 두 릴레이션의 애트리뷰트를 비교하는 조인 조건을 기술
SELECT ...
FROM   R, S
WHERE  R.A <비교 연산자> S.B;   -- 가장 흔한 비교 연산자는 =

-- ===== 조인 예 =====
-- [조인] FROM의 두 릴레이션으로 카티션 곱을 만들고, 조인 조건 E.DNO = D.DEPTNO를 만족하는 투플 쌍만 남김 (동등 조인)
--   DNO가 널인 사원은 짝이 없으므로 결과에서 빠짐
SELECT EMPNAME, DEPTNAME
FROM   EMPLOYEE AS E, DEPARTMENT AS D
WHERE  E.DNO = D.DEPTNO;

-- ===== 자체 조인 =====
-- 모든 사원의 이름과 직속 상사의 이름
-- [자체 조인] 같은 EMPLOYEE를 별칭 E(사원)와 M(상사)으로 두 번 사용
--   사원의 MANAGER와 상사의 EMPNO가 같은 쌍을 연결 (MANAGER가 널인 사장은 결과에서 빠짐)
SELECT E.EMPNAME, M.EMPNAME
FROM   EMPLOYEE E, EMPLOYEE M
WHERE  E.MANAGER = M.EMPNO;

-- ===== 조인 + ORDER BY =====
-- [ORDER BY 여러 기준] 첫 번째 기준(DEPTNAME)으로 정렬하고, 값이 같으면 두 번째 기준(SALARY DESC)으로 정렬
SELECT   DEPTNAME, EMPNAME, TITLE, SALARY
FROM     EMPLOYEE E, DEPARTMENT D
WHERE    E.DNO = D.DEPTNO
ORDER BY DEPTNAME, SALARY DESC;   -- 부서이름 오름차순, 같은 부서 내 급여 내림차순

-- ===== 중첩 질의 ① 스칼라값 1개 반환 =====
-- 박영권과 같은 직급을 갖는 모든 사원
-- [중첩 질의 + =] 괄호 안의 질의가 먼저 한 번 수행되어 값 1개('과장')를 반환
--   결과가 단일 값이므로 =, <, > 같은 비교 연산자로 외부 질의와 비교 가능
SELECT EMPNAME, TITLE
FROM   EMPLOYEE
WHERE  TITLE = (SELECT TITLE
                FROM   EMPLOYEE
                WHERE  EMPNAME = '박영권');   -- 중첩 질의 결과 '과장' → 박영권, 조민희

-- ===== 중첩 질의 ② 애트리뷰트 1개짜리 릴레이션 반환 (IN) =====
-- 영업부나 개발부에 근무하는 사원 이름
-- [중첩 질의 + IN] 중첩 질의가 값 여러 개(1, 3)를 반환하므로 = 대신 IN으로 "목록 중 하나와 같은지" 비교
SELECT EMPNAME
FROM   EMPLOYEE
WHERE  DNO IN (SELECT DEPTNO
               FROM   DEPARTMENT
               WHERE  DEPTNAME = '영업' OR DEPTNAME = '개발');  -- (1, 3)

-- 같은 질의를 조인으로
-- [조인] 조인 조건으로 사원과 부서를 연결한 뒤 부서 이름 조건을 AND로 추가
--   OR 조건을 괄호로 묶어야 AND보다 먼저 평가됨 (괄호가 없으면 AND가 먼저 결합)
SELECT EMPNAME
FROM   EMPLOYEE E, DEPARTMENT D
WHERE  E.DNO = D.DEPTNO
  AND  (D.DEPTNAME = '영업' OR D.DEPTNAME = '개발');

-- ===== 중첩 질의 ③ 여러 애트리뷰트 릴레이션 반환 (EXISTS) =====
-- [EXISTS] 중첩 질의의 결과에 투플이 하나라도 있으면 참, 없으면 거짓
--   중첩 질의가 외부의 E.DNO를 참조하므로 외부 EMPLOYEE의 투플마다 다시 평가됨
SELECT EMPNAME
FROM   EMPLOYEE E
WHERE  EXISTS (SELECT *
               FROM   DEPARTMENT D
               WHERE  E.DNO = D.DEPTNO
                 AND  (DEPTNAME = '영업' OR DEPTNAME = '개발'));

-- ===== 상관 중첩 질의 =====
-- 자기 부서 평균 급여보다 많이 받는 사원
-- [상관 중첩 질의] 중첩 질의가 외부 질의의 E.DNO를 사용하므로, 외부 투플 하나마다 그 사원 부서의 평균을 새로 계산해 비교
SELECT EMPNAME, DNO, SALARY
FROM   EMPLOYEE E
WHERE  SALARY > (SELECT AVG(SALARY)
                 FROM   EMPLOYEE
                 WHERE  DNO = E.DNO);   -- ← 외부의 E를 참조 (상관)

-- ===== 4.5 INSERT문 (한 투플) =====
-- [형식] 나열한 애트리뷰트에 VALUES의 값을 순서대로 대응시켜 투플 1개 삽입
--   애트리뷰트 목록을 생략하면 릴레이션의 모든 애트리뷰트에 정의된 순서대로 값을 줘야 함
INSERT INTO 릴레이션(애트리뷰트1, ..., 애트리뷰트n)
VALUES (값1, ..., 값n);

-- 예) DEPARTMENT에 (5, 연구, NULL) 삽입
-- [INSERT ... VALUES] 값을 모르는 FLOOR에는 NULL을 명시해 널값 삽입
INSERT INTO DEPARTMENT VALUES (5, '연구', NULL);

-- ===== INSERT문 (여러 투플) =====
-- [형식] VALUES 대신 SELECT문을 쓰면 질의 결과의 모든 투플이 한 번에 삽입됨
INSERT INTO 릴레이션(애트리뷰트1, ..., 애트리뷰트n)
SELECT ... FROM ... WHERE ...;

-- 예) 급여 300만 이상 사원을 HIGH_SALARY에 삽입 (HIGH_SALARY는 이미 생성되어 있다고 가정)
-- [INSERT ... SELECT] SELECT 결과의 EMPNAME, TITLE, SALARY가 각각 ENAME, TITLE, SAL에 순서대로 들어감
INSERT INTO HIGH_SALARY(ENAME, TITLE, SAL)
SELECT EMPNAME, TITLE, SALARY
FROM   EMPLOYEE
WHERE  SALARY >= 3000000;

-- ===== DELETE문 =====
-- [형식] WHERE 조건을 만족하는 투플을 삭제, WHERE를 생략하면 모든 투플 삭제
--   투플만 지워지고 릴레이션 정의는 남음 (릴레이션 자체를 없애는 DROP TABLE과 다름)
DELETE FROM 릴레이션
WHERE  조건;

-- 예) 4번 부서 삭제
-- [DELETE] DEPTNO가 4인 투플 삭제 (이 부서를 참조하는 투플이 있으면 참조 무결성 옵션에 따라 거부 또는 연쇄 처리)
DELETE FROM DEPARTMENT
WHERE  DEPTNO = 4;

-- ===== UPDATE문 =====
-- [형식] WHERE 조건을 만족하는 투플의 애트리뷰트 값을 SET 절의 내용대로 변경
--   SET의 오른쪽에는 값 또는 식이 올 수 있고, 여러 애트리뷰트는 콤마로 구분, WHERE를 생략하면 모든 투플 변경
UPDATE 릴레이션
SET    애트리뷰트 = 값 또는 식 [, …]
WHERE  조건;

-- ===== 4.6 SQL3 트리거 형식 =====
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
