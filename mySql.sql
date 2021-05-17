-- Cities with more than one airport
SELECT city, COUNT(airport_name)
FROM "dst_project"."airports"
GROUP BY city
HAVING COUNT(airport_name) > 1

-- Total Statuses
SELECT DISTINCT status
FROM "dst_project"."flights"

-- Planes in air
SELECT COUNT(*)
FROM "dst_project"."flights"
WHERE status = 'Departed'

-- Seats per airplane
SELECT COUNT(*) 
FROM "dst_project"."aircrafts"
INNER JOIN "dst_project"."seats" ON "dst_project"."aircrafts"."aircraft_code" = "dst_project"."seats"."aircraft_code"
WHERE "dst_project"."aircrafts"."model" = 'Boeing 777-300'

-- Total flights on period
SELECT COUNT(*)
FROM "dst_project"."flights"
WHERE status = 'Arrived' AND actual_arrival BETWEEN '2017-04-01' AND '2017-09-01'

-- Total cancelled flights
SELECT COUNT(*)
FROM "dst_project"."flights"
WHERE status = 'Cancelled'

-- Aircraft models amount
SELECT *
FROM "dst_project"."aircrafts"
WHERE model LIKE 'Boeing%'

-- Aircraft models amount
SELECT *
FROM "dst_project"."aircrafts"
WHERE model LIKE 'Sukhoi Superjet%'

-- Aircraft models amount
SELECT *
FROM "dst_project"."aircrafts"
WHERE model LIKE 'Airbus%'

-- Airports in Asia
SELECT COUNT(*)
FROM "dst_project"."airports"
WHERE timezone LIKE 'Asia%'

-- Airports in Europe
SELECT COUNT(*)
FROM "dst_project"."airports"
WHERE timezone LIKE 'Europe%'

-- Airports in Australia
SELECT COUNT(*)
FROM "dst_project"."airports"
WHERE timezone LIKE 'Australia%'

-- Most late
SELECT flight_id, actual_arrival, scheduled_arrival
FROM "dst_project"."flights"
ORDER BY scheduled_arrival - actual_arrival
LIMIT 1

-- Longest flight
SELECT scheduled_arrival - scheduled_departure
FROM "dst_project"."flights"
ORDER BY scheduled_arrival - scheduled_departure DESC
LIMIT 1

-- Longest flight airports
SELECT arrival_airport, departure_airport
FROM "dst_project"."flights"
ORDER BY scheduled_arrival - scheduled_departure DESC
LIMIT 1

-- Average flight time
SELECT AVG(actual_arrival - actual_departure)
FROM "dst_project"."flights"

-- Su9 seat types
SELECT fare_conditions, COUNT(fare_conditions)
FROM "dst_project"."aircrafts"
INNER JOIN "dst_project"."seats" ON "dst_project"."aircrafts"."aircraft_code" = "dst_project"."seats"."aircraft_code"
WHERE "dst_project"."aircrafts"."aircraft_code" = 'SU9'
GROUP BY fare_conditions

-- Min booking
SELECT MIN(total_amount) 
FROM "dst_project"."bookings"

-- Seat number of a passenger
SELECT *
FROM "dst_project"."tickets"
INNER JOIN "dst_project"."ticket_flights" on "dst_project"."tickets"."ticket_no" = "dst_project"."ticket_flights"."ticket_no"
INNER JOIN "dst_project"."flights" on "dst_project"."ticket_flights"."flight_id" = "dst_project"."flights"."flight_id"
INNER JOIN "dst_project"."boarding_passes" on "dst_project"."ticket_flights"."ticket_no" = "dst_project"."boarding_passes"."ticket_no"
INNER JOIN "dst_project"."aircrafts" on "dst_project"."aircrafts"."aircraft_code" = "dst_project"."flights"."aircraft_code"
INNER JOIN "dst_project"."seats" on "dst_project"."aircrafts"."aircraft_code" = "dst_project"."seats"."aircraft_code" AND "dst_project"."seats"."seat_no" = "dst_project"."boarding_passes"."seat_no"
WHERE passenger_id = '4313 788533'

-- Flights to Anapa
SELECT COUNT(*)
FROM "dst_project"."flights"
INNER JOIN "dst_project"."airports" on "dst_project"."flights"."arrival_airport" = "dst_project"."airports"."airport_code"
WHERE city = 'Anapa' AND status = 'Arrived' AND actual_arrival BETWEEN '2017-01-01' AND '2017-12-31'

