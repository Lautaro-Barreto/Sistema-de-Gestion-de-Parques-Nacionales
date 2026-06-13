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

CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarCanon
	@IdCanon Integer,
	@IdEstadoCanon INT,
    @IdConcesion INTEGER,
    @Monto_Mensual DECIMAL(13,3),
    @Fecha_Vencimiento DATE
AS
BEGIN
	BEGIN TRY
		--Busca el Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('Canon inexistente')
            RAISERROR('Canon Inexistente', 16, 1)
        END
		--Busca el Estado Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon)
        BEGIN
            PRINT('Estado de Canon inexistente')
            RAISERROR('Estado de Canon Inexistente', 16, 1)
        END

		--Busca la Concesión verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('Concesión inexistente')
            RAISERROR('Concesión Inexistente', 16, 1)
        END
		 -- Valida el Monto ingresado
        IF NOT @Monto_Mensual > 0 OR @Monto_Mensual IS NULL 
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Vencimiento IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
		UPDATE Area_Negocios.Canon 
		SET  IdEstado = @IdEstadoCanon,
		IdConcesion = @IdConcesion,
		Monto_Mensual = @Monto_Mensual,
		Fecha_Vencimiento = @Fecha_Vencimiento
		WHERE IdCanon = @IdCanon 
	END TRY
	BEGIN CATCH
        -- Lanzar return
		IF ERROR_SEVERITY() > 10
		BEGIN	
			RAISERROR('Algo salio mal en la modificación del Canon', 16, 1);
			RETURN;
		END
	END CATCH
END
GO