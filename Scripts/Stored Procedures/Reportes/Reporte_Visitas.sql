/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de visitas por semana, mes y año, por parque
*/
USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ReporteVisitasParque
@IdParque INT 
AS
BEGIN
    BEGIN TRY

        IF NOT EXISTS(SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque AND Activo = 1)
        BEGIN 
            RAISERROR('El parque proporcionado no existe o no está disponible.',16,1)
        END 

        SELECT p.Nombre AS PARQUE,
        YEAR(e.Fecha_Acceso) AS AÑO,
        MONTH(e.Fecha_Acceso) AS MES,
        DATEPART(WEEK, e.Fecha_Acceso) AS SEMANA,
        COUNT(e.IdEntrada) AS 'TOTAL VISITAS'
        FROM Area_Infraestructura.Parque p 
        JOIN Area_Comercial.Entrada e ON e.IdParque = p.IdParque
        WHERE p.IdParque = @IdParque
        GROUP BY p.Nombre, YEAR(e.Fecha_Acceso), MONTH(e.Fecha_Acceso), DATEPART(WEEK, e.Fecha_Acceso)
        ORDER BY AÑO, MES, SEMANA
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
