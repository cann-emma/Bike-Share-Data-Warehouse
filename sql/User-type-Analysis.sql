-- DATA ANALYSIS BY USER TYPE
-- How do riding patterns differ between annual members and casual riders?

-- Total rides by Rider Type
SELECT r.member_casual, COUNT(r.rider_type_key)
FROM fact_trips f
INNER JOIN dim_rider_type r
USING (rider_type_key)
GROUP BY r.member_casual;


--- Average and Median Trip Duration
SELECT ROUND(AVG(f.trip_duration_minutes), 1) as avg_ride_duration,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY f.trip_duration_minutes) as median_ride_duration
FROM fact_trips f;

--- Average Trip Duration By Rider Type
SELECT r.member_casual, ROUND(AVG(f.trip_duration_minutes), 1) as avg_ride_duration
FROM fact_trips f
INNER JOIN dim_rider_type r
USING (rider_type_key)
GROUP BY r.member_casual;

--- Median Trip Duration By Rider Type 
SELECT r.member_casual, 
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY f.trip_duration_minutes) as median_ride_duration
FROM fact_trips f
INNER JOIN dim_rider_type r
USING (rider_type_key)
GROUP BY r.member_casual;


--- Overall Weekday Ride Frequency By Rider Type

SELECT r.member_casual, 
CASE WHEN d.day_of_week= 0 THEN 'Sunday'
WHEN d.day_of_week= 1 THEN 'Monday'
WHEN d.day_of_week= 2 THEN 'Tuesday'
WHEN d.day_of_week= 3 THEN 'Wednesday'
WHEN d.day_of_week= 4 THEN 'Thursday'
WHEN d.day_of_week= 5 THEN 'Friday'
WHEN d.day_of_week= 6 THEN 'Saturday' END as dow, 
COUNT(d.day_of_week) as weekly_freq
FROM fact_trips f
INNER JOIN dim_rider_type r 
USING (rider_type_key)
INNER JOIN dim_date d
USING (date_key)
GROUP BY r.member_casual, d.day_of_week
ORDER BY d.day_of_week ASC, member_casual DESC;

--- Total Number of trips per DOW
SELECT  
CASE WHEN d.day_of_week= 0 THEN 'Sunday'
WHEN d.day_of_week= 1 THEN 'Monday'
WHEN d.day_of_week= 2 THEN 'Tuesday'
WHEN d.day_of_week= 3 THEN 'Wednesday'
WHEN d.day_of_week= 4 THEN 'Thursday'
WHEN d.day_of_week= 5 THEN 'Friday'
WHEN d.day_of_week= 6 THEN 'Saturday' END as dow, 
COUNT(d.day_of_week) as total_trips
FROM fact_trips f
INNER JOIN dim_date d
USING (date_key)
GROUP BY d.day_of_week
ORDER BY total_trips DESC;

--- Median Trip Duration by DOW
SELECT 
CASE WHEN d.day_of_week= 0 THEN 'Sunday'
WHEN d.day_of_week= 1 THEN 'Monday'
WHEN d.day_of_week= 2 THEN 'Tuesday'
WHEN d.day_of_week= 3 THEN 'Wednesday'
WHEN d.day_of_week= 4 THEN 'Thursday'
WHEN d.day_of_week= 5 THEN 'Friday'
WHEN d.day_of_week= 6 THEN 'Saturday' END as dow, 
ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY f.trip_duration_minutes)::NUMERIC, 1) as median_trip_duration
FROM fact_trips f
INNER JOIN dim_date d
USING (date_key)
GROUP BY dow
ORDER BY median_trip_duration DESC;

---Remaining Questions: How do these patterns change across season?
---Is this trend general or season spefic?

SELECT CASE WHEN EXTRACT(MONTH FROM date_key) IN (12,1,2) THEN 'Winter'
WHEN EXTRACT(MONTH FROM date_key) IN (3,4,5) THEN 'Spring'
WHEN EXTRACT(MONTH FROM date_key) IN (6,7,8) THEN 'Summer'
WHEN EXTRACT(MONTH FROM date_key) IN (9,10,11) THEN 'Fall' END AS seasons,
ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
FROM fact_trips
GROUP BY seasons
ORDER BY seasons DESC;

