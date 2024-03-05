DROP DATABASE comp_1630_project;
CREATE DATABASE comp_1630_project;
USE comp_1630_project;
BEGIN;
CREATE TABLE USER (
    user_id INT PRIMARY KEY,
    user_fname VARCHAR(255),
    user_lname VARCHAR(255),
    user_email VARCHAR(255),
    user_phone_no VARCHAR(20),
    user_join_date DATE,
    is_librarian BOOLEAN,
    is_staff BOOLEAN,
    is_faculty BOOLEAN,
    is_public BOOLEAN,
    user_valid BOOLEAN
);

CREATE TABLE GENRE (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(255)
);

CREATE TABLE BOOK (
    book_id INT PRIMARY KEY,
    title VARCHAR(255),
    publication_date DATE,
    added_date DATE,
    added_by_user_id INT,
    FOREIGN KEY (added_by_user_id) REFERENCES USER(user_id)
);

CREATE TABLE AUTHOR (
    author_id INT PRIMARY KEY,
    author_fname VARCHAR(255),
    author_lname VARCHAR(255)
);

CREATE TABLE BOOK_GENRE (
    genre_id INT,
    book_id INT,
    sort_order INT,
    PRIMARY KEY (genre_id, book_id),
    FOREIGN KEY (genre_id) REFERENCES GENRE(genre_id),
    FOREIGN KEY (book_id) REFERENCES BOOK(book_id)
);

CREATE TABLE AUTHORSHIP (
    author_id INT,
    book_id INT,
    sort_order INT,
    PRIMARY KEY (author_id, book_id),
    FOREIGN KEY (author_id) REFERENCES AUTHOR(author_id),
    FOREIGN KEY (book_id) REFERENCES BOOK(book_id)
);

CREATE TABLE FINE_REASON (
    reason_id INT PRIMARY KEY,
    reason_str VARCHAR(255)
);

CREATE TABLE LOCATION (
    location_id INT PRIMARY KEY,
    building_num INT,
    loc_name VARCHAR(255),
    loc_aisle_num INT,
    loc_floor_num INT,
    genre_id INT,
    FOREIGN KEY (genre_id) REFERENCES GENRE(genre_id)
);

CREATE TABLE BUILDING (
    building_num INT PRIMARY KEY,
    building_label VARCHAR(255)
);

CREATE TABLE COPY (
    copy_id INT PRIMARY KEY,
    book_id INT,
    is_hardcover BOOLEAN,
    is_large_print BOOLEAN,
    location_id INT,
    added_by_user_id INT,
    added_date DATE,
    FOREIGN KEY (book_id) REFERENCES BOOK(book_id),
    FOREIGN KEY (location_id) REFERENCES LOCATION(location_id),
    FOREIGN KEY (added_by_user_id) REFERENCES USER(user_id)
);

CREATE TABLE COPY_STATUS (
    status_id INT PRIMARY KEY,
    copy_id INT,
    status_date DATE,
    is_damaged BOOLEAN,
    is_lost BOOLEAN,
    is_reserved BOOLEAN,
    is_loaned BOOLEAN,
    triggering_user_id INT,
    FOREIGN KEY (copy_id) REFERENCES COPY(copy_id),
    FOREIGN KEY (triggering_user_id) REFERENCES USER(user_id)
);

ALTER TABLE COPY ADD COLUMN status_id INT;
ALTER TABLE COPY ADD FOREIGN KEY (status_id) REFERENCES COPY_STATUS(status_id);

CREATE TABLE LOAN (
    loan_id INT PRIMARY KEY,
    copy_id INT,
    user_id INT,
    checkout_date DATE,
    return_date DATE,
    due_date DATE,
    renewed_date DATE,
    FOREIGN KEY (copy_id) REFERENCES COPY(copy_id),
    FOREIGN KEY (user_id) REFERENCES USER(user_id)
);

CREATE TABLE RESERVATION (
    reservation_id INT PRIMARY KEY,
    user_id INT,
    book_id INT,
    reservation_start DATE,
    reservation_end DATE,
    FOREIGN KEY (user_id) REFERENCES USER(user_id),
    FOREIGN KEY (book_id) REFERENCES BOOK(book_id)
);

CREATE TABLE FINE (
    fine_id INT PRIMARY KEY,
    loan_id INT,
    fine_date DATE,
    fine_amount DECIMAL(10,2),
    reason_id INT,
    is_paid BOOLEAN,
    FOREIGN KEY (loan_id) REFERENCES LOAN(loan_id),
    FOREIGN KEY (reason_id) REFERENCES FINE_REASON(reason_id)
);

CREATE TABLE PAYMENT (
    payment_id INT PRIMARY KEY,
    fine_id INT,
    pay_date DATE,
    pay_amount DECIMAL(10,2),
    pay_method VARCHAR(255),
    FOREIGN KEY (fine_id) REFERENCES FINE(fine_id)
);

COMMIT;
SHOW TABLES;
