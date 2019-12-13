SELECT 
	MIN(UC_UID)
FROM (
SELECT 
	UC.UC_UID
FROM BSI_UC_TEXT uct
	INNER JOIN BSI_UC uc ON UC.UC_UID = UCT.UC_UID
WHERE CODE_TYPE = 45831
AND UCT.LANGUAGE_UID = 246
AND lower(TRIM(REPLACE(REPLACE(UCT.TEXT, '.', ''), ' ', ''))) = (
	SELECT 
		lower(TRIM(REPLACE(REPLACE(IUCT.TEXT, '.', ''), ' ', ''))) 
	FROM BSI_UC_TEXT iuct 
	WHERE IUCT.UC_UID = 3088753255 
	AND IUCT.LANGUAGE_UID = 246)
)
;

SELECT lower(TRIM(REPLACE(REPLACE(IUCT.TEXT, '.', ''), ' ', ''))) FROM BSI_UC_TEXT iuct 
	WHERE IUCT.UC_UID = 3088753255 
	AND IUCT.LANGUAGE_UID = 246
;

CREATE OR REPLACE FUNCTION GET_STEP_UID_MIN_VALUE (step_uid_in in bsi_uc_step.step_uid%type)
    RETURN NUMBER 
IS
    minuid bsi_uc_step.step_uid%type;
BEGIN
    SELECT 
      MIN(UC_UID) into minuid
    FROM (
        SELECT
            UC.UC_UID
        FROM BSI_UC_TEXT uct
            INNER JOIN BSI_UC uc ON UC.UC_UID = UCT.UC_UID
        WHERE CODE_TYPE = 45831
        AND UCT.LANGUAGE_UID = 246
        AND lower(TRIM(REPLACE(REPLACE(UCT.TEXT, '.', ''), ' ', ''))) = 
        (
            SELECT 
                lower(TRIM(REPLACE(REPLACE(IUCT.TEXT, '.', ''), ' ', ''))) 
            FROM BSI_UC_TEXT iuct 
            WHERE IUCT.UC_UID = step_uid_in 
            AND IUCT.LANGUAGE_UID = 246
        )
    );

    RETURN minuid;
END GET_STEP_UID_MIN_VALUE
;

SELECT GET_STEP_UID_MIN_VALUE(5384358638) FROM dual
;
