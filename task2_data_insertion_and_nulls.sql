-- create & select database (MySQL)
CREATE DATABASE IF NOT EXISTS elevate_task;
USE elevate_task;

-- create tables
CREATE TABLE department (
  dept_id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employee (
  emp_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50),
  dept_id INT,
  salary DECIMAL(10,2) DEFAULT 30000,
  hired_date DATE DEFAULT (CURRENT_DATE),
  email VARCHAR(150) UNIQUE,
  notes TEXT,
  FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

-- 1) Insert departments
INSERT INTO department (name) VALUES ('Engineering');
INSERT INTO department (name) VALUES ('HR');
INSERT INTO department (name) VALUES ('Sales');

-- 2) Insert employees demonstrating defaults and NULLs
INSERT INTO employee (first_name, last_name, dept_id, salary, email)
VALUES ('Amit', 'Shah', 1, 55000, 'amit.shah@example.com');

INSERT INTO employee (first_name, last_name, dept_id, email, notes)
VALUES ('Rekha', 'Patel', NULL, NULL, NULL);    -- dept and salary/email missing

INSERT INTO employee (first_name, last_name, email)
VALUES ('Vikram', 'Joshi', 'vikram.j@example.com');  -- salary uses DEFAULT

INSERT INTO employee (first_name, last_name, dept_id, salary, email)
VALUES ('Sunita', 'Kaur', 2, NULL, NULL);   -- explicit NULLs

select * from employee;

-- show rows with any important NULL
SELECT emp_id, first_name, last_name, dept_id, salary, email
FROM employee
WHERE dept_id IS NULL OR salary IS NULL OR email IS NULL;

-- count missing per column
SELECT
  SUM(email IS NULL) AS missing_email,
  SUM(dept_id IS NULL) AS missing_dept,
  SUM(salary IS NULL) AS missing_salary
FROM employee;

SET SQL_SAFE_UPDATES = 0;


UPDATE employee
SET salary = 30000
WHERE salary IS NULL;

UPDATE employee
SET dept_id = (SELECT dept_id FROM department WHERE name = 'Sales' LIMIT 1)
WHERE dept_id IS NULL;

UPDATE employee
SET email = LOWER(CONCAT(first_name, '.', last_name, '@example.com'))
WHERE email IS NULL;

SET SQL_SAFE_UPDATES = 1;
SELECT emp_id, first_name, last_name, dept_id, salary, email FROM employee;

-- 10% raise to Engineering (dept_id = 1)
UPDATE employee
SET salary = salary * 1.10
WHERE dept_id = 1;

-- Fix a single row by emp_id
UPDATE employee
SET last_name = 'Joshi'
WHERE emp_id = 3;  -- change id to real value

select * from employee;

-- PREVIEW rows to delete (example: test accounts)
SELECT * FROM employee WHERE LOWER(first_name) LIKE '%test%' OR LOWER(last_name) LIKE '%test%';

-- Delete after preview
START TRANSACTION;
DELETE FROM employee WHERE emp_id = 99; -- example: replace 99 with target id
COMMIT;
-- If mistake: ROLLBACK (before COMMIT)

-- No NULLs remaining in required fields
SELECT COUNT(*) AS missing_email FROM employee WHERE email IS NULL;
SELECT COUNT(*) AS missing_dept FROM employee WHERE dept_id IS NULL;

-- Unique emails check
SELECT email, COUNT(*) AS cnt FROM employee GROUP BY email HAVING cnt > 1;

-- Referential integrity: find employees whose dept_id doesn't exist (should be zero)
SELECT e.emp_id, e.first_name, e.dept_id
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;



