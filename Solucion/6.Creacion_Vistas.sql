/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 26/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación de todas las vistas usadas
*/

--Esta vista busca permitir ver guardaparques pero sin que puedan visualizar sus dnis como debe ser
USE SGParquesNacionales
GO
CREATE OR ALTER VIEW Area_Infraestructura.Vista_Guardaparques_Seguros
AS
SELECT 
    IdGuardaparque,
    IdParque,
    -- Traducimos el binario encriptado a texto nuevamente. 
    -- Si la llave no está abierta en la sesión, esto devolverá NULL de forma segura.
    CONVERT(CHAR(8), DecryptByKey(Dni)) AS Dni_TextoClaro,
    Nombre,
    Apellido,
    Fecha_Ingreso,
    Fecha_Egreso,
    Activo
FROM 
    Area_Infraestructura.Guardaparque
GO;



--Esta vista busca permitir ver guardaparques pero sin que puedan visualizar sus dnis como debe ser

CREATE OR ALTER VIEW Area_Excursiones.Vista_Guias_Seguros
AS
SELECT 
    IdGuia,
    -- Traducimos el binario encriptado a texto nuevamente. 
    -- Si la llave no está abierta en la sesión, esto devolverá NULL de forma segura.
    CONVERT(CHAR(8), DecryptByKey(DNI)) AS Dni_TextoClaro,
    IdParque,
    Nombre,
    Apellido,
    IdEspecialidad,
    Titulo
FROM 
    Area_Excursiones.Guia;
GO
