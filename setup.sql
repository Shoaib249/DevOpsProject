-- Database create
CREATE DATABASE IF NOT EXISTS flask_auth_db;

-- User create
CREATE USER IF NOT EXISTS 'flaskuser'@'localhost' IDENTIFIED BY 'trongPAss123!';

-- User ko permission dena
GRANT ALL PRIVILEGES ON flask_auth_db.* TO 'flaskuser'@'localhost';

-- Changes apply karna
FLUSH PRIVILEGES;

-- Database select karna
USE flask_auth_db;

-- Users table create karna
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255)
);
