# Task

The task is to create a database for a hotel. The database should contain information about the hotel's rooms, clients,
reservations, services and payments.

# ERD Diagram

Diagram of the database schema. It is also available in the [docs/erd.jpg](docs/erd.jpg) file.

```mermaid
erDiagram
    SUITE_TYPE ||--o{ SUITE : "is type of"
    SUITE_TYPE {
        integer id PK
        varchar name
        integer capacity
        double price
    }
    SUITE {
        integer number PK
        integer type_id FK
    }
    SUITE ||--o{ RESERVATION : "reserved"
    RESERVATION {
        integer id PK
        varchar client_passport FK
        integer suite_number FK
        date arrival
        date departure
        varchar payment_option
    }
    CLIENT ||--o{ RESERVATION : "makes"
    CLIENT {
        varchar passport_number PK
        varchar first_name
        varchar last_name
    }
    CLIENT ||--o{ RESERVATION_CLIENT : "is"
    RESERVATION ||--o{ RESERVATION_CLIENT : "has"
    RESERVATION_CLIENT {
        varchar client_passport FK
        integer reservation_id FK
    }
    RESERVATION ||--o{ SERVICE_REQUEST : "has"
    SERVICE_REQUEST {
        integer id PK
        integer reservation_id FK
        varchar service_id FK
        date date
    }
    SERVICE ||--o{ SERVICE_REQUEST : "requested"
    SERVICE {
        varchar id PK
        varchar name
        double price
    }
```