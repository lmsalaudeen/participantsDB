CREATE DATABASE Participants;
USE Participants;

-- Create Personal Information Table
CREATE TABLE personal_info (
    `ID` VARCHAR(6) NOT NULL PRIMARY KEY,
    `first_name` VARCHAR(50),
    `last_name` VARCHAR(50),
    `age` INT,
    `phone` BIGINT,
    `email` VARCHAR(50),
    `house_no` VARCHAR (5),
    `street` VARCHAR(50),
    `city` VARCHAR(25),
    `post_code` VARCHAR(10),
    `country` VARCHAR(20)
);

-- Insert Data into Personal Information Table
INSERT INTO personal_info VALUES 
	('LS01','Latifah','Salaudeen',28,7378777205,'lmsalaudeen@gmail.com',47,'linthorpe','middlesbrough','TS1 3QJ','UK'),
	('FB02','Frodo ','Baggins',50,01642218121,'fbaggins@gmail.com',10,'clairville','middlesbrough','TS4 2HH','UK'),
	('JW03','John','Wick',47,NULL,'jwick@hotmail.com',13,'marton','newcastle','NW8 4QQ','UK'),
	('JB04','James','Bond',55,780500007,'007@gmail.com',6,'cleveland','london','SW1 5HI','UK'),
	('AA05','Avatar','Aang',12,NULL,'aang@basingse.com',25,'air temple','peterbrough','PE2 8PQ','UK');

-- Create Physical Characteristics Table
CREATE TABLE physical_characteristics (
    `ID` VARCHAR (6),
    `height` INT,
    `weight` DECIMAL(4, 2),
    `sex` VARCHAR(1),
    `race` VARCHAR(9),
    FOREIGN KEY (ID) REFERENCES personal_info (ID)
);

-- Insert Data into Physical Characteristics Table
INSERT INTO physical_characteristics VALUES 
	('LS01',169,90.3,'f','african'),
	('FB02',124,45,'m','hobbit'),
	('JW03',185,85,'m','caucasian'),
	('JB04',183,76.4,'m','caucasian'),
	('AA05',150,54,'m','asian');

-- Create Biochemicals Table
CREATE TABLE biochemicals (
    `ID` VARCHAR(6),
    `systolic_bp` INT,
    `diastolic_bp` INT,
    `ldl` NUMERIC(3, 2),
    `hdl` NUMERIC(3, 2),
    `triglyceradehyde` NUMERIC(3, 2),
    FOREIGN KEY (ID) REFERENCES personal_info (ID)
);

-- Insert Data into Biochemicals Table
INSERT INTO biochemicals VALUES 
	('LS01',110,75,1.6,1.94,5.5),
	('FB02',100,75,1.3,1.3,1),
	('JW03',140,80,1.27,1.13,2.6),
	('JB04',135,81,1.3,1.8,1.09),
	('AA05',95,70,0.9,1.56,1.35);
    
-- Create Comorbidities Table
CREATE TABLE comorbidities (
    `ID` VARCHAR(6),
    `heart_disease` VARCHAR(3),
    `retinopathy` VARCHAR(3),
    `metabolic` VARCHAR(3),
    `skin` VARCHAR(3),
    FOREIGN KEY (ID) REFERENCES personal_info (ID)
);

-- Insert Data into Comorbidities Table
INSERT INTO comorbidities VALUES 
	('LS01','no','no','no','no'),
	('FB02','yes','yes','yes','no'),
	('JW03','no','no','no','yes'),
	('JB04','no','no','no','yes'),
	('AA05','no','no','yes','no');
    
-- Create Medications Table
CREATE TABLE meds (
    `ID` VARCHAR(6),
    `dietary_supplement` VARCHAR(3),
    `anti_depressant` VARCHAR(3),
    `contraceptive` VARCHAR(3),
    `anti_hypertensive` VARCHAR(3),
    FOREIGN KEY (ID) REFERENCES personal_info (ID)
);

-- Insert Data into Medications Table
INSERT INTO meds VALUES 
	('LS01','yes','no','yes','no'),
	('FB02','yes','yes','no','yes'),
	('JW03','no','yes','no','yes'),
	('JB04','no','no','no','no'),
	('AA05','no','yes','no','no');
    

