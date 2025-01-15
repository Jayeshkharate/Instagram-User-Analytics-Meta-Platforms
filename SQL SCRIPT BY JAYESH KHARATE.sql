---------------------------------------------------------------------------------------
-- SOCIAL MEDIA PROJECT
-- SUBMITTED BY --
-- JAYESH KHARATE MAY 2024 BATCH --
---------------------------------------------------------------------------------------
-- #OBJECTIVE ANSWERS#
------------------------------------------------------------------------------------------------------------------------------
-- OBJECTIVE QUESTION 1:

-- TO CHECK DUPLICATES:
-- users table
SELECT username, COUNT(*)
FROM users
GROUP BY username
HAVING COUNT(*) > 1;

-- photos table
SELECT image_url, user_id, COUNT(*)
FROM photos
GROUP BY image_url, user_id
HAVING COUNT(*) > 1;

-- comments table
SELECT comment_text, user_id, photo_id, COUNT(*)
FROM comments
GROUP BY comment_text, user_id, photo_id
HAVING COUNT(*) > 1;

-- likes table
SELECT user_id, photo_id, COUNT(*)
FROM likes
GROUP BY user_id, photo_id
HAVING COUNT(*) > 1;

-- follows table
SELECT follower_id, followee_id, COUNT(*)
FROM follows
GROUP BY follower_id, followee_id
HAVING COUNT(*) > 1;

-- tags table
SELECT tag_name, COUNT(*)
FROM tags
GROUP BY tag_name
HAVING COUNT(*) > 1;

-- photo_tags table
SELECT photo_id, tag_id, COUNT(*)
FROM photo_tags
GROUP BY photo_id, tag_id
HAVING COUNT(*) > 1;

-- TO REMOVE DUPLICATES:
DELETE FROM users
WHERE id NOT IN (
    SELECT MIN(id)
    FROM users
    GROUP BY username
);users

-- TO CHECK NULL:
-- users table
SELECT COUNT(*) AS null_count
FROM users
WHERE id IS NULL OR username IS NULL OR created_at IS NULL;

-- comments table
SELECT COUNT(*) AS null_count
FROM comments
WHERE comment_text IS NULL OR user_id IS NULL OR photo_id IS NULL OR created_at IS NULL;

-- likes table
SELECT COUNT(*) AS null_count
FROM likes
WHERE user_id IS NULL OR photo_id IS NULL OR created_at IS NULL;

-- photos table
SELECT COUNT(*) AS null_count
FROM photos
WHERE image_url IS NULL OR user_id IS NULL OR created_at IS NULL;

-- follows table
SELECT COUNT(*) AS null_count
FROM follows
WHERE follower_id IS NULL OR followee_id IS NULL OR created_at IS NULL;

-- tags table
SELECT COUNT(*) AS null_count
FROM tags
WHERE tag_name IS NULL OR created_at IS NULL;

-- photo_tags table
SELECT COUNT(*) AS null_count
FROM photo_tags
WHERE photo_id IS NULL OR tag_id IS NULL;

-- TO REMOVE NULL VALUES:
DELETE FROM users
WHERE username IS NULL OR created_at IS NULL;
---------------------------------------------------------------------------------------

-- OBJECTIVE QUESTION 2:

SELECT u.id, u.username,
    COALESCE(p.num_posts, 0) AS num_posts,
    COALESCE(l.num_likes, 0) AS num_likes,
    COALESCE(c.num_comments, 0) AS num_comments
FROM users u
LEFT JOIN (
    SELECT user_id, COUNT(*) AS num_posts
    FROM photos
    GROUP BY user_id
) p ON u.id = p.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS num_likes
    FROM likes
    GROUP BY user_id
) l ON u.id = l.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS num_comments
    FROM comments
    GROUP BY user_id
) c ON u.id = c.user_id;
---------------------------------------------------------------------------------------

-- OBJECTIVE QUESTION 3:

