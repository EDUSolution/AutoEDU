/*
Deployment script for HiEd_DW
This script deploys all objects to the Data warehouse for the EDU Solution
Script Managed by Kellyn Gorman, TSP with Microsoft EDU
*/

SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "HiEd_DW"
:setvar DefaultFilePrefix "HiEd_DW"
:setvar DefaultDataPath ""
:setvar DefaultLogPath ""

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF;
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
               QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [sys].[databases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
PRINT N'Creating [dbo].[DimAcademicLevel]...';


GO
CREATE TABLE [dbo].[DimAcademicLevel] (
    [AcademicLevelSK] INT          IDENTITY (1, 1) NOT NULL,
    [AcademicLevelAK] VARCHAR (2)  NOT NULL,
    [AcademicLevel]   VARCHAR (25) NOT NULL,
    CONSTRAINT [PK_AcademicLevel_AcademicLevelSK] PRIMARY KEY CLUSTERED ([AcademicLevelSK] ASC)
);


GO
PRINT N'Creating [dbo].[DimAcademicProgram]...';


GO
CREATE TABLE [dbo].[DimAcademicProgram] (
    [AcademicProgramSK] INT          IDENTITY (1, 1) NOT NULL,
    [AcademicProgramAK] VARCHAR (10) NOT NULL,
    [AcademicProgram]   VARCHAR (50) NOT NULL,
    [AcademicPlanAK]    VARCHAR (10) NOT NULL,
    [AcademicPlan]      VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_AcademicProgram_AcademicProgramSK] PRIMARY KEY CLUSTERED ([AcademicProgramSK] ASC)
);


GO
 PRINT N'Creating [dbo].[DimAdmitType]...';


GO
CREATE TABLE [dbo].[DimAdmitType] (
    [AdmitTypeSK] INT          IDENTITY (1, 1) NOT NULL,
    [AdmitTypeAK] VARCHAR (5)  NOT NULL,
    [AdmitType]   VARCHAR (75) NOT NULL,
    CONSTRAINT [PK_AdmitType_AdmiTypeSK] PRIMARY KEY CLUSTERED ([AdmitTypeSK] ASC)
);


GO
PRINT N'Creating [dbo].[DimApplicationSource]...';


GO
CREATE TABLE [dbo].[DimApplicationSource] (
    [ApplicationSourceSK] INT          IDENTITY (1, 1) NOT NULL,
    [ApplicationSourceAK] VARCHAR (3)  NOT NULL,
    [ApplicationSource]   VARCHAR (25) NOT NULL,
    CONSTRAINT [PK_ApplicationSource_ApplicationSourceSK] PRIMARY KEY CLUSTERED ([ApplicationSourceSK] ASC)
);


GO
PRINT N'Creating [dbo].[DimClass]...';


GO
CREATE TABLE [dbo].[DimClass] (
    [ClassSK]           INT          IDENTITY (1, 1) NOT NULL,
    [SubjectAK]         VARCHAR (10) NOT NULL,
    [CatalogAK]         VARCHAR (10) NOT NULL,
    [ClassSectionAK]    VARCHAR (5)  NOT NULL,
    [Title]             VARCHAR (50) NULL,
    [CreditHours]       INT          NULL,
    [InstructionModeAK] VARCHAR (35) NULL,
    CONSTRAINT [PK_Class_ClassSK] PRIMARY KEY CLUSTERED ([ClassSK] ASC)
);


GO
PRINT N'Creating [dbo].[DimDate]...';
 GO
CREATE TABLE [dbo].[DimDate] (
    [DateSK]                      INT          NOT NULL,
    [FullDate]                    DATETIME     NOT NULL,
    [Day]                         TINYINT      NOT NULL,
    [DayOfWeek]                   VARCHAR (9)  NOT NULL,
    [DayOfWeekNumber]             INT          NOT NULL,
    [DayOfWeekInMonth]            TINYINT      NOT NULL,
    [CalendarMonthNumber]         TINYINT      NOT NULL,
    [CalendarMonthName]           VARCHAR (9)  NOT NULL,
    [CalendarQuarterNumber]       TINYINT      NOT NULL,
    [CalendarQuarterName]         VARCHAR (6)  NOT NULL,
    [CalendarYearNumber]          INT          NOT NULL,
    [StandardDate]                VARCHAR (10) NULL,
    [WeekDayFlag]                 BIT          NOT NULL,
    [HolidayFlag]                 BIT          NOT NULL,
    [OpenFlag]                    BIT          NOT NULL,
    [FirstDayOfCalendarMonthFlag] BIT          NOT NULL,
    [LastDayOfCalendarMonthFlag]  BIT          NOT NULL,
    [HolidayText]                 VARCHAR (50) NULL,
    [Term]                        VARCHAR (10) NULL,
    [TermNumber]                  INT          NULL,
    [SchoolYear]                  INT          NULL,
    [TermAK]                      INT          NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateSK] ASC) WITH (FILLFACTOR = 90)
);


