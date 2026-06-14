
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para leer datos de organizaciones
de un archivo CSV a una tabla temporal global apra ser procesados por otro SP.  
*/


USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.Sp_ImportarDatosEmpresasCSVTemporal
    @RutaArchivoEmpresas VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        IF OBJECT_ID('tempdb..##Staging_Organizaciones') IS NULL
        BEGIN
            PRINT 'La tabla temporal ##Staging_Organizaciones no existe. Asegúrese de ejecutar el procedimiento almacenado principal antes de este.'
            RETURN;
        END;

         -- Paso 1: Crear una tabla Raw para absorber las 14 columnas del CSV
        CREATE TABLE #Organizaciones_Raw_CSV (
            IdStaging INT IDENTITY(1,1) PRIMARY KEY,
            [organizacion] VARCHAR(255),
            [rubro] VARCHAR(255),
            [subrubro] VARCHAR(255),
            [calle] VARCHAR(255),
            [numero] VARCHAR(50),
            [pais] VARCHAR(255),
            [provincia] VARCHAR(255),
            [ciudad] VARCHAR(255),
            [telefono] VARCHAR(50),
            [facebook] VARCHAR(255),
            [web] VARCHAR(255),
            [programa] VARCHAR(255),
            [fecha_distincion] DATE,
            [fecha_revalidacion] DATE
        );
        
        -- Verificar que el archivo existe
        DECLARE @ExisteArchivo INT;
        EXEC master.dbo.xp_fileexist @RutaArchivoEmpresas, @ExisteArchivo OUTPUT;
        IF @ExisteArchivo = 0
        BEGIN
            RAISERROR('El archivo no existe o no es accesible.', 16, 1);
            RETURN;
        END

        IF OBJECT_ID('tempdb..#Staging_Raw_CSV') IS NOT NULL
        DROP TABLE #Staging_Raw_CSV;

        -- Adaptado a las 14 columnas del CSV
        CREATE TABLE #Staging_Raw_CSV (
            organizacion VARCHAR(255), rubro VARCHAR(255), subrubro VARCHAR(255), calle VARCHAR(255),
            numero VARCHAR(50), pais VARCHAR(50), provincia VARCHAR(80), ciudad VARCHAR(80),
            telefono VARCHAR(50), facebook VARCHAR(255), web VARCHAR(255), programa VARCHAR(255),
            fecha_distincion VARCHAR(50), fecha_revalidacion VARCHAR(50)
        );
        
        DECLARE @RutaArchivo NVARCHAR(500) = 'C:\ArchivosTPBDA\registro-organizaciones-distinguidas-sact.csv';
        DECLARE @Sql NVARCHAR(MAX);
        SET @Sql = N'
        BULK INSERT #Staging_Raw_CSV
        FROM ''' + @RutaArchivo + '''
        WITH (FORMAT = ''CSV'', FIELDQUOTE = ''"'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', FIRSTROW = 2, CODEPAGE = ''65001'');';

        EXEC sp_executesql @sql;

        -- Insertar los datos desde la tabla de staging a la tabla global de staging, realizando las transformaciones necesarias
        INSERT INTO ##Staging_Organizaciones (Organizacion, Rubro, Provincia, Fecha_Distincion)
        SELECT 
            organizacion,
            rubro,
            provincia,
            TRY_CAST(fecha_distincion AS DATE)
        FROM #Staging_Raw_CSV
        WHERE organizacion IS NOT NULL AND organizacion <> '';
        
        --delete FROM ##Staging_Organizaciones ORDER BY Organizacion ;
    
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salio mal en la importación de datos', 16, 1);
            RETURN;
        END
    END CATCH
END