/*
#Universidad Nacional de la Matanza
#Materia: 3641 - Bases de Datos Aplicada 
#Fecha: 19/06/2026
#Integrantes: Barreto Lautaro, Losada Agustina, Miranda Guillermo, Villar Facundo
#Descripción: Este script se encarga de la creación de todos los  Stored Procedure utilizado para
crear, modificar y eliminar las tablas del esquema Area_Negocios. 
*/

--Primero usar la BD
USE SGParquesNacionales
GO

-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LOS CANONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearCanon
    @IdEstado INTEGER,
    @IdConcesion INTEGER,
    @Monto_Mensual DECIMAL(13,3),
    @Fecha_Vencimiento DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el IdEstado en la tabla de Estados.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstado)
        BEGIN
            PRINT('No Existe el Estado de canon Ingresado')
            RAISERROR('EstadoCanon Invalido',16,1)
        END
        --Busca el IdConcesion en la tabla de Concesiones.
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la Concesión Ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END

        -- Valida el Monto ingresado
        IF @Monto_Mensual IS NULL OR  @Monto_Mensual <= 0 
        BEGIN
            PRINT('El Monto Ingresado no es valido, debe ser mayor a 0')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Vencimiento IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END

        IF @Fecha_Vencimiento < CAST(GETDATE() AS DATE)
        BEGIN
            RAISERROR('La fecha de vencimiento no puede ser anterior a la fecha actual.', 16, 1);
            RAISERROR('Fecha Invalida', 16, 1)
        END
            INSERT INTO Area_Negocios.Canon(IdEstado,IdConcesion,Monto_Mensual,Fecha_Vencimiento) VALUES (@IdEstado,@IdConcesion,@Monto_Mensual,@Fecha_Vencimiento)

    END TRY
    BEGIN CATCH
        -- Lanzamos return
            RAISERROR('Algo salio mal en la creación del Canon',16,1);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--                  CREACIÓN DE LAS CONCESIONES
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearConcesion
    @IdTipoActividadConcesion INTEGER,
    @IdEmpresa INTEGER,
    @IdParque INTEGER,
    @Fecha_Inicio DATE,
    @Fecha_Fin DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el Id del TipoActividad en la tabla de Tipo_Actividad_Concesion.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('No Existe el Tipo de actividad de concesion ingresada')
            RAISERROR('TipoActividad Invalida',16,1)
        END
        --Busca la empresa en la tabla de Empresa_Concesionaria.
        --No solo verificar si existe si no si está activa también
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1)
        BEGIN
            PRINT('No Existe la Empresa concesionaria o no esta activa actualmente')
            RAISERROR('EmpresaConcesionaria Invalida',16,1)
        END
        --Busca el parque en la tabla de Parques
        IF NOT EXISTS ( SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('No Existe el parque Ingresado')
            RAISERROR('Parque Invalido',16,1)
        END

        -- Valida la fecha de inicio ingresada, comprobando que no sea nula.
		IF @Fecha_Inicio IS NULL
		BEGIN
            PRINT('La fecha de Inicio no puede ser nula')
            RAISERROR('Fecha Inicio Inválida', 16, 1)
        END
        -- Valida la fecha de fin ingresada, comprobando que no sea nula.
		IF @Fecha_Fin IS NULL
		BEGIN
            PRINT('La fecha de Fin no puede ser nula')
            RAISERROR('Fecha Fin Inválida', 16, 1)
        END

        --Obviamente la fecha de Fin debe ser menor que la de inicio
        IF @Fecha_Fin <= @Fecha_Inicio
        BEGIN
            RAISERROR('La fecha de finalización debe ser estrictamente posterior a la fecha de inicio.', 16, 1);
        END

        INSERT INTO Area_Negocios.Concesion(IdTipoActividadConcesion,IdEmpresa,IdParque,Fecha_Inicio,Fecha_Fin) VALUES (@IdTipoActividadConcesion,@IdEmpresa,@IdParque,@Fecha_Inicio,@Fecha_Fin)

    END TRY
    BEGIN CATCH
        -- Lanzamos return	
            RAISERROR('Algo salio mal en la creación de la Concesión',16,1);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LAS EMPRESAS CONCESIONARIAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearEmpresaConcesionaria
	@Nombre varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos nombre ingresado.
        IF  @Nombre IS NULL OR @Nombre ='' OR NOT @Nombre NOT LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Nombre) > 80 
        BEGIN
            PRINT('El nombre de la empresa ingresado no es valido')
            RAISERROR('Nombre Invalido', 16,1)
        END
        -- Se busca que el nombre no sea repetido
        DECLARE @IdNombreEmpresaRepe INT;
        SELECT @IdNombreEmpresaRepe = IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = @Nombre;
        IF @IdNombreEmpresaRepe IS NOT NULL
        BEGIN
            PRINT('Ya existe una empresa con ese nombre')
            RAISERROR('Nombre Invalido',16,1)
        END
        INSERT INTO Area_Negocios.Empresa_Concesionaria(Nombre, Estado) VALUES (@Nombre, 1)
    END TRY
    BEGIN CATCH
        -- Lanzamos Rollback
            RAISERROR('Algo salio mal en el registro del nombre de la empresa',16,1);
            RETURN;
    END CATCH
    