GO
PRINT N'Creating [dbo].[DimResidencyStatus]...';


GO
CREATE TABLE [dbo].[DimResidencyStatus] (
    [ResidencyStatusSK] INT          IDENTITY (1, 1) NOT NULL,
    [ResidencyStatusAK] CHAR (1)     NOT NULL,
    [ResidencyStatus]   VARCHAR (15) NOT NULL,
    CONSTRAINT [PK_ResidencyStatus_ResidencyStatusSK] PRIMARY KEY CLUSTERED ([ResidencyStatusSK] ASC)
);


GO
PRINT N'Creating [dbo].[DimStudent]...';

GO
CREATE TABLE [dbo].[DimStudent] (
    [StudentSK]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [StudentAK]   BIGINT       NOT NULL,
    [Gender]      VARCHAR (20) NULL,
    [Age]         INT          NULL,
    [City]        VARCHAR (75) NOT NULL,
    [StateAbbrev] VARCHAR (3)  NOT NULL,
    [PostalCode]  VARCHAR (15) NULL,
    [Active]      BIT          NULL,
    [AdmitTerm]   INT          NULL,
    CONSTRAINT [PK_Student_StudentSK] PRIMARY KEY CLUSTERED ([StudentSK] ASC)
);


GO
PRINT N'Creating [dbo].[EventDrivenEnrollmentDetails]...';


GO
CREATE TABLE [dbo].[EventDrivenEnrollmentDetails] (
    [row_id]               INT          IDENTITY (1, 1) NOT NULL,
    [ClassSK]              INT          NULL,
    [DropDateSK]           INT          NULL,
    [EnrollDateSK]         INT          NULL,
    [EnrollmentTermDateSK] INT          NULL,
    [StudentSK]            BIGINT       NULL,
    [SubjectAK]            VARCHAR (10) NULL,
    [CatalogAK]            VARCHAR (10) NULL,
    [ClassSectionAK]       VARCHAR (5)  NULL,
    [Age]                  INT          NULL,
    [Gender]               VARCHAR (20) NULL,
    [City]                 VARCHAR (75) NULL,
    [StateAbbrev]          VARCHAR (3)  NULL,
    [PostalCode]           VARCHAR (15) NULL,
    [AdmitTerm]            INT          NULL,
    [Term]                 VARCHAR (10) NULL,
    [SchoolYear]           INT          NULL,
    [Subject]              VARCHAR (10) NULL,
    [Catalog]              VARCHAR (10) NULL,
    [Section]              VARCHAR (5)  NULL,
    [Class]                VARCHAR (50) NULL,
    [CreditHours]          INT          NULL,
    [Enrolled]             INT          NULL,
    [Dropped]              INT          NULL,
    [MidTermGrade]         VARCHAR (5)  NULL,
    [EndSemesterGrade]     VARCHAR (5)  NULL,
    CONSTRAINT [PK_DimCompany33_CompanyKey] PRIMARY KEY CLUSTERED ([row_id] ASC)
);


GO
PRINT N'Creating [dbo].[FactAdmission]...';


GO
CREATE TABLE [dbo].[FactAdmission] (
    [StudentSK]                BIGINT NOT NULL,
    [AdmitDateSK]              INT    NOT NULL,
    [AdmitTypeSK]              INT    NOT NULL,
    [ApplicationSourceSK]      INT    NOT NULL,
    [AcademicProgramSK]        INT    NOT NULL,
    [CurrentAcademicProgramSK] INT    NOT NULL
);


GO
PRINT N'Creating [dbo].[FactEnrollmentDetails]...';


GO
CREATE TABLE [dbo].[FactEnrollmentDetails] (
    [EnrollmentTermDateSK] INT         NULL,
    [StudentSK]            BIGINT      NULL,
    [ClassSK]              INT         NULL,
    [EnrollDateSK]         INT         NULL,
    [DropDateSK]           INT         NULL,
    [Enrolled]             INT         NULL,
    [Dropped]              INT         NULL,
    [MidTermGrade]         VARCHAR (5) NULL,
    [EndSemesterGrade]     VARCHAR (5) NULL
);


GO
PRINT N'Creating [dbo].[FactEnrollmentSummary]...';
 
 GO
CREATE TABLE [dbo].[FactEnrollmentSummary] (
    [EnrollmentTermDateSK]   INT            NOT NULL,
    [StudentSK]              BIGINT         NOT NULL,
    [ResidencyStatusSK]      INT            NOT NULL,
    [AcademicLevelSK]        INT            NOT NULL,
    [CreditHoursAttempted]   INT            NULL,
    [CreditHoursEarned]      INT            NULL,
    [TermGPA]                DECIMAL (5, 3) NULL,
    [TransferCredit]         DECIMAL (6, 3) NULL,
    [CumCreditHoursAtempted] INT            NULL,
    [CumCreditHoursEarned]   INT            NULL,
    [CumGPA]                 DECIMAL (5, 3) NULL
);


