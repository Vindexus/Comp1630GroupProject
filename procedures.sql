USE comp_1630_project;
-- How many active loans are there?
SELECT COUNT(*) FROM loan WHERE return_date IS NULL;

-- Dynamically set the due date of a loan based on the user's types
DROP TRIGGER IF EXISTS LoanDueDate;
DELIMITER $$
CREATE TRIGGER LoanDueDate 
BEFORE INSERT ON loan
FOR EACH ROW
BEGIN
    -- Student or faculty get 30 days, everyone else gets 15 days
    SET NEW.due_date = (SELECT CASE WHEN is_student OR is_faculty THEN DATE_ADD(NOW(), INTERVAL 30 DAY) ELSE DATE_ADD(NOW(), INTERVAL 15 DAY) END
    FROM user
    WHERE user_id = NEW.user_id);

    -- Create a new status for that copy. Keep all previous status values the same, and change is_lost and is_loaned values
    INSERT INTO copy_status (copy_id, status_date, is_damaged, is_lost, is_reserved, is_loaned, triggering_user_id)
    SELECT NEW.copy_id, NOW(), recent.is_damaged, FALSE, recent.is_reserved, TRUE, NEW.user_id
    FROM copy_status recent
    WHERE copy_id = NEW.copy_id
    ORDER BY status_date DESC
    LIMIT 1;
END;
$$
DELIMITER ;


-- List all media for a genre given the genre's name. Priority is given to media who have that specific genre ranked higher on their list of genres
SELECT m.title, g.genre_name, mg.sort_order
FROM media m
JOIN media_genre mg
ON mg.media_id = m.media_id
JOIN genre g
ON g.genre_id = mg.genre_id
WHERE g.genre_name = "Fantasy"
ORDER BY mg.sort_order ASC, m.title ASC;

-- For Media #1, find the next reservation for it that isn't over yet
SELECT reservation_id, user_fname, user_lname, user_email, media.title, media.media_id
FROM media, reservation, user
WHERE media.media_id = 1
AND reservation.media_id = media.media_id
AND reservation.reservation_end IS NOT NULL
AND reservation.reservation_end < NOW()
AND reservation.reservation_start IS NOT NULL
ORDER BY reservation.created_date ASC
LIMIT 1;

-- How many items are out on loan right now to users who are students?
SELECT COUNT(*) as 'Active Loans to Students'
FROM user u, loan l
WHERE l.user_id = u.user_id
AND l.return_date IS NULL
AND u.is_student = TRUE;

-- Get a list all copies currently marked as damaged
SELECT m.title, cs.*
FROM copy_status cs
JOIN copy c
ON c.status_id = cs.status_id
JOIN media m
ON m.media_id = c.media_id
WHERE is_damaged = 1
ORDER BY status_date DESC;

-- Returns whether a current user can check out books, based on their type, loans, and fines
DROP PROCEDURE IF EXISTS UserCanCheckout;
DELIMITER $$
CREATE PROCEDURE UserCanCheckout (IN $userId INT)
BEGIN
    DECLARE $defaultMaxLoans INT DEFAULT 3;
    DECLARE $studentFacultyMaxLoans INT DEFAULT 5;
    DECLARE $maxFines DOUBLE(9,2) DEFAULT 10;
    
    SELECT u.user_id, u.user_fname, u.user_lname, under_loan_limit, under_fine_limit, under_loan_limit AND under_fine_limit AS 'Can Check Out'
    FROM (
    SELECT u.user_id, active_loans < CASE WHEN is_student OR is_faculty THEN $studentFacultyMaxLoans ELSE $defaultMaxLoans END AS under_loan_limit, COALESCE(fine_total, 0) AS 'total_unnpaid_fines', COALESCE(fine_total, 0) < $maxFines AS under_fine_limit
    FROM user u
    JOIN (
        SELECT COUNT(*) as active_loans, user_id
        FROM loan
        WHERE user_id = $userId
        AND return_date IS NULL
        GROUP BY user_id
        ) al
    ON al.user_id = u.user_id
    LEFT JOIN (
        SELECT SUM(fine_amount) as fine_total, user_id
        FROM fine f, loan l
        WHERE user_id = $userId
        AND l.loan_id = f.loan_id
        AND f.is_paid = FALSE
        GROUP BY user_id
    ) ft
    ON ft.user_id = u.user_id
    WHERE u.user_id = $userId) limits
    JOIN user u
    ON u.user_id = limits.user_id;
