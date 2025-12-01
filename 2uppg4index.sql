DROP INDEX IF EXISTS idx_course_instance_year;
DROP INDEX IF EXISTS idx_course_instance_course_code;
DROP INDEX IF EXISTS idx_course_instance_period_year;

DROP INDEX IF EXISTS idx_planned_activity_course_instance;
DROP INDEX IF EXISTS idx_planned_activity_activity_type;

DROP INDEX IF EXISTS idx_teaching_allocation_course_instance;
DROP INDEX IF EXISTS idx_teaching_allocation_employee;
DROP INDEX IF EXISTS idx_teaching_allocation_activity_type;

DROP INDEX IF EXISTS idx_employee_employment_id;
DROP INDEX IF EXISTS idx_system_setting_name;



-- INDEXES ON COURSE_INSTANCE
--
-- Used by:
--   • All queries that restrict to current year
--   • Queries that group by / filter on period_code
--   • Joins on course_code (from course → course_instance)


-- Speed up WHERE ci.year = EXTRACT(YEAR FROM CURRENT_DATE)
CREATE INDEX IF NOT EXISTS idx_course_instance_year
    ON course_instance(year);

-- Speed up JOINs and grouping by course_code
CREATE INDEX IF NOT EXISTS idx_course_instance_course_code
    ON course_instance(course_code);

-- Combined index for period + year (Query 3 & 4 style workloads)
CREATE INDEX IF NOT EXISTS idx_course_instance_period_year
    ON course_instance(period_code, year);




-- INDEXES ON PLANNED_ACTIVITY
--
-- Used by:
--   • Query 1 (planned hours per course instance)
--   • Variance query (planned vs allocated)
--   • JOIN planned_activity → course_instance
--   • JOIN planned_activity → teaching_activity_type


-- Speed up JOIN pa.course_instance_id = ci.course_instance_id
CREATE INDEX IF NOT EXISTS idx_planned_activity_course_instance
    ON planned_activity(course_instance_id);


CREATE INDEX IF NOT EXISTS idx_planned_activity_activity_type
    ON planned_activity(activity_type_id);




-- INDEXES ON TEACHING_ALLOCATION
--
-- Used by:
--   • Query 2 (allocated hours per teacher & instance)
--   • Query 3 (teacher load)
--   • Query 4 (teachers > N courses)
--   • Variance query (allocated vs planned)
--   • JOIN teaching_allocation → course_instance
--   • JOIN teaching_allocation → employee
--   • JOIN teaching_allocation → teaching_activity_type


-- Speed up JOIN ta.course_instance_id = ci.course_instance_id
CREATE INDEX IF NOT EXISTS idx_teaching_allocation_course_instance
    ON teaching_allocation(course_instance_id);

-- Speed up grouping/filtering by teacher (employee_id)
-- for teacher load and "teachers over N courses".
CREATE INDEX IF NOT EXISTS idx_teaching_allocation_employee
    ON teaching_allocation(employee_id);

-- Help with activity-type-specific aggregations
CREATE INDEX IF NOT EXISTS idx_teaching_allocation_activity_type
    ON teaching_allocation(activity_type_id);




-- Employment_id is used in Query 4 output and sometimes for lookups
CREATE INDEX IF NOT EXISTS idx_employee_employment_id
    ON employee(employment_id);

-- If system_setting is used to parametrize N (max courses per period)
CREATE INDEX IF NOT EXISTS idx_system_setting_name
    ON system_setting(name);

