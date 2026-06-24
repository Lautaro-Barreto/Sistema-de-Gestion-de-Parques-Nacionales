
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar el SP que registra la venta de entradas
Requisitos para ejecutarlo: haber ejecutado el script "seed data" para tener datos en la base de datos y haber creado el SP "Sp_RegistrarVentaEntradas" previamente.
*/

/*
====================================================================================================================================
                        PREPARACIÓN DE DATOS PARA PRUEBAS DE PAGO DE CANONES
                        
                        Requisitos:
                        - Haber ejecutado previamente el script de creación de la base de datos y sus objetos.
                        - Haber ejecutado previamente el script de creación de los SPs de ABM y Lógica de Negocios.
						- No tener datos en la tablas venta, detalle, entrada para que se vean claramente los resultados

                        Ir ejecutando cada parte de a una, yendo por cada "bloque" separado por la declaración de variables
====================================================================================================================================
*/

USE SGParquesNacionales
GO

/*
DELETE FROM Area_Comercial.Precio_Parque_Tipo_Visitante;
DELETE FROM Area_Excursiones.Contratacion_Actividad;
DELETE FROM AREA_Comercial.Detalle_Venta_Entrada;
DELETE FROM Area_Comercial.Entrada;
DELETE FROM Area_Comercial.Venta;
*/

IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Punto_De_Venta)
BEGIN
	EXEC Area_Comercial.SP_CrearPuntoDeVenta 'Boletería Principal';
	EXEC Area_Comercial.SP_CrearPuntoDeVenta 'Web';
END

IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Forma_De_Pago)
BEGIN
	EXEC Area_Comercial.SP_CrearFormaDePago 'Efectivo';
    EXEC Area_Comercial.SP_CrearFormaDePago 'Tarjeta de Credito';
    EXEC Area_Comercial.SP_CrearFormaDePago 'Tarjeta de Debito';
    EXEC Area_Comercial.SP_CrearFormaDePago 'Transferencia';
END

IF NOT EXISTS (SELECT 1 FROM Area_Comercial.Tipo_Visitante)
BEGIN
	EXEC Area_Comercial.Sp_CrearTipoVisitante 'Residente';
	EXEC Area_Comercial.Sp_CrearTipoVisitante 'No residente';
END

EXEC Area_Infraestructura.SP_CrearRegion
    @Nombre = 'Región Increíble dos';

EXEC Area_Infraestructura.SP_CrearProvincia
    @Nombre = 'Provincia Increíble dos',
    @NombreRegion = 'Región Increíble dos';

EXEC Area_Infraestructura.SP_CrearTipoParque
    @Descripcion = 'Parque Increíble dos';

EXEC Area_Infraestructura.SP_CrearParque
    @Nombre = 'Parque Nacional Increíble dos',
    @TipoParqueDesc = 'Parque Increíble dos',
    @Provincia = 'Provincia Increíble dos',
    @Superficie = 3333.33; 

EXEC Area_Infraestructura.SP_CrearParque
    @Nombre = 'Parque Nacional Increíble uno',
    @TipoParqueDesc = 'Parque Increíble dos',
    @Provincia = 'Provincia Increíble dos',
    @Superficie = 3333.33; 

EXEC Area_Comercial.Sp_CrearPrecioParqueTipoVisitante
	@Parque = 'Parque Nacional Increíble uno',
	@TipoVisitante = 'Residente',
	@Precio = 33.33;

EXEC Area_Comercial.Sp_CrearPrecioParqueTipoVisitante
	@Parque = 'Parque Nacional Increíble uno',
	@TipoVisitante = 'No residente',
	@Precio = 44.44;

EXEC Area_Comercial.Sp_CrearPrecioParqueTipoVisitante
	@Parque = 'Parque Nacional Increíble dos',
	@TipoVisitante = 'Residente',
	@Precio = 33.33;

EXEC Area_Comercial.Sp_CrearPrecioParqueTipoVisitante
	@Parque = 'Parque Nacional Increíble dos',
	@TipoVisitante = 'No residente',
	@Precio = 44.44;

EXEC Area_Excursiones.SP_CrearTipoActividad
	@Descripcion = 'Turismo Increíble';