GO
PRINT N'Creating [dbo].[stage_EventDrivenEnrollmentDetails]...';


GO
CREATE TABLE [dbo].[stage_EventDrivenEnrollmentDetails] (
    [ClassSK]              INT          NULL,
    [DropDateSK]           INT          NULL,
    [EnrollDateSK]         INT          NULL,
    [EnrollmentTermDateSK] INT          NULL,
    [StudentSK]            BIGINT       NULL,
    [SubjectAK]            VARCHAR (10) NULL,
    [CatalogAK]            VARCHAR (10) NULL,
    [ClassSectionAK]       VARCHAR (5)  NULL,
    [Age]                  INT          NULL,
    [Gender]               VARCHAR (20) NULL,
    [City]                 VARCHAR (75) NULL,
    [StateAbbrev]          VARCHAR (3)  NULL,
    [PostalCode]           VARCHAR (15) NULL,
    [AdmitTerm]            INT          NULL,
    [Term]                 VARCHAR (10) NULL,
    [SchoolYear]           INT          NULL,
    [Subject]              VARCHAR (10) NULL,
    [Catalog]              VARCHAR (10) NULL,
    [Section]              VARCHAR (5)  NULL,
    [Class]                VARCHAR (50) NULL,
    [CreditHours]          INT          NULL,
    [Enrolled]             INT          NULL,
    [Dropped]              INT          NULL,
     [MidTermGrade]         VARCHAR (5)  NULL,
    [EndSemesterGrade]     VARCHAR (5)  NULL
);


GO
PRINT N'Creating [dbo].[Term]...';


GO
CREATE TABLE [dbo].[Term] (
    [TermID]     INT          NOT NULL,
    [Term]       VARCHAR (50) NULL,
    [TermNumber] INT          NULL,
    [SchoolYear] VARCHAR (50) NULL,
    [StartDate]  VARCHAR (50) NULL,
    [EndDate]    VARCHAR (50) NULL,
    [TermAK]     VARCHAR (50) NULL,
    CONSTRAINT [PK_Term_TermPK] PRIMARY KEY CLUSTERED ([TermID] ASC)
);


GO
PRINT N'Creating [dbo].[FK_FactAdmission_To_DimAcademicProgram_On_AcademicProgramSK]...';


GO
ALTER TABLE [dbo].[FactAdmission] WITH NOCHECK
    ADD CONSTRAINT [FK_FactAdmission_To_DimAcademicProgram_On_AcademicProgramSK] FOREIGN KEY ([AcademicProgramSK]) REFERENCES [dbo].[DimAcademicProgram] ([AcademicProgramSK]);


GO
PRINT N'Creating [dbo].[FK_FactAdmission_To_DimAcademicProgram_On_CurrentAcademicProgram]...';


GO
ALTER TABLE [dbo].[FactAdmission] WITH NOCHECK
    ADD CONSTRAINT [FK_FactAdmission_To_DimAcademicProgram_On_CurrentAcademicProgram] FOREIGN KEY ([CurrentAcademicProgramSK]) REFERENCES [dbo].[DimAcademicProgram] ([AcademicProgramSK]);


GO
PRINT N'Creating [dbo].[FK_FactAdmission_To_DimAdmitType_On_AdmitTypeSK]...';


GO
ALTER TABLE [dbo].[FactAdmission] WITH NOCHECK
    ADD CONSTRAINT [FK_FactAdmission_To_DimAdmitType_On_AdmitTypeSK] FOREIGN KEY ([AdmitTypeSK]) REFERENCES [dbo].[DimAdmitType] ([AdmitTypeSK]);


GO
PRINT N'Creating [dbo].[FK_FactAdmission_To_DimApplicationSource_On_ApplicationSourceSK]...';


GO
ALTER TABLE [dbo].[FactAdmission] WITH NOCHECK
    ADD CONSTRAINT [FK_FactAdmission_To_DimApplicationSource_On_ApplicationSourceSK] FOREIGN KEY ([ApplicationSourceSK]) REFERENCES [dbo].[DimApplicationSource] ([ApplicationSourceSK]);


GO
PRINT N'Creating [dbo].[FK_FactAdmission_To_DimDateSK_On_AdmitDateSK]...';


GO
ALTER TABLE [dbo].[FactAdmission] WITH NOCHECK
    ADD CONSTRAINT [FK_FactAdmission_To_DimDateSK_On_AdmitDateSK] FOREIGN KEY ([AdmitDateSK]) REFERENCES [dbo].[DimDate] ([DateSK]);


