/*
用途：2026-11-17 舊 GymProject 結構對齊 80fbafc 的修正紀錄。
適用於本次已檢視的舊版結構，不是全新建表／通用遷移。
使用前備份並比對結構；本機已逐步完成修正者不需重跑。
本整合檔僅靜態檢查；各修正已由使用者在本機分階段執行並成功啟動後端。
不刪表、不刪資料；缺少關聯欄位的量測／續約表若非空則中止。
*/
USE [GymProject];
GO
SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF COL_LENGTH(N'dbo.inbodyrecords', N'attendanceid') IS NULL
       AND EXISTS (SELECT 1 FROM dbo.inbodyrecords)
        THROW 50001, N'量測表已有資料，需先人工確認出席對應。', 1;

    IF COL_LENGTH(N'dbo.renewal', N'newmembercourseid') IS NULL
       AND EXISTS (SELECT 1 FROM dbo.renewal)
        THROW 50002, N'續約表已有資料，需先人工確認新購課方案。', 1;

    IF EXISTS (SELECT 1 FROM dbo.course
               WHERE price IS NOT NULL
                 AND TRY_CONVERT(NUMERIC(10,2), price) IS NULL)
        THROW 50003, N'課程價格超出 NUMERIC(10,2) 範圍。', 1;

    IF EXISTS (SELECT 1 FROM dbo.course
               WHERE DATALENGTH(CONVERT(NVARCHAR(MAX), status)) > 40)
        THROW 50004, N'課程狀態長度超過 NVARCHAR(20) 容量。', 1;

    IF COL_LENGTH(N'dbo.attendance', N'updatetime') IS NULL
        ALTER TABLE dbo.attendance ADD updatetime DATETIME NULL;

    ALTER TABLE dbo.course ALTER COLUMN price NUMERIC(10,2) NOT NULL;
    ALTER TABLE dbo.course ALTER COLUMN status NVARCHAR(20) NOT NULL;
    ALTER TABLE dbo.course ALTER COLUMN description NVARCHAR(MAX) NOT NULL;

    IF COL_LENGTH(N'dbo.followup', N'contactmethod') IS NULL
        ALTER TABLE dbo.followup ADD contactmethod NVARCHAR(20) NULL;
    IF COL_LENGTH(N'dbo.followup', N'createdate') IS NULL
        ALTER TABLE dbo.followup ADD createdate DATETIME NULL;
    IF COL_LENGTH(N'dbo.followup', N'createdat') IS NOT NULL
        EXEC sys.sp_executesql N'
            UPDATE dbo.followup SET createdate = createdat
            WHERE createdate IS NULL AND createdat IS NOT NULL;';
    ALTER TABLE dbo.followup ALTER COLUMN note NVARCHAR(MAX) NULL;

    IF COL_LENGTH(N'dbo.member', N'avatarurl') IS NULL
        ALTER TABLE dbo.member ADD avatarurl NVARCHAR(500) NULL;

    IF COL_LENGTH(N'dbo.inbodyrecords', N'attendanceid') IS NULL
        ALTER TABLE dbo.inbodyrecords ADD attendanceid INT NOT NULL;
    IF OBJECT_ID(N'dbo.FK_inbodyrecords_attendance', N'F') IS NULL
        EXEC sys.sp_executesql N'
            ALTER TABLE dbo.inbodyrecords WITH CHECK
            ADD CONSTRAINT FK_inbodyrecords_attendance
            FOREIGN KEY (attendanceid) REFERENCES dbo.attendance(attendanceid);';
    IF NOT EXISTS (SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.inbodyrecords')
          AND name = N'UQ_inbodyrecords_attendanceid')
        EXEC sys.sp_executesql N'
            ALTER TABLE dbo.inbodyrecords ADD CONSTRAINT
            UQ_inbodyrecords_attendanceid UNIQUE (attendanceid);';

    IF COL_LENGTH(N'dbo.renewal', N'newmembercourseid') IS NULL
        ALTER TABLE dbo.renewal ADD newmembercourseid INT NOT NULL;
    IF COL_LENGTH(N'dbo.renewal', N'note') IS NULL
        ALTER TABLE dbo.renewal ADD note NVARCHAR(500) NULL;
    IF OBJECT_ID(N'dbo.FK_renewal_newmembercourse', N'F') IS NULL
        EXEC sys.sp_executesql N'
            ALTER TABLE dbo.renewal WITH CHECK
            ADD CONSTRAINT FK_renewal_newmembercourse
            FOREIGN KEY (newmembercourseid) REFERENCES dbo.membercourse(membercourseid);';
    IF NOT EXISTS (SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.renewal')
          AND name = N'UQ_renewal_newmembercourseid')
        EXEC sys.sp_executesql N'
            ALTER TABLE dbo.renewal ADD CONSTRAINT
            UQ_renewal_newmembercourseid UNIQUE (newmembercourseid);';

    COMMIT TRANSACTION;
    PRINT N'舊版結構修正完成。請以 ddl-auto=validate 啟動後端並驗證功能。';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
