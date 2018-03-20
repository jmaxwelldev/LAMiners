-- Create a database to use
CREATE DATABASE LACrime;

USE LACrime;

-- Load and clean the unemployment rate data

CREATE TABLE UnemploymentRate(
	RateDate DATE NOT NULL,
    Rate DECIMAL(4,1) NOT NULL,
    
    PRIMARY KEY (RateDate)
);

LOAD DATA LOCAL INFILE '~/Data/LAMiners/Data/UnemploymentRate.csv' 
	INTO TABLE UnemploymentRate 
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
(@var, Rate)
SET RateDate = STR_TO_DATE(@var, '%m/%d/%y');

SELECT * FROM UnemploymentRate ORDER BY RateDate;

DELETE FROM UnemploymentRate
	WHERE YEAR(RateDate) < 2010;

-- Load the crime data
CREATE TABLE CrimeData(
	ID Int NOT NULL,
    DateReported DATE NOT NULL,
    DateOccurred DATE NOT NULL,
    TimeOccurred TIME NOT NULL,
    AreaID Int NOT NULL,
    AreaName VARCHAR(12),
    ReportingDistrict Int,
    CrimeCode Int NOT NULL DEFAULT -1,
    CrimeCodeDescription VARCHAR(30),
    MOCodes VARCHAR(50),
    VictimAge Int NOT NULL DEFAULT -1,
    VictimSex CHAR(1) NOT NULL DEFAULT 'X',
    VictimDescent CHAR(1) NOT NULL DEFAULT 'X',
    PremiseCode Int,
    PremiseDescription VARCHAR(65),
    WeaponUsedCode Int NOT NULL DEFAULT -1,
    WeaponDescription VARCHAR(50),
    StatusCode CHAR(2),
    StatusDescription VARCHAR(15),
    CrimeCode1 Int NOT NULL DEFAULT -1,
    CrimeCode2 Int NOT NULL DEFAULT -1,
    CrimeCode3 Int NOT NULL DEFAULT -1,
    CrimeCode4 Int NOT NULL DEFAULT -1,
    Address VARCHAR(45),
    CrossStreet VARCHAR(35),
    Location VARCHAR(40),
    
    PRIMARY KEY(ID)
);

SET sql_mode='';

LOAD DATA LOCAL INFILE '~/Data/LAMiners/Data/Crime_Data_from_2010_to_Present.csv' 
	INTO TABLE CrimeData 
	FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
(
	ID,
    @var1,
    @var2,
    @var3,
    AreaID,
    AreaName,
    ReportingDistrict,
    @varCrimeCode,
    CrimeCodeDescription,
    MOCodes,
    @varVictimAge,
    @varVictimSex,
    @varVictimDescent,
    PremiseCode,
    PremiseDescription,
    @varWeaponUsedCode,
    WeaponDescription,
    StatusCode,
    StatusDescription,
    @varCrimeCode1,
    @varCrimeCode2,
    @varCrimeCode3,
    @varCrimeCode4,
    Address,
    CrossStreet, 
    Location
)
SET DateReported = STR_TO_DATE(@var1, '%m/%d/%Y'), 
		DateOccurred = STR_TO_DATE(@var2, '%m/%d/%Y'),
        TimeOccurred = STR_TO_DATE(@var3, '%H%i'),
        CrimeCode = IF(@varCrimeCode = '', -1, @varCrimeCode),
        VictimAge = IF(@varVictimAge = '', -1, @varVictimAge),
        VictimSex = IF(@varVictimSex = '', 'X', @varVictimSex),
        VictimDescent = IF(@varVictimDescent = '', 'X', @varVictimDescent),
        WeaponUsedCode = IF(@varWeaponUsedCode = '', -1, @varWeaponUsedCode),
        CrimeCode1 = IF(@varCrimeCode1 = '', -1, @varCrimeCode1),
        CrimeCode2 = IF(@varCrimeCode2 = '', -1, @varCrimeCode2),
		CrimeCode3 = IF(@varCrimeCode3 = '', -1, @varCrimeCode3),
		CrimeCode4 = IF(@varCrimeCode4 = '', -1, @varCrimeCode4);


DELETE FROM CrimeData 
	WHERE YEAR(DateOccurred) > 2017;

SELECT * FROM CrimeData
	WHERE YEAR(DateOccurred) = 2017
    LIMIT 10;

TRUNCATE CrimeData;
