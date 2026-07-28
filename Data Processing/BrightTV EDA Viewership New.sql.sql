-- Databricks notebook source
    --I wanted to see the whole table before doing the analysis

SELECT * 
 FROM brighttvcasestudy.default.bright_tv_userprofiles;



 --Checking for duplicates in my data
 SELECT UserID,
        COUNT(*) AS duplicate_count
FROM brighttvcasestudy.default.bright_tv_userprofiles
GROUP BY UserID
HAVING COUNT(*) > 1;


 --How big is this data
 SELECT COUNT(*) AS number_of_rows,
        COUNT(DISTINCT UserID) AS number_Subs
    FROM brighttvcasestudy.default.bright_tv_userprofiles;

    --Are there any rows where UserId is NULL
    SELECT COUNT(*) AS cnt
    FROM brighttvcasestudy.default.bright_tv_userprofiles
    WHERE UserID is NULL;

     SELECT DISTINCT UserID
    FROM brighttvcasestudy.default.bright_tv_userprofiles;

----------------------------------------------------------
----Gender Checks
----------------------------------------------------------

SELECT DISTINCT Gender
FROM brighttvcasestudy.default.bright_tv_userprofiles;

SELECT COUNT(*)
FROM brighttvcasestudy.default.bright_tv_userprofiles
WHERE Gender=' '; 


-------------------Counting number of Subscribers with gender-------
SELECT COUNT(*) AS Cnt,
       COUNT(DISTINCT UserID) AS Subs,
    CASE
        WHEN Gender = ' ' THEN 'Unknown'
        WHEN Gender = 'None' THEN 'Unknown'
        WHEN Gender iLIKE 'Unknown' THEN 'Unknown' ELSE Gender END AS Gender

FROM brighttvcasestudy.default.bright_tv_userprofiles

        GROUP BY
    CASE
        WHEN Gender = ' ' THEN 'Unknown'
        WHEN Gender = 'None' THEN 'Unknown'
        WHEN Gender iLIKE 'Unknown' THEN 'Unknown' ELSE Gender END;

     
     -----------------------------------------------------------------
     --Race Checks
     -----------------------------------------------------------------

SELECT DISTINCT Race
FROM brighttvcasestudy.default.bright_tv_userprofiles;
     ---Checking the race and eliminating the other none,empty and other 
     SELECT DISTINCT  
         CASE
            WHEN Race IN('other') THEN 'None'
            WHEN Race= ' ' THEN 'None'
            ELSE Race
            END AS Ethnic_Group
FROM brighttvcasestudy.default.bright_tv_userprofiles;

--Checking number of rows that are empty on race column
SELECT COUNT(*) AS num_rows
FROM brighttvcasestudy.default.bright_tv_userprofiles
WHERE Race IS NULL;

-------------------------------------------------
--Provinces checks/other provinces are NUll
-------------------------------------------------
SELECT DISTINCT Province
FROM brighttvcasestudy.default.bright_tv_userprofiles;


SELECT DISTINCT 
       CASE 
        WHEN Province=' ' THEN 'Uncategorized'
        WHEN Province='None' THEN 'Uncategorized'
        ELSE Province
        END AS Region
FROM brighttvcasestudy.default.bright_tv_userprofiles;

SELECT DISTINCT 
       CASE 
        WHEN Province=' 'OR Province='None' THEN 'Uncategorized'
        ELSE Province
        END AS Region 
FROM brighttvcasestudy.default.bright_tv_userprofiles;


--------------------------------------------
---AGE Checks 
--------------------------------------------

SELECT MIN(Age) AS min_age,--- = 0
       MAX(Age) AS max_age -- = 114
FROM brighttvcasestudy.default.bright_tv_userprofiles;


SELECT COUNT(*) AS cnt
FROM brighttvcasestudy.default.bright_tv_userprofiles
WHERE age IS NULL;

----------------------------Viewership--------------------
SELECT * 
FROM brighttvcasestudy.default.bright_tv_viewership
LIMIT 15;

---------------------------------------------------------

