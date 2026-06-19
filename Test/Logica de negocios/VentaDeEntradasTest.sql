
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar el SP que registra la venta de entradas
Requisitos para ejecutarlo: haber ejecutado el script "seed data" para tener datos en la base de datos y haber creado el SP "Sp_RegistrarVentaEntradas" previamente.
*/

USE SGParquesNacionales
GO

-- 1. Registrar una venta de entradas con un parque inexistente
EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Inexistente',
    @CantidadEntradas = 1,
    @TipoVisitante = 'Residente',
    @Actividad = 'Tour Guiado',
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 1,
	@FormaDePago = 'Efectivo'
go

-- 2. Registrar una venta de entradas con un tipo de visitante inexistente
EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Iguazú',
    @CantidadEntradas = 1,
    @TipoVisitante = 'Inexistente',
    @Actividad = 'Trekking',
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 1,
	@FormaDePago = 'Efectivo'
go

-- 3. Registrar una venta de entradas con una cantidad de entradas invalida
EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Iguazú',
    @CantidadEntradas = 0,
    @TipoVisitante = 'Residente',
    @Actividad = 'Tour Guiado Senderismo 1',
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 2,
	@FormaDePago = 'Efectivo'
go

-- 4. Registrar una venta de entradas con un punto de venta inexistente
EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Iguazú',
	@CantidadEntradas = 1,
	@TipoVisitante = 'Residente',
	@Actividad = 'Tour Guiado Senderismo 1',
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 999,
	@FormaDePago = 'Efectivo'

-- 5. Registrar una venta de entradas con una actividad que no existe para ese parque

-- vemos que la actividad "Tour Guiado Senderismo 1" no existe para el Parque Nacional Iguazú
select a.Nombre from area_excursiones.actividad a 
join Area_Infraestructura.parque p on a.IdParque = p.IdParque
where p.Nombre = 'Parque Nacional Iguazú'

EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Iguazú',
	@CantidadEntradas = 2,
	@TipoVisitante = 'Residente',
	@Actividad = 'Tour Guiado Senderismo 1', --Esta actividad no existe para el Parque Nacional Iguazú, así que debería tirar error.
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 1,
	@FormaDePago = 'Efectivo'

-- 6. Registrar una venta de entradas con datos correctos
DECLARE @IdVentaEntrada INT;
EXEC @IdVentaEntrada = Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Iguazú',
	@CantidadEntradas = 2,
	@TipoVisitante = 'Residente',
	@Actividad = 'Tour Guiado Cabalgata 16', --Esta actividad sí existe para el Parque Nacional Iguazú, así que debería registrar la venta correctamente.
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 1,
	@FormaDePago = 'Efectivo'

--vemos los datos de la venta registrada
SELECT distinct v.IdVenta, pdv.Descripcion as [Punto de venta], p.Nombre, tv.Descripcion AS [Tipo visitante], fp.Descripcion AS [Forma de pago], e.IdEntrada, e.Precio as [Precio unitario], dve.Cantidad, dve.Subtotal,
 a.Nombre AS [Actividad contratada], a.Costo as [Costo actividad], v.Total as [Total venta], ca.Fecha_Contratacion, a.Duracion as [Duración actividad (horas)], v.Fecha as [Fecha venta]
FROM Area_Comercial.Venta v
JOIN Area_Comercial.Detalle_Venta_Entrada dve ON v.IdVenta = dve.IdVenta
JOIN Area_Comercial.Entrada e ON dve.IdEntrada = e.IdEntrada
join Area_Comercial.Tipo_Visitante tv on e.IdTipoVisitante = tv.IdTipoVisitante
join Area_Comercial.Forma_De_Pago fp on v.IdFormaDePago = fp.IdFormaDePago
join Area_Infraestructura.Parque p on v.IdParque = p.IdParque
join Area_Comercial.Punto_De_Venta pdv on v.IdPuntoDeVenta = pdv.IdPuntoDeVenta
join Area_Excursiones.Contratacion_Actividad ca on v.IdVenta = ca.IdVenta
join Area_Excursiones.Actividad a on ca.IdActividad = a.IdActividad
where v.IdVenta = @IdVentaEntrada

IF @IdVentaEntrada IS NOT NULL
BEGIN
    PRINT 'Venta de entradas registrada exitosamente. IdVentaEntrada: ' + CAST(@IdVentaEntrada AS VARCHAR);
END
ELSE
BEGIN
    PRINT 'Error al registrar la venta de entradas.';
END