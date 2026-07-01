/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de crear el Stored Procedure utilizado para generar seed data del área de excursiones.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_AreaExcursionesSeed
    @Actividades BIT = 1,
    @Guias BIT = 1,
    @Asignaciones BIT = 1
AS
BEGIN
    BEGIN TRY
        set nocount on;
        BEGIN TRANSACTION;

            -- ==============================================================================
            --     CREACIÓN DE ACTIVIDADES, GUÍAS Y ASIGNACIÓN DE ESPECIALIDADES
            -- ==============================================================================

            IF @Actividades = 1
            BEGIN
                -- Creación de 30 Actividades distribuidas en los Parques
                -- cada actividad debe tener una habilitacion 
                IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad)
                BEGIN
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Senderismo';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Trekking';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Navegacion';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Cabalgata';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Avistaje de Aves';
                    EXEC Area_Excursiones.Sp_CrearTipoActividad 'Observacion de Flora/Fauna';
                END

                IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion)
                BEGIN
                    INSERT INTO Area_Excursiones.Habilitacion (Descripcion) VALUES 
                    ('Primeros Auxilios y RCP'), 
                    ('Rescate Acuático y Buceo'), 
                    ('Alta Montaña y Escalada'), 
                    ('Supervivencia en Entornos Extremos'), 
                    ('Observación de Flora y Fauna Local');
                END

                IF (SELECT COUNT(*) FROM Area_Excursiones.Actividad) < 30
                BEGIN
                    DECLARE @cantActividades INT = 0;
                    WHILE @cantActividades < 30
                    BEGIN
                        DECLARE @IdTipoActividad INT, @IdParque INT;
                        DECLARE @NombreTipoActividad VARCHAR(30) ;
                        DECLARE @NombreActividad VARCHAR(30) = 'Tour Guiado';
                        DECLARE @Costo decimal(10, 2) = 5000 + (ABS(CHECKSUM(NEWID())) % 10000);
                        DECLARE @Duracion INT = 2 + (ABS(CHECKSUM(NEWID())) % 6);
                        DECLARE @Cupo_maximo INT = 20 + (ABS(CHECKSUM(NEWID())) % 30);

                        SET @IdTipoActividad = (SELECT TOP 1 IdTipoActividad FROM Area_Excursiones.Tipo_Actividad ORDER BY NEWID());
                        SET @NombreTipoActividad = (SELECT TOP 1 Descripcion FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = @IdTipoActividad);
                        SET @NombreActividad = @NombreActividad + ' ' + @NombreTipoActividad;
                        
                        SET @IdParque = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());

                        EXEC Area_Excursiones.Sp_CrearActividad
                            @tipoActividad = @IdTipoActividad,
                            @idParque = @IdParque,
                            @Nombre = @NombreActividad,
                            @Costo = @Costo,
                            @Duracion = @Duracion,
                            @Cupo_maximo = @Cupo_maximo

                        -- Asignar requisitos (1 o 2 habilitaciones por actividad)
                        INSERT INTO Area_Excursiones.Habilitaciones_por_Actividad (IdActividad, IdHabilitacion)
                        SELECT A.IdActividad, H.IdHabilitaciones
                        FROM Area_Excursiones.Actividad A
                        CROSS APPLY (
                            -- Selecciona 1 o 2 habilitaciones aleatorias para cada actividad
                            SELECT TOP (1 + ABS(CHECKSUM(NEWID())) % 2) IdHabilitaciones 
                            FROM Area_Excursiones.Habilitacion ORDER BY NEWID()
                        ) H
                        WHERE NOT EXISTS (
                            SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad HA 
                            WHERE HA.IdActividad = A.IdActividad AND HA.IdHabilitacion = H.IdHabilitaciones
                        );

                        SET @cantActividades = @cantActividades + 1;
                    END
                END
            END

            -- Creación de 20 Guías con especialidades asignados a actividades de sus respectivos parques
            -- cada guia debe cumplir con todas las habilitaciones de las actividades que se realizan en su parque asignado, por lo que se asigna la habilitacion 
            -- al guia y luego se relaciona el guia con las actividades de su parque que correspondan a esa habilitacion

            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Senderismo';
            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Trekking';
            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Rafting';
            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Cabalgatas';
            EXEC Area_Excursiones.Sp_CrearEspecialidad 'Especialidad en Avistaje de Aves';

            IF @Guias = 1
            BEGIN
                DECLARE @NomYApeGuias TABLE (id INT IDENTITY(1,1), nombre VARCHAR(30), apellido VARCHAR(30));
                INSERT INTO @NomYApeGuias VALUES
                ('Thom', 'Yorke'), ('Jonny', 'Greenwood'), 
                ('Colin', 'Greenwood'), ('Ed', 'O''Brien'),
                ('Phil', 'Selway'), ('Robert', 'Smith'),
                ('Simon', 'Gallup'), ('Jason', 'Cooper'), 
                ('Roger', 'O''Donnell'), ('Reeves', 'Gabrels'),
                ('Michael', 'Dempsey'), ('Andy', 'Anderson'),
                ('Perry', 'Bamonte'), ('Nicholas', 'Matthews'),
                ('Johnny', 'Braddock'), ('Adam', 'Virostko'),
                ('Dan', 'Juarez'), ('Bradley', 'Iverson'),
                ('Ray', 'Toro'), ('Mikey', 'Way');

                DECLARE @TotalGuias INT = (SELECT COUNT(*) FROM Area_Excursiones.Guia WHERE Nombre LIKE 'GuiaNom%');
                DECLARE @RandParqueGuia INT;
                DECLARE @RandEspId INT;
                DECLARE @DniGuia CHAR(8);
                DECLARE @NomGuia VARCHAR(30);
                DECLARE @ApeGuia VARCHAR(30);
                DECLARE @TituloGuia VARCHAR(30);

                -- Declaración y asignación dinámica de los límites
                DECLARE @limInf INT = 1;
                DECLARE @limSup INT = (SELECT COUNT(*) FROM @NomYApeGuias) + 1;
                IF @TotalGuias < 20
                BEGIN
                    DECLARE @GuiaNo INT = 1;
                    WHILE @GuiaNo <= 20
                    BEGIN
                        SET @RandParqueGuia = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());
                        SET @RandEspId = (SELECT TOP 1 IdEspecialidad FROM Area_Excursiones.Especialidad ORDER BY NEWID());
                        SET @DniGuia = CAST(CAST(RAND() * 89999999 + 10000000 AS INT) AS CHAR(8));
                        SET @NomGuia = (SELECT nombre FROM @NomYApeGuias WHERE id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
                        SET @ApeGuia = (SELECT apellido FROM @NomYApeGuias WHERE id = CAST(RAND()*(@limSup - @limInf)+@limInf AS INT));
                        SET @TituloGuia = 'Licenciado en turismo';

                        EXEC Area_Excursiones.Sp_CrearGuia @DniGuia, @RandParqueGuia, @RandEspId, @NomGuia, @ApeGuia, @TituloGuia
                        DECLARE @NewGuiaId INT = SCOPE_IDENTITY();
                        SET @GuiaNo = @GuiaNo + 1;
                    END
                END;
                -- Eliminamos los guias repetidos
                -- Acá los parámetros por los que partimos son los que se van a contar como repetidos
                WITH cte(idGuia, nombre, apellido, ocurrencias) AS (
                    SELECT idGuia, nombre, apellido, 
                    ROW_NUMBER() OVER(PARTITION BY nombre, apellido ORDER BY idGuia) as duplicados
                    from Area_Excursiones.Guia
                )
                delete from cte where ocurrencias > 1;

                -- Asignar Habilitaciones a los Guías
                INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion, Fecha_Inicio_Validez, Fecha_Fin_Validez)
                SELECT 
                    G.IdGuia, 
                    H.IdHabilitaciones, 
                    DATEADD(DAY, -30, GETDATE()), -- Inicio hace 30 días
                    DATEADD(DAY, 365, GETDATE())  -- Vence en 1 año
                FROM Area_Excursiones.Guia G
                CROSS APPLY (
                    -- Truco: Si el ID del guía es par, le damos TODAS las habilitaciones (Guía Maestro).
                    -- Si es impar, le damos solo 2 aleatorias. Esto garantiza que haya asignaciones exitosas.
                    SELECT TOP (CASE WHEN G.IdGuia % 2 = 0 THEN 5 ELSE 2 END) IdHabilitaciones
                    FROM Area_Excursiones.Habilitacion ORDER BY NEWID()
                ) H
                WHERE NOT EXISTS (
                    SELECT 1 FROM Area_Excursiones.Habilitacion_Guia HG 
                    WHERE HG.IdGuia = G.IdGuia AND HG.IdHabilitacion = H.IdHabilitaciones
                );
            END

            -- ==============================================================================
            -- ASIGNACIÓN DE GUÍAS A ACTIVIDADES (respetando las habilitaciones requeridas)
            -- ==============================================================================
            
            if @Asignaciones = 1
            BEGIN
                IF OBJECT_ID('tempdb..#ParejasValidas') IS NULL
                BEGIN
                    CREATE TABLE #ParejasValidas (Id INT IDENTITY(1,1), IdGuia INT, IdActividad INT);
                END

                -- Filtramos usando exactamente la misma lógica de doble negación del SP
                INSERT INTO #ParejasValidas (IdGuia, IdActividad)
                SELECT G.IdGuia, A.IdActividad
                FROM Area_Excursiones.Guia G
                CROSS JOIN Area_Excursiones.Actividad A
                WHERE NOT EXISTS (
                    SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad HA
                    WHERE HA.IdActividad = A.IdActividad
                    AND NOT EXISTS (
                        SELECT 1 FROM Area_Excursiones.Habilitacion_Guia HG 
                        WHERE HG.IdGuia = G.IdGuia AND HG.IdHabilitacion = HA.IdHabilitacion 
                        AND HG.Fecha_Fin_Validez >= GETDATE()
                    )
                )
                AND NOT EXISTS (
                    -- Evitamos insertar si la pareja ya existe en Guias_por_Actividad
                    SELECT 1 FROM Area_Excursiones.Guias_por_Actividad GA 
                    WHERE GA.IdGuia = G.IdGuia AND GA.IdActividad = A.IdActividad
                );

                -- Ejecutamos el SP iterando la tabla temporal
                DECLARE @MaxId INT = (SELECT ISNULL(MAX(Id), 0) FROM #ParejasValidas);
                DECLARE @Iterador INT = 1;
                DECLARE @IdGuiaActual INT, @IdActividadActual INT;

                WHILE @Iterador <= @MaxId
                BEGIN
                    SELECT @IdGuiaActual = IdGuia, @IdActividadActual = IdActividad 
                    FROM #ParejasValidas WHERE Id = @Iterador;

                    EXEC Area_Excursiones.Sp_CrearGuiasPorActividad 
                        @IdGuia = @IdGuiaActual, 
                        @IdActividad = @IdActividadActual;

                    SET @Iterador = @Iterador + 1;
                END
                DROP TABLE IF EXISTS #ParejasValidas;
            END

        COMMIT TRANSACTION
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al generar seed data del área de excursiones: %s', 16, 1, @ErrorMessage);
        ROLLBACK TRANSACTION;
    END CATCH
END