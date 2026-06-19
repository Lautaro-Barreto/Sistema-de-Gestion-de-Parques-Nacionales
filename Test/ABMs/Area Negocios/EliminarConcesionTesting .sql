/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure utilizado para
eliminar una Concesion.
*/
USE SGParquesNacionales
GO

--SELECT * FROM Area_Negocios.Concesion
--Preparacion del entorno de testing:
--      específico

-- Variables globales para cálculos de fechas dinámicas en el entorno de testing
DECLARE @FechaVencimiento1 DATE = DATEADD(month, 3, CAST(GETDATE() AS DATE));
DECLARE @FechaVencimiento2 DATE = DATEADD(month, 4, CAST(GETDATE() AS DATE));
DECLARE @FechaPago DATE = CAST(GETDATE() AS DATE);

EXEC Area_Infraestructura.Sp_CrearRegion @Nombre = 'Noreste'
EXEC Area_Infraestructura.Sp_CrearProvincia @Nombre = 'Misiones', @Region = 'Noreste'
EXEC Area_Infraestructura.Sp_CrearTipoParque @Descripcion = 'Selva'
EXEC Area_Infraestructura.Sp_CrearParque @Nombre = 'Parque Nacional Iguazú', @TipoParqueDesc = 'Selva', @Provincia = 'Misiones', @Superficie = 50000.00

EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Reti Marley'
EXEC Area_Negocios.SP_CrearEmpresaConcesionaria 'Turrontar'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Taqueria'
EXEC Area_Negocios.SP_CrearTipoActividadConcesion 'Puesto De Nachos'
EXEC Area_Negocios.SP_CrearEstadoCanon 'Pagado'

-- Creamos los cánones con fechas válidas a futuro
EXEC Area_Negocios.SP_CrearCanon 1, 1, 95000.00, @FechaVencimiento1;
EXEC Area_Negocios.SP_CrearCanon 1, 2, 5000.00, @FechaVencimiento2;

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
EXEC Area_Negocios.SP_EliminarConcesion 1;
--Resultado: Algo salio mal en la eliminación de la Concesión
