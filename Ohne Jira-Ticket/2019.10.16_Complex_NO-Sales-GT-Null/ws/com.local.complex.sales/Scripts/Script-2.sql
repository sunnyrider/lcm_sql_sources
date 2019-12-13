SELECT DISTINCT STATUS_UID FROM BSI_X_EXT_PRODUCT
;
SELECT DISTINCT TYPE_UID FROM BSI_X_EXT_PRODUCT
;

SELECT 
	xprd.PRODUCT_NR, 
	xprd.TYPE_UID, 
	IUCT.TEXT,
	xprd.STATUS_UID,
	SUCT.TEXT
FROM BSI_X_EXT_PRODUCT xprd
	INNER JOIN BSI_UC iuc
		INNER JOIN BSI_UC_TEXT iuct
		ON IUCT.UC_UID = IUC.UC_UID
		AND IUCT.LANGUAGE_UID = 246
		AND LOWER(IUCT.TEXT) LIKE LOWER('grundeintra%')
	ON IUC.UC_UID = xprd.TYPE_UID
	INNER JOIN BSI_UC suc
		INNER JOIN BSI_UC_TEXT suct
		ON SUCT.UC_UID = SUC.UC_UID
		AND SUCT.LANGUAGE_UID = 246
	ON xprd.STATUS_UID = SUC.UC_UID
WHERE xprd.STATUS_UID IN (109307, 109311)
;


--WITH ad_product_types AS (SELECT uc_uid FROM bsi_uc CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid = 108402)
WITH ad_product_types AS (SELECT uc_uid FROM bsi_uc 
	CONNECT BY PRIOR uc_uid = parent_uid START WITH uc_uid IN (108401,3958467004,5799850223,5799850380)
)
--WITH ad_product_types AS (
--	SELECT UC.UC_UID 
--		FROM BSI_UC uc INNER JOIN BSI_UC_TEXT uct ON UCT.UC_UID = UC.UC_UID 
--	WHERE LOWER(UCT.TEXT) LIKE LOWER('grundeintra%')
--	AND UC.CODE_TYPE = 108580
--	)
SELECT 
       xprd.contract_position,
       xprd.evt_product_start evt_start,
       xprd.evt_product_end evt_end,
       xprd.price_netto,
       XPRD.JOIN_NR,
       XPRD.JOIN_TYPE_UID
FROM bsi_x_ext_product xprd
WHERE xprd.type_uid IN (SELECT uc_uid FROM ad_product_types)
AND xprd.STATUS_UID IN (109307, 109311)
;
