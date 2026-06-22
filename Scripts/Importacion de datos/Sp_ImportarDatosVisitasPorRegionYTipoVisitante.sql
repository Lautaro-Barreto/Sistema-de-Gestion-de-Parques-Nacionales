/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 22/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
importar datos de visitas por region y tipo de visitante desde archivos CSV a una tabla temporal.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.Sp_ImportarDatosVisitasPorRegionYTipoVisitante
    @RutaArchivoVisitas VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Primero se chequea que el archivo exista
    DECLARE @ExisteArchivo INT;
    EXEC master.dbo.xp_fileexist @RutaArchivoVisitas, @ExisteArchivo OUTPUT;
    IF @ExisteArchivo = 0
    BEGIN
        RAISERROR('El archivo no existe o no es accesible.', 16, 1);
        RETURN;
    END

    -- Se crea una tabla temporal para absorber las 5 columnas del CSV
    IF OBJECT_ID('tempdb..##Staging_Visitas_Raw_CSV') IS NOT NULL
        DROP TABLE ##Staging_Visitas_Raw_CSV;
 
    CREATE TABLE ##Staging_Visitas_Raw_CSV (
        [indice_tiempo] VARCHAR(50) COLLATE Latin1_General_CI_AS,
        [region_de_destino] VARCHAR(255) COLLATE Latin1_General_CI_AS,
        [origen_visitantes] VARCHAR(255) COLLATE Latin1_General_CI_AS,
        [visitas] VARCHAR(50) COLLATE Latin1_General_CI_AS,
        [observaciones] VARCHAR(255) COLLATE Latin1_General_CI_AS
    );

    BEGIN TRY
        BEGIN TRANSACTION;
        -- Se lee el archivo CSV y se vuelca en la tabla Raw
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
        BULK INSERT ##Staging_Visitas_Raw_CSV
        FROM ''' + @RutaArchivoVisitas + '''
        WITH (
            FORMAT = ''CSV'',            -- Interpreta correctamente los textos entre comillas dobles
            FIELDQUOTE = ''"'',
            FIELDTERMINATOR = '','',     -- Separador de columnas
            ROWTERMINATOR = ''0x0a'',      -- Separador de filas
            FIRSTROW = 2,              -- Saltea los encabezados de las columnas
            CODEPAGE = ''65001''         -- Usa UTF-8 para que acentos y eñes (ej. "Región") se lean perfecto
        );'

        EXEC sp_executesql @sql;

        -- Se realiza un mapeo de las regiones a excepción de la Patagonia (porque tiene región Norte y Austral).
        UPDATE ##Staging_Visitas_Raw_CSV
            SET region_de_destino = CASE LOWER(TRIM(region_de_destino))
                WHEN 'buenos aires' THEN 'Región Centro'
                WHEN 'cordoba'      THEN 'Región Centro Este'
                WHEN 'cuyo'         THEN 'Región Centro'
                WHEN 'litoral'      THEN 'Región Noroeste'
                WHEN 'norte'        THEN 'Región Noroeste'
                ELSE region_de_destino
            END;
        
        -- Las dos regiones de la Patagonia tendrán los mismos datos
        INSERT INTO ##Staging_Visitas_Raw_CSV ([indice_tiempo], [region_de_destino], [origen_visitantes], [visitas], [observaciones])
        SELECT [indice_tiempo], r.region, [origen_visitantes], [visitas], [observaciones]
        FROM ##Staging_Visitas_Raw_CSV
        CROSS JOIN (VALUES ('Región Patagonia Norte'), ('Región Patagonia Austral')) AS r(region)
        WHERE LOWER(TRIM(region_de_destino)) = 'patagonia';

        -- Se eliminan las filas originales sin mapear
        DELETE FROM ##Staging_Visitas_Raw_CSV
        WHERE LOWER(TRIM(region_de_destino)) = 'patagonia';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

    DROP TABLE IF EXISTS ##Staging_Visitas_Raw_CSV;
END