END $$
DELIMITER ;

-- For answering "How many items do we have?"
DROP PROCEDURE IF EXISTS GetNumNonLostCopiesOfMedia;
DELIMITER //
CREATE PROCEDURE GetNumNonLostCopiesOfMedia(IN $mediaId INT)
BEGIN
    SELECT COUNT(*) as num
    FROM copy c
    JOIN copy_status cs
    ON cs.status_id = c.status_id
    WHERE cs.is_lost = 0
    AND c.media_id = $mediaId;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS GetMediaNextReservation;
DELIMITER //
CREATE PROCEDURE GetMediaNextReservation (IN $mediaId INT)
BEGIN
    SELECT reservation_id, user_fname, user_lname, user_email, media.title, media.media_id
    FROM media, reservation, user
    WHERE media.media_id = $mediaId
    AND reservation.media_id = media.media_id
    AND reservation.reservation_end IS NOT NULL
    AND reservation.reservation_end > NOW()
    AND reservation.reservation_start IS NOT NULL
    ORDER BY reservation.created_date ASC
    LIMIT 1;
END //
DELIMITER ;
    

-- Active loans for a user
DROP PROCEDURE IF EXISTS GetUserActiveLoansCount;
DELIMITER //
CREATE PROCEDURE GetUserActiveLoansCount (IN $userId INT)
BEGIN
    SELECT COUNT(*) AS active_loans_count
    FROM loan
    WHERE user_id = $userId
    AND return_date IS NULL;
END //
DELIMITER ;

-- How many reservations exist for some media?
DROP PROCEDURE IF EXISTS GetReservationsForMedia;
DELIMITER //
CREATE PROCEDURE GetReservationsForMedia (
    IN mediaTitle VARCHAR(255)
)
BEGIN
    SELECT COUNT(*) AS reservation_count
    FROM reservation
    JOIN media ON reservation.media_id = media.media_id
    WHERE media.title = mediaTitle;
END//
DELIMITER ;

-- Media created by author
DROP PROCEDURE IF EXISTS GetMediaByCreator;
DELIMITER //
CREATE PROCEDURE GetMediaByCreator (
    IN creatorFirstName VARCHAR(255),
    IN creatorLastName VARCHAR(255)
)
BEGIN
    SELECT media.title
    FROM media
    JOIN media_creators ON media.media_id = media_creators.media_id
    JOIN creator ON media_creators.creator_id = creator.creator_id
    WHERE creator.creator_fname = creatorFirstName
    AND creator.creator_lname = creatorLastName;
END//
DELIMITER ;

-- Fines per USER
DROP PROCEDURE IF EXISTS GetOutstandingFinesForUser;
DELIMITER //
CREATE PROCEDURE GetOutstandingFinesForUser (
    IN userId INT
)
BEGIN
    SELECT f.*
    FROM fine f
    JOIN loan l ON f.loan_id = l.loan_id
    WHERE l.user_id = userId
    AND f.is_paid = 0;
END//
DELIMITER ;

-- Location of genre
DROP PROCEDURE IF EXISTS GetLibraryLocationForGenre;
DELIMITER //
CREATE PROCEDURE GetLibraryLocationForGenre (
    IN genreName VARCHAR(255)
)
BEGIN
    SELECT location.*
    FROM location
    JOIN genre ON location.genre_id = genre.genre_id
    WHERE genre.genre_name = genreName;
END//
DELIMITER ;

-- Increase the amount of each fine by 0.25 cents every day
DROP EVENT IF EXISTS calculate_fine_event;
DELIMITER //
CREATE EVENT calculate_fine_event
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE fine
    SET fine_amount = (fine_amount + (0.25 * (DATEDIFF(NOW(), fine_date))))
    WHERE is_paid = FALSE;
END//
DELIMITER ;

-- Generate list of email adresses for users whose loans will expire in 24hrs
DROP PROCEDURE IF EXISTS loans_expiring_in_24hs;
DELIMITER //
CREATE PROCEDURE loans_expiring_in_24hs()
BEGIN
    SELECT l.user_id, u.user_email, l.loan_id
    FROM loan l JOIN user u ON l.user_id = u.user_id
    WHERE DATEDIFF(due_date, now()) <= 1;
END//
DELIMITER ;

