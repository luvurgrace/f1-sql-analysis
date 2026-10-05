USE f1;

-- Q1: Most dominant Formula 1 drivers by decade
--
-- Definition of dominance:
-- Win rate = race wins / race starts within a decade.
--
-- Methodology:
-- 1. Group drivers by decade.
-- 2. Calculate starts, wins, and win rate.
-- 3. Exclude drivers with fewer than 20 starts in a decade.
-- 4. Rank drivers within each decade by win rate.
-- 5. Display the top 3 drivers per decade.
--
-- Notes:
-- - Starts and wins are counted as distinct races rather than rows.
-- - This avoids double-counting historical shared-car entries.
-- - The 2020s are incomplete (2020-2026).
-- - The 2026 season currently contains races through the
--   Hungarian Grand Prix only.

WITH driver_stats AS (
    SELECT
        FLOOR(r.year / 10) * 10 AS decade,
        d.driverId,
        CONCAT(d.forename, ' ', d.surname) AS driver_name,

        COUNT(DISTINCT res.raceId) AS starts,

        COUNT(
            DISTINCT CASE
                WHEN res.positionOrder = 1
                THEN res.raceId
            END
        ) AS wins,

        ROUND(
            100.0 *
            COUNT(
                DISTINCT CASE
                    WHEN res.positionOrder = 1
                    THEN res.raceId
                END
            )
            / COUNT(DISTINCT res.raceId),
            2
        ) AS win_rate_pct

    FROM results res
    JOIN races r
        ON r.raceId = res.raceId
    JOIN drivers d
        ON d.driverId = res.driverId

    GROUP BY
        decade,
        d.driverId,
        driver_name

    HAVING COUNT(DISTINCT res.raceId) >= 20
),

ranked AS (
    SELECT
        decade,
        driver_name,
        starts,
        wins,
        win_rate_pct,

        ROW_NUMBER() OVER (
            PARTITION BY decade
            ORDER BY win_rate_pct DESC, wins DESC
        ) AS rank_in_decade

    FROM driver_stats
)

SELECT
    decade,
    rank_in_decade,
    driver_name,
    starts,
    wins,
    win_rate_pct
FROM ranked
WHERE rank_in_decade <= 3
ORDER BY
    decade,
    rank_in_decade;