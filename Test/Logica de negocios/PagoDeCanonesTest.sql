/*
====================================================================================================================================
                        PREPARACIÓN DE DATOS PARA PRUEBAS DE PAGO DE CANONES
                        
                        Requisitos:
                        - Haber ejecutado previamente el script de creación de la base de datos y sus objetos.
                        - Haber ejecutado previamente el script de creación de los SPs de ABM y Lógica de Negocios.

                        Ir ejecutando cada parte de a una, yendo por cada "bloque" separado por la declaración de variables
====================================================================================================================================
*/

USE SGParquesNacionales
GO

-- Insertar Estados de Canon (si no existen)
IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon)
BEGIN
    EXEC Area_Negocios.SP_CrearEstadoCanon 'Vigente'
    EXEC Area_Negocios.SP_CrearEstadoCanon 'Adeudado'
    EXEC Area_Negocios.SP_CrearEstadoCanon 'Saldado en Término'
    EXEC Area_Negocios.SP_CrearEstadoCanon 'Saldado con Atraso'
    EXEC Area_Negocios.SP_CrearEstadoCanon 'Exento'
    EXEC Area_Negocios.SP_CrearEstadoCanon 'Extinguido'
END

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria
    @Nombre = 'Empresa Increíble';

EXEC Area_Negocios.SP_CrearTipoActividadConcesion
    @Descripcion = 'Turismo Increíble';

EXEC Area_Infraestructura.SP_CrearRegion
    @Nombre = 'Región Increíble';

EXEC Area_Infraestructura.SP_CrearProvincia
    @Nombre = 'Provincia Increíble',
    @NombreRegion = 'Región Increíble';

EXEC Area_Infraestructura.SP_CrearTipoParque
    @Descripcion = 'Parque Increíble';

EXEC Area_Infraestructura.SP_CrearParque
    @Nombre = 'Parque Nacional Increíble',
    @TipoParqueDesc = 'Parque Increíble',
    @Provincia = 'Provincia Increíble',
    @Superficie = 1000.75; 

select * from area_negocios.empresa_concesionaria where Nombre = 'Empresa Increíble';
select * from area_negocios.tipo_actividad_concesion where Descripcion = 'Turismo Increíble';
select * from area_infraestructura.region where Nombre = 'Región Increíble';
select * from area_infraestructura.provincia where Nombre = 'Provincia Increíble';
select * from area_infraestructura.parque where Nombre = 'Parque Nacional Increíble';

/*
====================================================================================================================
    PRUEBA 1:
    - Crear una concesión para la empresa, parque y actividad previamente creados
    - Registrar el pago de un canon vigente
    - verificar que se genere el próximo canon a pagar
    - verificar que el estado del canon anterior cambie a "Saldado en Término"
====================================================================================================================
*/

DECLARE @IdEmpresaN INT, @IdTipoAct INT, @IdParqueN INT;
SELECT @IdEmpresaN = IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = 'Empresa Increíble';
SELECT @IdTipoAct = IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = 'Turismo Increíble';
SELECT @IdParqueN = IdParque FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque Nacional Increíble';

-- Creamos una concesión para esa empresa, parque y actividad, y luego verificamos que se haya creado correctamente
EXEC Area_Negocios.SP_CrearConcesion
    @IdTipoActividadConcesion = @IdTipoAct,
    @IdEmpresa = @IdEmpresaN,
    @IdParque = @IdParqueN,
    @Fecha_Inicio = '2026-01-01',
    @Fecha_Fin = '2026-07-30';

SELECT c.IdConcesion, ec.Nombre as Empresa, p.Nombre as Parque, c.Fecha_Inicio, c.Fecha_Fin, tac.Descripcion as Actividad
FROM area_negocios.concesion c
INNER JOIN area_negocios.empresa_concesionaria ec ON c.IdEmpresa = ec.IdEmpresa
INNER JOIN area_negocios.tipo_actividad_concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
INNER JOIN area_infraestructura.parque p ON c.IdParque = p.IdParque
WHERE ec.Nombre = 'Empresa Increíble' AND tac.Descripcion = 'Turismo Increíble' AND p.Nombre = 'Parque Nacional Increíble';

