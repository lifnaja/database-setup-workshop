-- Aircrafts Data Table
DROP TABLE IF EXISTS aircrafts_data;
CREATE TABLE aircrafts_data (
    aircraft_code CHARACTER(3) NOT NULL,
    model         JSONB        NOT NULL,
    range         INTEGER      NOT NULL,
    CONSTRAINT aircrafts_range_check
        CHECK (range > 0)
);

-- Airports Data Table
DROP TABLE IF EXISTS airports_data;
CREATE TABLE airports_data (
    airport_code CHARACTER(3) NOT NULL,
    airport_name JSONB        NOT NULL,
    city         JSONB        NOT NULL,
    coordinates  POINT        NOT NULL,
    timezone     TEXT         NOT NULL
);

-- Boarding Passes Table
DROP TABLE IF EXISTS boarding_passes;
CREATE TABLE boarding_passes (
    ticket_no   CHARACTER(13)        NOT NULL,
    flight_id   INTEGER              NOT NULL,
    boarding_no INTEGER              NOT NULL,
    seat_no     VARCHAR(4)           NOT NULL
);

-- Bookings Table
DROP TABLE IF EXISTS bookings;
CREATE TABLE bookings (
    book_ref     CHARACTER(6)             NOT NULL,
    book_date    TIMESTAMPTZ              NOT NULL,
    total_amount NUMERIC(10, 2)           NOT NULL
);

-- Flights Table
DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
    flight_id           SERIAL PRIMARY KEY,
    flight_no           CHARACTER(6)             NOT NULL,
    scheduled_departure TIMESTAMPTZ              NOT NULL,
    scheduled_arrival   TIMESTAMPTZ              NOT NULL,
    departure_airport   CHARACTER(3)             NOT NULL,
    arrival_airport     CHARACTER(3)             NOT NULL,
    status              VARCHAR(20)             NOT NULL,
    aircraft_code       CHARACTER(3)             NOT NULL,
    actual_departure    TIMESTAMPTZ,
    actual_arrival      TIMESTAMPTZ
);

-- Seats Table
DROP TABLE IF EXISTS seats;
CREATE TABLE seats (
    aircraft_code   CHARACTER(3)       NOT NULL,
    seat_no         VARCHAR(4)         NOT NULL,
    fare_conditions VARCHAR(10)        NOT NULL
);

-- Ticket Flights Table
DROP TABLE IF EXISTS ticket_flights;
CREATE TABLE ticket_flights (
    ticket_no       CHARACTER(13)      NOT NULL,
    flight_id       INTEGER            NOT NULL,
    fare_conditions VARCHAR(10)        NOT NULL,
    amount          NUMERIC(10, 2)     NOT NULL
);

-- Tickets Table
DROP TABLE IF EXISTS tickets;
CREATE TABLE tickets (
    ticket_no    CHARACTER(13)         NOT NULL,
    book_ref     CHARACTER(6)          NOT NULL,
    passenger_id VARCHAR(20)           NOT NULL
);
