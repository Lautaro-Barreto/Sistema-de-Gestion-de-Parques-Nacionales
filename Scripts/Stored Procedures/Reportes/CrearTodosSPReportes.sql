/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de Parques y conseciones relacionadas
*/
USE SGParquesNacionales
--REPORTE VISITAS 
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

--REPORTE INGRESOS
CREATE OR ALTER PROCEDURE Area_Comercial.Sp_ReporteIngresos AS
BEGIN 
    WITH IngresosEntradas AS(
        SELECT v.IdParque,
        YEAR(v.Fecha) AS AÑO,
        MONTH(v.Fecha) AS MES,
        DATEPART(WEEK,v.Fecha) AS SEMANA,
        SUM(d.Cantidad) AS [Cantidad Entradas],
        SUM(d.Subtotal) AS [Ingresos Entradas]
        FROM Area_Comercial.Detalle_Venta_Entrada d
        JOIN Area_Comercial.Venta v ON v.IdVenta = d.IdVenta
        GROUP BY v.IdParque, YEAR(v.Fecha), MONTH(v.Fecha), DATEPART(WEEK,v.Fecha)
    ),

    IngresosActividades AS(
        SELECT  
        v.IdParque,
        YEAR(v.Fecha) AS AÑO,
        MONTH(v.Fecha) AS MES,
        DATEPART(WEEK,v.Fecha) AS SEMANA,
        SUM(c.Monto) AS [Ingresos Actividades]
        FROM Area_Excursiones.Contratacion_Actividad c
        JOIN Area_Comercial.Venta v ON v.IdVenta = c.IdVenta
        GROUP BY v.IdParque, YEAR(v.Fecha), MONTH(v.Fecha), DATEPART(WEEK,v.Fecha)
    ),
    
    IngresosConceciones AS(
        SELECT 
        cs.IdParque,
        YEAR(p.Fecha_Pago) AS AÑO,
        MONTH(p.Fecha_Pago) AS MES,
        DATEPART(WEEK,p.Fecha_Pago) AS SEMANA,
        SUM(p.IdPagoCanon) AS [Ingresos Concesiones]

        FROM Area_Negocios.Pago_Canon p
        JOIN Area_Negocios.Canon c ON c.IdCanon = p.IdCanon
        JOIN Area_Negocios.Concesion cs ON cs.IdConcesion = c.IdConcesion
        GROUP BY cs.IdParque, YEAR(p.Fecha_Pago), MONTH(p.Fecha_Pago), DATEPART(WEEK,p.Fecha_Pago)
    )

    SELECT p.Nombre AS Parque,
    COALESCE(e.AÑO, a.AÑO,c.AÑO) AS AÑO,
    COALESCE(e.MES, a.MES, c.MES) AS MES,
    COALESCE(e.SEMANA, a.SEMANA, c.SEMANA) AS SEMANA,
    ISNULL(e.[Cantidad Entradas], 0) AS [Total Entradas],
    ISNULL(e.[Ingresos Entradas], 0) AS [Ingesos Entradas],
    ISNULL(a.[Ingresos Actividades], 0) AS[Ingesos Actividades],
    ISNULL(c.[Ingresos Concesiones], 0) AS [Ingesos Concesiones]
    FROM Area_Infraestructura.Parque p
    FULL JOIN IngresosEntradas e ON e.IdParque = p.IdParque
    FULL JOIN IngresosActividades a ON a.IdParque = p.IdParque
    FULL JOIN IngresosConceciones c ON c.IdParque = p.IdParque
END
GO

--REPORTE DEUDORES

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
GO
--REPORTE MATRIZ DE VISITAS
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

--REPORTES PARQUES Y CONSECIONES XML
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_ReporteParquesYConcesionesXML
AS
BEGIN 
SELECT
p.IdParque AS [@Id], 
        p.Nombre AS [NombreParque],
        
        -- SUBCONSULTA CORRELACIONADA: Construye el vector anidado de concesiones
        (
            SELECT 
                c.IdConcesion AS [@IdConcesion],
                c.Fecha_Inicio AS [FechaInicio],
                c.Fecha_Fin AS [FechaFin],
                e.Nombre AS [Titular],
                ta.Descripcion AS [ServicioPrestado]
            FROM Area_Negocios.Concesion c
            INNER JOIN Area_Negocios.Empresa_Concesionaria e ON c.IdEmpresa = e.IdEmpresa
            LEFT JOIN Area_Negocios.Tipo_Actividad_Concesion ta ON c.IdTipoActividadConcesion = ta.IdTipoActividadConcesion
            WHERE c.IdParque = p.IdParque -- Relación jerárquica con el parque externo
            FOR XML PATH('Concesion'), TYPE -- Genera los nodos hijos como XML 
        ) AS [Concesiones] -- Nombre del nodo contenedor del vector

    FROM Area_Infraestructura.Parque p
    WHERE p.Activo = 1 -- Filtro de borrado lógico (según reglas del negocio)
    FOR XML PATH('Parque'), ROOT('Parques'), TYPE; 
    -- 'Parque' define el nodo de cada fila, 'ROOT' envuelve todo en una etiqueta contenedora.

END 
GO
