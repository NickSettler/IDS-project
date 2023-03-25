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