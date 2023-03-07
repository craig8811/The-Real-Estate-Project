/* Now, I will begin exploring the data to summarize the important variables for
our model for housing price prediction. The variables are: square footage, location,
bedrooms, bathrooms, yearbuilt and hometypes. */


-- Lets see the lowest, highest, and average sqft in our dataset(livingarea is listed in sqft but some lotareaunits are acres)
SELECT MIN(livingarea) AS lowest_sqft,
	   MAX(livingarea) AS highest_sqft,
	   AVG(livingarea) AS avg_sqft
FROM g_housing_cleaned
WHERE bedrooms <>0 AND bathrooms <>0;


--Check my distribution of livingareas from lowest to highest. Everthing ok
SELECT livingarea
FROM g_housing_cleaned
ORDER BY livingarea ASC


-- Impute average livingarea for single_family hometype in dekalb county
SELECT *
FROM g_housing_cleaned
WHERE livingarea = 87120

SELECT AVG(livingarea)
FROM g_housing_cleaned
WHERE hometype = 'SINGLE_FAMILY' AND county = 'Dekalb County';


-- Set living area to 2277.24 to id "30038-14485210". Set living area to 2367(cross-referenced), and pricepersquarefoot to 151.67 for "30290-14606909" It's updated now
UPDATE g_housing_cleaned
SET pricepersquarefoot = 151.67
WHERE id = '30290-14606909';



SELECT MIN(livingarea), MAX(livingarea), AVG(livingarea)
FROM g_housing_cleaned
WHERE lotareaunits = 'Acres'
AND bathrooms <>0 AND bedrooms <>0

SELECT MIN(livingarea), MAX(livingarea), AVG(livingarea)
FROM g_housing_cleaned
WHERE lotareaunits = 'sqft'
AND bathrooms <>0 AND bedrooms <>0


-- Investigating the low livingarea values when it's set to Acres loteareunits. They are accurate listings(i.e. cottages/mobile homes)
SELECT id,
       price,
	   city,
	   streetaddress,
       livingarea,
	   hometype,
	   description
	   
FROM g_housing_cleaned
WHERE lotareaunits = 'Acres'
AND bathrooms <>0 AND bedrooms <>0
ORDER BY livingarea ASC


-- Average livingarea and average livingarea by hometype(filtering out lots with no bedrooms and bathrooms, these are for development, not houses)

SELECT ROUND(AVG(livingarea::numeric),2)  -- 2395.71
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <>0

SELECT hometype,
	   ROUND(AVG(livingarea::numeric),2) AS avg_sqft_hometype -- C: 1420, MF: 2477, TH: 2044, SF: 2461, LOT: 2431
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <>0
GROUP BY hometype;


-- All the distinct locations in the dataset(447 cities)
SELECT DISTINCT city
FROM g_housing_cleaned
ORDER BY city ASC;


-- Number of homes in each location

SELECT city,
	   COUNT(*) AS num_of_homes
FROM g_housing_cleaned
WHERE bathrooms <>0 AND bedrooms <>0
GROUP BY city
ORDER BY COUNT(*) DESC, city ASC
LIMIT 10;


-- Total number of homes, excluding lots

WITH homes AS (
		SELECT city,
			   COUNT(*) AS num_of_homes
		FROM g_housing_cleaned
		WHERE bathrooms <>0 AND bedrooms <>0
		GROUP BY city
		ORDER BY COUNT(*) DESC, city ASC)

SELECT SUM(num_of_homes) as total_homes
FROM homes;


-- Bedrooms and Bathrooms distribution
SELECT bedrooms,
	   COUNT(*) AS beds_per_house
FROM g_housing_cleaned
WHERE bedrooms <> 0
GROUP BY bedrooms
ORDER BY COUNT(*) DESC;

SELECT bathrooms,
	   COUNT(*) AS beds_per_house
FROM g_housing_cleaned
WHERE bathrooms <> 0
GROUP BY bathrooms
ORDER BY COUNT(*) DESC;


-- Different hometypes
SELECT DISTINCT hometype
FROM g_housing_cleaned
;


-- Number of homes per hometype
SELECT hometype,
	   COUNT(*) AS num_of_homes
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0
GROUP BY hometype
ORDER BY COUNT(*) DESC;


-- Min, Max, Avg price for homes
SELECT MIN(price) AS low_price,
	   MAX(price) AS high_price,
	   ROUND(AVG(price::numeric),2) AS avg_price
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;


-- Avg price per hometype
SELECT hometype,
	   ROUND(AVG(price::numeric)) AS avg_price_hometype
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0
GROUP BY hometype
ORDER BY AVG(price) DESC;


-- Avg Price per location
SELECT city,
	   ROUND(AVG(price::numeric)) AS avg_price
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0
GROUP BY city
ORDER BY ROUND(AVG(price::numeric)) DESC;


--Avg Price per location per hometype(Good for drilldown visualization)
SELECT city,
	   zipcode,
	   price
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0 AND yearbuilt <> 0
ORDER BY city ASC;





-- Calculating the median price of homes in the dataset excluding undeveloped lots
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) AS median_price
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0
;



