WITH 
date_range AS (
	SELECT to_date('01.07.2019', 'dd.mm.yyyy') start_date, to_date('01.08.2019', 'dd.mm.yyyy') end_date FROM dual
),
active_custs AS (
 	SELECT DISTINCT
 		ejj.join_nr, 
 		ejj.ext_join_type_uid, 
 		1 stand_start, 
 		1 stand_ende
	-- Aktive Kunden, d.h. Kunden, welche mindestens 1 Produkt haben, 
 	-- dessen Start vor Monatsstart und Ende nach Monatsende
	FROM   bsi_x_ext_join ej
		JOIN   bsi_x_ext_join_join ejj 
			ON ej.ext_join_nr = ejj.ext_join_nr 
			AND ej.ext_join_type_uid = ejj.ext_join_type_uid
	WHERE  ej.interface_uid = 108187	-- Adresse (CODE_TYPE = 108408)
	AND    ej.ext_join_type_uid = 108224	-- External Company (CODE_TYPE = 318593)
	AND    EXISTS (
		SELECT 1
		   FROM   bsi_x_ext_product prd /* Samba */
		   WHERE  prd.JOIN_NR = ej.EXT_JOIN_NR
		   AND    PRD.JOIN_TYPE_UID = ej.ext_join_type_uid
		   AND EXISTS (
		   		SELECT 1 FROM bsi_uc 
		   		WHERE uc_uid = 108402	-- Werbeproduct 
		   		CONNECT BY PRIOR parent_uid = uc_uid 
		   		START WITH uc_uid = prd.type_uid)
		   AND COALESCE (
		   		(SELECT evt_conclusion FROM bsi_x_ext_contract WHERE contract_nr = prd.contract_nr), prd.evt_product_start) 
				< (SELECT start_date FROM date_range) AND prd.evt_product_END >= (SELECT end_date FROM date_range)
	)
),
calc_stats_custs AS (
 	SELECT 
 		join_nr, 
 		ext_join_type_uid, 
 		max(stand_start) stand_start, 
 		max(stand_ende) stand_ende 
 	FROM (
	/* Kunden welche nicht aktiv sind, bei denen aber ein Produkt in diesem Monat ablauft */
		SELECT 
			ejj.join_nr, 
			ejj.ext_join_type_uid, 
			1 stand_start, 
			0 stand_ende
		FROM   bsi_x_ext_join ej
			JOIN   bsi_x_ext_join_join ejj 
			ON ej.ext_join_nr = ejj.ext_join_nr 
			AND ej.ext_join_type_uid = ejj.ext_join_type_uid
		WHERE  ej.interface_uid = 108187
		AND    ej.ext_join_type_uid = 108224
		AND EXISTS (
			SELECT 1
			FROM   bsi_x_ext_product prd /* Samba */
			   WHERE  prd.join_nr = ej.ext_join_nr
			   AND    PRD.JOIN_TYPE_UID = ej.ext_join_type_uid
			   AND    EXISTS (
			   		SELECT 1 
			   		FROM bsi_uc 
			   		WHERE uc_uid = 108402	-- Werbeprodukt
			   		CONNECT BY PRIOR parent_uid = uc_uid 
			   		START WITH uc_uid = prd.type_uid)
			   AND COALESCE (
			   		(SELECT evt_conclusion 
			   			FROM bsi_x_ext_contract 
			   			WHERE contract_nr = prd.contract_nr), prd.evt_product_start) < (SELECT start_date FROM date_range) 
			   			AND prd.evt_product_END >= (SELECT start_date FROM date_range)
			 )
		AND not EXISTS (SELECT 0 FROM active_custs WHERE join_nr = ejj.join_nr)
		/* Kunden welche nicht aktiv sind, bei denen aber ein neues Produkt in diesem Monat dazukommt */
		UNION SELECT DISTINCT 
			ejj.join_nr, 
			ejj.ext_join_type_uid, 
			0 stand_start, 
			1 stand_ende
		FROM   bsi_x_ext_join ej
			JOIN   bsi_x_ext_join_join ejj ON ej.ext_join_nr = ejj.ext_join_nr 
			AND ej.ext_join_type_uid = ejj.ext_join_type_uid
		WHERE  ej.interface_uid = 108187
		AND    ej.ext_join_type_uid = 108224
		AND EXISTS (
			SELECT 1
			   FROM bsi_x_ext_product prd /* Samba */
			   WHERE PRD.join_nr = ej.ext_join_nr
			   AND  PRD.join_type_uid = ej.ext_join_type_uid
			   AND  EXISTS (SELECT 1 FROM bsi_uc WHERE uc_uid = 108402 /* ad product */ 
			   		CONNECT BY PRIOR parent_uid = uc_uid 
			   		START WITH uc_uid = prd.type_uid)
			   AND COALESCE (
			   		(SELECT evt_conclusion 
			   			FROM bsi_x_ext_contract 
			   			WHERE contract_nr = prd.contract_nr), prd.evt_product_start) < (SELECT end_date FROM date_range) 
			   			AND prd.evt_product_END >= (SELECT end_date FROM date_range)
			)
		AND not EXISTS (SELECT 0 FROM active_custs WHERE join_nr = ejj.join_nr)
	) GROUP BY (join_nr, ext_join_type_uid)
),
cust_stats AS ( /* Berechnung der verschiedenen Kriterien (Beschrieb der Stati --> LCM-1593)*/
  	SELECT csc.join_nr,
         csc.ext_join_type_uid,
         csc.stand_start stand_start,
         csc.stand_start ablauf, 
         /* In der calc_stats_custs sind nur Kunden, deren Produkte ablaufen (sofern sie am Anfang welche hatten */
         /* Ersatz haben Kunden, welche ein Produkt haben, welches ersetzt wurde im gegebenen Zeitraum */
        CASE WHEN stand_start = 1 
        	AND stand_ende = 1 
        	AND EXISTS (
            	SELECT 1
				   FROM   bsi_x_ext_product prd
				   WHERE  PRD.join_nr IN (
				   		SELECT iejj.ext_join_nr 
				   		FROM bsi_x_ext_join_join iejj 
				   		JOIN bsi_x_ext_join iej ON iejj.ext_join_nr = iej.ext_join_nr 
				   		AND iejj.ext_join_type_uid = iej.ext_join_type_uid 
				   		WHERE iejj.ext_join_type_uid = 108224 
				   		AND iejj.ext_join_type_uid = csc.ext_join_type_uid 
				   		AND iejj.join_nr = csc.join_nr 
				   		AND iej.interface_uid = 108187
				   	)
				   AND    PRD.join_type_uid = csc.ext_join_type_uid
				   AND    EXISTS (
					   		SELECT 1 FROM bsi_uc 
					   		WHERE uc_uid = 108402 /* ad product */ 
					   		CONNECT BY PRIOR parent_uid = uc_uid 
					   		START WITH uc_uid = prd.type_uid
				   		)
				   AND    PRD.EVT_PRODUCT_END >= (SELECT start_date FROM date_range)
				   AND    PRD.evt_product_END < (SELECT end_date FROM date_range)
				   AND COALESCE((SELECT evt_conclusion 
				   				FROM bsi_x_ext_contract 
				   				WHERE contract_nr = prd.contract_nr), prd.evt_product_start
				   		) < (SELECT start_date FROM date_range)
				   AND PRD.STATUS_UID = 109310 /* Ersetzt */
		) THEN 1
		  ELSE 0 
		  END ersatz,
        /* Ordentlicher Ersatz haben Kunden, welche einen neuen Vertrag haben und dessen Produkte nicht ersetzt wurden */
        CASE WHEN stand_start = 1 
        	AND stand_ende = 1 
        	AND not EXISTS 
        	(  
        	   SELECT 1
			   FROM   bsi_x_ext_product prd
			   WHERE PRD.join_nr IN (
			   			SELECT iejj.ext_join_nr 
			   			FROM bsi_x_ext_join_join iejj 
			   			JOIN bsi_x_ext_join iej 
			   				ON iejj.ext_join_nr = iej.ext_join_nr 
			   				AND iejj.ext_join_type_uid = iej.ext_join_type_uid 
			   			WHERE iejj.ext_join_type_uid = 108224 
			   			AND iejj.ext_join_type_uid = csc.ext_join_type_uid 
			   			AND iejj.join_nr = csc.join_nr 
			   			AND iej.interface_uid = 108187
			   	)
			   AND    PRD.join_type_uid = csc.ext_join_type_uid
			   AND    EXISTS (
			   			SELECT 1 FROM bsi_uc 
			   			WHERE uc_uid = 108402 /* ad product */ 
			   			CONNECT BY PRIOR parent_uid = uc_uid 
			   			START WITH uc_uid = prd.type_uid
			   	)
			   AND    PRD.EVT_PRODUCT_END >= (SELECT start_date FROM date_range)
			   AND    PRD.EVT_PRODUCT_END < (SELECT end_date FROM date_range)
			   AND  COALESCE(
			   				(SELECT evt_conclusion FROM bsi_x_ext_contract 
			   					WHERE contract_nr = prd.contract_nr), prd.evt_product_start
			   		) < (SELECT start_date FROM date_range)
			   AND  PRD.STATUS_UID = 109310 /* Ersetzt */
			   ) THEN
			   		1
               ELSE 
               		0 
               END ordentlich_ersatz,
        /* Ablauf nicht ordentlich --> keine neuen Vertr�ge mehr, ein Produkt wurde storniert */
        CASE WHEN stand_start = 1 
        	AND stand_ende = 0 
        	AND EXISTS 
        	(SELECT 1
				FROM   bsi_x_ext_product prd
				WHERE  PRD.join_nr IN (
							SELECT iejj.ext_join_nr 
							FROM bsi_x_ext_join_join iejj 
								JOIN bsi_x_ext_join iej 
								ON iejj.ext_join_nr = iej.ext_join_nr 
								AND iejj.ext_join_type_uid = iej.ext_join_type_uid 
							WHERE iejj.ext_join_type_uid = 108224 
							AND iejj.ext_join_type_uid = csc.ext_join_type_uid 
							AND iejj.join_nr = csc.join_nr 
							AND iej.interface_uid = 108187
				)
				AND PRD.join_type_uid = csc.ext_join_type_uid
				AND EXISTS (
						SELECT 1 FROM bsi_uc 
						WHERE uc_uid = 108402 /* ad product */ 
						CONNECT BY PRIOR parent_uid = uc_uid 
						START WITH uc_uid = prd.type_uid
				)
				AND    PRD.evt_product_END >= (SELECT start_date FROM date_range)
				AND    PRD.evt_product_END < (SELECT end_date FROM date_range)
				AND    PRD.STATUS_UID = 109310 /* Storniert */
		) THEN 
			1
		ELSE 
			0 
		END abgang_nicht_ordentlich,
        /* Ablauf ordentlich --> keine neuen Vertr�ge mehr, kein Produkt wurde storniert */
        CASE WHEN stand_start = 1 
        	AND stand_ende = 0 
        	AND not EXISTS (
        		SELECT 1
				FROM   bsi_x_ext_product prd
					WHERE  PRD.JOIN_NR IN (
							SELECT iejj.ext_join_nr 
							FROM bsi_x_ext_join_join iejj 
								JOIN bsi_x_ext_join iej 
								ON iejj.ext_join_nr = iej.ext_join_nr 
								AND iejj.ext_join_type_uid = iej.ext_join_type_uid 
							WHERE iejj.ext_join_type_uid = 108224 
							AND iejj.ext_join_type_uid = csc.ext_join_type_uid 
							AND iejj.join_nr = csc.join_nr 
							AND iej.interface_uid = 108187
					)
					AND PRD.JOIN_TYPE_UID = csc.ext_join_type_uid
					AND EXISTS (
							SELECT 1 FROM bsi_uc 
							WHERE uc_uid = 108402 /* ad product */ 
							CONNECT BY PRIOR parent_uid = uc_uid 
							START WITH uc_uid = prd.type_uid
					)
					AND    PRD.EVT_PRODUCT_END >= (SELECT start_date FROM date_range)
					AND    PRD.EVT_PRODUCT_END < (SELECT end_date FROM date_range)
					AND    PRD.STATUS_UID = 109310 /* Storniert */
				) THEN 
					1
			ELSE 
				0 
			END abgang_ordentlich,
            CASE WHEN stand_start = 0 AND stand_ende = 1 THEN 1 ELSE 0 END neu,
            csc.stand_ende stand_ende
      FROM   calc_stats_custs csc
      UNION SELECT atvc.join_nr,
              atvc.ext_join_type_uid,
              1, 0, 0, 0, 0, 0, 0, 1
      FROM   active_custs atvc
),
cust_stats2 AS (
	SELECT ssc.*,
		/* Marktquadrant Berechnung */
		CASE WHEN EXISTS (
			SELECT 1 FROM   bsi_x_ext_product prd
			WHERE  prd.join_nr IN (
						SELECT iejj.ext_join_nr 
						FROM bsi_x_ext_join_join iejj 
						JOIN bsi_x_ext_join iej ON iejj.ext_join_nr = iej.ext_join_nr 
						AND iejj.ext_join_type_uid = iej.ext_join_type_uid 
						WHERE iejj.ext_join_type_uid = 108224 
						AND iejj.ext_join_type_uid = ssc.ext_join_type_uid 
						AND iejj.join_nr = ssc.join_nr 
						AND iej.interface_uid = 108187
			)
			AND    prd.join_type_uid = ssc.ext_join_type_uid
			AND    COALESCE(
						(
							SELECT evt_conclusion FROM bsi_x_ext_contract WHERE contract_nr = prd.contract_nr
						), prd.evt_product_start)
						< (SELECT start_date FROM date_range)
			AND    evt_product_END >= (SELECT start_date FROM date_range)
			AND    EXISTS (
						SELECT 1 FROM bsi_uc 
						WHERE uc_uid = 108402 /* ad product */ 
						CONNECT BY PRIOR parent_uid = uc_uid 
						START WITH uc_uid = prd.type_uid
			)
			AND    not EXISTS (
						SELECT 1 FROM bsi_uc 
						WHERE uc_uid = 132289 /* search product */ 
						CONNECT BY PRIOR parent_uid = uc_uid 
						START WITH uc_uid = prd.type_uid
			)
		) THEN 1 
		ELSE 0 
		END start_is_local_ch,
		CASE WHEN EXISTS (
			SELECT 1 FROM   bsi_x_ext_product prd
			WHERE  prd.join_nr IN (
						SELECT iejj.ext_join_nr 
						FROM bsi_x_ext_join_join iejj 
						JOIN bsi_x_ext_join iej ON iejj.ext_join_nr = iej.ext_join_nr 
						AND iejj.ext_join_type_uid = iej.ext_join_type_uid 
						WHERE iejj.ext_join_type_uid = 108224 
						AND iejj.ext_join_type_uid = ssc.ext_join_type_uid 
						AND iejj.join_nr = ssc.join_nr 
						AND iej.interface_uid = 108187
			)
			AND    prd.join_type_uid = ssc.ext_join_type_uid
			AND    COALESCE(
					(
						SELECT evt_conclusion FROM bsi_x_ext_contract WHERE contract_nr = prd.contract_nr
					), prd.evt_product_start
					) < (SELECT start_date FROM date_range)
			AND    evt_product_END >= (SELECT start_date FROM date_range)
			AND    EXISTS (
					SELECT 1 FROM bsi_uc 
					WHERE uc_uid = 132289 /* search product */ 
					CONNECT BY PRIOR parent_uid = uc_uid 
					START WITH uc_uid = prd.type_uid
			)
		) THEN 1 
		ELSE 0 
		END start_is_search_ch,
		CASE WHEN EXISTS (
			SELECT 1 FROM bsi_x_ext_product prd
			WHERE  prd.join_nr IN (
						SELECT iejj.ext_join_nr 
						FROM bsi_x_ext_join_join iejj JOIN bsi_x_ext_join iej ON iejj.ext_join_nr = iej.ext_join_nr 
						AND iejj.ext_join_type_uid = iej.ext_join_type_uid 
						WHERE iejj.ext_join_type_uid = 108224 
						AND iejj.ext_join_type_uid = ssc.ext_join_type_uid 
						AND iejj.join_nr = ssc.join_nr 
						AND iej.interface_uid = 108187
			)
			AND    prd.join_type_uid = ssc.ext_join_type_uid
			AND    COALESCE(
					(
						SELECT evt_conclusion FROM bsi_x_ext_contract WHERE contract_nr = prd.contract_nr
					), prd.evt_product_start
					) < (SELECT end_date FROM date_range)
			AND    evt_product_END >= (SELECT end_date FROM date_range)
			AND    EXISTS (
						SELECT 1 FROM bsi_uc 
						WHERE uc_uid = 108402 /* ad product */ 
						CONNECT BY PRIOR parent_uid = uc_uid 
						START WITH uc_uid = prd.type_uid
			)
			AND    not EXISTS (
						SELECT 1 FROM bsi_uc 
						WHERE uc_uid = 132289 /* search product */ 
						CONNECT BY PRIOR parent_uid = uc_uid 
						START WITH uc_uid = prd.type_uid
			)
		) THEN 1 
		ELSE 0 
		END ende_is_local_ch,
		CASE WHEN EXISTS (SELECT 1
			FROM   bsi_x_ext_product prd
			WHERE  prd.join_nr IN (
						SELECT iejj.ext_join_nr 
						FROM bsi_x_ext_join_join iejj 
						JOIN bsi_x_ext_join iej ON iejj.ext_join_nr = iej.ext_join_nr 
						AND iejj.ext_join_type_uid = iej.ext_join_type_uid 
						WHERE iejj.ext_join_type_uid = 108224 
						AND iejj.ext_join_type_uid = ssc.ext_join_type_uid 
						AND iejj.join_nr = ssc.join_nr 
						AND iej.interface_uid = 108187
			)
			AND    prd.join_type_uid = ssc.ext_join_type_uid
			AND    COALESCE(
					(
						SELECT evt_conclusion FROM bsi_x_ext_contract WHERE contract_nr = prd.contract_nr
					), prd.evt_product_start) 
					< (SELECT end_date FROM date_range)
			AND    evt_product_END >= (SELECT end_date FROM date_range)
			AND    EXISTS (
						SELECT 1 FROM bsi_uc 
						WHERE uc_uid = 132289 /* search product */ 
						CONNECT BY PRIOR parent_uid = uc_uid 
						START WITH uc_uid = prd.type_uid
			)
		) THEN 1 
		ELSE 0 
		END ende_is_search_ch
	FROM cust_stats ssc
),
cust_stats3 AS ( 
	SELECT cs2.*,
        CASE WHEN cs2.start_is_local_ch = 1 AND cs2.start_is_search_ch = 1 THEN 130980
            WHEN cs2.start_is_local_ch = 1 THEN 130981
            WHEN cs2.start_is_search_ch = 1 THEN 130982
			ELSE 130983 
		END customer_quadrant_start,
        CASE WHEN cs2.ende_is_local_ch = 1 AND cs2.ende_is_search_ch = 1 THEN 130980
            WHEN cs2.ende_is_local_ch = 1 THEN 130981
            WHEN cs2.ende_is_search_ch = 1 THEN 130982
            ELSE 130983 
		END customer_quadrant_ende,
        CASE WHEN cs2.ext_join_type_uid = 108224 THEN
            COALESCE((SELECT sfs.leader_nr
                       FROM   bsi_x_structure_sales sfs
                       WHERE  sfs.user_nr = (SELECT max(advisor_user_nr) FROM bsi_company_advisor WHERE company_nr = cs2.join_nr AND advisor_uid = 128840 /* Fieldsales */)),
             0)
        ELSE COALESCE((SELECT sfs.leader_nr
                       FROM   bsi_x_structure_sales sfs
                       WHERE  sfs.user_nr = (SELECT max(advisor_user_nr) FROM bsi_person_advisor WHERE person_nr = cs2.join_nr AND advisor_uid = 128840 /* Fieldsales */)),
             0)
        END region_leader,
		COALESCE (
			(SELECT SUM(COALESCE(xct.value_total, 0)) value_total
				FROM   bsi_x_ext_contract xct
				JOIN   bsi_x_ext_join_join ejj ON xct.join_nr = ejj.ext_join_nr AND xct.join_type_uid = ejj.ext_join_type_uid
				WHERE  xct.origin_uid = 108185 /*Samba*/
				AND    xct.evt_conclusion < (SELECT start_date FROM date_range)
				AND EXISTS (
						SELECT 1 FROM bsi_x_ext_product prd 
						WHERE prd.contract_nr = xct.contract_nr 
						AND EXISTS (
							SELECT 1 FROM bsi_uc 
							WHERE uc_uid = 108402 /* ad product */ 
							CONNECT BY PRIOR parent_uid = uc_uid 
							START WITH uc_uid = prd.type_uid
						) 
					AND prd.evt_product_END >= (SELECT start_date FROM date_range)
				)
				AND ejj.join_nr = cs2.join_nr), 0
		) wert_start,
        COALESCE(
			(SELECT SUM(COALESCE(xct.value_total, 0)) value_total
				FROM   bsi_x_ext_contract xct
				JOIN   bsi_x_ext_join_join ejj ON xct.join_nr = ejj.ext_join_nr AND xct.join_type_uid = ejj.ext_join_type_uid
				WHERE  xct.origin_uid = 108185 /*Samba*/
				AND    xct.evt_conclusion < (SELECT end_date FROM date_range)
				AND EXISTS (
						SELECT 1 FROM bsi_x_ext_product prd 
						WHERE prd.contract_nr = xct.contract_nr 
						AND EXISTS (
								SELECT 1 FROM bsi_uc 
								WHERE uc_uid = 108402 /* ad product */ 
								CONNECT BY PRIOR parent_uid = uc_uid 
								START WITH uc_uid = prd.type_uid
						) 
					AND prd.evt_product_END >= (SELECT end_date FROM date_range)
				)
				AND ejj.join_nr = cs2.join_nr), 0
		 ) wert_ende
	FROM   cust_stats2 cs2
),
cust_stats4 AS (
	SELECT bsiutl_uctext(customer_quadrant_start, 246) marktquadrant_start, /* Gruppierung nach Marktquadrant */
       CASE WHEN region_leader <> 0 THEN
          (SELECT uc.text || ' - ' || uc_text.text 
				FROM bsi_uc uc 
					left outer JOIN bsi_uc_text uc_text 
					ON uc.uc_uid = uc_text.uc_uid 
					AND uc_text.language_uid = 246 
				WHERE uc.uc_uid = (
					SELECT structure_sales_uid 
						FROM bsi_x_structure_sales 
					WHERE user_nr = (SELECT director_nr FROM bsi_x_structure_sales WHERE user_nr = region_leader))
			)
		else
			'Nicht zugewiesen' 
		END rd,
       CASE WHEN region_leader <> 0 THEN 1 ELSE 2 END rd_order,
       CASE WHEN region_leader <> 0 THEN
			(
				SELECT uc.text || ' - ' || uc_text.text 
				FROM bsi_uc uc left outer JOIN bsi_uc_text uc_text ON uc.uc_uid = uc_text.uc_uid 
				AND uc_text.language_uid = 246 
				WHERE uc.uc_uid = (
					SELECT structure_sales_uid FROM bsi_x_structure_sales WHERE user_nr = region_leader
				)
			)
       ELSE '' 
       END rl,
       1 rl_order,
       SUM(stand_start) stand_start,
       SUM(wert_start) wert_start,
       SUM(ablauf) ablauf,
       SUM(CASE WHEN ablauf = 1 THEN wert_start ELSE 0 end) ablauf_wert,
       SUM(ersatz) ersatz,
       SUM(CASE WHEN ersatz = 1 THEN wert_start ELSE 0 end) ersatz_wert,
       SUM(CASE WHEN ersatz = 1 THEN wert_ende ELSE 0 end) ersetzt_wert,
       SUM(ordentlich_ersatz) ordentlich_ersatz,
       SUM(CASE WHEN ordentlich_ersatz = 1 THEN wert_start ELSE 0 end) ord_ersatz_wert,
       SUM(CASE WHEN ordentlich_ersatz = 1 THEN wert_ende ELSE 0 end) ord_ersetzt_wert,
       SUM(abgang_nicht_ordentlich) abgang_nicht_ordentlich,
       SUM(CASE WHEN abgang_nicht_ordentlich = 1 THEN wert_start ELSE 0 end) abgang_nicht_ord_wert,
       SUM(abgang_ordentlich) abgang_ordentlich,
       SUM(CASE WHEN abgang_ordentlich = 1 THEN wert_start ELSE 0 end) abgang_ord_wert,
       SUM(neu) neu,
       SUM(CASE WHEN neu = 1 THEN wert_ende ELSE 0 end) neu_wert,
       SUM(stand_ende) stand_ende,
       SUM(wert_ende) wert_ende,
       bsiutl_uctext(customer_quadrant_ende, 246) marktquadrant_ende
	FROM cust_stats3 cs3 GROUP BY (customer_quadrant_start, customer_quadrant_ende, region_leader)
)
SELECT 
	CASE WHEN marktquadrant_start <> 'Z' THEN 
		marktquadrant_start 
	ELSE 
		'' 
	END marktquadrant_start,
	(SELECT start_date FROM date_range) start_date,
	rd region,
	COALESCE(rl, rd) rl,
	stand_start,
	wert_start,
	ablauf,
	ablauf_wert,
	ersatz,
	ersatz_wert,
	ersetzt_wert,
	ordentlich_ersatz,
	ord_ersatz_wert,
	ord_ersetzt_wert,
	abgang_nicht_ordentlich,
	abgang_nicht_ord_wert,
	abgang_ordentlich,
	abgang_ord_wert,
	neu,
	neu_wert,
	stand_ende,
	wert_ende,
	(SELECT end_date - 1 FROM date_range) end_date,
	CASE WHEN marktquadrant_ende <> 'Z' THEN 
		marktquadrant_ende 
	ELSE 
		'' 
	END marktquadrant_ende 
