-- =============================================
-- Author:		Francisco Bahamondes
-- Create date: 2020-03-03
-- Description:	Genera datos para reporte de 
--              Resumen Financiero 10 Años
--				(Lustro pasado y proyecciones).
-- =============================================
IF OBJECT_ID ( 'EERR_Sp_Reporte_RFXA_Genera', 'P' ) IS NOT NULL 
    DROP PROCEDURE  EERR_Sp_Reporte_RFXA_Genera;
GO

CREATE PROCEDURE EERR_Sp_Reporte_RFXA_Genera
	@sConsolidadosPeriodos VARCHAR(255)
	,@sLibros as Varchar(100)
AS
-- VARIABLES DE LOG
Declare @iRetVal as int;
Declare @sName AS Varchar(100);
Declare @sTexto as nVarchar(500);
-- VARIABLES
DECLARE @sToken as Varchar(24);
-- TABLAS TEMPORALES
DECLARE @TablaConsolidadosPeriodos AS TABLE ( IdConsolidado INT, Periodo VARCHAR(6));
Declare @TablaTemporal Table ( 
								idConsolidado int
								, DescripcionConsolidado varchar(500)
								, idCompania varchar(18)
								, DescripcionCompania varchar(500)
								, idGrupo varchar(4)					-- Este codigo incluye el tipo para uso de orden
								, DescripcionGrupo varchar(500)
								, idConcepto varchar(10)				-- Este codigo incluye el el campo de orden
								, DescripcionConcepto varchar(500)
								, idCuenta varchar(8)
								, DescripcionCuenta varchar(500)
								, idPeriodo varchar(6)
								, Valor numeric(25)
								, FlagImprime int
								, Tipo varchar(2)
							 );
DECLARE @TablaTemporalReporte AS TABLE (
								IdConcepto INT
								,idCompania varchar(18)
								,NombreEmpresa varchar(500)
								,Periodo varchar(6)
								,Monto numeric(25)
								);
--CURSORES
DECLARE @CursorConsolidadosPeriodos AS CURSOR;
--
DECLARE @iIdConsolidado INT;
DECLARE @sPeriodo VARCHAR(6);
BEGIN
	SET NOCOUNT ON;
	--
	Set @sName = 'EERR_Sp_Reporte_ERF_Genera';
	--
	Set @sTexto = '__ Parametros Entrada';
	Set @sTexto = @sTexto + ' ConsolidadosPeriodos {' + Convert(varchar, @sConsolidadosPeriodos) + '}' ;
	Set @sTexto = @sTexto + ' Libros {' + @sLibros + '}' ;
	Execute EERR_sp_Log4Sql_Info @sName, @sTexto;
	BEGIN TRY;
		-- SEPARAMOS LOS CONSOLIDADOS Y PERIODOS EN UNA TABLA
		WITH Separa(pn, start, stop) AS (
			SELECT 1, 1, CASE WHEN CHARINDEX(',', @sConsolidadosPeriodos)>0 THEN CHARINDEX(',', @sConsolidadosPeriodos) ELSE LEN(@sConsolidadosPeriodos)+1 END
			UNION ALL
			SELECT pn + 1, stop + 1, CASE WHEN CHARINDEX(',', @sConsolidadosPeriodos, stop + 1)> 0 THEN CHARINDEX(',', @sConsolidadosPeriodos, stop + 1) ELSE LEN(@sConsolidadosPeriodos)+1 END
			FROM Separa
			WHERE stop > 0 AND stop<LEN(@sConsolidadosPeriodos)-1
		)
		INSERT INTO @TablaConsolidadosPeriodos
			SELECT CAST(ltrim(rtrim(SUBSTRING(SUBSTRING(@sConsolidadosPeriodos, start, stop - start),1,charindex('-',SUBSTRING(@sConsolidadosPeriodos, start, stop - start),1)-1))) AS int) IdConsolidado
				,ltrim(rtrim(SUBSTRING(SUBSTRING(@sConsolidadosPeriodos, start, stop - start),charindex('-',SUBSTRING(@sConsolidadosPeriodos, start, stop - start),1)+1,len(SUBSTRING(@sConsolidadosPeriodos, start, stop - start))))) Periodo
			FROM Separa;
		--
		-- INSERTAMOS LOS CONSOLIDADOS Y PERIODOS EN EL CURSOR
		SET @CursorConsolidadosPeriodos = CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR 
			SELECT IdConsolidado, Periodo 
				FROM @TablaConsolidadosPeriodos
				ORDER BY Periodo ASC;
		OPEN @CursorConsolidadosPeriodos;
		FETCH NEXT FROM @CursorConsolidadosPeriodos INTO @iIdConsolidado, @sPeriodo;
		While @@FETCH_STATUS = 0
			Begin
				--
				-- Creacion de un token para las transacciones
				Set @sToken = convert(varchar(24), ROUND(CAST(CAST(GETUTCDATE() AS FLOAT)*8.64e8 AS BIGINT),-1)*1000+599266080000000000);
				Set @sTexto = '_____ Token creado {' + @sToken +'}';
				-- Ejecutamos la extracción de movimientos
				EXEC @iRetVal = EERR_Sp_ERF_Extrae_Movimientos @sToken, @iIdConsolidado, @sPeriodo, @sLibros,'_____';
				If @iRetVal = 1 
					Begin
						Set @sTexto = '_____ Devolvio Error';
						Execute EERR_sp_Log4Sql_Debug @sName, @sTexto;
						Return @iRetVal;
					End;
				

				-- Inserta INGRESOS POR VENTA
				INSERT INTO @TablaTemporalReporte
					SELECT 1
						,idCompania
						,DescripcionCompania
						,idPeriodo
						,SUM(Valor) AS Monto
					FROM EERR_Tmp_Token_ERF
					WHERE 1=1
						AND idConcepto = '01000020'
						AND Token = @sToken
						AND idCompania != '0'
					GROUP BY idCompania
							,DescripcionCompania
							,idPeriodo

				-- Inserta INGRESOS POR VENTA
				INSERT INTO @TablaTemporalReporte
					SELECT 1
						,'0'
						,'ICAFAL S.A. CONSOLIDADO'
						,idPeriodo
						,SUM(Valor) AS Monto
					FROM EERR_Tmp_Token_ERF
					WHERE 1=1
						AND idConcepto = '01000020'
						AND Token = @sToken
					GROUP BY idPeriodo
				DELETE FROM EERR_Tmp_Token_ERF WHERE Token = @sToken
			END;
		SELECT * FROM @TablaTemporalReporte;
		RETURN (0);
	END TRY
	BEGIN CATCH
		Declare @sErr as Varchar(2000);
		set @sErr = 'Num : {' + Convert(varchar, ERROR_LINE()) + '} Mensaje : {' + ERROR_MESSAGE() + '}';
		Execute EERR_sp_Log4sql_ERROR @sName, @sErr;
		print @sErr;
		Return (1);
	END CATCH;
END;