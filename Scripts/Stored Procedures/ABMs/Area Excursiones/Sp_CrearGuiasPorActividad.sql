/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear una relación entre guía y actividad.
*/


/*
si se quiere asignar un guia a una actividad, PRIMERO se deber verificar que ese guia TENGA la habilitación necesaria para esa actividad,
y luego se asigna el guia a la actividad.
*/

USE SGParquesNacionales
go
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearGuiasPorActividad
    @IdGuia INT,
    @IdActividad INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --Validamos que el guia y la actividad existan
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía no existe.', 16, 1)
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad)
        BEGIN
            RAISERROR('La actividad no existe.', 16, 1)
        END
        --ahora debemos validar que el guia tenga la HABILITACION para esa actividad
        IF NOT EXISTS (
            -- 1er nivel: Agarramos todas las habilitaciones que pide la actividad
            SELECT 1 FROM Area_Excursiones.Habilitaciones_por_Actividad ha
            WHERE ha.IdActividad = @IdActividad
            AND NOT EXISTS (
                -- 2do nivel: nos fijamos si alguna de esas NO la tiene el guía (o está vencida)
                SELECT 1 FROM Area_Excursiones.Habilitacion_Guia hg 
                WHERE hg.IdGuia = @IdGuia
                AND hg.IdHabilitacion = ha.IdHabilitacion
                AND hg.Fecha_Fin_Validez >= GETDATE() --la habilitación debe estar vigente
            )
        )
        BEGIN 
            -- Si llegamos acá, significa que la doble negación fue verdadera.
            -- NO hay ninguna habilitación exigida que el guía NO tenga. 
            -- Por lo tanto, LAS TIENE TODAS.
            INSERT INTO Area_Excursiones.Guias_por_actividad (IdGuia, IdActividad) 
            VALUES (@IdGuia, @IdActividad);
        END
        ELSE
        BEGIN
            RAISERROR('El guía no tiene la habilitación necesaria para esta actividad.', 16, 1)
        END

    END TRY


    BEGIN CATCH
        -- 1. Capturamos los datos del error original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- 2. Aseguramos que el estado sea válido para que no falle el RAISERROR
        IF @ErrorState = 0 SET @ErrorState = 1;

        -- 3. Volvemos a lanzar el mismo error exacto que saltó en el TRY
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH

END

GO