---
SELECT CASE WHEN EXTRACT(MONTH FROM f.date_key) IN (12,1,2) THEN 'Winter'
WHEN EXTRACT(MONTH FROM f.date_key) IN (3,4,5) THEN 'Spring'
WHEN EXTRACT(MONTH FROM f.date_key) IN (6,7,8) THEN 'Summer'
WHEN EXTRACT(MONTH FROM f.date_key) IN (9,10,11) THEN 'Fall' END AS seasons, r.member_casual,
ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
FROM fact_trips f
INNER JOIN dim_rider_type r
USING (rider_type_key)
GROUP BY seasons, r.member_casual
ORDER BY seasons DESC;


--- Bike Use By Season
SELECT CASE WHEN EXTRACT(MONTH FROM f.date_key) IN (12,1,2) THEN 'Winter'
WHEN EXTRACT(MONTH FROM f.date_key) IN (3,4,5) THEN 'Spring'
WHEN EXTRACT(MONTH FROM f.date_key) IN (6,7,8) THEN 'Summer'
WHEN EXTRACT(MONTH FROM f.date_key) IN (9,10,11) THEN 'Fall' END AS seasons, b.rideable_type, 
COUNT(b.bike_type_key) AS trip_count
FROM fact_trips f
INNER JOIN dim_bike_type b
USING (bike_type_key)
GROUP BY seasons, b.rideable_type
ORDER BY trip_count DESC;


---
SELECT b.rideable_type,
ROUND(AVG(f.trip_duration_minutes), 1) as avg_ride_duration
FROM fact_trips f
INNER JOIN dim_bike_type b
USING (bike_type_key) 
GROUP BY b.rideable_type
ORDER BY avg_ride_duration DESC;

---
SELECT b.rideable_type,
ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY f.trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
FROM fact_trips f
INNER JOIN dim_bike_type b
USING (bike_type_key) 
GROUP BY b.rideable_type
ORDER BY median_ride_duration DESC;

---
SELECT CASE WHEN EXTRACT(MONTH FROM f.date_key) IN (12,1,2) THEN 'Winter'
WHEN EXTRACT(MONTH FROM f.date_key) IN (3,4,5) THEN 'Spring'
WHEN EXTRACT(MONTH FROM f.date_key) IN (6,7,8) THEN 'Summer'
WHEN EXTRACT(MONTH FROM f.date_key) IN (9,10,11) THEN 'Fall' END AS seasons, b.rideable_type,
ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
FROM fact_trips f
INNER JOIN dim_bike_type b
USING (bike_type_key) 
GROUP BY seasons, b.rideable_type
ORDER BY seasons DESC;

---
SELECT f.ride_id, start_station.station_name AS start_station_name, end_station.station_name AS end_station_name
FROM fact_trips f
LEFT JOIN dim_station start_station
ON f.start_station_key = start_station.station_key
LEFT JOIN dim_station end_station
ON f.end_station_key = end_station.station_key;







-- DATA ANALYSIS BY USER TYPE
-- How do riding patterns differ between annual members and casual riders?


--- TOTALS
-- SELECT COUNT(*) AS total_rides FROM fact_trips;

-- --- Total rides by Rider Type
-- SELECT r.member_casual, COUNT(*)
-- FROM fact_trips f
-- INNER JOIN dim_rider_type r
-- USING (rider_type_key)
-- GROUP BY r.member_casual;

--- Total Rides Per Rideable Type
-- SELECT b.rideable_type, COUNT(*)
-- FROM fact_trips f
-- INNER JOIN dim_bike_type b
-- USING (bike_type_key) 
-- GROUP BY b.rideable_type;


