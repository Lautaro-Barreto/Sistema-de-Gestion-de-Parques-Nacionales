/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del Stored Procedure utilizado para crear 
una Concesion.
*/
USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearConcesion
    @IdTipoActividadConcesion INTEGER,
    @IdEmpresa INTEGER,
    @IdParque INTEGER,
    @Fecha_Inicio DATE,
    @Fecha_Fin DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el Id del TipoActividad en la tabla de Tipo_Actividad_Concesion.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('No Existe el Tipo de actividad de concesion ingresada')
            RAISERROR('TipoActividad Invalida',16,1)
        END
        --Busca la empresa en la tabla de Empresa_Concesionaria.
        --No solo verificar si existe si no si está activa también
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1)
        BEGIN
            PRINT('No Existe la Empresa concesionaria o no esta activa actualmente')
            RAISERROR('EmpresaConcesionaria Invalida',16,1)
        END
        --Busca el parque en la tabla de Parques
        IF NOT EXISTS ( SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('No Existe el parque Ingresado')
            RAISERROR('Parque Invalido',16,1)
        END

        -- Valida la fecha de inicio ingresada, comprobando que no sea nula.
		IF @Fecha_Inicio IS NULL
		BEGIN
            PRINT('La fecha de Inicio no puede ser nula')
            RAISERROR('Fecha Inicio Inválida', 16, 1)
        END
        -- Valida la fecha de fin ingresada, comprobando que no sea nula.
		IF @Fecha_Fin IS NULL
		BEGIN
            PRINT('La fecha de Fin no puede ser nula')
            RAISERROR('Fecha Fin Inválida', 16, 1)
        END

        --Obviamente la fecha de Fin debe ser menor que la de inicio
        IF @Fecha_Fin <= @Fecha_Inicio
        BEGIN
            RAISERROR('La fecha de finalización debe ser estrictamente posterior a la fecha de inicio.', 16, 1);
        END

        INSERT INTO Area_Negocios.Concesion(IdTipoActividadConcesion,IdEmpresa,IdParque,Fecha_Inicio,Fecha_Fin) VALUES (@IdTipoActividadConcesion,@IdEmpresa,@IdParque,@Fecha_Inicio,@Fecha_Fin)

    END TRY
    BEGIN CATCH
        -- Lanzamos return	
            RAISERROR('Algo salio mal en la creación de la Concesión',16,1);
            Return;
    END CATCH
END
GO