-- BEGIN CLIENT

-- DROP TABLE XMOISE01.client;
-- DROP VIEW XMOISE01.client_view;
-- DROP PROCEDURE XMOISE01.create_client;

CREATE TABLE client
(
    passport_number     VARCHAR(16)  NOT NULL PRIMARY KEY,
    first_name          VARCHAR(32)  NOT NULL,
    last_name           VARCHAR(32)  NOT NULL,
    birth_date          DATE         NOT NULL,
    permanent_residence VARCHAR(128) NOT NULL,
    temporary_residence VARCHAR(128) NOT NULL,
    phone_number        VARCHAR(16)  NOT NULL,
    email               VARCHAR(64)  NOT NULL,
    registration_date   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT phone_number_check CHECK (REGEXP_LIKE(phone_number, '^\+?[0-9]+$')),
    CONSTRAINT email_check CHECK (REGEXP_LIKE(email, '^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'))
);

CREATE OR REPLACE VIEW client_view AS
SELECT passport_number,
       first_name,
       last_name,
       (first_name || ' ' || last_name) AS full_name,
       birth_date,
       permanent_residence,
       temporary_residence,
       phone_number,
       email,
       registration_date
FROM client;

CREATE OR REPLACE PROCEDURE create_client(
    insert_passport_number IN VARCHAR,
    insert_first_name IN VARCHAR,
    insert_last_name IN VARCHAR,
    insert_birth_date IN DATE,
    insert_permanent_residence IN VARCHAR,
    insert_temporary_residence IN VARCHAR,
    insert_phone_number IN VARCHAR,
    insert_email IN VARCHAR
)
AS
BEGIN
    INSERT INTO client
    VALUES (insert_passport_number,
            insert_first_name,
            insert_last_name,
            insert_birth_date,
            insert_permanent_residence,
            insert_temporary_residence,
            insert_phone_number,
            insert_email,
            CURRENT_TIMESTAMP);
END;

-- INSERTS FOR TESTING
BEGIN
    create_client(
            '123456789',
            'John',
            'Doe',
            TO_DATE('01.01.2000', 'DD.MM.YYYY'),
            'Permanent residence',
            'Temporary residence',
            '+420123456789',
            'john-doe@gmail.com'
        );
    create_client(
            '987654321',
            'Jane',
            'Doe',
            TO_DATE('01.01.2001', 'DD.MM.YYYY'),
            'Permanent residence',
            'Temporary residence',
            '+420987654321',
            'jane-doe@gmail.com'
        );
END;

-- END CLIENT

-- SUITE TYPES BEGIN
-- Suite types are declared in suite_type table.
-- It also has a specification of a suite type (suite_type_spec) used to represent generalization relationship between suite types.
-- suite_type_spec contains information about suite variant (ROOM or APARTMENT) and number of beds and rooms.
-- Suite variant is used to determine if a suite type is a room or an apartment.
-- Number of beds and rooms is used to determine if a suite type is a room or an apartment

-- DROP TABLE XMOISE01.suite_type_spec;
-- DROP TABLE XMOISE01.suite_type;
-- DROP VIEW XMOISE01.suite_type_view;
-- DROP PROCEDURE XMOISE01.insert_suite_type;

CREATE TABLE suite_type
(
    id       INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    name     VARCHAR(255)                     NOT NULL CHECK ( name <> '' ),
    capacity INT                              NOT NULL CHECK ( capacity > 0 ),
    price    FLOAT                            NOT NULL CHECK ( price > 0 ),
    CONSTRAINT suite_type_pk PRIMARY KEY (id),
    CONSTRAINT suite_type_unique UNIQUE (name)
);

CREATE TABLE suite_type_spec
(
    suite_type_id INT          NOT NULL,
    suite_variant VARCHAR(255) NOT NULL CHECK ( suite_variant in ('ROOM', 'APARTMENT') ),
    beds_count    INT          NOT NULL CHECK ( beds_count > 0 ),
    rooms_count   INT          NOT NULL CHECK ( rooms_count > 0 ),
    CONSTRAINT suite_type_spec_pk PRIMARY KEY (suite_type_id),
    CONSTRAINT suite_type_spec_fk FOREIGN KEY (suite_type_id) REFERENCES suite_type (id),
    CONSTRAINT suite_type_spec_unique UNIQUE (suite_variant, beds_count, rooms_count),
    CONSTRAINT suite_type_spec_check CHECK ( suite_variant = 'ROOM' AND beds_count >= 1 AND rooms_count = 1 OR
                                             suite_variant = 'APARTMENT' AND beds_count >= 1 AND rooms_count > 1 )
);

CREATE OR REPLACE VIEW suite_type_view AS
SELECT suite_type_id AS id, STS.suite_variant, name, capacity, price, beds_count, rooms_count
FROM suite_type
         JOIN suite_type_spec STS on suite_type.ID = STS.SUITE_TYPE_ID;

