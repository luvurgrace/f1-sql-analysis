# Formula 1 SQL Analytics Project

SQL analysis of Formula 1 history (1950-2026) in MySQL 8: window functions, CTEs, views, and Python charts.

## Did you know?

- Since 1950, only 25 Grand Prix have been won from 11th place or lower on the grid. The biggest comeback in the dataset belongs to John Watson, who won the 1983 US Grand Prix West from 22nd.
- Max Verstappen took both such wins of the 2020s (Belgium 2022 from 14th, São Paulo 2024 from 17th), and half of all of them since 2010.

## Dataset

[Formula 1 World Championship (1950-2026)](https://github.com/Arths17/f1-dataset) by Atharv Ranjan, an extension of the Ergast database updated via the Jolpica API (CC0 license). 17 related tables: races, results, drivers, constructors, qualifying, pit stops, standings, and 2025-2026 extras (tire stints, weather, practice).

The CSV files are not included in this repository. Download them from the link above and place them in `data/`.

![ER diagram](docs/f1_erd.png)

## Research Questions

| # | Question | Status |
|---|---|---|
| 1 | Most dominant drivers by decade | Done |
| 2 | Constructor dominance by decade | Done |
| 3 | Season champions and title margins | Done |
| 4 | Impact of pole position | Done |
| 5 | Position gainers | In progress |
| 6 | Pit stop evolution | Planned |
| 7 | Reliability trends | Planned |
| 8 | Tire strategy effectiveness (2025-2026) | Planned |

## Key Findings

### Q1: Most dominant drivers by decade
![Q1](charts/q1_dominant_drivers.png)

- Juan Fangio in the 1950s has the highest decade win rate (47.1%), ahead of Michael Schumacher in the 2000s (45.9%) and Max Verstappen in the 2020s (44.4%, decade incomplete).
- Lewis Hamilton is the only driver in the top three of three different decades.
- Win rate favors short, strong careers, so a minimum of 20 starts is applied.

### Q2: Constructor dominance by decade
![Q2](charts/q2_constructor_dominance.png)

- Ferrari in the 2000s (48.9%), Red Bull in the 2020s (47.9%, incomplete) and Mercedes in the 2010s (47.0%) are the most dominant constructor-decades.
- The 1970s were the most competitive era: Team Lotus (26.3%) and Ferrari (26.2%) are effectively tied.

### Q3: Season champions and title margins
![Q3 margins](charts/q3_championship_margins.png)
![Q3 titles](charts/q3_titles_by_driver.png)

- Eleven drivers have won three or more titles; Hamilton and Schumacher lead with seven each.
- Nine championships were decided by one point or less; the closest was Lauda over Prost in 1984 (half a point).
- Normalized by the champion's points, margins show no steady trend but cycles.

### Q4: Impact of pole position
![Q4](charts/q4_grid_groups.png)

- The pole-sitter's win rate fell to 28% in the 1980s, then rose to about 50% in the 2000s-2010s and 56% in the 2020s (incomplete).
- Starters from P11 or lower never won more than 0.33% of races in any decade.
- These figures show association, not cause: dominant cars tend to take both pole and the win.

Full findings and caveats for each question are in [`docs/notes.md`](docs/notes.md).

### Q5: Position gainers
![Q5](charts/q5_gain_vs_expected.png)

- A naive ranking by positions gained (grid minus finish) is dominated by midfield and backmarker drivers of the 1970s-1990s, such as Marc Surer (+8.3 per race): they start far back and survive the attrition of their era, while front-runners have little room to gain.
- Comparing each driver with the typical finish from the same grid slot in the same decade gives a very different top ten. Max Verstappen leads at +1.69 positions per race (211 classified finishes), ahead of Niki Lauda and Bruce McLaren (+1.26).
- The top ten consists almost entirely of champions and front-running drivers, so this metric partly reflects car quality, not only overtaking skill.

### Q6: Pit lane time since 2011
![Q6](charts/q6_pit_lane_by_circuit.png)

- Pit stop data starts in 2011. The median time in the pit lane has not shortened since then (about 23-24 s, entry to exit).
- Means are distorted by red-flag stops (in 2021, a 220 s mean against a 24 s median), so medians are used.
- Comparing the same circuits shows changes of less than 1.1 s at most tracks; the two biggest shifts (Albert Park, Silverstone) happened in a single season, which points to track changes rather than team performance.

## Data Notes

- The 2026 season is incomplete (through the Hungarian Grand Prix, round 11); it is excluded or marked in year-by-year comparisons.
- Early seasons contain shared cars (a driver taking over a teammate's car mid-race), so starts and wins are counted as distinct races rather than result rows.
- Some teams appear under several constructor names (e.g. Lotus-Climax, Lotus-Ford); they are not merged because identical names can refer to unrelated teams.
- In 1997 Michael Schumacher is absent from the final standings (excluded after the Jerez collision), which inflates Villeneuve's margin.
- The Indianapolis 500 counted as a World Championship round from 1950 to 1960 and is part of the dataset. Its 33-car grid skews "back of the grid" statistics in the 1950s; for example, all three 1950s wins from 11th or lower came at Indianapolis.
- Position-gain metrics (Q5) count classified finishers only and exclude the Indianapolis 500 (a championship round in 1950-1960 with a 33-car grid).
- 28 of 29 invalid pit stop records (under 10 s) come from the newly added 2026 season

## How to Reproduce

1. Download the dataset and put the CSV files into `data/`.
2. Install dependencies: `pip install -r requirements.txt`
3. Copy `.env.example` to `.env` and fill in your MySQL credentials.
4. Create the database: run `sql/00_create_database.sql` in MySQL (8.0+ required for window functions and CTEs).
5. Load the data: `python scripts/load_data.py`
6. Add keys and views: run `sql/01_primary_keys.sql`, `sql/02_foreign_keys.sql`, `sql/03_views.sql` in that order.
7. Run the queries from `sql/analysis/`. Charts are built in `notebooks/analysis.ipynb`.

## Project Structure

```
f1-analysis/
├── data/          # CSV files (not tracked)
├── docs/          # ER diagram, notes
├── sql/           # database setup and analysis queries
│   └── analysis/  # one file per research question
├── scripts/       # data loading
├── notebooks/     # charts
├── results/       # query outputs (CSV)
└── charts/        # images used in this README
```

## Tech Stack

MySQL 8, SQL (CTEs, window functions, views), Python, pandas, SQLAlchemy, matplotlib, Jupyter.