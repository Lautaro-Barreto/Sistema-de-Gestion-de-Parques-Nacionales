/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear una Especialidad.
*/


USE SGParquesNacionales
go

CREATE PROCEDURE Area_Excursiones.Sp_CrearEspecialidad
    @Descripcion VARCHAR(50)
AS 
BEGIN 
    BEGIN TRY
        IF @Descripcion IS NULL OR LEN(@Descripcion) = 0
        BEGIN
            RAISERROR('La descripción debe tener entre 1 y 50 caracteres.', 16, 1)
            
        END
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Ocurrió un error al crear la especialidad.', 16, 1)
            RETURN
        END
    END CATCH

    INSERT INTO Area_Excursiones.Especialidad (Descripcion)
    VALUES (@Descripcion)
    DECLARE @idNuevo_Especialidad INT
    SET @idNuevo_Especialidad = SCOPE_IDENTITY()
    RETURN @idNuevo_Especialidad
END
GO