-- View Tables
SELECT* FROM personal_info;
SELECT* FROM physical_characteristics;
SELECT* FROM biochemicals;
SELECT* FROM comorbidities;
SELECT* FROM meds;

-- Creating a view to reveal age, sex and comorbidities
CREATE VIEW participants_common AS
SELECT 
c.*, 
physical.sex,
personal.age
FROM comorbidities c
INNER JOIN physical_characteristics physical ON c.ID = physical.ID
INNER JOIN personal_info personal ON c.ID = personal.ID;

SELECT* FROM participants_common;

-- Stored Function
-- a function to calculate bmi
DELIMITER //
CREATE FUNCTION bmi_calc (weight DECIMAL, height INT)
RETURNS DECIMAL(4,2) DETERMINISTIC
BEGIN
    DECLARE bmi VARCHAR(10);
	SET bmi = ROUND(weight/POWER(height/100, 2), 2); 
    RETURN (bmi);
END//
DELIMITER ;

-- call the function
SELECT height, weight, ID, bmi_calc(weight,height) BMI
FROM physical_characteristics;

-- Stored Procedure
-- A procedure to insert new data 

DELIMITER //
CREATE PROCEDURE newEntry(
IN `ID` VARCHAR(6),
IN `first_name` VARCHAR(50),
IN `last_name` VARCHAR(50),
IN `age` INT,
IN `phone` BIGINT,
IN `email` VARCHAR(50),
IN `house_no` VARCHAR (5),
IN `street` VARCHAR(50),
IN `city` VARCHAR(25),
IN `post_code` VARCHAR(10),
IN `country` VARCHAR(20))
BEGIN
INSERT INTO personal_info(ID,first_name,last_name,age,phone,email,house_no,street,city,post_code,country)
VALUES (ID,first_name,last_name,age,phone,email,house_no,street,city,post_code,country);
END//
DELIMITER ;

-- call Procedure
CALL newEntry (
'BS06',
'Baek',
'Sehee',
30,
09134563,
'baeksehee@tteokbokki.com',
45,
'tteokbokki',
'seoul',
'SE1 BS6',
'SK'
);

SELECT* FROM personal_info;

-- alter physical characteristics table to include bmi column
ALTER TABLE physical_characteristics
ADD bmi DECIMAL (4,2);

-- update physical characteristics table to include bmi
UPDATE physical_characteristics
SET bmi = bmi_calc(weight,height);

SELECT* FROM physical_characteristics;

-- a query + subquery to show biochemicals table for those with bmi < 30
SELECT* FROM biochemicals
WHERE ID IN (
SELECT ID FROM physical_characteristics 
WHERE bmi < 30);


SELECT b.*,
physical.bmi
from biochemicals b
JOIN physical_characteristics physical ON b.ID = physical.ID
WHERE b.ID IN (
SELECT ID FROM physical_characteristics 
WHERE bmi < 30);


-- a trigger to set email in lower case
DELIMITER //
CREATE TRIGGER emailFont
BEFORE INSERT ON personal_info
FOR EACH ROW
BEGIN
	SET NEW.email = CONCAT(LOWER(SUBSTRING(NEW.email FROM 1)));
END//
DELIMITER ;

-- Testing the newEntry trigger
CALL newEntry (
'BS07',
'Baek',
'Sehee',
30,
09134563,
'BAEK@tteokbokki.com',
45,
'tteokbokki',
'seoul',
'SE1 BS6',
'SK'
);

SELECT* FROM personal_info;

-- A view to merge all tables but hide identifiable info
CREATE VIEW participants_dataAnalyst AS
SELECT 
c.*, 
physical.sex, physical.race, physical.bmi,
personal.age,
b.ldl, b.hdl, b.triglyceradehyde,
m.dietary_supplement,m.anti_depressant,m.contraceptive,m.anti_hypertensive
from comorbidities c
INNER JOIN physical_characteristics physical ON c.ID = physical.ID
INNER JOIN personal_info personal ON c.ID = personal.ID
INNER JOIN biochemicals b ON c.ID = b.ID
INNER JOIN meds m ON c.ID = m.ID;

SELECT* FROM participants_dataAnalyst;



