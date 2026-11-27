USE checkin_demo;

-- 1. Aliases, DISTINCT, ORDER BY, LIMIT & OFFSET
SELECT student_id AS `Student ID`, student_name AS `Full Name`, year_level AS `Year`
FROM student
ORDER BY student_name ASC
LIMIT 5 OFFSET 0;

SELECT DISTINCT status FROM attendance ORDER BY status;

-- 2. Comparison Operators (=, <>, >, <, >=, <=)
SELECT attendance_id, enrollment_id, attendance_date, status, time_in
FROM attendance
WHERE status <> 'Present'
  AND attendance_date >= '2026-09-28';

SELECT attendance_id, enrollment_id, attendance_date, time_in
FROM attendance
WHERE time_in > '08:10:00';

-- 3. Logical Operators (AND, OR, NOT, XOR)
SELECT attendance_id, enrollment_id, status, remarks
FROM attendance
WHERE (status = 'Absent' OR status = 'Late')
  AND NOT (remarks IS NULL);

SELECT attendance_id, enrollment_id, status, remarks
FROM attendance
WHERE (status = 'Absent') XOR (remarks IS NOT NULL);

-- 4. Special Operators (BETWEEN, IN, LIKE, REGEXP, IS NULL, <=>)
SELECT attendance_id, enrollment_id, attendance_date, status
FROM attendance
WHERE attendance_date BETWEEN '2026-09-28' AND '2026-10-01';

SELECT student_id, student_name, year_level
FROM student
WHERE student_id IN (2025305121, 2025304619, 2025300867, 2025301932, 2025301815);

SELECT teacher_id, teacher_name, email
FROM teacher
WHERE teacher_name LIKE '%Garcia%' OR email REGEXP '^[a-c]';

SELECT student_id, student_name, contact_number
FROM student
WHERE contact_number <=> NULL;

-- 5. Aggregates, Arithmetic, GROUP BY & HAVING (Student Attendance Summary)
SELECT
  s.student_id,
  s.student_name,
  COUNT(a.attendance_id) AS total_sessions,
  SUM(a.status = 'Present') AS present_days,
  SUM(a.status = 'Late')    AS late_days,
  SUM(a.status = 'Absent')  AS absent_days,
  ROUND((SUM(a.status = 'Present') / COUNT(a.attendance_id)) * 100, 2) AS punctuality_pct
FROM student s
JOIN enrollment e ON s.student_id = e.student_id
JOIN attendance a ON e.enrollment_id = a.enrollment_id
GROUP BY s.student_id, s.student_name
HAVING COUNT(a.attendance_id) >= 1
ORDER BY punctuality_pct DESC, s.student_name ASC;

-- 6. INNER JOIN (6-table master attendance sheet)
SELECT
  a.attendance_date,
  sub.subject_code,
  c.section,
  t.teacher_name,
  s.student_id,
  s.student_name,
  a.status,
  IFNULL(a.time_in, 'N/A') AS arrival_time,
  COALESCE(a.remarks, 'None') AS remarks
FROM attendance a
INNER JOIN enrollment e ON a.enrollment_id = e.enrollment_id
INNER JOIN student s    ON e.student_id    = s.student_id
INNER JOIN class c      ON e.class_id      = c.class_id
INNER JOIN subject sub  ON c.subject_id    = sub.subject_id
INNER JOIN teacher t    ON c.teacher_id    = t.teacher_id
ORDER BY a.attendance_date DESC, s.student_name ASC;

-- 7. LEFT JOIN (Students with zero attendance records yet)
SELECT s.student_id, s.student_name, e.enrollment_id, a.attendance_id
FROM student s
LEFT JOIN enrollment e ON s.student_id = e.student_id
LEFT JOIN attendance a ON e.enrollment_id = a.enrollment_id
WHERE a.attendance_id IS NULL;

-- 8. RIGHT JOIN (All teachers, including any without assigned classes)
SELECT t.teacher_id, t.teacher_name, c.class_id, c.section
FROM class c
RIGHT JOIN teacher t ON c.teacher_id = t.teacher_id;

-- 9. FULL OUTER JOIN Simulation (MySQL UNION ALL pattern)
SELECT s.student_name, e.class_id
FROM student s
LEFT JOIN enrollment e ON s.student_id = e.student_id
UNION ALL
SELECT s.student_name, e.class_id
FROM student s
RIGHT JOIN enrollment e ON s.student_id = e.student_id
WHERE s.student_id IS NULL;

-- 10. SELF JOIN (Pair classmates enrolled in the same class)
SELECT
  e1.class_id,
  s1.student_name AS student_1,
  s2.student_name AS student_2
FROM enrollment e1
JOIN enrollment e2 ON e1.class_id = e2.class_id AND e1.student_id < e2.student_id
JOIN student s1 ON e1.student_id = s1.student_id
JOIN student s2 ON e2.student_id = s2.student_id
ORDER BY e1.class_id;