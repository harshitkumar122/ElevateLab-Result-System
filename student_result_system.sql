DROP DATABASE IF EXISTS StudentResultDB;

CREATE DATABASE StudentResultDB;
USE StudentResultDB;

-- Step 1: Create Tables
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50)
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    credits INT
);

CREATE TABLE Semesters (
    semester_id INT PRIMARY KEY,
    semester_name VARCHAR(50)
);

CREATE TABLE Grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    semester_id INT,
    marks INT,
    grade CHAR(2),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id),
    FOREIGN KEY (semester_id) REFERENCES Semesters(semester_id)
);

-- Step 2: Insert Base Data
INSERT INTO Students VALUES
(1, 'Amit', 'CSE'),
(2, 'Priya', 'ECE'),
(3, 'Rahul', 'ME');

INSERT INTO Courses VALUES
(101, 'DBMS', 4),
(102, 'Maths', 3),
(103, 'OS', 3);

INSERT INTO Semesters VALUES
(1, 'Semester 1'),
(2, 'Semester 2');

DELIMITER //

CREATE TRIGGER auto_grade
BEFORE INSERT ON Grades
FOR EACH ROW
BEGIN
    IF NEW.marks >= 85 THEN
        SET NEW.grade = 'A';
    ELSEIF NEW.marks >= 70 THEN
        SET NEW.grade = 'B';
    ELSEIF NEW.marks >= 60 THEN
        SET NEW.grade = 'C';
    ELSE
        SET NEW.grade = 'D';
    END IF;
END;
//

DELIMITER ;

-- Step 4: Insert Grades (trigger sets grade automatically)
INSERT INTO Grades (student_id, course_id, semester_id, marks) VALUES
(1, 101, 1, 85),
(1, 102, 1, 78),
(2, 101, 1, 90),
(2, 103, 1, 70),
(3, 102, 1, 65),
(3, 103, 1, 88);

-- Step 5: Create GPA View
CREATE VIEW Student_GPA AS
SELECT 
    s.student_id,
    s.name,
ROUND(
    IFNULL(SUM(
        CASE 
            WHEN g.grade = 'A' THEN 10
            WHEN g.grade = 'B' THEN 8
            WHEN g.grade = 'C' THEN 6
            WHEN g.grade = 'D' THEN 4
            ELSE 0
        END * c.credits), 0)
/ NULLIF(SUM(c.credits), 0), 2) AS GPA
FROM Students s
JOIN Grades g ON s.student_id = g.student_id
JOIN Courses c ON g.course_id = c.course_id
GROUP BY s.student_id, s.name;

-- Step 6: Rank Students by GPA
SELECT *,
       RANK() OVER (ORDER BY GPA DESC) AS rank_position
FROM Student_GPA;
SELECT 
    s.name AS student_name,
    c.course_name,
    g.marks,
    g.grade,
    CASE
        WHEN g.marks >= 40 THEN 'Pass'
        ELSE 'Fail'
    END AS result_status
FROM Grades g
JOIN Students s ON g.student_id = s.student_id
JOIN Courses c ON g.course_id = c.course_id;

SELECT 
    s.student_id,
    s.name AS student_name,
    sem.semester_name,
    ROUND(SUM(
        CASE 
            WHEN g.grade = 'A' THEN 10
            WHEN g.grade = 'B' THEN 8
            WHEN g.grade = 'C' THEN 6
            WHEN g.grade = 'D' THEN 4
            ELSE 0
        END * c.credits
    ) / SUM(c.credits), 2) AS semester_gpa
FROM Students s
JOIN Grades g ON s.student_id = g.student_id
JOIN Courses c ON g.course_id = c.course_id
JOIN Semesters sem ON g.semester_id = sem.semester_id
GROUP BY s.student_id, s.name, sem.semester_name
ORDER BY s.student_id, sem.semester_name;

SELECT * FROM Grades;

