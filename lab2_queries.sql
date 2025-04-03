-- 1. Students and their enrolled courses  
SELECT   
    students.name AS student_name,   
    courses.title AS course_name,   
    enrollments.semester   
FROM enrollments  
INNER JOIN students ON enrollments.student_id = students.student_id  
INNER JOIN courses ON enrollments.course_id = courses.course_id; 

-- 2. All courses and their professors  
SELECT   
    courses.title AS course_name,   
    courses.credits AS credit_hours,   
    professors.name AS professor_name   
FROM courses  
LEFT JOIN professors ON courses.professor_id = professors.professor_id;  


-- 3. Professors and their students by course  
SELECT   
    professors.name AS professor_name,   
    courses.title AS course_name,   
    students.name AS student_name  
FROM enrollments  
INNER JOIN courses ON enrollments.course_id = courses.course_id  
INNER JOIN professors ON courses.professor_id = professors.professor_id  
INNER JOIN students ON enrollments.student_id = students.student_id  
ORDER BY professors.name, courses.title; 


-- 4. Courses without any students enrolled  
SELECT   
    courses.title AS course_name,   
    professors.name AS professor_name   
FROM courses  
LEFT JOIN enrollments ON courses.course_id = enrollments.course_id  
LEFT JOIN professors ON courses.professor_id = professors.professor_id  
WHERE enrollments.course_id IS NULL;  

-- 5. Update course credits for "Introduction to Programming"  
UPDATE courses  
SET credits = credits + 1  
WHERE title = 'Introduction to Programming';  

-- 6. Update professor department  
UPDATE professors  
SET department = 'Data Science'  
WHERE name = 'Dr. Miller';  
-- 7. Delete students who are not enrolled in any courses  
DELETE FROM students  
WHERE student_id NOT IN (SELECT DISTINCT student_id FROM enrollments);  
-- 8. Delete courses that have no students enrolled  
DELETE FROM courses  
WHERE course_id NOT IN (SELECT DISTINCT course_id FROM enrollments);  
-- 9. Count students by major  
SELECT   
    major AS student_major,   
    COUNT(*) AS num_students   
FROM students  
GROUP BY major;  
-- 10. Count students per course  
SELECT   
    courses.title AS course_name,   
    COUNT(enrollments.enrollment_id) AS num_students   
FROM courses  
LEFT JOIN enrollments ON courses.course_id = enrollments.course_id  
GROUP BY courses.course_id;  
-- 11. Professors who teach more than the average number of courses  
SELECT   
    professors.name   
FROM professors   
WHERE (SELECT COUNT(*)  
       FROM courses  
       WHERE courses.professor_id = professors.professor_id) >   
      (SELECT AVG(course_count)  
       FROM (SELECT professor_id, COUNT(*) AS course_count   
             FROM courses GROUP BY professor_id) AS temp);  
             -- 12. Students enrolled only in Physics courses  
SELECT   
    students.name   
FROM students  
WHERE student_id NOT IN (  
    SELECT enrollments.student_id  
    FROM enrollments  
    INNER JOIN courses ON enrollments.course_id = courses.course_id  
    WHERE courses.title != 'Physics'  
);  