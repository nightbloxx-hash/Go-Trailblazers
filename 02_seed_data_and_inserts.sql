USE checkin_demo;

-- 1. Expand Programs to 10 records (BSIT already exists as program_id = 1)
INSERT IGNORE INTO program (program_code, program_name) VALUES
('BSCS',  'Bachelor of Science in Computer Science'),
('BSIS',  'Bachelor of Science in Information Systems'),
('BSCE',  'Bachelor of Science in Civil Engineering'),
('BSEE',  'Bachelor of Science in Electrical Engineering'),
('BSME',  'Bachelor of Science in Mechanical Engineering'),
('BSTCM', 'Bachelor of Science in Technology Communication Management'),
('BSDS',  'Bachelor of Science in Data Science'),
('BSESM', 'Bachelor of Science in Environmental Science and Management'),
('BTLED', 'Bachelor of Technology and Livelihood Education');

-- 2. Expand Academic Terms
INSERT IGNORE INTO academic_term (school_year, semester) VALUES
('2025-2026', '1st Semester'),
('2025-2026', '2nd Semester'),
('2026-2027', '2nd Semester'),
('2026-2027', 'Midyear');

-- 3. Expand Subjects to 11 records (subject_id 1..3 already exist)
INSERT IGNORE INTO subject (subject_code, subject_title, subject_type) VALUES
('IT211', 'Human-Computer Interaction', 'Lecture'),
('IT215', 'Accounting Principles', 'Lecture'),
('IT221', 'Web Systems and Technologies', 'Lecture'),
('IT222', 'Networking 1', 'Laboratory'),
('IT223', 'Object-Oriented Programming', 'Laboratory'),
('ES201', 'Environmental Science', 'Lecture'),
('IM201', 'Information Management', 'Lecture'),
('GE108', 'Ethics', 'Lecture');

-- 4. Expand Teachers to all 10 records from Proposal
INSERT IGNORE INTO teacher (teacher_id, teacher_name, contact_number, email) VALUES
(2025004, 'Mark Villanueva', '9202122234', 'mark.villanueva@ustp.edu.ph'),
(2025005, 'Liza Garcia',     '9212223245', 'liza.garcia@ustp.edu.ph'),
(2025006, 'Carlo Mendoza',   '9222324256', 'carlo.mendoza@ustp.edu.ph'),
(2025007, 'Grace Ramos',     '9232425267', 'grace.ramos@ustp.edu.ph'),
(2025008, 'Paul Lim',        '9242526278', 'paul.lim@ustp.edu.ph'),
(2025009, 'Nina Sandoval',   '9252627123', 'nina.sandoval@ustp.edu.ph'),
(2025010, 'Kevin Tan',       '9262728654', 'kevin.tan@ustp.edu.ph');

-- 5. Expand Classes to 10 records (class_id 1..3 already exist)
INSERT IGNORE INTO class (subject_id, teacher_id, term_id, section, schedule) VALUES
(4,  2025004, 1, 'IT2R2', 'MTh 01:00-02:30 PM'),
(5,  2025005, 1, 'IT2R2', 'S 02:00-03:00 PM'),
(6,  2025006, 1, 'IT2R2', 'ThS 03:00-04:30 PM'),
(7,  2025007, 1, 'IT2R2', 'M 03:00-05:00 PM'),
(8,  2025008, 1, 'IT2R2', 'TTh 08:00-09:30 AM'),
(9,  2025009, 1, 'IT2R4', 'MF 10:00-11:00 AM'),
(10, 2025010, 1, 'IT2R5', 'TTh 11:00-12:30 NN');

-- 6. Expand Students to all 10 records from Proposal (including all 5 group members)
INSERT IGNORE INTO student (student_id, program_id, student_name, year_level, contact_number) VALUES
(2025301932, 1, 'Varren Plantas',  '2nd Year', '9247840034'),
(2025301815, 1, 'Ryan Sabunod',    '2nd Year', '9221257635'),
(2025305022, 1, 'Daniel Padilla',  '2nd Year', '9279845626'),
(2025307409, 1, 'Joshua Garcia',   '2nd Year', '9234675327'),
(2025304336, 2, 'Dwight Ramos',    '2nd Year', '9269043178'),
(2025307731, 3, 'Gerald Anderson', '1st Year', '9255437819'),
(2025309003, 1, 'Alden Richards',  '2nd Year', NULL);

-- 7. Expand Enrollments to 12 records (enrollment_id 1..3 already exist)
INSERT IGNORE INTO enrollment (student_id, class_id) VALUES
(2025305121, 1), -- Kent Alberca in IT212 (IT2R2)
(2025300867, 1), -- Prince Garcia in IT212 (IT2R2)
(2025301932, 1), -- Varren Plantas in IT212 (IT2R2)
(2025301815, 1), -- Ryan Sabunod in IT212 (IT2R2)
(2025305022, 4), -- Daniel Padilla in IT211
(2025307409, 5), -- Joshua Garcia in IT215
(2025304336, 6), -- Dwight Ramos in IT221
(2025307731, 7), -- Gerald Anderson in IT222
(2025309003, 8); -- Alden Richards in IT223

-- 8. Expand Attendance to 16 records (attendance_id 1..4 already exist)
INSERT IGNORE INTO attendance (enrollment_id, attendance_date, status, time_in, remarks) VALUES
(4,  '2026-09-28', 'Present', '07:58:00', NULL),
(5,  '2026-09-28', 'Present', '08:00:00', NULL),
(6,  '2026-09-28', 'Late',    '08:18:00', 'Heavy traffic in Iponan'),
(7,  '2026-09-28', 'Absent',  NULL,       'At the Clinic'),
(1,  '2026-10-02', 'Present', '07:55:00', NULL),
(4,  '2026-10-02', 'Late',    '08:12:00', NULL),
(5,  '2026-10-02', 'Present', '07:59:00', NULL),
(6,  '2026-10-02', 'Absent',  NULL,       'Medical excuse'),
(7,  '2026-10-02', 'Present', '08:03:00', NULL),
(8,  '2026-10-02', 'Present', '13:01:00', NULL),
(9,  '2026-10-03', 'Late',    '14:14:00', NULL),
(10, '2026-10-03', 'Present', '15:00:00', NULL);

-- 9. Additional INSERT Scenarios (Selected columns + Upsert)
INSERT IGNORE INTO student (student_id, program_id, student_name, year_level)
VALUES (2025309901, 1, 'Clarissa Mae Morales', '2nd Year');

INSERT INTO attendance (enrollment_id, attendance_date, status, time_in, remarks)
VALUES (1, '2026-10-05', 'Late', '08:25:00', 'Returned from Clinic')
ON DUPLICATE KEY UPDATE
  status  = VALUES(status),
  time_in = VALUES(time_in),
  remarks = VALUES(remarks);