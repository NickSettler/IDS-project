CREATE TABLE service{
    service_id     INT          NOT NULL PRIMARY KEY,
    service_name   VARCHAR(255) NOT NULL,
    service_price  FLOAT        NOT NULL,
    service_status VARCHAR(255) NOT NULL,
    }

CREATE PROCEDURE insert_service (
    service_id IN INT,
    service_name IN VARCHAR,
    service_price IN FLOAT,
    service_status IN VARCHAR
)
    AS
BEGIN
  INSERT INTO service (service_id, service_name, service_price, service_status)
  VALUES (insert_service_id, insert_service_name, insert_service_price, insert_service_status);
END;

-- TESTING DATA

BEGIN
    insert_service(1, 'Cleaning Room', 10, 'access')
    insert_service(2, 'Breakfast in the room', 15, 'access')
    insert_service(3, 'Wake-up call', 1, 'access')
END;