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
CALL GetNumNonLostCopiesOfMedia(1);

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

-- Run reservation process every day
CREATE EVENT process_reservations_event
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    CALL process_reservations();
END //

-- Check for is_lost status prior to making a reservation; proceed if not
CREATE PROCEDURE MakeReservation(
IN p_user_id INT,
IN p_copy_id INT,
)
BEGIN
    DECLARE v_lost_flag INT;

    -- Get the is_lost flag for the copy_id
    SELECT is_lost INTO lost_flag
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
END;
//