END
GO
-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LOS ESTADOS DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearEstadoCanon
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos descripcion ingresada.
        IF @Descripcion IS NULL OR @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%'  OR LEN(@Descripcion) > 100
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('Descripcion Invalida', 16,1)
        END

        INSERT INTO Area_Negocios.Estado_Canon(Descripcion) VALUES (@Descripcion)  
    END TRY
    BEGIN CATCH
        -- Lanzamos Return
            RAISERROR('Algo salio mal en la creación del estado del canon',16,1);
            RETURN;
    END CATCH
     
END
GO

-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LOS PAGOS DE CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearPagoCanon
	@IdCanon INTEGER,
    @Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
	BEGIN TRY
        -- Busca el IdCanon en la tabla de Canon.
        --Verifica que existe
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('No Existe el Canon Ingresado')
            RAISERROR('Canon Invalido',16,1)
        END
        -- Valida el Monto ingresado
        IF  @Monto_Abonado IS NULL OR  @Monto_Abonado <= 0 
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Pago IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
        INSERT INTO Area_Negocios.Pago_Canon(IdCanon,Monto_Abonado,Fecha_Pago) VALUES (@IdCanon,@Monto_Abonado,@Fecha_Pago)
    END TRY
    BEGIN CATCH
        -- Lanzamos return	
            RAISERROR('Algo salio mal en la creación del pago del canon',16,1);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              CREACIÓN DE LOS TIPOS DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_CrearTipoActividadConcesion
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
        -- Validamos descripcion ingresada.
        IF @Descripcion IS NULL OR @Descripcion ='' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Descripcion)>100 
        BEGIN
            PRINT('La descripcion ingresada no es valida')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        -- Validamos que la descripcion no se encuentra ya registrada
        IF EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = @Descripcion)
        BEGIN
            PRINT('La descripcion ingresada ya se encuentra registrada')
            RAISERROR('Descripcion Invalida', 16,1)
        END
        INSERT INTO Area_Negocios.Tipo_Actividad_Concesion(Descripcion) VALUES (@Descripcion)
    END TRY
    BEGIN CATCH
        -- Lanzamos RETURN
            RAISERROR('Algo salio mal en la creación del Tipo de actividad de Concesion',16,1);
            RETURN;
    END CATCH
    
END
GO

-- //////////////////////////////////////////////////////////////
--              Apartado 2: SPs de Modificación
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE LOS CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarCanon
	@IdCanon Integer,
	@IdEstadoCanon INT,
    @IdConcesion INTEGER,
    @Monto_Mensual DECIMAL(13,3),
    @Fecha_Vencimiento DATE
