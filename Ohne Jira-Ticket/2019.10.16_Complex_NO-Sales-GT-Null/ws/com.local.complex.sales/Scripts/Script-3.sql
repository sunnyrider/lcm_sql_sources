--WITH ad_product_types AS (SELECT uc_uid FROM bsi_uc CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid = 108402)
WITH ad_product_types AS (SELECT uc_uid FROM bsi_uc 
--	CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid IN (108401,3958467004,5799850223,5799850380)
	CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid IN (108402, 108401)
)
SELECT mejj.join_no master_no,
       mej.name master_name,
       cejj.join_no customer_no,
       CMP.X_COMPLEX_NO,
       cej.name customer_name,
       xcnt.contract_no,
       xprd.contract_position,
       bsiutl_uctext(xprd.type_uid, 246) product_type,
       xcnt.evt_conclusion evt_conclusion,
       xprd.evt_product_start evt_start,
       xprd.evt_product_end evt_end,
       xprd.price_netto
FROM bsi_x_ext_contract xcnt
JOIN bsi_x_ext_product xprd
	JOIN bsi_x_ext_join_join cejj
		JOIN bsi_x_ext_join cej
			ON cej.ext_join_nr = cejj.ext_join_nr 
			AND cej.ext_join_type_uid = cejj.ext_join_type_uid
		JOIN bsi_x_ext_join_join mejj
			JOIN bsi_x_ext_join mej
				ON mej.ext_join_nr = mejj.ext_join_nr 
				AND mej.ext_join_type_uid = mejj.ext_join_type_uid
			ON mejj.join_nr = cejj.join_nr 
			AND mejj.ext_join_type_uid = cejj.ext_join_type_uid 
			AND mejj.is_master = 1
		ON cejj.ext_join_nr = xprd.join_nr 
		AND cejj.ext_join_type_uid = xprd.join_type_uid
		INNER JOIN BSI_COMPANY cmp 
		ON CMP.COMPANY_NR = CEJJ.JOIN_NR
	ON xprd.contract_nr = xcnt.contract_nr
WHERE xprd.type_uid IN (SELECT uc_uid FROM ad_product_types)
AND xprd.STATUS_UID IN (109307, 109311)
AND xcnt.evt_conclusion < sysdate AND xprd.evt_product_end > sysdate
AND cej.active = 1
;



WITH ad_product_types AS (SELECT uc_uid FROM bsi_uc 
	CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid IN (108401,3958467004,5799850223,5799850380)
)
SELECT DISTINCT
       CMP.X_COMPLEX_NO
FROM bsi_x_ext_product xprd
	JOIN bsi_x_ext_join_join cejj
		JOIN bsi_x_ext_join cej
			ON cej.ext_join_nr = cejj.ext_join_nr 
			AND cej.ext_join_type_uid = cejj.ext_join_type_uid
		ON cejj.ext_join_nr = xprd.join_nr 
		AND cejj.ext_join_type_uid = xprd.join_type_uid
		INNER JOIN BSI_COMPANY cmp 
		ON CMP.COMPANY_NR = CEJJ.JOIN_NR
WHERE xprd.type_uid IN (SELECT uc_uid FROM ad_product_types)
AND xprd.STATUS_UID IN (109307, 109311)	-- Aktuell, Fakturiert
AND cej.active = 1
AND CMP.IS_ACTIVE = 1
;



WITH ad_product_types AS (SELECT uc_uid FROM bsi_uc CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid = 108402)
--WITH ad_product_types AS (SELECT uc_uid FROM bsi_uc 
--	CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid IN (108401,3958467004,5799850223,5799850380)
--)
SELECT 
       cejj.join_no customer_no,
       CMP.X_COMPLEX_NO,
       cej.name customer_name,
--       xcnt.contract_no,
       xprd.contract_position,
       bsiutl_uctext(xprd.type_uid, 246) product_type,
--       xcnt.evt_conclusion evt_conclusion,
       xprd.evt_product_start evt_start,
       xprd.evt_product_end evt_end,
       xprd.price_netto
--FROM bsi_x_ext_contract xcnt
FROM bsi_x_ext_product xprd
	JOIN bsi_x_ext_join_join cejj
		JOIN bsi_x_ext_join cej
			ON cej.ext_join_nr = cejj.ext_join_nr 
			AND cej.ext_join_type_uid = cejj.ext_join_type_uid
		ON cejj.ext_join_nr = xprd.join_nr 
		AND cejj.ext_join_type_uid = xprd.join_type_uid
		INNER JOIN BSI_COMPANY cmp 
		ON CMP.COMPANY_NR = CEJJ.JOIN_NR
--	ON xprd.contract_nr = xcnt.contract_nr
WHERE xprd.type_uid IN (SELECT uc_uid FROM ad_product_types)
AND xprd.STATUS_UID IN (109307, 109311)
--AND xcnt.evt_conclusion < sysdate AND xprd.evt_product_end > sysdate
AND cej.active = 1
;


WITH ad_product_types AS (SELECT uc_uid FROM bsi_uc CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid = 108402)
--WITH ad_product_types AS (SELECT uc_uid FROM bsi_uc 
--	CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid IN (108401,3958467004,5799850223,5799850380)
--)
SELECT mejj.join_no master_no,
       mej.name master_name,
       cejj.join_no customer_no,
       CMP.X_COMPLEX_NO,
       cej.name customer_name,
       xcnt.contract_no,
       xprd.contract_position,
       bsiutl_uctext(xprd.type_uid, 246) product_type,
       xcnt.evt_conclusion evt_conclusion,
       xprd.evt_product_start evt_start,
       xprd.evt_product_end evt_end,
       xprd.price_netto
FROM bsi_x_ext_contract xcnt
JOIN bsi_x_ext_product xprd
	JOIN bsi_x_ext_join_join cejj
		JOIN bsi_x_ext_join cej
			ON cej.ext_join_nr = cejj.ext_join_nr 
			AND cej.ext_join_type_uid = cejj.ext_join_type_uid
		JOIN bsi_x_ext_join_join mejj
			JOIN bsi_x_ext_join mej
				ON mej.ext_join_nr = mejj.ext_join_nr 
				AND mej.ext_join_type_uid = mejj.ext_join_type_uid
			ON mejj.join_nr = cejj.join_nr 
			AND mejj.ext_join_type_uid = cejj.ext_join_type_uid 
			AND mejj.is_master = 1
		ON cejj.ext_join_nr = xprd.join_nr 
		AND cejj.ext_join_type_uid = xprd.join_type_uid
		INNER JOIN BSI_COMPANY cmp 
		ON CMP.COMPANY_NR = CEJJ.JOIN_NR
	ON xprd.contract_nr = xcnt.contract_nr
WHERE xprd.type_uid IN (SELECT uc_uid FROM ad_product_types)
AND xprd.STATUS_UID IN (109307, 109311)
AND xcnt.evt_conclusion < sysdate AND xprd.evt_product_end > sysdate
AND cej.active = 1
;
