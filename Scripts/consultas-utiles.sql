-- Chequear que no quede ninguna transaccion abierta
SELECT 
    st.session_id,
    at.name AS transaction_name,
    DATEDIFF(SECOND, at.transaction_begin_time, GETDATE()) AS elapsed_seconds
FROM sys.dm_tran_active_transactions at
JOIN sys.dm_tran_session_transactions st ON st.transaction_id = at.transaction_id;

-- parques, provincias y regiones
SELECT p.IdParque, p.Nombre, tp.Descripcion as [Tipo de parque], pr.Nombre as [Provincia], r.Nombre as [Region] FROM Area_Infraestructura.Parque p
join area_Infraestructura.Tipo_Parque tp on tp.IdTipoParque = p.IdTipoParque
join area_infraestructura.Provincia pr on pr.IdProvincia = p.IdProvincia
join area_Infraestructura.Region r on r.IdRegion = pr.IdRegion
order by r.Nombre;

-- precios por parque y tipo de visitante
select p.Nombre, tv.Descripcion as [tipo visitante], pptv.Precio from Area_Comercial.Precio_Parque_Tipo_Visitante pptv
join Area_Infraestructura.Parque p on p.IdParque = pptv.IdParque
join Area_Comercial.Tipo_Visitante tv on tv.IdTipoVisitante = pptv.IdTipoVisitante
order by p.Nombre, tv.Descripcion;

-- Descuentos por parque
select p.Nombre, d.Descripcion, d.Porcentaje from Area_Comercial.Descuento_Parque d
join Area_Infraestructura.Parque p on p.IdParque = d.IdParque

-- Historial de ventas
SELECT DISTINCT 
v.IdVenta, v.Total as [Total venta], v.Fecha as [Fecha venta], pdv.Descripcion as [Punto de venta], p.Nombre as [Parque], fp.Descripcion AS [Forma de pago],
e.IdEntrada, tv.Descripcion AS [Tipo visitante], e.Precio as [Precio de la entrada],
a.Nombre AS [Actividad contratada], a.Costo as [Costo actividad], a.Duracion as [Duración actividad (horas)]
FROM Area_Comercial.Venta v
JOIN Area_Comercial.Detalle_Venta_Entrada dve ON v.IdVenta = dve.IdVenta
JOIN Area_Comercial.Entrada e ON dve.IdEntrada = e.IdEntrada
join Area_Comercial.Tipo_Visitante tv on e.IdTipoVisitante = tv.IdTipoVisitante
join Area_Comercial.Forma_De_Pago fp on v.IdFormaDePago = fp.IdFormaDePago
join Area_Infraestructura.Parque p on v.IdParque = p.IdParque
join Area_Comercial.Punto_De_Venta pdv on v.IdPuntoDeVenta = pdv.IdPuntoDeVenta
left join Area_Excursiones.Contratacion_Actividad ca on v.IdVenta = ca.IdVenta
left join Area_Excursiones.Actividad a on ca.IdActividad = a.IdActividad

-- Actividades con su parque
select a.Nombre as [Actividad], tp.Descripcion as [Tipo Actividad], p.Nombre as [Parque] from Area_Excursiones.Actividad a
join Area_Excursiones.Tipo_Actividad tp on tp.IdTipoActividad = a.IdTipoActividad
join Area_Infraestructura.Parque p on p.IdParque = a.IdParque

-- Guardaparques con su parque
select g.IdGuardaparque, g.Dni, g.Nombre, g.Apellido, p.Nombre as [Parque], g.Fecha_Ingreso, g.Fecha_Egreso from Area_Infraestructura.Guardaparque g
join Area_Infraestructura.Parque p on p.IdParque = g.IdParque

-- Guias con su parque y especialidad
select g.IdGuia, g.DNI, g.Nombre, g.Apellido, p.Nombre as [Parque], e.Descripcion as [Especialidad] from Area_Excursiones.Guia g
join Area_Infraestructura.Parque p on p.IdParque = g.IdParque
join Area_Excursiones.Especialidad e on e.IdEspecialidad = g.IdEspecialidad

