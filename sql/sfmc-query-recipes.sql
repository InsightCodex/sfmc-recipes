/* 1. SYNTAX ORDER (Logical Processing) */
-- FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY

/* 2. FILTERING & SELECTION */
-- NOTE: SFMC use 'TOP' instead of 'LIMIT'
SELECT TOP 100 * FROM [Member_Master] WHERE Status = 'Active';

-- Checking for existence (Correlated Subquery)
SELECT * FROM [Orders] o 
WHERE EXISTS (SELECT 1 FROM [Customers] c WHERE c.SubscriberKey = o.SubscriberKey); 

-- Removing duplicates (Set-based)
SELECT DISTINCT SubscriberKey FROM [Email_Sends]; 

/* 3. CONDITIONAL LOGIC (CASE Expression) */
-- Essential for segmenting data or creating dynamic labels 
SELECT 
    SubscriberKey, 
    City,
    CASE
        WHEN City IS NULL THEN 'Unknown'
        WHEN City IN ('Melbourne', 'Geelong') THEN 'VIC'
        ELSE 'Other'
    END AS State_Label 
FROM [Member_Master];

/* 4. PATTERN MATCHING (LIKE Operator) */
SELECT SubscriberKey FROM [Data_Extension]
WHERE Email LIKE '%@gmail.com'       -- Ends with @gmail.com
  AND SubscriberKey LIKE 'ID_%'      -- Starts with ID_ 
  AND City LIKE '[A-M]%'             -- Starts with any char between A and M 
  AND PolicyNumber LIKE '[^0-9]%';   -- Does NOT start with a number 

/* 5. AGGREGATIONS & REPORTING */
-- NOTE: NULLs are ignored except in COUNT(*) 
SELECT 
    City, 
    COUNT(*) AS TotalRows,
    COUNT(Email) AS ValidEmails,
    SUM(AnnualSpend) AS TotalRevenue,
    AVG(AnnualSpend) AS AverageSpend
FROM [Member_Master]
GROUP BY City
HAVING COUNT(*) > 500; 

/* 6. JOINS (Data Integration) */
-- INNER JOIN: Common records 
-- LEFT JOIN: All from left table (Most common in SFMC sends) 
SELECT 
    sub.SubscriberKey, 
    s.EventDate AS SendTime
FROM [_Subscribers] sub
LEFT JOIN [_Sent] s ON sub.SubscriberKey = s.SubscriberKey;

/* 7. SET OPERATORS (UNION/INTERSECT/EXCEPT) */
-- UNION: Distinct combined 
-- UNION ALL: Includes duplicates (Faster, recommended for SFMC if distinct not needed) 
-- EXCEPT: Records in A but NOT in B 
SELECT Email FROM [Campaign_A]
EXCEPT
SELECT Email FROM [Exclusion_List]; 

/* 8. DEFENSIVE PROGRAMMING: NULL SAFETY */
-- ALWAYS use 'NOT EXISTS' instead of 'NOT IN' when subquery might contain NULLs 
-- This prevents the "empty set" issue in SQL Server
SELECT a.SubscriberKey
FROM [Audience_DE] a
WHERE NOT EXISTS (
    SELECT 1 FROM [Unsubscribe_List] u 
    WHERE u.SubscriberKey = a.SubscriberKey
); 

/* 9. SFMC SYSTEM DATA VIEWS (Examples) */
-- Querying 30-day engagement 
SELECT 
    s.SubscriberKey,
    s.JobID,
    c.EventDate AS ClickDate
FROM [_Sent] s
INNER JOIN [_Click] c ON s.SubscriberKey = c.SubscriberKey AND s.JobID = c.JobID
WHERE s.EventDate > DATEADD(day, -30, GETDATE());
