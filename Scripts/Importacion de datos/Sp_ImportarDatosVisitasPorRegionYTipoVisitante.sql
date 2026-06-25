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

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ImportarDatosVisitasPorRegionYTipoVisitante
    @RutaArchivoVisitas VARCHAR(255),
    @Año INT,
    @Mes INT
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
    IF OBJECT_ID('tempdb..#Staging_Visitas_Raw_CSV') IS NULL
    BEGIN
        CREATE TABLE #Staging_Visitas_Raw_CSV (
            [indice_tiempo] VARCHAR(50) COLLATE Latin1_General_CI_AS,
            [region_de_destino] VARCHAR(255) COLLATE Latin1_General_CI_AS,
            [origen_visitantes] VARCHAR(255) COLLATE Latin1_General_CI_AS,
            [visitas] VARCHAR(50) COLLATE Latin1_General_CI_AS,
            [observaciones] VARCHAR(300) COLLATE Latin1_General_CI_AS
        );
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        -- Se lee el archivo CSV y se vuelca en la tabla Raw
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'
        BULK INSERT #Staging_Visitas_Raw_CSV
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
        -- print 'Datos importados a tabla temporal. Listo para procesar datos.';
        -- Se realiza un mapeo de las regiones a excepción de la Patagonia (porque tiene región Norte y Austral).
        UPDATE #Staging_Visitas_Raw_CSV
            SET region_de_destino = CASE LOWER(TRIM(region_de_destino))
                WHEN 'buenos aires' THEN 'Región Centro'
                WHEN 'cordoba'      THEN 'Región Centro Este'
                WHEN 'cuyo'         THEN 'Región Centro'
                WHEN 'litoral'      THEN 'Región Noroeste'
                WHEN 'norte'        THEN 'Región Noroeste'
                ELSE region_de_destino
            END;
        -- print 'Mapeo de regiones completado.';
        -- Las dos regiones de la Patagonia tendrán los mismos datos
        INSERT INTO #Staging_Visitas_Raw_CSV ([indice_tiempo], [region_de_destino], [origen_visitantes], [visitas], [observaciones])
        SELECT [indice_tiempo], r.region, [origen_visitantes], [visitas], [observaciones]
        FROM #Staging_Visitas_Raw_CSV
        CROSS JOIN (VALUES ('Región Patagonia Norte'), ('Región Patagonia Austral')) AS r(region)
        WHERE LOWER(TRIM(region_de_destino)) = 'patagonia';

        -- Se eliminan las filas originales sin mapear
        DELETE FROM #Staging_Visitas_Raw_CSV
        WHERE LOWER(TRIM(region_de_destino)) = 'patagonia'
        -- print 'Filas originales eliminadas.';

        -- Se crea una tabla temporal para almacenar los datos ya procesados y casteados
        IF OBJECT_ID('tempdb..#VisitasProcesadas') IS NULL
        BEGIN
            CREATE TABLE #VisitasProcesadas (
                ID INT IDENTITY(1,1) PRIMARY KEY,
                FechaMes DATE,
                RegionCSV VARCHAR(50),
                OrigenCSV VARCHAR(50),
                TotalVisitas INT
            );
        END

        -- Se crean los tipos de visitantes si no existen
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = 'Residente')
        BEGIN
            EXEC Area_Comercial.Sp_CrearTipoVisitante @Descripcion = 'Residente';
        END
        IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = 'No residente')
        BEGIN
            EXEC Area_Comercial.Sp_CrearTipoVisitante @Descripcion = 'No residente';
        END

        -- Filtrar y castear los datos base
        INSERT INTO #VisitasProcesadas (FechaMes, RegionCSV, OrigenCSV, TotalVisitas)
        SELECT 
            TRY_CAST([indice_tiempo] AS DATE),
            [region_de_destino],
            CASE 
                WHEN [origen_visitantes] = 'residentes' THEN 'Residente'
                WHEN [origen_visitantes] = 'no residentes' THEN 'No residente'
                ELSE [origen_visitantes]
            END,
            TRY_CAST([visitas] AS INT)
        FROM #Staging_Visitas_Raw_CSV
        WHERE [origen_visitantes] <> 'total'
          AND TRY_CAST([visitas] AS INT) > 0
          AND YEAR(TRY_CAST([indice_tiempo] AS DATE)) = @Año
          AND MONTH(TRY_CAST([indice_tiempo] AS DATE)) = @Mes;
        -- print 'Datos procesados y casteados. Listo para registrar ventas.';

        -- Se crean las ventas de entradas que corresponden a un parque random
        -- de la region de destino para un año y mes determinados
        DECLARE @MinId INT = 1;
        DECLARE @MaxId INT;
        SELECT @MaxId = ISNULL(MAX(ID), 0) FROM #VisitasProcesadas;

        WHILE @MinId <= @MaxId
        BEGIN
            DECLARE @FechaMesFila DATE, @RegionCSV VARCHAR(50), @OrigenCSV VARCHAR(30), @TotalVisitasFila INT;
            SELECT 
                @FechaMesFila = FechaMes, 
                @RegionCSV = RegionCSV, 
                @OrigenCSV = OrigenCSV, 
                @TotalVisitasFila = TotalVisitas
            FROM #VisitasProcesadas 
            WHERE ID = @MinId;

            -- Dividir las visitas de este mes en 4 semanas
            DECLARE @Semana INT = 1;
            WHILE @Semana <= 4
            BEGIN
                DECLARE @VisitasSemana INT = CEILING(@TotalVisitasFila / 4.0);
                
                -- Seleccionar un día al azar dentro de la semana evaluada
                DECLARE @StartDay INT = (@Semana - 1) * 7 + 1;
                DECLARE @EndDay INT = IIF(@Semana = 4, DAY(EOMONTH(@FechaMesFila)), @Semana * 7);
                DECLARE @RandomDay INT = @StartDay + ABS(CHECKSUM(NEWID())) % (@EndDay - @StartDay + 1);
                DECLARE @FechaVenta DATE = DATEADD(DAY, @RandomDay - 1, @FechaMesFila);
                -- print 'Fecha de venta generada: ' + CAST(@FechaVenta AS VARCHAR);

                -- Seleccionar una Forma de Pago aleatoria
                DECLARE @DescFormaDePago VARCHAR(30) = NULL;
                SELECT TOP 1 @DescFormaDePago = Descripcion FROM Area_Comercial.Forma_De_Pago ORDER BY NEWID();
                -- print 'Forma de pago seleccionada: ' + @DescFormaDePago;

                -- Seleccionar un Punto de Venta aleatorio
                DECLARE @IdPdv INT = NULL;
                SELECT TOP 1 @IdPdv = IdPuntoDeVenta FROM Area_Comercial.Punto_De_Venta ORDER BY NEWID();
                -- print 'Punto de venta seleccionado: ' + CAST(@IdPdv AS VARCHAR);

                -- Seleccionar un parque random de la región de destino
                DECLARE @ParqueRandom VARCHAR(80) = (SELECT TOP 1 p.Nombre FROM Area_Infraestructura.Parque p
                               JOIN Area_Infraestructura.Provincia pr ON p.IdProvincia = pr.IdProvincia
                               JOIN Area_Infraestructura.Region r ON pr.IdRegion = r.IdRegion
                               WHERE r.Nombre = @RegionCSV
                               ORDER BY NEWID());
                -- print 'Parque seleccionado: ' + @ParqueRandom;

                -- print 'Registrando venta: ' + @ParqueRandom + ' - ' + CAST(@VisitasSemana AS VARCHAR) + ' entradas - ' + @OrigenCSV + ' - ' + CAST(@FechaVenta AS VARCHAR) + ' - ' + @DescFormaDePago;

                -- Insertar una venta de entradas para esta semana
                EXEC Area_Comercial.Sp_RegistrarVentaEntradas
                    @Parque = @ParqueRandom, -- Elegir un parque random de la región
                    @CantidadEntradas = @VisitasSemana,
                    @TipoVisitante = @OrigenCSV,
                    @Actividad = NULL, -- No se asigna actividad porque no tenemos esa info en el CSV
                    @Fecha = @FechaVenta,
                    @IdPuntoDeVenta = @IdPdv,
                    @FormaDePago = @DescFormaDePago;

                SET @Semana = @Semana + 1;
            END
            SET @MinId = @MinId + 1;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
    DROP TABLE IF EXISTS #Staging_Visitas_Raw_CSV;
    DROP TABLE IF EXISTS #VisitasProcesadas;
END