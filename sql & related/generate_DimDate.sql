SET NOCOUNT ON;
DECLARE @StartDate DATE = '1990-01-01';
DECLARE @EndDate DATE = '2010-12-31';

-- Generate dates using a recursive CTE (works for 40-year range)
;WITH DateCTE AS (
    SELECT @StartDate AS [Date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [Date])
    FROM DateCTE
    WHERE [Date] < @EndDate
)
INSERT INTO DW.DimDate (
    DimDateKey,
    FullDate,
    [Year],
    Quarter,
    [Month],
    DayOfMonth,
    DayOfWeek,
    WeekOfYear,
    MonthName,
    DayName
)
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), [Date], 112)), -- YYYYMMDD as integer
    [Date],
    YEAR([Date]),
    DATEPART(QUARTER, [Date]),
    MONTH([Date]),
    DAY([Date]),
    (DATEPART(WEEKDAY, [Date]) + @@DATEFIRST - 2) % 7 + 1, -- Monday=1 to Sunday=7
    DATEPART(ISO_WEEK, [Date]), -- ISO-8601 week numbering
    DATENAME(MONTH, [Date]),
    DATENAME(WEEKDAY, [Date])
FROM DateCTE
OPTION (MAXRECURSION 0); -- Allow unlimited recursion