DECLARE @IdTipoActividadIncreible INT = (SELECT IdTipoActividad FROM Area_Excursiones.Tipo_Actividad WHERE Descripcion = 'Turismo Increíble');
DECLARE @IdParqueIncreible INT = (SELECT IdParque FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque Nacional Increíble dos');
EXEC Area_Excursiones.Sp_CrearActividad
	@tipoActividad = @IdTipoActividadIncreible,
	@idParque = @IdParqueIncreible,
	@Nombre = 'Excursión Increíble',
	@Costo = 33.33,
	@Duracion = 3,
	@Cupo_maximo = 3;
EXEC Area_Excursiones.Sp_CrearActividad
	@tipoActividad = @IdTipoActividadIncreible,
	@idParque = @IdParqueIncreible,
	@Nombre = 'Turismo Increíble',
	@Costo = 33.33,
	@Duracion = 3,
	@Cupo_maximo = 3;

-- Verificar datos inicializados
select * from area_infraestructura.region where Nombre = 'Región Increíble dos';
select * from area_infraestructura.provincia where Nombre = 'Provincia Increíble dos';
select * from area_infraestructura.parque where Nombre = 'Parque Nacional Increíble dos';
select * from area_excursiones.tipo_actividad where Descripcion = 'Turismo Increíble';
select * from area_excursiones.actividad where Nombre in ('Excursión Increíble', 'Turismo Increíble');
SELECT * FROM Area_Comercial.Punto_De_Venta;
SELECT * FROM Area_Comercial.Forma_De_Pago;
SELECT * FROM Area_Comercial.Precio_Parque_Tipo_Visitante;

/*
====================================================================================================================
    PRUEBA 1: Venta de entradas válida, con o sin contratación de actividad
    - Registrar una venta de entradas válida en el parque creado
	- Verificar que la venta se haya registrado correctamente y que los datos sean correctos
	- Verificar que el total de la venta sea correcto y que se haya registrado correctamente en la tabla de ventas
	- Ver el detalle (ticket) correspondiente de la venta
====================================================================================================================
*/

DECLARE @PdvRandom INT = (SELECT TOP 1 IdPuntoDeVenta FROM Area_Comercial.Punto_De_Venta ORDER BY NEWID());
DECLARE @FechaActual DATE = GETDATE();

-- Venta de entradas con contratación de actividad
EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Increíble dos',
	@CantidadEntradas = 2,
	@TipoVisitante = 'Residente',
	@Actividad = 'Excursión Increíble',
	@Fecha = @FechaActual,
	@IdPuntoDeVenta = @PdvRandom,
	@FormaDePago = 'Efectivo'

-- Para ver el ticket completo 
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

-- Venta de entradas sin contratación de actividad
DECLARE @FechaActual2 DATE = GETDATE();
DECLARE @PdvRandom2 INT = (SELECT TOP 1 IdPuntoDeVenta FROM Area_Comercial.Punto_De_Venta ORDER BY NEWID());
EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Increíble uno',
	@CantidadEntradas = 2,
	@TipoVisitante = 'Residente',
	@Actividad = NULL,
	@Fecha = @FechaActual2,
	@IdPuntoDeVenta = @PdvRandom2,
	@FormaDePago = 'Efectivo'

-- Para ver el ticket completo
-- Se puede ver que no hay actividad contratada, y que el total de la venta es correcto (2 entradas * 33.33 = 66.66) 
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

/*
====================================================================================================================
    PRUEBA 2: Validaciones de los SPs
    - Registrar una venta de entradas con un parque inexistente
	- Registrar una venta de entradas con un tipo de visitante inexistente
====================================================================================================================
*/

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
	@Parque = 'Parque Nacional Increíble dos',
    @CantidadEntradas = 1,
    @TipoVisitante = 'Inexistente',
    @Actividad = 'Trekking',
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 1,
	@FormaDePago = 'Efectivo'
go

-- 3. Registrar una venta de entradas con una cantidad de entradas invalida
EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Increíble dos',
    @CantidadEntradas = 0,
    @TipoVisitante = 'Residente',
    @Actividad = 'Turismo Increíble',
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 2,
	@FormaDePago = 'Efectivo'
go

-- 4. Registrar una venta de entradas con un punto de venta inexistente
EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Increíble dos',
	@CantidadEntradas = 1,
	@TipoVisitante = 'Residente',
	@Actividad = 'Tour Guiado Senderismo 1',
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 999,
	@FormaDePago = 'Efectivo'
go

-- 5. Registrar una venta de entradas con una actividad que no existe para ese parque
EXEC Area_Comercial.Sp_RegistrarVentaEntradas
	@Parque = 'Parque Nacional Increíble Uno',
	@CantidadEntradas = 2,
	@TipoVisitante = 'Residente',
	@Actividad = 'Excursión Increíble', --Esta actividad no existe para el Parque Nacional Iguazú, así que debería tirar error.
	@Fecha = '2026-07-15',
	@IdPuntoDeVenta = 1,
	@FormaDePago = 'Efectivo'