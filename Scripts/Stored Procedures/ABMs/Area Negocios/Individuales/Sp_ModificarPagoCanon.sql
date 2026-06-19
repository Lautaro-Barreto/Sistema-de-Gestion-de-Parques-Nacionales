/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para modificar un
Pago de canon.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarPagoCanon
	@IdPagoCanon INT,
	@IdCanon INT,
	@Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
	BEGIN TRY
		--Busca el Pago Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon)
        BEGIN
            PRINT('Pago de Canon inexistente')
            RAISERROR('PagoCanon Inexistente', 16, 1)
        END
		-- Busca el IdCanon en la tabla de Canon.
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('No Existe el Canon Ingresado')
            RAISERROR('Canon Invalido',16,1)
        END
		-- Valida el Monto ingresado
        IF NOT @Monto_Abonado > 0 OR @Monto_Abonado IS NULL
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Pago IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
		--Se completa la operación
	UPDATE Area_Negocios.Pago_Canon SET Monto_Abonado = @Monto_Abonado,
			IdCanon = @IdCanon,
			Fecha_Pago = @Fecha_Pago
			WHERE IdPagoCanon = @IdPagoCanon;
	END TRY
	BEGIN CATCH
        -- Lanzar RETURN
			RAISERROR('Algo salio mal en la modificación del Pago del Canon', 16, 1);
			RETURN;
	END CATCH
	

END
GO