/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para la importación masiva
de datos a la tabla Empresa_Concesionaria.  
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.Sp_ImportarDatosEmpresas
    @RutaArchivoEmpresas VARCHAR(255),
    @CrearConcesiones BIT = 0 -- Parámetro opcional para decidir si se crean concesiones automáticamente
AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION;
    SET NOCOUNT ON;
      
        -- Verificar que el archivo existe
        DECLARE @ExisteArchivo INT;
        EXEC master.dbo.xp_fileexist @RutaArchivoEmpresas, @ExisteArchivo OUTPUT;
        IF @ExisteArchivo = 0
        BEGIN
            RAISERROR('El archivo no existe o no es accesible.', 16, 1);
            RETURN;
        END

        IF OBJECT_ID('tempdb..#Staging_Organizaciones') IS NULL
        BEGIN
            CREATE TABLE #Staging_Organizaciones (
                IdStaging INT IDENTITY(1,1) PRIMARY KEY,
                Organizacion VARCHAR(255) COLLATE Latin1_General_CI_AS,
                Rubro VARCHAR(255) COLLATE Latin1_General_CI_AS,
                Provincia VARCHAR(80) COLLATE Latin1_General_CI_AS,
                Fecha_Distincion DATE
            );
        END

        -- Importar los datos del archivo CSV a la tabla temporal de staging
        IF OBJECT_ID('tempdb..#Staging_Raw_CSV') IS NULL
        BEGIN
            -- Adaptado a las 14 columnas del CSV
            CREATE TABLE #Staging_Raw_CSV (
                organizacion VARCHAR(255), 
                rubro VARCHAR(255),
                subrubro VARCHAR(255),
                calle VARCHAR(255),
                numero VARCHAR(50),
                pais VARCHAR(50),
                provincia VARCHAR(80),
                ciudad VARCHAR(80),
                telefono VARCHAR(50),
                facebook VARCHAR(255),
                web VARCHAR(255),
                programa VARCHAR(255),
                fecha_distincion VARCHAR(50),
                fecha_revalidacion VARCHAR(50)
            );
        END

        DECLARE @Sql NVARCHAR(MAX);
        SET @Sql = N'
        BULK INSERT #Staging_Raw_CSV
        FROM ''' + @RutaArchivoEmpresas + '''
        WITH (FORMAT = ''CSV'', FIELDQUOTE = ''"'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'', FIRSTROW = 2, CODEPAGE = ''65001'');';

        EXEC sp_executesql @sql;

        -- Insertar los datos desde la tabla de staging a la tabla global de staging, realizando las transformaciones necesarias
        INSERT INTO #Staging_Organizaciones (Organizacion, Rubro, Provincia, Fecha_Distincion)
        SELECT 
            organizacion,
            rubro,
            provincia,
            TRY_CAST(fecha_distincion AS DATE)
        FROM #Staging_Raw_CSV
        WHERE organizacion IS NOT NULL AND organizacion <> '';

        -- 1. Insertar Estados de Canon (si no existen)
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon)
        BEGIN
            INSERT INTO Area_Negocios.Estado_Canon (Descripcion) 
            VALUES ('Vigente'), ('Adeudado'), ('Saldado en Término'), ('Saldado con Atraso'), ('Exento'), ('Extinguido');
        END

        -- 2. Insertar o actualizar Empresas Concesionarias
        MERGE Area_Negocios.Empresa_Concesionaria AS Target
        USING (SELECT DISTINCT Organizacion FROM #Staging_Organizaciones WHERE Organizacion IS NOT NULL AND Organizacion <> '') AS Source
        ON Target.Nombre = Source.Organizacion
        WHEN MATCHED THEN
            UPDATE SET Nombre = Source.Organizacion
        WHEN NOT MATCHED THEN
            INSERT (Nombre) VALUES (Source.Organizacion);

        -- 3. Insertar o actualizar Tipos de Actividad
        MERGE Area_Negocios.Tipo_Actividad_Concesion AS Target
        USING(
            SELECT DISTINCT Rubro 
            FROM #Staging_Organizaciones s
            WHERE NOT EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion t WHERE t.Descripcion = s.Rubro)
        ) AS Source
        ON Target.Descripcion = Source.Rubro
        WHEN MATCHED THEN
            UPDATE SET Descripcion = Source.Rubro
        WHEN NOT MATCHED THEN
            INSERT (Descripcion) VALUES (Source.Rubro);

        -- 4. Generar las Concesiones solo si se indica
        IF @CrearConcesiones = 1
        BEGIN
            DECLARE @MinId INT = (select MIN(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
            DECLARE @MaxId INT = (select MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
            WHILE @MinId <= @MaxId
            BEGIN
                DECLARE @Random
                EXECUTE Area_Negocios.Sp_CrearConcesion 
                SET @MInId = @MinId + 1;
            END

@IdTipoActividadConcesion int,@IdEmpresa int,@IdParque int,@Fecha_Inicio date,@Fecha_Fin date
            -- 4. Generar las Concesiones
            -- Usamos OUTER APPLY para buscar 1 parque aleatorio (NEWID) de la provincia que viene en el CSV. 
            -- Si esa provincia no tiene parque en tu BD, asigna un parque aleatorio de cualquier lugar.
            INSERT INTO Area_Negocios.Concesion (IdTipoActividadConcesion, IdEmpresa, IdParque, Fecha_Inicio, Fecha_Fin)
            SELECT 
                tac.IdTipoActividadConcesion,
                ec.IdEmpresa,
                ISNULL(ParqueAleatorioProvincia.IdParque, ParqueAleatorioNacional.IdParque),
                ISNULL(s.Fecha_Distincion, GETDATE()), -- Fallback por si la fecha viene vacía
                -- Fecha de fin aleatoria entre 365 y 730 días (1 o 2 años) a partir de hoy
                DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365 + 365, GETDATE())
            FROM #Staging_Organizaciones s
            INNER JOIN Area_Negocios.Empresa_Concesionaria ec ON ec.Nombre = s.Organizacion
            INNER JOIN Area_Negocios.Tipo_Actividad_Concesion tac ON tac.Descripcion = s.Rubro
            OUTER APPLY (
                SELECT TOP 1 pq.IdParque 
                FROM Area_Infraestructura.Parque pq
                INNER JOIN Area_Infraestructura.Provincia pr ON pq.IdProvincia = pr.IdProvincia
                WHERE pr.Nombre LIKE '%' + s.Provincia + '%'
                ORDER BY NEWID()
            ) ParqueAleatorioProvincia
            CROSS APPLY (
                SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID()
            ) ParqueAleatorioNacional
            WHERE NOT EXISTS (
                SELECT 1 FROM Area_Negocios.Concesion c WHERE c.IdEmpresa = ec.IdEmpresa AND c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
            );

            -- 5. Generar el Primer Canon de cada Concesión recién creada
            DECLARE @IdVigente INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Vigente');
            
            INSERT INTO Area_Negocios.Canon (IdConcesion, IdEstado, Monto_Mensual, Fecha_Vencimiento)
            SELECT 
                c.IdConcesion,
                @IdVigente,
                CASE 
                    -- Rangos aleatorios según rubro
                    WHEN tac.Descripcion LIKE '%Alojamiento%' THEN 300000 + (ABS(CHECKSUM(NEWID())) % 200000)
                    WHEN tac.Descripcion LIKE '%Gastronomía%' THEN 150000 + (ABS(CHECKSUM(NEWID())) % 100000)
                    ELSE 50000 + (ABS(CHECKSUM(NEWID())) % 50000)
                END,
                DATEADD(DAY, 7 + (ABS(CHECKSUM(NEWID())) % 24), GETDATE())
            FROM Area_Negocios.Concesion c
            INNER JOIN Area_Negocios.Tipo_Actividad_Concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
            WHERE NOT EXISTS (SELECT 1 FROM Area_Negocios.Canon ca WHERE ca.IdConcesion = c.IdConcesion);
        END

        COMMIT TRANSACTION;
        
        IF @CrearConcesiones = 1
            PRINT 'Negocios y concesiones creados con éxito.';
        ELSE
            PRINT 'Negocios creados con éxito.';

        DROP TABLE #Staging_Organizaciones;
        DROP TABLE #Staging_Raw_CSV;
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
            DECLARE @ErrorState INT = ERROR_STATE();
            RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
            ROLLBACK TRANSACTION;
            DROP TABLE IF EXISTS #Staging_Organizaciones;
            DROP TABLE IF EXISTS #Staging_Raw_CSV;
            RETURN;
        END
    END CATCH
END