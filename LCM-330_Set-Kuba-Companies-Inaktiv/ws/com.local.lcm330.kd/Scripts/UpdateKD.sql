-- Update-Abfrage:
-- Setzt alle Kunden aus BSI_X_EXT_KUBA_DATA-inaktiv
--
MERGE INTO BSI_X_EXT_JOIN ext_join_update 
USING 
(
	SELECT DISTINCT
		EJJ.JOIN_NO kuba_join_no
	FROM BSI_X_EXT_KUBA_DATA xkd 
		INNER JOIN BSI_X_EXT_JOIN_JOIN ejj
			INNER JOIN BSI_X_EXT_JOIN ej 
			ON EJ.EXT_JOIN_NR = EJJ.EXT_JOIN_NR
			AND EJ.EXT_JOIN_TYPE_UID = EJJ.EXT_JOIN_TYPE_UID
		ON EJJ.EXT_JOIN_NR = XKD.JOIN_NR
	WHERE EJ.INTERFACE_UID NOT IN (108187, 108205) -- samba / nxdsmp, K�ba: 131309
	AND EJ.ACTIVE = 1
) set_inactive
ON
(
	set_inactive.kuba_join_no = ext_join_update.JOIN_NO
)
WHEN MATCHED THEN 
	UPDATE SET ext_join_update.ACTIVE = 0
;



MERGE INTO BSICRM.BSI_X_EXT_JOIN ext_join_update 
USING 
(
	SELECT BSI_X_EXT_JOIN__JOIN_NO FROM BSICRM_EXT.BSI_X_KUBA_DATA_JOIN
) reset_active
ON
(
	reset_active.BSI_X_EXT_JOIN__JOIN_NO = ext_join_update.JOIN_NO
)
WHEN MATCHED THEN 
	UPDATE SET ext_join_update.ACTIVE = 1
;