--------------Counting the number of rows-------------------User ID is a foreign Key which we cannot count DISTINCT--------
SELECT COUNT(*) AS num_rows,
COUNT(COALESCE(UserID0,userid4)) AS subs
FROM brighttvcasestudy.default.bright_tv_viewership;

-----------------------------------------------------

SELECT COUNT(*) AS num_rows,
COUNT(COALESCE(UserID0,userid4)) AS Active_subs,
COUNT(DISTINCT COALESCE(UserID0,userid4)) AS Active_Users
FROM brighttvcasestudy.default.bright_tv_viewership;


------------Checking all the channels on the Channel Column----------
SELECT DISTINCT Channel2
FROM brighttvcasestudy.default.bright_tv_viewership;

SELECT DISTINCT 
      CASE 
         WHEN Channel2 IN ('SawSee', ' Sawsee') THEN 'SawSee'
         WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','SuperSport Live Events','Dstv Events 1') THEN 'LIVE Events'
         ELSE Channel2
         END AS TV_Channels
         FROM brighttvcasestudy.default.bright_tv_viewership;

---------------------------------------------------------------

WITH base AS (
      SELECT COALESCE(UserID0,userid4) AS userid 
      FROM brighttvcasestudy.default.bright_tv_viewership
),
processing AS(
SELECT 
      DAYNAME(RecordDate2) AS day_name,
      HOUR(RecordDate2) AS hour_of_day,
      MONTHNAME(RecordDate2) AS month_name
   FROM brighttvcasestudy.default.bright_tv_viewership
),

-----------------------------------------------------------
--Getting the month ID and TIME PART----------------------------------
viewership AS (

SELECT 
      COALESCE(UserID0,userid4) AS userid, 
     ---Dates
     TO_CHAR(RecordDate2,'yyyyMM') AS month_id, -- TO_CHAR(): Converts a date into a string &&& TO_DATE(): Converts a string into a date
     TO_DATE(RecordDate2) AS watch_Date, ---Is to extract the date from the timestamp in our table
    --- TIME(RecordDate2) AS watch_time,
     DAYNAME(RecordDate2) AS day_name,

     CASE 
        WHEN day_name IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
        END AS Days_of_the_Week,

      MONTHNAME(RecordDate2) AS month_name,

      CASE 
         WHEN Channel2 IN ('SawSee', ' Sawsee') THEN 'SawSee'
         WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','SuperSport Live Events','Dstv Events 1') THEN 'LIVE Events'
         ELSE Channel2
         END AS TV_Channels,

         date_format(RecordDate2, 'HH:mm:ss') AS Watch_Time,
          HOUR(RecordDate2) AS hour_of_day,

          CASE
           WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
           WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
           WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
           WHEN date_format(RecordDate2, 'HH:mm:ss') BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
      END AS TIME_OF_DAY,

ROUND(Hour(`Duration 2`) * 60 + minute(`Duration 2`) + second(`Duration 2`) / 60, 2) AS duration_minute,

           Date_FORMAT(`Duration 2`, 'HH:mm:ss') AS Duration,
       CASE 
           WHEN Date_FORMAT(`Duration 2`, 'HH:mm:ss') BETWEEN '00:00:00' AND '00:30:00' THEN '01. Low Usage'
           WHEN Date_FORMAT(`Duration 2`, 'HH:mm:ss') BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage'
               WHEN Date_FORMAT(`Duration 2`, 'HH:mm:ss') > '00:59:59' THEN '03. High Usage'
       END AS Duration_Category
       
   FROM brighttvcasestudy.default.bright_tv_viewership
)

SELECT * FROM viewership;

