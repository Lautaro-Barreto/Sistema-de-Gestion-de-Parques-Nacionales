/*
ESTADOS DE UN CANON:
- Adeudado: Cuando la fecha de vencimiento es menor a la fecha actual y el estado no es "Saldado en Término", "Saldado con Atraso" o "Exento".
- Vigente: Cuando la fecha de vencimiento es mayor o igual a la fecha actual y el estado no es "Saldado en Término", "Saldado con Atraso" o "Exento".
- Saldado en Término: Cuando se registra un pago antes o en la fecha de vencimiento.
- Saldado con Atraso: Cuando se registra un pago después de la fecha de vencimiento.
- Exento: Cuando el canon no requiere pago.
- Extinguido: Cuando el canon ha sido cancelado o eliminado.
Este trigger se encarga de actualizar el estado de los cánones automáticamente después de cada inserción

select * from area_negocios.estado_canon;
*/

CREATE OR ALTER TRIGGER Area_Negocios.Tg_ActualizarEstadosCanones
ON Area_Negocios.Canon
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Area_Negocios.Canon
    SET IdEstado = CASE
        WHEN Fecha_Vencimiento < GETDATE() AND IdEstado NOT IN (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion IN ('Saldado en Término', 'Saldado con Atraso', 'Exento', 'Extinguido')) THEN
            (SELECT IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE Descripcion = 'Adeudado')
        ELSE
            IdEstado
    END
END