SELECT AVG(tag_count) AS avg_tags_per_post
FROM (
    SELECT photo_id, COUNT(tag_id) AS tag_count
    FROM photo_tags
    GROUP BY photo_id
) AS tag_counts;
---------------------------------------------------------------------------------------

-- OBJECTIVE QUESTION 4:

CREATE VIEW LikeCounts AS (SELECT photo_id, COUNT(*) AS likes
    FROM likes
    GROUP BY photo_id);
CREATE VIEW CommentCounts AS (SELECT photo_id, COUNT(*) AS comments
    FROM comments
    GROUP BY photo_id);
WITH UserEngagements AS (SELECT u.id, u.username,
           COUNT(p.id) AS total_posts,
           COALESCE(SUM(l.likes), 0) AS total_likes,
           COALESCE(SUM(c.comments), 0) AS total_comments,
		   (COALESCE(SUM(l.likes), 0) + COALESCE(SUM(c.comments), 0)) / COUNT(p.id) AS engagement_rate
    FROM users u
    LEFT JOIN photos p ON u.id = p.user_id
    LEFT JOIN LikeCounts l ON p.id = l.photo_id
    LEFT JOIN CommentCounts c ON p.id = c.photo_id
    GROUP BY u.id, u.username)
SELECT id, username,
       total_posts,
       total_likes,
       total_comments,
       engagement_rate,
       DENSE_RANK() OVER(ORDER BY engagement_rate desc) as user_rank
FROM UserEngagements
WHERE total_posts > 0;
---------------------------------------------------------------------------------------

-- OBJECTIVE QUESTION 5:

-- most followers
SELECT u.id, u.username, COUNT(f.followee_id) AS follower_count
FROM users u
LEFT JOIN follows f ON u.id = f.followee_id
GROUP BY u.id, u.username
ORDER BY follower_count DESC
LIMIT 1; 

-- most following
SELECT u.id, u.username, COUNT(f.follower_id) AS following_count
FROM users u
LEFT JOIN follows f ON u.id = f.follower_id
GROUP BY u.id, u.username
ORDER BY following_count DESC
LIMIT 1; 
---------------------------------------------------------------------------------------

-- OBJECTIVES QUESTION 6:

WITH UserEngagements AS (
    SELECT u.id, u.username,
           COUNT(p.id) AS total_posts,
           COALESCE(SUM(l.likes), 0) AS total_likes,
           COALESCE(SUM(c.comments), 0) AS total_comments,
           (COALESCE(SUM(l.likes), 0) + COALESCE(SUM(c.comments), 0)) / COUNT(p.id) AS engagement_rate
    FROM users u
    LEFT JOIN photos p ON u.id = p.user_id
    LEFT JOIN LikeCounts l ON p.id = l.photo_id
    LEFT JOIN CommentCounts c ON p.id = c.photo_id
    GROUP BY u.id, u.username
)
SELECT id, username,
       total_posts,
       total_likes,
       total_comments,
       CASE 
           WHEN total_posts > 0 THEN engagement_rate
           ELSE 0
       END AS avg_engagement_rate_per_post
FROM UserEngagements
ORDER BY avg_engagement_rate_per_post DESC;

-- OR

SELECT 
    u.id AS user_id,
    u.username,
    COUNT(p.id) AS total_posts,
    COALESCE(SUM(like_count + comment_count), 0) AS total_engagements,
    COALESCE(f.follower_count, 0) AS follower_count,
    CASE 
        WHEN COUNT(p.id) = 0 OR COALESCE(f.follower_count, 0) = 0 THEN 0
        ELSE (COALESCE(SUM(like_count + comment_count), 0) / COUNT(p.id)) / COALESCE(f.follower_count, 0)
    END AS avg_engagement_rate
FROM 
    users u
LEFT JOIN 
    photos p ON u.id = p.user_id
