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
