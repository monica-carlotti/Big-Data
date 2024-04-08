-- Schema for the Flight booking and travel planning database
-- Monica Carlotti

-- Create table for flights
CREATE TABLE "Flights" (
    "flight_id" INTEGER PRIMARY KEY,
    "airline_id" INTEGER NOT NULL,
    "flight_number" TEXT NOT NULL,
    "departure_airport_code" TEXT NOT NULL,
    "arrival_airport_code" TEXT NOT NULL,
    "departure_time" DATETIME NOT NULL,
    "arrival_time" DATETIME NOT NULL,
    "departure_year" INTEGER NOT NULL DEFAULT strftime('%Y', 'now'),
    FOREIGN KEY("airline_id") REFERENCES "Airlines"("airline_id")
);

-- Create table for airlines
CREATE TABLE "Airlines" (
    "airline_id" INTEGER PRIMARY KEY,
    "airline_name" TEXT NOT NULL,
    CONSTRAINT unique_airline_name UNIQUE (airline_name)
);
-- Create table for airports
CREATE TABLE "Airports" (
    "airport_code" TEXT PRIMARY KEY,
    "airport_name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    CONSTRAINT unique_airport_code UNIQUE (airport_code)
);

-- Create table for aircraft
CREATE TABLE "Aircraft" (
    "aircraft_id" INTEGER PRIMARY KEY,
    "aircraft_type" TEXT NOT NULL,
    "seating_capacity" INTEGER NOT NULL
);

-- Create table for tickets
CREATE TABLE "Tickets" (
    "ticket_id" INTEGER PRIMARY KEY,
    "fare_id" INTEGER NOT NULL,
    "price" REAL NOT NULL,
    "fare_type" TEXT NOT NULL CHECK (fare_type IN ('economy', 'premium_economy', 'business', 'first_class')),
    "flight_id" INTEGER NOT NULL,
    "customer_id" INTEGER NOT NULL,
    FOREIGN KEY("fare_id") REFERENCES "Fares"("fare_id"),
    FOREIGN KEY("flight_id") REFERENCES "Flights"("flight_id"),
    FOREIGN KEY("customer_id") REFERENCES "Customers"("customer_id")
);

-- Create table for flight schedules
CREATE TABLE "Schedules" (
    "schedule_id" INTEGER PRIMARY KEY,
    "flight_number" TEXT NOT NULL,
    "departure_time" DATETIME NOT NULL,
    "arrival_time" DATETIME NOT NULL,
    "flight_id" INTEGER NOT NULL,
    FOREIGN KEY("flight_id") REFERENCES "Flights"("flight_id")
);


-- Create table for flight routes
CREATE TABLE "Routes" (
    "route_id" INTEGER PRIMARY KEY,
    "departure_airport_code" TEXT NOT NULL,
    "arrival_airport_code" TEXT NOT NULL,
    "distance" REAL NOT NULL CHECK(distance>0),
    "flight_id" INTEGER NOT NULL,
    FOREIGN KEY("departure_airport_code") REFERENCES "Airports"("airport_code"),
    FOREIGN KEY("arrival_airport_code") REFERENCES "Airports"("airport_code"),
    FOREIGN KEY("flight_id") REFERENCES "Flights"("flight_id")
);

-- Create table for customers
CREATE TABLE "Customers" (
    "customer_id" INTEGER PRIMARY KEY,
    "customer_name" TEXT NOT NULL,
    "contact_information" TEXT NOT NULL CHECK (contact_information LIKE '%@%.%')
);

-- TRIGGER
-- Create a trigger to validate customer names
CREATE TRIGGER validate_customer_name_trigger
BEFORE INSERT ON Customers
FOR EACH ROW
BEGIN
    IF INSTR(NEW.customer_name, ' ') = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer name must contain both first name and last name';
    END IF;
END;

--  Create a trigger to prevent flights with same departure and arrival airport
CREATE TRIGGER same_airport_trigger
BEFORE INSERT ON Routes
FOR EACH ROW
BEGIN
    IF NEW.departure_airport_code = NEW.arrival_airport_code THEN
        -- Raise an error
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Departure and arrival airports cannot be the same';
    END IF;
END;

-- Create a trigger to ensure flight duration is greater than 0
CREATE TRIGGER flight_duration_trigger
BEFORE INSERT ON Schedules
FOR EACH ROW
BEGIN
    IF NEW.arrival_time <= NEW.departure_time THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Flight duration must be greater than 0';
    END IF;
END;

-- VIEWS

-- TopDestinations view: This view lists the most popular destinations based on the number of flights departing from each airport.
CREATE VIEW TopDestinations AS
SELECT
    departure_airport_code,
    COUNT(*) AS num_departures
FROM
    Flights
GROUP BY
    departure_airport_code
ORDER BY
    num_departures DESC;

-- BusiestAirports view: lists the busiest airports based on the total number of departures and arrivals.
CREATE VIEW BusiestAirports AS
SELECT
    departure_airport_code,
    COUNT(*) AS n_departures,
    (SELECT COUNT(*)
     FROM Flights
     WHERE arrival_airport_code = Airports.airport_code) AS n_arrivals
FROM
    Flights
GROUP BY
    departure_airport_code
ORDER BY
    (n_departures + n_arrivals) DESC;


-- TotalTicketsSold view: Provides the total number of tickets sold for each flight.
CREATE VIEW TotalTicketsSold AS
SELECT
    Flights.flight_id,
    Flights.flight_number,
    COUNT(Tickets.ticket_id) AS total_tickets_sold
FROM
    Flights
LEFT JOIN
    Tickets ON Flights.flight_id = Tickets.flight_id
GROUP BY
    Flights.flight_id, Flights.flight_number;



-- DelayedFlights view: Identifies flights that are delayed
CREATE VIEW DelayedFlights AS
SELECT
    *
FROM
    Flights
WHERE
    arrival_time > departure_time + INTERVAL '30 minutes';


-- DelayedFlightsByAirline view: provide details of each delayed flight along with the corresponding airline's name. 
CREATE VIEW DelayedFlightsByAirline AS
SELECT
    Flights.*,
    Airlines.airline_name
FROM
    Flights
JOIN
    Airlines ON Flights.airline_id = Airlines.airline_id;

-- INDEX

-- Create index for retrieval of flight information (index for flight number on the Flights table)
CREATE INDEX "index_flight_number" ON "Flights" ("flight_number");

-- Create index for retrieval of airport information (index on the airport_code column of the Airports table)
CREATE INDEX "index_airport_code" ON "Airports" ("airport_code");

-- Index for faster retrieval of customer information (index on the customer_name column of the Customers table)
CREATE INDEX "index_customer_name" ON "Customers" ("customer_name");

-- Index for  retrieval of departure times (index on the departure_time column of the Schedules table)
CREATE INDEX "index_departure_time" ON "Schedules" ("departure_time");

-- Index for retrieval of arrival time (index on the arrival_time column of the Schedules table)
CREATE INDEX "index_arrival_time" ON "Flights" ("arrival_time");


