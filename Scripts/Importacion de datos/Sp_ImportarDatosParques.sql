/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
importar datos de parques nacionales desde archivos XML o CSV.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ImportarDatosParques
    @RutaArchivoParques VARCHAR(500),
AS
BEGIN

    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##Staging_Parques') IS NULL
    BEGIN 
        CREATE TABLE Area_Infraestructura.##Staging_Parques (
            IdStaging INT IDENTITY(1,1) PRIMARY KEY,
            Provincia VARCHAR(80) COLLATE Latin1_General_CI_AS,
            Parque VARCHAR(80) COLLATE Latin1_General_CI_AS,
            Region VARCHAR(80) COLLATE Latin1_General_CI_AS,
            Superficie DECIMAL(14,4)
        )
    END
    BEGIN TRY

        -- Verificar que el archivo existe
        DECLARE @ExisteArchivo INT;
        EXEC master.dbo.xp_fileexist @RutaArchivoParques, @ExisteArchivo OUTPUT;
        IF @ExisteArchivo = 0
        BEGIN
            RAISERROR('El archivo no existe o no es accesible.', 16, 1);
            RETURN;
        END

        -- Dependiendo si es csv o xml, ejecutamos uno u otro procedimiento de importación a la tabla temporal de staging
        -- Los datasets originiales no cuentan con un tipo de parque, por lo que es necesario leer un segundo 
        -- Dataset para asignarlos, aunque temporalmente se inserta un tipo de parque "no especificado" para luego actualizarlo con el dataset correcto
        IF right(@RutaArchivoParques, 4) = '.csv'
        BEGIN      
             EXEC Area_Infraestructura.Sp_ImportarDatosParquesCSVTemporal @RutaArchivoParques;
        END
        ELSE IF right(@RutaArchivoParques, 4) = '.xml'
        BEGIN
            EXEC Area_Infraestructura.Sp_ImportarDatosParquesXMLTemporal @RutaArchivoParques;
        END
        ELSE
        BEGIN
            RAISERROR('Formato de archivo no soportado. Solo se permiten archivos .csv o .xml', 16, 1);
            RETURN;
        END

            BEGIN TRANSACTION;

            IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Parque Nacional')
            INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Parque Nacional');

            IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Reserva Natural')
                INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Reserva Natural');

            IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Monumento Natural')
                INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Monumento Natural');

            IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Tipo_Parque WHERE Descripcion = 'Otro / No Especificado')
                INSERT INTO Area_Infraestructura.Tipo_Parque (Descripcion) VALUES ('Otro / No Especificado');

            -- Paso 1: Insertar Regiones faltantes            
            INSERT INTO Area_Infraestructura.Region (Nombre)
            SELECT DISTINCT s.Region
            FROM Area_Infraestructura.##Staging_Parques s
            WHERE s.Region IS NOT NULL 
            AND s.Region <> ''
            AND NOT EXISTS (
                SELECT 1 FROM Area_Infraestructura.Region r WHERE r.Nombre = s.Region
            );

            -- Paso 2: Insertar Provincias faltantes (Asignándoles la FK de Región correspondiente)
            INSERT INTO Area_Infraestructura.Provincia (IdRegion, Nombre)
            SELECT DISTINCT r.IdRegion, s.Provincia
            FROM Area_Infraestructura.##Staging_Parques s
            INNER JOIN Area_Infraestructura.Region r ON s.Region = r.Nombre
            WHERE s.Provincia IS NOT NULL 
            AND s.Provincia <> ''
            AND NOT EXISTS (
                SELECT 1 FROM Area_Infraestructura.Provincia p WHERE p.Nombre = s.Provincia
            );

            -- Paso 3: Insertar Parques (Asignándoles la FK de Provincia correspondiente, y el tipo de parque evaluando su nombre)
            INSERT INTO Area_Infraestructura.Parque (IdProvincia, IdTipoParque, Nombre, Superficie)
            SELECT DISTINCT 
                p.IdProvincia,
                tp.IdTipoParque,
                s.Parque,
                s.Superficie
            FROM Area_Infraestructura.##Staging_Parques s
            INNER JOIN Area_Infraestructura.Provincia p ON s.Provincia = p.Nombre
            
            -- Evaluamos el nombre del área en Staging y lo unimos con su descripción real
            INNER JOIN Area_Infraestructura.Tipo_Parque tp ON tp.Descripcion = 
                CASE 
                    WHEN s.Parque LIKE '%Parque%' THEN 'Parque Nacional'
                    WHEN s.Parque LIKE '%Reserva%' THEN 'Reserva Natural'
                    WHEN s.Parque LIKE '%Monumento%' THEN 'Monumento Natural'
                    ELSE 'Otro / No Especificado'
                END
                
            WHERE s.Parque IS NOT NULL 
            AND s.Parque <> ''
            AND NOT EXISTS (
                SELECT 1 
                FROM Area_Infraestructura.Parque pq 
                WHERE pq.Nombre = s.Parque AND pq.IdProvincia = p.IdProvincia
            );

        COMMIT TRANSACTION;
        PRINT 'Migración de datos completada con éxito.';

    DROP TABLE Area_Infraestructura.##Staging_Parques;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        DROP TABLE IF EXISTS Area_Infraestructura.##Staging_Parques;
    END CATCH
END
GO