GO
PRINT N'Creating [dbo].[FK_FactAdmission_To_DimStudent_On_StudentSK]...';


GO
ALTER TABLE [dbo].[FactAdmission] WITH NOCHECK
    ADD CONSTRAINT [FK_FactAdmission_To_DimStudent_On_StudentSK] FOREIGN KEY ([StudentSK]) REFERENCES [dbo].[DimStudent] ([StudentSK]);


GO
PRINT N'Creating [dbo].[FK_FactEnrollmentDetails_To_DimClass_On_ClassSK]...';


GO
ALTER TABLE [dbo].[FactEnrollmentDetails] WITH NOCHECK
    ADD CONSTRAINT [FK_FactEnrollmentDetails_To_DimClass_On_ClassSK] FOREIGN KEY ([ClassSK]) REFERENCES [dbo].[DimClass] ([ClassSK]);


GO
PRINT N'Creating [dbo].[FK_FactEnrollmentDetails_To_DimDate_On_DropDateSK]...';


GO
ALTER TABLE [dbo].[FactEnrollmentDetails] WITH NOCHECK
    ADD CONSTRAINT [FK_FactEnrollmentDetails_To_DimDate_On_DropDateSK] FOREIGN KEY ([DropDateSK]) REFERENCES [dbo].[DimDate] ([DateSK]);


GO
PRINT N'Creating [dbo].[FK_FactEnrollmentDetails_To_DimDate_On_EnrollDateSK]...';


GO
ALTER TABLE [dbo].[FactEnrollmentDetails] WITH NOCHECK
    ADD CONSTRAINT [FK_FactEnrollmentDetails_To_DimDate_On_EnrollDateSK] FOREIGN KEY ([EnrollDateSK]) REFERENCES [dbo].[DimDate] ([DateSK]);


GO
PRINT N'Creating [dbo].[FK_FactEnrollmentDetails_To_DimDate_On_EnrollmentTermDateSK]...';


GO
ALTER TABLE [dbo].[FactEnrollmentDetails] WITH NOCHECK
    ADD CONSTRAINT [FK_FactEnrollmentDetails_To_DimDate_On_EnrollmentTermDateSK] FOREIGN KEY ([EnrollmentTermDateSK]) REFERENCES [dbo].[DimDate] ([DateSK]);


GO
PRINT N'Creating [dbo].[FK_FactEnrollmentDetails_To_DimStudent_On_StudentSK]...';


GO
ALTER TABLE [dbo].[FactEnrollmentDetails] WITH NOCHECK
    ADD CONSTRAINT [FK_FactEnrollmentDetails_To_DimStudent_On_StudentSK] FOREIGN KEY ([StudentSK]) REFERENCES [dbo].[DimStudent] ([StudentSK]);


GO
PRINT N'Creating [dbo].[FK_FactEnrollmentSummary_To_DimAcademicLevel_On_AcademicLevelSK]...';


GO
ALTER TABLE [dbo].[FactEnrollmentSummary] WITH NOCHECK
    ADD CONSTRAINT [FK_FactEnrollmentSummary_To_DimAcademicLevel_On_AcademicLevelSK] FOREIGN KEY ([AcademicLevelSK]) REFERENCES [dbo].[DimAcademicLevel] ([AcademicLevelSK]);


GO
PRINT N'Creating [dbo].[FK_FactEnrollmentSummary_To_DimDate_On_EnrollmentTermDateSK]...';


GO
ALTER TABLE [dbo].[FactEnrollmentSummary] WITH NOCHECK
    ADD CONSTRAINT [FK_FactEnrollmentSummary_To_DimDate_On_EnrollmentTermDateSK] FOREIGN KEY ([EnrollmentTermDateSK]) REFERENCES [dbo].[DimDate] ([DateSK]);


GO
PRINT N'Creating [dbo].[FK_FactEnrollmentSummary_To_DimResidencyStatus_On_ResidencyStatusSK]...';


GO
ALTER TABLE [dbo].[FactEnrollmentSummary] WITH NOCHECK
    ADD CONSTRAINT [FK_FactEnrollmentSummary_To_DimResidencyStatus_On_ResidencyStatusSK] FOREIGN KEY ([ResidencyStatusSK]) REFERENCES [dbo].[DimResidencyStatus] ([ResidencyStatusSK]);


GO
PRINT N'Creating [dbo].[FK_FactEnrollmentSummary_To_DimStudent_On_StudentSK]...';


GO
ALTER TABLE [dbo].[FactEnrollmentSummary] WITH NOCHECK
    ADD CONSTRAINT [FK_FactEnrollmentSummary_To_DimStudent_On_StudentSK] FOREIGN KEY ([StudentSK]) REFERENCES [dbo].[DimStudent] ([StudentSK]);


GO
PRINT N'Creating [dbo].[LoadDateDimension]...';


