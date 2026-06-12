/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear una actividad.
*/


USE SGParquesNacionales
go

CREATE PROCEDURE Area_Excursiones.Sp_CrearActividad
    @tipoActividad INT,
    @idParque INT,
    @Nombre VARCHAR(30),
    @Costo decimal(10, 2),
    @Duracion INT,
    @Cupo_maximo INT
AS
BEGIN
    BEGIN TRY
        --El tipo de Actividad debe estar en la db
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE Id_Tipo_Actividad = @tipoActividad)
        BEGIN
            RAISERROR('El tipo de actividad no existe.', 16, 1)
            
        END
        --El parque debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE Id_Parque = @idParque)
        BEGIN
            RAISERROR('El Parque no existe.', 16, 1)
            
        END

        IF @Costo < 0
        BEGIN
            RAISERROR('El costo no puede ser negativo.', 16, 1)
            
        END 
        IF @Duracion <= 0
        BEGIN  
            RAISERROR('La duración debe ser positiva.', 16, 1)
            
        END
        IF @Cupo_maximo <= 0 
        BEGIN
            RAISERROR('El cupo máximo debe ser positivo.', 16, 1)
            

        END
        IF( @Nombre IS NULL OR LEN(@Nombre) = 0)
        BEGIN
            RAISERROR('El nombre debe tener entre 1 y 30 caracteres.', 16, 1)
            
        END

    END TRY

    BEGIN CATCH
        IF ERROR_SEVERITY() > 10
        BEGIN
            RAISERROR('Error al crear la actividad: %s', 16, 1)
            RETURN;
        END
    END CATCH

    INSERT INTO Area_Excursiones.Actividad (IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo)
    VALUES (@tipoActividad, @idParque, @Nombre, @Costo, @Duracion, @Cupo_maximo)
    DECLARE @Id_NuevaActividad INT 
    SET @Id_NuevaActividad = SCOPE_IDENTITY()
    RETURN @Id_NuevaActividad
END
GO
