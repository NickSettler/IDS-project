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

CREATE OR REPLACE VIEW reservation_client_view AS
SELECT id,
       client_passport,
       suite_number,
       arrival,
       departure,
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
    insert_payment_option VARCHAR
)
AS
BEGIN
    INSERT INTO reservation (client_passport, suite_number, arrival, departure, payment_option)
    VALUES (insert_client_passport, insert_suite_number, insert_arrival, insert_departure, insert_payment_option);
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
                            'CASH'
                        );
                END LOOP;
        END LOOP;
END;