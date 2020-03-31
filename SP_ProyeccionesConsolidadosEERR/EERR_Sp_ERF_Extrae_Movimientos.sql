-- ==========================================================================================
-- Author:		Francisco Bahamondes
-- Create date: 2020-03-03
-- Description:	Extrae movimientos de un consolidado para ser utilizados en reportes
-- ==========================================================================================
IF OBJECT_ID ( 'EERR_Sp_ERF_Extrae_Movimientos', 'P' ) IS NOT NULL 
    DROP PROCEDURE  EERR_Sp_ERF_Extrae_Movimientos;
GO

CREATE PROCEDURE EERR_Sp_ERF_Extrae_Movimientos
	@sToken AS VARCHAR(24),
	@iIdConsolidado AS INT,
	@sPeriodo AS VARCHAR(6),
	@sLibros AS VARCHAR(100),
	@sDeep as varchar(30)
AS
--
-- VARIABLES DE LOG
Declare @iRetVal as int;
Declare @sName AS Varchar(100);
Declare @sTexto as nVarchar(500);
--
-- VARIABLES
DECLARE @sRESAToken AS VARCHAR(24);
Declare @sDescripcionConsolidado as varchar(100);
Declare @sCodigoConsolidado as varchar(18);
--
-- CURSORES
Declare @SaldosCursor as Cursor;
Declare @curAnidados as Cursor;
--
Declare @TmpidConsolidado int;
Declare @TmpDescripcionConsolidado varchar(500)
Declare @TmpidCompania varchar(18)
Declare @TmpDescripcionCompania varchar(500)
Declare @TmpidGrupo varchar(4)
Declare @TmpDescripcionGrupo varchar(500)
Declare @TmpidConcepto varchar(10)
Declare @TmpDescripcionConcepto varchar(500)
Declare @TmpidCuenta varchar(8)
Declare @TmpDescripcionCuenta varchar(500)
Declare @TmpidPeriodo varchar(6)
Declare @TmpValor numeric(25)
Declare @TmpFlagImprime int
Declare @TmpTipo varchar(2)
--
Declare @iIdAnidado as int;
Declare @sCodigoAnidado as varchar(18);
Declare @sDescripcionAnidado as Varchar(100);
Declare @iIdAnidadoOrg as int;
--
BEGIN
	SET NOCOUNT ON;
	--
	Set @sName = 'EERR_Sp_ERF_Extrae_Movimientos';
	--
	Set @sTexto = @sDeep + ' Parametros Entrada';
	Set @sTexto = @sTexto + ' idConsolidado {' + Convert(varchar, @iIdConsolidado) + '}' ;
	Set @sTexto = @sTexto + ' Periodo {' + @sPeriodo + '}' ;
	Set @sTexto = @sTexto + ' Libros {' + @sLibros + '}' ;
	Execute EERR_sp_Log4Sql_Info @sName, @sTexto;
	BEGIN TRY
		SET @sTexto = 'Inicio Proceso de extraccion de movimientos ERF';
		EXECUTE EERR_sp_Log4Sql_Debug @sName,@sTexto;
		--
		Select @sDescripcionConsolidado = Descripcion, @sCodigoConsolidado = Codigo From EERR_Tbl_Consolidados   Where IdRegistro = @iIdConsolidado;
		-- Inicio Extraccion de Ajuste
		Set @sTexto = @sDeep + '____ Inicio Extraccion de Ajustes';
		Execute EERR_sp_Log4Sql_Debug @sName, @sTexto;
		Execute EERR_Sp_Ajustes_Automaticos @iIdConsolidado, @sPeriodo, @sLibros;
		--
		-- Insercion de Ajustes
		Set @sTexto = @sDeep + '______ Insercion de Ajustes ';
		Execute EERR_sp_Log4Sql_Debug @sName, @sTexto;
		INSERT INTO EERR_Tmp_Token_ERF
			Select @sToken
				, C.IdRegistro
				, C.Codigo +'-'+ C.Descripcion
				, Case when AJ.PeriodoAfectado = AJ.PeriodoVista
					Then '0' 
					Else '-1'
					End Compania
				, Case when AJ.PeriodoAfectado = AJ.PeriodoVista
					Then 'Ajustes de Consolidación'
					Else 'Reclasificaciones'
					End Compania					
				, MG.Tipo +  CG.IdGrupo
				, MG.Descripcion MGDescripcion
				, Right( '00' + convert(varchar,MCO.Orden), 2) + CG.IdConcepto
				, MCO.Descripcion MCODescripcion
				, CG.IdCuenta
				, rtrim(CG.IdCuenta) + '-' +MCU.Descripcion MCUDescripcion
				, @sPeriodo
				, Case When  CG.IdCuenta = 'ERF_NC' then (AJ.Debito - AJ.Credito)
					Else (AJ.Credito - AJ.Debito) 
					End Valor
				, MCU.FlagImprime
				, 'AJ'
			From EERR_Tbl_Consolidados C
				, EERR_Tbl_Ajustes AJ
				, EERR_TbT_Consolidado_Grupo_Concepto_Cuenta CG
				, EERR_Tbl_Maestro_Grupos MG
				, EERR_Tbl_Maestro_Conceptos MCO
				, EERR_Tbl_Maestro_Cuentas MCU
			Where 1=1
				And C.IdRegistro = @iIdConsolidado
				And AJ.IdConsolidado = C.IdRegistro
				And AJ.PeriodoAfectado = @sPeriodo
				And MCU.Tipo in ( '3I', '3E' )
				And CG.IdCuenta = AJ.IdCuenta
				And CG.IdConsolidado = C.IdRegistro
				And CG.IdGrupo = MG.Codigo
				And CG.IdConcepto = MCO.Codigo
				And CG.IdCuenta = MCU.IdCuenta

		-- Saldos de consolidado incial
		EXEC @iRetVal = EERR_Sp_ERF_ExtraeSaldos @iIdConsolidado, @sPeriodo, @sLibros, @sDeep, @CursorSaldos = @SaldosCursor OUTPUT;
		If @iRetVal = 1 
			Begin
				Set @sTexto = @sDeep + '____ Devolvio Error';
				Execute EERR_sp_Log4Sql_Debug @sName, @sTexto;
				Return @iRetVal;
			End;
		FETCH NEXT FROM @SaldosCursor into 
				@TmpidConsolidado, @TmpDescripcionConsolidado, @TmpidCompania, @TmpDescripcionCompania, @TmpidGrupo, @TmpDescripcionGrupo, 
				@TmpidConcepto, @TmpDescripcionConcepto, @TmpidCuenta, @TmpDescripcionCuenta, @TmpidPeriodo, @TmpValor, @TmpFlagImprime, @TmpTipo
		WHILE (@@FETCH_STATUS = 0)  
			BEGIN;
				Insert Into EERR_Tmp_Token_ERF
						Values 
							(@sToken, @TmpidConsolidado , @TmpDescripcionConsolidado, @TmpidCompania, @TmpDescripcionCompania, @TmpidGrupo, @TmpDescripcionGrupo
							, @TmpidConcepto, @TmpDescripcionConcepto, @TmpidCuenta, @TmpDescripcionCuenta, @TmpidPeriodo, @TmpValor, @TmpFlagImprime, @TmpTipo)
					--
					FETCH NEXT FROM @SaldosCursor into 
								@TmpidConsolidado, @TmpDescripcionConsolidado, @TmpidCompania, @TmpDescripcionCompania, @TmpidGrupo, @TmpDescripcionGrupo
								, @TmpidConcepto, @TmpDescripcionConcepto, @TmpidCuenta, @TmpDescripcionCuenta, @TmpidPeriodo, @TmpValor, @TmpFlagImprime, @TmpTipo
			END;
		CLOSE @SaldosCursor; 
		Deallocate @SaldosCursor;
		-- Creacion de un token para las transacciones
		Set @curAnidados = CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR 
			Select CodigoReferenciado, Codigo, Descripcion, idRegistro From EERR_Tbl_Consolidados  
				Where idPadre = @iIdConsolidado And TipoNodo = 1;
		Open @curAnidados;
		Fetch Next From @curAnidados Into @iIdAnidado, @sCodigoAnidado, @sDescripcionAnidado, @iIdAnidadoOrg
		While @@FETCH_STATUS = 0
			Begin
				-- GENERAMOS UN NUEVO TOKEN PARA LAS TRANSACCIONES
				Set @sRESAToken = convert(varchar(24), ROUND(CAST(CAST(GETUTCDATE() AS FLOAT)*8.64e8 AS BIGINT),-1)*1000+599266080000000000);
				Set @sTexto = @sDeep + '_____ RESAToken creado {' + @sRESAToken +'}';
				Execute EERR_sp_Log4Sql_Debug @sName, @sTexto;
				-- Prechequeo de id a enviar
				set @iIdAnidado = Case when @iIdAnidado = 0 then @iIdAnidadoOrg Else @iIdAnidado End;
				-- Llamado al recursivo
				Execute @iRetVal = EERR_Sp_ERF_Recursivo_ExtraeSaldosyAjustes @sRESAToken, @iIdAnidado, @sPeriodo, @sLibros, @sDeep;
				If @iRetVal = 1 
					Begin
						Set @sTexto =  @sDeep + '____ Devolvio Error';
						Execute EERR_sp_Log4Sql_Debug @sName, @sTexto;
						Return @iRetVal;
					End;
				-- Insertamos todas los Saldos que extrajo del consolidado
				Set @sTexto =  @sDeep + '_____ Insertamos los saldos que extrajo';
				Execute EERR_sp_Log4Sql_Debug @sName, @sTexto;
				Insert Into EERR_Tmp_Token_ERF
					Select  
						@sToken, @iIdConsolidado, @sCodigoConsolidado + '-' + @sDescripcionConsolidado, @sCodigoAnidado, @sCodigoAnidado +'-' + @sDescripcionAnidado, 
						idGrupo, DescripcionGrupo, idConcepto, DescripcionConcepto, idCuenta, DescripcionCuenta, idPeriodo, Valor, FlagImprime, Tipo
					From EERR_Tmp_Token_ERF   Where Token = @sRESAToken;
				-- Insertamos los Ajustes del consolidado
				Set @sTexto =  @sDeep + '_____ Insertamos los Ajustes que extrajo';
				Execute EERR_sp_Log4Sql_Debug @sName, @sTexto;
				Insert into EERR_Tmp_Token_ERF
					Select @sToken
						,@iIdConsolidado
						, @sCodigoConsolidado + '-' + @sDescripcionConsolidado
						, @sCodigoAnidado
						, @sCodigoAnidado +'-' + @sDescripcionAnidado
						, MG.Tipo +  CG.IdGrupo
						, MG.Descripcion MGDescripcion
						, Right( '00' + convert(varchar,MCO.Orden), 2) + CG.IdConcepto
						, MCO.Descripcion MCODescripcion
						, CG.IdCuenta
						, rtrim(CG.IdCuenta) + '-' +MCU.Descripcion MCUDescripcion
						, @sPeriodo
						, Case When  CG.IdCuenta = 'ERF_NC' then (AJ.Debito - AJ.Credito)
							Else (AJ.Credito - AJ.Debito) 
							End Valor
						, MCU.FlagImprime
						, 'AA'
					From EERR_Tbl_Consolidados C
						, EERR_Tbl_Ajustes AJ
						, EERR_TbT_Consolidado_Grupo_Concepto_Cuenta CG
						, EERR_Tbl_Maestro_Grupos MG
						, EERR_Tbl_Maestro_Conceptos MCO
						, EERR_Tbl_Maestro_Cuentas MCU
					Where 1=1
						--
						And C.IdRegistro = @iIdAnidado
						AND AJ.IdConsolidado = C.IdRegistro
						AND AJ.PeriodoAfectado = @sPeriodo
						AND AJ.PeriodoVista = @sPeriodo
						AND MCU.Tipo in ( '3I', '3E' )
						And CG.IdCuenta = AJ.IdCuenta
						--
						And CG.IdConsolidado = C.IdRegistro
						And CG.IdGrupo = MG.Codigo
						And CG.IdConcepto = MCO.Codigo
						And CG.IdCuenta = MCU.IdCuenta
					DELETE FROM EERR_Tmp_Token_ERF WHERE Token = @sRESAToken;
				--
				Fetch Next From @curAnidados Into @iIdAnidado, @sCodigoAnidado, @sDescripcionAnidado, @iIdAnidadoOrg
			End;
		Close @curAnidados; 
		Deallocate @curAnidados;
		Return (0);
	End Try
	Begin Catch
		Declare @sErr as Varchar(2000);
		set @sErr = 'Num : {' + Convert(varchar, ERROR_LINE()) + '} Mensaje : {' + ERROR_MESSAGE() + '}';
		Execute EERR_sp_Log4sql_ERROR @sName, @sErr;
		print @sErr;
		Return (1);
	End Catch;
END;