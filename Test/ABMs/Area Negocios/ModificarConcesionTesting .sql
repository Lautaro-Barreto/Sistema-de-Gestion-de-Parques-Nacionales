/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 12/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga del testing del Stored Procedure utilizado para
modificar una Concesion.
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

