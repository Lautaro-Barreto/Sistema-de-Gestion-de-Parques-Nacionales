/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de crear el Stored Procedure utilizado para generar seed data del área de negocios.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.Sp_AreaNegociosSeed
    @Empresas BIT = 1,
    @Concesiones BIT = 1
AS
BEGIN
    BEGIN TRY
        set nocount on;
        BEGIN TRANSACTION;

        -- Crear al menos 5 empresas concesionarias
        IF @Empresas = 1 AND NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria)
        BEGIN
            EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Agus Inc.';
            EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'Umbrella Corp';
            EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'YPF';
            EXEC Area_Negocios.Sp_CrearEmpresaConcesionaria 'Freddy Fazbears Pizza';
            EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Claure y Co.';

            EXEC Area_Negocios.SP_CrearTipoActividadConcesion @Descripcion = 'Regadero';
            EXEC Area_Negocios.SP_CrearTipoActividadConcesion @Descripcion = 'Restaurante';

        END
       
        -- Crear al menos 10 Concesiones
        IF @Concesiones = 1
        BEGIN
            DECLARE @TotalConcesiones INT = (SELECT COUNT(*) FROM Area_Negocios.Concesion);
            IF @TotalConcesiones < 10
            BEGIN
                DECLARE @ConNo INT = 1;
                WHILE @ConNo <= 10
                    BEGIN
                    DECLARE @RandParqueCon INT = (SELECT TOP 1 IdParque FROM Area_Infraestructura.Parque ORDER BY NEWID());
                    DECLARE @RandEmpId INT = (SELECT TOP 1 IdEmpresa FROM Area_Negocios.Empresa_Concesionaria ORDER BY NEWID());
                    DECLARE @RandTipoConId INT = (SELECT TOP 1 IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion ORDER BY NEWID());
                    DECLARE @FInicio DATE = DATEADD(DAY, -CAST(RAND() * 365 AS INT), GETDATE());
                    DECLARE @FFin DATE = DATEADD(YEAR, 5, @FInicio);
                    EXEC Area_Negocios.SP_CrearConcesion @RandTipoConId, @RandEmpId, @RandParqueCon, @FInicio, @FFin
                    SET @ConNo = @ConNo + 1;
                END
            END
        END

        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al generar seed data del área de negocios: %s', 16, 1, @ErrorMessage);
    END CATCH
END