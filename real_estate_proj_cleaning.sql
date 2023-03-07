/* Housing Cost Project: Using Linear Regression To Predict The Cost of a House based
on the following variables: location, number of rooms, square footage and other relevant
variables */

##############################
-- Task One: Cleaning The Data
-- In This Task We Will Clean The Data For
-- Duplicates, Missing Values, & String Consistency
##############################

-- 1.1: Handle Missing Data: Impute or remove missing values

SELECT index                   -- Looking for missing values
FROM g_housing
WHERE index IS NULL
OR index = 0;

SELECT id
FROM g_housing
WHERE id IS NULL
OR id = '0';

SELECT stateid
FROM g_housing
WHERE stateid IS NULL
OR stateid = 0;

SELECT countyid
FROM g_housing
WHERE countyid IS NULL
OR countyid = 0;

-- 911 records of cities without their corresponding cityid. Won't impute or remove this column because it isn't an important variable. 
SELECT cityid 
FROM g_housing
WHERE cityid IS NULL
OR cityid = 0
ORDER BY city;

SELECT country
FROM g_housing
WHERE country IS NULL
OR country = '0';

SELECT datepostedstring              -- 1 Null value here. Will remove because its missing multiple data in columns and related to lot sales.
FROM g_housing
WHERE datepostedstring IS NULL 
;

DELETE FROM g_housing				-- Null value has been deleted
WHERE datepostedstring IS NULL
RETURNING *;



SELECT is_bankowned            
FROM g_housing
WHERE is_bankowned IS NULL
OR is_bankowned = 0;

SELECT is_forauction           
FROM g_housing
WHERE is_forauction IS NULL
OR is_forauction = 1;

SELECT event
FROM g_housing
WHERE event IS NULL
OR event = '0';

-- 19 null values. Will remove these rows because they are missing important data(e.g. price, price-sq. ft)
SELECT time					
FROM g_housing
WHERE time IS NULL
OR time = 0;

DELETE FROM g_housing		-- null values have been removed.
WHERE time IS NULL
RETURNING *;

-- 49 estates with 0 as their value. Will remove these rows, missing important data(e.g. price, price-sq. ft)
SELECT price                 
FROM g_housing
WHERE price IS NULL
OR price = 0;

DELETE FROM g_housing		-- Nulls removed.
WHERE price = 0
RETURNING *;



/* pricepersquarefoot has 5432 missing values. Updating by imputing livingarea averages first, then updating 
by imputing pricepersquarfoot derived from price & livingarea. */
SELECT pricepersquarefoot			
FROM g_housing
WHERE pricepersquarefoot = 0
OR pricepersquarefoot IS NULL
;


UPDATE g_housing
SET livingarea = avg_liv_area.avg_living_area
FROM(
	SELECT city, AVG(livingarea) AS avg_living_area
	FROM g_housing
	WHERE livingarea <> 0
	GROUP BY city
	) AS avg_liv_area
WHERE g_housing.city = avg_liv_area.city
AND livingarea = 0


/* pricepersquarefoot has been imputed. Update again because i need to calculate living area based on city 
and hometype for more accurate results.*/

UPDATE g_housing			
SET pricepersquarefoot = price/livingarea
WHERE pricepersquarefoot = 0
;


SELECT city
FROM g_housing
WHERE LENGTH(city) <= 2
OR LENGTH(city) <=3
;

SELECT state
FROM g_housing
WHERE LENGTH(state) <= 20
GROUP BY state
;

-- has 4423 values of 0 and an outlier of 9999. 4,208 of these values are for hometype: lot. Will leave them because they havent been built.
SELECT hometype, COUNT(*)			
FROM g_housing
WHERE yearbuilt IS NULL
OR yearbuilt <= 0
GROUP BY hometype;

SELECT streetaddress
FROM g_housing
WHERE LENGTH(streetaddress) <= 6
;

SELECT zipcode
FROM g_housing
WHERE zipcode <=1


SELECT longitude
FROM g_housing
WHERE longitude IS NULL
OR longitude = 0;

SELECT latitude
FROM g_housing
WHERE latitude IS NULL
OR latitude = 0;