LEFT JOIN 
    (SELECT 
         photo_id, 
         COUNT(*) AS like_count 
     FROM 
         likes 
     GROUP BY 
         photo_id
    ) l ON p.id = l.photo_id
LEFT JOIN 
    (SELECT 
         photo_id, 
         COUNT(*) AS comment_count 
     FROM 
         comments 
     GROUP BY 
         photo_id
    ) c ON p.id = c.photo_id
LEFT JOIN 
    (SELECT 
         followee_id, 
         COUNT(*) AS follower_count 
     FROM 
         follows 
     GROUP BY 
         followee_id
    ) f ON u.id = f.followee_id
GROUP BY 
    u.id, u.username, f.follower_count
ORDER BY 
    avg_engagement_rate DESC;
---------------------------------------------------------------------------------------  
    
-- OBJECTIVE QUESTION 7:

SELECT u.id, u.username
FROM users u
LEFT JOIN likes l ON u.id = l.user_id
WHERE l.user_id IS NULL;
----------------------------------------------------------------------------------------

-- OBJECTIVE QUESTION 8:

-- MOST USED TAGS:
SELECT 
    t.tag_name, 
    COUNT(pt.photo_id) AS tag_usage_count
FROM 
    tags t
JOIN 
    photo_tags pt ON t.id = pt.tag_id
GROUP BY 
    t.tag_name
ORDER BY 
    tag_usage_count DESC;

-- USER SEGMENT
SELECT 
    u.id AS user_id,
    u.username, 
    t.tag_name
FROM 
    users u
JOIN 
    likes l ON u.id = l.user_id
JOIN 
    photos p ON l.photo_id = p.id
JOIN 
    photo_tags pt ON p.id = pt.photo_id
JOIN 
    tags t ON pt.tag_id = t.id
GROUP BY 
    t.tag_name,u.username,u.id;
---------------------------------------------------------------------------------------
    
-- OBJECTIVE QUESTION 9:

  WITH photo_counts AS (SELECT user_id,COUNT(id) AS photo_count
    FROM photos
    GROUP BY user_id),
comment_counts AS (SELECT user_id,COUNT(id) AS comment_count
    FROM comments
    GROUP BY user_id),
like_counts AS (SELECT user_id,COUNT(photo_id) AS like_count
    FROM likes
    GROUP BY user_id),
user_activity AS (SELECT u.id AS user_id,u.username,
        COALESCE(pc.photo_count, 0) AS photo_count,
        COALESCE(cc.comment_count, 0) AS comment_count,
        COALESCE(lc.like_count, 0) AS like_count
    FROM users u
    LEFT JOIN photo_counts pc ON u.id = pc.user_id
    LEFT JOIN comment_counts cc ON u.id = cc.user_id
    LEFT JOIN like_counts lc ON u.id = lc.user_id)
SELECT user_id,username,photo_count AS photos,comment_count AS comments,like_count AS likes,
    CASE
        WHEN photo_count > 0 THEN 'Photo'
        WHEN comment_count > 0 THEN 'Comment'
        WHEN like_count > 0 THEN 'Like'
        ELSE 'None'
    END AS content_type
FROM user_activity
ORDER BY content_type;   
------------------------------------------------------------------------------------------------------------------------------
 
-- OBJECTIVE QUESTION 10:

SELECT 
u.id as user_id, u.username,
COALESCE(l.likes_count, 0) AS likes_count,
COALESCE(c.comments_count, 0) AS comments_count,
COALESCE(t.tags_count, 0) AS tags_count
FROM users u
LEFT JOIN (SELECT user_id, COUNT(*) AS likes_count FROM likes GROUP BY user_id) l ON u.id = l.user_id
LEFT JOIN (SELECT user_id, COUNT(*) AS comments_count FROM comments GROUP BY user_id) c ON u.id = c.user_id
LEFT JOIN (SELECT tag_id, COUNT(*) AS tags_count FROM photo_tags GROUP BY tag_id) t ON u.id = t.tag_id;
---------------------------------------------------------------------------------------------------------

