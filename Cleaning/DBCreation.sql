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

DROP TABLE HourlyWeather;

CREATE TABLE HourlyWeather (
	dfNum Int,
	WeatherDate DATETIME NOT NULL,
    ReportType VARCHAR(5) NOT NULL,
    HourlyVisibility Decimal(5, 2),
	HourlyDryBulbTempF Int,
    HourlyRelativeHumidity Int,
	HourlyPrecip Decimal(5,2),
	HourlyHeatIndex Decimal(5,2),
    PRIMARY KEY(WeatherDate)
);

LOAD DATA LOCAL INFILE '~/Data/LAMiners/Data/HourlyWeather.csv'
	INTO TABLE HourlyWeather
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
(
	dfNum,
	@vdate,
    ReportType,
    @varvisibility,
    @vartemp,
    @varhumid,
    @varprecip,
    @varheatindex
)
SET WeatherDate = STR_TO_DATE(@vdate, '%Y-%m-%d %H:%i'),
		HourlyVisibility = IF(@varvisibility = '', -1, @varvisibility),
        HourlyDryBulbTempF = IF(@vartemp = '', 999, @vartemp),
        HourlyRelativeHumidity = IF(@varhumid='', -1, @varhumid),
        HourlyPrecip = IF(@varprecip='', 0, @varprecip),
        HourlyHeatIndex = IF(@varheatindex='', 999, @varheatindex);

SELECT * FROM HourlyWeather LIMIT 30;

CREATE TABLE DailyWeather (
	dfNum Int NOT NULL, 
	WeatherDate DATE NOT NULL,
    DailyMaximumDryBulbTemp Int,
    DailyMinimumDryBulbTemp Int,
    DailyAverageDryBulbTemp Int,
    DailyAverageRelativeHumidity Int,
    DailySunrise TIME,
    DailySunset TIME,
    DailyPrecip decimal(5,2),
    DailySnowfall decimal(4,1),
    DailySnowDepth decimal(4,1),
    DailyAverageWindSpeed decimal(3,1),
    DailyAverageHeatIndex decimal(5,2),
    PRIMARY KEY (WeatherDate)
);

LOAD DATA LOCAL INFILE '~/Data/LAMiners/Data/DailyWeather.csv'
	INTO TABLE DailyWeather
    FIELDS TERMINATED BY ','
    OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
(
	dfNum,
	@vdate,
    @vTempMax,
    @vTempMin,
    @vTempAvg,
    @vAvgHum,
    @vSunrise,
    @vSunset,
    @vPrecip,
    @vSnowfall,
    @vSnowDepth,
    @vWindSpeed,
    @vHI
)
SET WeatherDate = STR_TO_DATE(@vdate, '%Y-%m-%d'),
		DailyMaximumDryBulbTemp = IF(@vTempMax='', 999, @vTempMax),
        DailyMinimumDryBulbTemp = IF(@vTempMin='', 999, @vTempMin),
        DailyAverageDryBulbTemp = IF(@vTempAvg='', 999, @vTempAvg),
        DailyAverageRelativeHumidity = IF(@vAvgHum='', -1, @vAvgHum),
        DailySunrise = CONCAT(@vSunrise, '00'),
        DailySunset = CONCAT(@vSunset, '00'),
        DailyPrecip = IF(@vPrecip='', 0, @vPrecip),
        DailySnowfall = IF(@vSnowfall='', 0, @vSnowfall),
        DailySnowDepth = IF(@vSnowDepth='', 0, @vSnowDepth),
        DailyAverageWindSpeed = IF(@vWindSpeed='', 0, @vWindSpeed),
        DailyAverageHeatIndex = IF(@vHI='', 999, @vHI);

SELECT * FROM DailyWeather LIMIT 10;