-- Q8 (part 1): Race outcome by number of pit stops, dry races 2025-2026
-- Groups with 3 or more stops are merged because they are rare.
-- Note: results are indicative (28 dry races); strategy is not random, because
-- front-runners and backmarkers choose different strategies.

SELECT
    CASE WHEN stops >= 3 THEN '3+' ELSE CAST(stops AS CHAR) END AS stops_group,
    COUNT(*) AS entries,
    ROUND(AVG(grid), 1) AS avg_grid,
    ROUND(AVG(positionOrder), 1) AS avg_finish,
    ROUND(AVG(gained), 2) AS avg_gain,
    ROUND(100 * AVG(positionOrder <= 3), 1) AS podium_pct
FROM dry_race_strategies
GROUP BY stops_group
ORDER BY stops_group;



-- Q8 (part 2): Most common tyre strategies (at least 15 entries)
-- S = Soft, M = Medium, H = Hard, in stint order.

SELECT
    strategy,
    COUNT(*) AS entries,
    ROUND(AVG(grid), 1) AS avg_grid,
    ROUND(AVG(positionOrder), 1) AS avg_finish,
    ROUND(AVG(gained), 2) AS avg_gain,
    ROUND(100 * AVG(positionOrder <= 3), 1) AS podium_pct
FROM dry_race_strategies
GROUP BY strategy
HAVING COUNT(*) >= 15
ORDER BY entries DESC;



-- Q8 (part 3): Teammate comparison within the same race
-- For every pair of teammates with a different number of stops, did the driver with
-- FEWER stops finish ahead? 50% would mean no advantage either way.
-- Both drivers share the same car, so car quality is controlled for; the strategy
-- is still not random (e.g. a driver who pits for damage or under a safety car).

SELECT
    CONCAT(fewer.stops, ' vs ', more.stops, ' stops') AS pair_type,
    COUNT(*) AS pairs,
    SUM(fewer.positionOrder < more.positionOrder) AS fewer_stops_ahead,
    ROUND(100 * AVG(fewer.positionOrder < more.positionOrder), 1) AS fewer_ahead_pct
FROM dry_race_strategies fewer
JOIN dry_race_strategies more
    ON more.raceId = fewer.raceId
   AND more.constructorId = fewer.constructorId
   AND more.driverId <> fewer.driverId
   AND fewer.stops < more.stops
GROUP BY pair_type
ORDER BY pairs DESC;