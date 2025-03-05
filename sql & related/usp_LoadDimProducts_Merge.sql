-- Drop procedure if exists
IF OBJECT_ID('DW.usp_LoadDimProducts_Merge', 'P') IS NOT NULL
    DROP PROCEDURE DW.usp_LoadDimProducts_Merge;
GO

CREATE PROCEDURE DW.usp_LoadDimProducts_Merge
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Temp table to capture MERGE results
        DECLARE @MergeOutput TABLE (
            ActionType NVARCHAR(10),
            ProductID INT,
            ProductName NVARCHAR(40),
            QuantityPerUnit NVARCHAR(20),
            UnitPrice MONEY,
            UnitsInStock SMALLINT,
            UnitsOnOrder SMALLINT,
            ReorderLevel SMALLINT,
            Discontinued BIT
        );

        -- MERGE statement with Type 2 SCD logic
        MERGE DW.DimProducts AS T
        USING (
            SELECT 
                ProductID,
                ProductName,
                QuantityPerUnit,
                UnitPrice,
                UnitsInStock,
                UnitsOnOrder,
                ReorderLevel,
                Discontinued
            FROM Staging.Products
        ) AS S
        ON T.ProductID = S.ProductID AND T.IsCurrent = 1

        -- Expire existing record if attributes change
        WHEN MATCHED AND (
            T.ProductName <> S.ProductName
            OR ISNULL(T.QuantityPerUnit, '') <> ISNULL(S.QuantityPerUnit, '')
            OR ISNULL(T.UnitPrice, 0) <> ISNULL(S.UnitPrice, 0)
            OR ISNULL(T.UnitsInStock, 0) <> ISNULL(S.UnitsInStock, 0)
            OR ISNULL(T.UnitsOnOrder, 0) <> ISNULL(S.UnitsOnOrder, 0)
            OR ISNULL(T.ReorderLevel, 0) <> ISNULL(S.ReorderLevel, 0)
            OR T.Discontinued <> S.Discontinued
        )
        THEN 
            UPDATE SET
                T.IsCurrent = 0,
                T.ValidTo = GETDATE()

        -- Insert new records
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                ProductID,
                ProductName,
                QuantityPerUnit,
                UnitPrice,
                UnitsInStock,
                UnitsOnOrder,
                ReorderLevel,
                Discontinued,
                ValidFrom,
                ValidTo,
                IsCurrent
            )
            VALUES (
                S.ProductID,
                S.ProductName,
                S.QuantityPerUnit,
                S.UnitPrice,
                S.UnitsInStock,
                S.UnitsOnOrder,
                S.ReorderLevel,
                S.Discontinued,
                GETDATE(),
                '9999-12-31',
                1
            )

        -- Expire records removed from source (optional)
        WHEN NOT MATCHED BY SOURCE AND T.IsCurrent = 1 THEN
            UPDATE SET
                T.IsCurrent = 0,
                T.ValidTo = GETDATE()

        -- Capture changes for new version insertion
        OUTPUT 
            $action,
            S.ProductID,
            S.ProductName,
            S.QuantityPerUnit,
            S.UnitPrice,
            S.UnitsInStock,
            S.UnitsOnOrder,
            S.ReorderLevel,
            S.Discontinued
        INTO @MergeOutput;

        -- Insert new versions of changed records
        INSERT INTO DW.DimProducts (
            ProductID,
            ProductName,
            QuantityPerUnit,
            UnitPrice,
            UnitsInStock,
            UnitsOnOrder,
            ReorderLevel,
            Discontinued,
            ValidFrom,
            ValidTo,
            IsCurrent
        )
        SELECT 
            ProductID,
            ProductName,
            QuantityPerUnit,
            UnitPrice,
            UnitsInStock,
            UnitsOnOrder,
            ReorderLevel,
            Discontinued,
            GETDATE(),
            '9999-12-31',
            1
        FROM @MergeOutput
        WHERE ActionType = 'UPDATE';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO