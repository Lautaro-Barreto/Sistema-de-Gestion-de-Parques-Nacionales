/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure utilizado para
crear un Canon.
*/
USE SGParquesNacionales
GO

--SELECT * FROM Area_Negocios.Concesion
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

--Caso  Exitoso.
EXEC Area_Negocios.SP_CrearCanon @IdEstado=1,
                                     @IdConcesion=1,
                                     @Monto_Mensual=95000.00,
                                    @Fecha_Vencimiento='2025-12-31'
EXEC Area_Negocios.SP_CrearCanon 1,2, 5000.00,'2025-10-31'

-- Casos no Permitidos:

-- Estado Nulo
EXEC Area_Negocios.SP_CrearCanon NULL,2, 5000.00,'2025-10-31'
--Resultado: Algo salio mal en la creación del Canon

--Estado No existente
EXEC Area_Negocios.SP_CrearCanon 99,2, 5000.00,'2025-10-31'
--Resultado: Algo salio mal en la creación del Canon

-- Concesión Nula
EXEC Area_Negocios.SP_CrearCanon 1,NULL, 5000.00,'2025-10-31'
--Resultado: Algo salio mal en la creación del Canon

-- Concesión Inexistente
EXEC Area_Negocios.SP_CrearCanon 1,99, 5000.00,'2025-10-31'
--Resultado: Algo salio mal en la creación del Canon

-- Monto negativo
EXEC Area_Negocios.SP_CrearCanon 1,2, -5000.00,'2025-10-31'
--Resultado: Algo salio mal en la creación del Canon
-- Monto con valor 0
EXEC Area_Negocios.SP_CrearCanon 1,2, 0.00,'2025-10-31'
--Resultado: Algo salio mal en la creación del Canon

-- Fecha Nula
EXEC Area_Negocios.SP_CrearCanon 1,2, 5000.00,NULL
--Resultado: Algo salio mal en la creación del Canon


