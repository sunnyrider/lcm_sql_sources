WITH 
date_range AS (
	SELECT to_date('01.01.2010', 'dd.mm.yyyy') start_date, to_date('01.10.2019', 'dd.mm.yyyy') end_date FROM dual
),
active_custs AS (
 	SELECT DISTINCT
 		ejj.join_nr, 
 		ejj.ext_join_type_uid
	FROM   bsi_x_ext_join ej
		JOIN   bsi_x_ext_join_join ejj 
			ON ej.ext_join_nr = ejj.ext_join_nr 
			AND ej.ext_join_type_uid = ejj.ext_join_type_uid
	WHERE ej.interface_uid IN (108187)	-- 108187=Adresse (CODE_TYPE = 108408)
	AND ej.ext_join_type_uid = 108224	-- External Company (CODE_TYPE = 318593)
	AND EXISTS (
		SELECT 1
		   FROM   bsi_x_ext_product prd /* Samba */
		   WHERE  prd.JOIN_NR = ej.EXT_JOIN_NR
		   AND    PRD.JOIN_TYPE_UID = ej.ext_join_type_uid
		   AND prd.STATUS_UID IN (109307, 109311)
		   AND PRD.TYPE_UID NOT IN (SELECT UC.UC_UID FROM BSI_UC uc WHERE UC.CODE_TYPE IN (108580) AND UC.PARENT_UID = 6077977889)
		   AND prd.evt_product_END >= (SELECT end_date FROM date_range)
	)
),
calc_stats_custs AS (
 	SELECT 
 		join_nr,
 		ext_join_type_uid 
 	FROM (
	/* Kunden welche nicht aktiv sind, bei denen aber ein Produkt in diesem Monat ablauft */
		SELECT 
			ejj.join_nr, 
			ejj.ext_join_type_uid
		FROM   bsi_x_ext_join ej
			JOIN   bsi_x_ext_join_join ejj 
				ON ej.ext_join_nr = ejj.ext_join_nr 
				AND ej.ext_join_type_uid = ejj.ext_join_type_uid
		WHERE ej.interface_uid IN (108187)  -- 108187=Adresse (CODE_TYPE = 108408)
		AND ej.ext_join_type_uid = 108224 -- External Company (CODE_TYPE = 318593)
		AND EXISTS (
			SELECT 1
			FROM   bsi_x_ext_product prd /* Samba */
			   WHERE  prd.join_nr = ej.ext_join_nr
			   AND    PRD.JOIN_TYPE_UID = ej.ext_join_type_uid
			   AND prd.STATUS_UID IN (109307, 109311)
			   AND PRD.TYPE_UID NOT IN (SELECT UC.UC_UID FROM BSI_UC uc WHERE UC.CODE_TYPE IN (108580) AND UC.PARENT_UID = 6077977889)
--			   	AND prd.EVT_PRODUCT_END >= (SELECT start_date FROM date_range)
			 )
		AND not EXISTS (SELECT 0 FROM active_custs WHERE join_nr = ejj.join_nr)
		/* Kunden welche nicht aktiv sind, bei denen aber ein neues Produkt in diesem Monat dazukommt */
		UNION SELECT DISTINCT 
			ejj.join_nr, 
			ejj.ext_join_type_uid
		FROM   bsi_x_ext_join ej
			JOIN   bsi_x_ext_join_join ejj 
				ON ej.ext_join_nr = ejj.ext_join_nr 
				AND ej.ext_join_type_uid = ejj.ext_join_type_uid
		WHERE  ej.interface_uid IN (108187)  -- 108187=Adresse (CODE_TYPE = 108408)
		AND ej.ext_join_type_uid = 108224 -- External Company (CODE_TYPE = 318593)
		AND EXISTS (
			SELECT 1
			   FROM bsi_x_ext_product prd /* Samba */
			   WHERE PRD.join_nr = ej.ext_join_nr
			   AND  PRD.join_type_uid = ej.ext_join_type_uid
			   AND prd.STATUS_UID IN (109307, 109311)
			   AND PRD.TYPE_UID NOT IN (SELECT UC.UC_UID FROM BSI_UC uc WHERE UC.CODE_TYPE IN (108580) AND UC.PARENT_UID = 6077977889)
			   AND COALESCE (
			   		(SELECT evt_conclusion
			   			FROM bsi_x_ext_contract xct WHERE XCT.CONTRACT_NR = prd.CONTRACT_NR), prd.EVT_PRODUCT_START) 
			   			< (SELECT end_date FROM date_range) 
--			   	AND prd.EVT_PRODUCT_END >= (SELECT end_date FROM date_range)
			)
			AND not EXISTS (SELECT 0 FROM active_custs WHERE join_nr = ejj.join_nr)
		) GROUP BY (join_nr, ext_join_type_uid)
	UNION SELECT 
		atvc.join_nr,
	    atvc.ext_join_type_uid
	FROM   active_custs atvc
),
cust_stats3 AS ( 
	SELECT cstc.*,
        COALESCE (
			(SELECT SUM(COALESCE(xct.value_total, 0)) value_total
				FROM   bsi_x_ext_contract xct
				JOIN   bsi_x_ext_join_join ejj ON xct.join_nr = ejj.ext_join_nr AND xct.join_type_uid = ejj.ext_join_type_uid
				WHERE  xct.origin_uid = 108185 /*Samba*/
				AND    xct.evt_conclusion < (SELECT end_date FROM date_range)
				AND EXISTS (
						SELECT 1 FROM bsi_x_ext_product prd 
						WHERE prd.contract_nr = xct.contract_nr
						AND PRD.TYPE_UID NOT IN (SELECT UC.UC_UID FROM BSI_UC uc WHERE UC.CODE_TYPE IN (108580) AND UC.PARENT_UID = 6077977889)
					AND prd.evt_product_END >= (SELECT end_date FROM date_range)
				)
				AND ejj.join_nr = cstc.join_nr), 0
		 ) wert_ende
	FROM calc_stats_custs cstc
)

SELECT
	(SELECT X_COMPLEX_NO FROM BSI_COMPANY WHERE company_nr = join_nr) COMPLEX_NO,
	join_nr,
	wert_ende
FROM (
	SELECT * FROM (
		SELECT * FROM cust_stats3
		WHERE wert_ende > 0
--		ORDER BY wert_ende
	)
)
;
