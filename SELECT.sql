-- ============================================================
-- SELECT.sql
-- DML - 검색
--
-- 목차
--   1. 기본 형식
--   2. WHERE 조건
--   3. ORDER BY
--   4. 집단 함수 / GROUP BY / HAVING
--   5. 집합 연산
--   6. 조인
--   7. 중첩 질의
-- ============================================================


-- ############################################################
-- 1. 기본 형식
-- SELECT문 기본 형식, 애트리뷰트 선택, DISTINCT, 별칭, 산술 연산
-- 출처: 1014 강의 (교재 4.2 그림 4.4, 4.4 그림 4.9)
-- ############################################################

-- ===== 4.2 그림 4.4 검색 예 =====
-- [SELECT] DEPTNO가 1 또는 3인 투플에서 DEPTNAME, FLOOR만 추출 (OR: 두 조건 중 하나라도 참이면 선택)
SELECT DEPTNAME, FLOOR FROM DEPARTMENT WHERE DEPTNO = 1 OR DEPTNO = 3;

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

-- ===== SELECT절의 산술 연산자 =====
-- [산술 연산 + AS] SELECT 절에서 SALARY * 1.1을 계산해 NEWSALARY라는 이름으로 출력
--   결과에만 나타나는 값이며 릴레이션에 저장된 SALARY는 변하지 않음
SELECT EMPNAME, SALARY, SALARY * 1.1 AS NEWSALARY
FROM   EMPLOYEE
WHERE  TITLE = '과장';


-- ############################################################
-- 2. WHERE 조건
-- WHERE 절 조건 검색: 비교 연산자, LIKE, AND/OR/<>, BETWEEN, IN, IS NULL
-- 출처: 1014 강의 (교재 4.4)
-- ############################################################

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

-- ===== 널값 =====
-- [IS NULL] 널값과의 비교는 = 로 할 수 없음 (DNO = NULL의 결과는 참이 아닌 unknown) → IS NULL 사용
SELECT EMPNO, EMPNAME FROM EMPLOYEE
WHERE  DNO IS NULL;
-- [IS NOT NULL] DNO 값이 널이 아닌(부서가 지정된) 투플 선택
SELECT EMPNO, EMPNAME FROM EMPLOYEE
WHERE  DNO IS NOT NULL;


-- ############################################################
-- 3. ORDER BY
-- 결과 정렬 (조인 결과의 다중 기준 정렬은 6번 섹션)
-- 출처: 1014 강의 (교재 4.4)
-- ############################################################

-- [ORDER BY] 결과를 SALARY 기준으로 정렬, ASC/DESC를 생략하면 오름차순
SELECT   SALARY, TITLE, EMPNAME
FROM     EMPLOYEE
WHERE    DNO = 2
ORDER BY SALARY;     -- 2500000 김창섭 → 3000000 조민희 → 5000000 이성래


-- ############################################################
-- 4. 집단 함수 / GROUP BY / HAVING
-- 집단 함수, GROUP BY, HAVING
-- 출처: 1014 강의 (교재 4.4)
-- ############################################################

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


-- ############################################################
-- 5. 집합 연산
-- 집합 연산 (UNION)
-- 출처: 1014 강의 (교재 4.4)
-- ############################################################

-- [UNION] 두 질의 결과의 합집합, 중복은 자동 제거 (중복을 유지하려면 UNION ALL)
--   두 결과의 애트리뷰트 개수와 도메인이 같아야 함 (합병 가능)
(SELECT DNO    FROM EMPLOYEE   WHERE EMPNAME  = '김창섭')
UNION
(SELECT DEPTNO FROM DEPARTMENT WHERE DEPTNAME = '개발');   -- 2, 3


-- ############################################################
-- 6. 조인
-- 조인: 일반 형식, 동등 조인, 자체 조인, 조인 + ORDER BY
-- (조인으로 정의한 뷰는 setup/02_sample_data.sql의 EMP_PLANNING 참고)
-- 출처: 1014 강의 (교재 4.4)
-- ############################################################

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


-- ############################################################
-- 7. 중첩 질의
-- 중첩 질의: 스칼라값(=), 단일 애트리뷰트 릴레이션(IN), EXISTS, 상관 중첩 질의
-- 출처: 1014 강의 (교재 4.4)
-- ############################################################

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
