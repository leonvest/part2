DROP MATERIALIZED VIEW IF EXISTS mv_teacher_load_current_year CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_course_instance_planned_vs_allocated_variance CASCADE;



------------------------------------------------------------
-- MATERIALIZED VIEW 1:
-- TEACHER LOAD PER CURRENT YEAR (Query 3)
--
-- Heavy because it joins:
--   • course_instance
--   • course_layout
--   • teaching_allocation
--   • teaching_activity_type
--   • employee
--
-- Materialization improves repeated reads dramatically.
------------------------------------------------------------

CREATE MATERIALIZED VIEW mv_teacher_load_current_year AS
SELECT *
FROM v_teacher_load_current_year;

-- Optional: index on materialized view to speed filtering by teacher
CREATE INDEX IF NOT EXISTS idx_mv_teacher_load_teacher_name
    ON mv_teacher_load_current_year("Teacher's Name");



------------------------------------------------------------
-- MATERIALIZED VIEW 2:
-- PLANNED VS ALLOCATED VARIANCE > 15% (Higher grade)
--------------------------------------------------

CREATE MATERIALIZED VIEW mv_course_instance_planned_vs_allocated_variance AS
SELECT *
FROM v_course_instance_planned_vs_allocated_variance;

-- Optional: index to speed searching/filtering
CREATE INDEX IF NOT EXISTS idx_mv_variance_course_instance
    ON mv_course_instance_planned_vs_allocated_variance("Course Instance ID");


-- Refresh teacher load view
REFRESH MATERIALIZED VIEW mv_teacher_load_current_year;

-- Refresh variance view
REFRESH MATERIALIZED VIEW mv_course_instance_planned_vs_allocated_variance;
