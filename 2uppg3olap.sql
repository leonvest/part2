


DROP VIEW IF EXISTS v_planned_hours_per_instance CASCADE;
DROP VIEW IF EXISTS v_allocated_hours_per_teacher_instance CASCADE;
DROP VIEW IF EXISTS v_teacher_load_current_year CASCADE;
DROP VIEW IF EXISTS v_teachers_over_n_courses_current_period CASCADE;



-- QUERY 1: PLANNED HOURS PER COURSE INSTANCE (CURRENT YEAR)

CREATE VIEW v_planned_hours_per_instance AS
SELECT
    ci.course_code                  AS "Course Code",
    ci.course_instance_id           AS "Course Instance ID",
    cl.hp                           AS "HP",
    ci.period_code                  AS "Period",
    ci.num_students                 AS "# Students",

    SUM(CASE WHEN tat.activity_name = 'Lecture'
             THEN pa.planned_hours * tat.factor ELSE 0 END) AS "Lecture Hours",

    SUM(CASE WHEN tat.activity_name = 'Tutorial'
             THEN pa.planned_hours * tat.factor ELSE 0 END) AS "Tutorial Hours",

    SUM(CASE WHEN tat.activity_name = 'Lab'
             THEN pa.planned_hours * tat.factor ELSE 0 END) AS "Lab Hours",

    SUM(CASE WHEN tat.activity_name = 'Seminar'
             THEN pa.planned_hours * tat.factor ELSE 0 END) AS "Seminar Hours",

    SUM(CASE WHEN tat.activity_name = 'Other'
             THEN pa.planned_hours * tat.factor ELSE 0 END) AS "Other Overhead Hours",

    SUM(CASE WHEN tat.activity_name = 'Admin'
             THEN pa.planned_hours * tat.factor ELSE 0 END) AS "Admin",

    SUM(CASE WHEN tat.activity_name = 'Exam'
             THEN pa.planned_hours * tat.factor ELSE 0 END) AS "Exam",

    SUM(pa.planned_hours * tat.factor) AS "Total Hours"

FROM course_instance ci
JOIN course_layout cl
  ON cl.layout_id = ci.layout_id
JOIN planned_activity pa
  ON pa.course_instance_id = ci.course_instance_id
JOIN teaching_activity_type tat
  ON tat.activity_type_id = pa.activity_type_id
WHERE ci.year = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY
    ci.course_code,
    ci.course_instance_id,
    cl.hp,
    ci.period_code,
    ci.num_students
ORDER BY
    ci.course_code,
    ci.course_instance_id;



-- QUERY 2: ALLOCATED HOURS PER TEACHER & ACTIVITY (CURRENT YEAR)

