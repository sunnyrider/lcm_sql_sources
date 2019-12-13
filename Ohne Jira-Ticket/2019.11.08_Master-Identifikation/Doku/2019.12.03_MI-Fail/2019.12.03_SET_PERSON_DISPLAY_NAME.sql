Message: 
03.12.2019 02:29:48 --> set_master_person 
ORA-06512: at "BSICRM.SET_PERSON_DISPLAY_NAME", line 1 
ORA-06512: at "BSICRM.BSI_LOCAL_CH", line 4534 ; 
ORA-06502: PL/SQL: numeric or value error: character string buffer too small 
ORA-06512: at "BSICRM.SET_PERSON_DISPLAY_NAME", line 1


set_master_person 
ORA-06512: at "BSICRM.SET_PERSON_DISPLAY_NAME", line 1
ORA-06512: at "BSICRM.BSI_LOCAL_CH", line 4534; 
ORA-06502: PL/SQL: numeric or value error: character string buffer too small
ORA-06512: at "BSICRM.SET_PERSON_DISPLAY_NAME", line 1


create or replace
PROCEDURE SET_PERSON_DISPLAY_NAME (P_PERSON_NR IN NUMBER) IS
	v_company_names VARCHAR(250) := NULL;
	v_display_name VARCHAR(250) := NULL;
	v_length NUMBER;
BEGIN
	/* select company names */
	SELECT (p.last_name || ', ' || p.first_name) INTO v_display_name 
		FROM bsi_person p WHERE p.person_nr = P_PERSON_NR;

	SELECT SUBSTR(LISTAGG(c.display_name , ', ') within 
			GROUP(ORDER BY c.display_name), 0, 250
		) INTO v_company_names
	FROM bsi_company c JOIN bsi_company_person cp ON c.company_nr = cp.company_nr
	AND cp.person_nr = P_PERSON_NR
	WHERE cp.role_uid IN (
		SELECT company_person_role_uid FROM bsi_uc_company_person_role uccpr
		WHERE uccpr.is_use_for_display_name = 1);

		SELECT length(v_company_names) into v_length from dual;

		IF (v_length > 249) THEN 
			SELECT (substr(v_company_names, 0, 246) || '...') INTO v_company_names FROM dual;
		END IF;

		IF (v_company_names IS NOT NULL) THEN
			SELECT SUBSTR((v_display_name || ' (' || v_company_names || ')'), 0, 250) INTO v_display_name FROM dual;
		ELSE
			SELECT SUBSTR((v_display_name || ' (' || p.person_no || ')'), 0, 250) INTO v_display_name 
			FROM bsi_person p WHERE p.person_nr = P_PERSON_NR;
		END IF;
		
		SELECT length(v_display_name) into v_length from dual;
		
		IF (v_length > 249) THEN
			SELECT (substr(v_display_name, 0, 246) || '...') INTO v_display_name FROM dual;
		END IF;

		UPDATE bsi_person p SET p.display_name = v_display_name, p.company_display_names = v_company_names WHERE p.person_nr = P_PERSON_NR;
END; 