AS
BEGIN
	BEGIN TRY
		--Busca el Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('Canon inexistente')
            RAISERROR('Canon Inexistente', 16, 1)
        END
		--Busca el Estado Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon)
        BEGIN
            PRINT('Estado de Canon inexistente')
            RAISERROR('Estado de Canon Inexistente', 16, 1)
        END

		--Busca la Concesión verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('Concesión inexistente')
            RAISERROR('Concesión Inexistente', 16, 1)
        END
		 -- Valida el Monto ingresado
        IF NOT @Monto_Mensual > 0 OR @Monto_Mensual IS NULL 
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Vencimiento IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
		IF @Fecha_Vencimiento < CAST(GETDATE() AS DATE)
		BEGIN
			PRINT('La fecha no puede ser anterior al dia actual')
			RAISERROR('La fecha de vencimiento no puede ser anterior a la fecha actual.', 16, 1);
		END
		UPDATE Area_Negocios.Canon 
		SET  IdEstado = @IdEstadoCanon,
		IdConcesion = @IdConcesion,
		Monto_Mensual = @Monto_Mensual,
		Fecha_Vencimiento = @Fecha_Vencimiento
		WHERE IdCanon = @IdCanon 
	END TRY
	BEGIN CATCH
        -- Lanzar return
			RAISERROR('Algo salio mal en la modificación del Canon', 16, 1);
			RETURN;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE LAS CONCESIONES
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarConcesion
    @IdConcesion INTEGER,
    @IdTipoActividadConcesion INTEGER,
    @IdEmpresa INTEGER,
    @IdParque INTEGER,
    @Fecha_Inicio DATE,
    @Fecha_Fin DATE
AS
BEGIN
	BEGIN TRY

        -- Se verifica que la concesión exista
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la concesión ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END
        -- Busca el Id del TipoActividad en la tabla de Tipo_Actividad_Concesion.
       IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('No Existe el Tipo de actividad ingresada')
            RAISERROR('TipoActividad Invalida',16,1)
        END
        --Busca la empresa en la tabla de Empresa_Concesionaria.
        --No solo verificar si existe si no si está activa también
        IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1)
        BEGIN
            PRINT('No Existe la Empresa concesionaria o no esta activa actualmente')
            RAISERROR('EmpresaConcesionaria Invalida',16,1)
        END
        --Busca el parque en la tabla de Parques
        IF NOT EXISTS ( SELECT 1 FROM Area_Infraestructura.Parque WHERE IdParque = @IdParque)
        BEGIN
            PRINT('No Existe el parque Ingresado')
            RAISERROR('Parque Invalido',16,1)
        END

        -- Valida la fecha de inicio ingresada, comprobando que no sea nula.
		IF @Fecha_Inicio IS NULL
		BEGIN
            PRINT('La fecha de Inicio no puede ser nula')
            RAISERROR('Fecha Inicio Inválida', 16, 1)
        END
        -- Valida la fecha de fin ingresada, comprobando que no sea nula.
		IF @Fecha_Fin IS NULL
		BEGIN
            PRINT('La fecha de Fin no puede ser nula')
            RAISERROR('Fecha Fin Inválida', 16, 1)
        END

        UPDATE Area_Negocios.Concesion
        SET IdTipoActividadConcesion=@IdTipoActividadConcesion,
        IdEmpresa=@IdEmpresa,
        IdParque=@IdParque,
        Fecha_Inicio=@Fecha_Inicio,
        Fecha_Fin=@Fecha_Fin
        WHERE IdConcesion=@IdConcesion

    END TRY
    BEGIN CATCH
        -- Lanzamos return
            RAISERROR('Algo salio mal en la modificación de la Concesión',16,1);
            Return;
    END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE LAS EMPRESAS
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarEmpresaConcesionaria
	@IdEmpresaConcesionaria INT,
	@Nombre varchar(150),
	@Estado bit
