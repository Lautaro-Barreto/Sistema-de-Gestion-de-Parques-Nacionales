/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación del Stored Procedure utilizado para
importar datos de visitas por región y tipo de visitante desde archivos
 CSV a una tabla temporal.
*/

USE SGParquesNacionales
GO

CREATE OR ALTER PROCEDURE Area_Negocios.Sp_ImportarDatosVisitasPorRegionYTipoVisitante
    @RutaArchivoVisitas VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
    END
    BEGIN CATCH
    END
        
END