CREATE OR REPLACE PROCEDURE insert_suite_type(
    suite_name IN VARCHAR,
    suite_capacity IN INT,
    suite_price IN FLOAT,
    suite_type IN VARCHAR,
    suite_beds_count IN INT,
    suite_rooms_count IN INT,
    suite_type_id OUT INT
)
    IS
BEGIN
    INSERT INTO suite_type (name, capacity, price)
    VALUES (suite_name, suite_capacity, suite_price)
    RETURNING id INTO suite_type_id;
    INSERT INTO suite_type_spec (suite_type_id, suite_variant, beds_count, rooms_count)
    VALUES (suite_type_id, suite_type, suite_beds_count, suite_rooms_count);
END;

-- INSERTS FOR TESTING
DECLARE
    suite_type_id INT;
BEGIN
    insert_suite_type('Single Room', 4, 100, 'ROOM', 1, 1, suite_type_id);
    insert_suite_type('Double Room', 4, 150, 'ROOM', 2, 1, suite_type_id);
    insert_suite_type('Standard Apartment', 1, 200, 'APARTMENT', 1, 2, suite_type_id);
    insert_suite_type('Luxury Apartment', 1, 300, 'APARTMENT', 2, 2, suite_type_id);
END;

-- SUITE TYPES END

-- SUITES BEGIN
-- Suites are declared in suite table.
-- It also has a specification of a suite type (suite_type_id) used to represent relationship between suite and its suite type.
-- Suite type is used to determine if a suite is a room or an apartment.

-- DROP TABLE XMOISE01.suite;
-- DROP VIEW XMOISE01.suite_view;
-- DROP PROCEDURE XMOISE01.insert_suite;

CREATE TABLE suite
(
    suite_number  INT NOT NULL PRIMARY KEY,
    suite_type_id INT,
    -- 0 - not available, 1 - available
    suite_status  SMALLINT DEFAULT 1,
    CONSTRAINT suite_type_id_fk FOREIGN KEY (suite_type_id) REFERENCES suite_type (id)
        ON DELETE SET NULL,
    CONSTRAINT suite_number_fk CHECK ( suite_number > 1000 AND suite_number < 9999 ),
    CONSTRAINT suite_status_ck CHECK ( suite_status IN (0, 1))
);

CREATE VIEW suite_view AS
SELECT suite_number,
       SUBSTR(suite_number, 1, 1) AS floor,
       ST.CAPACITY,
       ST.NAME,
       ST.PRICE,
       STS.ROOMS_COUNT,
       STS.BEDS_COUNT,
       STS.SUITE_VARIANT
FROM suite
         JOIN SUITE_TYPE ST on ST.ID = SUITE.SUITE_TYPE_ID
         JOIN SUITE_TYPE_SPEC STS on ST.ID = STS.SUITE_TYPE_ID;

CREATE PROCEDURE insert_suite(insert_number IN INT, insert_type_id IN INT)
AS
BEGIN
    INSERT INTO suite (suite_number, suite_type_id)
    VALUES (insert_number, insert_type_id);
END;

-- INSERTS FOR TESTING
BEGIN
    FOR suite_type IN (SELECT * FROM SUITE_TYPE)
        LOOP
            insert_suite(suite_type.ID * 1000 + 1, suite_type.ID);
            insert_suite
                (suite_type.ID * 1000 + 2, suite_type.ID);
            insert_suite
                (suite_type.ID * 1000 + 3, suite_type.ID);
        END LOOP;
END;

-- SUITES END

-- SERVICES BEGIN

CREATE TABLE service
(
    id             INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    service_name   VARCHAR(255)                     NOT NULL,
    service_price  FLOAT                            NOT NULL,
    service_status SMALLINT                         NOT NULL,
    CONSTRAINT service_status_check CHECK (service_status IN (0, 1))
);

CREATE PROCEDURE insert_service(
    insert_service_name IN VARCHAR,
    insert_service_price IN FLOAT,
    insert_service_status IN VARCHAR
)
AS
BEGIN
    INSERT INTO service (service_name, service_price, service_status)
    VALUES (insert_service_name, insert_service_price, insert_service_status);
END;

-- TESTING DATA

BEGIN
    insert_service('Cleaning Room', 10, 1);
    insert_service('Breakfast in the room', 15, 1);
    insert_service('Wake-up call', 1, 1);
END;

-- SERVICES END

-- RESERVATIONS BEGIN

-- DROP TABLE reservation;
-- DROP TRIGGER reservation_check_dates;
-- DROP VIEW reservation_client_view;
-- DROP VIEW reservation_suite_view;

