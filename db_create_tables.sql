-- Clear Database: 
USE tsubd_airport_1;

DROP TABLE IF EXISTS Crews_Crew_members;
DROP TABLE IF EXISTS Crews;
DROP TABLE IF EXISTS Crew_members;
DROP TABLE IF EXISTS Airports_Flights;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Flights;
DROP TABLE IF EXISTS Aircrafts;
DROP TABLE IF EXISTS Airlines;
DROP TABLE IF EXISTS Airports;

-- Airports Table

CREATE TABLE Airports (
    airport_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    international_code VARCHAR(5)
);

-- Airlines Table

CREATE TABLE Airlines (
    airline_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);

-- Aircrafts Table

CREATE TABLE Aircrafts (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    number VARCHAR(50),
    brand VARCHAR(50),
    model VARCHAR(50),
    capacity INT
);

-- Flights Table

CREATE TABLE Flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_id INT,
    aircraft_id INT,
    flight_number VARCHAR(50),
    type VARCHAR(50),
    rangee INT,
    departure_time TIME,
    arrival_time TIME,
    travel_time TIME,
    frequency VARCHAR(100),
    FOREIGN KEY (airline_id) REFERENCES Airlines(airline_id),
    FOREIGN KEY (aircraft_id) REFERENCES Aircrafts(aircraft_id)
);

-- Events Table

CREATE TABLE Events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_id INT,
    flight_id INT,
    type VARCHAR(50),
    date DATE,
    del_adv_time TIME,
    status VARCHAR(50),
    FOREIGN KEY (airport_id) REFERENCES Airports(airport_id),
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

-- Airports_Flights Table

CREATE TABLE Airports_Flights (
    airport_id INT,
    flight_id INT,
    PRIMARY KEY (airport_id, flight_id),
    FOREIGN KEY (airport_id) REFERENCES Airports(airport_id),
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

-- Crew_members Table

CREATE TABLE Crew_members (
    crew_member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    position VARCHAR(100),
    number_of_flights INT
);

-- Crews Table

CREATE TABLE Crews (
    crew_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT,
    name VARCHAR(255),
    time_of_flight TIME,
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

-- Crews_Crew_members Table

CREATE TABLE Crews_Crew_members (
    crew_id INT,
    crew_member_id INT,
    PRIMARY KEY (crew_id, crew_member_id),
    FOREIGN KEY (crew_id) REFERENCES Crews(crew_id),
    FOREIGN KEY (crew_member_id) REFERENCES Crew_members(crew_member_id)
);
