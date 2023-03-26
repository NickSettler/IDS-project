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
