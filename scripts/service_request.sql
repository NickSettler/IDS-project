CREATE TABLE service_request{
    service_request_id   INT  NOT NULL PRIMARY KEY,
    service_request_date DATE NOT NULL,
    service_id           INT,
    reservation_id       INT,
    CONSTRAINT service_id_fk FOREIGN KEY (service_id) REFERENCES service (id)
    FOREIGN KEY reservation_id_fk FOREIGN KEY (reservation_id) REFERENCES reservation (id)
    }

CREATE VIEW service_request_view AS
SELECT sr.service_request_id,
       sr.date,
       s.service_name,
       s.service_price,
FROM service_request
    JOIN service s ON sr.service_id = s.service_id;

CREATE PROCEDURE insert_service_request (service_id IN INT, service_request_date IN DATE)
AS
BEGIN
  INSERT INTO service_request (service_request_id, service_request_date)
  VALUES (insert_request_id, insert_request_date);
END;

-- TESTING DATA

BEGIN
    insert_service_request (1, 01.04.2023)
    insert_service_request (2, 01.04.2023)
    insert_service_request (3, 02.04.2023)
END;