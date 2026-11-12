-- 1. بناء الجداول الأساسية
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password BINARY(64) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    username VARCHAR(50) UNIQUE NOT NULL,
    bio VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Follows (
    follow_id INT AUTO_INCREMENT PRIMARY KEY,
    follower_id INT,
    following_id INT,
    FOREIGN KEY (follower_id) REFERENCES Users(user_id),
    FOREIGN KEY (following_id) REFERENCES Users(user_id)
);

CREATE TABLE Tweets (
    tweet_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    content VARCHAR(280) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    tweet_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (tweet_id) REFERENCES Tweets(tweet_id)
);

-- 2. برمجة الوظائف (Stored Procedures)
CREATE PROCEDURE createAccount(
    IN p_email VARCHAR(100),
    IN p_password VARCHAR(100),
    IN p_username VARCHAR(50),
    IN p_bio VARCHAR(255)
)
BEGIN
    INSERT INTO Users (email, password) 
    VALUES (p_email, MD5(p_password));
    
    INSERT INTO Profiles (user_id, username, bio) 
    VALUES (LAST_INSERT_ID(), p_username, p_bio);
END;

CREATE PROCEDURE User_Follow(
    IN p_follower_username VARCHAR(50),
    IN p_following_username VARCHAR(50)
)
BEGIN
    DECLARE v_follower_id INT;
    DECLARE v_following_id INT;
    
    SELECT user_id INTO v_follower_id FROM Profiles WHERE username = p_follower_username;
    SELECT user_id INTO v_following_id FROM Profiles WHERE username = p_following_username;
    
    INSERT INTO Follows (follower_id, following_id) 
    VALUES (v_follower_id, v_following_id);
END;

-- 3. تجربة النظام والاستعلام
CALL createAccount('sara@email.com', 'Pass1234', 'sara_dev', 'مطور قواعد بيانات');
CALL createAccount('noura@email.com', 'Secret99', 'noura_sa', 'مهتمة بالتقنية');
CALL User_Follow('noura_sa', 'sara_dev');

INSERT INTO Tweets (user_id, content) VALUES (1, 'أول تغريدة لي في مشروعي البرمجي!');
INSERT INTO Tweets (user_id, content) VALUES (1, 'ختمت دورة قواعد البيانات في منصة سطر بنجاح');

SELECT p.username AS 'اسم المستخدم', COUNT(t.tweet_id) AS 'عدد التغريدات'
FROM Profiles p
JOIN Tweets t ON p.user_id = t.user_id
WHERE p.username = 'sara_dev'
GROUP BY p.username;
