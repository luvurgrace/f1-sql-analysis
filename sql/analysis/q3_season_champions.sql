-- Q3: Season champions and title margins
--
-- Champion = 1st place in season standings after the final race.
-- Margin is shown both in raw points and as a percentage of
-- champion points because scoring systems changed over time.
--
-- Note:
-- 2026 is incomplete, so the listed driver is the current leader.
USE f1;

SELECT
    fs.year,

    CONCAT(
        d.forename,
        ' ',
        d.surname
    ) AS driver_name,

    fs.points,
    fs.wins,

    ROUND(
        fs.points - fs.runner_up_points,
        1
    ) AS margin,

    ROUND(
        100 * (fs.points - fs.runner_up_points)
        / fs.points,
        1
    ) AS margin_pct

FROM season_final_standings fs
JOIN drivers d
    ON d.driverId = fs.driverId

WHERE fs.position = 1

ORDER BY fs.year;



-- Q3A: Drivers with 3+ championship titles
-- 2026 excluded because the season is incomplete.
USE f1;

SELECT
    CONCAT(
        d.forename,
        ' ',
        d.surname
    ) AS driver_name,

    COUNT(*) AS titles

FROM season_final_standings fs

JOIN drivers d
    ON d.driverId = fs.driverId

WHERE fs.position = 1
  AND fs.year < 2026

GROUP BY
    d.driverId,
    driver_name

HAVING COUNT(*) >= 3

ORDER BY
    titles DESC,
    driver_name;



-- Q3B: Closest championships
-- Show every championship decided by 1 point or less.
USE f1;

SELECT
    fs.year,

    CONCAT(
        d.forename,
        ' ',
        d.surname
    ) AS champion,

    fs.points,

    ROUND(
        fs.points - fs.runner_up_points,
        1
    ) AS margin

FROM season_final_standings fs

JOIN drivers d
    ON d.driverId = fs.driverId

WHERE fs.position = 1
  AND fs.year < 2026
  AND fs.points - fs.runner_up_points <= 1

ORDER BY
    margin,
    fs.year;