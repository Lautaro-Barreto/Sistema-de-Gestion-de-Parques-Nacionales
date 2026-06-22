/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 22/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripcion: Este script se encarga de testear los Stored Procedures de creacion, eliminacion y
modificacion de las tablas del esquema Area_Negocios.
*/

USE SGParquesNacionales
GO

-- ===========================================================================================
--                                 Pruebas de creacion
-- ===========================================================================================

-- 1. CANON
--Preparacion del entorno de testing:
EXEC Area_Infraestructura.SP_CrearRegion
        @Nombre = 'Noreste'
        GO
EXEC Area_Infraestructura.SP_CrearProvincia
        @Nombre = 'Misiones',
        @Region = 'Noreste'
GO
 EXEC Area_Infraestructura.SP_CrearTipoParque
        @Descripcion = 'Selva'
GO
    EXEC Area_Infraestructura.SP_CrearParque
        @Nombre = 'Parque Nacional Iguazú',
        @TipoParqueDesc = 'Selva',
        @Provincia = 'Misiones',
        @Superficie = 50000.00

GO
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Reti Marley'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Turrontar'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Bairo'
GO
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto De Nachos'
GO

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 3,'Bairo',0

EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'

-- Definimos variables para calcular fechas dinámicas relativas al día de hoy
DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFutura1 DATE = DATEADD(month, 6, CAST(GETDATE() AS DATE)); -- Hoy + 6 meses
DECLARE @FechaFutura2 DATE = DATEADD(month, 3, CAST(GETDATE() AS DATE)); -- Hoy + 3 meses
DECLARE @FechaPasada DATE = DATEADD(day, -5, CAST(GETDATE() AS DATE));   -- Hace 5 días

--Casos  Exitosos.
EXEC Area_Negocios.SP_CrearCanon @IdEstado=1,
                                     @IdConcesion=1,
                                     @Monto_Mensual=95000.00,
                                    @Fecha_Vencimiento=@FechaFutura1
EXEC Area_Negocios.SP_CrearCanon 1,2, 5000.00,@FechaFutura2

-- Casos no Permitidos:
-- Estado Nulo
EXEC Area_Negocios.SP_CrearCanon NULL,2, 5000.00,@FechaFutura2
--Resultado: Algo salio mal en la creación del Canon

--Estado No existente
EXEC Area_Negocios.SP_CrearCanon 99,2, 5000.00,@FechaFutura2
--Resultado: Algo salio mal en la creación del Canon

-- Concesión Nula
EXEC Area_Negocios.SP_CrearCanon 1,NULL, 5000.00,@FechaFutura2
--Resultado: Algo salio mal en la creación del Canon

-- Concesión Inexistente
EXEC Area_Negocios.SP_CrearCanon 1,99, 5000.00,@FechaFutura2
--Resultado: Algo salio mal en la creación del Canon

-- Monto negativo
EXEC Area_Negocios.SP_CrearCanon 1,2, -5000.00,@FechaFutura2
--Resultado: Algo salio mal en la creación del Canon
-- Monto con valor 0
EXEC Area_Negocios.SP_CrearCanon 1,2, 0.00,@FechaFutura2
--Resultado: Algo salio mal en la creación del Canon

-- Fecha Nula
EXEC Area_Negocios.SP_CrearCanon 1,2, 5000.00,NULL
--Resultado: Algo salio mal en la creación del Canon

-- NUEVO CASO RECHAZADO: Fecha de vencimiento anterior a la fecha actual (Hace 5 días)
EXEC Area_Negocios.SP_CrearCanon 1, 2, 5000.00, @FechaPasada;
--Resultado: Algo salio mal en la creación del Canon
GO


-- 2. CONCESION
--Preparacion del entorno de testing:
EXEC Area_Infraestructura.Sp_CrearRegion
        @Nombre = 'Noreste'
        GO
EXEC Area_Infraestructura.Sp_CrearProvincia
        @Nombre = 'Misiones',
        @Region = 'Noreste'
GO
 EXEC Area_Infraestructura.Sp_CrearTipoParque
        @Descripcion = 'Selva'
GO
    EXEC Area_Infraestructura.Sp_CrearParque
        @Nombre = 'Parque Nacional Iguazú',
        @TipoParqueDesc = 'Selva',
        @Provincia = 'Misiones',
        @Superficie = 50000.00

GO
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Reti Marley'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Turrontar'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Bairo'
GO
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto De Nachos'
GO

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 3,'Bairo',0