AS
BEGIN
	BEGIN TRY

		--Busca la Empresa Concesionaria en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresaConcesionaria)
        BEGIN
            PRINT('Empresa Concesionaria inexistente')
            RAISERROR('Empresa Inexistente', 16, 1)
        END

		-- El nuevo nombre debe ser valido
		IF @Nombre IS NULL OR @Nombre='' OR @Nombre LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Nombre) > 80
		BEGIN
			PRINT('El Nuevo nombre de la empresa no es valido.');
			RAISERROR('EmpresaConcesionaria Invalida', 16, 1);
		END
		-- La modificacion de Nombre no puede estar repetida.
		IF EXISTS (SELECT 1 FROM Area_Negocios.Empresa_Concesionaria WHERE Nombre = @Nombre AND IdEmpresa <> @IdEmpresaConcesionaria)
        BEGIN
			-- Lanzar el error
			PRINT('La empresa ya se encuentra registrada.');
			RAISERROR('EmpresaConcesionaria Invalida', 16, 1);
		END
		-- El estado no puede ser vacio
		IF @Estado IS NULL
		BEGIN
			PRINT('No puede colocar un estado vacío')
			RAISERROR('Estado Invalido', 16, 1);
		END
			UPDATE Area_Negocios.Empresa_Concesionaria
			SET Nombre = @Nombre, Estado = @Estado
			WHERE IdEmpresa = @IdEmpresaConcesionaria; 

	END TRY
	BEGIN CATCH
			RAISERROR('Algo salio mal en la modificación de la Empresa', 16, 1);
			RETURN;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DEL ESTADO DEL CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarEstadoCanon
	@IdEstadoCanon INT,
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
		--Busca el Estado Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon)
        BEGIN
            PRINT('Estado Canon inexistente')
            RAISERROR('Estado Canon Inexistente', 16, 1)
        END

		-- La nueva descripcion debe ser valida
		-- 2. Validar formato de la descripción
        IF @Descripcion IS NULL OR @Descripcion = '' OR LEN(@Descripcion) > 100
        BEGIN
            RAISERROR('La nueva descripción no es válida o excede el límite de caracteres.', 16, 1);
        END

        IF @Descripcion LIKE '%[^a-zA-ZñÑ. ]%'
        BEGIN
			PRINT('La nueva descripción no es valida.');
            RAISERROR('La descripción contiene caracteres no permitidos (solo letras y espacios).', 16, 1);
        END

        -- 3. Validar duplicados EXCLUYENDO el registro actual
        IF EXISTS (SELECT 1 FROM Area_Negocios.Estado_Canon WHERE Descripcion = @Descripcion AND IdEstadoCanon <> @IdEstadoCanon)
        BEGIN
			PRINT('La nueva descripción se encuentra repetida y ya existe.');
            RAISERROR('Ya existe otro Estado de Canon con esa misma descripción.', 16, 1);
        END
		UPDATE Area_Negocios.Estado_Canon
        SET Descripcion = @Descripcion
        WHERE IdEstadoCanon = @IdEstadoCanon;
	END TRY
	BEGIN CATCH
        -- Lanzar Rollback
			RAISERROR('Algo salio mal en la modificación del Estado del Canon', 16, 1);
			RETURN;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DEL PAGO DEL CANON
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarPagoCanon
	@IdPagoCanon INT,
	@IdCanon INT,
	@Monto_Abonado DECIMAL(13,3),
    @Fecha_Pago DATE
AS
BEGIN
	BEGIN TRY
		--Busca el Pago Canon verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon)
        BEGIN
            PRINT('Pago de Canon inexistente')
            RAISERROR('PagoCanon Inexistente', 16, 1)
        END
		-- Busca el IdCanon en la tabla de Canon.
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('No Existe el Canon Ingresado')
            RAISERROR('Canon Invalido',16,1)
        END
		-- Valida el Monto ingresado
        IF NOT @Monto_Abonado > 0 OR @Monto_Abonado IS NULL
        BEGIN
            PRINT('El Monto Ingresado no es valido')
            RAISERROR('Monto Invalido',16,1)
        END
        -- Valida la fecha ingresada, comprobando que no sea nula.
		IF @Fecha_Pago IS NULL
		BEGIN
            PRINT('La fecha no puede ser nula')
            RAISERROR('Fecha Invalida', 16, 1)
        END
		--Se completa la operación
	UPDATE Area_Negocios.Pago_Canon SET Monto_Abonado = @Monto_Abonado,
			IdCanon = @IdCanon,
			Fecha_Pago = @Fecha_Pago
			WHERE IdPagoCanon = @IdPagoCanon;
	END TRY
	BEGIN CATCH
        -- Lanzar RETURN
			RAISERROR('Algo salio mal en la modificación del Pago del Canon', 16, 1);
			RETURN;
	END CATCH
	