-- SELECT r.member_casual, b.rideable_type, COUNT(*)
-- FROM fact_trips f
-- INNER JOIN dim_rider_type r
-- USING (rider_type_key)
-- INNER JOIN dim_bike_type b
-- USING (bike_type_key) 
-- GROUP BY r.member_casual, b.rideable_type;



-- SELECT r.member_casual, 
-- CASE WHEN d.day_of_week= 0 THEN 'Sunday'
-- WHEN d.day_of_week= 1 THEN 'Monday'
-- WHEN d.day_of_week= 2 THEN 'Tuesday'
-- WHEN d.day_of_week= 3 THEN 'Wednesday'
-- WHEN d.day_of_week= 4 THEN 'Thursday'
-- WHEN d.day_of_week= 5 THEN 'Friday'
-- WHEN d.day_of_week= 6 THEN 'Saturday' END as dow, 
-- COUNT(d.day_of_week) as weekly_freq
-- FROM fact_trips f
-- INNER JOIN dim_rider_type r 
-- USING (rider_type_key)
-- INNER JOIN dim_date d
-- USING (date_key)
-- GROUP BY r.member_casual, d.day_of_week
-- ORDER BY d.day_of_week ASC, member_casual DESC;

--- Total Number of trips per DOW
SELECT  
CASE WHEN d.day_of_week= 0 THEN 'Sunday'
WHEN d.day_of_week= 1 THEN 'Monday'
WHEN d.day_of_week= 2 THEN 'Tuesday'
WHEN d.day_of_week= 3 THEN 'Wednesday'
WHEN d.day_of_week= 4 THEN 'Thursday'
WHEN d.day_of_week= 5 THEN 'Friday'
WHEN d.day_of_week= 6 THEN 'Saturday' END as dow, 
COUNT(d.day_of_week) as total_trips
FROM fact_trips f
INNER JOIN dim_date d
USING (date_key)
GROUP BY d.day_of_week
ORDER BY total_trips DESC;




--- PERCENTAGES
-- SELECT r.member_casual, ROUND(COUNT(*) * 100.0/(SELECT COUNT(*) FROM fact_trips), 2) AS pct
-- FROM fact_trips f
-- INNER JOIN dim_rider_type r
-- USING (rider_type_key)
-- GROUP BY r.member_casual;

-- SELECT b.rideable_type, COUNT(*) AS trip_count,
-- ROUND(COUNT(*) * 100.0 /(SELECT COUNT(*) FROM fact_trips),2) AS pct_of_total_trips
-- FROM fact_trips f
-- JOIN dim_bike_type b
-- USING (bike_type_key)
-- GROUP BY b.rideable_type
-- ORDER BY pct_of_total_trips DESC;

--- -- Percentage of Total Trips Represented by Each Rider Type and Bike Type Combination
-- SELECT r.member_casual, b.rideable_type, COUNT(*)*100.0/ SUM((COUNT(*)) OVER (PARTITION BY b.rideable_type) as pct
-- FROM fact_trips f
-- INNER JOIN dim_rider_type r
-- USING (rider_type_key)
-- INNER JOIN dim_bike_type b
-- USING (bike_type_key) 
-- GROUP BY r.member_casual, b.rideable_type;


-- SELECT b.rideable_type,r.member_casual, COUNT(*) AS trip_count,
-- ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER (PARTITION BY b.rideable_type),2) AS pct_of_rideable_type
-- FROM fact_trips f
-- JOIN dim_rider_type r
-- USING (rider_type_key)
-- JOIN dim_bike_type b
-- USING (bike_type_key)
-- GROUP BY b.rideable_type,r.member_casual
-- ORDER BY b.rideable_type,r.member_casual;

