---DATA MODELING
--- Fact and Dim Tables Following Star Schema

DROP TABLE IF EXISTS dim_rider_type;

CREATE TABLE dim_rider_type (
    rider_type_key SERIAL PRIMARY KEY,
    member_casual VARCHAR(20) UNIQUE
);


INSERT INTO dim_rider_type (member_casual)
SELECT DISTINCT member_casual
FROM stg_trips
WHERE member_casual IS NOT NULL;


---

DROP TABLE IF EXISTS dim_bike_type;

CREATE TABLE dim_bike_type (
    bike_type_key SERIAL PRIMARY KEY,
    rideable_type VARCHAR(50) UNIQUE
);

INSERT INTO dim_bike_type (rideable_type)
SELECT DISTINCT rideable_type
FROM stg_trips
WHERE rideable_type IS NOT NULL;


---

DROP TABLE IF EXISTS dim_station;

CREATE TABLE dim_station (
    station_key SERIAL PRIMARY KEY,
    station_id VARCHAR(50) UNIQUE,
    station_name TEXT,
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION
);

INSERT INTO dim_station (
    station_id,
    station_name,
    lat,
    lng
)

SELECT DISTINCT ON (station_id)
    station_id,
    station_name,
    lat,
    lng
FROM (

    SELECT
        start_station_id AS station_id,
        start_station_name AS station_name,
        start_lat AS lat,
        start_lng AS lng
    FROM stg_trips

    UNION ALL

    SELECT
        end_station_id,
        end_station_name,
        end_lat,
        end_lng
    FROM stg_trips

) s

WHERE station_id IS NOT NULL;


--- Sanity Check. Any Duplications?

SELECT station_id, COUNT(*)
FROM dim_station
GROUP BY station_id
HAVING COUNT(*) > 1;

-- ---

DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    date_key DATE PRIMARY KEY,
    year INT,
    quarter INT,
    month INT,
    day INT,
    day_of_week INT,
    weekend_flag BOOLEAN
);


INSERT INTO dim_date
SELECT DISTINCT
    start_date AS date_key,
    EXTRACT(YEAR FROM start_date),
    EXTRACT(QUARTER FROM start_date),
    EXTRACT(MONTH FROM start_date),
    EXTRACT(DAY FROM start_date),
    EXTRACT(DOW FROM start_date),
    CASE
        WHEN EXTRACT(DOW FROM start_date) IN (0,6)
        THEN TRUE
        ELSE FALSE
    END
FROM stg_trips;


---

CREATE INDEX idx_station_id
ON dim_station(station_id);

CREATE INDEX idx_start_station_id
ON stg_trips(start_station_id);

CREATE INDEX idx_end_station_id
ON stg_trips(end_station_id);

---

DROP TABLE IF EXISTS fact_trips;

CREATE TABLE fact_trips (
    trip_key SERIAL PRIMARY KEY,

    ride_id TEXT UNIQUE,

    started_at TIMESTAMP,
    ended_at TIMESTAMP,

    trip_duration_minutes NUMERIC,

    start_station_key INT,
    end_station_key INT,

    rider_type_key INT,
    bike_type_key INT,

    date_key DATE,

    FOREIGN KEY (start_station_key)
        REFERENCES dim_station(station_key),

    FOREIGN KEY (end_station_key)
        REFERENCES dim_station(station_key),

    FOREIGN KEY (rider_type_key)
        REFERENCES dim_rider_type(rider_type_key),

    FOREIGN KEY (bike_type_key)
        REFERENCES dim_bike_type(bike_type_key),

    FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key)
);



INSERT INTO fact_trips (
    ride_id,
    started_at,
    ended_at,
    trip_duration_minutes,
    start_station_key,
    end_station_key,
    rider_type_key,
    bike_type_key,
    date_key
)
SELECT
    s.ride_id,
    s.started_at,
    s.ended_at,
    s.trip_duration_minutes,

    ds_start.station_key,
    ds_end.station_key,

    dr.rider_type_key,
    db.bike_type_key,

    s.start_date

FROM stg_trips s

LEFT JOIN dim_station ds_start
    ON s.start_station_id = ds_start.station_id

LEFT JOIN dim_station ds_end
    ON s.end_station_id = ds_end.station_id

LEFT JOIN dim_rider_type dr
    ON s.member_casual = dr.member_casual

LEFT JOIN dim_bike_type db
    ON s.rideable_type = db.rideable_type;