--Caso  Exitoso.
EXEC Area_Negocios.SP_CrearConcesion @IdTipoActividadConcesion=1,
                                     @IdEmpresa=1,
                                     @IdParque=1,
                                    @Fecha_Inicio='2026-01-05',
                                    @Fecha_Fin='2028-01-01'
EXEC Area_Negocios.SP_CrearConcesion 1,2,1,'2025-06-06','2025-12-31'
EXEC Area_Negocios.SP_CrearConcesion 2,1,1,'2025-06-06','2027-10-31'

-- Casos no Permitidos:
-- Tipo Actividad Nula
EXEC Area_Negocios.SP_CrearConcesion NULL,1,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la creación de la Concesión

--Tipo de Actividad Inexistente
EXEC Area_Negocios.SP_CrearConcesion  99,1,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la creación de la Concesión

-- Empresa Nula
EXEC Area_Negocios.SP_CrearConcesion 1,NULL,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la creación de la Concesión

-- Empresa Inexistente
EXEC Area_Negocios.SP_CrearConcesion 1,99,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la creación de la Concesión

-- Empresa Inactiva
EXEC Area_Negocios.SP_CrearConcesion 1,3,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la creación de la Concesión


-- Parque Nulo
EXEC Area_Negocios.SP_CrearConcesion 1,1,NULL,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la creación de la Concesión


-- Parque Inexistente
EXEC Area_Negocios.SP_CrearConcesion 1,1,99,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la creación de la Concesión

--Fecha Inicio Nula
EXEC Area_Negocios.SP_CrearConcesion 1,2,1,NULL,'2025-12-31'
--Resultado: Algo salio mal en la creación de la Concesión
--Fecha Fin Nula
EXEC Area_Negocios.SP_CrearConcesion 1,2,1,'2025-06-06',NULL
--Resultado: Algo salio mal en la creación de la Concesión
--Fecha Fin anterior a Fecha Inicio
EXEC Area_Negocios.SP_CrearConcesion 1,2,1,'2025-06-06','2024-12-31'
--Resultado: Algo salio mal en la creación de la Concesión


-- 3. EMPRESA
--Casos  Exitosos.
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Cardenal'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Jumbolan'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Amiguru'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Reti Marley'

-- Casos No Permitidos:
-- Nombre Vacío
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria ''
--Resultado: Algo salio mal en el registro del nombre de la empresa

--Nombre Nulo
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria NULL

--Nombre muy grande
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbb'
--Resultado: Algo salio mal en el registro del nombre de la empresa

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria '123'
--Resultado: Algo salio mal en el registro del nombre de la empresa


-- Nombre Repetido
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa'
--Resultado: Algo salio mal en el registro del nombre de la empresa


-- 4. ESTADO_CANON
--Caso  Exitoso.
EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'

-- Casos no Permitidos:
-- Nombre Vacío
EXEC Area_Negocios.SP_CrearEstadoCanon ''
--Resultado: Algo salio mal en la creación del estado del canon

--Nombre muy grande
EXEC Area_Negocios.SP_CrearEstadoCanon 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbb'
--Resultado: Algo salio mal en la creación del estado del canon

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_CrearEstadoCanon '123'
--Resultado: Algo salio mal en el registro del nombre de la empresa

-- Nombre nulo
EXEC Area_Negocios.SP_CrearEstadoCanon NULL
--Resultado: Algo salio mal en el registro del nombre de la empresa


-- 5. PAGO_CANON
--Caso  Exitoso.
EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'

-- Casos no Permitidos:
-- Nombre Vacío
EXEC Area_Negocios.SP_CrearEstadoCanon ''
--Resultado: Algo salio mal en la creación del estado del canon

--Nombre muy grande
EXEC Area_Negocios.SP_CrearEstadoCanon 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbb'
--Resultado: Algo salio mal en la creación del estado del canon

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_CrearEstadoCanon '123'
--Resultado: Algo salio mal en el registro del nombre de la empresa

-- Nombre nulo
EXEC Area_Negocios.SP_CrearEstadoCanon NULL
--Resultado: Algo salio mal en el registro del nombre de la empresa


-- 6. TIPO_ACTIVIDAD_CONCESION
--Casos  Exitosos.
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Pizzeria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto de Nachos'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'

-- Casos No Permitidos:
-- Nombre Vacío
EXEC Area_Negocios.SP_CrearTipoActividadConcesion ''
--Resultado: Algo salio mal en el registro del nombre de la empresa