-- Flights from Anapa
SELECT COUNT(*)
FROM "dst_project"."flights"
INNER JOIN "dst_project"."airports" on "dst_project"."flights"."departure_airport" = "dst_project"."airports"."airport_code"
WHERE city = 'Anapa' AND actual_departure BETWEEN '2017-01-01' AND '2017-03-01'

-- Anapa cancelled
SELECT COUNT(*)
FROM "dst_project"."flights"
INNER JOIN "dst_project"."airports" on "dst_project"."flights"."departure_airport" = "dst_project"."airports"."airport_code"
WHERE city = 'Anapa' AND status = 'Cancelled'

-- From Anapa not in Moscow
SELECT COUNT(*)
FROM "dst_project"."flights"
INNER JOIN "dst_project"."airports" AS departure_port on "dst_project"."flights"."departure_airport" = departure_port."airport_code"
INNER JOIN "dst_project"."airports" AS arrival_port on "dst_project"."flights"."arrival_airport" = arrival_port."airport_code" 
WHERE departure_port.city = 'Anapa' AND arrival_port.city <> 'Moscow'

-- Most seats from Anapa
SELECT COUNT(seat_no), "dst_project"."aircrafts"."model"
FROM "dst_project"."aircrafts"
INNER JOIN "dst_project"."seats" ON "dst_project"."aircrafts"."aircraft_code" = "dst_project"."seats"."aircraft_code"
WHERE "dst_project"."aircrafts"."model" IN (
    SELECT DISTINCT model
    FROM "dst_project"."flights"
    INNER JOIN "dst_project"."airports" AS departure_port ON "dst_project"."flights"."departure_airport" = departure_port."airport_code"
    INNER JOIN "dst_project"."airports" AS arrival_port ON "dst_project"."flights"."arrival_airport" = arrival_port."airport_code" 
    INNER JOIN "dst_project"."aircrafts" ON "dst_project"."aircrafts"."aircraft_code" = "dst_project"."flights"."aircraft_code"
    WHERE departure_port.city = 'Anapa' OR arrival_port.city = 'Anapa'
)
GROUP BY "dst_project"."aircrafts"."model"

-- Dataset
SELECT anapa_flights.aircraft_code, anapa_flights.flight_id, anapa_flights.flight_no, arrival_airport, flight_time, 
    total_tickets, total_seats_number, total_sum, (total_seats_number - total_tickets) as not_sold
FROM (
    SELECT COUNT(*) AS total_seats_number, dst_project.aircrafts.aircraft_code
    FROM dst_project.aircrafts
    INNER JOIN "dst_project"."seats" ON "dst_project"."aircrafts"."aircraft_code" = "dst_project"."seats"."aircraft_code"
    WHERE "dst_project"."aircrafts"."aircraft_code" IN 
    (
        SELECT aircraft_code
        FROM dst_project.flights
        WHERE departure_airport = 'AAQ'
    )
    GROUP BY "dst_project"."aircrafts"."aircraft_code"
) seats_per_model
RIGHT JOIN 
(
    SELECT *, (actual_arrival - actual_departure) as flight_time
    FROM dst_project.flights
    WHERE departure_airport = 'AAQ'
        AND (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
        AND status not in ('Cancelled')
) anapa_flights
ON (seats_per_model.aircraft_code = anapa_flights.aircraft_code)
INNER JOIN
(
    -- Tickets sold and profit gained
    SELECT COUNT(ticket_no) as total_tickets, SUM(amount) AS total_sum, dst_project.ticket_flights.flight_id
    FROM dst_project.ticket_flights
    INNER JOIN dst_project.flights ON dst_project.flights.flight_id = dst_project.ticket_flights.flight_id
    INNER JOIN dst_project.aircrafts ON dst_project.aircrafts.aircraft_code = dst_project.flights.aircraft_code
    WHERE dst_project.flights.flight_id in 
    (
        SELECT flight_id
        FROM dst_project.flights
        WHERE departure_airport = 'AAQ'
            AND (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
            AND status not in ('Cancelled')
    )
    GROUP BY dst_project.ticket_flights.flight_id
) tickets_data
ON anapa_flights.flight_id = tickets_data.flight_id

-- Fare Conditions on flights from Anapa
SELECT COUNT(fare_conditions) as amount, fare_conditions
FROM dst_project.ticket_flights
INNER JOIN dst_project.flights ON dst_project.flights.flight_id = dst_project.ticket_flights.flight_id
WHERE dst_project.flights.flight_id in 
(
    SELECT flight_id
    FROM dst_project.flights
    WHERE departure_airport = 'AAQ'
        AND (date_trunc('month', scheduled_departure) in ('2017-01-01','2017-02-01', '2017-12-01'))
        AND status not in ('Cancelled')
)
GROUP BY fare_conditions

