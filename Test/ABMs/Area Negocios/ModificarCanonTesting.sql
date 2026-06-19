/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure utilizado para
Modificar un Canon.
*/
USE SGParquesNacionales
GO

--SELECT * FROM Area_Negocios.Canon
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

-- ==========================================================================================
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
