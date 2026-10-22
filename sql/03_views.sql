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



-- One row per car entry that actually started a race (Indianapolis 500 excluded),
-- with the finishing status grouped into a category.
-- Technical = mechanical or car failure; Accident = crashes and collisions;
-- Other = unknown cause, disqualifications and driver-related reasons.
CREATE OR REPLACE VIEW reliability_entries AS
SELECT
    r.year,
    FLOOR(r.year / 10) * 10 AS decade,
    res.raceId,
    s.status,
    CASE
        WHEN s.status = 'Finished'
          OR s.status LIKE '+%'
          OR s.status = 'Lapped' THEN 'Finished'
        WHEN s.status IN ('Accident', 'Collision', 'Spun off', 'Collision damage',
                          'Fatal accident')
            THEN 'Accident'
        WHEN s.status IN (
            'Engine', 'Gearbox', 'Suspension', 'Transmission', 'Electrical', 'Brakes',
            'Clutch', 'Fuel system', 'Turbo', 'Hydraulics', 'Overheating', 'Ignition',
            'Oil leak', 'Throttle', 'Halfshaft', 'Wheel', 'Oil pressure', 'Fuel pump',
            'Differential', 'Tyre', 'Handling', 'Fuel leak', 'Steering', 'Radiator',
            'Power Unit', 'Puncture', 'Wheel bearing', 'Injection', 'Fuel pressure',
            'Water leak', 'Alternator', 'Exhaust', 'Mechanical', 'Chassis', 'Magneto',
            'Driveshaft', 'Out of fuel',
            'Battery', 'Axle', 'Heat shield fire', 'Power loss', 'Distributor',
            'Oil pump', 'Electronics', 'Oil pipe', 'Broken wing', 'Rear wing',
            'Vibrations', 'Wheel nut', 'Water pressure', 'Water pump', 'Front wing',
            'ERS', 'Technical', 'Undertray', 'Fuel', 'Pneumatics', 'Fire',
            'Wheel rim', 'Spark plugs', 'Water pipe', 'Fuel pipe', 'Drivetrain',
            'Fuel rig', 'Track rod', 'Supercharger', 'Engine fire',
            'Tyre puncture', 'Oil line', 'Launch control', 'Driver Seat'
        ) THEN 'Technical'
        ELSE 'Other'
    END AS category
FROM results res
JOIN races r
    ON r.raceId = res.raceId
JOIN status s
    ON s.statusId = res.statusId
WHERE r.name <> 'Indianapolis 500'
  AND s.status NOT IN ('Did not qualify', 'Did not prequalify', 'Withdrew',
                       'Did not start', '107% Rule');




-- One row per driver and dry race of 2025-2026: tyre strategy and race outcome.
-- Wet races (rain recorded, or intermediate/wet tyres used by anyone) are excluded,
-- and so are entries with an unknown tyre compound.
-- Strategy = compound initials in stint order (e.g. M-H); stops = stints - 1,
-- which also counts tyre changes under red flags.
-- Only classified finishers who started from the grid are kept.
CREATE OR REPLACE VIEW dry_race_strategies AS
WITH wet_races AS (
    SELECT raceId
    FROM tire_stints
    WHERE compound IN ('INTERMEDIATE', 'WET')
    UNION
    SELECT raceId
    FROM weather
    WHERE rainfall = 1
),
strategies AS (
    SELECT
        raceId,
        driverId,
        COUNT(*) - 1 AS stops,
        GROUP_CONCAT(LEFT(compound, 1) ORDER BY stint SEPARATOR '-') AS strategy
    FROM tire_stints
    WHERE raceId NOT IN (SELECT raceId FROM wet_races)
    GROUP BY raceId, driverId
    HAVING SUM(compound IS NULL) = 0
)
SELECT
    s.raceId,
    s.driverId,
    res.constructorId,
    s.stops,
    s.strategy,
    res.grid,
    res.positionOrder,
    res.grid - res.positionOrder AS gained
FROM strategies s
JOIN results res
    ON res.raceId = s.raceId
   AND res.driverId = s.driverId
WHERE res.position IS NOT NULL
  AND res.grid > 0;