FROM (
	SELECT * FROM (
		SELECT * FROM cust_stats4

		UNION ALL 
			SELECT 
				marktquadrant_start,
				rd,
				1,
				'',
				0,
				SUM(stand_start) stand_start,
				SUM(wert_start) wert_start,
				SUM(ablauf) ablauf,
				SUM(ablauf_wert) ablauf_wert,
				SUM(ersatz) ersatz,
				SUM(ersatz_wert) ersatz_wert,
				SUM(ersetzt_wert) ersetzt_wert,
				SUM(ordentlich_ersatz) ordentlich_ersatz,
				SUM(ord_ersatz_wert) ord_ersatz_wert,
				SUM(ord_ersetzt_wert) ord_ersetzt_wert,
				SUM(abgang_nicht_ordentlich) abgang_nicht_ordentlich,
				SUM(abgang_nicht_ord_wert) abgang_nicht_ord_wert,
				SUM(abgang_ordentlich) abgang_ordentlich,
				SUM(abgang_ord_wert) abgang_ord_wert,
				SUM(neu) neu,
				SUM(neu_wert) neu_wert,
				SUM(stand_ende) stand_ende,
				SUM(wert_ende) wert_ende,
				marktquadrant_ende 
			FROM cust_stats4
			WHERE rd <> 'Nicht zugewiesen' 
			GROUP BY marktquadrant_start, marktquadrant_ende, rd

		UNION ALL 
			SELECT 
				marktquadrant_start,
				'Total Schweiz',
				0,
				'',
				0,
				SUM(stand_start) stand_start,
				SUM(wert_start) wert_start,
				SUM(ablauf) ablauf,
				SUM(ablauf_wert) ablauf_wert,
				SUM(ersatz) ersatz,
				SUM(ersatz_wert) ersatz_wert,
				SUM(ersetzt_wert) ersetzt_wert,
				SUM(ordentlich_ersatz) ordentlich_ersatz,
				SUM(ord_ersatz_wert) ord_ersatz_wert,
				SUM(ord_ersetzt_wert) ord_ersetzt_wert,
				SUM(abgang_nicht_ordentlich) abgang_nicht_ordentlich,
				SUM(abgang_nicht_ord_wert) abgang_nicht_ord_wert,
				SUM(abgang_ordentlich) abgang_ordentlich,
				SUM(abgang_ord_wert) abgang_ord_wert,
				SUM(neu) neu,
				SUM(neu_wert) neu_wert,
				SUM(stand_ende) stand_ende,
				SUM(wert_ende) wert_ende,
				marktquadrant_ende
			FROM cust_stats4 GROUP BY marktquadrant_start, marktquadrant_ende

		UNION ALL 
			SELECT 
				'Z',
				'Gesamttotal Schweiz',
				0,
				'',
				0,
				SUM(stand_start) stand_start,
				SUM(wert_start) wert_start,
				SUM(ablauf) ablauf,
				SUM(ablauf_wert) ablauf_wert,
				SUM(ersatz) ersatz,
				SUM(ersatz_wert) ersatz_wert,
				SUM(ersetzt_wert) ersetzt_wert,
				SUM(ordentlich_ersatz) ordentlich_ersatz,
				SUM(ord_ersatz_wert) ord_ersatz_wert,
				SUM(ord_ersetzt_wert) ord_ersetzt_wert,
				SUM(abgang_nicht_ordentlich) abgang_nicht_ordentlich,
				SUM(abgang_nicht_ord_wert) abgang_nicht_ord_wert,
				SUM(abgang_ordentlich) abgang_ordentlich,
				SUM(abgang_ord_wert) abgang_ord_wert,
				SUM(neu) neu,
				SUM(neu_wert) neu_wert,
				SUM(stand_ende) stand_ende,
				SUM(wert_ende) wert_ende,
				''
			FROM cust_stats4
	)
	ORDER BY marktquadrant_start, marktquadrant_ende, rd_order, rd, rl_order, rl
)
;