GO

CREATE PROC dbo.LoadDateDimension
@Start datetime,
@End datetime
AS

DECLARE
@StartDate AS DATETIME = @Start,
@EndDate AS DATETIME = @End,
@Date AS DATETIME,
@WDofMonth AS INT,
@CurrentMonth AS INT = 1,
@CurrentDate AS DATE = getdate();

DELETE FROM dbo.DimDate;

--IF YOU ARE USING THE YYYYMMDD format for the primary key then you need to comment out this line.
--DBCC CHECKIDENT (DimDate, RESEED, 60000) --In case you need to add earlier dates later.
DECLARE @tmpDOW TABLE (
DOW  INT,
Cntr INT); --Table for counting DOW occurance in a month

INSERT  INTO @tmpDOW (DOW, Cntr)
VALUES              (1, 0); --Used in the loop below

INSERT  INTO @tmpDOW (DOW, Cntr)
VALUES              (2, 0);

INSERT  INTO @tmpDOW (DOW, Cntr)
VALUES              (3, 0);

INSERT  INTO @tmpDOW (DOW, Cntr)
VALUES              (4, 0);

INSERT  INTO @tmpDOW (DOW, Cntr)
VALUES              (5, 0);

INSERT  INTO @tmpDOW (DOW, Cntr)
VALUES              (6, 0);

INSERT  INTO @tmpDOW (DOW, Cntr)
VALUES              (7, 0);

SET @Date = @StartDate;

WHILE @Date < @EndDate
 BEGIN
 IF DATEPART(MONTH, @Date) <> @CurrentMonth
 BEGIN
 SELECT @CurrentMonth = DATEPART(MONTH, @Date);
 UPDATE  @tmpDOW
 SET Cntr = 0;
 END
 UPDATE  @tmpDOW
 SET Cntr = Cntr + 1
 WHERE   DOW = DATEPART(DW, @DATE);
 SELECT @WDofMonth = Cntr
 FROM   @tmpDOW
 WHERE  DOW = DATEPART(DW, @DATE);

 INSERT INTO DimDate ([DateSK], [FullDate], [Day], [DayOfWeek], [DayOfWeekNumber], [DayOfWeekInMonth], [CalendarMonthNumber], [CalendarMonthName], [CalendarQuarterNumber], [CalendarQuarterName], [CalendarYearNumber], [StandardDate], [WeekDayFlag], [HolidayFlag], [OpenFlag], [FirstDayOfCalendarMonthFlag], [LastDayOfCalendarMonthFlag], HolidayText) --TO MAKE THE DateSK THE YYYYMMDD FORMAT UNCOMMENT THIS LINE… Comment for autoincrementing.
 SELECT CONVERT (VARCHAR, @Date, 112) AS [DateSK], --TO MAKE THE DateSK THE YYYYMMDD FORMAT UNCOMMENT THIS LINE COMMENT FOR AUTOINCREMENT
  @Date AS [FullDate],
 DATEPART(DAY, @DATE) AS [Day],
 CASE DATEPART(DW, @DATE)
 WHEN 1 THEN 'Sunday'
 WHEN 2 THEN 'Monday'
 WHEN 3 THEN 'Tuesday'
 WHEN 4 THEN 'Wednesday'
 WHEN 5 THEN 'Thursday'
 WHEN 6 THEN 'Friday'
 WHEN 7 THEN 'Saturday'
 END AS [DayOfWeek],
 DATEPART(DW, @DATE) AS [DayOfWeekNumber],
 @WDofMonth AS [DOWInMonth],
 DATEPART(MONTH, @DATE) AS [CalendarMonthNumber], --To be converted with leading zero later.
 DATENAME(MONTH, @DATE) AS [CalendarMonthName],
 DATEPART(qq, @DATE) AS [CalendarQuarterNumber], --Calendar quarter
 CASE DATEPART(qq, @DATE)
 WHEN 1 THEN 'First'
 WHEN 2 THEN 'Second'
 WHEN 3 THEN 'Third'
 WHEN 4 THEN 'Fourth'
 END AS [CalendarQuarterName],
 DATEPART(YEAR, @Date) AS [CalendarYearNumber],
 RIGHT('0' + CONVERT (VARCHAR (2), MONTH(@Date)), 2) + '/' + RIGHT('0' + CONVERT (VARCHAR (2), DAY(@Date)), 2) + '/' + CONVERT (VARCHAR (4), YEAR(@Date)),
 CASE DATEPART(DW, @DATE)
 WHEN 1 THEN 0
 WHEN 2 THEN 1
 WHEN 3 THEN 1
 WHEN 4 THEN 1
 WHEN 5 THEN 1
 WHEN 6 THEN 1
 WHEN 7 THEN 0
 END AS [WeekDayFlag],
 0 AS HolidayFlag,
 CASE DATEPART(DW, @DATE)
 WHEN 1 THEN 0
 WHEN 2 THEN 1
 WHEN 3 THEN 1
 WHEN 4 THEN 1
 WHEN 5 THEN 1
 WHEN 6 THEN 1
 WHEN 7 THEN 1
 END AS OpenFlag,
 CASE DATEPART(dd, @Date)