-- Creamos el canon para esa concesión, y luego verificamos que se haya creado correctamente
DECLARE @EstadoVigente INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Vigente');
DECLARE @ConcesionIncreible INT = (SELECT IdConcesion FROM Area_Negocios.Concesion WHERE IdEmpresa = (SELECT IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = 'Empresa Increíble') AND IdTipoActividadConcesion = (SELECT IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = 'Turismo Increíble') AND IdParque = (SELECT IdParque FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque Nacional Increíble'));

EXEC Area_Negocios.SP_CrearCanon
    @IdEstado = @EstadoVigente,
    @IdConcesion = @ConcesionIncreible,
    @Monto_Mensual = 1000.00,
    @Fecha_Vencimiento = '2026-07-01';

SELECT ca.IdCanon, c.IdConcesion, ec.Nombre, p.Nombre as Parque, ec2.Descripcion as Estado, ca.Monto_Mensual, ca.Fecha_Vencimiento
FROM area_negocios.canon ca
INNER JOIN area_negocios.concesion c ON ca.IdConcesion = c.IdConcesion
INNER JOIN area_negocios.empresa_concesionaria ec ON c.IdEmpresa = ec.IdEmpresa
INNER JOIN area_negocios.tipo_actividad_concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
INNER JOIN area_negocios.estado_canon ec2 ON ca.IdEstado = ec2.IdEstadoCanon
INNER JOIN area_infraestructura.parque p ON c.IdParque = p.IdParque
WHERE ec.Nombre = 'Empresa Increíble' AND tac.Descripcion = 'Turismo Increíble' AND p.Nombre = 'Parque Nacional Increíble';

-- Ahora registramos el pago del canon vigente 
DECLARE @EstadoVigenteN INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Vigente');
DECLARE @ConcesionIncreibleN INT = (SELECT distinct IdConcesion FROM Area_Negocios.Concesion WHERE IdEmpresa = (SELECT IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = 'Empresa Increíble') AND IdTipoActividadConcesion = (SELECT IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = 'Turismo Increíble') AND IdParque = (SELECT IdParque FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque Nacional Increíble'));
DECLARE @IdCanonIncreible INT = (SELECT distinct IdCanon FROM Area_Negocios.Canon WHERE IdConcesion = @ConcesionIncreibleN AND IdEstado = @EstadoVigenteN);
DECLARE @FechaActual DATE = GETDATE();

EXEC Area_Negocios.SP_Registrar_Pago_Canon
    @IdConcesion = @ConcesionIncreibleN,
    @IdCanon = @IdCanonIncreible,
    @Fecha_Pago = @FechaActual,
    @Monto_Abonado = 1000.00

-- Verificamos que el pago se haya registrado correctamente
select * from area_negocios.pago_canon where IdCanon = @IdCanonIncreible;

-- Verificamos dos cosas:
-- 1. Que se haya creado un nuevo canon a vencerse el mes siguiente
-- 2. Que el canon anterior haya cambiado su estado a "Saldado en Término" o "Saldado con Atraso" según corresponda
SELECT ca.IdCanon, c.IdConcesion, ec.Nombre, p.Nombre as Parque, ec2.Descripcion as Estado, ca.Monto_Mensual, ca.Fecha_Vencimiento
FROM area_negocios.canon ca
INNER JOIN area_negocios.concesion c ON ca.IdConcesion = c.IdConcesion
INNER JOIN area_negocios.empresa_concesionaria ec ON c.IdEmpresa = ec.IdEmpresa
INNER JOIN area_negocios.tipo_actividad_concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
INNER JOIN area_negocios.estado_canon ec2 ON ca.IdEstado = ec2.IdEstadoCanon
INNER JOIN area_infraestructura.parque p ON c.IdParque = p.IdParque
WHERE ec.Nombre = 'Empresa Increíble' AND tac.Descripcion = 'Turismo Increíble' AND p.Nombre = 'Parque Nacional Increíble';

/*
====================================================================================================================
    PRUEBA 2:
    - Registrar un pago de un canon en una fecha posterior a su vencimiento
    - verificar que se genere el próximo canon a pagar
    - verificar que el estado del canon anterior cambie a "Saldado con Atraso"
====================================================================================================================
*/

-- Ahora intentaremos pagar el segundo canon en una fecha posterior a su vencimiento para verificar que el estado cambie a "Saldado con Atraso"
-- También veremos que se genere el tercer canon a vencerse el mes siguiente
DECLARE @EstadoVigenteNN INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Vigente');
DECLARE @ConcesionIncreibleNN INT = (SELECT IdConcesion FROM Area_Negocios.Concesion WHERE IdEmpresa = (SELECT IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = 'Empresa Increíble') AND IdTipoActividadConcesion = (SELECT IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = 'Turismo Increíble') AND IdParque = (SELECT IdParque FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque Nacional Increíble'));
DECLARE @IdCanonIncreibleNN INT = (SELECT distinct IdCanon FROM Area_Negocios.Canon WHERE IdConcesion = @ConcesionIncreibleNN AND IdEstado = @EstadoVigenteNN);
DECLARE @FechaAtrasada DATE = (SELECT DATEADD(DAY, 10, Fecha_Vencimiento) FROM Area_Negocios.Canon WHERE IdCanon = @IdCanonIncreibleNN);

EXEC Area_Negocios.SP_Registrar_Pago_Canon
    @IdConcesion = @ConcesionIncreibleNN,
    @IdCanon = @IdCanonIncreibleNN,
    @Fecha_Pago = @FechaAtrasada,
    @Monto_Abonado = 1000.00

Select * from area_negocios.pago_canon where IdCanon = @IdCanonIncreibleNN;

SELECT ca.IdCanon, c.IdConcesion, ec.Nombre, p.Nombre as Parque, ec2.Descripcion as Estado, ca.Monto_Mensual, ca.Fecha_Vencimiento
FROM area_negocios.canon ca
INNER JOIN area_negocios.concesion c ON ca.IdConcesion = c.IdConcesion
INNER JOIN area_negocios.empresa_concesionaria ec ON c.IdEmpresa = ec.IdEmpresa
INNER JOIN area_negocios.tipo_actividad_concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
INNER JOIN area_negocios.estado_canon ec2 ON ca.IdEstado = ec2.IdEstadoCanon
INNER JOIN area_infraestructura.parque p ON c.IdParque = p.IdParque
WHERE ec.Nombre = 'Empresa Increíble' AND tac.Descripcion = 'Turismo Increíble' AND p.Nombre = 'Parque Nacional Increíble';

/*
====================================================================================================================
    PRUEBA 3:
    - Intentar registrar un pago de un canon exento
    - verificar que se genere el error correspondiente y no se registre el pago
====================================================================================================================
*/

-- Ahora creamos un canon exento para la misma concesión y verificamos que no se pueda pagar
DECLARE @ConcesionIncreibleNNN INT = (SELECT IdConcesion FROM Area_Negocios.Concesion WHERE IdEmpresa = (SELECT IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = 'Empresa Increíble') AND IdTipoActividadConcesion = (SELECT IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = 'Turismo Increíble') AND IdParque = (SELECT IdParque FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque Nacional Increíble'));
DECLARE @EstadoExento INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Exento');

EXEC Area_Negocios.SP_CrearCanon
    @IdEstado = @EstadoExento,
    @IdConcesion = @ConcesionIncreibleNNN,
    @Monto_Mensual = 1000.00,
    @Fecha_Vencimiento = '2026-08-01';

-- Ahora intentamos pagar el canon exento y esperamos que nos devuelva un error
DECLARE @EstadoExentoN INT = (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Exento');
DECLARE @ConcesionIncreibleNNNN INT = (SELECT IdConcesion FROM Area_Negocios.Concesion WHERE IdEmpresa = (SELECT IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = 'Empresa Increíble') AND IdTipoActividadConcesion = (SELECT IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = 'Turismo Increíble') AND IdParque = (SELECT IdParque FROM Area_Infraestructura.Parque WHERE Nombre = 'Parque Nacional Increíble'));
DECLARE @IdCanonExento INT = (SELECT distinct IdCanon FROM Area_Negocios.Canon WHERE IdConcesion = @ConcesionIncreibleNNNN AND IdEstado = @EstadoExentoN);
DECLARE @FechaActualN DATE = GETDATE();

EXEC Area_Negocios.SP_Registrar_Pago_Canon
    @IdConcesion = @ConcesionIncreibleNNNN,
    @IdCanon = @IdCanonExento,
    @Fecha_Pago = @FechaActualN,
    @Monto_Abonado = 1000.00;

Select * from area_negocios.pago_canon where IdCanon = @IdCanonExento;

SELECT ca.IdCanon, c.IdConcesion, ec.Nombre, p.Nombre as Parque, ec2.Descripcion as Estado, ca.Monto_Mensual, ca.Fecha_Vencimiento
FROM area_negocios.canon ca
INNER JOIN area_negocios.concesion c ON ca.IdConcesion = c.IdConcesion
INNER JOIN area_negocios.empresa_concesionaria ec ON c.IdEmpresa = ec.IdEmpresa
INNER JOIN area_negocios.tipo_actividad_concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
INNER JOIN area_negocios.estado_canon ec2 ON ca.IdEstado = ec2.IdEstadoCanon
INNER JOIN area_infraestructura.parque p ON c.IdParque = p.IdParque
WHERE ec.Nombre = 'Empresa Increíble' AND tac.Descripcion = 'Turismo Increíble' AND p.Nombre = 'Parque Nacional Increíble';

SELECT * FROM Area_Negocios.Canon
SELECT * FROM Area_Negocios.Pago_Canon