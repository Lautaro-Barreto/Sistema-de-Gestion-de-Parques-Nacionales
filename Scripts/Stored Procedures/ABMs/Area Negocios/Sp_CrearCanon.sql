/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para crear 
un Canon.
*/
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearCanon
    @IdEstado INTEGER,
    @IdConcesion INTEGER,
    @Monto_Mensual DECIMAL(13,3),
    @Fecha_Vencimiento DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el IdEstado en la tabla de Estados.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstado)
        BEGIN
            PRINT('No Existe el Estado de canon Ingresado')
            RAISERROR('EstadoCanon Invalido',16,1)
        END
        --Busca el IdConcesion en la tabla de Concesiones.
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la Concesión Ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END

        -- Valida el Monto ingresado
        IF @Monto_Mensual IS NULL OR  @Monto_Mensual <= 0 
        BEGIN
            PRINT('El Monto Ingresado no es valido, debe ser mayor a 0')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Vencimiento IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END

        IF @Fecha_Vencimiento < CAST(GETDATE() AS DATE)
        BEGIN
            RAISERROR('La fecha de vencimiento no puede ser anterior a la fecha actual.', 16, 1);
            RAISERROR('Fecha Invalida', 16, 1)
        END
            INSERT INTO Area_Negocios.Canon(IdEstado,IdConcesion,Monto_Mensual,Fecha_Vencimiento) VALUES (@IdEstado,@IdConcesion,@Monto_Mensual,@Fecha_Vencimiento)

    END TRY
    BEGIN CATCH
        -- Lanzamos return
            RAISERROR('Algo salio mal en la creación del Canon',16,1);
            Return;
    END CATCH
END
GO