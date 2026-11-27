-- =====================================================================
-- Check In, Trailblazers!  |  MySQL DDL script (8.0 / 9.0)
-- Based on the Physical Database Design (dbdiagram.io) in the proposal.
-- Run on a disposable training database, never on production.
-- Run the error tests (section 5) ONE AT A TIME; they are meant to fail.
-- =====================================================================

-- 1. Database ---------------------------------------------------------
SELECT VERSION();

CREATE DATABASE IF NOT EXISTS checkin_demo
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE checkin_demo;
SELECT DATABASE();

-- 2. Tables (dependency order) ----------------------------------------
-- program, academic_term, subject, teacher -> class, student
-- -> enrollment -> attendance

CREATE TABLE program (
  program_id   INT NOT NULL AUTO_INCREMENT,
  program_code VARCHAR(20)  NOT NULL,
  program_name VARCHAR(120) NOT NULL,
  PRIMARY KEY (program_id),
  UNIQUE KEY uq_program_code (program_code),
  CONSTRAINT chk_program_code CHECK (CHAR_LENGTH(TRIM(program_code)) > 0),
  CONSTRAINT chk_program_name CHECK (CHAR_LENGTH(TRIM(program_name)) > 0)
) ENGINE=InnoDB;

CREATE TABLE academic_term (
  term_id     INT NOT NULL AUTO_INCREMENT,
  school_year VARCHAR(9)  NOT NULL,
  semester    VARCHAR(20) NOT NULL,
  PRIMARY KEY (term_id),
  UNIQUE KEY uq_term (school_year, semester),
  CONSTRAINT chk_term_year CHECK (CHAR_LENGTH(TRIM(school_year)) > 0),
  CONSTRAINT chk_term_sem  CHECK (CHAR_LENGTH(TRIM(semester)) > 0)
) ENGINE=InnoDB;

CREATE TABLE subject (
  subject_id    INT NOT NULL AUTO_INCREMENT,
  subject_code  VARCHAR(20)  NOT NULL,
  subject_title VARCHAR(120) NOT NULL,
  subject_type  VARCHAR(20)  NOT NULL,
  PRIMARY KEY (subject_id),
  UNIQUE KEY uq_subject_code (subject_code),
  CONSTRAINT chk_subject_code  CHECK (CHAR_LENGTH(TRIM(subject_code)) > 0),
  CONSTRAINT chk_subject_title CHECK (CHAR_LENGTH(TRIM(subject_title)) > 0),
  CONSTRAINT chk_subject_type  CHECK (CHAR_LENGTH(TRIM(subject_type)) > 0)
) ENGINE=InnoDB;

CREATE TABLE teacher (
  teacher_id     INT NOT NULL,
  teacher_name   VARCHAR(120) NOT NULL,
  contact_number VARCHAR(15)  DEFAULT NULL,
  email          VARCHAR(150) NOT NULL,
  PRIMARY KEY (teacher_id),
  UNIQUE KEY uq_teacher_email (email),
  CONSTRAINT chk_teacher_name  CHECK (CHAR_LENGTH(TRIM(teacher_name)) > 0),
  CONSTRAINT chk_teacher_email CHECK (CHAR_LENGTH(TRIM(email)) > 0)
) ENGINE=InnoDB;