END
GO

-- //////////////////////////////////////////////////////////////
--              MODIFICACIÓN DE TIPO DE ACTIVIDAD
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_ModificarTipoActividadConcesion
	@IdTipoActividadConcesion INT,
	@Descripcion varchar(150)
AS
BEGIN
	BEGIN TRY
		--Busca el id verificando que existe en la base de datos
		IF NOT EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('Tipo de Actividad inexistente')
            RAISERROR('TipoActividadConcesion Inexistente', 16, 1)
        END

		-- La nueva descripcion debe ser valida
		IF @Descripcion IS  NULL OR @Descripcion = '' OR @Descripcion LIKE '%[^a-zA-ZñÑ. ]%' OR LEN(@Descripcion) > 100
		BEGIN
			PRINT('La nueva descripción no es válida.');
			RAISERROR('Descripcion Invalida', 16, 1);
		END

		--La nueva Descripcion no puede ser una repetida
		IF EXISTS (SELECT 1 FROM Area_Negocios.Tipo_Actividad_Concesion WHERE Descripcion = @Descripcion AND IdTipoActividadConcesion <> @IdTipoActividadConcesion)
		BEGIN
			-- Lanzar el error
			PRINT('La nueva descripción ya se encuentra registrada.');
			RAISERROR('Descripcion Invalida', 16, 1);
		END
		UPDATE Area_Negocios.Tipo_Actividad_Concesion
			SET Descripcion = @Descripcion
			WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
	END TRY
	BEGIN CATCH
        -- Lanzar return
			RAISERROR('Algo salio mal en la modificación del Tipo De Actividad de la concesion', 16, 1);
			Return;
	END CATCH
END
GO
-- //////////////////////////////////////////////////////////////
--              Apartado 3: Sps de Eliminación
-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarCanon
    @IdCanon INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que la id canon ingresado exista en la Base de Datos
        DECLARE @IdCanonExiste INT;
        SELECT @IdCanonExiste = IdCanon FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon;
        IF @IdCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Canon con ese Identificador')
            RAISERROR('Canon Inexistente',16,1)
        END
        IF EXISTS (SELECT 1 FROM Area_Negocios.Pago_Canon WHERE IdCanon = @IdCanon)
        BEGIN
            PRINT('El canon ingresado tiene pagos asociados')
            RAISERROR('No se puede eliminar el Canon porque posee registros de pagos asociados.', 16, 1);
        END
         DELETE FROM Area_Negocios.Canon WHERE IdCanon = @IdCanon;
    END TRY
    BEGIN CATCH	
            RAISERROR('Algo salio mal en la eliminación del Canon',16,1);
            RETURN;
    END CATCH
   
END
GO
-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE CONCESION
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarConcesion
    @IdConcesion INTEGER
AS
BEGIN
	BEGIN TRY

        -- Se verifica que la concesión exista
        IF NOT EXISTS ( SELECT 1 FROM Area_Negocios.Concesion WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('No Existe la concesión ingresada')
            RAISERROR('Concesión Invalida',16,1)
        END
        --Viendo que no hayan canones para esa concesión
        IF EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdConcesion = @IdConcesion)
        BEGIN
            PRINT('La concesión ingresada tiene canones asociados')
            RAISERROR('No se puede eliminar la Concesión porque tiene históricos de cánones vinculados.', 16, 1);
        END

        DELETE FROM Area_Negocios.Concesion WHERE IdConcesion=@IdConcesion
    END TRY
    BEGIN CATCH
        -- Lanzamos return
            RAISERROR('Algo salio mal en la eliminación de la Concesión',16,1);
            Return;
    END CATCH