-- Median Price per city(City results skewed with low num_homes value)
SELECT city, 
       PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) AS median_price,
	   COUNT(*) AS num_homes
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0
GROUP BY city
ORDER BY 2 DESC;


-- 10 most expensive homes
SELECT *
FROM g_housing_cleaned
ORDER BY price DESC
LIMIT 10;


-- Checking correlation between livingarea and price
SELECT ROUND(corr_price_livarea::numeric,2) AS corr_price_livarea
FROM(SELECT CORR(livingarea,price) AS corr_price_livarea
	FROM g_housing_cleaned
	WHERE bathrooms <> 0 AND bedrooms <> 0) t;
	
SELECT price,
	   livingarea
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0
ORDER BY price ASC, livingarea ASC;


-- Checking correlation between bedrooms and price
SELECT ROUND(correlation::numeric,2) AS corr_price_bed
FROM(SELECT CORR(bedrooms,price) AS correlation
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0) t;

SELECT price,
	   bedrooms
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0
ORDER BY price ASC, bedrooms ASC;


-- Checking correlation between bathrooms and price
SELECT ROUND(correlation::numeric, 2) AS corr_price_bath
FROM(SELECT CORR(bathrooms,price) AS correlation
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0) t;

SELECT price,
	   bathrooms
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0 
ORDER BY price ASC, bathrooms ASC;


-- Checking correlation between yearbuilt and price
SELECT ROUND(correlation::numeric, 2) AS corr_price_year
FROM(SELECT CORR(yearbuilt,price) AS correlation
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0 AND yearbuilt <> 0) t;

SELECT price,
	   yearbuilt
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0 AND yearbuilt <> 0
ORDER BY price ASC, yearbuilt ASC;


-- Checking correlation between cityid and price**dont include
SELECT CORR(cityid, price) AS correlation
FROM g_housing_cleaned
WHERE bathrooms <> 0 AND bedrooms <> 0 AND cityid <> 0;


-- Summary statistics Mean, Median, Mode For(*datepostedstring, price, pricepersquarefoot, yearbuilt, *livingarea, bathrooms, bedrooms, garagespaces)
/*must use difference between date_part to perform some arithmetic for summary date statistics. */



-- Mean, Median, Mode for price(Excluding undeveloped lots)
SELECT ROUND(AVG(price::numeric),2) AS avg_price
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY price) AS median_price
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT MODE() WITHIN GROUP (ORDER BY price) AS mode_price
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;


---- Mean, Median, Mode for pricepersquarefoot(Excluding undeveloped lots)
SELECT ROUND(AVG(pricepersquarefoot::numeric),2) AS avg_pricepersquarefoot
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY pricepersquarefoot) AS median_pricepersquarefoot
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT MODE() WITHIN GROUP (ORDER BY pricepersquarefoot) AS mode_pricepersquarefoot
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;



---- Mean, Median, Mode for yearbuilt(Excluding undeveloped lots)
SELECT ROUND(AVG(yearbuilt::numeric),2) AS avg_yearbuilt
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0 AND yearbuilt <> 0;

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY yearbuilt) AS median_yearbuilt
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0 AND yearbuilt <> 0;

SELECT MODE() WITHIN GROUP (ORDER BY yearbuilt) AS mode_yearbuilt
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0 AND yearbuilt <> 0;


---- Mean, Median, Mode for livingarea(Excluding undeveloped lots)
SELECT ROUND(AVG(livingarea::numeric),2) AS avg_livingarea
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY livingarea) AS median_livingarea
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT MODE() WITHIN GROUP (ORDER BY ROUND(livingarea)) AS mode_livingarea
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;


---- Mean, Median, Mode for bathrooms(Excluding undeveloped lots)
SELECT ROUND(AVG(bathrooms::numeric),2) AS avg_bathrooms
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY bathrooms) AS median_bathrooms
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT MODE() WITHIN GROUP (ORDER BY bathrooms) AS mode_bathrooms
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;


---- Mean, Median, Mode for bedrooms(Excluding undeveloped lots)
SELECT ROUND(AVG(bedrooms::numeric),2) AS avg_bedrooms
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY bedrooms) AS median_bedrooms
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

SELECT MODE() WITHIN GROUP (ORDER BY bedrooms) AS mode_bedrooms
FROM g_housing_cleaned
WHERE bedrooms <> 0 AND bathrooms <> 0;

--Finding the Average Listing in Georgia(city, hometype, price, livingarea, bed, bath)
SELECT city,
	   COUNT(*) AS city_count,
	   hometype,
	   COUNT(*) AS hometype_count,
	   ROUND(AVG(price::numeric)) AS avg_price,
	   ROUND(AVG(livingarea::numeric)) AS avg_sqft,
	   ROUND(AVG(bedrooms::numeric),2) AS avg_beds,
	   ROUND(AVG(bathrooms::numeric),2) AS avg_baths
FROM g_housing_cleaned
GROUP BY city, hometype
ORDER BY 2 DESC, 4 DESC
LIMIT 1;



