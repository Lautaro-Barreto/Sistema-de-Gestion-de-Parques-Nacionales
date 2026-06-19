/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para registrar el pago de un 
canon, actualizar su estado y generar el próximo canon a pagar.   
*/

CREATE OR ALTER PROCEDURE Area_Negocios.SP_Registrar_Pago_Canon
    @IdCanon INT,
    @IdConcesion INT,
    @Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Obtener la info del canon que se intenta pagar
    DECLARE @IdEstadoActual INT, @Fecha_Vencimiento DATE, @Monto_Mensual DECIMAL(13,3);
    
    SELECT @IdEstadoActual = IdEstado, @Fecha_Vencimiento = Fecha_Vencimiento, @Monto_Mensual = Monto_Mensual
    FROM Area_Negocios.Canon
    WHERE IdCanon = @IdCanon AND IdConcesion = @IdConcesion;

    IF @IdEstadoActual IS NULL
    BEGIN
        RAISERROR('El Canon especificado no existe.', 16, 1);
        RETURN;
    END

    -- Validar que no esté exento o ya cancelado
    DECLARE @IdExento INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Exento');
    DECLARE @IdSaldadoTermino INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Saldado en Término');
    DECLARE @IdSaldadoAtraso INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Saldado con Atraso');

    IF @IdEstadoActual = @IdExento
    BEGIN
        RAISERROR('El canon especificado está exento. No requiere pago.', 16, 1);
        RETURN;
    END

    IF @IdEstadoActual IN (@IdSaldadoTermino, @IdSaldadoAtraso)
    BEGIN
        RAISERROR('El canon especificado ya se encuentra saldado.', 16, 1);
        RETURN;
    END

    -- Determinar el estado posterior al pago basado en las fechas
    DECLARE @NuevoEstado INT;
    IF @Fecha_Pago <= @Fecha_Vencimiento
        SET @NuevoEstado = @IdSaldadoTermino;
    ELSE
        SET @NuevoEstado = @IdSaldadoAtraso;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Insertar el recibo en la tabla de Pagos
        INSERT INTO Area_Negocios.Pago_Canon (IdCanon, IdConcesion, Estado, Monto_Abonado, Fecha_Pago)
        VALUES (@IdCanon, @IdConcesion, 'Completado', @Monto_Abonado, @Fecha_Pago);

        -- 2. Actualizar el Canon pagado para cerrarlo
        UPDATE Area_Negocios.Canon
        SET IdEstado = @NuevoEstado
        WHERE IdCanon = @IdCanon;

        -- 3. Emitir el nuevo Canon para la próxima cuota (30 días después del vencimiento original)
        DECLARE @IdVigente INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Vigente');
        
        INSERT INTO Area_Negocios.Canon (IdConcesion, IdEstado, Monto_Mensual, Fecha_Vencimiento)
        VALUES (
            @IdConcesion, 
            @IdVigente, 
            @Monto_Mensual,
            DATEADD(DAY, 30, @Fecha_Vencimiento)
        );

        COMMIT TRANSACTION;
        PRINT 'Pago registrado correctamente. Nuevo canon emitido.';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR (@ErrorMsg, 16, 1);
    END CATCH
END
GO