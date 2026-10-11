USE f1;

-- Q6: How has time spent in the pit lane changed since 2011?
--
-- Important: `milliseconds` is the whole time in the pit lane (entry to exit),
-- not the stationary time of the tire change.
-- Pit stop data exists only from 2011 (see check 1).


-- Data checks

-- Check 1: which seasons have pit stop data?
SELECT MIN(r.year) AS first_year, MAX(r.year) AS last_year, COUNT(*) AS stops
FROM pit_stops p
JOIN races r ON r.raceId = p.raceId;
-- Result: 2011-2026, 12,627 stops

-- Check 2: extremes in the data
SELECT MIN(milliseconds) AS min_ms, MAX(milliseconds) AS max_ms,
       SUM(milliseconds > 60000) AS stops_over_60s
FROM pit_stops;
-- Result: min 0 ms (invalid), max ~51 min, 517 stops over a minute

-- Check 3: stops under 10 s are impossible and treated as data errors
SELECT COUNT(*) AS suspicious
FROM pit_stops
WHERE milliseconds < 10000;
-- Result: 29

-- Check 4: where are the invalid records?
SELECT r.year, COUNT(*) AS bad_stops
FROM pit_stops p
JOIN races r ON r.raceId = p.raceId
WHERE p.milliseconds < 10000
GROUP BY r.year;
-- Result: 28 of 29 are in 2026 (newly added season), 1 in 2025


-- Q6 (part 1): Pit lane time by season, median vs mean

-- Median is used because red-flag and repair stops are extreme outliers.
-- Stops under 10 s are excluded as data errors.
-- Note: 2026 is incomplete (11 rounds) and 2020 was a shortened season.

WITH stops AS (
    SELECT r.year, p.milliseconds
    FROM pit_stops p
    JOIN races r
        ON r.raceId = p.raceId
    WHERE p.milliseconds >= 10000
),
ranked AS (
    SELECT
        year,
        milliseconds,
        ROW_NUMBER() OVER (PARTITION BY year ORDER BY milliseconds) AS rn,
        COUNT(*) OVER (PARTITION BY year) AS cnt,
        AVG(milliseconds) OVER (PARTITION BY year) AS mean_ms,
        AVG(milliseconds > 60000) OVER (PARTITION BY year) AS over_60s
    FROM stops
)
SELECT
    year,
    MAX(cnt) AS stops,
    ROUND(AVG(milliseconds) / 1000, 2) AS median_s,
    ROUND(MAX(mean_ms) / 1000, 2) AS mean_s,
    ROUND(100 * MAX(over_60s), 1) AS share_over_60s_pct
FROM ranked
WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
GROUP BY year
ORDER BY year;


-- Q6 (part 2): Median pit lane time per circuit, 2011-2014 vs 2022-2025

-- Same circuits only, so changes in the calendar do not distort the comparison.
-- 2026 is incomplete and skipped. A circuit needs at least 30 stops in each period.

WITH stops AS (
    SELECT
        c.name AS circuit,
        CASE
            WHEN r.year BETWEEN 2011 AND 2014 THEN 'early'
            WHEN r.year BETWEEN 2022 AND 2025 THEN 'recent'
        END AS period,
        p.milliseconds
    FROM pit_stops p
    JOIN races r
        ON r.raceId = p.raceId
    JOIN circuits c
        ON c.circuitId = r.circuitId
    WHERE p.milliseconds >= 10000
),
ranked AS (
    SELECT
        circuit,
        period,
        milliseconds,
        ROW_NUMBER() OVER (PARTITION BY circuit, period ORDER BY milliseconds) AS rn,
        COUNT(*) OVER (PARTITION BY circuit, period) AS cnt
    FROM stops
    WHERE period IS NOT NULL
),
medians AS (
    SELECT
        circuit,
        period,
        MAX(cnt) AS stops,
        AVG(milliseconds) / 1000 AS median_s
    FROM ranked
    WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
    GROUP BY circuit, period
)
SELECT
    e.circuit,
    e.stops AS early_stops,
    l.stops AS recent_stops,
    ROUND(e.median_s, 2) AS early_s,
    ROUND(l.median_s, 2) AS recent_s,
    ROUND(l.median_s - e.median_s, 2) AS change_s
FROM medians e
JOIN medians l
    ON l.circuit = e.circuit
   AND l.period = 'recent'
WHERE e.period = 'early'
  AND e.stops >= 30
  AND l.stops >= 30
ORDER BY change_s;


-- Diagnostics for the two outlier circuits of part 2

-- Diagnostic 1: median per season at Albert Park and Silverstone
-- Result: both changes are steps in a single season, not gradual trends
-- (Albert Park: ~22-24 s until 2019, ~18 s from 2022; Silverstone: ~25 s until
-- 2013, ~29 s from 2014).
WITH s AS (
    SELECT c.name AS circuit, r.year, p.milliseconds
    FROM pit_stops p
    JOIN races r ON r.raceId = p.raceId
    JOIN circuits c ON c.circuitId = r.circuitId
    WHERE p.milliseconds >= 10000
      AND c.name IN ('Albert Park Grand Prix Circuit', 'Silverstone Circuit')
),
ranked AS (
    SELECT
        circuit, year, milliseconds,
        ROW_NUMBER() OVER (PARTITION BY circuit, year ORDER BY milliseconds) AS rn,
        COUNT(*) OVER (PARTITION BY circuit, year) AS cnt
    FROM s
)
SELECT circuit, year, MAX(cnt) AS stops,
       ROUND(AVG(milliseconds) / 1000, 2) AS median_s
FROM ranked
WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
GROUP BY circuit, year
ORDER BY circuit, year;

-- Diagnostic 2: Albert Park 2023 shows a median of ~880 s. Why?
SELECT COUNT(*) AS stops, SUM(p.milliseconds > 60000) AS over_60s
FROM pit_stops p
JOIN races r ON r.raceId = p.raceId
JOIN circuits c ON c.circuitId = r.circuitId
WHERE c.name = 'Albert Park Grand Prix Circuit' AND r.year = 2023;
-- Result: 49 of 65 stops are longer than a minute (red flags), so even the
-- median is distorted in that single race.