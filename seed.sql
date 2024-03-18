
-- Inserting users
INSERT INTO user (user_fname, user_lname, user_email, user_phone_no, is_librarian, is_staff, is_faculty, is_public, user_valid)
VALUES 
('John', 'Doe', 'john.doe@example.com', '1234567890', TRUE, FALSE, FALSE, FALSE, TRUE),
('Jane', 'Smith', 'jane.smith@example.com', '9876543210', FALSE, TRUE, FALSE, FALSE, TRUE),
('Alice', 'Johnson', 'alice.johnson@example.com', '5551234567', FALSE, FALSE, TRUE, FALSE, TRUE),
('Michael', 'Brown', 'michael.brown@example.com', '1112223333', FALSE, FALSE, FALSE, TRUE, TRUE),
('Emma', 'Jones', 'emma.jones@example.com', '4445556666', FALSE, FALSE, FALSE, TRUE, TRUE),
('William', 'Taylor', 'william.taylor@example.com', '7778889999', FALSE, TRUE, FALSE, FALSE, TRUE),
('Sophia', 'Wilson', 'sophia.wilson@example.com', '2223334444', FALSE, FALSE, TRUE, FALSE, TRUE),
('Oliver', 'Martinez', 'oliver.martinez@example.com', '6667778888', TRUE, FALSE, FALSE, FALSE, TRUE),
('Ava', 'Rodriguez', 'ava.rodriguez@example.com', '9990001111', FALSE, FALSE, FALSE, TRUE, TRUE),
('Noah', 'Lopez', 'noah.lopez@example.com', '3334445555', FALSE, TRUE, FALSE, FALSE, TRUE);

-- Inserting genres
INSERT INTO genre (genre_name) VALUES 
('Fiction'),
('Science Fiction'),
('Fantasy'),
('Horror'),
('Romance'),
('Thriller'),
('Mystery'),
('Biography'),
('History'),
('Adventure');

-- Inserting media items
INSERT INTO media (title, release_date, added_by_user_id, media_type) VALUES
('The Great Gatsby', '1925-04-10', 1, 'book'),
('The Lord of the Rings: The Fellowship of the Ring', '2001-12-19', 1, 'movie'),
('National Geographic', '1888-09-22', 1, 'magazine'),
('To Kill a Mockingbird', '1960-07-11', 2, 'book'),
('Star Wars: A New Hope', '1977-05-25', 2, 'movie'),
('Time', '1923-03-03', 3, 'magazine'),
('Harry Potter and the Sorcerer''s Stone', '1997-06-26', 4, 'book'),
('The Matrix', '1999-03-31', 4, 'movie'),
('Vogue', '1892-12-17', 5, 'magazine'),
('1984', '1949-06-08', 6, 'book'),
('Inception', '2010-07-16', 7, 'movie'),
('National Geographic Traveler', '1984-09-17', 7, 'magazine'),
('Pride and Prejudice', '1813-01-28', 8, 'book'),
('The Shawshank Redemption', '1994-09-23', 9, 'movie'),
('Popular Science', '1872-05-06', 10, 'magazine');

-- Inserting books
INSERT INTO book (media_id) VALUES 
(1), (4), (7), (10), (13);

-- Inserting movies
INSERT INTO movie (media_id, runtime_minutes) VALUES 
(2, 178), (5, 121), (8, 136), (11, 148), (14, 142);

-- Inserting magazines
INSERT INTO magazine (media_id, issue_num) VALUES 
(3, 1), (6, 1), (9, 1), (12, 1), (15, 1);

-- Inserting creators
INSERT INTO creator (creator_fname, creator_lname) VALUES 
('F. Scott', 'Fitzgerald'),
('J.R.R.', 'Tolkien'),
('Harper', 'Lee'),
('George', 'Lucas'),
('Christopher', 'Nolan'),
('Jane', 'Austen'),
('Frank', 'Darabont'),
('George', 'Orwell'),
('J.K.', 'Rowling'),
('Andy', 'Wachowski');

-- Inserting media-genre associations
INSERT INTO media_genre (genre_id, media_id) VALUES 
(1, 1), (3, 2), (4, 3), (1, 4), (2, 5),
(4, 6), (3, 7), (2, 8), (4, 9), (1, 10),
(6, 11), (4, 12), (1, 13), (6, 14), (10, 15);

-- Inserting locations
INSERT INTO building (building_label) VALUES 
('Main Library'), ('Science Building'), ('Arts Building'), ('Social Sciences Building');

