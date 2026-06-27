/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de deudores con meses y montos.
*/
USE SGParquesNacionales
GO
CREATE OR ALTER PROCEDURE Area_Negocios.Sp_ReporteDeudores AS
BEGIN 
    WITH MesesAtrasados AS(
    SELECT c.IdConcesion, 
    COUNT(c.IdCanon) AS [Cantidad Meses Atrasados],
    SUM(c.Monto_Mensual - ISNULL(p.MontoAbonado, 0)) AS DEUDA
    FROM Area_Negocios.Canon c

    LEFT JOIN (
        SELECT IdCanon, SUM(Monto_Abonado) AS MontoAbonado
        FROM Area_Negocios.Pago_Canon
        GROUP BY IdCanon
    ) p ON p.IdCanon = c.IdCanon

    WHERE  c.Fecha_Vencimiento < GETDATE()
    AND (p.MontoAbonado IS NULL OR p.MontoAbonado < c.Monto_Mensual)
    GROUP BY c.IdConcesion 
)

SELECT e.Nombre AS [Empresa Concesionaria], 
c.IdConcesion  AS [Id Concesión],
m.[Cantidad Meses Atrasados], 
m.DEUDA AS [Deuda Total]
FROM Area_Negocios.Empresa_Concesionaria e
JOIN Area_Negocios.Concesion c ON c.IdEmpresa = e.IdEmpresa
JOIN MesesAtrasados m ON m.IdConcesion = c.IdConcesion

END 
