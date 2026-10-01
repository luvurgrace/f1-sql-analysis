USE f1;

-- Races
ALTER TABLE races
    ADD CONSTRAINT fk_races_circuit
        FOREIGN KEY (circuitId) REFERENCES circuits (circuitId);

ALTER TABLE races
    ADD CONSTRAINT fk_races_season
        FOREIGN KEY (year) REFERENCES seasons (year);


-- Race results
ALTER TABLE results
    ADD CONSTRAINT fk_results_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE results
    ADD CONSTRAINT fk_results_driver
        FOREIGN KEY (driverId) REFERENCES drivers (driverId);

ALTER TABLE results
    ADD CONSTRAINT fk_results_constructor
        FOREIGN KEY (constructorId) REFERENCES constructors (constructorId);

ALTER TABLE results
    ADD CONSTRAINT fk_results_status
        FOREIGN KEY (statusId) REFERENCES status (statusId);


-- Sprint race results
ALTER TABLE sprint_results
    ADD CONSTRAINT fk_sprint_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE sprint_results
    ADD CONSTRAINT fk_sprint_driver
        FOREIGN KEY (driverId) REFERENCES drivers (driverId);

ALTER TABLE sprint_results
    ADD CONSTRAINT fk_sprint_constructor
        FOREIGN KEY (constructorId) REFERENCES constructors (constructorId);

ALTER TABLE sprint_results
    ADD CONSTRAINT fk_sprint_status
        FOREIGN KEY (statusId) REFERENCES status (statusId);


-- Qualifying sessions
ALTER TABLE qualifying
    ADD CONSTRAINT fk_quali_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE qualifying
    ADD CONSTRAINT fk_quali_driver
        FOREIGN KEY (driverId) REFERENCES drivers (driverId);

ALTER TABLE qualifying
    ADD CONSTRAINT fk_quali_constructor
        FOREIGN KEY (constructorId) REFERENCES constructors (constructorId);


-- Driver standings
ALTER TABLE driver_standings
    ADD CONSTRAINT fk_dstand_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE driver_standings
    ADD CONSTRAINT fk_dstand_driver
        FOREIGN KEY (driverId) REFERENCES drivers (driverId);


-- Constructor standings
ALTER TABLE constructor_standings
    ADD CONSTRAINT fk_cstand_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE constructor_standings
    ADD CONSTRAINT fk_cstand_constr
        FOREIGN KEY (constructorId) REFERENCES constructors (constructorId);


-- Constructor results
ALTER TABLE constructor_results
    ADD CONSTRAINT fk_cres_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE constructor_results
    ADD CONSTRAINT fk_cres_constr
        FOREIGN KEY (constructorId) REFERENCES constructors (constructorId);


-- Additional tables available only for 2025–2026
ALTER TABLE practice_results
    ADD CONSTRAINT fk_prac_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE practice_results
    ADD CONSTRAINT fk_prac_driver
        FOREIGN KEY (driverId) REFERENCES drivers (driverId);

ALTER TABLE tire_stints
    ADD CONSTRAINT fk_tire_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE tire_stints
    ADD CONSTRAINT fk_tire_driver
        FOREIGN KEY (driverId) REFERENCES drivers (driverId);

ALTER TABLE weather
    ADD CONSTRAINT fk_weather_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);


-- Largest tables last (constraint validation may take longer)
ALTER TABLE pit_stops
    ADD CONSTRAINT fk_pit_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE pit_stops
    ADD CONSTRAINT fk_pit_driver
        FOREIGN KEY (driverId) REFERENCES drivers (driverId);

ALTER TABLE lap_times
    ADD CONSTRAINT fk_lap_race
        FOREIGN KEY (raceId) REFERENCES races (raceId);

ALTER TABLE lap_times
    ADD CONSTRAINT fk_lap_driver
        FOREIGN KEY (driverId) REFERENCES drivers (driverId);