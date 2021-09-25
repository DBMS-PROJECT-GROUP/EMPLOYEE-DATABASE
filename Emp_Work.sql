//Procedure to update the salary of employee having bonus and delete the record from bonus
DELIMITER $$
CREATE PROCEDURE update_salary()
BEGIN 
	DECLARE f INT ;
	DECLARE id INT ;
	DECLARE bon DECIMAL;
	DECLARE b_id VARCHAR(8);
	DECLARE cur CURSOR  FOR SELECT bonus_id, emp_id,bonus_amount FROM bonus;
	DECLARE CONTINUE handler FOR NOT FOUND SET f=1;
	OPEN cur;
	loop1 : loop
		fetch cur INTO b_id,id,bon;
		if f=1 then 
			leave loop1;
		END if;
		UPDATE employee SET sal = sal + bon WHERE emp_id = id ;
		DELETE FROM bonus WHERE bonus_id=b_id;
	END LOOP loop1;
	close cur;
END$$
DELIMITER ;

//calling procedure 
CALL update_salary();

//Procedure to display the names of employees which are deleted
DROP PROCEDURE if EXISTS show_deleted_emp_names;
DELIMITER $$
CREATE PROCEDURE show_deleted_emp_names()
BEGIN 
	DECLARE f INT DEFAULT 0;
	DECLARE fname VARCHAR(50);
	DECLARE emp_names VARCHAR(5000) DEFAULT ' '; 
	DECLARE cur CURSOR FOR SELECT e_name FROM emp_backup;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET f=1;
	OPEN cur;
	loop1: LOOP
		FETCH cur INTO fname;
		IF f=1 THEN
			LEAVE loop1;
		END IF;
		SET emp_names = CONCAT(emp_names, fname, ', ');
	END LOOP loop1;
	CLOSE cur;
	SELECT emp_names;
END$$
DELIMITER ; 

//call procedure 
CALL show_deleted_emp_names();


//Trigger : to backup the details of employee who are deleted 
DROP TRIGGER IF EXISTS employee_backup;
DELIMITER $$
CREATE TRIGGER employee_backup
AFTER DELETE ON employee FOR EACH ROW 
BEGIN 
	INSERT INTO emp_backup(e_id,e_name,doj,sal,d_id) VALUES 
	(OLD.emp_id,OLD.emp_name,OLD.doj,OLD.sal,OLD.dept_id);
END$$
DELIMITER ;


//Trigger : to check no two leaves are taken for same reason
DELIMITER $$
DROP TRIGGER IF EXISTS check_for_same_reason;
CREATE TRIGGER check_for_same_reason
BEFORE INSERT ON leaves FOR EACH ROW 
BEGIN 
	DECLARE f INT DEFAULT 0;
	DECLARE leave_reason VARCHAR(30);
	DECLARE cur CURSOR FOR SELECT l_reason FROM leaves WHERE emp_id = NEW.emp_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET f=1;
	OPEN cur;
	loop1 : LOOP
		FETCH cur INTO leave_reason;
		IF f=1 THEN 
			LEAVE loop1;
		ELSEIF leave_reason = NEW.l_reason THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No two leaves are allowed for same reason';
		END IF;
	END LOOP loop1;
	CLOSE cur;
END $$
DELIMITER ;


//Trigger to check employee leave not exceeds 3
DELIMITER $$
DROP TRIGGER IF EXISTS check_for_leave;
CREATE TRIGGER check_for_leave
BEFORE INSERT ON leaves FOR EACH ROW 
BEGIN 
	DECLARE c INT ;
	SELECT COUNT(emp_id) FROM leaves WHERE emp_id=NEW.emp_id INTO c;
	IF c>=3 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Not More than 3 leaves are allowed';
	END IF;
END $$
DELIMITER ;


