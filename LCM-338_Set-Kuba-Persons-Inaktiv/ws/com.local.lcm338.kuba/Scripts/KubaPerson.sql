SELECT
	COUNT(DISTINCT CPS.PERSON_NR) AS kuba_personen
FROM BSI_X_EXT_KUBA_DATA kbd 
	INNER JOIN BSI_X_EXT_JOIN_JOIN ejj
		INNER JOIN BSI_X_EXT_JOIN ej ON EJ.EXT_JOIN_NR = EJJ.EXT_JOIN_NR
		AND EJ.EXT_JOIN_TYPE_UID = EJJ.EXT_JOIN_TYPE_UID
	INNER JOIN BSI_COMPANY_PERSON cps
		INNER JOIN BSI_PERSON prs ON PRS.PERSON_NR = CPS.PERSON_NR
		AND PRS.IS_ACTIVE = 1
		INNER JOIN BSI_X_EXT_JOIN_JOIN pjj 
			INNER JOIN BSI_X_EXT_JOIN pj ON PJ.EXT_JOIN_NR = PJJ.EXT_JOIN_NR
			AND PJ.EXT_JOIN_TYPE_UID = 108236  -- External Person
		ON PJJ.JOIN_NR = CPS.PERSON_NR
	ON CPS.COMPANY_NR = EJJ.JOIN_NR
	ON EJJ.EXT_JOIN_NR = KBD.JOIN_NR
WHERE EJ.ACTIVE = 1
AND EJ.INTERFACE_UID = 131309 -- K�ba
AND EJ.EXT_JOIN_TYPE_UID = 108224  -- External Company
;
-- 263996

SELECT
	COUNT(DISTINCT CPS.PERSON_NR) AS personen_zu_firma
FROM BSI_X_EXT_JOIN_JOIN ejj
	INNER JOIN BSI_X_EXT_JOIN ej ON EJ.EXT_JOIN_NR = EJJ.EXT_JOIN_NR
	AND EJ.EXT_JOIN_TYPE_UID = EJJ.EXT_JOIN_TYPE_UID
	INNER JOIN BSI_COMPANY_PERSON cps
		INNER JOIN BSI_PERSON prs ON PRS.PERSON_NR = CPS.PERSON_NR
		AND PRS.IS_ACTIVE = 1
		INNER JOIN BSI_X_EXT_JOIN_JOIN pjj 
			INNER JOIN BSI_X_EXT_JOIN pj ON PJ.EXT_JOIN_NR = PJJ.EXT_JOIN_NR
			AND PJ.EXT_JOIN_TYPE_UID = 108236  -- External Person
		ON PJJ.JOIN_NR = CPS.PERSON_NR
	ON CPS.COMPANY_NR = EJJ.JOIN_NR
WHERE EJ.ACTIVE = 1
AND EJ.EXT_JOIN_TYPE_UID = 108224  -- External Company
;



SELECT
	COUNT(DISTINCT KBD.JOIN_NR) AS Anzahl
--	KBD.JOIN_TYPE_UID,
--	KBD.JOIN_NR,
--	EJ.JOIN_NO
FROM BSI_X_EXT_KUBA_DATA kbd 
	INNER JOIN BSI_X_EXT_JOIN_JOIN ejj
		INNER JOIN BSI_X_EXT_JOIN ej 
		ON EJ.EXT_JOIN_NR = EJJ.EXT_JOIN_NR
		AND EJ.EXT_JOIN_TYPE_UID = EJJ.EXT_JOIN_TYPE_UID
	ON EJJ.EXT_JOIN_NR = KBD.JOIN_NR
WHERE EJ.ACTIVE = 1
;
-- 362357