--Nombre Nulo
EXEC Area_Negocios.SP_CrearTipoActividadConcesion NULL
--Resultado: Algo salio mal en la creación del Tipo de actividad de Concesion

--Nombre muy grande
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbb'
--Resultado: Algo salio mal en la creación del Tipo de actividad de Concesion

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_CrearTipoActividadConcesion '123'
--Resultado: Algo salio mal en la creación del Tipo de actividad de Concesion

-- Nombre Repetido
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Pizzeria'
--Resultado: Algo salio mal en la creación del Tipo de actividad de Concesion


-- ===========================================================================================
--                               Pruebas de modificacion
-- ===========================================================================================

-- 1. CANON
--Preparacion del entorno de testing:
EXEC Area_Infraestructura.Sp_CrearRegion
        @Nombre = 'Noreste'
        GO
EXEC Area_Infraestructura.Sp_CrearProvincia
        @Nombre = 'Misiones',
        @Region = 'Noreste'
GO
 EXEC Area_Infraestructura.Sp_CrearTipoParque
        @Descripcion = 'Selva'
GO
    EXEC Area_Infraestructura.Sp_CrearParque
        @Nombre = 'Parque Nacional Iguazú',
        @TipoParqueDesc = 'Selva',
        @Provincia = 'Misiones',
        @Superficie = 50000.00

GO
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Reti Marley'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Turrontar'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Bairo'
GO
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto De Nachos'
GO

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 3,'Bairo',0

EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'
GO

-- Declaración de variables para el cálculo dinámico de fechas relativas a hoy
DECLARE @FechaFuturaCrear1 DATE = DATEADD(month, 3, CAST(GETDATE() AS DATE)); -- Hoy + 3 meses
DECLARE @FechaFuturaCrear2 DATE = DATEADD(month, 4, CAST(GETDATE() AS DATE)); -- Hoy + 4 meses

DECLARE @FechaModificarFutura1 DATE = DATEADD(month, 6, CAST(GETDATE() AS DATE)); -- Hoy + 6 meses
DECLARE @FechaModificarFutura2 DATE = DATEADD(month, 8, CAST(GETDATE() AS DATE)); -- Hoy + 8 meses
DECLARE @FechaModificarPasada DATE = DATEADD(month, -1, CAST(GETDATE() AS DATE));  -- Hace 1 mes (Inválida)

-- Inserción inicial:
EXEC Area_Negocios.SP_CrearCanon 1, 1, 95000.00, @FechaFuturaCrear1;
EXEC Area_Negocios.SP_CrearCanon 1, 2, 5000.00, @FechaFuturaCrear2;
GO
--Caso  Exitoso.
EXEC Area_Negocios.SP_ModificarCanon @IdCanon=1,
                                        @IdEstadoCanon=1,
                                     @IdConcesion=2,
                                     @Monto_Mensual=10000.00,
                                    @Fecha_Vencimiento=@FechaModificarFutura1
EXEC Area_Negocios.SP_ModificarCanon 1,1,2, 5000.00,@FechaModificarFutura2;

-- Casos no Permitidos:
-- Canon Nulo
EXEC Area_Negocios.SP_ModificarCanon NULL,1,2, 5000.00,@FechaModificarFutura2;
--Resultado: Algo salio mal en la modificación del Canon

-- Canon Nulo Inexistente
EXEC Area_Negocios.SP_ModificarCanon 99,1,2, 5000.00,@FechaModificarFutura2;
--Resultado: Algo salio mal en la modificación del Canon

-- Estado Nulo
EXEC Area_Negocios.SP_ModificarCanon 1,NULL,2, 5000.00,@FechaModificarFutura2;
--Resultado: Algo salio mal en la modificación del Canon

--Estado No existente
EXEC Area_Negocios.SP_ModificarCanon 1,99,2, 5000.00,@FechaModificarFutura2;
--Resultado: Algo salio mal en la modificación del Canon

-- Concesión Nula
EXEC Area_Negocios.SP_ModificarCanon 1,1,NULL, 5000.00,@FechaModificarFutura2;
--Resultado: Algo salio mal en la modificación del Canon

-- Concesión Inexistente
EXEC Area_Negocios.SP_ModificarCanon 1,1,99, 5000.00,@FechaModificarFutura2;
--Resultado: Algo salio mal en la modificación del Canon