WHEN 1 THEN 1 ELSE 0
 END AS [FirstDayOfCalendarMonthFlag],
 CASE
 WHEN DateAdd(day, -1, DateAdd(month, DateDiff(month, 0, @Date) + 1, 0)) = @Date THEN 1 ELSE 0
 END AS [LastDayOfCalendarMonthFlag],
 NULL AS HolidayText;
 SELECT @Date = DATEADD(dd, 1, @Date);
 END

 -- Add HOLIDAYS ————————————————————————————————————--
-- New Years Day ———————————————————————————————
 UPDATE  dbo.DimDate
 SET HolidayText = 'New Year”s Day',
 HolidayFlag = 1,
 OpenFlag    = 0
 WHERE   [CalendarMonthNumber] = 1
 AND [DAY] = 1;

--Set OpenFlag = 0 if New Year's Day is on weekend
 UPDATE  dbo.DimDate
 SET OpenFlag = 0
 WHERE   DateSK IN (SELECT CASE
 WHEN DayOfWeek = 'Sunday' THEN DATESK + 1
 END
 FROM   DimDate
 WHERE  CalendarMonthNumber = 1
 AND [DAY] = 1);

-- Martin Luther King Day —————————————————————————————
--Third Monday in January starting in 1983
 UPDATE  DimDate
 SET HolidayText = 'Martin Luther King Jr. Day',
 HolidayFlag = 1,
 OpenFlag    = 0
 WHERE   [CalendarMonthNumber] = 1 --January
 AND [Dayofweek] = 'Monday'
 AND CalendarYearNumber >= 1983 --When holiday was official
 AND [DayOfWeekInMonth] = 3; --Third X day of current month.

 --President's Day —————————————————————————————
 --Third Monday in February.
 UPDATE  DimDate
 SET HolidayText = 'President”s Day',
 HolidayFlag = 1,
 OpenFlag    = 0
WHERE   [CalendarMonthNumber] = 2 --February
 AND [Dayofweek] = 'Monday'
 AND [DayOfWeekInMonth] = 3; --Third occurance of a monday in this month.

 --Memorial Day —————————————————————————————-
 --Last Monday in May
 UPDATE  dbo.DimDate
 SET HolidayText = 'Memorial Day',
 HolidayFlag = 1,
 OpenFlag    = 0
 FROM    DimDate
 WHERE   DateSK IN (SELECT   MAX([DateSK])
 FROM     dbo.DimDate
 WHERE    [CalendarMonthName] = 'May'
 AND [DayOfWeek] = 'Monday'
 GROUP BY CalendarYearNumber, [CalendarMonthNumber]);

--4th of July ———————————————————————————————
 UPDATE  dbo.DimDate
 SET HolidayText = 'Independance Day',
 HolidayFlag = 1,
 OpenFlag    = 0
 WHERE   [CalendarMonthNumber] = 7
 AND [DAY] = 4;

--Set OpenFlag = 0 if July 4th is on weekend
 UPDATE  dbo.DimDate
 SET OpenFlag = 0
 WHERE   DateSK IN (SELECT CASE
 WHEN DayOfWeek = 'Sunday' THEN DATESK + 1
 END
 FROM   DimDate
 WHERE  CalendarMonthNumber = 7
 AND [DAY] = 4);

--Labor Day ——————————————————————————————-
 --First Monday in September
 UPDATE  dbo.DimDate
 SET HolidayText = 'Labor Day',
 HolidayFlag = 1,
 OpenFlag    = 0
 FROM    DimDate
 WHERE   DateSK IN (SELECT   MIN([DateSK])
 FROM     dbo.DimDate
 WHERE    [CalendarMonthName] = 'September'
  AND [DayOfWeek] = 'Monday'
 GROUP BY CalendarYearNumber, [CalendarMonthNumber]);

--Columbus Day——————————————————————————————
--2nd Monday in October
 UPDATE  dbo.DimDate
 SET HolidayText = 'Columbus Day',
 HolidayFlag = 1,
 OpenFlag    = 0
 FROM    DimDate
 WHERE   DateSK IN (SELECT   MIN(DateSK)
 FROM     dbo.DimDate
 WHERE    [CalendarMonthName] = 'October'
 AND [DayOfWeek] = 'Monday'
 AND [DayOfWeekInMonth] = 2
 GROUP BY CalendarYearNumber, [CalendarMonthNumber]);

