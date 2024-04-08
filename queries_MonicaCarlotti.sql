-- Queries for the Flight booking and travel planning database
-- Monica Carlotti

-- ITALY AIRPORTS: These queries modify and query an "Airports" table. The first alters the table to include a "Country" column. The second selects airport names and cities in Italy. The third adds a new airport entry for Milan, Italy. 
-- Alter Airports table by adding the "Country" column
ALTER TABLE Airports
ADD COLUMN country TEXT NOT NULL;

-- This query selects the airport names and cities from the Airports table where the country is 'Italy', it displays the names of all airports in Italy.
SELECT airport_name, city
FROM Airports
WHERE country = 'Italy';

-- add a new airport in Milan, Italy
INSERT INTO Airports (airport_code, airport_name, city, country)
VALUES ('MXP', 'Milan Malpensa Airport', 'Milan', 'Italy');

--AIRPORTS PER COUNTRY
-- Query to count number of airports in each country and select those that have 3 or less than 3, ordered from greatest to least and then alphabetically by country name.
SELECT 
    country,
    COUNT(airport_code) AS n_airports
FROM 
    Airports
GROUP BY 
    country
HAVING 
    n_airports <= 3
ORDER BY 
    n_airports DESC,
    country ASC;

-- BUSY AIRPORTS:
-- Query to find the 10 most trafficked airports with the most flights (departing and landing), ordered from greatest number of flights to least.
SELECT 
    Airports.airport_name,
    COUNT(DISTINCT Departures.flight_id) AS departing_flights,
    COUNT(DISTINCT Arrivals.flight_id) AS arriving_flights
FROM 
    Airports
LEFT JOIN 
    Flights AS Departures ON Airports.airport_code = Departures.departure_airport_code
LEFT JOIN 
    Flights AS Arrivals ON Airports.airport_code = Arrivals.arrival_airport_code
GROUP BY 
    Airports.airport_code, Airports.airport_name
ORDER BY 
    (departing_flights + arriving_flights) DESC,
    Airports.airport_name ASC
LIMIT 10;


-- NON-OPERATIVE AIRPORTS: these queries aim to identify and remove non-operative airports from the database. The first query creates a table for non-operative airports, the second populates it with airports that have no flights since 2000, and the third removes these airports from the original list. Finally, it shows how to drop the table if needed.
-- Create a separate table for NonOperativeAirports
CREATE TABLE NonOperativeAirports (
    airport_code TEXT PRIMARY KEY,
    airport_name TEXT NOT NULL
);

-- This query identifies and inserts non operative airports (no flights departing or landing since 2000) into the new table
INSERT INTO NonOperativeAirports (airport_code, airport_name)
SELECT DISTINCT Airports.airport_code, Airports.airport_name
FROM Airports
LEFT JOIN Flights ON Airports.airport_code = Flights.departure_airport_code
LEFT JOIN Flights ON Airports.airport_code = Flights.arrival_airport_code
WHERE (Flights.departure_time IS NULL OR Flights.departure_time < '2000-01-01')
AND (Flights.arrival_time IS NULL OR Flights.arrival_time < '2000-01-01');

-- Delete the non-operative airports from the original list of airports
DELETE FROM Airports
WHERE airport_code IN (SELECT airport_code FROM NonOperativeAirports);

-- Use Drop if I want to remove all the NonOperativeAirports (query above would not work after dropping the NonOperativeAirports table)
DROP TABLE NonOperativeAirports;

-- PERMISSIONS: The first query grants SELECT privilege on the Flights table to the user 'analyst', enabling them to retrieve data. The second query revokes INSERT, UPDATE, and DELETE permissions on all tables from users who haven't been explicitly granted those permissions.
-- query to Grant SELECT privilege on the Flights table to a user named 'analyst'
GRANT SELECT ON Flights TO analyst;

-- Query to revoke permissions from any user who hasn't been explicitly granted them.
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES FROM public;

-- TICKETS PRICES: The first query alters the Tickets table by adding a new column named 'price' to store the ticket prices. The second query calculates the average price per ticket for each fare type from the Tickets table, providing insights into pricing trends based on fare types.
-- Alter Tickets table to add price
ALTER TABLE Tickets
ADD COLUMN price DECIMAL(10, 2) NOT NULL;

-- Query to calculate the average price per ticket for each fare_type
SELECT fare_type, AVG(price) AS average_price
FROM Tickets
GROUP BY fare_type;

-- DISTANCE OF FLIGHTS: 
These queries determine the average distance traveled by flights in the database, with one focusing on all flights and the other specifically on flights departing from Beijing Airport ('PEK').
-- Query to find the average distance of flights
SELECT AVG(distance) AS average_distance
FROM Flights
JOIN Routes ON Flights.flight_id = Routes.flight_id;

-- Query to find the average distance of flights departing from Beijing Airport
SELECT AVG(distance) AS average_distance
FROM Flights
JOIN Routes ON Flights.flight_id = Routes.flight_id
WHERE Routes.departure_airport_code = 'PEK';

