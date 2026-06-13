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