-- Monto negativo
EXEC Area_Negocios.SP_ModificarCanon 1,1,2, -5000.00,@FechaModificarFutura2;
--Resultado: Algo salio mal en la modificación del Canon
-- Monto con valor 0
EXEC Area_Negocios.SP_ModificarCanon 1,1,2, 0.00,@FechaModificarFutura2;
--Resultado: Algo salio mal en la modificación del Canon

-- Fecha Nula
EXEC Area_Negocios.SP_ModificarCanon 1,1,2, 5000.00,NULL
--Resultado: Algo salio mal en la modificación del Canon

-- Intentar modificar el vencimiento asignando una fecha del mes pasado
EXEC Area_Negocios.SP_ModificarCanon 1, 1, 2, 5000.00, @FechaModificarPasada;
--Resultado: La fecha de vencimiento no puede ser anterior a la fecha actual.
GO


-- 2. CONCESION
--Preparacion del entorno de testing:
EXEC Area_Infraestructura.Sp_CrearRegion
        @Nombre = 'Noreste'
        GO
EXEC Area_Infraestructura.Sp_CrearProvincia
        @Nombre = 'Misiones',
        @Region = 'Noreste'
GO
 EXEC Area_Infraestructura.Sp_CrearTipoParque
        @Descripcion = 'Selva'
GO
    EXEC Area_Infraestructura.Sp_CrearParque
        @Nombre = 'Parque Nacional Iguazú',
        @TipoParqueDesc = 'Selva',
        @Provincia = 'Misiones',
        @Superficie = 50000.00

GO
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Reti Marley'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Turrontar'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Bairo'
GO
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto De Nachos'
GO

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 3,'Bairo',0


--Caso  Exitoso.
EXEC Area_Negocios.SP_ModificarConcesion @IdConcesion=1, 
                                        @IdTipoActividadConcesion=1,
                                     @IdEmpresa=2,
                                     @IdParque=1,
                                    @Fecha_Inicio='2026-01-05',
                                    @Fecha_Fin='2028-01-01'
EXEC Area_Negocios.SP_ModificarConcesion 2,2,2,1,'2025-11-09','2025-12-31'

-- Casos no Permitidos:
-- Concesion Nula
EXEC Area_Negocios.SP_ModificarConcesion NULL,1,1,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la modificación de la Concesión

-- Concesion no encontrada
EXEC Area_Negocios.SP_ModificarConcesion 99,1,1,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la modificación de la Concesión

-- Tipo Actividad Nula
EXEC Area_Negocios.SP_ModificarConcesion 1,NULL,1,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la modificación de la Concesión

--Tipo de Actividad Inexistente
EXEC Area_Negocios.SP_ModificarConcesion  1,99,1,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la modificación de la Concesión

-- Empresa Nula
EXEC Area_Negocios.SP_ModificarConcesion 1,1,NULL,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la modificación de la Concesión

-- Empresa Inexistente
EXEC Area_Negocios.SP_ModificarConcesion 1,1,99,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la modificación de la Concesión

-- Empresa Inactiva
EXEC Area_Negocios.SP_ModificarConcesion 1,1,3,1,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la modificación de la Concesión


-- Parque Nulo
EXEC Area_Negocios.SP_ModificarConcesion 1,1,1,NULL,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la modificación de la Concesión


-- Parque Inexistente
EXEC Area_Negocios.SP_ModificarConcesion 1,1,1,99,'2025-06-06','2025-12-31'
--Resultado: Algo salio mal en la modificación de la Concesión


-- 3. EMPRESA
--Preparacion de Testeo:
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Winguluy'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Cardenal'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Jumbolan'


--Casos  Exitosos.
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria @IdEmpresaConcesionaria = 1,@Nombre = 'Enterprise', @Estado = 1

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 2,'Ayudin', 0

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 3,'Lavryol',1
GO

-- Casos No Permitidos:
-- Nombre Vacío
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1,'',1
--Resultado: Algo salio mal en la modifiacion de la Empresa

--Nombre Nulo
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1, NULL,1
--Resultado: Algo salio mal en la modifiacion de la Empresa

--Nombre muy grande
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbb',1
--Resultado: Algo salio mal en la modificacion de la Empresa

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1,'123',1
--Resultado: Algo salio mal en la modificacion de la Empresa

-- Estado Nulo
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1,'Horije',NULL
--Resultado: Algo salio mal en la modificacion de la Empresa

-- Nombre Repetido
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1,'Lavryol',1
--Resultado: Algo salio mal en la modificacion de la Empresa

-- Intentar colocar otro tipo de dato en el estado
EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 1,'Horije','HOLA'
--Resultado: Error al convertir el tipo de datos varchar a bit.


