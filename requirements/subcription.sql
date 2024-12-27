-- Enable the Event Scheduler
use roofmarket_db;
SET GLOBAL event_scheduler = ON;

-- Drop the Event if it Already Exists
DROP EVENT IF EXISTS decrease_duration;

-- Create the Event to Decrease Duration and Delete Rows with 0 Duration
DELIMITER $$

CREATE EVENT decrease_duration
ON SCHEDULE EVERY 1 SECOND
DO
BEGIN
  -- Decrease Duration by 1 for Rows where Duration > 0
  UPDATE transaction
  SET duration = duration - 1,
      updated_at = NOW()
  WHERE duration > 0;

  -- Delete Rows where Duration Reaches 0
  DELETE FROM transaction
  WHERE duration <= 0;
END $$

DELIMITER ;
