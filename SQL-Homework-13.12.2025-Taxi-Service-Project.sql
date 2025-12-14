
IF DB_ID('taxi_service_db') IS NULL
BEGIN
	CREATE DATABASE taxi_service_db;
END

USE taxi_service_db;



--! Customers Table

CREATE TABLE Customers (
	customer_id		int             IDENTITY(1, 1),
	phone			varchar			UNIQUE					NOT NULL,
	email			varchar			UNIQUE					NULL,
	reg_date		datetime		DEFAULT(GETDATE())      NOT NULL,
	is_active		bit				DEFAULT(0)              NOT NULL,

	CONSTRAINT PK_Customers_customer_id			PRIMARY KEY (customer_id),

	CONSTRAINT CH_Customers_phone_starts_with   CHECK       (phone LIKE '+%'),
	CONSTRAINT CH_Customers_phone_length        CHECK		(LEN(phone) >= 10)
);




--! Drivers Table

CREATE TABLE Drivers (
	driver_id       int             IDENTITY(1, 1),
	license         varchar         UNIQUE                  NOT NULL,
    phone           varchar         UNIQUE                  NOT NULL,
    name            nvarchar                                NOT NULL,
    hire_date       date                                    NULL,
    status          nvarchar                                NULL,

    CONSTRAINT PK_Drivers_driver_id     PRIMARY KEY (driver_id),

    CONSTRAINT CH_Drivers_status        CHECK       (status IN ('available', 'unavailable')),
);



--! Cars Table

CREATE TABLE Cars (
    car_id          int             IDENTITY(1, 1),
    plate           varchar         UNIQUE                  NOT NULL,
    model           nvarchar                                NOT NULL,
    year            int                                     NULL,
    driver_id       int                                     NULL,

    CONSTRAINT PK_Cars_car_id              PRIMARY KEY (car_id),

    CONSTRAINT FK_Cars_driver_id           FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id)
        ON DELETE CASCADE,

    CONSTRAINT CH_Cars_year                CHECK       (year >= 2000),
);


--! Riders Table

CREATE TABLE Rides (
    ride_id         int             IDENTITY(1, 1),
    customer_id     int                                     NOT NULL,
    driver_id       int                                     NOT NULL,
    car_id          int                                     NOT NULL,
    status          nvarchar                                NOT NULL,
    price           decimal                                 NOT NULL,
    start_time      datetime                                NOT NULL,
    end_time        datetime                                NULL, 

    CONSTRAINT PK_Riders_ride_id		   PRIMARY KEY (ride_id),

    CONSTRAINT FK_Rides_customer_id        FOREIGN KEY (customer_id)    REFERENCES Customers(customer_id),
    CONSTRAINT FK_Rides_driver_id          FOREIGN KEY (driver_id)       REFERENCES Drivers(driver_id),     
    CONSTRAINT FK_Rides_car_id             FOREIGN KEY (car_id)         REFERENCES Cars(car_id),

    CONSTRAINT CH_Rides_status             CHECK       (status IN ('in_progress', 'completed', 'cancelled')),  
    CONSTRAINT CH_Rides_price              CHECK       (price > 0),  
);


--! Payments Table

CREATE TABLE Payments (
    payment_id      int             IDENTITY(1, 1),
    ride_id         int             UNIQUE                  NOT NULL,
    amount          decimal                                 NULL,
    method          nvarchar                                NULL,
    pay_date        datetime        DEFAULT(GETDATE())      NOT NULL, 

    CONSTRAINT PK_Payments_payment_id     PRIMARY KEY (payment_id),

    CONSTRAINT FK_Payments_ride_id        FOREIGN KEY (ride_id) REFERENCES Rides(ride_id),

    CONSTRAINT CH_Payments_amount         CHECK       (amount > 0),
    CONSTRAINT CH_Payments_method         CHECK       (method IN ('cash', 'card', 'crypto'))
)


--! Reviews Table

CREATE TABLE Reviews (
    review_id       int             IDENTITY(1, 1),
    ride_id         int             UNIQUE                  NOT NULL,
    rating          int                                     NOT NULL,
    comment         nvarchar                                NULL,

    CONSTRAINT PK_Reviews_review_id     PRIMARY KEY (review_id),

    CONSTRAINT FK_Reviews_ride_id       FOREIGN KEY (ride_id) REFERENCES Rides(ride_id),

    CONSTRAINT CH_Reviews_rating        CHECK       (rating >= 1 AND rating <= 5)
)



-- Droping tables if required
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Riders;
DROP TABLE IF EXISTS Cars;
DROP TABLE IF EXISTS Drivers;
DROP TABLE IF EXISTS Customers;


-- Before droping - хотел бы спросить касательно удаления бд. Как это осуществляется под капотом и откуда могут браться 
--                      новые подключения к бд.
USE master;
ALTER DATABASE taxi_service_db
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;


-- If database drop is required
DROP DATABASE IF EXISTS taxi_service_db;