SELECT hasbadgeocode
FROM g_housing
WHERE hasbadgeocode IS NULL
OR hasbadgeocode = 0;

-- 99 null values. Will leave, description isn't important variable.
SELECT *			
FROM g_housing
WHERE description IS NULL
OR description = ' ';


SELECT currency
FROM g_housing
WHERE currency IS NULL
OR currency = '0';

-- 176 values of 0
SELECT livingarea			
FROM g_housing
WHERE livingarea <= 0;

DELETE FROM g_housing		-- 176 values removed
WHERE livingarea <=0
RETURNING*;

--5183 values of 0
SELECT livingareavalue			
FROM g_housing
WHERE livingareavalue IS NULL
OR livingareavalue <= 0;

ALTER TABLE g_housing			-- Removed whole column because it's a copy of livingarea
DROP COLUMN livingareavalue;


SELECT lotareaunits
FROM g_housing
WHERE lotareaunits IS NULL
OR lotareaunits = '0';

-- 4506 values of 0 and an outlier of 89. 4317 values are lots, 166 multi_family, 23 single_family. Won't change any data.
SELECT bathrooms			
FROM g_housing
WHERE bathrooms IS NULL
OR bathrooms <= 0
;

SELECT bedrooms			-- 4492 values of 0. 4293 are lots, 174 multi_family, 24 single_family, 1 condo. Won't change any data.
FROM g_housing
WHERE bedrooms IS NULL
OR bedrooms <= 0
;

-- 7138 values of 0. livingarea and building area are copies of each other.
SELECT livingarea, buildingarea, livingarea - buildingarea			
FROM g_housing
WHERE buildingarea <> 0
AND livingarea - buildingarea > 0;

ALTER TABLE g_housing			--Dropped the buildingarea column
DROP COLUMN buildingarea;


SELECT parking
FROM g_housing
WHERE parking IS NULL
OR parking <= 0;

SELECT garagespaces
FROM g_housing
WHERE garagespaces IS NULL
OR garagespaces <= 0;

SELECT hasgarage
FROM g_housing
WHERE hasgarage IS NULL
OR hasgarage < 0;

-- 6324 values of 0 for levels. Will leave this column data alone for now. 41 different level types.
SELECT levels, COUNT(*)				
FROM g_housing
GROUP BY levels
WHERE levels IS NULL
OR levels = 'One';

SELECT pool
FROM g_housing
WHERE pool IS NULL
OR pool <= 0;

SELECT spa
FROM g_housing
WHERE spa IS NULL
OR spa <= 0;

SELECT isnewconstruction
FROM g_housing
WHERE isnewconstruction IS NULL
OR isnewconstruction <= 0;

SELECT haspetsallowed
FROM g_housing
WHERE haspetsallowed IS NULL
OR haspetsallowed <= 0;

SELECT hometype
FROM g_housing
WHERE hometype IS NULL
OR hometype = '0';

SELECT county
FROM g_housing
WHERE county IS NULL
OR county = '0';




-- 1.2: Handle Duplicates: Identify and remove duplicate records

SELECT index, COUNT(*)
FROM g_housing
GROUP BY index
HAVING COUNT(*) > 1
;

-- Have 1250 duplicates that I need to remove. Use MIN function on index to single out lowest value duplicates.
SELECT id, COUNT(*)	
FROM g_housing
GROUP BY id
HAVING COUNT(*) > 1;


DELETE FROM g_housing			-- The 1250 duplicate ids have been removed
WHERE index NOT IN (
					SELECT MIN(index)
					FROM g_housing
					GROUP BY id)
					
-- ALL DATA AFTER id MAY CONTAIN DUPLICATES, BUT WONT AFFECT OUTCOME AFTER REMOVING id DUPLICATES
 




-- 1.3: Handle Outliers: Detect and correct outliers


SELECT * FROM g_housing

SELECT MAX(index), MIN(index) 	-- 12328 total rows, having max index of 13803 because previously we removed duplicates.
FROM g_housing;

SELECT LENGTH(id), COUNT(*) -- Normal distribution of id length: 14char(5603 values), 15char(2630 values), 16char(4095 values)
FROM g_housing
GROUP BY LENGTH(id);