END
GO

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE EMPRESA
-- //////////////////////////////////////////////////////////////
CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarEmpresaConcesionaria
    @IdEmpresa INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        --Validamos que la empresa si este actualmente activa
        DECLARE @IdEmpresaExiste INT;
        SELECT @IdEmpresaExiste = IdEmpresa FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa AND Estado = 1;
        IF @IdEmpresaExiste IS NULL
        BEGIN
            PRINT('No existe una Empresa Concesionaria activa con ese Id')
            RAISERROR('Empresa Inexistente',16,1)
        END
        
        UPDATE Area_Negocios.Empresa_Concesionaria SET Estado = 0 WHERE IdEmpresa = @IdEmpresa
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminacion de la empresa concesionaria',16,1);
            RETURN;
    END CATCH
    --DELETE FROM Area_Negocios.Empresa_Concesionaria WHERE IdEmpresa = @IdEmpresa;
    
END
GO

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE ESTADO DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarEstadoCanon
    @IdEstadoCanon INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdEstadoCanonExiste INT;
        SELECT @IdEstadoCanonExiste = IdEstadoCanon FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon;
        IF @IdEstadoCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Estado de Canon con ese Id')
            RAISERROR('EstadoCanon Inexistente',16,1)
        END
        --No puede tener Canones asociados
        IF EXISTS (SELECT 1 FROM Area_Negocios.Canon WHERE IdEstado = @IdEstadoCanon)
        BEGIN
            PRINT('No existe un Estado de Canon con ese Id')
            RAISERROR('No se puede eliminar el Estado de Canon porque está siendo utilizado por registros de la tabla Canon.', 16, 1);
        END

        DELETE FROM Area_Negocios.Estado_Canon WHERE IdEstadoCanon = @IdEstadoCanon;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminacion del Estado de Canon',16,1);
            RETURN;
    END CATCH
    
END
GO

-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE PAGO DE CANON
-- //////////////////////////////////////////////////////////////

CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarPagoCanon
    @IdPagoCanon INT
AS
BEGIN
    BEGIN TRY

        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdPagoCanonExiste INT;
        SELECT @IdPagoCanonExiste = IdPagoCanon FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon;
        IF @IdPagoCanonExiste IS NULL
        BEGIN
            PRINT('No existe un Pago de Canon con ese Id')
            RAISERROR('PagoCanon Inexistente',16,1)
        END
         DELETE FROM Area_Negocios.Pago_Canon WHERE IdPagoCanon = @IdPagoCanon;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminación del Pago de Canon',16,1);
            RETURN;
    END CATCH
   
END
GO
-- //////////////////////////////////////////////////////////////
--              ELIMINACIÓN DE TIPO DE ACTIVIDAD 
-- //////////////////////////////////////////////////////////////


CREATE OR ALTER PROCEDURE Area_Negocios.SP_EliminarTipoActividadConcesion
    @IdTipoActividadConcesion INT
AS
BEGIN
    BEGIN TRY
        -- Validamos que la id ingresado exista en la Base de Datos
        DECLARE @IdTipoActividadConcesionExiste INT;
        SELECT @IdTipoActividadConcesionExiste = IdTipoActividadConcesion FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
        IF @IdTipoActividadConcesionExiste IS NULL
        BEGIN
            PRINT('No existe un Tipo de Actividad con ese Id')
            RAISERROR('TipoActividadConcesion Inexistente',16,1)
        END
        --Reviso que la la actividad no se asocie a concesiones
        IF EXISTS (SELECT 1 FROM Area_Negocios.Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion)
        BEGIN
            PRINT('No se puede eliminar poque existen concesiones asignadas a esta actividad.')
            RAISERROR('No se puede eliminar el Tipo de Actividad debido a que existen concesiones vigentes que dependen de él.', 16, 1);
        END
        DELETE FROM Area_Negocios.Tipo_Actividad_Concesion WHERE IdTipoActividadConcesion = @IdTipoActividadConcesion;
    END TRY
    BEGIN CATCH
            RAISERROR('Algo salio mal en la eliminación del Tipo de Actividad Concesion',16,1);
            RETURN;
    END CATCH
    
END
GO