-- OBJECTIVE QUESTION 11:

WITH EngagementCounts AS (
    SELECT u.id, u.username,
           COUNT(DISTINCT l.user_id) AS total_likes,
           COUNT(DISTINCT c.id) AS total_comments,
           COUNT(DISTINCT t.tag_id) AS total_tags,
           COUNT(DISTINCT l.user_id) + COUNT(DISTINCT c.id) + COUNT(DISTINCT t.tag_id) AS total_engagement
    FROM users u
    LEFT JOIN photos p ON u.id = p.user_id
    LEFT JOIN likes l ON p.id = l.photo_id AND l.created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
    LEFT JOIN comments c ON p.id = c.photo_id AND c.created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
    LEFT JOIN photo_tags t ON p.id = t.photo_id
    GROUP BY u.id, u.username
)
SELECT id, username, total_likes, total_comments, total_tags, total_engagement,
       RANK() OVER (ORDER BY total_engagement DESC) AS engagement_rank
FROM EngagementCounts
ORDER BY engagement_rank;
------------------------------------------------------------------------------------------------------------------------------

-- OBJECTIVE QUESTION 12:

WITH TagAverageLikes AS (
    SELECT t.tag_name,AVG(likes_count.likes) AS avg_likes
    FROM tags t
    JOIN photo_tags pt ON t.id = pt.tag_id
    JOIN photos p ON pt.photo_id = p.id
    JOIN (SELECT photo_id, COUNT(*) AS likes
		  FROM likes
		  GROUP BY photo_id) AS likes_count ON p.id = likes_count.photo_id
    GROUP BY t.tag_name)
SELECT tag_name,avg_likes
FROM TagAverageLikes
ORDER BY avg_likes DESC
LIMIT 10; 
------------------------------------------------------------------------------------------------------------------------------

-- OBJECTIVE QUESTION 13:

SELECT 
    u.username AS follower,
    u2.username AS followee
FROM 
    follows f1
JOIN 
    follows f2 ON f1.follower_id = f2.followee_id AND f1.followee_id = f2.follower_id
JOIN 
    users u ON f1.follower_id = u.id
JOIN 
    users u2 ON f1.followee_id = u2.id
WHERE 
    f2.created_at > f1.created_at;
    
-- OR

SELECT 
    u1.username AS follower_username
FROM 
    follows f1
JOIN 
    follows f2 ON f1.follower_id = f2.followee_id 
              AND f1.followee_id = f2.follower_id
JOIN 
    users u1 ON f1.follower_id = u1.id
WHERE 
    f1.created_at > f2.created_at;
------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- #SUBJECTIVE ANSWERS#
------------------------------------------------------------------------------------------------------------------------------
-- SUBJECTIVE QUESTION 1:

WITH user_activity AS (SELECT u.id AS user_id,u.username,
        IFNULL(photo_counts.total_photos, 0) AS total_photos,
        IFNULL(comment_counts.total_comments, 0) AS total_comments,
        IFNULL(like_counts.total_likes_given, 0) AS total_likes_given,
        IFNULL(follower_counts.total_followers, 0) AS total_followers,
        IFNULL(following_counts.total_following, 0) AS total_following,
        (IFNULL(photo_counts.total_photos, 0) +
            IFNULL(comment_counts.total_comments, 0) +
            IFNULL(like_counts.total_likes_given, 0)  +
            IFNULL(follower_counts.total_followers, 0)  +
            IFNULL(following_counts.total_following, 0) ) AS engagement_score
    FROM users u
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_photos FROM photos GROUP BY user_id) photo_counts ON u.id = photo_counts.user_id
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_comments FROM comments GROUP BY user_id) comment_counts ON u.id = comment_counts.user_id
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_likes_given FROM likes GROUP BY user_id) like_counts ON u.id = like_counts.user_id
    LEFT JOIN(SELECT followee_id AS user_id, COUNT(*) AS total_followers FROM follows GROUP BY followee_id) follower_counts ON u.id = follower_counts.user_id
    LEFT JOIN(SELECT follower_id AS user_id, COUNT(*) AS total_following FROM follows GROUP BY follower_id) following_counts ON u.id = following_counts.user_id),
