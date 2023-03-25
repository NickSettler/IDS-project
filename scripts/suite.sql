-- DROP TABLE XMOISE01.suite;
-- DROP VIEW XMOISE01.suite_view;
-- DROP PROCEDURE XMOISE01.insert_suite;

CREATE TABLE suite
(
    suite_number  INT NOT NULL PRIMARY KEY,
    suite_type_id INT,
    CONSTRAINT suite_type_id_fk FOREIGN KEY (suite_type_id) REFERENCES suite_type (id)
        ON DELETE SET NULL,
    CONSTRAINT suite_number_fk CHECK ( suite_number > 1000 AND suite_number < 9999 )
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
    FOR suite_type IN (SELECT * FROM SUITE_TYPE) LOOP
        insert_suite(suite_type.ID * 1000 + 1, suite_type.ID);
        insert_suite(suite_type.ID * 1000 + 2, suite_type.ID);
        insert_suite(suite_type.ID * 1000 + 3, suite_type.ID);
    END LOOP;
END;