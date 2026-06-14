/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para modificar una especialidad.
*/

USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarEspecialidad
    @IdEspecialidad INT,
    @Descripcion VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Validar que la especialidad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @IdEspecialidad)
        BEGIN
            RAISERROR('La especialidad con el Id proporcionado no existe.', 16, 1)
            RETURN
        END
        --validar que la descripción sea válida
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
            RETURN
        END

        -- Modificar la especialidad
        UPDATE Area_Excursiones.Especialidad
        SET Descripcion = @Descripcion
        WHERE IdEspecialidad = @IdEspecialidad

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
