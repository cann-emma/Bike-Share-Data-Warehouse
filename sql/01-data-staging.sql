-- DATA STAGING
DROP TABLE IF EXISTS stg_trips;

CREATE TABLE stg_trips AS
SELECT *
FROM raw_trips_all;

UPDATE stg_trips
SET member_casual = LOWER(TRIM(member_casual)),
    rideable_type = LOWER(TRIM(rideable_type));

UPDATE stg_trips
SET start_station_name = NULLIF(TRIM(start_station_name), ''),
    end_station_name = NULLIF(TRIM(end_station_name), ''),
    start_station_id = NULLIF(TRIM(start_station_id), ''),
    end_station_id = NULLIF(TRIM(end_station_id), '');

DELETE FROM stg_trips
WHERE started_at IS NULL
   OR ended_at IS NULL;

DELETE FROM stg_trips
WHERE ended_at <= started_at;

-- DELETE FROM stg_trips a
-- USING stg_trips b
-- WHERE a.ctid < b.ctid
--   AND a.ride_id = b.ride_id;

WITH dedupe AS (SELECT *, ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY started_at) AS rn FROM stg_trips)
DELETE FROM stg_trips
WHERE ride_id IN (SELECT ride_id FROM dedupe WHERE rn > 1);

UPDATE stg_trips
SET member_casual = 'unknown'
WHERE member_casual NOT IN ('member', 'casual');


ALTER TABLE stg_trips
ADD COLUMN trip_duration_minutes NUMERIC;


UPDATE stg_trips
SET trip_duration_minutes =
    EXTRACT(EPOCH FROM (ended_at - started_at)) / 60;


DELETE FROM stg_trips
WHERE trip_duration_minutes <= 0
   OR trip_duration_minutes > 1440;


ALTER TABLE stg_trips
ADD COLUMN start_hour INT,
ADD COLUMN start_day_of_week INT;


UPDATE stg_trips
SET start_hour = EXTRACT(HOUR FROM started_at),
    start_day_of_week = EXTRACT(DOW FROM started_at);


ALTER TABLE stg_trips
ADD COLUMN start_date DATE;


UPDATE stg_trips
SET start_date = started_at::DATE;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ride_id) AS unique_rides,
    COUNT(*) FILTER (WHERE trip_duration_minutes IS NULL) AS missing_duration,
    MIN(trip_duration_minutes),
    MAX(trip_duration_minutes),
    AVG(trip_duration_minutes)
FROM stg_trips;


SELECT COUNT(trip_duration_minutes)
FROM stg_trips
WHERE trip_duration_minutes BETWEEN 720 AND 1440;



SELECT FLOOR(trip_duration_minutes / 60) AS duration_hours, COUNT(*) AS trips
FROM stg_trips
GROUP BY FLOOR(trip_duration_minutes / 60)
ORDER BY duration_hours;


SELECT MAX(trip_duration_minutes) AS max_duration, 
PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY trip_duration_minutes) AS p95,
PERCENTILE_CONT(0.99) WITHIN GROUP(ORDER BY trip_duration_minutes) AS p99
FROM stg_trips;


WITH bands AS(
SELECT trip_duration_minutes, 
CASE WHEN trip_duration_minutes < 15 THEN '<15 min'
WHEN trip_duration_minutes < 30 THEN '15-30 min'
WHEN trip_duration_minutes < 60 THEN '30-60 min'
WHEN trip_duration_minutes < 120 THEN '1-2 hrs'
WHEN trip_duration_minutes < 360 THEN '2-6 hrs'
WHEN trip_duration_minutes < 720 THEN '6-12 hrs'
WHEN trip_duration_minutes < 1440 THEN '12-24 hrs'
ELSE '>24 hrs' END as duration_bands
FROM stg_trips)


SELECT duration_bands, COUNT(trip_duration_minutes) as count_duration
FROM bands
GROUP BY duration_bands
ORDER BY count_duration DESC;