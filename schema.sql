DROP DATABASE comp_1630_project;
CREATE DATABASE comp_1630_project;
USE comp_1630_project;
BEGIN;
CREATE TABLE user (
    user_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_password VARCHAR(255),
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
    genre_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    genre_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE media (
    media_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    release_date DATETIME,
    added_date DATETIME NOT NULL DEFAULT NOW(),
    added_by_user_id INT UNSIGNED,
    media_type ENUM('book', 'movie', 'magazine') NOT NULL,
    FOREIGN KEY (added_by_user_id) REFERENCES user(user_id)
);

CREATE TABLE book (
    book_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    media_id INT UNSIGNED NOT NULL UNIQUE,
    FOREIGN KEY (media_id) REFERENCES media(media_id)
);

CREATE TABLE movie (
    movie_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    media_id INT UNSIGNED NOT NULL UNIQUE,
    runtime_minutes SMALLINT UNSIGNED,
    FOREIGN KEY (media_id) REFERENCES media(media_id)
);

CREATE TABLE magazine (
    magazine_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    media_id INT UNSIGNED NOT NULL UNIQUE,
    issue_num MEDIUMINT UNSIGNED,
    FOREIGN KEY (media_id) REFERENCES media(media_id)
);

CREATE TABLE creator (
    creator_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    creator_fname VARCHAR(255),
    creator_lname VARCHAR(255)
);

CREATE TABLE media_genre (
    genre_id INT UNSIGNED,
    media_id INT UNSIGNED,
    sort_order INT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (genre_id, media_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id),
    FOREIGN KEY (media_id) REFERENCES media(media_id),
    CONSTRAINT UNIQUE(genre_id, media_id)
);

CREATE TABLE media_creators (
    creator_id INT UNSIGNED,
    media_id INT UNSIGNED,
    sort_order INT UNSIGNED,
    PRIMARY KEY (creator_id, media_id),
    FOREIGN KEY (creator_id) REFERENCES creator(creator_id),
    FOREIGN KEY (media_id) REFERENCES media(media_id),
    CONSTRAINT UNIQUE(creator_id, media_id)
);

CREATE TABLE fine_reason (
    reason_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    reason_str VARCHAR(255) NOT NULL
);

CREATE TABLE building (
    building_num INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    building_label VARCHAR(255) NOT NULL
);

CREATE TABLE location (
    location_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    building_num INT UNSIGNED NOT NULL,
    loc_name VARCHAR(255),
    loc_aisle_num INT UNSIGNED,
    loc_floor_num INT UNSIGNED,
    genre_id INT UNSIGNED,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id),
    FOREIGN KEY (building_num) REFERENCES building(building_num)
);

CREATE TABLE copy (
    copy_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    media_id INT UNSIGNED,
    is_hardcover BOOLEAN,
    is_large_print BOOLEAN,
    location_id INT UNSIGNED,
    added_by_user_id INT UNSIGNED,
    added_date DATETIME,
    FOREIGN KEY (media_id) REFERENCES media(media_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    FOREIGN KEY (added_by_user_id) REFERENCES user(user_id)
);

CREATE TABLE copy_status (
    status_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    copy_id INT UNSIGNED NOT NULL,
    status_date DATETIME NOT NULL DEFAULT NOW(),
    is_damaged BOOLEAN NOT NULL DEFAULT FALSE,
    is_lost BOOLEAN NOT NULL DEFAULT FALSE,
    is_reserved BOOLEAN NOT NULL DEFAULT FALSE,
    is_loaned BOOLEAN NOT NULL DEFAULT FALSE,
    triggering_user_id INT UNSIGNED,
    FOREIGN KEY (copy_id) REFERENCES copy(copy_id),
    FOREIGN KEY (triggering_user_id) REFERENCES user(user_id)
);

ALTER TABLE copy ADD COLUMN status_id INT UNSIGNED;
ALTER TABLE copy ADD FOREIGN KEY (status_id) REFERENCES copy_status(status_id);

CREATE TABLE loan (
    loan_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    copy_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    checkout_date DATETIME NOT NULL DEFAULT NOW(),
    return_date DATETIME,
    due_date DATETIME,
    renewed_date DATETIME,
    FOREIGN KEY loan_fk_copy_id (copy_id) REFERENCES copy(copy_id),
    FOREIGN KEY loan_fk_user_id (user_id) REFERENCES user(user_id)
);

CREATE TABLE reservation (
    reservation_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id INT UNSIGNED NOT NULL,
    copy_id INT UNSIGNED NOT NULL,
    created_date DATETIME NOT NULL DEFAULT NOW(),
    reservation_start DATETIME,
    reservation_end DATETIME,
    is_active BOOL,
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (media_id) REFERENCES media(media_id)
);

CREATE TABLE fine (
    fine_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    loan_id INT UNSIGNED NOT NULL,
    fine_date DATETIME NOT NULL DEFAULT NOW(),
    fine_amount DECIMAL(10,2) NOT NULL,
    reason_id INT UNSIGNED NOT NULL,
    is_paid BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (loan_id) REFERENCES loan(loan_id),
    FOREIGN KEY (reason_id) REFERENCES fine_reason(reason_id)
);

CREATE TABLE payment (
    payment_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    fine_id INT UNSIGNED NOT NULL,
    pay_date DATETIME NOT NULL DEFAULT NOW(),
    pay_amount DECIMAL(10,2) NOT NULL,
    pay_method VARCHAR(255) NOT NULL,
    FOREIGN KEY (fine_id) REFERENCES fine(fine_id)
);

COMMIT;
SHOW TABLES;
