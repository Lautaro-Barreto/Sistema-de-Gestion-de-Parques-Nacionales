/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de generar el reporte de Parques y conseciones relacionadas
*/

USE SGParquesNacionales
GO
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