WITH user_profiles AS (
SELECT TRIM(CAST(UserID AS STRING)) AS UserID, 
CASE 
        WHEN Province=' ' THEN 'Uncategorized'
        WHEN Province='None' THEN 'Uncategorized'
        ELSE Province
        END AS Region,

         CASE
    WHEN age < 1 THEN 'Infant'
    WHEN age BETWEEN 1 AND 12 THEN 'Child'
    WHEN age BETWEEN 13 AND 17 THEN 'Teenager'
    WHEN age BETWEEN 18 AND 34 THEN 'Young Adult'
    WHEN age BETWEEN 35 AND 64 THEN 'Adult'
    WHEN age >= 65 THEN 'Pensioner'
       END AS age_groups,

CASE 
    WHEN (email IS NOT NULL) OR (email<>' ') OR (email NOT IN (' None' ))THEN 1
    ELSE 0
    END AS Email_flag,

    CASE
     WHEN `Social Media Handle` IS NOT NULL OR `Social Media Handle`=' 'OR `Social Media Handle`NOT IN (' None') THEN 1
     ELSE 0
     END AS SocialMedia_Flag,
      
      
        CASE
            WHEN Race IN('other') THEN 'None'
            WHEN Race= ' ' THEN 'None'
            ELSE Race
            END AS Ethnic_Group,


    CASE
        WHEN Gender = ' ' THEN 'Unknown'
        WHEN Gender = 'None' THEN 'Unknown'
        WHEN Gender iLIKE 'Unknown' THEN 'Unknown' ELSE Gender END AS Gender
FROM brighttvcasestudy.default.bright_tv_userprofiles
),

Viewership AS (
       SELECT 
      TRIM(CAST(COALESCE(UserID0,userid4) AS STRING)) AS UserID,
      TO_CHAR(RecordDate2,'yyyyMM') AS month_id, --TO_CHAR():converts a date into a string  &&& TO_DATE(): Converts a string into a date
     TO_DATE(RecordDate2) AS watch_Date, -- Is to extract the date from the timstamp in our table
    --- TIME(RecordDate2) AS watch_time,
   --  TO_CHAR(RecordDate2,'DD') AS day_of_Week,
     DAYNAME(RecordDate2) AS day_name,

     CASE 
        WHEN day_name IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
        END AS Days_of_the_Week,

      MONTHNAME(RecordDate2) AS month_name,

      CASE 
         WHEN Channel2 IN ('SawSee', ' Sawsee') THEN 'SawSee'
         WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport','SuperSport Live Events','Dstv Events 1') THEN 'LIVE Events'
         ELSE Channel2
         END AS TV_Channels,


         date_format(RecordDate2, 'HH:mm:ss') AS Watch_Time,
          HOUR(RecordDate2) AS hour_of_day,
           date_format(`Duration 2`, 'HH:mm:ss') AS Duration,

           ------------------------------------------------------------------
           ---Duration Backet
           ------------------------------------------------------------------- 
           CASE 
             WHEN (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`) + SECOND(`Duration 2`) / 60) < 5 THEN 'Very Short (<5 min)'
             WHEN (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`) + SECOND(`Duration 2`) / 60) >= 5 AND (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`) + SECOND(`Duration 2`) / 60) < 10 THEN 'Short (5-10 min)'
             WHEN (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`) + SECOND(`Duration 2`) / 60) >= 10 AND (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`) + SECOND(`Duration 2`) / 60) < 20 THEN 'Medium (10-20 min)'
             WHEN (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`) + SECOND(`Duration 2`) / 60) >= 20 AND (HOUR(`Duration 2`) * 60 + MINUTE(`Duration 2`) + SECOND(`Duration 2`) / 60) < 30 THEN 'Long (20-30 min)'
             ELSE 'Very Long (30+ min)'
           END AS Duration_Bucket

        
       FROM brighttvcasestudy.default.bright_tv_viewership

)
SELECT 
A.*,
B.Region,
B.Age_groups,
B.Ethnic_Group,
B.Email_flag,
B.Gender
FROM viewership AS A LEFT JOIN user_profiles AS B ON A.UserID=B.UserID;
----------------------------------------------------------------


------------------------VISUALIZATION--------------------------------------------------
----------------------------------------------------------------------------------------
SELECT COUNT(UserID) AS Total_Subs
FROM brighttvcasestudy.brighttv.bright_tv_user_profiles;




