USE f1;

-- Q4 (part 1): Pole position win and podium rate by decade

-- Exclude races with multiple grid=1 entries
-- caused by historical shared-car records.

WITH ambiguous_poles AS (
    SELECT raceId
    FROM results
    WHERE grid = 1
    GROUP BY raceId
    HAVING COUNT(*) > 1
)

SELECT
    FLOOR(r.year / 10) * 10 AS decade,

    COUNT(*) AS poles,

    SUM(res.positionOrder = 1) AS wins_from_pole,

    ROUND(
        100.0 * SUM(res.positionOrder = 1) / COUNT(*),
        2
    ) AS win_rate_pct,

    SUM(res.positionOrder <= 3) AS podiums_from_pole,

    ROUND(
        100.0 * SUM(res.positionOrder <= 3) / COUNT(*),
        2
    ) AS podium_rate_pct

FROM results res

JOIN races r
    ON r.raceId = res.raceId

WHERE res.grid = 1
  AND res.raceId NOT IN (
      SELECT raceId
      FROM ambiguous_poles
  )

GROUP BY FLOOR(r.year / 10) * 10

ORDER BY decade;


-- Q4 (part 2): Win and podium rate by starting position group
WITH ambiguous_poles AS (
    SELECT
        raceId
    FROM results
    WHERE grid = 1
    GROUP BY raceId
    HAVING COUNT(*) > 1
),
grid_groups AS (
    SELECT
        FLOOR(r.year / 10) * 10 AS decade,
        CASE
            WHEN res.grid = 1 THEN 'Pole'
            WHEN res.grid BETWEEN 2 AND 3 THEN 'P2-P3'
            WHEN res.grid BETWEEN 4 AND 10 THEN 'P4-P10'
            ELSE 'P11+'
        END AS grid_group,
        res.positionOrder
    FROM results res
    JOIN races r
        ON r.raceId = res.raceId
    WHERE res.grid > 0
      AND res.raceId NOT IN (
            SELECT raceId
            FROM ambiguous_poles
      )
)
SELECT
    decade,
    grid_group,
    COUNT(*) AS starts,
    SUM(positionOrder = 1) AS wins,
    ROUND(
        100.0 * SUM(positionOrder = 1) / COUNT(*),
        2
    ) AS win_rate_pct,
    SUM(positionOrder <= 3) AS podiums,
    ROUND(
        100.0 * SUM(positionOrder <= 3) / COUNT(*),
        2
    ) AS podium_rate_pct
FROM grid_groups
GROUP BY
    decade,
    grid_group
ORDER BY
    decade,
    FIELD(
        grid_group,
        'Pole',
        'P2-P3',
        'P4-P10',
        'P11+'
    );