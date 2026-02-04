# SQL Data Modeling and Analytics Solutions

-- 1. Add a new facility with fixed values: Adds a new facility record with explicitly defined costs and maintenance values.
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

-- 2. Insert a new facility using the next available ID: Inserts a new facility while dynamically generating the next facid based on existing records.
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

-- 3. Update the initial outlay of a specific facility: Modifies the upfront cost of a facility identified by its facility ID.
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE facid = 1;

-- 4. Update facility costs based on another facility: Updates member and guest costs by referencing and adjusting the pricing of another facility.
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

-- 5. Delete all booking records: Removes all rows from the bookings table.
DELETE FROM cd.bookings;

-- 6. Delete a specific member: Deletes a single member record using a conditional filter.
DELETE FROM cd.members
WHERE memid = 37;

-- 7. Find facilities with relatively low member costs: Retrieves facilities where the member cost is positive but low compared to maintenance costs.
SELECT
    facid,
    name,
    membercost,
    monthlymaintenance
FROM cd.facilities
WHERE
    membercost > 0
    AND membercost < monthlymaintenance / 50;

-- 8. Find facilities related to tennis: Selects all facilities whose names contain the word ?Tennis?.
SELECT
    facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance
FROM cd.facilities
WHERE name LIKE '%Tennis%';

-- 9. Retrieve facilities with specific IDs: Filters facilities using a predefined list of facility IDs.
SELECT
    facid,
    name,
    membercost,
    guestcost,
    initialoutlay,
    monthlymaintenance
FROM cd.facilities
WHERE facid IN (1, 5);

-- 10. List members and their recommenders: Displays each member together with the member who recommended them using a self join.
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

-- 11. Combine member surnames and facility names: Uses a UNION to merge two different result sets into a single list.
SELECT surname
FROM cd.members
UNION
SELECT name
FROM cd.facilities;

-- 12. Find booking times for a specific member: Retrieves all booking start times for a member identified by first and last name.
SELECT
    bks.starttime
FROM cd.bookings AS bks
LEFT JOIN cd.members AS mems
    ON bks.memid = mems.memid
WHERE
    mems.firstname = 'David'
    AND mems.surname = 'Farrell';

-- 13. Find tennis court bookings on a specific day: Lists all tennis court bookings within a given date range.
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

-- 14. Identify members who recommended others: Finds distinct members who appear as recommenders for at least one other member.
SELECT DISTINCT
    recs.firstname,
    recs.surname
FROM cd.members AS mems
INNER JOIN cd.members AS recs
    ON recs.memid = mems.recommendedby
ORDER BY
    recs.surname,
    recs.firstname;

-- 15. Show members with their recommender names: Displays each member?s full name alongside their recommender?s full name using a subquery.
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

-- 16. Count how many members each person has recommended: Aggregates the number of referrals made by each recommending member.
SELECT
    recommendedby,
    COUNT(*)
FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;

-- 17. Calculate total booking slots per facility: Summarizes total usage of each facility based on booked time slots.
SELECT
    facid,
    SUM(slots) AS "Total Slots"
FROM cd.bookings
GROUP BY facid
ORDER BY facid;

-- 18. Calculate facility usage for a specific month: Measures facility usage during a specific date range.
SELECT
    facid,
    SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE
    starttime >= '2012-09-01'
    AND starttime < '2012-10-01'
GROUP BY facid
ORDER BY SUM(slots);

-- 19. Show monthly facility usage for a given year: Breaks down facility usage by month for analytical reporting.
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

-- 20. Count distinct members who made bookings: Determines how many unique members appear in the bookings table.
SELECT
    COUNT(DISTINCT memid)
FROM cd.bookings;

-- 21. Find each member?s first booking after a given date: Identifies the earliest booking date for each member within a time window.
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

-- 22. Display total member count using a window function: Adds the total row count to each result row without collapsing the dataset.
SELECT
    COUNT(*) OVER (),
    firstname,
    surname
FROM cd.members
ORDER BY joindate;

-- 23. Assign a sequential number to members: Ranks members chronologically based on their join date.
SELECT
    ROW_NUMBER() OVER (ORDER BY joindate),
    firstname,
    surname
FROM cd.members
ORDER BY joindate;

-- 24. Identify the most-used facility: Finds the facility with the highest total number of booked slots.
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

-- 25. Format member names: Concatenates surname and firstname into a single formatted string.
SELECT
    surname || ', ' || firstname
FROM cd.members;

-- 26. Find phone numbers with parentheses: Uses a regular expression to detect specific formatting patterns in phone numbers.
SELECT
    memid,
    telephone
FROM cd.members
WHERE telephone ~ '[()]'
ORDER BY memid;

-- 27. Count members by surname initial: Groups members alphabetically by the first letter of their surname.
SELECT
    SUBSTR(surname, 1, 1) AS letter,
    COUNT(*)
FROM cd.members
GROUP BY letter
ORDER BY letter;
