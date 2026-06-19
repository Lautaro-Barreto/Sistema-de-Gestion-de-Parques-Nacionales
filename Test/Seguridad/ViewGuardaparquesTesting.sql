/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de probar una vista para restringir visualizar datos sensibles
en este caso el dni de los guardaparques

*/
USE SGParquesNacionales
GO
--Preparación del entorno de testing
-- Nulo

--Caso exitoso: El DNI aparece encriptado porque la llave no está abierta.
SELECT * FROM Area_Infraestructura.Vista_Guardaparques_Seguros
--Resultado: Se reemplaza como datos nulos para el usuario

--Ahora abramos la llave
OPEN SYMMETRIC KEY SymKey_DNI_SGPN DECRYPTION BY CERTIFICATE Certificado_DNI_SGPN;

-- Ahora sí, la vista puede hacer la traducción mágica
SELECT * FROM Area_Infraestructura.Vista_Guardaparques_Seguros;
--Resultado: El dni se visualiza exitosamente.


-- Cerramos la caja fuerte, para ocultar de nuevo los dnis.
CLOSE SYMMETRIC KEY SymKey_DNI_SGPN;
GO