--Veteran's Day ————————————————————————————————————--
 UPDATE  DimDate
 SET HolidayText = 'Veteran”s Day',
 HolidayFlag = 1,
 OpenFlag    = 0
 WHERE   DateSK IN (SELECT CASE
 WHEN DayOfWeek = 'Saturday' THEN DateSK - 1
 WHEN DayOfWeek = 'Sunday' THEN DateSK + 1 ELSE DateSK
 END AS VeteransDateSK
 FROM   DimDate
 WHERE  [CalendarMonthNumber] = 11
 AND [DAY] = 11);

 --THANKSGIVING ————————————————————————————————————--
 --Fourth THURSDAY in November.
 UPDATE  DimDate
 SET HolidayText = 'Thanksgiving Day',
 HolidayFlag = 1,
 OpenFlag    = 0
 WHERE   [CalendarMonthNumber] = 11
 AND [DAYOFWEEK] = 'Thursday'
 AND [DayOfWeekInMonth] = 4;

 --CHRISTMAS ——————————————————————————————-
 UPDATE  dbo.DimDate
 SET HolidayText = 'Christmas Day',
 HolidayFlag = 1,
 OpenFlag    = 0
 WHERE   [CalendarMonthNumber] = 12
 AND [DAY] = 25;

--Set OpenFlag = 0 if Christmas on weekend
 UPDATE  dbo.DimDate
 SET OpenFlag = 0
 WHERE   DateSK IN (SELECT CASE
 WHEN DayOfWeek = 'Sunday' THEN DATESK + 1
 WHEN Dayofweek = 'Saturday' THEN DateSK - 1
 END
 FROM   DimDate
 WHERE  CalendarMonthNumber = 12
 AND DAY = 25);

-- Valentine's Day
 UPDATE  dbo.DimDate
 SET HolidayText = 'Valentine''s Day'
 WHERE   CalendarMonthNumber = 2
 AND [DAY] = 14;

-- Saint Patrick's Day
 UPDATE  dbo.DimDate
 SET HolidayText = 'Saint Patrick''s Day'
 WHERE   [CalendarMonthNumber] = 3
 AND [DAY] = 17;

 --Mother's Day —————————————————————————————
 --Second Sunday of May
 UPDATE  DimDate
 SET HolidayText = 'Mother''s Day' --select * from DimDate
 WHERE   [CalendarMonthNumber] = 5 --May
 AND [Dayofweek] = 'Sunday'
 AND [DayOfWeekInMonth] = 2; --Second occurance of a monday in this month.

 --Father's Day —————————————————————————————
 --Third Sunday of June
 UPDATE  DimDate
 SET HolidayText = 'Father''s Day' --select * from DimDate
 WHERE   [CalendarMonthNumber] = 6 --June
 AND [Dayofweek] = 'Sunday'
 AND [DayOfWeekInMonth] = 3; --Third occurance of a monday in this month.

 --Halloween 10/31 ———————————————————————————-
 UPDATE  dbo.DimDate
 SET HolidayText = 'Halloween'
 WHERE   [CalendarMonthNumber] = 10
 AND [DAY] = 31;

-- Election Day————————————————————————————--
-- The first Tuesday after the first Monday in November.
 BEGIN TRY
 DROP TABLE #tmpHoliday;
 END TRY
 BEGIN CATCH
 --do nothing
 END CATCH

CREATE TABLE #tmpHoliday
 (
 ID     INT      IDENTITY (1, 1),
 DateID INT     ,
 Week   TINYINT ,
 YEAR   CHAR (4),
 DAY    CHAR (2)
 );

INSERT INTO #tmpHoliday (DateID, [YEAR], [DAY])
 SELECT   [DateSK],
 CalendarYearNumber,
 [DAY]
 FROM     dbo.DimDate
 WHERE    [CalendarMonthNumber] = 11
 AND [Dayofweek] = 'Monday'
 ORDER BY CalendarYearNumber, [DAY];

DECLARE @CNTR AS INT,
 @POS AS INT,
 @STARTYEAR AS INT,
 @ENDYEAR AS INT,
 @CURRENTYEAR AS INT,
 @MINDAY AS INT;

SELECT @CURRENTYEAR = MIN([YEAR]),
 @STARTYEAR = MIN([YEAR]),
 @ENDYEAR = MAX([YEAR])
 FROM   #tmpHoliday;

WHILE @CURRENTYEAR <= @ENDYEAR
 BEGIN
 SELECT @CNTR = COUNT([YEAR])
 FROM   #tmpHoliday
 WHERE  [YEAR] = @CURRENTYEAR;
 SET @POS = 1;
 WHILE @POS <= @CNTR
 BEGIN
 SELECT @MINDAY = MIN(DAY)
 FROM   #tmpHoliday
 WHERE  [YEAR] = @CURRENTYEAR
 AND [WEEK] IS NULL;
 UPDATE  #tmpHoliday
 SET [WEEK] = @POS
 WHERE   [YEAR] = @CURRENTYEAR
 AND [DAY] = @MINDAY;
 SELECT @POS = @POS + 1;
 END
 SELECT @CURRENTYEAR = @CURRENTYEAR + 1;
 END

