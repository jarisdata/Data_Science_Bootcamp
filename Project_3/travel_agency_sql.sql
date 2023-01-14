DROP DATABASE travel_agency;
CREATE DATABASE travel_agency;

USE travel_agency;

DROP TABLE cities;
CREATE TABLE IF NOT EXISTS cities(
city_id INT AUTO_INCREMENT, 
city VARCHAR(30),
lat FLOAT,
lon FLOAT,
PRIMARY KEY (city_id)
);

DROP TABLE airports;
CREATE TABLE IF NOT EXISTS airports(
city_id INT NOT NULL, 
icao VARCHAR(30),
airport VARCHAR(100),
city VARCHAR(30),
PRIMARY KEY (icao),
FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

DROP TABLE weather;
CREATE TABLE IF NOT EXISTS weather(
weather_id INT AUTO_INCREMENT,
city_id INT NOT NULL, 
city VARCHAR(30),
description VARCHAR(100),
temperature FLOAT,
felt_temperature FLOAT,
wind_speed FLOAT,
rain_probability FLOAT,
timestamp DATETIME,
PRIMARY KEY (weather_id),
FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

DROP TABLE arrivals;
CREATE TABLE IF NOT EXISTS arrivals(
flight_id INT AUTO_INCREMENT, 
icao VARCHAR(4),
scheduledTimeLocal VARCHAR(40),
departure_icao VARCHAR(4),
PRIMARY KEY (flight_id),
FOREIGN KEY (icao) REFERENCES airports(icao)
);
