USE f1;

-- Final driver standings of each season (after the last race),
-- including runner-up points for title margin analysis

CREATE OR REPLACE VIEW season_final_standings AS

WITH last_round AS (
    SELECT
        year,
        MAX(round) AS last_round
    FROM races
    GROUP BY year
),

final_race AS (
    SELECT
        r.year,
        r.raceId
    FROM races r
    JOIN last_round lr
        ON lr.year = r.year
       AND lr.last_round = r.round
)

SELECT
    fr.year,
    ds.driverId,
    ds.points,
    ds.wins,
    ds.position,

    LEAD(ds.points) OVER (
        PARTITION BY fr.year
        ORDER BY ds.position
    ) AS runner_up_points

FROM driver_standings ds
JOIN final_race fr
    ON fr.raceId = ds.raceId;