-- ======================================================
--          USO EXCLUSIVO PARA TESTING DE DESARROLLO
-- ======================================================

/*
# Universidad Nacional de la Matanza
# Materia: 3641 - Bases de Datos Aplicada 
# Fecha: 09/06/2026
# Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
# Descripción: En este sript se crea un esquema para testing
*/

-- Cambiar al contexto master
USE master;
GO

-- Forzar modo SINGLE_USER y cerrar todas las conexiones
ALTER DATABASE SGParquesNacionales
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Eliminar la base
DROP DATABASE SGParquesNacionales;
GO