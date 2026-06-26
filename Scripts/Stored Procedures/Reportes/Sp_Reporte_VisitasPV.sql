/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de deudores con meses y montos.
*/
USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_Reporte_VisitasAnuales 
    @Año INT
AS 
BEGIN 
    WITH VistasMensuales AS(
        SELECT  
        p.Nombre AS Parque,
        e.IdEntrada AS Entradas,
        MONTH(e.Fecha_Acceso) AS Mes
        FROM Area_Comercial.Entrada e
        JOIN Area_Infraestructura.Parque p ON p.IdParque = e.IdParque
        WHERE YEAR(e.Fecha_Acceso) = @Año
    )
    SELECT Parque,
    ISNULL([1], 0) AS Enero,
    ISNULL([2], 0) AS Febrero,
    ISNULL([3], 0) AS Marzo,
    ISNULL([4], 0) AS Abril,
    ISNULL([5], 0) AS Mayo,
    ISNULL([6], 0) AS Junio,
    ISNULL([7], 0) AS Julio,
    ISNULL([8], 0) AS Agosto,
    ISNULL([9], 0) AS Septiembre,
    ISNULL([10], 0) AS Octubre,
    ISNULL([11], 0) AS Noviembre,
    ISNULL([12], 0) AS Diciembre
    FROM VistasMensuales
    PIVOT(COUNT(Entradas) FOR Mes IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
    )AS pvt
END
GO