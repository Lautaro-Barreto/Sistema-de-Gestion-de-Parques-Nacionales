/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear una relación entre guía y actividad.
*/


USE SGParquesNacionales
go
CREATE PROCEDURE Area_Excursiones.Sp_CrearGuiasPorActividad
    @IdGuia INT,
    @IdActividad INT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía no existe.', 16, 1)
            
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Actividad WHERE IdActividad = @IdActividad)
        BEGIN
            RAISERROR('La actividad no existe.', 16, 1)
            
        END

    END TRY
    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Ocurrió un error al crear la relación entre guía y actividad.', 16, 1)
            RETURN
        END
    END CATCH

    INSERT INTO Area_Excursiones.Guias_Por_Actividad (IdGuia, IdActividad)
    VALUES (@IdGuia, @IdActividad)
END

GO