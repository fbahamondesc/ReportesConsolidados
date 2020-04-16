-- ARGUMENTOS
DECLARE @sPath VARCHAR(255) = 'C:\Consolidacion\Files\ISA Presup. 2018 (Ind.).csv';
--VARIABLES
DECLARE @sSql varchar(1000);
DECLARE @iStart INT;
DECLARE @iEnd INT;
DECLARE @cDelimiter CHAR(1) = ';';
-- CURSORES
DECLARE @curPresupuestos CURSOR;
--
DECLARE @PresOrProy VARCHAR(300);
DECLARE @IndivOrCons VARCHAR(300);
DECLARE @Empresa VARCHAR(300);
DECLARE @Nivel1 VARCHAR(300);
DECLARE @Nivel2 VARCHAR(300);
DECLARE @Nivel3 VARCHAR(300);
DECLARE @Concepto VARCHAR(300);
DECLARE @UF VARCHAR(300);
DECLARE @UF_Promedio VARCHAR(300);
DECLARE @sept_17 VARCHAR(300);
DECLARE @dic_17 VARCHAR(300);
DECLARE @ene_18 VARCHAR(300);
DECLARE @feb_18 VARCHAR(300);
DECLARE @mar_18 VARCHAR(300);
DECLARE @abr_18 VARCHAR(300);
DECLARE @may_18 VARCHAR(300);
DECLARE @jun_18 VARCHAR(300);
DECLARE @jul_18 VARCHAR(300);
DECLARE @ago_18 VARCHAR(300);
DECLARE @sept_18 VARCHAR(300);
DECLARE @oct_18 VARCHAR(300);
DECLARE @nov_18 VARCHAR(300);
DECLARE @dic_18 VARCHAR(300);
DECLARE @NOTAS VARCHAR(300);
DECLARE @total_2018 VARCHAR(300);

-- TABLAS TEMPORALES
CREATE TABLE #EERR_TMP_PresupuestosCsv (
	PresOrProy VARCHAR(300),	IndivOrCons VARCHAR(300),	Empresa VARCHAR(300),	Nivel1 VARCHAR(300),	Nivel2 VARCHAR(300),	Nivel3 VARCHAR(300),	Concepto VARCHAR(300),	UF VARCHAR(300),	UF_Promedio VARCHAR(300),	sept_17 VARCHAR(300),	dic_17 VARCHAR(300),	ene_18 VARCHAR(300),	feb_18 VARCHAR(300),	mar_18 VARCHAR(300),	abr_18 VARCHAR(300),	may_18 VARCHAR(300),	jun_18 VARCHAR(300),	jul_18 VARCHAR(300),	ago_18 VARCHAR(300),	sept_18 VARCHAR(300),	oct_18 VARCHAR(300),	nov_18 VARCHAR(300),	dic_18 VARCHAR(300),	NOTAS VARCHAR(300),	total_2018 VARCHAR(300)
);
--
CREATE TABLE #EERR_TMP_Presupuestos (
	PresOrProy VARCHAR(25),	IndivOrCons VARCHAR(25),	Empresa VARCHAR(25),	Nivel1 VARCHAR(300),	Nivel2 VARCHAR(300),	Nivel3 VARCHAR(300),	Concepto VARCHAR(300),	UF VARCHAR(25),	UF_Promedio VARCHAR(25),	Periodo VARCHAR(6),	Monto VARCHAR(25),	NOTAS VARCHAR(300),	total_año VARCHAR(25)
);

--

-- Insertamos las lineas del archivo CSV en una tabla temporal
SET @sSql = 'BULK INSERT #EERR_TMP_PresupuestosCsv 
			 FROM ''' + @sPath + '''
			 WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = '';'',
				ROWTERMINATOR=''\n'' ,
				batchsize=300000
			 );
;';
EXEC (@sSql)

-- Iniciamos el cursor para leer las filas del archivo de excel
SET @curPresupuestos = CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR 
	SELECT PresOrProy, IndivOrCons, Empresa, Nivel1, Nivel2, Nivel3, Concepto, UF,
			UF_Promedio, sept_17, dic_17, ene_18, feb_18, mar_18, abr_18, may_18,
			jun_18, jul_18, ago_18, sept_18, oct_18, nov_18, dic_18, NOTAS, total_2018 
		FROM #EERR_TMP_PresupuestosCsv;
OPEN @curPresupuestos;
FETCH NEXT FROM @curPresupuestos INTO @PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
									  @UF_Promedio, @sept_17, @dic_17, @ene_18, @feb_18, @mar_18, @abr_18, @may_18, 
									  @jun_18, @jul_18, @ago_18, @sept_18, @oct_18, @nov_18, @dic_18, @NOTAS, @total_2018;
WHILE @@FETCH_STATUS = 0
	BEGIN;
		INSERT INTO #EERR_TMP_Presupuestos (PresOrProy,IndivOrCons,Empresa,Nivel1,Nivel2,Nivel3,Concepto,UF
											,UF_Promedio,Periodo,Monto,NOTAS,total_año)
		VALUES (@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF,
				@UF_Promedio,'201709',@sept_17,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201712',@dic_17,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201801',@ene_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201802',@feb_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201803',@mar_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201804',@abr_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201805',@may_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201806',@jun_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201807',@jul_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201808',@ago_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201809',@sept_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201810',@oct_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201811',@nov_18,@NOTAS,@total_2018),
				(@PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
				@UF_Promedio,'201812',@dic_18,@NOTAS,@total_2018)
		FETCH NEXT FROM @curPresupuestos INTO @PresOrProy, @IndivOrCons, @Empresa, @Nivel1, @Nivel2, @Nivel3, @Concepto, @UF, 
									  @UF_Promedio, @sept_17, @dic_17, @ene_18, @feb_18, @mar_18, @abr_18, @may_18, 
									  @jun_18, @jul_18, @ago_18, @sept_18, @oct_18, @nov_18, @dic_18, @NOTAS, @total_2018;
	END;


SELECT RTRIM(LTRIM(ISNULL(PresOrProy, ''))) AS PresOrProy
	,RTRIM(LTRIM(ISNULL(IndivOrCons, ''))) AS IndivOrCons
	,RTRIM(LTRIM(ISNULL(Empresa, ''))) AS Empresa
	,RTRIM(LTRIM(ISNULL(Nivel1, ''))) AS Nivel1
	,RTRIM(LTRIM(ISNULL(Nivel2, ''))) AS Nivel2
	,RTRIM(LTRIM(ISNULL(Nivel3, ''))) AS Nivel3
	,RTRIM(LTRIM(ISNULL(Concepto, ''))) AS Concepto
	,RTRIM(LTRIM(ISNULL(UF, ''))) AS UF
	,RTRIM(LTRIM(ISNULL(UF_Promedio, ''))) AS UF_Promedio
	,RTRIM(LTRIM(ISNULL(Periodo, ''))) AS Periodo
	,RTRIM(LTRIM(ISNULL(Monto, ''))) AS Monto
	,RTRIM(LTRIM(ISNULL(NOTAS, ''))) AS NOTAS
	,RTRIM(LTRIM(ISNULL(total_año, ''))) AS total_año
	from #EERR_TMP_Presupuestos
--
DROP TABLE #EERR_TMP_PresupuestosCsv
DROP TABLE #EERR_TMP_Presupuestos