CREATE TABLE class (
  class_id   INT NOT NULL AUTO_INCREMENT,
  subject_id INT NOT NULL,
  teacher_id INT NOT NULL,
  term_id    INT NOT NULL,
  section    VARCHAR(20) NOT NULL,
  schedule   VARCHAR(50) NOT NULL,
  PRIMARY KEY (class_id),
  UNIQUE KEY uq_class_offering (subject_id, term_id, section),
  CONSTRAINT chk_class_section  CHECK (CHAR_LENGTH(TRIM(section)) > 0),
  CONSTRAINT chk_class_schedule CHECK (CHAR_LENGTH(TRIM(schedule)) > 0),
  CONSTRAINT fk_class_subject FOREIGN KEY (subject_id)
    REFERENCES subject(subject_id) ON DELETE RESTRICT,
  CONSTRAINT fk_class_teacher FOREIGN KEY (teacher_id)
    REFERENCES teacher(teacher_id) ON DELETE RESTRICT,
  CONSTRAINT fk_class_term FOREIGN KEY (term_id)
    REFERENCES academic_term(term_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE student (
  student_id     INT NOT NULL,
  program_id     INT NOT NULL,
  student_name   VARCHAR(120) NOT NULL,
  year_level     VARCHAR(20)  NOT NULL,
  contact_number VARCHAR(15)  DEFAULT NULL,
  PRIMARY KEY (student_id),
  CONSTRAINT chk_student_name  CHECK (CHAR_LENGTH(TRIM(student_name)) > 0),
  CONSTRAINT chk_student_level CHECK (CHAR_LENGTH(TRIM(year_level)) > 0),
  CONSTRAINT fk_student_program FOREIGN KEY (program_id)
    REFERENCES program(program_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE enrollment (
  enrollment_id INT NOT NULL AUTO_INCREMENT,
  student_id    INT NOT NULL,
  class_id      INT NOT NULL,
  PRIMARY KEY (enrollment_id),
  UNIQUE KEY uq_enrollment (student_id, class_id),
  CONSTRAINT fk_enroll_student FOREIGN KEY (student_id)
    REFERENCES student(student_id) ON DELETE RESTRICT,
  CONSTRAINT fk_enroll_class FOREIGN KEY (class_id)
    REFERENCES class(class_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE attendance (
  attendance_id   INT NOT NULL AUTO_INCREMENT,
  enrollment_id   INT NOT NULL,
  attendance_date DATE NOT NULL,
  status          VARCHAR(10) NOT NULL,
  time_in         TIME DEFAULT NULL,
  remarks         VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (attendance_id),
  UNIQUE KEY uq_attendance_day (enrollment_id, attendance_date),
  CONSTRAINT chk_attendance_status
    CHECK (status IN ('Present','Absent','Late')),
  CONSTRAINT fk_attendance_enrollment FOREIGN KEY (enrollment_id)
    REFERENCES enrollment(enrollment_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

SHOW TABLES;

-- 3. Sample data (taken from the proposal's sample values) ------------
INSERT INTO program (program_code, program_name)
VALUES ('BSIT', 'Bachelor of Science in Information Technology');

INSERT INTO academic_term (school_year, semester)
VALUES ('2026-2027', '1st Semester');

INSERT INTO subject (subject_code, subject_title, subject_type)
VALUES ('IT212', 'Database Systems', 'Lecture'),
       ('IT213', 'Platform Technologies', 'Lecture'),
       ('IT214', 'Human-Computer Interaction', 'Lecture');

INSERT INTO teacher (teacher_id, teacher_name, contact_number, email)
VALUES (2025001, 'Maria Santos',   '9171819201', 'maria.santos@ustp.edu.ph'),
       (2025002, 'Juan Dela Cruz', '9181920212', 'juan.delacruz@ustp.edu.ph'),
       (2025003, 'Ana Reyes',      '9192021223', 'ana.reyes@ustp.edu.ph');

INSERT INTO class (subject_id, teacher_id, term_id, section, schedule)
VALUES (1, 2025001, 1, 'IT2R2', 'MF 08:00-10:00 AM'),
       (2, 2025002, 1, 'IT2R1', 'TTh 09:30-11:00 AM'),
       (3, 2025003, 1, 'IT2R3', 'MT 06:00-07:30 PM');

INSERT INTO student (student_id, program_id, student_name, year_level, contact_number)
VALUES (2025304619, 1, 'Niel Flores',  '2nd Year', '9208645821'),
       (2025305121, 1, 'Kent Alberca', '2nd Year', '9191674352'),
       (2025300867, 1, 'Prince Garcia','2nd Year', '9219840323');

INSERT INTO enrollment (student_id, class_id)
VALUES (2025304619, 1), (2025305121, 2), (2025300867, 3);

INSERT INTO attendance (enrollment_id, attendance_date, status, time_in, remarks)
VALUES (1, '2026-09-28', 'Present', '08:02:00', NULL),
       (2, '2026-09-28', 'Late',    '08:15:00', NULL),
       (3, '2026-09-29', 'Present', '09:01:00', NULL),
       (3, '2026-09-30', 'Absent',  NULL,       'At the Clinic');

SELECT * FROM attendance;

-- 4. Generated report (attendance summary per student) ---------------
SELECT s.student_name,
       SUM(a.status = 'Present') AS present_count,
       SUM(a.status = 'Absent')  AS absent_count,
       SUM(a.status = 'Late')    AS late_count
FROM attendance a
JOIN enrollment e ON e.enrollment_id = a.enrollment_id
JOIN student s    ON s.student_id    = e.student_id
GROUP BY s.student_id, s.student_name;

-- 5. ERROR TESTS - run each ONE AT A TIME (they should fail) ---------
-- Duplicate PK (1062):
--   INSERT INTO teacher VALUES (2025001,'Test','9000000000','test@ustp.edu.ph');
-- Duplicate UNIQUE email (1062):
--   INSERT INTO teacher VALUES (2025099,'Test','9000000000','maria.santos@ustp.edu.ph');
-- NULL in required field (1048):
--   INSERT INTO program (program_code, program_name) VALUES (NULL,'No Code');
-- Invalid CHECK, status not allowed (3819):
--   INSERT INTO attendance (enrollment_id,attendance_date,status)
--   VALUES (1,'2026-10-05','Excused');
-- Invalid FK, program does not exist (1452):
--   INSERT INTO student (student_id,program_id,student_name,year_level)
--   VALUES (2025999999,999,'Ghost','1st Year');
-- Duplicate attendance, same student+class+date (1062):
--   INSERT INTO attendance (enrollment_id,attendance_date,status)
--   VALUES (1,'2026-09-28','Present');
-- Duplicate enrollment (1062):
--   INSERT INTO enrollment (student_id,class_id) VALUES (2025304619,1);

-- 6. ALTER TABLE -------------------------------------------------------
ALTER TABLE teacher ADD COLUMN department VARCHAR(80) NULL;
ALTER TABLE teacher MODIFY COLUMN department VARCHAR(150) NULL;
ALTER TABLE teacher RENAME COLUMN department TO teacher_department;
ALTER TABLE attendance ADD CONSTRAINT chk_remarks_len
  CHECK (remarks IS NULL OR CHAR_LENGTH(remarks) <= 200);
ALTER TABLE attendance DROP CHECK chk_remarks_len;
ALTER TABLE teacher DROP COLUMN teacher_department;

-- 7. Referential integrity (both should FAIL) -------------------------
-- DELETE FROM teacher WHERE teacher_id = 2025001;   -- error 1451
-- DROP TABLE teacher;                               -- error 3730

-- 8. RENAME, TRUNCATE, DROP --------------------------------------------
CREATE TABLE ddl_practice (
  id INT AUTO_INCREMENT PRIMARY KEY,
  remarks VARCHAR(100)
);
INSERT INTO ddl_practice (remarks) VALUES ('First'),('Second');
RENAME TABLE ddl_practice TO ddl_experiment;
TRUNCATE TABLE ddl_experiment;
SELECT COUNT(*) FROM ddl_experiment;
DROP TABLE ddl_experiment;

-- 9. Final verification ------------------------------------------------
SHOW TABLES;
SELECT table_name, column_name, referenced_table_name, referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = 'checkin_demo'
  AND referenced_table_name IS NOT NULL
ORDER BY table_name, column_name;
