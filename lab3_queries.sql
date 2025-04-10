-- Active: 1743664600480@@127.0.0.1@3306@university_management
-- Active: 1743664600480@@127.0.0.1@3306@university_management
-- LAB 3 SOLUTIONS (Advanced SQL Operations)
-- University Management Database
-- Task 1: Create a view that shows student information without email addresses
CREATE VIEW student_directory AS
SELECT 
    student_id,
    name,
    major,
    enrollment_date
FROM students;


-- Test the view
SELECT * FROM student_directory LIMIT 5;

-- Task 2a: Add a CHECK constraint to ensure credits are positive
ALTER TABLE courses
ADD CONSTRAINT chk_credits_positive CHECK (credits > 0);

-- First check if the constraint already exists
SELECT CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME = 'students' AND CONSTRAINT_TYPE = 'UNIQUE';

-- If it exists, drop it first
ALTER TABLE students DROP CONSTRAINT uk_student_email;

-- Then add it fresh (only if needed)
ALTER TABLE students ADD CONSTRAINT uk_student_email UNIQUE (email);
--------------------------------------------------
-- TASK 3: Create an INDEX for performance
--------------------------------------------------
CREATE INDEX idx_enrollments_student_id 
ON enrollments(student_id);

-- Verify index was created
SHOW INDEX FROM enrollments WHERE Key_name = 'idx_enrollments_student_id';


--------------------------------------------------
-- TASK 4: Create and test a TRANSACTION
--------------------------------------------------
-- Transaction example: Register a new student and enroll them
START TRANSACTION;

-- 1. Add new student
INSERT INTO students (name, email, major, enrollment_date)
VALUES ('Emma Davis', 'emma.davis@univ.edu', 'Mathematics', '2025-03-10');

-- Get the auto-generated student ID
SET @new_student_id = LAST_INSERT_ID();

-- 2. Enroll in Calculus I
INSERT INTO enrollments (student_id, course_id, semester)
SELECT 
    @new_student_id, 
    course_id, 
    'Spring 2025'
FROM courses 
WHERE title = 'Calculus I';

-- 3. Update course credits
UPDATE courses 
SET credits = credits + 0.5 
WHERE title = 'Calculus I';

-- Verify changes before committing
SELECT 'Students table:' AS log;
SELECT * FROM students WHERE student_id = @new_student_id;

SELECT 'Enrollments table:' AS log;
SELECT * FROM enrollments WHERE student_id = @new_student_id;

SELECT 'Courses table:' AS log;
SELECT * FROM courses WHERE title = 'Calculus I';

-- Uncomment one:
-- ROLLBACK; -- To cancel all changes
COMMIT; -- To save all changes
-- Demonstrate ROLLBACK scenario (add after your COMMIT example)
START TRANSACTION;
INSERT INTO students (name, email, major, enrollment_date)
VALUES ('Rollback Test', 'rollback@test.edu', 'Physics', CURDATE());
SELECT * FROM students WHERE email = 'rollback@test.edu'; -- Verify exists
ROLLBACK;
SELECT * FROM students WHERE email = 'rollback@test.edu'; -- Verify gone


--------------------------------------------------
-- TASK 5: Complex Query (JOIN + SUBQUERY + HAVING)
--------------------------------------------------
-- Find students enrolled in more courses than average
SELECT 
    s.student_id,
    s.name,
    COUNT(e.course_id) AS courses_enrolled,
    (SELECT AVG(course_count) 
     FROM (SELECT COUNT(*) AS course_count 
           FROM enrollments 
           GROUP BY student_id) AS avg_table) AS avg_courses
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.student_id
HAVING courses_enrolled > (
    SELECT AVG(course_count) 
    FROM (SELECT COUNT(*) AS course_count 
          FROM enrollments 
          GROUP BY student_id) AS avg_table
)
ORDER BY courses_enrolled DESC;


--------------------------------------------------
-- BONUS TASK: Authorization (Role & Grant)
--------------------------------------------------
-- Create a read-only role for advisors
CREATE ROLE IF NOT EXISTS 'advisor_role';

-- Grant permissions
GRANT SELECT ON university_management.student_directory TO 'advisor_role';
GRANT SELECT ON university_management.courses TO 'advisor_role';
GRANT SELECT ON university_management.professors TO 'advisor_role';

-- Create sample user
CREATE USER IF NOT EXISTS 'advisor_john'@'localhost' IDENTIFIED BY 'securepass123';
GRANT 'advisor_role' TO 'advisor_john'@'localhost';

-- Verify permissions (run as admin)
SHOW GRANTS FOR 'advisor_john'@'localhost';
-- Run as the new user to test:
SHOW GRANTS;  -- Should show only SELECT on granted tables