ranked_users AS (SELECT user_id,username,engagement_score,RANK() OVER (ORDER BY engagement_score DESC) AS user_rank
    FROM user_activity)
SELECT user_id,username,engagement_score,user_rank
FROM ranked_users
WHERE user_rank = 1;
------------------------------------------------------------------------------------------------------------------------------

-- SUBJECTIVE QUESTION 2:

WITH user_activity AS (SELECT u.id AS user_id,u.username,
        IFNULL(photo_counts.total_photos, 0) AS total_photos,
        IFNULL(comment_counts.total_comments, 0) AS total_comments,
        IFNULL(like_counts.total_likes_given, 0) AS total_likes_given,
        IFNULL(follower_counts.total_followers, 0) AS total_followers,
        IFNULL(following_counts.total_following, 0) AS total_following,
        (IFNULL(photo_counts.total_photos, 0) +
            IFNULL(comment_counts.total_comments, 0) +
            IFNULL(like_counts.total_likes_given, 0)  +
            IFNULL(follower_counts.total_followers, 0)  +
            IFNULL(following_counts.total_following, 0) ) AS engagement_score
    FROM users u
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_photos FROM photos GROUP BY user_id) photo_counts ON u.id = photo_counts.user_id
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_comments FROM comments GROUP BY user_id) comment_counts ON u.id = comment_counts.user_id
    LEFT JOIN(SELECT user_id, COUNT(*) AS total_likes_given FROM likes GROUP BY user_id) like_counts ON u.id = like_counts.user_id
    LEFT JOIN(SELECT followee_id AS user_id, COUNT(*) AS total_followers FROM follows GROUP BY followee_id) follower_counts ON u.id = follower_counts.user_id
    LEFT JOIN(SELECT follower_id AS user_id, COUNT(*) AS total_following FROM follows GROUP BY follower_id) following_counts ON u.id = following_counts.user_id),
ranked_users AS (SELECT user_id,username,engagement_score,RANK() OVER (ORDER BY engagement_score ASC) AS user_rank
    FROM user_activity)
SELECT user_id,username,engagement_score,user_rank
FROM ranked_users
WHERE user_rank = '1';
------------------------------------------------------------------------------------------------------------------------------

-- SUBJECTIVE QUESTION 3:

SELECT
    t.tag_name,
    COUNT(pt.photo_id) AS total_posts,
    COALESCE(SUM(likes.total_likes), 0) AS total_likes,
    COALESCE(SUM(comments.total_comments), 0) AS total_comments,
    (COALESCE(SUM(likes.total_likes), 0) + COALESCE(SUM(comments.total_comments), 0)) / COUNT(pt.photo_id) AS average_engagement
FROM
    tags t
JOIN
    photo_tags pt ON t.id = pt.tag_id
LEFT JOIN
    (SELECT photo_id, COUNT(*) AS total_likes FROM likes GROUP BY photo_id) likes ON pt.photo_id = likes.photo_id
LEFT JOIN
    (SELECT photo_id, COUNT(*) AS total_comments FROM comments GROUP BY photo_id) comments ON pt.photo_id = comments.photo_id
GROUP BY
    t.tag_name
ORDER BY
    average_engagement DESC
LIMIT 10;
------------------------------------------------------------------------------------------------------------------------------

-- SUBJECTIVE QUESTION 4:

SELECT
    DATE_FORMAT(p.created_dat, '%H') AS hour_of_day,
    DAYNAME(p.created_dat) AS day_of_week,
    COUNT(p.id) AS total_posts,
    COALESCE(SUM(likes.total_likes), 0) AS total_likes,
    COALESCE(SUM(comments.total_comments), 0) AS total_comments,
    (COALESCE(SUM(likes.total_likes), 0) + COALESCE(SUM(comments.total_comments), 0)) / COUNT(p.id) AS average_engagement
