USE f1;

-- Q5 (part 1)

-- Q5: Which drivers gain the most positions during a race?
--
-- Definition: positions gained = grid position - finishing position.
--
-- Methodology:
-- 1. Only classified finishers are counted (position IS NOT NULL), otherwise
--    retirements would be treated as "lost positions" and punish unreliable cars.
-- 2. Pit-lane starts (grid = 0), the Indianapolis 500 and races with ambiguous
--    grid data are excluded.
-- 3. Drivers need at least 50 classified finishes.

WITH ambiguous_poles AS (
    SELECT raceId
    FROM results
    WHERE grid = 1
    GROUP BY raceId
    HAVING COUNT(*) > 1
),
finishers AS (
    SELECT
        res.raceId,
        res.driverId,
        res.grid,
        res.positionOrder,
        res.grid - res.positionOrder AS gained
    FROM results res
    JOIN races r
        ON r.raceId = res.raceId
    WHERE res.position IS NOT NULL
      AND res.grid > 0
      AND r.name <> 'Indianapolis 500'
      AND res.raceId NOT IN (SELECT raceId FROM ambiguous_poles)
),
driver_stats AS (
    SELECT
        d.driverId,
        CONCAT(d.forename, ' ', d.surname) AS driver_name,
        COUNT(DISTINCT f.raceId) AS races,
        ROUND(AVG(f.grid), 2) AS avg_grid,
        ROUND(AVG(f.gained), 2) AS avg_gain
    FROM finishers f
    JOIN drivers d
        ON d.driverId = f.driverId
    GROUP BY d.driverId, driver_name
    HAVING COUNT(DISTINCT f.raceId) >= 50
)
SELECT *
FROM driver_stats
ORDER BY avg_gain DESC
LIMIT 10;


-- Q5 (part 2)

-- Q5B: Positions gained relative to the typical result from the same grid slot
--
-- Expected finish = average finishing position of classified finishers who started
-- from the same grid slot in the same decade (grid sizes and reliability changed
-- over time, so slots are only compared within a decade).
-- gain_vs_expected > 0 means the driver finishes higher than a typical car
-- starting from that slot. Slots with fewer than 20 finishers per decade are ignored.

WITH ambiguous_poles AS (
    SELECT raceId
    FROM results
    WHERE grid = 1
    GROUP BY raceId
    HAVING COUNT(*) > 1
),
finishers AS (
    SELECT
        res.raceId,
        res.driverId,
        FLOOR(r.year / 10) * 10 AS decade,
        res.grid,
        res.positionOrder
    FROM results res
    JOIN races r
        ON r.raceId = res.raceId
    WHERE res.position IS NOT NULL
      AND res.grid > 0
      AND r.name <> 'Indianapolis 500'
      AND res.raceId NOT IN (SELECT raceId FROM ambiguous_poles)
),
expected AS (
    SELECT
        decade,
        grid,
        AVG(positionOrder) AS exp_finish
    FROM finishers
    GROUP BY decade, grid
    HAVING COUNT(*) >= 20
),
driver_stats AS (
    SELECT
        d.driverId,
        CONCAT(d.forename, ' ', d.surname) AS driver_name,
        COUNT(DISTINCT f.raceId) AS races,
        ROUND(AVG(f.grid), 2) AS avg_grid,
        ROUND(AVG(f.grid - f.positionOrder), 2) AS avg_gain,
        ROUND(AVG(e.exp_finish - f.positionOrder), 2) AS gain_vs_expected
    FROM finishers f
    JOIN expected e
        ON e.decade = f.decade
       AND e.grid = f.grid
    JOIN drivers d
        ON d.driverId = f.driverId
    GROUP BY d.driverId, driver_name
    HAVING COUNT(DISTINCT f.raceId) >= 50
)
SELECT driver_name, races, avg_grid, avg_gain, gain_vs_expected
FROM driver_stats
ORDER BY gain_vs_expected DESC
LIMIT 10;