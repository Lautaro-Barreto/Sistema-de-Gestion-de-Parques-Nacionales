/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure de la modificación de un
Pago del canon. 
*/
USE SGParquesNacionales
GO

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
--SElect * FROM Area_Negocios.Pago_Canon
EXEC Area_Negocios.SP_EliminarPagoCanon 3
GO


-- Casos No Permitidos:

-- Pago de Canon  Inexistente
EXEC Area_Negocios.SP_EliminarPagoCanon NULL
--Resultado: Algo salio mal en la eliminación del Pago de Canon

-- Pago de Canon  Inexistente
EXEC Area_Negocios.SP_EliminarPagoCanon 99
--Resultado: Algo salio mal en la eliminación del Pago de Canon