//display names of employee of a certain department 
DELIMITER $$
CREATE PROCEDURE show_emp_names(id INT)
BEGIN 
	DECLARE f INT DEFAULT 0;
	DECLARE fname VARCHAR(50);
	DECLARE emp_names VARCHAR(5000) DEFAULT ' '; 
	DECLARE cur CURSOR FOR SELECT emp_name FROM employee WHERE dept_id=id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET f=1;
	OPEN cur;
	loop1: LOOP
		FETCH cur INTO fname;
		IF f=1 THEN
			LEAVE loop1;
		END IF;
		SET emp_names = CONCAT(emp_names, fname, ', ');
	END LOOP loop1;
	CLOSE cur;
	SELECT emp_names;
END$$
DELIMITER ; 

//call procedure 
CALL show_emp_names(4);


//function display salary of employee in certain dept where the sal is greater than 50000
DELIMITER $$
CREATE FUNCTION display_sal_count(id INT )
RETURNS INT
BEGIN 
	DECLARE count_of_emp INT DEFAULT 0;
	SELECT COUNT(emp_id) FROM employee WHERE sal>50000 AND dept_id =id INTO count_of_emp;
	RETURN count_of_emp;
END $$
DELIMITER ;

//call function
SELECT display_sal_count(7);



CREATE TABLE employee (emp_name VARCHAR(30) NOT NULL,emp_id INTEGER PRIMARY KEY,doj DATE,sal DECIMAL,dept_id INT REFERENCES department(dept_id));

INSERT INTO employee(emp_name,emp_id,doj,sal,dept_id) VALUES 
('Jacob T',1100,'2016-05-16',30000,5),
('Hareesh K',1101,'2018-05-19',40000,1),
('Rahul R',1102,'2019-01-03',35000,2),
('George J',1103,'2019-10-31',33000,5),
('Varun D',1104,'2018-08-15',45000,6),
('David B',1105,'2017-06-22',42000,6),
('Derik J',1106,'2019-03-04',41000,7),
('Ram G',1107,'2015-09-17',46000,3),
('Ann Maria',1108,'2019-03-10',50000,4),
('Reena H',1109,'2017-12-13',53000,7),
('Kiran K',1110,'2019-09-09',52000,4),
('Thomas S',1111,'2018-02-17',54000,3),
('Sanal S',1112,'2017-11-18',35000,2),
('Aishwarya L',1113,2017-07-19,40000,1),
('Megha R',1114,'2018-11-30',42000,7),
('Fathima S',1115,'2016-05-25',45000,1);

CREATE TABLE department (dept_id INTEGER PRIMARY KEY AUTO_INCREMENT,dept_name VARCHAR(30));

INSERT INTO department (dept_name) VALUES 
('General Management'),
('Marketing Department'),
('Operations Department'),
('Finance Department'),
('Sales Department'),
('Human Resource Department'),
('Purchase Department');

CREATE TABLE lEAVES (l_date DATE NOT NULL ,l_reason VARCHAR(30), emp_id INT REFERENCES employee(emp_id));
INSERT INTO LEAVES (emp_id,l_date,l_reason) VALUES 
(1100,'2018-07-01','Sick Leave'),
(1101,'2019-01-02','Casual Leave'),
(1102,'2019-10-10','Marriage Leave'),
(1108,'2019-11-20','Casual Leave'),
(1113,'2017-12-18','Maternity Leave');

CREATE TABLE bonus (bonus_id VARCHAR(6) primary key,emp_id INT REFERENCES employee(emp_id), bonus_amount DECIMAL(7,2));
INSERT INTO bonus (bonus_id ,emp_id,bonus_amount ) VALUES
('B122',1108,2500.00),
('B123',1103,1000.00),
('B124',1113,1200.00),
('B125',1105,1500.00),
('B126',1101,1250.00);

CREATE TABLE company(cmp_name VARCHAR(50) NOT NULL , cmp_id INTEGER NOT NULL , turnover DECIMAL , profit DECIMAL);
INSERT INTO company (cmp_name,cmp_id,turnover,profit) VALUES 
('ACM Solutions',1001,NULL,NULL),
('Infosys',1002,NULL,NULL),
('Tata Consultancy Services',1003,NULL,NULL),
('UST Global',1004,NULL,NULL);

CREATE TABLE emp_backup (e_id INT PRIMARY KEY ,e_name VARCHAR(30) NOT NULL , doj DATE ,sal DECIMAL(10,2), d_id INT );
