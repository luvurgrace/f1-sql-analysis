USE f1;

-- Q7: How has car reliability changed, and what were the main causes of retirement?
--
-- Uses the view `reliability_entries` (see sql/03_views.sql): one row per car entry
-- that started a race, with the finishing status grouped into
-- Finished / Technical / Accident / Other. Did-not-start entries and the
-- Indianapolis 500 are excluded in the view.
-- Entries are result rows, so a shared car in the 1950s counts as two entries.



-- Data checks

-- Check 1: all finishing statuses by frequency (used to build the categories)
SELECT s.status, COUNT(*) AS n, SUM(res.position IS NULL) AS unclassified
FROM results res
JOIN status s ON s.statusId = res.statusId
GROUP BY s.statusId, s.status
ORDER BY n DESC
LIMIT 60;
-- Result: "+N Laps" and "Lapped" are finishes, not retirements;
-- "Did not qualify", "Did not prequalify", "Withdrew" never started.

-- Check 2: what is left in "Other" after grouping?
SELECT status, COUNT(*) AS n
FROM reliability_entries
WHERE category = 'Other'
GROUP BY status
ORDER BY n DESC
LIMIT 20;
-- Result: Retired, Not classified, Disqualified and driver-related reasons
-- (illness, injury): unknown cause or not about the car.

-- Check 3: why is "Other" high in the 2020s?
SELECT year, status, COUNT(*) AS n
FROM reliability_entries
WHERE decade = 2020 AND category = 'Other'
GROUP BY year, status
ORDER BY year, n DESC;
-- Result: generic "Retired" jumps to 51 entries in 2025 and 44 in 2026
-- (1-9 per year before), so the 2025-2026 data records causes less precisely.



-- Q7 (part 1): Failure rate and failure categories by decade

-- Failure = any entry that did not end with a "Finished" status (finished or lapped).
-- Other = unknown cause (Retired, Not classified), disqualifications and
-- driver-related reasons; it must not be read as car reliability.
-- Note: the 2020s are incomplete (2020-2026).

SELECT
    decade,
    COUNT(*) AS entries,
    ROUND(100 * AVG(category <> 'Finished'), 1) AS failure_rate_pct,
    ROUND(100 * AVG(category = 'Technical'), 1) AS technical_pct,
    ROUND(100 * AVG(category = 'Accident'), 1) AS accident_pct,
    ROUND(100 * AVG(category = 'Other'), 1) AS other_pct
FROM reliability_entries
GROUP BY decade
ORDER BY decade;



-- Q7 (part 2): Most frequent specific causes of retirement by decade

-- "Engine" and "Power Unit" are merged: the engine was renamed Power Unit in the
-- hybrid era, so separate statuses would hide engine failures after 2014.
-- Share is measured against all entries of the decade.

WITH causes AS (
    SELECT
        decade,
        CASE WHEN status IN ('Engine', 'Power Unit') THEN 'Engine / Power Unit'
             ELSE status
        END AS cause,
        COUNT(*) AS n
    FROM reliability_entries
    WHERE category IN ('Technical', 'Accident')
    GROUP BY decade, cause
),
totals AS (
    SELECT decade, COUNT(*) AS entries
    FROM reliability_entries
    GROUP BY decade
),
ranked AS (
    SELECT
        c.decade,
        c.cause,
        c.n,
        ROUND(100 * c.n / t.entries, 1) AS pct_of_entries,
        ROW_NUMBER() OVER (PARTITION BY c.decade ORDER BY c.n DESC) AS rn
    FROM causes c
    JOIN totals t
        ON t.decade = c.decade
)
SELECT decade, rn AS place, cause, n, pct_of_entries
FROM ranked
WHERE rn <= 3
ORDER BY decade, rn;