FROM
    photos p
LEFT JOIN
    (SELECT photo_id, COUNT(*) AS total_likes FROM likes GROUP BY photo_id) likes ON p.id = likes.photo_id
LEFT JOIN
    (SELECT photo_id, COUNT(*) AS total_comments FROM comments GROUP BY photo_id) comments ON p.id = comments.photo_id
GROUP BY
    hour_of_day
ORDER BY
    average_engagement DESC;
------------------------------------------------------------------------------------------------------------------------------
    
-- SUBJECTIVE QUESTION 5:

SELECT 
    u.id AS user_id,
    u.username,
    COUNT(f.follower_id) AS follower_count,
    COALESCE(SUM(likes.total_likes), 0) AS total_likes,
    COALESCE(SUM(comments.total_comments), 0) AS total_comments,
    COALESCE(SUM(likes.total_likes), 0) + COALESCE(SUM(comments.total_comments), 0) AS total_engagement,
    CASE WHEN COUNT(f.follower_id) > 0 THEN 
        (COALESCE(SUM(likes.total_likes), 0) + COALESCE(SUM(comments.total_comments), 0)) / COUNT(f.follower_id)
    ELSE 0 END AS engagement_rate
FROM 
    users u
LEFT JOIN 
    follows f ON u.id = f.followee_id
LEFT JOIN 
    (SELECT photo_id, COUNT(*) AS total_likes FROM likes GROUP BY photo_id) likes
    ON u.id = (SELECT user_id FROM photos WHERE id = likes.photo_id)
LEFT JOIN 
    (SELECT photo_id, COUNT(*) AS total_comments FROM comments GROUP BY photo_id) comments 
    ON u.id = (SELECT user_id FROM photos WHERE id = comments.photo_id)
GROUP BY 
    u.id, u.username
ORDER BY 
    engagement_rate DESC, follower_count DESC
    LIMIT 10;
------------------------------------------------------------------------------------------------------------------------------

-- SUBJECTIVE QUESTION 6:

SELECT 
    u.id AS user_id,
    u.username,
    COALESCE(SUM(likes_count), 0) AS total_likes,
    COALESCE(SUM(comments_count), 0) AS total_comments,
    COALESCE(COUNT(DISTINCT p.id), 0) AS total_photos,
    CASE 
        WHEN COALESCE(COUNT(DISTINCT p.id), 0) = 0 THEN 0 
        ELSE (COALESCE(SUM(likes_count), 0) + COALESCE(SUM(comments_count), 0)) / COALESCE(COUNT(DISTINCT p.id), 1) 
    END AS engagement_rate,
    CASE 
        WHEN COALESCE(COUNT(DISTINCT p.id), 0) = 0 THEN 'Low'
        WHEN (COALESCE(SUM(likes_count), 0) + COALESCE(SUM(comments_count), 0)) / COALESCE(COUNT(DISTINCT p.id), 1) > 150 THEN 'High'
        WHEN (COALESCE(SUM(likes_count), 0) + COALESCE(SUM(comments_count), 0)) / COALESCE(COUNT(DISTINCT p.id), 1) BETWEEN 100 AND 150 
        THEN 'Medium'
        ELSE 'Low'
    END AS engagement_level
FROM users u
LEFT JOIN (SELECT user_id, COUNT(*) AS likes_count FROM likes GROUP BY user_id) l ON u.id = l.user_id
LEFT JOIN (SELECT user_id, COUNT(*) AS comments_count FROM comments GROUP BY user_id) c ON u.id = c.user_id
LEFT JOIN photos p ON u.id = p.user_id
GROUP BY u.id, u.username
ORDER BY engagement_rate DESC;
--------------------------------------------------------------





    
