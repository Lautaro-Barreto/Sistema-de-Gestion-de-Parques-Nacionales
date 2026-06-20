/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para modificar un guia.
*/

USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_ModificarGuia
    @IdGuia INT,
    @Dni CHAR(8),
    @IdParque INT,
    @IdEspecialidad INT,
    @Nombre VARCHAR(30),
    @Apellido VARCHAR(30),
    @Titulo VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY 
        -- Validar que el guia exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guia con el Id proporcionado no existe.', 16, 1)

        END
        -- Validar que el parque exista
        IF NOT EXISTS (SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            RAISERROR('El parque con el Id proporcionado no existe.', 16, 1)
            
        END
        -- Validar que la especialidad exista
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Especialidad WHERE IdEspecialidad = @IdEspecialidad)
        BEGIN
            RAISERROR('La especialidad con el Id proporcionado no existe.', 16, 1)
            
        END
        --validar que el dni sea válido
        IF (@DNI LIKE '%[^0-9]%' OR LEN(@DNI) NOT BETWEEN 7 AND 8)
        BEGIN
            RAISERROR('DNI inválido: debe contener solo números y tener entre 7 y 8 dígitos.', 16, 1);
        END

        DECLARE @IdGuiaRepetido INT
        SELECT @IdGuiaRepetido = IdGuia FROM Area_Excursiones.Guia WHERE DNI = @Dni AND IdGuia != @IdGuia
        IF @IdGuiaRepetido IS NOT NULL
        BEGIN
            RAISERROR('El DNI proporcionado ya está registrado para otro guía. Guia Numero: %d', 16, 1, @IdGuiaRepetido)
        END

        --validar que el nombre, apellido y título sean válidos
        IF @Nombre IS NULL OR LEN(@Nombre) = 0
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1) 
        END

        IF @Apellido IS NULL OR LEN(@Apellido) = 0
        BEGIN
            RAISERROR('El apellido debe tener entre 1 y 30 caracteres.', 16, 1)   
        END

        IF @Titulo IS NULL OR LEN(@Titulo) = 0
        BEGIN
            RAISERROR('El título debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

        -- Modificar el guia
        UPDATE Area_Excursiones.Guia
        SET DNI = @Dni,
            IdParque = @IdParque,
            IdEspecialidad = @IdEspecialidad,
            Nombre = @Nombre,
            Apellido = @Apellido,
            Titulo = @Titulo
        WHERE IdGuia = @IdGuia

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