--- 
-- SELECT  
-- CASE WHEN d.day_of_week= 0 THEN 'Sunday'
-- WHEN d.day_of_week= 1 THEN 'Monday'
-- WHEN d.day_of_week= 2 THEN 'Tuesday'
-- WHEN d.day_of_week= 3 THEN 'Wednesday'
-- WHEN d.day_of_week= 4 THEN 'Thursday'
-- WHEN d.day_of_week= 5 THEN 'Friday'
-- WHEN d.day_of_week= 6 THEN 'Saturday' END as dow, 
-- COUNT(d.day_of_week) as total_trips, ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM fact_trips), 2) as pct
-- FROM fact_trips f
-- INNER JOIN dim_date d
-- USING (date_key)
-- GROUP BY dow;



-- SELECT  
-- CASE WHEN d.day_of_week= 0 THEN 'Sunday'
-- WHEN d.day_of_week= 1 THEN 'Monday'
-- WHEN d.day_of_week= 2 THEN 'Tuesday'
-- WHEN d.day_of_week= 3 THEN 'Wednesday'
-- WHEN d.day_of_week= 4 THEN 'Thursday'
-- WHEN d.day_of_week= 5 THEN 'Friday'
-- WHEN d.day_of_week= 6 THEN 'Saturday' END as dow, r.member_casual, 
-- COUNT(d.day_of_week) as total_trips
-- FROM fact_trips f
-- INNER JOIN dim_date d
-- USING (date_key)
-- INNER JOIN dim_rider_type r
-- USING (rider_type_key)
-- GROUP BY dow, r.member_casual;


WITH temp AS(SELECT  
CASE WHEN d.day_of_week= 0 THEN 'Sunday'
WHEN d.day_of_week= 1 THEN 'Monday'
WHEN d.day_of_week= 2 THEN 'Tuesday'
WHEN d.day_of_week= 3 THEN 'Wednesday'
WHEN d.day_of_week= 4 THEN 'Thursday'
WHEN d.day_of_week= 5 THEN 'Friday'
WHEN d.day_of_week= 6 THEN 'Saturday' END as dow, r.member_casual, 
COUNT(d.day_of_week) as total_trips
FROM fact_trips f
INNER JOIN dim_date d
USING (date_key)
INNER JOIN dim_rider_type r
USING (rider_type_key)
GROUP BY dow, r.member_casual)

SELECT dow, member_casual, total_trips, ROUND(total_trips*100.0/SUM(total_trips) OVER(PARTITION BY dp), 2) as pct
FROM temp
GROUP BY dow, member_casual, total_trips;



--- MEANS AND MEDIANS
-- --- Average and Median Trip Duration
-- SELECT ROUND(AVG(f.trip_duration_minutes), 1) as avg_ride_duration,
-- PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY f.trip_duration_minutes) as median_ride_duration
-- FROM fact_trips f;


--  Average and Median Trip Duration By Rider Type
-- SELECT r.member_casual, ROUND(AVG(f.trip_duration_minutes), 1) as avg_ride_duration,
-- ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY f.trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
-- FROM fact_trips f
-- INNER JOIN dim_rider_type r
-- USING (rider_type_key)
-- GROUP BY r.member_casual;


--- Average and Median Trip Duration By Rideable Type

-- SELECT b.rideable_type,
-- ROUND(AVG(f.trip_duration_minutes), 1) as avg_ride_duration,
-- ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY f.trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
-- FROM fact_trips f
-- INNER JOIN dim_bike_type b
-- USING (bike_type_key) 
-- GROUP BY b.rideable_type;



--- Average and Median Trip Duration By User and Rideable Type

-- SELECT r.member_casual, b.rideable_type,
-- ROUND(AVG(f.trip_duration_minutes), 1) as avg_ride_duration,
-- ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY f.trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
-- FROM fact_trips f
-- INNER JOIN dim_bike_type b
-- USING (bike_type_key) 
-- INNER JOIN dim_rider_type r
-- USING (rider_type_key)
-- GROUP BY r.member_casual, b.rideable_type;



-- --- Overall Weekday Ride Frequency By Rider Type



