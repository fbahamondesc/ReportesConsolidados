declare @err INT;
--EXEC @err = EERR_Sp_Reporte_ERF_Genera 482, '201812', 455, '201712', 'REAL,NOLOB,IFRS'
--EXEC @err = EERR_Sp_Reporte_ERFSuper_Genera 482, '201812', 455, '201712', 'REAL,NOLOB,IFRS'
--EXEC @err = EERR_Sp_Reporte_ESF_Genera 482, '201812', 455, '201712', 'REAL,NOLOB,IFRS'
--EXEC @err = EERR_Sp_Reporte_ESFSuper_Genera 482, '201812', 455, '201712', 'REAL,NOLOB,IFRS'


--EXEC @err = EERR_Sp_Reporte_ERF_Genera 455, '201712', 143, '201612', 'REAL,NOLOB,IFRS'
--EXEC @err = EERR_Sp_Reporte_ERFSuper_Genera 455, '201712', 143, '201612', 'REAL,NOLOB,IFRS'


--EXEC @err = EERR_Sp_Reporte_ERF_Genera 467, '201812', 118, '201712', 'REAL,NOLOB,IFRS'
--EXEC @err = EERR_Sp_Reporte_ERFSuper_Genera 467, '201812', 118, '201712', 'REAL,NOLOB,IFRS'

--EXEC @err = EERR_Sp_Reporte_RFXA_Genera '201712', 'REAL,NOLOB,IFRS';


--EXEC @err = EERR_Sp_ERF_Extrae_Movimientos '637199585710830000', 455, '201712', 'REAL,NOLOB,IFRS', '__';
--SELECT * FROM EERR_Tmp_Token_ERF WHERE Token = '637199585710830000';
--SELECT 1
--	,idPeriodo
--	,SUM(Valor) AS Monto
--FROM EERR_Tmp_Token_ERF
--WHERE idConcepto = '01000020'
--	AND Token = '637199585710830000'
--GROUP BY idPeriodo
--DELETE FROM EERR_Tmp_Token_ERF WHERE Token = '637199585710830000';

EXEC @err = EERR_Sp_Reporte_RFXA_Genera '455-201712', 'REAL,NOLOB,IFRS'

print @err;