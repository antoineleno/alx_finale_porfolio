SET GLOBAL validate_password.policy = LOW;
SET GLOBAL validate_password.length = 6;

CREATE DATABASE IF NOT EXISTS roofmarket_db;
CREATE USER IF NOT EXISTS 'roofmarket_user'@'localhost' IDENTIFIED BY 'roofmarket_pwd';
GRANT ALL PRIVILEGES ON roofmarket_db.* TO 'roofmarket_user'@'localhost';
FLUSH PRIVILEGES;