SELECT stateid, COUNT(*)  -- All same stateid, no outliers
FROM g_housing
GROUP BY stateid;

SELECT countyid, COUNT(*)  -- Even distribution of countyid, no outliers
FROM g_housing
GROUP BY countyid
;

SELECT cityid, COUNT(*)  -- Even distribution of cityid, no outliers
FROM g_housing
GROUP BY cityid
;

SELECT country, COUNT(*)  -- ALL same country 
FROM g_housing
GROUP BY country
;

SELECT MIN(datepostedstring), MAX(datepostedstring) -- Normal distribution, no outlier
FROM g_housing;

SELECT is_bankowned, COUNT(*) -- 12326 not owned by bank, 2 owned by bank
FROM g_housing
GROUP BY is_bankowned;


SELECT is_forauction, COUNT(*) -- 12325 not for auction, 3 for auction
FROM g_housing
GROUP BY is_forauction;

SELECT event, COUNT(*)		-- No outliers 
FROM g_housing
GROUP BY event;

SELECT MAX(time), MIN(time) -- No outliers
FROM g_housing;

/* Have a min. price of 10 then ascending prices of 795,895,975,1000, and etc. 177 values lower than 10,000. 
May have to filter these low values so they don't skew my data.*/

SELECT price 
FROM g_housing
ORDER BY price ASC;

-- The low value of 0.005 pricepersqft are tied to the low values above in price.
SELECT MAX(pricepersquarefoot), MIN(pricepersquarefoot)   
FROM g_housing;

/* Some cities are UPPER CASE. Cross check for duplicates of UPPER and normal case.(Avondale Est,Avondale Estates,
Ball ground, Ball Ground, Blue ridge, Blue Ridge, Trenton, Trenton, JESUP, Jesup, LAGRANGE, Lagrange, JOHNS CREEK, 
Johns Creek, Mc Caysville, McCaysville, Mc Rae, Mc Rae Helena, McRae Helena, Merritt St, Hawkinsville, Norman park, 
Norman Park, Pt Wentworth, Port Wentworth, Rock spring, Rock Spring, Rocky face, Rocky Face, Sandy springs, 
Sandy Springs, Talking rock, Talking Rock, Tunnel hill, Tunnel Hill, Union Pt, Union Point, Warner robins, 
Warner Robins, West Pt, West Point) */

SELECT city, COUNT(*) 
FROM g_housing
GROUP BY city
ORDER BY city ;

-- Updated the cities above and made them uniform.
UPDATE g_housing
SET city = REPLACE(city, 'West Pt', 'West Point')
WHERE city LIKE '%West Pt%';


SELECT state, COUNT(*)		-- Duplicates expected
FROM g_housing
GROUP BY state

-- 4069 values of 0 for yearbuilt. 1 value of 9999(0 values are for undeveloped lots, '9999' value will be filtered)
SELECT yearbuilt, COUNT(*)		
FROM g_housing
GROUP BY yearbuilt
ORDER BY yearbuilt

-- DELETE  id '31401-317206349', '31401-317206359','30363-82610574', streetaddress were exact same.
SELECT streetaddress, COUNT(*), hometype, city, price 
FROM g_housing
GROUP BY streetaddress, hometype, city, price
ORDER BY COUNT(*) DESC; 

-- DELETING 3 Duplicate streetaddresses that were the same but slightly different id
DELETE FROM g_housing
WHERE id IN('30510-2076566105','31401-317206349', '31401-317206359','30363-82610574')
RETURNING *;

SELECT zipcode, COUNT(*)
FROM g_housing
GROUP BY zipcode
ORDER BY COUNT(*) DESC;

SELECT longitude, COUNT(*)
FROM g_housing
GROUP BY longitude
ORDER BY COUNT(*) DESC;


SELECT latitude, COUNT(*)
FROM g_housing
GROUP BY latitude
ORDER BY COUNT(*) DESC;

SELECT hasbadgeocode, COUNT(*)
FROM g_housing
GROUP BY hasbadgeocode;

SELECT description, COUNT(*)
FROM g_housing
GROUP BY description
ORDER BY COUNT(*) DESC;

SELECT currency, COUNT(*)
FROM g_housing
GROUP BY currency
ORDER BY COUNT(*) DESC;

