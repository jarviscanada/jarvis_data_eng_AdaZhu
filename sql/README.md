# SQL Data Modeling and Analytics Project

This project focuses on designing a relational database schema for a club management system and implementing various SQL techniques to manipulate and analyze data. It covers everything from **Schema Definition (DDL)** to **complex analytical queries**, using PostgreSQL-compliant SQL.

---

## Project Overview

The goal of this project is to model a system that tracks:

- Club members  
- The facilities they use  
- The bookings they make  

The project is divided into two main phases:

1. **Data Modeling**  
   Creating the relational structure with appropriate primary keys, foreign keys, and constraints.

2. **Data Manipulation & Querying**  
   Solving real-world business questions using SQL.

---

## 1. Table Setup (DDL)

The database consists of three primary tables within the `cd` schema. Below are the SQL **Data Definition Language (DDL)** statements used to initialize the environment.

### Schema Relationships

The schema follows a classic relational model:

- **Members** can make multiple **Bookings**
- **Facilities** can be associated with multiple **Bookings**
- **Members** have a self-referencing relationship to support referrals

---

### Implementation

```sql
-- 1. Create Facilities Table
CREATE TABLE cd.facilities (
    facid INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    membercost NUMERIC NOT NULL,
    guestcost NUMERIC NOT NULL,
    initialoutlay NUMERIC NOT NULL,
    monthlymaintenance NUMERIC NOT NULL
);

-- 2. Create Members Table (includes self-reference for referrals)
CREATE TABLE cd.members (
    memid INTEGER PRIMARY KEY,
    surname VARCHAR(200) NOT NULL,
    firstname VARCHAR(200) NOT NULL,
    address VARCHAR(300),
    zipcode INTEGER,
    telephone VARCHAR(20),
    recommendedby INTEGER,
    joindate TIMESTAMP NOT NULL,
    CONSTRAINT fk_recommendedby
        FOREIGN KEY (recommendedby)
        REFERENCES cd.members(memid)
        ON DELETE SET NULL
);

-- 3. Create Bookings Table
CREATE TABLE cd.bookings (
    bookid INTEGER PRIMARY KEY,
    facid INTEGER NOT NULL,
    memid INTEGER NOT NULL,
    starttime TIMESTAMP NOT NULL,
    slots INTEGER NOT NULL,
    CONSTRAINT fk_facid
        FOREIGN KEY (facid)
        REFERENCES cd.facilities(facid),
    CONSTRAINT fk_memid
        FOREIGN KEY (memid)
        REFERENCES cd.members(memid)
);
```
## 2.Sql Queries

```sql
INSERT INTO cd.facilities (
    facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance
)
VALUES (
    9,
    'Spa',
    20,
    30,
    100000,
    800
);

INSERT INTO cd.facilities (
    facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance
)
SELECT
    (SELECT MAX(facid) FROM cd.facilities) + 1,
    'Spa',
    20,
    30,
    100000,
    800;

UPDATE cd.facilities
SET initialoutlay = 10000
WHERE facid = 1;

UPDATE cd.facilities AS facs
SET
    membercost = facs2.membercost * 1.1,
    guestcost  = facs2.guestcost * 1.1
FROM (
    SELECT *
    FROM cd.facilities
    WHERE facid = 0
) AS facs2
WHERE facs.facid = 1;

DELETE FROM cd.bookings;

DELETE FROM cd.members
WHERE memid = 37;

SELECT
    facid,
    name,
    membercost,
    monthlymaintenance
FROM cd.facilities
WHERE
    membercost > 0
    AND membercost < monthlymaintenance / 50;

SELECT
    facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance
FROM cd.facilities
WHERE name LIKE '%Tennis%';

SELECT
    facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance
FROM cd.facilities
WHERE facid IN (1, 5);

SELECT
    mems.firstname AS memfname,
    mems.surname   AS memsname,
    recs.firstname AS recfname,
    recs.surname   AS recsname
FROM cd.members AS mems
LEFT JOIN cd.members AS recs
    ON recs.memid = mems.recommendedby
ORDER BY
    mems.surname,
    mems.firstname;

SELECT surname
FROM cd.members
UNION
SELECT name
FROM cd.facilities;

SELECT
    bks.starttime
FROM cd.bookings AS bks
LEFT JOIN cd.members AS mems
    ON bks.memid = mems.memid
WHERE
    mems.firstname = 'David'
    AND mems.surname = 'Farrell';

SELECT
    bks.starttime AS start,
    facs.name     AS name
FROM cd.bookings AS bks
LEFT JOIN cd.facilities AS facs
    ON bks.facid = facs.facid
WHERE
    facs.name IN ('Tennis Court 1', 'Tennis Court 2')
    AND bks.starttime > '2012-09-21'
    AND bks.starttime < '2012-09-22'
ORDER BY
    bks.starttime;

SELECT DISTINCT
    recs.firstname,
    recs.surname
FROM cd.members AS mems
INNER JOIN cd.members AS recs
    ON recs.memid = mems.recommendedby
ORDER BY
    recs.surname,
    recs.firstname;

SELECT DISTINCT
    mems.firstname || ' ' || mems.surname AS member,
    (
        SELECT
            recs.firstname || ' ' || recs.surname
        FROM cd.members AS recs
        WHERE recs.memid = mems.recommendedby
    ) AS recommender
FROM cd.members AS mems
ORDER BY member;

SELECT
    recommendedby,
    COUNT(*)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;

SELECT
    facid,
    SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;

SELECT
    facid,
    SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE
    starttime >= '2012-09-01'
    AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY SUM(slots);

SELECT
    facid,
    EXTRACT(MONTH FROM starttime) AS month,
    SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime) = 2012
GROUP BY
    facid,
    month
ORDER BY
    facid,
    month;

SELECT
    COUNT(DISTINCT memid)
FROM cd.bookings;

SELECT
    mems.surname,
    mems.firstname,
    mems.memid,
    MIN(bks.starttime) AS starttime
FROM cd.bookings AS bks
INNER JOIN cd.members AS mems
    ON mems.memid = bks.memid
WHERE bks.starttime >= '2012-09-01'
GROUP BY
    mems.surname,
    mems.firstname,
    mems.memid
ORDER BY mems.memid;

SELECT
    COUNT(*) OVER (),
    firstname,
    surname
FROM cd.members
ORDER BY joindate;

SELECT
    ROW_NUMBER() OVER (ORDER BY joindate),
    firstname,
    surname
FROM cd.members
ORDER BY joindate;

SELECT
    facid,
    total
FROM (
    SELECT
        facid,
        SUM(slots) AS total,
        RANK() OVER (ORDER BY SUM(slots) DESC) AS rank
    FROM cd.bookings
    GROUP BY facid
) AS ranked
WHERE rank = 1;

SELECT
    surname || ', ' || firstname
FROM cd.members;

SELECT
    memid,
    telephone
FROM cd.members
WHERE telephone ~ '[()]'
ORDER BY memid;

SELECT
    SUBSTR(surname, 1, 1) AS letter,
    COUNT(*)
FROM cd.members
GROUP BY letter
ORDER BY letter;
```