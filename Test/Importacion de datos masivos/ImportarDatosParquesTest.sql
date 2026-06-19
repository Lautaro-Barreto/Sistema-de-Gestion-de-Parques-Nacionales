/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 09/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar los SPs de importación de datos masivos,
ejecutándolos y validando que los datos hayan sido importados correctamente a la tabla de staging y luego
a la tabla Parque, Region, Provincia, Tipo de Parque. 
*/

USE SGParquesNacionales
GO

-- Ejecutamos el SP de importación general para un archivo XML
EXEC Area_Infraestructura.Sp_ImportarDatosParques
    @RutaArchivoParques = 'C:\ArchivosTPBDA\sheet1.xml',
go

SELECT par.Nombre AS Parque, p.Nombre AS Provincia, r.Nombre AS Region, par.Superficie AS Superficie, tp.Descripcion AS Tipo_Parque
FROM Area_Infraestructura.Parque par
LEFT JOIN Area_Infraestructura.Provincia p ON par.IdProvincia = p.IdProvincia
LEFT JOIN Area_Infraestructura.Region r ON p.IdRegion = r.IdRegion
LEFT JOIN Area_Infraestructura.Tipo_Parque tp ON par.IdTipoParque = tp.IdTipoParque;
go

DELETE FROM Area_Infraestructura.Parque;
go
DELETE FROM Area_Infraestructura.Provincia;
go
DELETE FROM Area_Infraestructura.Region;
go
DELETE FROM Area_Infraestructura.Tipo_Parque;
go

-- Ejecutamos el SP de importación general para un archivo CSV
EXEC Area_Infraestructura.Sp_ImportarDatosParques
    @RutaArchivoParques = 'C:\ArchivosTPBDA\Áreas protegidas de Argentina - Sistema de Información de Biodiversidad.csv',
    @RutaArchivoVisitas = 'C:\ArchivosTPBDA\Visitas a parques nacionales - Sistema de Información de Biodiversidad.csv';
go

SELECT par.Nombre AS Parque, p.Nombre AS Provincia, r.Nombre AS Region, par.Superficie AS Superficie, tp.Descripcion AS Tipo_Parque
FROM Area_Infraestructura.Parque par
LEFT JOIN Area_Infraestructura.Provincia p ON par.IdProvincia = p.IdProvincia
LEFT JOIN Area_Infraestructura.Region r ON p.IdRegion = r.IdRegion
LEFT JOIN Area_Infraestructura.Tipo_Parque tp ON par.IdTipoParque = tp.IdTipoParque;
go