-- Actividades con sus guias asignados, su parque y tipo de actividad
select a.Nombre as [Actividad], p.Nombre as [Parque], g.Nombre + ' ' + g.Apellido as [Guia], ta.Descripcion as [Tipo Actividad] from Area_Excursiones.Actividad a
join Area_Infraestructura.Parque p on p.IdParque = a.IdParque
join Area_Excursiones.Guias_por_Actividad ga on ga.IdActividad = a.IdActividad
join Area_Excursiones.Guia g on g.IdGuia = ga.IdGuia
join area_excursiones.Tipo_Actividad ta on ta.IdTipoActividad = a.IdTipoActividad
order by p.Nombre, a.Nombre;

-- Habilitaciones por actividad
select a.Nombre, h.Descripcion
from Area_Excursiones.Habilitaciones_por_Actividad ha
join Area_Excursiones.Habilitacion h on ha.IdHabilitacion = h.IdHabilitaciones
join Area_Excursiones.Actividad a on ha.IdActividad = a.IdActividad

-- Habilitaciones por guia
select g.Nombre + ' ' + g.Apellido as [Guia], h.Descripcion as [Habilitacion], hg.Fecha_Inicio_Validez, hg.Fecha_Fin_Validez
from Area_Excursiones.Habilitacion_Guia hg
join Area_Excursiones.Guia g on g.IdGuia = hg.IdGuia
join Area_Excursiones.Habilitacion h on h.IdHabilitaciones = hg.IdHabilitacion;

-- Concesiones con su parque, empresa concesionaria y tipo de actividad concesionada
select c.IdConcesion, p.Nombre as [Parque], ec.Nombre as [Empresa Concesionaria], tac.Descripcion as [Tipo de Actividad de Concesion], c.Fecha_Inicio, c.Fecha_Fin
from Area_Negocios.Concesion c
join Area_Infraestructura.Parque p on p.IdParque = c.IdParque
join Area_Negocios.Empresa_Concesionaria ec on ec.IdEmpresa = c.IdEmpresa
join Area_Negocios.Tipo_Actividad_Concesion tac on tac.IdTipoActividadConcesion = c.IdTipoActividadConcesion

-- Canones con su empresa, concesion, parque, estado, monto y fecha de vencimiento
SELECT ca.IdCanon, c.IdConcesion, ec.Nombre, p.Nombre as Parque, ec2.Descripcion as Estado, ca.Monto_Mensual, ca.Fecha_Vencimiento
FROM area_negocios.canon ca
INNER JOIN area_negocios.concesion c ON ca.IdConcesion = c.IdConcesion
INNER JOIN area_negocios.empresa_concesionaria ec ON c.IdEmpresa = ec.IdEmpresa
INNER JOIN area_negocios.tipo_actividad_concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
INNER JOIN area_negocios.estado_canon ec2 ON ca.IdEstado = ec2.IdEstadoCanon
INNER JOIN area_infraestructura.parque p ON c.IdParque = p.IdParque
WHERE ec.Nombre = 'Empresa Increíble' AND tac.Descripcion = 'Turismo Increíble' AND p.Nombre = 'Parque Nacional Increíble';

-- Eliminar canones, empresas y concesiones en cascada
DELETE FROM area_negocios.pago_canon;
DELETE FROM area_negocios.canon;
DELETE FROM area_negocios.concesion;
DELETE FROM area_negocios.empresa_concesionaria;

-- Eliminar ventas y entradas en cascada
DELETE FROM Area_Comercial.Precio_Parque_Tipo_Visitante;
DELETE FROM Area_Excursiones.Contratacion_Actividad;
DELETE FROM AREA_Comercial.Detalle_Venta_Entrada;
DELETE FROM Area_Comercial.Entrada;
DELETE FROM Area_Comercial.Venta;

-- Eliminar actividades, guias y habilitaciones en cascada
DELETE FROM Area_Excursiones.Habilitacion_Guia;
DELETE FROM Area_Excursiones.Habilitaciones_por_Actividad;
DELETE FROM Area_Excursiones.Guias_por_Actividad;
DELETE FROM Area_Excursiones.Contratacion_Actividad;
DELETE FROM Area_Excursiones.Actividad;

-- Eliminar parques
DELETE FROM Area_Infraestructura.Guardaparque;
DELETE FROM Area_Comercial.Precio_Parque_Tipo_Visitante;
DELETE FROM Area_Comercial.Descuento_Parque;
DELETE FROM Area_Infraestructura.Parque;
-- Because why not
DELETE FROM Area_Infraestructura.Provincia;
DELETE FROM Area_Infraestructura.Region;