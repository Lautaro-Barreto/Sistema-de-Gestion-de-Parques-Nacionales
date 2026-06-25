/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar los SPs de importación de datos masivos desde un archivo CSV,
ejecutándolos y validando que los datos hayan sido importados correctamente a la tabla de staging y luego a
la tabla Empresa_Concesionaria.  
*/

USE SGParquesNacionales
GO

-- Se recomienda tener parques cargados
EXEC Area_Infraestructura.Sp_ImportarDatosParques
    @RutaArchivoParques = 'C:\ArchivosTPBDA\sheet1.xml'
go

-- Ver parques
SELECT p.IdParque, p.Nombre, tp.Descripcion as [Tipo de parque], pr.Nombre as [Provincia], r.Nombre as [Region] FROM Area_Infraestructura.Parque p
join area_Infraestructura.Tipo_Parque tp on tp.IdTipoParque = p.IdTipoParque
join area_infraestructura.Provincia pr on pr.IdProvincia = p.IdProvincia
join area_Infraestructura.Region r on r.IdRegion = pr.IdRegion
order by r.Nombre;

-- Ejecutamos el SP de importación
EXEC Area_Comercial.Sp_ImportarDatosVisitasPorRegionYTipoVisitante
    @RutaArchivoVisitas = 'C:\ArchivosTPBDA\visitas-residentes-y-no-residentes-por-region.csv',
    @Año = 2023,
    @Mes = 2;
go

select v.IDVenta, v.Fecha, v.Total, E.Precio AS [Subtotal], fdp.Descripcion as [Forma de Pago], 
pv.Descripcion as [Punto de Venta], tv.Descripcion as [Tipo de Visitante], p.Nombre as Parque,
count(e.IdEntrada) over (partition by DAY(v.Fecha)) as [Cantidad De Entradas],
CASE WHEN a.Nombre IS NOT NULL THEN a.Nombre ELSE 'No contratada' END AS [Actividad Contratada],
CASE WHEN a.Costo IS NOT NULL THEN a.Costo ELSE 0 END AS [Costo actividad]
from Area_Comercial.Venta v
join Area_Comercial.Detalle_Venta_Entrada dve ON v.IdVenta = dve.IdVenta
join Area_Comercial.Entrada e ON dve.IdEntrada = e.IdEntrada
join Area_Comercial.Forma_De_Pago fdp ON v.IdFormaDePago = fdp.IdFormaDePago
join Area_Comercial.Punto_De_Venta pv ON v.IdPuntoDeVenta = pv.IdPuntoDeVenta
join Area_Comercial.Tipo_Visitante tv ON e.IdTipoVisitante = tv.IdTipoVisitante
join Area_Infraestructura.Parque p ON v.IdParque = p.IdParque
join Area_Infraestructura.Provincia pr ON p.IdProvincia = pr.IdProvincia
join Area_Infraestructura.Region r ON pr.IdRegion = r.IdRegion
left join Area_Excursiones.Contratacion_Actividad ca ON v.IdVenta = ca.IdVenta
left join Area_Excursiones.Actividad a ON ca.IdActividad = a.IdActividad
ORDER BY v.Fecha;