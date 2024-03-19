-- Active loans for a user

BEGIN
    SELECT COUNT(*) AS active_loans_count
    FROM loan
    WHERE user_id = userId;
END //
DELIMITER ;

-- How many reservations exist for some media?

CREATE PROCEDURE GetReservationsForBook (
    IN mediaTitle VARCHAR(255)
)
BEGIN
    SELECT COUNT(*) AS reservation_count
    FROM reservation
    JOIN media ON reservation.media_id = media.media_id
    WHERE media.title = mediaTitle;
END;

-- Media created by author

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
END;

-- Fines per USER

CREATE PROCEDURE GetOutstandingFinesForUser (
    IN userId INT
)
BEGIN
    SELECT f.*
    FROM fine f
    JOIN loan l ON f.loan_id = l.loan_id
    WHERE l.user_id = userId
    AND f.is_paid = 0;
END;

-- Location of genre

CREATE PROCEDURE GetLibraryLocationForGenre (
    IN genreName VARCHAR(255)
)
BEGIN
    SELECT location.*
    FROM location
    JOIN genre ON location.genre_id = genre.genre_id
    WHERE genre.genre_name = genreName;
END;

-- Increase the amount of each fine by 0.25 cents every day
CREATE EVENT calculate_fine_event
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    UPDATE fine
    SET fine_amount = (fine_amount + (0.25 * (DATEDIFF(NOW(), fine_date))))
    WHERE is_paid = FALSE;
END;

-- Generate list of email adresses for users whose loans will expire in 24hrs
CREATE PROCEDURE loans_expiring_in_24hs()

BEGIN
    SELECT l.user_id, u.user_email, l.loan_id
    FROM loan l JOIN user u ON l.user_id = u.user_id
    WHERE DATEDIFF(due_date, now()) <= 1;
END;

-- Expired loans but not returned
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

-- List of users with fines exceeding $10
CREATE PROCEDURE users_in_debt()
BEGIN
<<<<<<< patch-5
    SELECT u.user_id, sum(fine_amount) AS outstanding_fine
    FROM fine f
    JOIN user u ON f.user_id = u.user_id
    WHERE is_paid = FALSE
    GROUP BY u.user_id
    HAVING outstanding_fine > 10;
END //

-- Remove reservations that have been held for 48 hours without being picked up, as well as activate any new reservations
CREATE PROCEDURE process_reservations()
BEGIN
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
        WHERE r2.media_id = r.media_id
        AND r2.is_active = FALSE
        AND r2.reservation_start < r.reservation_start
    );

    -- Update reservations based on the temporary table
    UPDATE reservation r1
    JOIN tmp_reservations tmp ON r1.reservation_id = tmp.reservation_id
    SET r1.is_active = TRUE,
        r1.reservation_end = DATE_ADD(NOW(), INTERVAL 2 DAY);

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS tmp_reservations;
END //

-- Run reservation process every day
CREATE EVENT process_reservations_event
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL process_reservations();
END //
