-- **********************************************
--
-- Bitte die Statements jeweils EINZELN ausf�hren
--
-- **********************************************

-- ------------------------
-- 1.
-- Backup-Tabelle erstellen
-- ------------------------
-- 
-- Tabelle zum Speichern der BSI_X_EXT_JOIN.JOIN_NO
-- mit Beziehung zu BSI_X_EXT_KUBA_DATA
--
CREATE TABLE BSICRM_EXT.BSI_X_KUBA_PERSONS_JOIN (
	BSI_X_EXT_JOIN__JOIN_NO VARCHAR2(60),
	BSI_PERSON__PERSON_NR NUMBER(22)
);


-- -------------------------------------------
-- 2.
-- Speichern von BSI_X_EXT_JOIN.JOIN_NO und
-- BSI_PERSON.PERSON_NR
-- f�r evt. Reaktivierung
-- -------------------------------------------
-- 
INSERT INTO BSICRM_EXT.BSI_X_KUBA_PERSONS_JOIN BKP (
	BKP.BSI_X_EXT_JOIN__JOIN_NO,
	BSI_PERSON__PERSON_NR
	)
	SELECT DISTINCT
		EJJ.JOIN_NO,
		PRS.PERSON_NR
	FROM BSICRM.BSI_X_EXT_JOIN_JOIN ejj
		LEFT JOIN BSICRM.BSI_PERSON prs 
		ON PRS.PERSON_NR = EJJ.JOIN_NR
		AND PRS.IS_ACTIVE = 1
		INNER JOIN BSICRM.BSI_X_EXT_JOIN ej 
		ON EJ.EXT_JOIN_NR = EJJ.EXT_JOIN_NR
		AND EJ.EXT_JOIN_TYPE_UID = EJJ.EXT_JOIN_TYPE_UID
	WHERE EJ.INTERFACE_UID IN (131310) -- 131310: K�Ba Personendaten
	AND EJ.ACTIVE = 1
;


-- ------------------------------------------------------
-- 3.
-- Update: Setzt K�Ba Personen in BSI_X_EXT_JOIN inaktiv
-- ------------------------------------------------------
--
MERGE INTO BSI_X_EXT_JOIN ext_join_update 
USING 
(
	SELECT DISTINCT
		EJJ.JOIN_NO kuba_join_no
	FROM BSICRM.BSI_X_EXT_JOIN_JOIN ejj
		INNER JOIN BSICRM.BSI_X_EXT_JOIN ej 
		ON EJ.EXT_JOIN_NR = EJJ.EXT_JOIN_NR
		AND EJ.EXT_JOIN_TYPE_UID = EJJ.EXT_JOIN_TYPE_UID
	WHERE EJ.INTERFACE_UID IN (131310) -- 131310: K�Ba Personendaten
	AND EJ.ACTIVE = 1
) set_inactive
ON
(
	set_inactive.kuba_join_no = ext_join_update.JOIN_NO
)
WHEN MATCHED THEN 
	UPDATE SET ext_join_update.ACTIVE = 0
;


-- -----------------------------------------------------------
-- 4.
-- Update: Setzt IS_ACTIVE = 0 f�r K�Ba Personen in BSI_PERSON
-- -----------------------------------------------------------
--
MERGE INTO BSI_PERSON person_updt
USING
(
	SELECT DISTINCT
		PRS.PERSON_NR person_number
	FROM BSI_PERSON prs
		INNER JOIN BSICRM.BSI_X_EXT_JOIN_JOIN ejj
			INNER JOIN BSICRM.BSI_X_EXT_JOIN ej 
			ON EJ.EXT_JOIN_NR = EJJ.EXT_JOIN_NR
			AND EJ.EXT_JOIN_TYPE_UID = EJJ.EXT_JOIN_TYPE_UID
		ON EJJ.JOIN_NR = PRS.PERSON_NR
	WHERE EJ.INTERFACE_UID IN (131310) -- 131310: K�Ba Personendaten
	AND PRS.IS_ACTIVE = 1
) set_inactive
ON 
(
	set_inactive.person_number = person_updt.PERSON_NR
)
WHEN MATCHED THEN
	UPDATE SET person_updt.IS_ACTIVE = 0
;



-- ------------------------------------------
-- Zur�cksetzen von K�ba Personen auf ACTIVE = 1
-- in  BSI_X_EXT_JOIN 
-- und BSI_PERSON
-- ------------------------------------------
--
-- --------------------------------
-- Set active = 1 in BSI_X_EXT_JOIN 
-- --------------------------------
--
MERGE INTO BSICRM.BSI_X_EXT_JOIN ext_join_reset
USING 
(
	SELECT BSI_X_EXT_JOIN__JOIN_NO FROM BSICRM_EXT.BSI_X_KUBA_PERSONS_JOIN
) reset_active
ON
(
	reset_active.BSI_X_EXT_JOIN__JOIN_NO = ext_join_reset.JOIN_NO
)
WHEN MATCHED THEN 
	UPDATE SET ext_join_reset.ACTIVE = 1
;

-- ----------------------------
-- Set active = 1 in BSI_PERSON 
-- ----------------------------
--
MERGE INTO BSICRM.BSI_PERSON person_reset 
USING 
(
	SELECT BSI_PERSON__PERSON_NR 
	FROM BSICRM_EXT.BSI_X_KUBA_PERSONS_JOIN
	WHERE BSI_PERSON__PERSON_NR IS NOT NULL
) reset_active
ON
(
	reset_active.BSI_PERSON__PERSON_NR = person_reset.PERSON_NR
)
WHEN MATCHED THEN 
	UPDATE SET person_reset.ACTIVE = 1
;
