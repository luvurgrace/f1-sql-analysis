USE f1;

-- Reference tables
ALTER TABLE circuits ADD PRIMARY KEY (circuitId);
ALTER TABLE constructors ADD PRIMARY KEY (constructorId);
ALTER TABLE drivers ADD PRIMARY KEY (driverId);
ALTER TABLE status ADD PRIMARY KEY (statusId);
ALTER TABLE seasons ADD PRIMARY KEY (year);
ALTER TABLE races ADD PRIMARY KEY (raceId);

-- Tables with their own unique identifier
ALTER TABLE results ADD PRIMARY KEY (resultId);
ALTER TABLE sprint_results ADD PRIMARY KEY (resultId);
ALTER TABLE qualifying ADD PRIMARY KEY (qualifyId);
ALTER TABLE driver_standings ADD PRIMARY KEY (driverStandingsId);
ALTER TABLE constructor_standings ADD PRIMARY KEY (constructorStandingsId);
ALTER TABLE constructor_results ADD PRIMARY KEY (constructorResultsId);

-- Tables without a dedicated ID: use composite primary keys
ALTER TABLE pit_stops ADD PRIMARY KEY (raceId, driverId, stop);
ALTER TABLE lap_times ADD PRIMARY KEY (raceId, driverId, lap);
ALTER TABLE tire_stints ADD PRIMARY KEY (raceId, driverId, stint);
ALTER TABLE weather ADD PRIMARY KEY (raceId);

-- The session column must be a fixed-length VARCHAR to be included in a primary key
ALTER TABLE practice_results MODIFY session VARCHAR(3) NOT NULL;
ALTER TABLE practice_results ADD PRIMARY KEY (raceId, driverId, session);