-- 4. ESTADO_CANON
--Preparacion del Entorno
EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'
EXEC Area_Negocios.SP_CrearEstadoCanon 'Deuda'

--Caso  Exitoso.
EXEC Area_Negocios.SP_ModificarEstadoCanon 1,'Deuda'
EXEC Area_Negocios.SP_ModificarEstadoCanon 2,'Pagado'

-- Casos no Permitidos:
-- Nombre Vacío
EXEC Area_Negocios.SP_ModificarEstadoCanon  1,''
--Resultado: Algo salio mal en la modifiacion del Estado del Canon

--Nombre muy grande
EXEC Area_Negocios.SP_ModificarEstadoCanon  2,'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbAAAbbbb'
--Resultado: Algo salio mal en la modifiacion del Estado del Canon

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_ModificarEstadoCanon  1,'123'
--Resultado: Algo salio mal en la modifiacion del Estado del Canon

-- Nombre nulo
EXEC Area_Negocios.SP_ModificarEstadoCanon  1,NULL
--Resultado: Algo salio mal en la modifiacion del Estado del Canon

-- Identificador Inexistente
EXEC Area_Negocios.SP_ModificarEstadoCanon  5,'Pagado'
--Resultado: Algo salio mal en la modifiacion del Estado del Canon


-- 5. PAGO_CANON
--Preparacion del Entorno de Testing:
EXEC Area_Infraestructura.Sp_CrearRegion
        @Nombre = 'Noreste'
        GO
EXEC Area_Infraestructura.Sp_CrearProvincia
        @Nombre = 'Misiones',
        @Region = 'Noreste'
GO
 EXEC Area_Infraestructura.Sp_CrearTipoParque
        @Descripcion = 'Selva'
GO
    EXEC Area_Infraestructura.Sp_CrearParque
        @Nombre = 'Parque Nacional Iguazú',
        @TipoParqueDesc = 'Selva',
        @Provincia = 'Misiones',
        @Superficie = 50000.00

GO
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Reti Marley'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Turrontar'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Bairo'
GO
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto De Nachos'
GO

EXEC Area_Negocios.SP_ModificarEmpresaConcesionaria 3,'Bairo',0

EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'

EXEC Area_Negocios.SP_CrearCanon 1,1,95000.00,'2025-12-31'
EXEC Area_Negocios.SP_CrearCanon 1,2, 5000.00,'2025-10-31'

EXEC Area_Negocios.SP_CrearPagoCanon 1,50000.60,'2026-06-12'
EXEC Area_Negocios.SP_CrearPagoCanon 1,30000.00,'2026-02-03'
GO

--Casos  Exitosos.
EXEC Area_Negocios.SP_ModificarPagoCanon 3,1,50000.60,'2026-06-12'
EXEC Area_Negocios.SP_ModificarPagoCanon 1,1,35000.00,'2026-02-03'
GO

-- Casos No Permitidos:
-- Pago de Canon  Inexistente
EXEC Area_Negocios.SP_ModificarPagoCanon 99,1,50000.60,'2026-05-12'
--Resultado: Algo salio mal en la modificación del Pago del Canon

-- Pago de Canon  Nulo
EXEC Area_Negocios.SP_ModificarPagoCanon NULL,1,50000.60,'2026-05-12'
--Resultado: Algo salio mal en la modificación del Pago del Canon

-- Canon Asociado Inexistente
EXEC Area_Negocios.SP_ModificarPagoCanon 99,50000.60,'2026-05-12'
--Resultado: Algo salio mal en la modificación del Pago del Canon

-- Canon Nulo
EXEC Area_Negocios.SP_ModificarPagoCanon 1, NULL,50000.60,'2026-05-12'
--Resultado: Algo salio mal en la modificación del Pago del Canon

--Importe Nulo
EXEC Area_Negocios.SP_ModificarPagoCanon 1,1,NULL,'2026-05-12'
--Resultado: Algo salio mal en la modificación del Pago del Canon

--Importe Negativo.
EXEC Area_Negocios.SP_ModificarPagoCanon 1,1,-30000,'2026-05-12'
--Resultado: Algo salio mal en la modificación del Pago del Canon

--Importe 0 o valor cero.
EXEC Area_Negocios.SP_ModificarPagoCanon 1,1,0,'2026-05-12'
--Resultado: Algo salio mal en la modificación del Pago del Canon

