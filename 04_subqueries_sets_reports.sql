USE checkin_demo;

-- 1. EXISTS Subquery (Students who have been sent 'At the Clinic')
SELECT s.student_id, s.student_name
FROM student s
WHERE EXISTS (
  SELECT 1
  FROM enrollment e
  JOIN attendance a ON e.enrollment_id = a.enrollment_id
  WHERE e.student_id = s.student_id
    AND a.remarks = 'At the Clinic'
);

-- 2. Correlated Subquery (Count of enrolled classes per student)
SELECT
  s.student_id,
  s.student_name,
  (SELECT COUNT(*) FROM enrollment e WHERE e.student_id = s.student_id) AS enrolled_classes
FROM student s;

-- 3. CASE Expression (Standing status classification)
SELECT
  s.student_name,
  a.attendance_date,
  a.status,
  CASE
    WHEN a.status = 'Present' THEN 'On Time'
    WHEN a.status = 'Late'    THEN 'Tardy - Monitor'
    WHEN a.status = 'Absent' AND a.remarks = 'At the Clinic' THEN 'Excused - Medical'
    ELSE 'Unexcused Absence'
  END AS standing_label
FROM attendance a
JOIN enrollment e ON a.enrollment_id = e.enrollment_id
JOIN student s    ON e.student_id    = s.student_id;

-- 4. Set Operators: UNION, INTERSECT, EXCEPT (MINUS)
SELECT teacher_id AS id_number, teacher_name AS full_name, 'Teacher' AS role FROM teacher
UNION
SELECT student_id AS id_number, student_name AS full_name, 'Student' AS role FROM student;

SELECT student_id FROM enrollment
INTERSECT
SELECT e.student_id FROM enrollment e JOIN attendance a ON e.enrollment_id = a.enrollment_id;

SELECT student_id FROM enrollment
EXCEPT
SELECT e.student_id FROM enrollment e JOIN attendance a ON e.enrollment_id = a.enrollment_id;

-- 5. Business Report: CTE + RANK() Window Function (Top Punctual Students)
WITH student_attendance_summary AS (
  SELECT
    s.student_id,
    s.student_name,
    SUM(a.status = 'Present') AS total_present,
    SUM(a.status = 'Late')    AS total_late,
    SUM(a.status = 'Absent')  AS total_absent
  FROM student s
  LEFT JOIN enrollment e ON s.student_id = e.student_id
  LEFT JOIN attendance a ON e.enrollment_id = a.enrollment_id
  GROUP BY s.student_id, s.student_name
)
SELECT
  student_id,
  student_name,
  total_present,
  total_late,
  total_absent,
  RANK() OVER (ORDER BY total_present DESC, total_late ASC) AS attendance_rank
FROM student_attendance_summary
ORDER BY attendance_rank, student_name;