/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de visitas por semana, mes y año, por parque
*/
USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ReporteVisitas
AS
BEGIN

        SELECT p.Nombre AS PARQUE,
        YEAR(e.Fecha_Acceso) AS AÑO,
        MONTH(e.Fecha_Acceso) AS MES,
        DATEPART(WEEK, e.Fecha_Acceso) AS SEMANA,
        COUNT(e.IdEntrada) AS 'TOTAL VISITAS'
        FROM Area_Infraestructura.Parque p 
        JOIN Area_Comercial.Entrada e ON e.IdParque = p.IdParque
        WHERE p.Activo = 1
        GROUP BY p.Nombre, YEAR(e.Fecha_Acceso), MONTH(e.Fecha_Acceso), DATEPART(WEEK, e.Fecha_Acceso)
        ORDER BY PARQUE, AÑO, MES, SEMANA
END 
GO