UPDATE  DT
 SET HolidayText = 'Election Day'
 FROM    dbo.DimDate AS DT
 INNER JOIN
 #tmpHoliday AS HL
 ON (HL.DateID + 1) = DT.DateSK
 WHERE   [WEEK] = 1;

DROP TABLE #tmpHoliday;

UPDATE d
SET
        d.Term = t.Term,
        d.TermNumber = t.TermNumber,
        d.SchoolYear = t.SchoolYear,
        d.TermAK = t.TermAK
FROM DimDate d
LEFT OUTER JOIN dbo.Term t
        ON d.fullDate between t.StartDate  and t.EndDate

/* Insert default date row */
INSERT INTO DimDate ([DateSK], [FullDate], [Day], [DayOfWeek], [DayOfWeekNumber], [DayOfWeekInMonth], [CalendarMonthNumber], [CalendarMonthName], [CalendarQuarterNumber], [CalendarQuarterName], [CalendarYearNumber], [StandardDate], [WeekDayFlag], [HolidayFlag], [OpenFlag], [FirstDayOfCalendarMonthFlag], [LastDayOfCalendarMonthFlag], HolidayText)
SELECT TOP 1  19000101,'1/1/1900',  Day, DayOfWeek, DayOfWeekNumber, DayOfWeekInMonth, CalendarMonthNumber, CalendarMonthName, CalendarQuarterNumber, CalendarQuarterName, CalendarYearNumber, '1/1/1900', WeekDayFlag, HolidayFlag, OpenFlag, FirstDayOfCalendarMonthFlag, LastDayOfCalendarMonthFlag, HolidayText
FROM DimDate
WHERE dayofweek = 'monday';
GO
PRINT N'Creating [dbo].[uspUnknownRow]...';


GO

CREATE Proc [dbo].[uspUnknownRow]
(
@schema sysname,
@table sysname,
@action varchar(10)
)
AS
/*Declare internal variables. Values are set within stored procedure*/
Declare
@sqlquery varchar(max),
@columns varchar(max),
@identity varchar(100),
@values varchar(max)
/*Returns the column identified as the identity column*/
SELECT @identity =
         COLUMN_NAME
      FROM  INFORMATION_SCHEMA.COLUMNS c
      INNER JOIN SYSOBJECTS o
      ON c.TABLE_NAME = o.name
      INNER JOIN sys.schemas s
      ON o.uid = s.schema_id
      LEFT JOIN sys.all_columns c2
      ON o.id = c2.object_id
      AND c.COLUMN_NAME = c2.name
      Where is_identity = 1
      AND c.TABLE_NAME = @table
      AND c.TABLE_SCHEMA = @schema
/*Returns column names for selected table*/
SELECT @columns = coalesce(+@columns + ', ', '') + COLUMN_NAME
      FROM  INFORMATION_SCHEMA.COLUMNS c
      INNER JOIN SYSOBJECTS o
      ON c.TABLE_NAME = o.name
      INNER JOIN sys.schemas s
      ON o.uid = s.schema_id
      LEFT JOIN sys.all_columns c2
      ON o.id = c2.object_id
      AND c.COLUMN_NAME = c2.name
WHERE
      c.TABLE_NAME = @table
      AND c.TABLE_SCHEMA = @schema
      AND c2.is_computed = 0
      AND c.TABLE_SCHEMA = s.name
Order by ORDINAL_POSITION;

GO

--SET @columns = @columns +']'
/*
Post-Deployment Script Template
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.
 Use SQLCMD syntax to include a file in the post-deployment script.
 Example:      :r .\myfile.sql
 Use SQLCMD syntax to reference a variable in the post-deployment script.
 Example:      :setvar TableName MyTable
               SELECT * FROM [$(TableName)]
--------------------------------------------------------------------------------------
*/

/* run in user database HigherED_DW */
/*
CREATE USER [HigherEDProxyUser] FROM LOGIN [HigherEDProxyUser] WITH DEFAULT_SCHEMA=[dbo];
GO

BEGIN
GRANT VIEW DEFINITION TO [HigherEDProxyUser];
GRANT CONNECT TO [HigherEDProxyUser];
EXEC sp_addrolemember N'db_datareader', [HigherEDProxyUser];
EXEC sp_addrolemember N'db_datawriter', [HigherEDProxyUser];
EXEC sp_addrolemember N'db_ddladmin ', [HigherEDProxyUser];
GRANT EXECUTE TO [HigherEDProxyUser];
END;
GO
*/
     