--Fecha Nula.
EXEC Area_Negocios.SP_ModificarPagoCanon 1,1,0,NULL
--Resultado: Algo salio mal en la modificación del Pago del Canon

-- Dato no transformable en fecha
EXEC Area_Negocios.SP_ModificarPagoCanon 1, 1,0,'Varchar'
--Resultado: Error al convertir el tipo de datos varchar a date.


-- 6. TIPO_ACTIVIDAD_CONCESION
--Preparacion del entorno de testing:
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Pizzeria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto de Nachos'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'
GO

--Casos  Exitosos.
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,'Pastaria'
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 2,'Puesto de Hotdogs'

--EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 2,'Puesto de Nachos'

-- Casos No Permitidos:
-- Nombre Vacío
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,''
--Resultado: Algo salio mal en la modificacion del Tipo De Actividad de la concesion

--Nombre Nulo
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,NULL
--Resultado: Algo salio mal en la modificacion del Tipo De Actividad de la concesion

--Nombre muy grande
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,'AAAAAAAAAAAAAAADVVVVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAbbbb'
--Resultado: Algo salio mal en la modificación del Tipo De Actividad de la concesion

-- Nombre no compuesto por letras
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,'123'
--Resultado: Algo salio mal en la modificación del Tipo De Actividad de la concesion

-- Nombre Repetido
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 1,'Taqueria'
--Resultado: Algo salio mal en la modificación del Tipo De Actividad de la concesion

--Identificador inexistente
EXEC Area_Negocios.SP_ModificarTipoActividadConcesion 99,'Taqueria'
--Resultado: Algo salio mal en la modificación del Tipo De Actividad de la concesion


-- ===========================================================================================
--                                Pruebas de eliminacion
-- ===========================================================================================

-- 1. CANON
-- PREPARACIÓN DEL ENTORNO
EXEC Area_Infraestructura.Sp_CrearRegion 'Noreste';
EXEC Area_Infraestructura.Sp_CrearProvincia 'Misiones', 'Noreste';
EXEC Area_Infraestructura.Sp_CrearTipoParque 'Selva';
EXEC Area_Infraestructura.Sp_CrearParque 'Parque Nacional Iguazú', 'Selva', 'Misiones', 50000.00;

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Canon Test';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Boleteria Temporal';
EXEC Area_Negocios.SP_CrearEstadoCanon 'Vigente';
GO

DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
DECLARE @IdActividad INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));

-- Creamos Concesion
EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin;
GO

