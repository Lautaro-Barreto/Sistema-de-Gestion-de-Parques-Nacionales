
/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar los SPs de importación de datos masivos desde un archivo CSV,
ejecutándolos y validando que los datos hayan sido importados correctamente a la tabla de staging y luego a la tabla Empresa_Concesionaria.  
*/

USE SGParquesNacionales
GO

-- Ejecutamos el SP de importación general para un archivo CSV
EXEC Area_Negocios.Sp_ImportarDatosEmpresas
    @RutaArchivoEmpresas = 'C:\ArchivosTPBDA\registro-organizaciones-distinguidas-sact.csv';

select concesion.IdConcesion, ec.Nombre, concesion.Fecha_Inicio, concesion.Fecha_Fin, tac.Descripcion as Actividad from area_negocios.concesion concesion
INNER JOIN area_negocios.empresa_concesionaria ec ON concesion.IdEmpresa = ec.IdEmpresa
INNER JOIN area_negocios.tipo_actividad_concesion tac ON concesion.IdTipoActividadConcesion = tac.IdTipoActividadConcesion

SELECT ca.IdCanon, ec.Nombre, p.Nombre as Parque, ec2.Descripcion as Estado, ca.Monto_Mensual, ca.Fecha_Vencimiento FROM area_negocios.canon ca
INNER JOIN area_negocios.concesion c ON ca.IdConcesion = c.IdConcesion
INNER JOIN area_negocios.empresa_concesionaria ec ON c.IdEmpresa = ec.IdEmpresa
INNER JOIN area_negocios.tipo_actividad_concesion tac ON c.IdTipoActividadConcesion = tac.IdTipoActividadConcesion
INNER JOIN area_negocios.estado_canon ec2 ON ca.IdEstado = ec2.IdEstadoCanon
INNER JOIN area_infraestructura.parque p ON c.IdParque = p.IdParque;