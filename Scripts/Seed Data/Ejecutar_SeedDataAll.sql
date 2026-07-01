/*
Este script inserta la seed data requerida de manera segura (con chequeos de existencia):

Tablas auxiliares inicializadas.
10 Parques adicionales.
30 Actividades asignadas a parques aleatorios.
20 Guías con especialidades asignados a actividades de sus respectivos parques.
20 Guardaparques con fechas de ingreso aleatorias.
10 Concesiones asociadas a empresas concesionarias.
Configuración de precios aleatorios en Precio_Parque_Tipo_Visitante para todos los parques.
Historial de 50 ventas simuladas registradas a través de Sp_RegistrarVentaEntradas.
*/

USE SGParquesNacionales
EXEC Area_Infraestructura.Sp_GenerarSeedDataAll
