/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para crear una actividad.
*/

USE SGParquesNacionales
go

CREATE OR ALTER PROCEDURE Area_Excursiones.Sp_CrearActividad
    @tipoActividad INT,
    @idParque INT,
    @Nombre VARCHAR(30),
    @Costo decimal(10, 2),
    @Duracion INT,
    @Cupo_maximo INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        --El tipo de Actividad debe estar en la db
        IF NOT EXISTS (SELECT 1 FROM Area_Excursiones.Tipo_Actividad WHERE IdTipoActividad = @tipoActividad)
        BEGIN
            RAISERROR('El tipo de actividad no existe.', 16, 1)
            
        END
        --El parque debe estar en la db
        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @idParque)
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


    INSERT INTO Area_Excursiones.Actividad (IdTipoActividad, IdParque, Nombre, Costo, Duracion, Cupo_maximo)
    VALUES (@tipoActividad, @idParque, @Nombre, @Costo, @Duracion, @Cupo_maximo)
    DECLARE @Id_NuevaActividad INT 
    SET @Id_NuevaActividad = SCOPE_IDENTITY()
    RETURN @Id_NuevaActividad

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
