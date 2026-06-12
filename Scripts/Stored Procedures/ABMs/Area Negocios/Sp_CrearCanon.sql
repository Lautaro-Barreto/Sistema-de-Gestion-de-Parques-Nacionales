/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para crear 
un Canon.
*/
USE SGParquesNacionales

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearCanon
    @IdEstado INTEGER,
    @IdConcesion INTEGER,
    @Monto_Mensual DECIMAL(13,3),
    @Fecha_Vencimiento DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el IdCanon en la tabla de Canon.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstado = @IdEstado)
        BEGIN
            PRINT('No Existe el Canon Ingresado')
            RAISERROR('Canon Invalido',16,1)
        END
        -- Valida el Monto ingresado
        IF NOT @Monto_Abonado > 0
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
        
    END TRY
    BEGIN CATCH
        -- Lanzamos Rollback
        IF ERROR_SEVERITY()>10
        BEGIN	
            RAISERROR('Algo salio mal en la creación del pago del canon',16,1);
            ROLLBACK;
        END
    END CATCH
    INSERT INTO Area_Negocios.Pago_Canon(IdCanon,Monto_Abonado,Fecha_Pago) VALUES (@IdCanon,@Monto_Abonado,@Fecha_Pago)
END
GO