DROP TABLE XMOISE01.suite_type_spec;
DROP TABLE XMOISE01.suite_type;
DROP VIEW XMOISE01.suite_type_view;
DROP PROCEDURE XMOISE01.insert_suite_type;

CREATE TABLE XMOISE01.suite_type
(
    id       INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    name     VARCHAR(255)                     NOT NULL CHECK ( name <> '' ),
    capacity INT                              NOT NULL CHECK ( capacity > 0 ),
    price    FLOAT                            NOT NULL CHECK ( price > 0 ),
    CONSTRAINT suite_type_pk PRIMARY KEY (id),
    CONSTRAINT suite_type_unique UNIQUE (name)
);

CREATE TABLE XMOISE01.suite_type_spec
(
    suite_type_id INT          NOT NULL,
    suite_variant VARCHAR(255) NOT NULL CHECK ( suite_variant in ('ROOM', 'APARTMENT') ),
    beds_count    INT          NOT NULL CHECK ( beds_count > 0 ),
    rooms_count   INT          NOT NULL CHECK ( rooms_count > 0 ),
    CONSTRAINT suite_type_spec_pk PRIMARY KEY (suite_type_id),
    CONSTRAINT suite_type_spec_fk FOREIGN KEY (suite_type_id) REFERENCES XMOISE01.suite_type (id),
    CONSTRAINT suite_type_spec_unique UNIQUE (suite_variant, beds_count, rooms_count),
    CONSTRAINT suite_type_spec_check CHECK ( suite_variant = 'ROOM' AND beds_count >= 1 AND rooms_count = 1 OR
                                             suite_variant = 'APARTMENT' AND beds_count >= 1 AND rooms_count > 1 )
);

CREATE VIEW XMOISE01.suite_type_view AS
SELECT suite_type_id AS id, STS.suite_variant, name, capacity, price, beds_count, rooms_count
FROM XMOISE01.suite_type
         JOIN XMOISE01.suite_type_spec STS on suite_type.ID = STS.SUITE_TYPE_ID;

CREATE PROCEDURE XMOISE01.insert_suite_type(
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
    INSERT INTO XMOISE01.suite_type (name, capacity, price)
    VALUES (suite_name, suite_capacity, suite_price)
    RETURNING id INTO suite_type_id;
    INSERT INTO XMOISE01.suite_type_spec (suite_type_id, suite_variant, beds_count, rooms_count)
    VALUES (suite_type_id, suite_type, suite_beds_count, suite_rooms_count);
END;

-- INSERTS FOR TESTING
DECLARE
    suite_type_id INT;
BEGIN
    XMOISE01.insert_suite_type('Single Room', 4, 100, 'ROOM', 1, 1, suite_type_id);
    XMOISE01.insert_suite_type('Double Room', 4, 150, 'ROOM', 2, 1, suite_type_id);
    XMOISE01.insert_suite_type('Standard Apartment', 1, 200, 'APARTMENT', 1, 2, suite_type_id);
    XMOISE01.insert_suite_type('Luxury Apartment', 1, 300, 'APARTMENT', 2, 2, suite_type_id);
END;
