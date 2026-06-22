/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
importar datos de parques nacionales desde archivos CSV a una tabla temporal.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ImportarDatosParquesCSVTemporal
    @RutaArchivo VARCHAR(500)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..##Staging_Parques') IS NULL
        BEGIN
            RAISERROR('La tabla temporal de staging no existe. Estas llamando a este procedimiento sin haber ejecutado primero el procedimiento principal de importación?', 16, 1);
            RETURN;
        END

        -- Paso 1: Crear una tabla Raw para absorber las 15 columnas del CSV
        IF OBJECT_ID('tempdb..#Staging_Raw_CSV') IS NULL
        BEGIN 
            CREATE TABLE #Staging_Raw_CSV (
                [Provincia] VARCHAR(255),
                [Área Protegida] VARCHAR(255),
                [Año de Creacion] VARCHAR(50),
                [Región] VARCHAR(255),
                [Superficie (HA)] VARCHAR(50), -- Lo importamos como VARCHAR para luego convertirlo a DECIMAL, así evitamos errores por formatos numéricos raros o celdas vacías
                [Latitud] VARCHAR(50),
                [Longitud] VARCHAR(50),
                [Instrumento de creación] VARCHAR(500),
                [Ecorregiones] VARCHAR(500),
                [Cat. internacional] VARCHAR(255),
                [Especies registradas] VARCHAR(50),
                [Animales] VARCHAR(50),
                [Bacterias] VARCHAR(50),
                [Hongos] VARCHAR(50),
                [Plantas] VARCHAR(50)
            );
        END

        -- Paso 2: Leer el archivo CSV y volcarlo en la tabla Raw
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
        BULK INSERT #Staging_Raw_CSV
        FROM ''' + @RutaArchivo + '''
        WITH (
            FORMAT = ''CSV'',            -- Interpreta correctamente los textos entre comillas dobles
            FIELDQUOTE = ''"'',
            FIELDTERMINATOR = '','',     -- Separador de columnas
            ROWTERMINATOR = ''\n'',      -- Separador de filas
            FIRSTROW = 3,              -- Saltea el título general y los encabezados de las columnas
            CODEPAGE = ''65001''         -- Usa UTF-8 para que acentos y eñes (ej. "Región") se lean perfecto
        );'

        EXEC sp_executesql @sql;

        -- Paso 3: Pasar solo los datos que nos importan a la tabla Staging oficial (con su formato correcto)
        INSERT INTO ##Staging_Parques (Provincia, Parque, Region, Superficie)
        SELECT 
            Provincia,
            [Área Protegida],
            [Región],
            -- Usamos TRY_CAST por si alguna superficie viene vacía o con un guión '-' en el CSV
            TRY_CAST([Superficie (HA)] AS DECIMAL(14,4)) 
        FROM #Staging_Raw_CSV
        WHERE [Área Protegida] IS NOT NULL AND [Área Protegida] <> '' 
        AND (
                [Área Protegida] LIKE '%Parque%' 
                OR 
                [Área Protegida] LIKE '%Reserva%' 
                OR 
                [Área Protegida] LIKE '%Monumento%'
        );

        -- Paso 4: Limpieza de la tabla Raw temporal
        DROP TABLE #Staging_Raw_CSV;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    DROP TABLE IF EXISTS #Staging_Raw_CSV; -- Aseguramos eliminar la tabla raw si quedó por algún error
END