SELECT livingarea, COUNT(*)
FROM g_housing
GROUP BY livingarea
ORDER BY COUNT(*) DESC;

-- Whether lotareunits is listed as acres or sqft, the livingarea output is in sqft 
SELECT lotareaunits, COUNT(*)		
FROM g_housing
GROUP BY lotareaunits
ORDER BY COUNT(*) DESC;


SELECT bathrooms, hometype, COUNT(*)
FROM g_housing
WHERE bathrooms = 0
GROUP BY bathrooms, hometype
ORDER BY COUNT(*) DESC;


SELECT bedrooms, COUNT(*)
FROM g_housing
GROUP BY bedrooms
ORDER BY COUNT(*) DESC;


SELECT parking, COUNT(*)
FROM g_housing
GROUP BY parking;

SELECT garagespaces, COUNT(*)
FROM g_housing
GROUP BY garagespaces;

SELECT hasgarage, COUNT(*)
FROM g_housing
GROUP BY hasgarage;

SELECT levels, COUNT(*)
FROM g_housing
GROUP BY levels;

SELECT pool, COUNT(*)
FROM g_housing
GROUP BY pool;

SELECT spa, COUNT(*)
FROM g_housing
GROUP BY spa;

SELECT isnewconstruction, COUNT(*)
FROM g_housing
GROUP BY isnewconstruction;

SELECT haspetsallowed, COUNT(*)
FROM g_housing
GROUP BY haspetsallowed;

SELECT hometype, COUNT(*)
FROM g_housing
GROUP BY hometype;

SELECT county, COUNT(*)
FROM g_housing
GROUP BY county
ORDER BY county ASC;




-- 1.4: Handle Inconsistent Data: Correct inconsistent or inaccurate data(bed/baths columns)


/* Using REGEXP to find listings with 0 bed or bath that have descriptions of bed/bath so that we can update them.
127 records found for Multi_Family hometypes */
         	
SELECT id, 
	   bathrooms, 
	   bedrooms, 
	   description, 
	   regexp_matches(description, '(\d+)[\s-]*(bed(room)?|bath(room)?(s)?|full\s+bath(s)?)[\s,-]*(\d+)?','gi')
FROM g_housing
WHERE hometype = 'MULTI_FAMILY' AND (bedrooms = 0 OR bathrooms = 0)
ORDER BY bedrooms DESC, bathrooms DESC;

/* ids of Multi_Family to update: "31639-2072223671","31602-248201096","31602-2071770776","31601-217674146", 
"31602-248201097","31602-248201057","30108-71746930","30415-76364920",	"30520-2069567562","30017-14721246" 
"31027-2070051057", "30093-14776437","30071-2069710884","30417-247166169","30046-14720333","30046-14724390"   
"30314-35834054","30096-14786700","30417-2087070435","30228-69916037","30318-69382789","30012-14998190"
"31811-299036383","31811-299036388","30344-35853078","30165-2069653573","30014-2082533786","30014-69860893"
"30014-69887141","30310-35842739","30312-65441115","30017-14721251","30017-14721237","30305-35900793"
"30240-2125751331","31537-240254700","30017-14721243","30017-2069927215","30017-14722251","30017-14722256"
"30017-14722252","30501-2071106315","30224-69895285","30236-35790794","30121-2069810607","30315-35892457"
"31794-227347040","30058-70839448","31794-227350438","31794-227346845","31794-227345449","30161-217338552"
"30317-14466278","30525-2069576184","30401-2073114878","30291-2070335389","30663-252314697","30337-55016988"
"30012-2069621595","30308-71752019","31204-210204723","30017-14721236","30046-14723744","31023-105215604" */



-- 8 records found for SINGLE_FAMILY hometypes

SELECT id, 
	   bathrooms, 
	   bedrooms, 
	   description, 
	   regexp_matches(description, '(\d+)[\s-]*(bed(room)?|bath(room)?(s)?|full\s+bath(s)?)[\s,-]*(\d+)?','gi')
FROM g_housing
WHERE hometype = 'SINGLE_FAMILY' AND (bedrooms = 0 OR bathrooms = 0)
ORDER BY bedrooms DESC, bathrooms DESC;