-- CAMBODIA: These queries aim to analyze flight data related to routes between Cambodia and London. The first query calculates the average price of flights departing from Cambodia and arriving in London. The second query determines the average flight length between airports in Cambodia and London. The third query identifies all airlines that operate flights to Cambodia. These analyses provide insights into flight pricing, travel distances, and airline options for travelers between Cambodia and London

-- Query to find the average price of flights departing from Cambodia airport and landing in London
SELECT AVG(price) AS average_price
FROM Tickets
JOIN Flights ON Tickets.flight_id = Flights.flight_id
JOIN Routes ON Flights.flight_id = Routes.flight_id
JOIN Airports AS DepartureAirport ON Routes.departure_airport_code = DepartureAirport.airport_code
JOIN Airports AS ArrivalAirport ON Routes.arrival_airport_code = ArrivalAirport.airport_code
WHERE DepartureAirport.country = 'Cambodia'
AND ArrivalAirport.city = 'London';

-- Query to find the average flight length between Airports in Cambodia and London.
SELECT AVG(Routes.distance) AS average_flight_length
FROM Flights
JOIN Routes ON Flights.flight_id = Routes.flight_id
JOIN Airports AS departure_airport ON Routes.departure_airport_code = departure_airport.airport_code
JOIN Airports AS arrival_airport ON Routes.arrival_airport_code = arrival_airport.airport_code
WHERE departure_airport.country = 'Cambodia' AND arrival_airport.city = 'London';
-- flight time would be different coming back from Cambodia, would require a similar query

-- Query to find all the Airlines that fly to Cambodia 
SELECT DISTINCT Airlines.airline_name
FROM Flights
JOIN Airports AS departure_airport ON Flights.departure_airport_code = departure_airport.airport_code
JOIN Airports AS arrival_airport ON Flights.arrival_airport_code = arrival_airport.airport_code
JOIN Airlines ON Flights.airline_id = Airlines.airline_id
WHERE departure_airport.city = 'London' AND arrival_airport.country = 'Cambodia';

-- PUNCTUALITY: These queries aim to analyze various aspects of airline performance and revenue. The first query calculates the on-time rate for each airline and ranks the top 10 airlines for punctuality. The second query retrieves the top 5 airlines sorted by the total number of tickets sold in 2010. The third query sorts airlines based on their revenue, considering both ticket sales and prices. Finally, the fourth query explores whether there is a correlation between punctuality and revenue for airlines.
-- Query to find the on-time rate for each airline and ranks the top 10 for punctuality
SELECT 
    Airlines.airline_name,
    (1.0 * COUNT(CASE WHEN Flights.arrival_time <= Flights.departure_time THEN 1 END) / COUNT(*)) AS on_time_rate
FROM 
    Flights
JOIN 
    Airlines ON Flights.airline_id = Airlines.airline_id
GROUP BY 
    Airlines.airline_name
ORDER BY 
    on_time_rate DESC
LIMIT 10;

-- Query to retrieve the top 5 airlines sorted by the total number of tickets sold in 2010
SELECT 
    Airlines.airline_name,
    COUNT(Tickets.ticket_id) AS total_tickets_sold
FROM 
    Airlines
JOIN 
    Flights ON Airlines.airline_id = Flights.airline_id
JOIN 
    Tickets ON Flights.flight_id = Tickets.flight_id
WHERE 
    Flights.departure_year = 2010
GROUP BY 
    Airlines.airline_name
ORDER BY 
    total_tickets_sold DESC
LIMIT 5;

-- Query to sort airlines based on revenue (tickets sold and price)
SELECT
    Airlines.airline_name,
    SUM(Tickets.price) AS total_revenue
FROM
    Airlines
JOIN
    Flights ON Airlines.airline_id = Flights.airline_id
JOIN
    Tickets ON Flights.flight_id = Tickets.flight_id
GROUP BY
    Airlines.airline_name
ORDER BY
    total_revenue DESC;

-- query to find whether punctuality is linked to revenue
SELECT 
    Airlines.airline_name AS airline_name,
    (1.0 * COUNT(CASE WHEN Flights.arrival_time <= Flights.departure_time THEN 1 END) / COUNT(*)) AS on_time_rate,
    SUM(Tickets.price) AS total_revenue
FROM 
    Airlines
JOIN 
    Flights ON Airlines.airline_id = Flights.airline_id
JOIN 
    Tickets ON Flights.flight_id = Tickets.flight_id
GROUP BY 
    Airlines.airline_name
ORDER BY 
    total_revenue DESC;

-- UPDATE QUERY: 
-- The San Francisco airport is changing name because of the confusion between Oakland and Auckland, query to update the name
UPDATE Airports
SET airport_name = 'San Francisco Bay Oakland International Airport'
WHERE airport_code = 'SFO';

-- DELETE QUERY:
-- Query to delete all costumers from the list who have not flown in 10 years
DELETE FROM Customers
WHERE customer_id NOT IN (
    SELECT DISTINCT Tickets.customer_id
    FROM Tickets
    JOIN Flights ON Tickets.flight_id = Flights.flight_id
    WHERE Flights.departure_time >= DATE('now', '-10 years')
);






