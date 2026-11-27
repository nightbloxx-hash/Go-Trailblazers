USE checkin_demo;

-- 1. Nurse "At the Clinic" Update inside a Reversible Transaction
SET SQL_SAFE_UPDATES = 0;
START TRANSACTION;

UPDATE attendance a
JOIN enrollment e ON a.enrollment_id = e.enrollment_id
SET a.status  = 'Absent',
    a.time_in = NULL,
    a.remarks = 'At the Clinic'
WHERE e.student_id = 2025305121
  AND a.attendance_date = '2026-09-28';

SAVEPOINT clinic_updated;

-- Verify the update
SELECT * FROM attendance WHERE remarks = 'At the Clinic';

-- Roll back so baseline sample data stays intact (use COMMIT in live production)
ROLLBACK;
SET SQL_SAFE_UPDATES = 1;

-- 2. Atomic Transaction: Emergency Evacuation Headcount (Proposal Business Rule)
START TRANSACTION;

INSERT IGNORE INTO attendance (enrollment_id, attendance_date, status, time_in, remarks)
SELECT
  e.enrollment_id,
  CURDATE(),
  'Present',
  CURTIME(),
  'Emergency Evacuation Headcount Verified'
FROM enrollment e
WHERE e.class_id = 1;

SELECT ROW_COUNT() AS students_accounted_for;
COMMIT;

-- 3. Role-Based Authorization Example (Data Dictionary Sec. 4)
-- Demonstrates how only authorized teachers/nurses modify attendance:
-- CREATE USER IF NOT EXISTS 'teacher_user'@'%' IDENTIFIED BY 'USTP_Trailblazer2026!';
-- GRANT SELECT, INSERT, UPDATE ON checkin_demo.attendance TO 'teacher_user'@'%';
-- FLUSH PRIVILEGES;