CREATE VIEW v_allocated_hours_per_teacher_instance AS
SELECT
    ci.course_code                  AS "Course Code",
    ci.course_instance_id           AS "Course Instance ID",
    cl.hp                           AS "HP",
    (e.first_name || ' ' || e.last_name) AS "Teacher's Name",
    jt.title                        AS "Designation",

    SUM(CASE WHEN tat.activity_name = 'Lecture'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Lecture Hours",

    SUM(CASE WHEN tat.activity_name = 'Tutorial'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Tutorial Hours",

    SUM(CASE WHEN tat.activity_name = 'Lab'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Lab Hours",

    SUM(CASE WHEN tat.activity_name = 'Seminar'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Seminar Hours",

    SUM(CASE WHEN tat.activity_name = 'Other'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Other Overhead Hours",

    SUM(CASE WHEN tat.activity_name = 'Admin'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Admin",

    SUM(CASE WHEN tat.activity_name = 'Exam'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Exam",

    SUM(ta.allocated_hours * tat.factor) AS "Total"

FROM course_instance ci
JOIN course_layout cl
  ON cl.layout_id = ci.layout_id
JOIN teaching_allocation ta
  ON ta.course_instance_id = ci.course_instance_id
JOIN teaching_activity_type tat
  ON tat.activity_type_id = ta.activity_type_id
JOIN employee e
  ON e.employee_id = ta.employee_id
JOIN job_title jt
  ON jt.job_title_id = e.job_title_id
WHERE ci.year = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY
    ci.course_code,
    ci.course_instance_id,
    cl.hp,
    e.first_name,
    e.last_name,
    jt.title
ORDER BY
    ci.course_code,
    ci.course_instance_id,
    "Teacher's Name";



-- QUERY 3: TOTAL ALLOCATED HOURS PER TEACHER (CURRENT YEAR)

CREATE VIEW v_teacher_load_current_year AS
SELECT
    ci.course_code                  AS "Course Code",
    ci.course_instance_id           AS "Course Instance ID",
    cl.hp                           AS "HP",
    ci.period_code                  AS "Period",
    (e.first_name || ' ' || e.last_name) AS "Teacher's Name",

    SUM(CASE WHEN tat.activity_name = 'Lecture'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Lecture Hours",

    SUM(CASE WHEN tat.activity_name = 'Tutorial'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Tutorial Hours",

    SUM(CASE WHEN tat.activity_name = 'Lab'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Lab Hours",

    SUM(CASE WHEN tat.activity_name = 'Seminar'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Seminar Hours",

    SUM(CASE WHEN tat.activity_name = 'Other'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Other Overhead Hours",

    SUM(CASE WHEN tat.activity_name = 'Admin'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Admin",

    SUM(CASE WHEN tat.activity_name = 'Exam'
             THEN ta.allocated_hours * tat.factor ELSE 0 END) AS "Exam",

    SUM(ta.allocated_hours * tat.factor) AS "Total"

FROM course_instance ci
JOIN course_layout cl
  ON cl.layout_id = ci.layout_id
JOIN teaching_allocation ta
  ON ta.course_instance_id = ci.course_instance_id
JOIN teaching_activity_type tat
  ON tat.activity_type_id = ta.activity_type_id
JOIN employee e
  ON e.employee_id = ta.employee_id
WHERE ci.year = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY
    ci.course_code,
    ci.course_instance_id,
    cl.hp,
    ci.period_code,
    e.first_name,
    e.last_name
ORDER BY
    "Teacher's Name",
    ci.course_code,
    ci.course_instance_id;




-- QUERY 4: TEACHERS ALLOCATED TO > N COURSES IN CURRENT PERIOD

CREATE VIEW v_teachers_over_n_courses_current_period AS
SELECT
    e.employment_id                           AS "Employment ID",
    (e.first_name || ' ' || e.last_name)      AS "Teacher's Name",
    ci.period_code                            AS "Period",
    COUNT(DISTINCT ci.course_instance_id)     AS "No of courses"
FROM teaching_allocation ta
JOIN employee e
  ON e.employee_id = ta.employee_id
JOIN course_instance ci
  ON ci.course_instance_id = ta.course_instance_id
WHERE ci.year = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY
    e.employment_id,
    e.first_name,
    e.last_name,
    ci.period_code
ORDER BY
    ci.period_code,
    "Teacher's Name";



-- EXAMPLES TO TEST THE VIEWS

-- Query 1
SELECT * FROM v_planned_hours_per_instance;

-- Query 2 (all)
SELECT * FROM v_allocated_hours_per_teacher_instance;

-- Query 3 (all)
SELECT * FROM v_teacher_load_current_year;

-- Query 3 (one teacher example)
SELECT * FROM v_teacher_load_current_year
WHERE "Teacher's Name" = 'Niharika Gauraha';

-- Query 4 (N = 1, period P1)
SELECT *
FROM v_teachers_over_n_courses_current_period
WHERE "Period" = 'P1'
  AND "No of courses" > 1;




-- EXPLAIN ANALYZE Examples 


-- EXPLAIN Query 1
EXPLAIN ANALYZE
SELECT * FROM v_planned_hours_per_instance;

-- EXPLAIN Query 3 (per teacher)
EXPLAIN ANALYZE
SELECT *
FROM v_teacher_load_current_year
WHERE "Teacher's Name" = 'Niharika Gauraha';



-- QUERY 4 


DROP VIEW IF EXISTS v_course_instance_planned_vs_allocated_variance CASCADE;

CREATE VIEW v_course_instance_planned_vs_allocated_variance AS
WITH planned AS (
    SELECT
        ci.course_instance_id,
        SUM(pa.planned_hours * tat.factor) AS total_planned_hours
    FROM course_instance ci
    JOIN planned_activity pa ON pa.course_instance_id = ci.course_instance_id
    JOIN teaching_activity_type tat ON tat.activity_type_id = pa.activity_type_id
    WHERE ci.year = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY ci.course_instance_id
),
allocated AS (
    SELECT
        ci.course_instance_id,
        SUM(ta.allocated_hours * tat.factor) AS total_allocated_hours
    FROM course_instance ci
    JOIN teaching_allocation ta ON ta.course_instance_id = ci.course_instance_id
    JOIN teaching_activity_type tat ON tat.activity_type_id = ta.activity_type_id
    WHERE ci.year = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY ci.course_instance_id
)
SELECT
    ci.course_code AS "Course Code",
    ci.course_instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    ci.period_code AS "Period",
    ROUND(p.total_planned_hours, 2) AS "Planned Total Hours",
    ROUND(a.total_allocated_hours, 2) AS "Allocated Total Hours",
    ROUND(
        (a.total_allocated_hours - p.total_planned_hours)
        / NULLIF(p.total_planned_hours, 0) * 100,
        2
    ) AS "Variance %"
FROM course_instance ci
JOIN course_layout cl ON cl.layout_id = ci.layout_id
JOIN planned p ON p.course_instance_id = ci.course_instance_id
JOIN allocated a ON a.course_instance_id = ci.course_instance_id
WHERE ABS(
        (a.total_allocated_hours - p.total_planned_hours)
        / NULLIF(p.total_planned_hours, 0) * 100
      ) > 15
ORDER BY ci.course_instance_id;


-- EXTRA VIEW (HIGHER GRADE):
-- PLANNED VS ALLOCATED VARIANCE > 15% PER COURSE INSTANCE

DROP VIEW IF EXISTS v_course_instance_planned_vs_allocated_variance CASCADE;

CREATE VIEW v_course_instance_planned_vs_allocated_variance AS
WITH planned AS (
    SELECT
        ci.course_instance_id,
        ci.course_code,
        ci.year,
        SUM(pa.planned_hours * tat.factor) AS planned_hours
    FROM course_instance ci
    JOIN planned_activity pa
      ON pa.course_instance_id = ci.course_instance_id
    JOIN teaching_activity_type tat
      ON tat.activity_type_id = pa.activity_type_id
    GROUP BY
        ci.course_instance_id,
        ci.course_code,
        ci.year
),
allocated AS (
    SELECT
        ci.course_instance_id,
        SUM(ta.allocated_hours * tat.factor) AS allocated_hours
    FROM course_instance ci
    JOIN teaching_allocation ta
      ON ta.course_instance_id = ci.course_instance_id
    JOIN teaching_activity_type tat
      ON tat.activity_type_id = ta.activity_type_id
    GROUP BY
        ci.course_instance_id
)
SELECT
    p.course_code              AS "Course Code",
    p.course_instance_id       AS "Course Instance ID",
    p.year                     AS "Year",
    p.planned_hours            AS "Planned Hours",
    a.allocated_hours          AS "Allocated Hours",
    ROUND(
      (a.allocated_hours - p.planned_hours)
      / NULLIF(p.planned_hours, 0)::numeric * 100
    , 2)                       AS "Variance %"
FROM planned p
JOIN allocated a
  ON a.course_instance_id = p.course_instance_id
WHERE p.year = EXTRACT(YEAR FROM CURRENT_DATE)
  AND ABS(a.allocated_hours - p.planned_hours)
      / NULLIF(p.planned_hours, 0)::numeric > 0.15
ORDER BY
    p.course_code,
    p.course_instance_id;