INSERT INTO location (building_num, loc_name, loc_aisle_num, loc_floor_num, genre_id) VALUES 
(1, 'Fiction Section', 2, 1, 1),
(1, 'Fantasy Section', 3, 1, 3),
(2, 'Movie Collection', NULL, 2, 2),
(2, 'Science Fiction Section', 1, 3, 2),
(3, 'Biography Section', 1, 2, 8),
(3, 'Romance Section', 3, 1, 5),
(4, 'History Section', 2, 2, 9),
(4, 'Mystery Section', 1, 1, 7),
(1, 'New Releases', NULL, 1, 1),
(1, 'Classic Literature', NULL, 1, 1),
(2, 'Adventure Section', 2, 1, 10),
(3, 'Magazine Rack', NULL, 3, 6),
(4, 'Thriller Section', 3, 2, 6);

-- Inserting copies
INSERT INTO copy (media_id, is_hardcover, is_large_print, location_id, added_by_user_id, added_date) VALUES 
(1, TRUE, FALSE, 1, 1, NOW()),
(2, FALSE, FALSE, 2, 1, NOW()),
(3, FALSE, FALSE, 3, 1, NOW()),
(4, TRUE, FALSE, 1, 2, NOW()),
(5, FALSE, FALSE, 2, 2, NOW()),
(6, FALSE, FALSE, 3, 3, NOW()),
(7, TRUE, FALSE, 1, 4, NOW()),
(8, FALSE, FALSE, 2, 4, NOW()),
(9, FALSE, FALSE, 3, 5, NOW()),
(10, TRUE, FALSE, 1, 6, NOW()),
(11, FALSE, FALSE, 2, 7, NOW()),
(12, FALSE, FALSE, 3, 7, NOW()),
(1, TRUE, FALSE, 1, 8, NOW()),
(1, FALSE, FALSE, 2, 9, NOW()),
(1, FALSE, FALSE, 2, 9, NOW()),
(1, FALSE, FALSE, 2, 9, NOW()),
(1, FALSE, FALSE, 2, 9, NOW()),
(1, FALSE, FALSE, 3, 10, NOW());

-- Inserting copy status
INSERT INTO copy_status (copy_id, is_reserved, is_loaned) VALUES 
(1, FALSE, FALSE),
(2, FALSE, FALSE),
(3, FALSE, FALSE),
(4, FALSE, FALSE),
(5, FALSE, FALSE),
(6, FALSE, FALSE),
(7, FALSE, FALSE),
(8, FALSE, FALSE),
(9, FALSE, FALSE),
(10, FALSE, FALSE),
(11, FALSE, FALSE),
(12, FALSE, FALSE),
(13, FALSE, FALSE),
(14, FALSE, FALSE),
(15, FALSE, FALSE);

UPDATE copy SET status_id = copy_id WHERE copy_id <= 15;
INSERT INTO copy_status (copy_id, is_reserved, is_loaned, is_damaged)
VALUES (15, FALSE, FALSE, TRUE);
UPDATE copy SET status_id = 16 WHERE copy_id = 15;

-- Inserting loans
INSERT INTO loan (copy_id, user_id, checkout_date, return_date, due_date) VALUES 
(1, 2, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY)),
(3, 3, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY)),
(5, 4, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY)),
(7, 5, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY)),
(9, 6, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY)),
(11, 7, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY)),
(13, 8, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY)),
(15, 9, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY)),
(16, 9, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY)),
(17, 9, NOW(), NULL, DATE_ADD(NOW(), INTERVAL 14 DAY));

-- Inserting reservations
INSERT INTO reservation (user_id, media_id, reservation_start, reservation_end) VALUES 
(1, 4, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(2, 5, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(3, 6, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(4, 7, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(5, 8, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(6, 9, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(7, 10, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(8, 11, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(9, 12, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY)),
(10, 13, NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY));

-- Inserting fine reasons
INSERT INTO fine_reason (reason_str) VALUES 
('Late Return'), ('Damage'), ('Lost Item'), ('Damage to Book Cover'), ('Overdue DVD'), ('Lost DVD'), ('Lost Magazine'), ('Torn Magazine Pages'), ('Late Magazine Return'), ('Missing Pages in Book');

-- Inserting fines
INSERT INTO fine (loan_id, fine_date, fine_amount, reason_id) VALUES 
(1, NOW(), 5.00, 1),
(2, NOW(), 2.50, 2),
(3, NOW(), 10.00, 3),
(4, NOW(), 3.00, 4),
(5, NOW(), 7.00, 5),
(6, NOW(), 15.00, 6);

-- Inserting payments
INSERT INTO payment (fine_id, pay_date, pay_amount, pay_method) VALUES 
(1, NOW(), 5.00, 'Credit Card'),
(2, NOW(), 2.50, 'Cash'),
(3, NOW(), 10.00, 'Credit Card');