CREATE TABLE reservation
(
    id              INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    client_passport VARCHAR(16)                      NOT NULL,
    suite_number    INT                              NOT NULL,
    arrival         DATE                             NOT NULL,
    departure       DATE                             NOT NULL,
    guests_count    INT                              NOT NULL,
    payment_option  VARCHAR(4)                       NOT NULL,
    sum             FLOAT                            NOT NULL,
    CONSTRAINT fk_client FOREIGN KEY (client_passport) REFERENCES client (passport_number),
    CONSTRAINT fk_suite FOREIGN KEY (suite_number) REFERENCES suite (suite_number),
    CONSTRAINT fk_payment_check CHECK (payment_option IN ('CASH', 'CARD')),
    CONSTRAINT fk_arrival_check CHECK (arrival < departure)
);

CREATE OR REPLACE TRIGGER reservation_sum
    BEFORE INSERT OR UPDATE
    ON reservation
    FOR EACH ROW
DECLARE
    price FLOAT;
BEGIN
    SELECT price INTO price FROM suite
                            JOIN SUITE_TYPE ST on ST.ID = SUITE.SUITE_TYPE_ID
                            WHERE suite_number = :NEW.suite_number;

    :NEW.sum := price * (TO_DATE(:NEW.departure, 'DD.MM.YYYY') - TO_DATE(:NEW.arrival, 'DD.MM.YYYY'));
END;

CREATE OR REPLACE TRIGGER reservation_check_dates
    BEFORE INSERT OR UPDATE
    ON reservation
    FOR EACH ROW
BEGIN
    IF :NEW.arrival < CURRENT_DATE OR :NEW.departure < CURRENT_DATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Arrival and departure dates must be in the future');
    END IF;
END;

CREATE OR REPLACE TRIGGER reservation_check_available
    BEFORE INSERT OR UPDATE
    ON reservation
    FOR EACH ROW
DECLARE
    counter INT;
BEGIN
    SELECT COUNT(*)
    INTO counter
    FROM reservation
    WHERE suite_number = :NEW.suite_number
        AND (
            (:NEW.arrival BETWEEN arrival AND departure)
            OR (:NEW.departure BETWEEN arrival AND departure)
        );
    IF counter > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'This suite is already reserved for the specified dates.');
    END IF;
END;

CREATE OR REPLACE TRIGGER reservation_check_guests
    BEFORE INSERT OR UPDATE
    ON reservation
    FOR EACH ROW
DECLARE
    counter INT;
BEGIN
    SELECT COUNT(*)
    INTO counter
    FROM suite s
        JOIN suite_type st ON s.suite_type_id = st.id
        WHERE :NEW.suite_number = s.suite_number AND :NEW.guests_count > st.capacity;
    IF counter > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid number of guests for this room.');
    END IF;
END;

CREATE OR REPLACE VIEW reservation_client_view AS
SELECT id,
       client_passport,
       suite_number,
       arrival,
       departure,
       guests_count,
       payment_option,
       c.full_name,
       c.phone_number,
       c.email
FROM reservation
         JOIN CLIENT_VIEW c ON client_passport = c.passport_number;

CREATE OR REPLACE VIEW reservation_suite_view AS
SELECT id,
       client_passport,
       r.suite_number,
       s.floor,
       arrival,
       departure,
       guests_count,
       payment_option,
       s.price,
       s.capacity,
       s.rooms_count,
       s.beds_count,
       s.suite_variant,
       ROUND((s.price * (r.departure - r.arrival)), 2) AS total_price
FROM reservation r
         JOIN SUITE_VIEW s ON r.suite_number = s.suite_number;

CREATE OR REPLACE PROCEDURE insert_reservation(
    insert_client_passport VARCHAR,
    insert_suite_number INT,
    insert_arrival DATE,
    insert_departure DATE,
    insert_guests_count INT,
    insert_payment_option VARCHAR
)
AS
BEGIN
    INSERT INTO reservation (client_passport, suite_number, arrival, departure, guests_count, payment_option)
    VALUES (insert_client_passport, insert_suite_number, insert_arrival, insert_departure, insert_guests_count, insert_payment_option);
END;

-- INSERTS FOR TESTING
DECLARE
    counter INT := 0;
BEGIN
    FOR client IN (SELECT * FROM CLIENT)
        LOOP
            FOR suite in (SELECT * FROM SUITE WHERE ROWNUM <= 2)
                LOOP
                    counter := counter + 1;
                    insert_reservation(
                            CLIENT.PASSPORT_NUMBER,
                            suite.SUITE_NUMBER,
                            TO_DATE('01.0' || counter || '.2024', 'DD.MM.YYYY'),
                            TO_DATE('05.0' || counter || '.2024', 'DD.MM.YYYY'),
                            1,
                            CASE WHEN MOD(counter, 3) = 0 THEN 'CASH' ELSE 'CARD' END
                        );
                END LOOP;
        END LOOP;
