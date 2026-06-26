/*
Este script inserta la seed data requerida de manera segura (con chequeos de existencia):

Tablas auxiliares inicializadas.
10 Parques adicionales.
30 Actividades asignadas a parques aleatorios.
20 Guías con especialidades asignados a actividades de sus respectivos parques.
20 Guardaparques con fechas de ingreso aleatorias.
10 Concesiones asociadas a empresas concesionarias.
Configuración de precios aleatorios en Precio_Parque_Tipo_Visitante para todos los parques.
Historial de 50 ventas simuladas registradas a través de Sp_RegistrarVentaEntradas.
*/

USE SGParquesNacionales
GO

/*select * from Area_Infraestructura.Parque

SELECT * from Area_Infraestructura.Guardaparque
SELECT * FROM Area_Infraestructura.Tipo_Parque
SELECT * from Area_Infraestructura.Historial_Trabajo_Guardaparque
select * from Area_Infraestructura.Provincia
select * from Area_Infraestructura.Region
*/

SELECT * from Area_Excursiones.Actividad
SELECT * from Area_Excursiones.Tipo_Actividad
SELECT * from Area_Excursiones.Habilitacion
SELECT * from Area_Excursiones.Habilitacion_Guia
SELECT * from Area_Excursiones.Guia
SELECT * from Area_Excursiones.Guias_por_Actividad
SELECT * from Area_Excursiones.Habilitaciones_por_Actividad


GO
SELECT * FROM Area_Comercial.
GO
CREATE OR ALTER PROCEDURE Area_Infraestructura.Sp_GenerarSeedDataAll
AS
BEGIN
    BEGIN TRY
    
        set nocount on;
        BEGIN TRANSACTION;
            EXEC Area_Infraestructura.Sp_AreaInfraSeed;
            EXEC Area_Excursiones.Sp_AreaExcursionesSeed;
            EXEC Area_Comercial.Sp_AreaComercialSeed;
            EXEC Area_Negocios.Sp_AreaNegociosSeed;
        COMMIT TRANSACTION;

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

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage VARCHAR(255) = ERROR_MESSAGE();
        RAISERROR('Error al generar seed data: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO