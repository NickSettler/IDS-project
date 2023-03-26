CREATE TABLE service_request(
    service_request_id   INT  NOT NULL PRIMARY KEY,
    service_request_date DATE NOT NULL,
    service_id           INT,
    reservation_id       INT,
    CONSTRAINT fk_service_id FOREIGN KEY (service_id) REFERENCES service (service_id),
    CONSTRAINT fk_reservation_id FOREIGN KEY (reservation_id) REFERENCES reservation (id)
    );

CREATE VIEW service_request_view AS
SELECT service_request.service_request_id,
       service_request.service_request_date,
       s.service_name,
       s.service_price
FROM service_request
    JOIN service s ON service_request.service_id = s.service_id;

CREATE PROCEDURE insert_service_request (
    insert_request_id IN INT,
    insert_request_date IN DATE,
    insert_service_id IN INT,
    insert_reservation_id IN INT
    )
AS
BEGIN
  INSERT INTO service_request (service_request_id, service_request_date)
  VALUES (insert_request_id, insert_request_date);
END;

-- TESTING DATA

BEGIN
    insert_service_request (1, '01-04-2023', 1, 1);
    insert_service_request (2, '02-04-2023', 2, 2);
    insert_service_request (3, '03-04-2023', 3, 3);
END;