/* ids of Single_Family to update:"30184-55491257","31069-70827021"
"30607-54366335","30747-2071169210"*/


-- 1 records found for CONDO hometypes

SELECT id, 
	   bathrooms, 
	   bedrooms, 
	   description, 
	   regexp_matches(description, '(\d+)[\s-]*(bed(room)?|bath(room)?(s)?|full\s+bath(s)?)[\s,-]*(\d+)?','gi')
FROM g_housing
WHERE hometype = 'CONDO' AND (bedrooms = 0 OR bathrooms = 0)
ORDER BY bedrooms DESC, bathrooms DESC;

/* ids of CONDO to update:"30605-2069710143"*/




-- 186 records found for LOT hometypes

SELECT id, 
	   bathrooms, 
	   bedrooms, 
	   description, 
	   regexp_matches(description, '(\d+)[\s-]*(bed(room)?|bath(room)?(s)?|full\s+bath(s)?)[\s,-]*(\d+)?','gi')
FROM g_housing
WHERE hometype = 'LOT' AND (bedrooms = 0 OR bathrooms = 0)
ORDER BY bedrooms DESC, bathrooms DESC;

/* ids of LOTS to update:"31632-76508777","31064-2075414403","31063-111810006","31546-105433918","31005-49861887"
"30094-14994046","30564-105323006","30721-214754566","30241-2072211750","31032-2079673115","30240-2097965622"
"30547-2072716008","31076-2071593083","30630-232367700","30442-2071053141","31791-242687198","30635-105241420"
"30543-101327579","30525-2077488869","30628-89890606","31714-193667520","30531-89880673","30728-58519842"
"30629-230148045","30176-2095958273","31021-243909060","30045-14722414","31037-2069653151","30669-2074037854"  */


--Updating all the records for the different hometypes that I flagged above. /* All Records Updated */

UPDATE g_housing
SET bedrooms = 1,
    bathrooms = 1
WHERE id = '30669-2074037854';

-- Deleting records that didn't have enough info to impute. /* Deleted */
DELETE FROM g_housing
WHERE id = '31601-217674146'
RETURNING *;







-- 1.5: Handle Incorrect Data Types: Convert data to the correct data type
/* Data is correctly formatted */
SELECT *
FROM g_housing
;









-- 1.6: Handle Non-Standardized Data: Standardize data across all records
/* Standardize these columns by casting to numeric and rounding to 0 places: 
pricepersquarefoot, livingarea. No need to permanently alter the table */

SELECT ROUND((price/pricepersquarefoot)::numeric,0) AS living_space,
	   ROUND(livingarea::numeric,0) AS livingarea
       
FROM g_housing













-- 1.7: Validate Data: Validate data to ensure it is consistent and accurate
/* Last time checking for nulls/missing values, duplicates, checking data types, outliers */

SELECT *  --12323 total records now
FROM g_housing ;

SELECT price,  -- duplicates
	   COUNT(*)
	   FROM g_housing
GROUP BY price
ORDER BY COUNT(*) DESC


SELECT MAX(price),			-- Outliers
	   MIN(price)
FROM g_housing

SELECT *
FROM g_housing
WHERE price = 10

--Finding outliers using the N_tile function. Filtering the outliers in the bottom 1 and top 100 percentiles.
	   
WITH q1 AS (
			SELECT price, NTILE(100) OVER (ORDER BY price) AS percentile
			FROM g_housing)

SELECT price
FROM q1
WHERE percentile IN (1, 100);
			
-- Deleting the 255 price outliers to  make the data more representative

DELETE FROM g_housing
WHERE price IN(
			WITH q1 AS (
			SELECT price, NTILE(100) OVER (ORDER BY price) AS percentile
			FROM g_housing)

SELECT price
FROM q1
WHERE percentile IN (1, 100))
RETURNING *;


			







-- 1.8: Save the cleaned data in a new file
COPY g_housing TO 'g_housing_cleaned.csv' WITH(FORMAT CSV, HEADER);

COPY (SELECT * FROM g_housing) TO '/Users/craigschlachter/Desktop/g_housing_cleaned.csv' DELIMITER ',' CSV HEADER;