--- Median Trip Duration by DOW
-- SELECT 
-- CASE WHEN d.day_of_week= 0 THEN 'Sunday'
-- WHEN d.day_of_week= 1 THEN 'Monday'
-- WHEN d.day_of_week= 2 THEN 'Tuesday'
-- WHEN d.day_of_week= 3 THEN 'Wednesday'
-- WHEN d.day_of_week= 4 THEN 'Thursday'
-- WHEN d.day_of_week= 5 THEN 'Friday'
-- WHEN d.day_of_week= 6 THEN 'Saturday' END as dow, 
-- ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY f.trip_duration_minutes)::NUMERIC, 1) as median_trip_duration
-- FROM fact_trips f
-- INNER JOIN dim_date d
-- USING (date_key)
-- GROUP BY dow
-- ORDER BY median_trip_duration DESC;



---Remaining Questions: How do these patterns change across season?
-- Is this trend general or season spefic?

-- SELECT CASE WHEN EXTRACT(MONTH FROM date_key) IN (12,1,2) THEN 'Winter'
-- WHEN EXTRACT(MONTH FROM date_key) IN (3,4,5) THEN 'Spring'
-- WHEN EXTRACT(MONTH FROM date_key) IN (6,7,8) THEN 'Summer'
-- WHEN EXTRACT(MONTH FROM date_key) IN (9,10,11) THEN 'Fall' END AS seasons,
-- ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
-- FROM fact_trips
-- GROUP BY seasons
-- ORDER BY seasons DESC;


-- SELECT CASE WHEN EXTRACT(MONTH FROM f.date_key) IN (12,1,2) THEN 'Winter'
-- WHEN EXTRACT(MONTH FROM f.date_key) IN (3,4,5) THEN 'Spring'
-- WHEN EXTRACT(MONTH FROM f.date_key) IN (6,7,8) THEN 'Summer'
-- WHEN EXTRACT(MONTH FROM f.date_key) IN (9,10,11) THEN 'Fall' END AS seasons, r.member_casual,
-- ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
-- FROM fact_trips f
-- INNER JOIN dim_rider_type r
-- USING (rider_type_key)
-- GROUP BY seasons, r.member_casual
-- ORDER BY seasons DESC;


--- Bike Use By Season
-- SELECT CASE WHEN EXTRACT(MONTH FROM f.date_key) IN (12,1,2) THEN 'Winter'
-- WHEN EXTRACT(MONTH FROM f.date_key) IN (3,4,5) THEN 'Spring'
-- WHEN EXTRACT(MONTH FROM f.date_key) IN (6,7,8) THEN 'Summer'
-- WHEN EXTRACT(MONTH FROM f.date_key) IN (9,10,11) THEN 'Fall' END AS seasons, b.rideable_type, 
-- COUNT(b.bike_type_key) AS trip_count
-- FROM fact_trips f
-- INNER JOIN dim_bike_type b
-- USING (bike_type_key)
-- GROUP BY seasons, b.rideable_type
-- ORDER BY trip_count DESC;


-- SELECT CASE WHEN EXTRACT(MONTH FROM f.date_key) IN (12,1,2) THEN 'Winter'
-- WHEN EXTRACT(MONTH FROM f.date_key) IN (3,4,5) THEN 'Spring'
-- WHEN EXTRACT(MONTH FROM f.date_key) IN (6,7,8) THEN 'Summer'
-- WHEN EXTRACT(MONTH FROM f.date_key) IN (9,10,11) THEN 'Fall' END AS seasons, b.rideable_type,
-- ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY trip_duration_minutes))::NUMERIC, 1) as median_ride_duration
-- FROM fact_trips f
-- INNER JOIN dim_bike_type b
-- USING (bike_type_key) 
-- GROUP BY seasons, b.rideable_type
-- ORDER BY seasons DESC;


-- SELECT
--     f.ride_id,
--     start_station.station_name AS start_station_name,
--     end_station.station_name AS end_station_name
-- FROM fact_trips f

-- LEFT JOIN dim_station start_station
--     ON f.start_station_key = start_station.station_key

-- LEFT JOIN dim_station end_station
--     ON f.end_station_key = end_station.station_key;




