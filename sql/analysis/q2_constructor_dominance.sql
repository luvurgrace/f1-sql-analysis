USE f1;

-- Q2: Most dominant Formula 1 constructors by decade
--
-- Definition of dominance:
-- Win rate = race wins / races entered within a decade.
--
-- Methodology:
-- 1. Group constructors by decade.
-- 2. Count race wins.
-- 3. Count distinct races entered.
-- 4. Exclude constructors with fewer than 30 races.
-- 5. Rank constructors within each decade by win rate.
--
-- Notes:
-- - Wins and races are counted as distinct races rather than rows.
-- - This avoids double-counting historical shared-car entries.
-- - The 2020s are incomplete (2020-2026).
-- - Wins and races are counted as distinct races rather than rows.
-- - This avoids double-counting historical shared-car entries.
-- - Win rate is calculated per race, not per car start,
-- - because constructors typically enter multiple cars per race.

WITH constructor_stats AS (
    SELECT
        FLOOR(r.year / 10) * 10 AS decade,
        c.constructorId,
        c.name AS constructor_name,

        COUNT(DISTINCT res.raceId) AS races,

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
    JOIN constructors c
        ON c.constructorId = res.constructorId

    GROUP BY
        decade,
        c.constructorId,
        constructor_name

    HAVING COUNT(DISTINCT res.raceId) >= 30
),

ranked AS (
    SELECT
        decade,
        constructor_name,
        races,
        wins,
        win_rate_pct,

        ROW_NUMBER() OVER (
            PARTITION BY decade
            ORDER BY win_rate_pct DESC, wins DESC
        ) AS rank_in_decade

    FROM constructor_stats
)

SELECT
    decade,
    rank_in_decade,
    constructor_name,
    races,
    wins,
    win_rate_pct
FROM ranked
WHERE rank_in_decade <= 3
ORDER BY
    decade,
    rank_in_decade;