-- Expired loans but not returned
DROP PROCEDURE IF EXISTS expired_unreturned_loans;
DELIMITER //
CREATE PROCEDURE expired_unreturned_loans()
BEGIN
    SELECT m.title, cs.copy_id, l.loan_id, u.user_id, u.user_email
    FROM copy_status cs
    JOIN loan l ON cs.copy_id = l.copy_id
    JOIN user u ON l.user_id = u.user_id
    JOIN copy cp ON cp.copy_id = cs.copy_id
    JOIN media m ON m.media_id = cp.media_id
    WHERE is_loaned = 1 AND DATEDIFF(NOW(), l.due_date) > 0;
END //
DELIMITER ;

-- List of users with fines exceeding $10
DROP PROCEDURE IF EXISTS users_in_debt;
DELIMITER //
CREATE PROCEDURE users_in_debt()
BEGIN
    SELECT u.user_id, sum(fine_amount) AS outstanding_fine
    FROM fine f
    JOIN user u ON f.user_id = u.user_id
    WHERE is_paid = FALSE
    GROUP BY u.user_id
    HAVING outstanding_fine > 10;
END //
DELIMITER ;

-- Remove reservations that have been held for 48 hours without being picked up, as well as activate any new reservations
DROP PROCEDURE IF EXISTS process_reservations;
DELIMITER //
CREATE PROCEDURE process_reservations()
BEGIN
    
    -- Update is_reserved in copy_status
    UPDATE copy_status cs
    JOIN reservation r ON cs.copy_id = r.copy_id
    SET cs.is_reserved = FALSE
    WHERE r.is_active = TRUE AND DATEDIFF(r.reservation_end, NOW()) < 0;
    
    -- Delete overdue reservations
    DELETE FROM reservation
    WHERE is_active = TRUE AND DATEDIFF(reservation_end, NOW()) < 0;

    -- Update reservations
    CREATE TEMPORARY TABLE tmp_reservations
    SELECT r.reservation_id
    FROM reservation r
    WHERE r.is_active = FALSE
    AND NOT EXISTS (
        SELECT 1
        FROM reservation r2
        WHERE r2.copy_id = r.copy_id
        AND r2.is_active = FALSE
        AND r2.created_date < r.created_date
    )
    AND NOT EXISTS (
        SELECT 1
        FROM copy_status cs
        WHERE cs.copy_id = r.copy_id
        AND cs.is_loaned = TRUE OR cs.is_lost = TRUE
    );

    -- Update reservations based on the temporary table
    UPDATE reservation r1
    JOIN tmp_reservations tmp ON r1.reservation_id = tmp.reservation_id
    JOIN copy_status cs ON cs.copy_id = r1.copy_id
    SET r1.is_active = TRUE,
        r1.reservation_start = NOW(),
        r1.reservation_end = DATE_ADD(NOW(), INTERVAL 2 DAY),
        cs.is_reserved = TRUE;

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS tmp_reservations;
END //
DELIMITER ;

-- Run reservation process every day
DROP EVENT IF EXISTS process_reservations_event;
DELIMITER //
CREATE EVENT process_reservations_event
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL process_reservations();
END//
DELIMITER ;

-- Check for is_lost status prior to making a reservation; proceed if not
DROP PROCEDURE IF EXISTS MakeReservation;
DELIMITER //
CREATE PROCEDURE MakeReservation(
IN p_user_id INT,
IN p_copy_id INT
)
BEGIN
    DECLARE v_lost_flag INT;

    -- Get the is_lost flag for the copy_id
    SELECT is_lost INTO v_lost_flag
    FROM copy_status
    WHERE copy_id = NEW.copy_id;

    -- Check if the item is lost, if so, raise an error
    IF lost_flag = TRUE THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot make a reservation for a lost item';
    ELSE
        INSERT INTO reservation (user_id, copy_id, created_date)
        VALUES (p_user_id, p_copy_id, NOW());
    END IF;
END//
DELIMITER ;

-- Find copy(ies) location based on the name of the error
DELIMITER //

CREATE PROCEDURE find_copy_locations(
    IN mediaTitle VARCHAR(255)
)
BEGIN
    SELECT l.building_num, l.loc_aisle_num, l.loc_floor_num
    FROM copy c
    JOIN location l ON c.location_id = l.location_id
    JOIN media m ON c.media_id = m.media_id
    WHERE m.title = mediaTitle;
END //

DELIMITER ;