END;

-- RESERVATIONS END

-- SERVICE REQUESTS BEGIN

CREATE TABLE service_request
(
    id                   INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    service_request_date DATE                             NOT NULL,
    service_id           INT                              NOT NULL,
    reservation_id       INT                              NOT NULL,
    CONSTRAINT fk_service_id FOREIGN KEY (service_id) REFERENCES service (id),
    CONSTRAINT fk_reservation_id FOREIGN KEY (reservation_id) REFERENCES reservation (id)
);

CREATE OR REPLACE TRIGGER request_check_dates
    BEFORE INSERT OR UPDATE
    ON service_request
    FOR EACH ROW
DECLARE
    counter INT;
BEGIN
    SELECT COUNT(*) INTO counter
        FROM reservation r
        WHERE r.id = :NEW.reservation_id AND
              (:NEW.service_request_date < r.arrival OR :NEW.service_request_date > r.departure);
    IF counter > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'The date of the service request must be on the dates of the reservation.');
    END IF;
END;

CREATE VIEW service_request_view AS
SELECT service_request.id,
       service_request.service_request_date,
       s.service_name,
       s.service_price
FROM service_request
         JOIN service s ON service_request.service_id = s.ID;

CREATE PROCEDURE insert_service_request(
    insert_request_date IN DATE,
    insert_service_id IN INT,
    insert_reservation_id IN INT
)
AS
BEGIN
    INSERT INTO service_request (service_request_date, service_id, reservation_id)
    VALUES (insert_request_date, insert_service_id, insert_reservation_id);
END;

-- TESTING DATA

BEGIN
    FOR res in (SELECT * FROM RESERVATION)
        LOOP
            FOR serv in (SELECT * FROM SERVICE)
                LOOP
                    insert_service_request('01-04-2023', serv.id, res.ID);
                END LOOP;
        END LOOP;
END;

-- SERVICE REQUESTS END


------------------- EXPLAIN PLAN AND INDEX -------------------

-- Plan for a request that lists the names
-- and number of reservations of Czech residents in alphabetical order
EXPLAIN PLAN FOR
    SELECT c.last_name, c.first_name, COUNT(r.client_passport) AS reservation_quantity
    FROM reservation r
    JOIN client c ON c.passport_number = r.client_passport
    WHERE c.permanent_residence LIKE 'CZK'
    GROUP BY c.last_name, c.first_name
    ORDER BY c.last_name;
-- output
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Index on the passport number column in
-- the reservations table to speed up the previous request
CREATE INDEX client_passport ON reservation (client_passport);


----------------- THE THIRD PART OF THE PROJECT --------------------

-- Joining service table and service requests by service id
-- | id service request | name service | date | id reservation |
SELECT sr.id, s.service_name, sr.service_request_date, sr.reservation_id
FROM service s
         INNER JOIN service_request sr ON s.id = sr.service_id;

-- Joining suite table and types of suites by type id
-- | suite number | type name | price | status |
SELECT s.suite_number, st.name, st.price, s.suite_status
FROM suite s
         INNER JOIN suite_type st ON s.suite_type_id = st.id;

-- Joining reservation, client and suite
-- | id reservation | client's first name | last name | date arrival | departure | suite |
SELECT r.id, c.first_name, c.last_name, r.arrival, r.departure, s.suite_number
FROM reservation r
         JOIN client c ON r.client_passport = c.passport_number
         JOIN suite s ON r.suite_number = s.suite_number;

-- Lists the number of rooms of each type (how many rooms of each type)
SELECT s.suite_type_id, st.name, COUNT(*) AS room_of_types
FROM suite s
         JOIN suite_type st ON s.suite_type_id = st.id
GROUP BY st.name, s.suite_type_id
ORDER BY s.suite_type_id;

-- Counts the number of reservations by payment
-- (How many reservations are paid by card and in cash)
SELECT payment_option, COUNT(*) as count_payment
FROM reservation
GROUP BY payment_option;

-- Lists the numbers of the most expensive rooms
SELECT s.suite_number
FROM suite s
         JOIN suite_type st ON s.suite_type_id = st.id
WHERE st.price = (SELECT MAX(price) FROM suite_type);

-- Lists rooms cheaper than 200
SELECT *
FROM suite s
WHERE EXISTS (SELECT *
              FROM suite_type st
              WHERE st.id = s.suite_type_id
                AND st.price < 200);

-- Lists clients who will arrive after March 1, 2024
SELECT first_name, last_name, phone_number
FROM client
WHERE passport_number IN (SELECT client_passport
                          FROM reservation
                          WHERE arrival >= TO_DATE('01.03.2024', 'DD.MM.YYYY'));

