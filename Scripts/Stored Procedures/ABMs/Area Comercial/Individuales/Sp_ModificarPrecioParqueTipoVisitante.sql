/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para modificar una tarifa asociada a un tipo de visitante en un parque. 
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ModificarPrecioParqueTipoVisitante
    @Parque VARCHAR(80),
    @TipoVisitante VARCHAR(30),
    @Precio DECIMAL(14,4)
AS
BEGIN
BEGIN TRY
    
    SET NOCOUNT ON;

    DECLARE @IdParque INT;
    DECLARE @IdTipoVisitante INT;

    -- Validar que el parque exista
    SELECT @IdParque = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = @Parque;
    IF @IdParque IS NULL
    BEGIN
        RAISERROR('El parque especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el tipo de visitante exista
    SELECT @IdTipoVisitante = IdTipoVisitante FROM Area_Comercial.Tipo_Visitante WHERE Descripcion = @TipoVisitante;
    IF @IdTipoVisitante IS NULL
    BEGIN
        RAISERROR('El tipo de visitante especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que el precio sea positivo
    IF @Precio <= 0
    BEGIN
        RAISERROR('El precio debe ser un valor positivo.', 16, 1);
        RETURN;
    END

    -- Actualizar el precio en la tabla Precio_Parque_Tipo_Visitante
    UPDATE Area_Comercial.Precio_Parque_Tipo_Visitante
    SET Precio = @Precio
    WHERE IdParque = @IdParque AND IdTipoVisitante = @IdTipoVisitante;

END TRY
BEGIN CATCH
    IF ERROR_SEVERITY() > 10
    BEGIN
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();	
        RAISERROR(@ErrorMessage, 16, 1);
    END
END CATCH
END
GO