USE LACrime;

-- Join the daily weather to the hourly weather, add a field for whether or not the crime took place in the dark
SELECT h.WeatherDate, ReportType, HourlyVisibility, HourlyDryBulbTempF, HourlyRelativeHumidity, HourlyPrecip, HourlyHeatIndex,
DailyMaximumDryBulbTemp, DailyMinimumDryBulbTemp, DailyAverageDryBulbTemp, DailyAverageRelativeHumidity, DailySunrise, DailySunset, DailyPrecip,
DailySnowfall, DailySnowDepth, DailyAverageWindSpeed, DailyAverageHeatIndex, 
(TIME(h.WeatherDate) < DailySunrise OR  TIME(h.WeatherDate) > DailySunset) AS isDark FROM
	HourlyWeather AS h
	JOIN DailyWeather AS d
	ON DATE(h.WeatherDate) = DATE(d.WeatherDate);


-- Create a table from these results
CREATE OR REPLACE VIEW Weather AS
	(SELECT h.WeatherDate, ReportType, HourlyVisibility, HourlyDryBulbTempF, HourlyRelativeHumidity, HourlyPrecip, HourlyHeatIndex,
	DailyMaximumDryBulbTemp, DailyMinimumDryBulbTemp, DailyAverageDryBulbTemp, DailyAverageRelativeHumidity, DailySunrise, DailySunset, DailyPrecip,
	DailySnowfall, DailySnowDepth, DailyAverageWindSpeed, DailyAverageHeatIndex, (TIME(h.WeatherDate) < DailySunrise OR  TIME(h.WeatherDate) > DailySunset) AS isDark FROM
		HourlyWeather AS h
		JOIN DailyWeather AS d
		ON DATE(h.WeatherDate) = DATE(d.WeatherDate));

-- Exporting the weather table
SELECT * FROM Weather ORDER BY WeatherDate ASC;

-- Match codes and IDs to descriptions
SELECT DISTINCT( CrimeCode), CrimeCodeDescription FROM CrimeData;

SELECT DISTINCT(AreaID), AreaName FROM CrimeData;

SELECT DISTINCT(PremiseCode), PremiseDescription FROM CrimeData;

SELECT DISTINCT(WeaponUsedCode), WeaponDescription FROM CrimeData;

SELECT DISTINCT(StatusCode), StatusDescription FROM CrimeData;

SELECT * FROM CrimeData LIMIT 10;

-- Join the unemployment data to the crime data and export to csv for more processing

SELECT ID, DateReported, DateOccurred, TimeOccurred, AreaID, ReportingDistrict, CrimeCode,
 MOCodes, VictimAge, VictimSex, VictimDescent, PremiseCode, WeaponUsedCode, StatusCode, CrimeCode1, CrimeCode2, CrimeCode3, CrimeCode4,
 Address, CrossStreet, Location, u.Rate AS UnemploymentRate FROM 
	CrimeData AS c
    JOIN UnemploymentRate AS u
    ON MONTH(u.RateDate) = MONTH(c.DateOccurred) AND YEAR(u.RateDate) = YEAR(c.DateOccurred)
    ORDER BY DateOccurred, TimeOccurred ASC;
    
-- Join the weather data to the crime data

/*
SELECT ID, DateReported, DateOccurred, TimeOccurred, AreaID, ReportingDistrict, CrimeCode,
 MOCodes, VictimAge, VictimSex, VictimDescent, PremiseCode, WeaponUsedCode, StatusCode, CrimeCode1, CrimeCode2, CrimeCode3, CrimeCode4,
 Address, CrossStreet, Location, WeatherDate, ReportType, HourlyVisibility, HourlyDryBulbTempF, HourlyRelativehumidity, HourlyPrecip, HourlyHeatIndex,
 DailyMaximumDryBulbTemp, DailyMinimumDryBulbTemp, DailyAverageDryBulbTemp, DailyAverageRelativeHumidity, DailySunrise, DailySunset, DailyPrecip,
 DailySnowfall, DailySnowDepth, DailyAverageWindSpeed, DailyAverageHeatIndex, isDark FROM
	(SELECT MIN(ABS(TimeOccurred - TIME(WeatherDate))), ID, DateReported, DateOccurred, TimeOccurred, AreaID, ReportingDistrict, CrimeCode,
	 MOCodes, VictimAge, VictimSex, VictimDescent, PremiseCode, WeaponUsedCode, StatusCode, CrimeCode1, CrimeCode2, CrimeCode3, CrimeCode4,
	 Address, CrossStreet, Location, WeatherDate, ReportType, HourlyVisibility, HourlyDryBulbTempF, HourlyRelativehumidity, HourlyPrecip, HourlyHeatIndex,
	 DailyMaximumDryBulbTemp, DailyMinimumDryBulbTemp, DailyAverageDryBulbTemp, DailyAverageRelativeHumidity, DailySunrise, DailySunset, DailyPrecip,
	 DailySnowfall, DailySnowDepth, DailyAverageWindSpeed, DailyAverageHeatIndex, isDark FROM
		(SELECT * FROM
			CrimeData AS c
			JOIN Weather AS w
			ON DATE(c.DateOccurred) = Date(w.WeatherDate)) AS DateMatch
			GROUP BY ID) AS trueRows;
*/
-- Takes too long causing timeouts, will use pandas instead
