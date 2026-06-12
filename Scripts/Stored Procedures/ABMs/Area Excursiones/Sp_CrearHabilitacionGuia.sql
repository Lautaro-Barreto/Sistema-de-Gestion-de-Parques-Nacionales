/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear una actividad.
*/


USE SGParquesNacionales
go
CREATE PROCEDURE Area_Excursiones.Sp_CrearHabilitacionGuia
    @IdGuia INT,
    @IdHabilitacion INT,
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Guia WHERE IdGuia = @IdGuia)
        BEGIN
            RAISERROR('El guía no existe.', 16, 1)
            
        END

        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Habilitacion WHERE IdHabilitacion = @IdHabilitacion)
        BEGIN
            RAISERROR('La habilitación no existe.', 16, 1)
            
        END

        IF @FechaInicio > @FechaFin
        BEGIN
            RAISERROR('La fecha de inicio no puede ser posterior a la fecha de fin.', 16, 1)
        END
        
        --Que la fecha de inicio no sea de hace más de 1 año atrás
        IF @FechaInicio < DATEADD(YEAR, -1, GETDATE())
        BEGIN
            RAISERROR('La fecha de inicio no puede ser tan antigua.', 16, 1)
            
        END
        
    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Ocurrió un error al crear la habilitación del guía.', 16, 1)
            RETURN
        END
    END CATCH

    INSERT INTO Area_Excursiones.Habilitacion_Guia (IdGuia, IdHabilitacion, Fecha_Inicio_Validez, Fecha_Fin_Validez)
    VALUES (@IdGuia, @IdHabilitacion, @FechaInicio, @FechaFin)

END
GO