DROP DATABASE comp_1630_project;
CREATE DATABASE comp_1630_project;
USE comp_1630_project;
BEGIN;
CREATE TABLE user (
    user_id INT PRIMARY KEY,
    user_fname VARCHAR(255),
    user_lname VARCHAR(255),
    user_email VARCHAR(255),
    user_phone_no VARCHAR(20),
    user_join_date DATETIME NOT NULL DEFAULT NOW(),
    is_librarian BOOLEAN NOT NULL DEFAULT FALSE,
    is_staff BOOLEAN NOT NULL DEFAULT FALSE,
    is_faculty BOOLEAN NOT NULL DEFAULT FALSE,
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    user_valid BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE book (
    book_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    publication_date DATETIME,
    added_date DATETIME NOT NULL DEFAULT NOW(),
    added_by_user_id INT,
    FOREIGN KEY (added_by_user_id) REFERENCES USER(user_id)
);

CREATE TABLE author (
    author_id INT PRIMARY KEY,
    author_fname VARCHAR(255),
    author_lname VARCHAR(255)
);

CREATE TABLE book_genre (
    genre_id INT,
    book_id INT,
    sort_order INT NOT NULL DEFAULT 1,
    PRIMARY KEY (genre_id, book_id),
    FOREIGN KEY (genre_id) REFERENCES GENRE(genre_id),
    FOREIGN KEY (book_id) REFERENCES BOOK(book_id),
    CONSTRAINT UNIQUE(genre_id, book_id)
);

CREATE TABLE authorship (
    author_id INT,
    book_id INT,
    sort_order INT,
    PRIMARY KEY (author_id, book_id),
    FOREIGN KEY (author_id) REFERENCES AUTHOR(author_id),
    FOREIGN KEY (book_id) REFERENCES BOOK(book_id),
    CONSTRAINT UNIQUE(author_id, book_id)
);

CREATE TABLE fine_reason (
    reason_id INT PRIMARY KEY,
    reason_str VARCHAR(255) NOT NULL
);

CREATE TABLE building (
    building_num INT PRIMARY KEY,
    building_label VARCHAR(255) NOT NULL
);

CREATE TABLE location (
    location_id INT PRIMARY KEY,
    building_num INT NOT NULL,
    loc_name VARCHAR(255),
    loc_aisle_num INT,
    loc_floor_num INT,
    genre_id INT,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id),
    FOREIGN KEY (building_num) REFERENCES building(building_num)
);

CREATE TABLE copy (
    copy_id INT PRIMARY KEY,
    book_id INT,
    is_hardcover BOOLEAN,
    is_large_print BOOLEAN,
    location_id INT,
    added_by_user_id INT,
    added_date DATETIME,
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    FOREIGN KEY (added_by_user_id) REFERENCES user(user_id)
);

CREATE TABLE copy_status (
    status_id INT PRIMARY KEY,
    copy_id INT NOT NULL,
    status_date DATETIME NOT NULL DEFAULT NOW(),
    is_damaged BOOLEAN NOT NULL DEFAULT FALSE,
    is_lost BOOLEAN NOT NULL DEFAULT FALSE,
    is_reserved BOOLEAN NOT NULL DEFAULT FALSE,
    is_loaned BOOLEAN NOT NULL DEFAULT FALSE,
    triggering_user_id INT,
    FOREIGN KEY (copy_id) REFERENCES copy(copy_id),
    FOREIGN KEY (triggering_user_id) REFERENCES USER(user_id)
);

ALTER TABLE copy ADD COLUMN status_id INT;
ALTER TABLE copy ADD FOREIGN KEY (status_id) REFERENCES copy_status(status_id);

CREATE TABLE loan (
    loan_id INT PRIMARY KEY,
    copy_id INT NOT NULL,
    user_id INT NOT NULL,
    checkout_date DATETIME NOT NULL DEFAULT NOW(),
    return_date DATETIME,
    due_date DATETIME,
    renewed_date DATETIME,
    FOREIGN KEY loan_fk_copy_id (copy_id) REFERENCES copy(copy_id),
    FOREIGN KEY loan_fk_user_id (user_id) REFERENCES user(user_id)
);

CREATE TABLE reservation (
    reservation_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_start DATE NOT NULL,
    reservation_end DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id)
);

CREATE TABLE fine (
    fine_id INT PRIMARY KEY,
    loan_id INT NOT NULL,
    fine_date DATETIME NOT NULL DEFAULT NOW(),
    fine_amount DECIMAL(10,2) NOT NULL,
    reason_id INT NOT NULL,
    is_paid BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (loan_id) REFERENCES loan(loan_id),
    FOREIGN KEY (reason_id) REFERENCES fine_reason(reason_id)
);

CREATE TABLE payment (
    payment_id INT PRIMARY KEY,
    fine_id INT NOT NULL,
    pay_date DATETIME NOT NULL DEFAULT NOW(),
    pay_amount DECIMAL(10,2) NOT NULL,
    pay_method VARCHAR(255) NOT NULL,
    FOREIGN KEY (fine_id) REFERENCES fine(fine_id)
);

COMMIT;
SHOW TABLES;
