
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
    @RutaArchivoEmpresas VARCHAR(255)
AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION;
    SET NOCOUNT ON;

        IF OBJECT_ID('tempdb..##Staging_Organizaciones') IS NOT NULL
            DROP TABLE ##Staging_Organizaciones;

        CREATE TABLE ##Staging_Organizaciones (
            IdStaging INT IDENTITY(1,1) PRIMARY KEY,
            Organizacion VARCHAR(255) COLLATE Latin1_General_CI_AS,
            Rubro VARCHAR(255) COLLATE Latin1_General_CI_AS,
            Provincia VARCHAR(80) COLLATE Latin1_General_CI_AS,
            Fecha_Distincion DATE
        );
        
        -- Verificar que el archivo existe
        DECLARE @ExisteArchivo INT;
        EXEC master.dbo.xp_fileexist @RutaArchivoEmpresas, @ExisteArchivo OUTPUT;
        IF @ExisteArchivo = 0
        BEGIN
            RAISERROR('El archivo no existe o no es accesible.', 16, 1);
            RETURN;
        END

        -- Importar los datos del archivo CSV a la tabla temporal de staging
        EXEC Area_Negocios.Sp_ImportarDatosEmpresasCSVTemporal @RutaArchivoEmpresas;

        -- 1. Insertar Estados de Canon (si no existen)
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Vigente')
        BEGIN
            INSERT INTO Area_Negocios.Estado_Canon (Descripcion) 
            VALUES ('Vigente'), ('Adeudado'), ('Saldado en Término'), ('Saldado con Atraso'), ('Exento'), ('Extinguido');
        END

        -- 2. Insertar Empresas Concesionarias (Estado 1 = Activa)
        INSERT INTO Area_Negocios.Empresa_Concesionaria (Nombre)
        SELECT DISTINCT Organizacion
        FROM ##Staging_Organizaciones s
        WHERE NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria e WHERE e.Nombre = s.Organizacion);

        -- 3. Insertar Tipos de Actividad
        INSERT INTO Area_Negocios.Tipo_Actividad_Concesion (Descripcion)
        SELECT DISTINCT Rubro 
        FROM ##Staging_Organizaciones s
        WHERE NOT EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion t WHERE t.Descripcion = s.Rubro);

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
        FROM ##Staging_Organizaciones s
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
                -- Rangos aleatorios según rubro en Argentina (Resoluciones APN)
                WHEN tac.Descripcion LIKE '%Alojamiento%' THEN 300000 + (ABS(CHECKSUM(NEWID())) % 200000)
                WHEN tac.Descripcion LIKE '%Gastronomía%' THEN 150000 + (ABS(CHECKSUM(NEWID())) % 100000)
                ELSE 50000 + (ABS(CHECKSUM(NEWID())) % 50000)
            END,
            DATEADD(DAY, 7 + (ABS(CHECKSUM(NEWID())) % 24), GETDATE())
        FROM Area_Negocios.Concesion c
        INNER JOIN Area_Negocios.Tipo_Actividad_Concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
        WHERE NOT EXISTS (SELECT 1 FROM Area_Negocios.Canon ca WHERE ca.IdConcesion = c.IdConcesion);

        COMMIT TRANSACTION;
        PRINT 'Negocios y Concesiones creados con éxito.';
        DROP TABLE ##Staging_Organizaciones;
    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN	
            RAISERROR('Algo salio mal en la importación de datos', 16, 1);
            ROLLBACK TRANSACTION;
            DROP TABLE IF EXISTS ##Staging_Organizaciones;
            RETURN;
        END
    END CATCH
END