-- Creamos 2 Cánones
DECLARE @IdConcesion INT = (SELECT MAX(IdConcesion) FROM Area_Negocios.Concesion);
DECLARE @IdEstado INT = (SELECT MAX(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
DECLARE @Vencimiento1 DATE = DATEADD(month, 1, CAST(GETDATE() AS DATE));
DECLARE @Vencimiento2 DATE = DATEADD(month, 2, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearCanon @IdEstado, @IdConcesion, 45000.00, @Vencimiento1; -- Canon para bloquear con pago
EXEC Area_Negocios.SP_CrearCanon @IdEstado, @IdConcesion, 55000.00, @Vencimiento2; -- Canon a eliminar
GO

--Caso  Exitoso.
EXEC Area_Negocios.SP_EliminarCanon @IdCanon=2

-- Casos no Permitidos:
-- Canon Nulo
EXEC Area_Negocios.SP_EliminarCanon NULL
--Resultado: Algo salio mal en la eliminación del Canon

-- Canon Inexistente
EXEC Area_Negocios.SP_EliminarCanon 99
--Resultado: Algo salio mal en la eliminación del Canon


-- 2. CONCESION
-- PREPARACIÓN DEL ENTORNO
EXEC Area_Infraestructura.Sp_CrearRegion 'Noreste';
EXEC Area_Infraestructura.Sp_CrearProvincia 'Misiones', 'Noreste';
EXEC Area_Infraestructura.Sp_CrearTipoParque 'Selva';
EXEC Area_Infraestructura.Sp_CrearParque 'Parque Nacional Iguazú', 'Selva', 'Misiones', 50000.00;

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Concesion Test';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Boleteria Temporal';
EXEC Area_Negocios.SP_CrearEstadoCanon 'Vigente';
GO

-- Creamos 2 Concesiones
DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
DECLARE @IdActividad INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin; -- Para bloquear
EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin; -- Para borrar
GO

--Caso  Exitoso.
EXEC Area_Negocios.SP_EliminarConcesion @IdConcesion=3

-- Casos no Permitidos:
-- Concesion Nula
EXEC Area_Negocios.SP_EliminarConcesion  NULL
--Resultado: Algo salio mal en la eliminación de la Concesión

-- Concesion no encontrada
EXEC Area_Negocios.SP_EliminarConcesion 99
--Resultado: Algo salio mal en la eliminación de la Concesión

-- Intentar borrar una concesion pero que ya tiene canones.
--Primero la declaro:
DECLARE @IdConcesionBloqueada INT = (SELECT MIN(IdConcesion) FROM Area_Negocios.Concesion);
DECLARE @IdEstado INT = (SELECT MAX(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
DECLARE @Vencimiento DATE = DATEADD(month, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearCanon @IdEstado, @IdConcesionBloqueada, 1000.00, @Vencimiento;
EXEC Area_Negocios.SP_EliminarConcesion @IdConcesion = @IdConcesionBloqueada;
GO
--En efecto, no se puede eliminar porque tiene canon asociados
--Resultado: Algo salio mal en la eliminación de la Concesión


-- 3. EMPRESA
--Creamos
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Volatil S.A.';
GO

-- Creamos los cánones con fechas válidas a futuro
--SELECT * FROM Area_Negocios.Empresa_Concesionaria
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Winguluy'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Cardenal.  d df '
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Jumbolan'


--Casos  Exitosos.
--Primero busco una que si exista independiente del id.
DECLARE @IdEmpresaBorrar INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria @IdEmpresa = @IdEmpresaBorrar;
GO

-- Casos No Permitidos:
-- No existe la empresa buscada
EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria 9999
--Resultado: Algo salio mal en la eliminacion de la empresa
-- La empresa ya está inactiva o borrada

DECLARE @IdEmpresaBorrar INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria where Estado=0);
EXEC Area_Negocios.SP_EliminarEmpresaConcesionaria @IdEmpresa = @IdEmpresaBorrar;
--Resultado: No existe empresa concesionaria activa con ese ID


-- 4. ESTADO_CANON
--Preparacion del Entorno
EXEC Area_Infraestructura.Sp_CrearRegion 'Noreste';
EXEC Area_Infraestructura.Sp_CrearProvincia 'Misiones', 'Noreste';
EXEC Area_Infraestructura.Sp_CrearTipoParque 'Selva';
EXEC Area_Infraestructura.Sp_CrearParque 'Parque Nacional Iguazú', 'Selva', 'Misiones', 50000.00;

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Estado Test';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Actividad X';

-- Creamos 2 estados
EXEC Area_Negocios.SP_CrearEstadoCanon 'Estado Bloqueado';
EXEC Area_Negocios.SP_CrearEstadoCanon 'Estado Descartable';
GO
--Caso  Exitoso.
--Nuevamente busco un estado de canon
DECLARE @IdEstadoBorrar INT = (SELECT MAX(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
EXEC Area_Negocios.SP_EliminarEstadoCanon @IdEstadoCanon = @IdEstadoBorrar;

-- Casos no Permitidos:

-- Identificador Nulo
EXEC Area_Negocios.SP_EliminarEstadoCanon  NULL
--Resultado: Algo salio mal en la eliminacion del Estado de Canon

-- Identificador no Encontrado
EXEC Area_Negocios.SP_EliminarEstadoCanon 99999
--Resultado: Algo salio mal en la eliminacion del Estado de Canon

-- Intentar borrar una que ya tiene canon asociado (Estado en uso por un Canon)
--Primero lo creamos
--Selecciono un id empresa y actividad y parque, buscando el maximo para que no interfiera
--el identity de las claves primarias.
DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria where Estado=1);
DECLARE @IdActividad INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
--La fecha de inicio es ahora y la de fin es un año despues
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));
--Finalmente creo la concesión
EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin;
--Ahora selecciono la concesión (la última creada)
DECLARE @IdConcesion INT = (SELECT MAX(IdConcesion) FROM Area_Negocios.Concesion);
DECLARE @IdEstadoBloqueado INT = (SELECT MIN(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
DECLARE @Vencimiento DATE = DATEADD(month, 1, CAST(GETDATE() AS DATE));

--Con el canon creado, su estado no se podría borrar
EXEC Area_Negocios.SP_CrearCanon @IdEstadoBloqueado, @IdConcesion, 500.00, @Vencimiento;
EXEC Area_Negocios.SP_EliminarEstadoCanon @IdEstadoCanon = @IdEstadoBloqueado;
GO


-- 5. PAGO_CANON
-- PREPARACIÓN DEL ENTORNO
EXEC Area_Infraestructura.Sp_CrearRegion 'Noreste';
EXEC Area_Infraestructura.Sp_CrearProvincia 'Misiones', 'Noreste';
EXEC Area_Infraestructura.Sp_CrearTipoParque 'Selva';
EXEC Area_Infraestructura.Sp_CrearParque 'Parque Nacional Iguazú', 'Selva', 'Misiones', 50000.00;

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Pago Test';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Actividad X';
EXEC Area_Negocios.SP_CrearEstadoCanon 'Vigente';
GO

DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
DECLARE @IdActividad INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearConcesion @IdActividad, @IdEmpresa, @IdParque, @FechaIn, @FechaFin;

DECLARE @IdConcesion INT = (SELECT MAX(IdConcesion) FROM Area_Negocios.Concesion);
DECLARE @IdEstado INT = (SELECT MAX(IdEstadoCanon) FROM Area_Negocios.Estado_Canon);
DECLARE @Vencimiento DATE = DATEADD(month, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearCanon @IdEstado, @IdConcesion, 500.00, @Vencimiento;

DECLARE @IdCanon INT = (SELECT MAX(IdCanon) FROM Area_Negocios.Canon);
DECLARE @FechaPago DATE = CAST(GETDATE() AS DATE);
EXEC Area_Negocios.SP_CrearPagoCanon @IdCanon, 500.00, @FechaPago;
GO

--Casos  Exitosos.
DECLARE @IdPagoBorrar INT = (SELECT MAX(IdPagoCanon) FROM Area_Negocios.Pago_Canon);
EXEC Area_Negocios.SP_EliminarPagoCanon @IdPagoCanon = @IdPagoBorrar;


-- Casos No Permitidos:
-- Pago de Canon  Inexistente
EXEC Area_Negocios.SP_EliminarPagoCanon NULL
--Resultado: Algo salio mal en la eliminación del Pago de Canon

-- Pago de Canon  Inexistente
EXEC Area_Negocios.SP_EliminarPagoCanon 9999
--Resultado: Algo salio mal en la eliminación del Pago de Canon


-- 6. TIPO_ACTIVIDAD_CONCESION
-- PREPARACIÓN DEL ENTORNO
EXEC Area_Infraestructura.Sp_CrearRegion 'Noreste';
EXEC Area_Infraestructura.Sp_CrearProvincia 'Misiones', 'Noreste';
EXEC Area_Infraestructura.Sp_CrearTipoParque 'Selva';
EXEC Area_Infraestructura.Sp_CrearParque 'Parque Nacional Iguazú', 'Selva', 'Misiones', 50000.00;

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Empresa Actividad Test';

-- Creamos 2 actividades
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Actividad Bloqueada';
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Actividad Efimera';
GO

--Casos Exitosos.
DECLARE @IdActividadBorrar INT = (SELECT MAX(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
EXEC Area_Negocios.SP_EliminarTipoActividadConcesion @IdTipoActividadConcesion = @IdActividadBorrar;


-- Casos No Permitidos:
--Identificador Nulo
EXEC Area_Negocios.SP_EliminarTipoActividadConcesion NULL
--Resultado: Algo salio mal en la eliminación del Tipo de Actividad Concesion

--Identificador inexistente
EXEC Area_Negocios.SP_EliminarTipoActividadConcesion 9999
--Resultado: Algo salio mal en la eliminación del Tipo de Actividad Concesion

-- Integridad  (Actividad asignada a una Concesion)
DECLARE @IdEmpresa INT = (SELECT MAX(IdEmpresa) FROM Area_Negocios.Empresa_Concesionaria);
DECLARE @IdActividadBloqueada INT = (SELECT MIN(IdTipoActividadConcesion) FROM Area_Negocios.Tipo_Actividad_Concesion);
DECLARE @IdParque INT = (SELECT MAX(IdParque) FROM Area_Infraestructura.Parque);
DECLARE @FechaIn DATE = CAST(GETDATE() AS DATE);
DECLARE @FechaFin DATE = DATEADD(year, 1, CAST(GETDATE() AS DATE));

EXEC Area_Negocios.SP_CrearConcesion @IdActividadBloqueada, @IdEmpresa, @IdParque, @FechaIn, @FechaFin;

EXEC Area_Negocios.SP_EliminarTipoActividadConcesion @IdTipoActividadConcesion = @IdActividadBloqueada;
GO
