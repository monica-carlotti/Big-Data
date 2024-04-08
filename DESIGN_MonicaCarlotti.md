# Design Document

A Flight Booking and Travel Planning Database

By Monica Carlotti

Video overview: <[https://youtu.be/UJDSnx7R26s]

## Scope
Purpose: The purpose of the database is to facilitate flight booking and travel planning by providing comprehensive information about flights, airlines, airports, ticket prices, schedules, routes, and costumers.

In Scope:

* Flights: Information about flights including flight numbers, departure and arrival airports, departure and arrival times.
* Airlines: Details about airlines operating flights such as airline names and contact information.
* Airports: Data regarding airports including airport codes, names, locations.
* Aircraft: Information about aircraft such as the type of aircraft, seating capacity.
* Ticket Prices/Fares: Information about ticket prices for different flights.including fare ID, fare type (e.g., economy, business), fare amount.
* Flight Schedules: Details about flight schedules including departure and arrival times.
* Routes: Information about flight routes including the departure airport, arrival airport, distance, and possibly other details like the average flight duration.
* Customers: Details about customers such as their unique identifiers, names, contact information, and possibly other details like frequent flyer status.

Out of Scope:
Non-flight-related travel information such as hotels, car rentals, tourist attractions, airports's facilities, public transport information to reach the airport.  

## Functional Requirements

This database will support:

* Flight Search and Booking:
Users should be able to search for and book flights.
Users should be able to view flight details and manage their bookings.

* Airlines and Airports Information:
Users should be able to access information about airlines and airports.

* Ticket Management:
Users should be able to manage their booked tickets.


Out of Scope:
Hotel accommodations, car rentals, and other non-flight-related travel services are beyond the scope of this database.

## Representation

Entities are captured in SQLite tables with the following schema.

### Entities

The database includes the following entities: Flights, Airlines, Airports, Aircrafts, Tickets, Schedule, Routes, Customers

#### Flights
The `Flights` table includes:
* `flight_id`, which specifies the unique ID for the flight as an INTEGER. This column thus has the PRIMARY KEY constraint applied.
* `airline_id`, which specifies the unique ID for the airline as an INTEGER. This column is a foreign key shared with the airlines table.
* `flight_number`, which specifies the flight's number as TEXT.
* `departure_airport_code`, which specifies the departure airport's code as TEXT.
* `arrival_airport_code`, which specifies the arrival airport's code as TEXT.
* `departure_time`, which specifies the departure time of the flight as DATETIME.
* `arrival_time`, which specifies the arrival time of the flight as DATETIME.

They are marked as NOT NULL to ensure that every flight has departure and arrival times specified, and to ensure that every flight has departure and arrival airports specified.
flight_number`is also NOT NULL, as flight numbers are considered mandatory for safety and regulatory compliance purposes.

#### Airlines
The `Airlines` table includes:

* `airline_id`, which specifies the unique ID for the airline as an INTEGER. This column has the PRIMARY KEY constraint applied.
* `airline_name`, which specifies the airline's name as TEXT.

All columns in the airlines table are required and hence should have the NOT NULL constraint applied. 

#### Airports
The `Airports` table includes:

* `airport_code`, which specifies the airport's code as TEXT. This column has the PRIMARY KEY constraint applied.
* `airport_name`, which specifies the airport's name as TEXT.
* `location`, which specifies the airport's location as TEXT.

Airport_name and location are marked as NOT NULL to ensure that every airport has a name and location specified. 

#### Aircraft
The `Aircraft` table includes:

* `aircraft_id`, which specifies the unique ID for the aircraft as an INTEGER. This column has the PRIMARY KEY constraint applied.
* `aircraft_type`, which specifies the model of the aircraft as TEXT.
* `seating_capacity`, which specifies the seating capacity of the aircraft as INTEGER.

All columns are marked as NOT NULL, ensuring that essential information about each aircraft, including its model and seating capacity, is provided. Seating capacity serves as an important safety and operational parameter for airline operations.

#### Ticket
The `Ticket` table includes:
* `fare_id`, which specifies the unique ID for the fare as an INTEGER. This column has the PRIMARY KEY constraint applied.
* `fare_type`, which specifies the type of fare (e.g., economy, business) as TEXT. Marked as NOT NULL to ensure that all tickets have a fare type specified.
* `flight_id` which specifies the unique ID for the flight as an INTEGER.  Each ticket is associated with a specific flight, it is a FOREIGN KEY that references the flight_id in the Flights table.
* `customer_id`, which specifies the unique ID for the customer as an INTEGER. It is a FOREIGN KEY that references the customer_id in the Customers table.


#### Schedule
The `Schedule` table includes:

* `schedule_id`, which specifies the unique ID for the schedule as an INTEGER. This column has the PRIMARY KEY constraint applied.
* `flight_number`, which specifies the flight number associated with the schedule as TEXT.
* `departure_time`, which specifies the departure time of the flight as DATETIME.
* `arrival_time`, which specifies the arrival time of the flight as DATETIME.
* `flight_id` which specifies the unique ID for the flight as an INTEGER.  It is a FOREIGN KEY that references the flight_id in the Flights table.

All columns are marked as NOT NULL to ensure that every flight schedule has a flight number, departure and arrival times specified.

#### Routes
The `Routes` table includes:

* `route_id`, which specifies the unique ID for the route as an INTEGER. This column thus has the PRIMARY KEY constraint applied.
* `departure_airport_code`, which specifies the departure airport's code as TEXT. It is a FOREIGN KEY that references the airport_code in the Airport table.
* `arrival_airport_code`, which specifies the arrival airport's code as TEXT. It is a FOREIGN KEY that references the airport_code in the Airport table.
* `distance`, which specifies the distance of the route as REAL.
* `flight_id`, which specifies the unique ID for the flight as an INTEGER. Each route is associated with one or more flights. It is a FOREIGN KEY that references the flight_id in the Flights table.

All columns are marked as NOT NULL to ensure that every route has departure and arrival airports specified, as well as a distance specified.

#### Customers
The `Customers` table includes:

* `customer_id`, which specifies the unique ID for the customer as an INTEGER. This column thus has the PRIMARY KEY constraint applied.
* `customer_name`, which specifies the customer's name as TEXT.
* `contact_information`, which specifies the customer's contact information as TEXT.

All columns are marked as NOT NULL, every costumer in the database must have a name and contact information specified for costumer interaction, support and identification.

These constraints were chosen to ensure data integrity, maintain consistency, and facilitate efficient querying of the database.

### Relationships

The below entity relationship diagram describes the relationships among the entities in the database.

![Entity Relationship Diagram](https://github.com/monica-carlotti/Big-Data/blob/main/ER.png)


- **flights ||--o{ airlines :**  
  This notation represents a one-to-many relationship between "flights" and "airlines". Each flight is associated with one airline, but an airline can operate multiple flights.

- **aircraft }|--|{ flights : "assigned to":**  
  This notation indicates a one-to-one relationship between aircraft and flights. Each flight is assigned to one aircraft, and each aircraft is assigned to one flight at a time.

- **Flights ||--|| Schedules : "scheduled for":**  
  Each flight is associated with one schedule, and each schedule is linked to one specific flight. While flights may have multiple schedules due to recurring operations, each flight typically has a unique identifier (such as flight_id), leading to a one-to-one relationship between flights and schedules.

- **airlines ||--o{ flights : 'operates':**  
  This represents a one-to-many relationship, where one airline can operate multiple flights, but each flight is operated by only one airline.

- **flights ||--o{ tickets : 'booked in':**  
  Describes a one-to-many relationship where flights can have multiple tickets booked for them, and each ticket is booked for exactly one flight.

- **tickets ||--o{ customers : 'purchased by':**  
  This relationship means that one ticket is purchased by one customer. However, a customer can purchase multiple tickets for themselves or others.

- **Flights }|--|{ Routes : "flown on":**  
  Represents a one-to-one relationship between flights and routes, indicating that each flight is associated with one route. While typically a flight is associated with a single specific route, exceptions may occur, especially for flights with layovers or connecting flights, in which case it would be a one-to-many relationship.

- **airports ||--o{ routes : "departure airport"**  
  **airports ||--o{ routes : "arrival airport":**  
  Airports typically have multiple flights departing from and arriving at them, serving as both origin and destination points for various routes.

## Optimizations

### VIEW

These views provide valuable insights and summaries of the flight data stored in the database.

* TopDestinations: This view helps identify the most popular destinations by showing the number of flights departing from each airport. It is useful for understanding travel demand and identifying key routes that airlines may want to invest in.

* BusiestAirports: By listing airports based on the total number of departures and arrivals, this view provides a comprehensive picture of airport activity. It helps identify the busiest hubs and allocate resources accordingly.

* TotalTicketsSold: This view provides a clear overview of ticket sales for each flight. It helps in assessing flight popularity and identifying trends in ticket purchases.

* DelayedFlights: Identifying flights that are delayed is crucial for monitoring operational performance and ensuring customer satisfaction. 

* DelayedFlightsByAirline: This view enhances the DelayedFlights view by providing additional details, including the corresponding airline's name.

### INDEX
Indexes improve the speed of data retrieval operations on a table. 
* The index on "flight_number" in the "Flights" table enables retrieval of flight information based on the flight number, which is commonly used for searching and identifying flights.
* The index on "airport_code" in the "Airports" table facilitates a search of airport information based on the airport code, which is often used for identifying airports in flight schedules and routes.
* The index on "customer_name" in the "Customers" table speeds up queries related to customer information based on their names.
* The index on "departure_time" in the "Schedules" table enhances the retrieval of flight schedules based on departure times, which is essential for querying flights departing at specific times or within a certain time range.
* The index on "arrival_time" in the "Flights" table accelerates the retrieval of flight information based on arrival times, enabling efficient querying of flights arriving at specific times or within a given time frame.
These last two indexes would help speed up queries that involve filtering flights based on their departure or arrival times, in order to calculate flight duration.

### Data integrity
To optimize data integrity and ensure efficient data management, several techniques are employed within the database schema. For instance, a unique constraint is enforced on the "airport_code" column in the Airports table, guaranteeing that each airport code is unique. Similarly, a unique constraint is placed on the "airline_name" column in the Airlines table, ensuring that each airline name is distinct. Additionally, the Flights table incorporates a default value for the "departure_year" column, automatically setting it to the current year upon insertion if no value is explicitly provided. In the Customers table, a check constraint can be implemented to validate the format of the "contact_information," such as ensuring it conforms to a valid email address format. Moreover, the "fare_type" column in the Tickets table is restricted to accept only predefined values like 'economy', 'premium_economy', 'business', and 'first_class', enhancing data consistency. Lastly, a check constraint is applied to the "distance" column in the Routes table, ensuring that the distance value recorded for each route is always greater than zero, thus maintaining data accuracy. These optimizations collectively contribute to a robust and reliable database system.

In addition, triggers are added to maintain data consistency and reliability within the database.The "validate_customer_name_trigger" ensures that customer names in the "Customers" table contain both a first name and a last name.
The "same_airport_trigger" prevents routes with identical departure and arrival airports from being inserted into the "Routes" table.
The "flight_duration_trigger" ensures that flight durations in the "Schedules" table are greater than zero.


## Limitations

While the database schema presented herein offers a robust foundation for managing flight booking and travel planning, several limitations warrant consideration to ensure its adaptability, security, and scalability in real-world applications.

Complexity in Representing Relationships: The schema captures essential relationships between entities such as flights, routes, and tickets. However, in real-world scenarios, these relationships can become more intricate, especially in scenarios involving many-to-many relationships or hierarchical structures. For example, a flight may have multiple routes or stops, and a ticket may be associated with multiple passengers. 
Data Privacy and Security: The database schema does not include provisions for data privacy and security measures, such as encryption, access control, or data anonymization. Without adequate safeguards the database may be vulnerable to data breaches,
Scalability: As the user base expands and the database workload increases, scalability challenges could impact database performance, response times, and overall system reliability. Scaling the database to handle growing demand while maintaining optimal performance would be challenging.

* There are certain limitations and scenarios this database might not represent well:
Real-Time Updates: The database might struggle to handle real-time updates, especially in high-traffic scenarios where multiple users are simultaneously accessing and modifying flight information. 
Internationalization: The schema does not account for internationalization requirements, such as supporting multiple languages, currencies, or date formats. In global travel scenarios, users from different regions may expect localized experiences tailored to their linguistic and cultural preferences. 
Data Privacy and Security: The database schema does not explicitly address data privacy requirements, such as compliance with regulations like GDPR (General Data Protection Regulation).
External Systems: The database may face challenges when integrating with external systems, such as airline reservation systems, third-party APIs due to variations in data formats, protocols etc. 

Addressing these limitations may involve iterative refinement of the database schema, adoption of best practices in data management and security, and alignment with industry standards and regulations.