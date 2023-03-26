CREATE TABLE service_request
(
    id                   INT GENERATED ALWAYS AS IDENTITY NOT NULL PRIMARY KEY,
    service_request_date DATE                             NOT NULL,
    service_id           INT                              NOT NULL,
    reservation_id       INT                              NOT NULL,
    CONSTRAINT fk_service_id FOREIGN KEY (service_id) REFERENCES service (id),
    CONSTRAINT fk_reservation_id FOREIGN KEY (reservation_id) REFERENCES reservation (id)
);

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
