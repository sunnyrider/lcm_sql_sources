create or REPLACE package bsicrm_ext.export_salesforce_pkg AS


PROCEDURE lcm_complex_places;
/*******************************************************************************
*
* c o m p l e x   p l a c e s
*
* LCM-340: Selektion Complex_No und "Places-No" aus S2_EM_PRODUCT_CONDENSED_IN
*
*******************************************************************************/


PROCEDURE lcm_complaints;
/*******************************************************************************
*
* c o m p l a i n t s
*
* LCM-328: Selektion Communication bei Cases
*
*******************************************************************************/


PROCEDURE lcm_cases;
/*******************************************************************************
*
* c a s e s
*
* LCM-331: Selektion Communication bei Cases
*
*******************************************************************************/


PROCEDURE lcm_contacts;
/*******************************************************************************
*
* c o n t a c t s
*
* LCM-285: Selektion Personen von Firmen
*
*******************************************************************************/


PROCEDURE lcm_structure;
/*******************************************************************************
*
* s t r u c t u r e
*
* LCM-282: Export f�r Strukturen
*
*******************************************************************************/


PROCEDURE lcm_billingprofile;
/*******************************************************************************
*
* b i l l i n g p r o f i l e
*
* LCM-302: Selektion f�r Billing Adressen
*
*******************************************************************************/


PROCEDURE lcm_accounts_leads;
/*******************************************************************************
*
* l e a d s
*
* LCM-292: lcm_accounts_leads selektieren 
*
*******************************************************************************/


PROCEDURE lcm_accounts_nx;
/*******************************************************************************
*
* a c c o u n t s _ n x
*
* LCM-294: Selektion f�r Accounts NX
*
*******************************************************************************/


PROCEDURE lcm_accounts_samba;
/*******************************************************************************
*
* a c c o u n t s _ s a m b a
*
* LCM-294: Selektion f�r Accounts SAMBA
*
*******************************************************************************/


PROCEDURE main;
/*******************************************************************************
*
* m a i n
*
* f�hrt alle Prozeduren der Reihe nach aus.
*
*******************************************************************************/

END export_salesforce_pkg;
/

CREATE OR REPLACE PACKAGE body bsicrm_ext.export_salesforce_pkg as
	vCntrlFilecsv utl_file.file_type;
	buffer_size constant binary_integer := 32760;
	vFileNamecsv varchar2(200);
	vDirectoryPath constant varchar2(100) := 'SF_EXPORT';
	c_Charakterset_DB constant varchar2(30) := 'UTF8';
	c_Charakterset_Out constant varchar2(30) := 'AL32UTF8'; -- UTF8
	vTextLine varchar2(8000);
	vErrorText varchar2(4000);
	h number;
	cr constant varchar2(1) := chr(13); -- Carriage Return


	PROCEDURE lcm_complex_places IS
	BEGIN
		h := 0;

		SELECT 'lcm_complex_places_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;

		dbms_output.put_line('Export lcm_complex_places, FileName '||vFileNamecsv);

		vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

		vTextLine := 'x_complex_no,place_id';
				
		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);  -- Schreibpuffer leeren

		FOR r IN 
			(
			SELECT
				CMP.X_COMPLEX_NO x_complex_no,
				SEMP."NO" place_id
			FROM S2_EM_PRODUCT_CONDENSED_IN semp 
			INNER JOIN BSI_COMPANY cmp
				INNER JOIN BSI_X_EXT_JOIN_JOIN ejj 
					INNER JOIN BSI_X_EXT_JOIN ej 
					ON EJ.EXT_JOIN_NR = EJJ.EXT_JOIN_NR
					AND EJ.EXT_JOIN_TYPE_UID = EJJ.EXT_JOIN_TYPE_UID
				ON EJJ.JOIN_NR = CMP.COMPANY_NR
			ON EJJ.JOIN_NO = SEMP.NXCUSTOMERID
		)
		LOOP

		vTextLine := REPLACE('"' || r.x_complex_no || '","'
				|| r.place_id
				|| '"','""')||cr;
                 
			utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
			utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren
  
			h := h + 1;

		END LOOP;
  
		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl lcm_complex_places: '||to_char(h));

	EXCEPTION WHEN OTHERS THEN
			vErrorText := 'Fehler bei lcm_complex_places: '||sqlerrm;
			dbms_output.put_line(vErrorText);
	END lcm_complex_places;


	------------------------------
	-- PROCEDURE lcm_complaints --
	------------------------------
	--
	PROCEDURE lcm_complaints IS
	BEGIN
		h := 0;

		SELECT 'lcm_complaints_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;

		dbms_output.put_line('Export lcm_complaints, FileName '||vFileNamecsv);

		vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

		vTextLine := 'x_complex_no,ClosedDate,description,Closed,case_reason,record_type_id,Status,subject,Company,name,case_type,LCM_Complaint_Number,lcm_solution,LCM_Contact_person,Created_in_LCM,Owner_lcm';
				
		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);  -- Schreibpuffer leeren

		FOR r IN 
			(
			SELECT DISTINCT
				CMP.X_COMPLEX_NO Account_id,
				CASE WHEN XCPL.EVT_FINISHED IS NOT NULL THEN 
					to_char(XCPL.EVT_FINISHED, 'dd.mm.yyyy') 
				ELSE ''
				END ClosedDate,
			
				dbms_lob.substr(XCPL.DESCRIPTION, 3000, 1) description,
				1 Closed,
			
				CASE WHEN uc_cp_cat.text IS NOT NULL THEN 
					UPPER(uc_cp_cat.text) 
				ELSE 'NONE'
				END case_reason,
			
				'COMPLAINT' record_type_id,
				'Closed' Status,
				XCPL.SUBJECT subject,
				CMP.COMPANY_NO Company,
			
				CASE WHEN upper(CMP.NAME1) NOT LIKE 'UNBEKANNT%' 
					AND trim(CMP.NAME1) NOT IN ('$','*','**','*/',',,','-','--','---','-.',':',';','?','??','^','�',':','-','0','00')
					AND CMP.NAME1 NOT LIKE '%?%' THEN
						REPLACE(REPLACE(REPLACE(CMP.NAME1, chr(13), ' '),
							chr(9), ' '), 
							chr(32), ' ')
				ELSE ''
				END name,
				'Problem' case_type,
				XCPL.COMPLAINT_NO LCM_Complaint_Number, 
				CASE WHEN XCPL.SOLUTION_NOTES IS NOT NULL THEN
					dbms_lob.substr(XCPL.SOLUTION_NOTES, 3500, 1)
				ELSE
					NULL
				END lcm_solution,
			
				XCPL.PERSON_NR LCM_Contact_person,
				to_char(XCPL.EVT_ISSUED, 'dd.mm.yyyy') Created_in_LCM,
			
				CASE WHEN prs_responsible.FIRST_NAME IS NOT NULL THEN
					prs_responsible.FIRST_NAME || ' ' || prs_responsible.LAST_NAME
				WHEN prs_responsible.LAST_NAME IS NULL THEN
					''
				ELSE
					prs_responsible.LAST_NAME
				END Owner_lcm
			FROM BSI_X_COMPLAINT xcpl 
				INNER JOIN BSI_X_EXT_JOIN_JOIN ejj 
					INNER JOIN BSI_X_EXT_JOIN ej ON EJ.EXT_JOIN_NR = EJJ.EXT_JOIN_NR
						AND EJ.EXT_JOIN_TYPE_UID = EJJ.EXT_JOIN_TYPE_UID
						AND EJ.ACTIVE = 1
					INNER JOIN BSI_COMPANY cmp ON CMP.COMPANY_NR = EJJ.JOIN_NR
				ON EJJ.JOIN_NR = XCPL.COMPANY_NR
				LEFT JOIN BSI_UC_TEXT uc_cp_cat ON uc_cp_cat.UC_UID = XCPL.COMPLAINT_CATEGORY_UID AND uc_cp_cat.LANGUAGE_UID = 1303
				LEFT JOIN BSI_PERSON prs_responsible ON prs_responsible.PERSON_NR = XCPL.RESPONSIBLE_USER_NR
			WHERE XCPL.COMPANY_NR IS NOT NULL
			--109053	Abgeschlossen
			--119170	Abgeschlossen
			--109056	Abkl�rung erledigt
			AND XCPL.STATUS_UID IN (119170, 109053, 109056)
			AND XCPL.EVT_ISSUED > to_date('31.12.2014', 'dd.mm.yyyy')
		)
		LOOP

		vTextLine := REPLACE('"' || r.x_complex_no || '","'
				|| r.ClosedDate || '","'
				|| r.description || '","'
				|| r.Closed || '","'
				|| r.case_reason || '","'
				|| r.record_type_id || '","'
				|| r.Status || '","'
				|| r.subject || '","'
				|| r.Company || '","'
				|| r.name || '","'
				|| r.case_type || '","'
				|| r.LCM_Complaint_Number || '","'
				|| r.lcm_solution || '","'
				|| r.LCM_Contact_person || '","'
				|| r.Created_in_LCM || '","'
				|| r.Owner_lcm || '"','""')||cr;
                 
			utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
			utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren
  
			h := h + 1;

		END LOOP;
  
		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl lcm_complaints: '||to_char(h));

	EXCEPTION WHEN OTHERS THEN
			vErrorText := 'Fehler bei lcm_complaints: '||sqlerrm;
			dbms_output.put_line(vErrorText);
	END lcm_complaints;


	-------------------------
	-- PROCEDURE lcm_cases --
	-------------------------
	--
	PROCEDURE lcm_cases IS
	BEGIN
		h := 0;

		SELECT 'lcm_cases_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;

		dbms_output.put_line('Export lcm_cases, FileName '||vFileNamecsv);

		vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

		vTextLine := 'x_complex_no,closed_date,contact_email,contact_fax,contact_mobile,contact_phone,created_date,closed,case_origin,case_reason,record_type,Status,subject,company,name,LCM_Contact_Number,LCM_User_opened_Case,LCM_User_closed_CASE,case_number,LCM_Communcation_Text,LCM_Document_link';
				
		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);  -- Schreibpuffer leeren

		FOR r IN 
			(
			WITH preselect AS
			(
				SELECT 
					CSE.CASE_NO,
					CSE.EVT_START,
					CSE.EVT_END,
					CSE.PERSON_NR,
					CSE.CREATE_USER_NR,
					CSE.X_CLOSE_USER_NR,
					CSE.PROCESS_UID,
					CSE.CHANNEL_UID,
					CSE.EMAIL_ADDRESS,
					CSE.FAX_NO,
					CSE.PHONE_NO,
					CMP.COMPANY_NO,
					CMP.COMPANY_NR,
					CMP.NAME1,
					CMP.X_COMPLEX_NO,
					CMC.COMMUNICATION_NR
				FROM BSICRM.BSI_CASE CSE
				INNER JOIN BSICRM.BSI_COMMUNICATION cmc ON CMC.CASE_FRAME_NR = CSE.CASE_FRAME_NR
					AND CMC.COMPANY_NR = CSE.X_COMPANY_NR
					AND CMC.PERSON_NR = CSE.PERSON_NR
				INNER JOIN BSI_COMPANY CMP ON CMP.COMPANY_NR = CSE.X_COMPANY_NR
				WHERE CSE.STATUS_UID IN (75959)  -- 75959 = Erledigt
				AND CMC.STATUS_UID IN (3513) -- 3513 = Stattgefunden
				AND CSE.X_COMPANY_NR IS NOT NULL
				AND CMP.IS_ACTIVE = 1
				AND CSE.CASE_FRAME_NR <> 0
				AND CSE.PROCESS_UID IN (3271703167, 3364612471, 3457763423, 3518482663, 3903314563, 4573005984, 4619699490, 4649764515, 4782164448, 4903308050, 5534726020, 6153389064, 5711045652, 3131025257, 4619700070, 4706762231, 4782164944, 2688964652, 3047541964, 3094668432, 3154736125, 3162135263, 3246632451, 3248098401, 3271705741, 3358401160, 3364611653, 3415639805, 3427645687, 3433668575, 3591522861, 3710251082, 3952232775, 4024149816, 4095429139, 4630654440, 4638986737, 4646089574, 4712866075, 4713705468, 4764468044, 4782163534, 4787447533, 4794588216, 5066602830, 5101763956, 5287849485, 5103195620, 3246631781, 3248098729, 3271705289, 3358401180, 3364611812, 3415640007, 3764640108, 3884749475, 4619691301, 4782163837, 5633686312, 3271705003, 3352157897, 3364612033, 3415708718, 3865386891, 3884749911, 4619691650, 4778221848, 4782164116, 4829182466, 5066602935, 4134383211, 4619699944, 4621318064, 2688964540, 2847386718, 3088753210, 3094668805, 3147379058, 3155112657, 3155114345, 3246633045, 3248098180, 3271701823, 3309920750, 3352157504, 3364245583, 3370649185, 3506391142, 4062705492, 4075411069, 4619690681, 4666159355, 4716064382, 4718185893, 4782162934, 4802857134, 4941756622, 4944311981, 4944317028, 4944318103, 4953220772, 5066602515, 5136868645, 5444427351, 5473362210, 5569325738, 5585549221, 5625231602, 7558734381, 2688964630, 3060265849, 3101858194, 3147378127, 3246997948, 3248098162, 3309921348, 3352157327, 3364611466, 3370648168, 3370660213, 3415639786, 3699823137, 4062706692, 4062708486, 4062712813, 4619691059, 4782163304, 4802856926, 5728609230, 5968070800, 6070610402, 6250380643, 6850542692, 7158342373, 6250378505, 6913132406, 7268911495, 2688965518, 3309921038, 3358401539, 3364612524, 4619699567, 6265265078, 3047542100, 6148086566, 6185609647, 6321752985, 7289764726, 7404701111, 6058918625, 6100817724, 5661727298, 6609779492, 6850542622, 5268361607, 6505974925, 6114808518, 6135719421, 6151750332, 6223405054, 6306026950, 6906208213)
				-- '31.12.2014'
				AND CSE.EVT_START > TO_DATE('31.12.2017', 'dd.mm.yyyy')
				ORDER BY CSE.X_COMPANY_NR, CSE.CASE_NO, CMC.COMMUNICATION_NR
			),
			document_sel AS 
			(
				SELECT
					BDOC.ITEM_KEY0_NR,
					BDOC.X_LOCATION_LOB
				FROM BSI_DOCUMENT bdoc
			)
			SELECT
				PSEL.X_COMPLEX_NO x_complex_no,
				to_char(PSEL.EVT_END, 'dd.mm.yyyy') closed_date,
				PSEL.EMAIL_ADDRESS contact_email,
				PSEL.FAX_NO contact_fax,
		
				CASE WHEN PSEL.PHONE_NO LIKE '%+4175%' 
					OR PSEL.PHONE_NO LIKE '%+4176%'  
					OR PSEL.PHONE_NO LIKE '%+4177%'  
					OR PSEL.PHONE_NO LIKE '%+4178%'  
					OR PSEL.PHONE_NO LIKE '%+4179%' THEN  
					PSEL.PHONE_NO
				ELSE 
					NULL
				END contact_mobile,   
		
				CASE WHEN PSEL.PHONE_NO LIKE '%+4175%' 
					OR PSEL.PHONE_NO LIKE '%+4176%'  
					OR PSEL.PHONE_NO LIKE '%+4177%' 
					OR PSEL.PHONE_NO LIKE '%+4178%' 
					OR PSEL.PHONE_NO LIKE '%+4179%'  THEN
					NULL
				ELSE 
					PSEL.PHONE_NO           
				END contact_phone,
		
				to_char(PSEL.EVT_START, 'dd.mm.yyyy') created_date,
		
				1 closed,
				uc_origin.TEXT case_origin,
				uc_process.text case_reason,
				CASE WHEN uc_process.text = 'Beschwerde' THEN
					'Beschwerde'
				ELSE
					'other'
				END record_type,
				'Closed' Status,
				CMC.DISPLAY_NAME subject,
				PSEL.COMPANY_NO company,
				REPLACE(PSEL.NAME1, chr(13), '') name,
				PSEL.PERSON_NR LCM_Contact_Number,
				CASE WHEN prsopen.FIRST_NAME IS NOT NULL THEN 
					REPLACE(REPLACE(prsopen.FIRST_NAME,'"',''''),'''''','''')
					|| ' ' || 
					REPLACE(REPLACE(prsopen.LAST_NAME,'"',''''),'''''','''')
				WHEN prsopen.LAST_NAME IS NULL THEN
					''
				ELSE 
					REPLACE(REPLACE(prsopen.LAST_NAME,'"',''''),'''''','''')
				END LCM_User_opened_Case,
				CASE WHEN prsclose.FIRST_NAME IS NOT NULL THEN 
					REPLACE(REPLACE(prsclose.FIRST_NAME,'"',''''),'''''','''')
					|| ' ' || 
					REPLACE(REPLACE(prsclose.LAST_NAME,'"',''''),'''''','''')
				WHEN prsclose.LAST_NAME IS NULL THEN
					''
				ELSE 
					REPLACE(REPLACE(prsclose.LAST_NAME,'"',''''),'''''','''')
				END LCM_User_closed_CASE,
		
				PSEL.CASE_NO case_number,
		
				CASE WHEN CMC.TEXT_LOB IS NOT NULL THEN
					dbms_lob.substr(CMC.TEXT_LOB, 1000, 1)
				ELSE
					NULL
				END LCM_Communcation_Text_Part1,
				CASE WHEN CMC.TEXT_LOB IS NOT NULL AND DBMS_LOB.GETLENGTH(CMC.TEXT_LOB) > 1000 THEN
					dbms_lob.substr(CMC.TEXT_LOB, 1000, 1001)
				ELSE 
					NULL
				END LCM_Communcation_Text_Part2,
				CASE WHEN CMC.TEXT_LOB IS NOT NULL AND DBMS_LOB.GETLENGTH(CMC.TEXT_LOB) > 2000 THEN
					dbms_lob.substr(CMC.TEXT_LOB, 1000, 2001)
				ELSE 
					NULL
				END LCM_Communcation_Text_Part3,
				CASE WHEN CMC.TEXT_LOB IS NOT NULL AND DBMS_LOB.GETLENGTH(CMC.TEXT_LOB) > 3000 THEN
					dbms_lob.substr(CMC.TEXT_LOB, 1000, 3001)
				ELSE 
					NULL
				END LCM_Communcation_Text_Part4,
		
				(
					SELECT 
						SUBSTR(LISTAGG(DSEL.X_LOCATION_LOB, '||') within GROUP(ORDER BY DSEL.X_LOCATION_LOB), 0, 3000)
					FROM document_sel dsel
					WHERE DSEL.ITEM_KEY0_NR = CMC.COMMUNICATION_NR
				) LCM_Document_link
			FROM preselect PSEL
				INNER JOIN BSICRM.BSI_COMMUNICATION cmc ON CMC.COMMUNICATION_NR = PSEL.COMMUNICATION_NR 
				INNER JOIN BSICRM.BSI_UC_TEXT uc_origin ON uc_origin.UC_UID = PSEL.CHANNEL_UID AND uc_origin.LANGUAGE_UID = 1303
				INNER JOIN BSICRM.BSI_PERSON prsopen ON prsopen.PERSON_NR = PSEL.CREATE_USER_NR
				INNER JOIN BSICRM.BSI_PERSON prsclose ON prsclose.PERSON_NR = PSEL.X_CLOSE_USER_NR
				INNER JOIN BSICRM.BSI_UC_TEXT uc_process ON uc_process.UC_UID = PSEL.PROCESS_UID AND uc_process.LANGUAGE_UID = 246
			-- 105356 = Marketing, 143891 = National Report
			WHERE CMC.ORIGIN_UID NOT IN (105356, 143891)
			AND PSEL.PHONE_NO IS NOT NULL
			)
		LOOP

		vTextLine := REPLACE('"' || r.x_complex_no || '","' 
				|| r.closed_date || '","' 
				|| r.contact_email || '","' 
				|| r.contact_fax || '","' 
				|| r.contact_mobile || '","' 
				|| r.contact_phone || '","' 
				|| r.created_date || '","' 
				|| r.closed || '","' 
				|| r.case_origin || '","' 
				|| r.case_reason || '","' 
				|| r.record_type || '","' 
				|| r.Status || '","' 
				|| r.subject || '","' 
				|| r.company || '","' 
				|| r.name || '","' 
				|| r.LCM_Contact_Number || '","' 
				|| r.LCM_User_opened_Case || '","' 
				|| r.LCM_User_closed_CASE || '","' 
				|| r.case_number || '","'
				|| REPLACE(REPLACE(r.LCM_Communcation_Text_Part1,'"',''''),'''''','''')
				|| REPLACE(REPLACE(r.LCM_Communcation_Text_Part2,'"',''''),'''''','''')
				|| REPLACE(REPLACE(r.LCM_Communcation_Text_Part3,'"',''''),'''''','''')
				|| REPLACE(REPLACE(r.LCM_Communcation_Text_Part4,'"',''''),'''''','''') || '","' 
				|| r.LCM_Document_link || '"','""') ||cr;
                 
			utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
			utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren
  
			h := h + 1;

		END LOOP;
  
		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl lcm_cases: '||to_char(h));

	EXCEPTION WHEN OTHERS THEN
			vErrorText := 'Fehler bei lcm_cases: '||sqlerrm;
			dbms_output.put_line(vErrorText);
	END lcm_cases;


	----------------------------
	-- PROCEDURE lcm_contacts --
	----------------------------
	--
	PROCEDURE lcm_contacts IS
	BEGIN

		h := 0;

		SELECT 'LCM_contacts_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;

		dbms_output.put_line('Export lcm_contacts, FileName '||vFileNamecsv);

		vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

		vTextLine := 'uk_LCM_X_COMPLEX_NO,uk_LCM_PERSON_NR,Salutation,Title,FirstName,LastName,Phone,MobilePhone,Fax,Email,PreferedLanguage__c,MailingStreet,MailingPostalCode,MailingCity,MailingState,MailingCountry';
				
		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);  -- Schreibpuffer leeren

		for r in (
			SELECT /*+ ordered use_hash(company ej ejj p ba city t2) full(company) full(ej) full(ejj) full(p) full(ba) full(city) full(t2) */
				distinct company.x_complex_no uk_LCM_X_COMPLEX_NO,  -- lcm_contacts
				c.person_nr uk_LCM_PERSON_NR, 
				DECODE (c.salutation_uid, 3193, 'Herr', 3194, 'Frau') salutation, -- nur Herr oder Frau liefern
				trim(c.title) Title, 
				c.firstname FirstName, 
				c.lastname LastName, 
				c.phone Phone, 
				c.mobilephone MobilePhone, 
				c.fax Fax, 
				c.email Email, 
				t2.text PreferedLanguage__c,
				ba.postal_display_street MailingStreet, 
				city.zip_code MailingPostalCode, 
				city.city MailingCity, 
				city.state MailingState, 
				CASE city.country_uid 
					WHEN 1001119 THEN '�sterreich' 
					WHEN 1001148 THEN 'Schweiz' 
					WHEN 1001161 THEN 'Deutschland' 
					WHEN 1001179 THEN 'Frankreich' 
					WHEN 1001215 THEN 'Italien' 
					WHEN 1001234 THEN 'Liechtenstein' 
				END MailingCountry
			FROM (
				SELECT /*+ ordered use_hash(cp_join ps t ae ap am af) full(cp_join) full(ps) full(t) full(ae) full(ap) full(am) full(af) */
					cp_join.company_nr, 
					RTRIM (TRIM(ps.first_name),chr(9)) firstname, 
					RTRIM (trim(ps.last_name),chr(9)) lastname, 
					max (ps.salutation_uid) salutation_uid, 
					max (ps.person_nr) person_nr, 
					max (ps.title) title, 
					max (ae.channel_value) email, 
					max (
						CASE WHEN substr(ap.channel_value,1,5) not in ('+4175','+4176','+4177','+4178','+4179') THEN 
							ap.channel_value 
						END
					) phone, 
					max (
						NVL(am.channel_value, 
							CASE WHEN SUBSTR(ap.channel_value,1,5) in ('+4175','+4176','+4177','+4178','+4179') THEN 
								ap.channel_value 
							END)
					) mobilephone, 
					max (af.channel_value) fax, 
					max (ps.language_uid) language_uid 
				FROM bsicrm.bsi_company_person cp_join
					JOIN bsicrm.bsi_person ps on ps.person_nr = cp_join.person_nr
					LEFT JOIN bsicrm.bsi_address ae on ae.item_key0_nr = ps.person_nr AND ae.channel_uid = 113641 AND ae.is_default_address != 0
					LEFT JOIN bsicrm.bsi_address ap on ap.item_key0_nr = ps.person_nr AND ap.channel_uid = 113638 AND ap.is_default_address != 0
					LEFT JOIN bsicrm.bsi_address am on am.item_key0_nr = ps.person_nr AND am.channel_uid = 113640 AND am.is_default_address != 0
					LEFT JOIN bsicrm.bsi_address af on af.item_key0_nr = ps.person_nr AND af.channel_uid = 113639 AND af.is_default_address != 0
				WHERE ps.is_active = 1  -- AND ps.person_nr in ( 4592605225,4675227030,4600035730,4629016440,4889135439,5076605797,5403113120,5095674409,5318291875,5327511550,5344424491,5128955035,5061706306,5095671012,4903311024,5594930965,5419169318,5799814489,6485814097,6079746251)
					AND ps.last_name not like '.%'
					AND upper(ps.last_name) not like 'UNBEKANNT%'
					AND RTRIM (trim(ps.last_name),chr(9))||RTRIM (TRIM(ps.first_name),chr(9)) is not null
					AND trim(ps.last_name) not in ('$','*','**','*/',',,','-','--','---','-.',':',';','?','??','^','�',':','-','0','00')
					AND ps.last_name not like '%?%'
				GROUP BY cp_join.company_nr, RTRIM (trim(ps.first_name),chr(9)), RTRIM (TRIM(ps.last_name),chr(9))
				) c
					JOIN bsicrm.bsi_company company on company.company_nr = c.company_nr
					JOIN bsicrm.bsi_x_ext_join ej on ej.join_no = company.company_no AND ej.interface_uid in (108187,108205)
					JOIN bsicrm.bsi_x_ext_join_join ejj on ejj.join_nr = company.company_nr
					LEFT JOIN (
						SELECT cc.company_nr 
							FROM bsicrm.bsi_company_company cc 
						union SELECT cc.group_company_nr 
							FROM bsicrm.bsi_company_company cc
					) cc on cc.company_nr = company.company_nr 
					LEFT JOIN bsicrm.bsi_x_ext_product p on p.join_nr = ejj.ext_join_nr 
					AND p.status_uid = 109307 
					AND p.type_uid in (1000408,1000409,1923083777,1923083778,1923083779,
						5684031909,6077978250,6077978180,6077978542,6077978285,
						1000415,1000419,1923083780,1923083781,1923083782,
						1923083783,1923083784,1923083785,5684031938,5684031911,
						6077978344,6599798156,6077978035,6599798005,6077978528,
						6599797809,6077978220,6599797644,1000427,1000428,
						1000429,1000623) -- 2G% / 2F%' / 2OS% / 2EH / 4NFZ
					LEFT JOIN bsicrm.bsi_address ba on ba.item_key0_nr = c.person_nr AND ba.channel_uid = 113688 AND ba.is_default_address != 0
					LEFT JOIN bsicrm.bsi_city city on city.city_nr = ba.city_nr
					LEFT JOIN bsicrm.bsi_uc_text t2 on t2.uc_uid = c.language_uid AND t2.language_uid = 1303
				WHERE company.is_active = 1  
					AND (ej.interface_uid = 108187   -- Parent von 108187 = 108185 (SAMBA) ist Master
					or ej.interface_uid = 108205  -- Parent von 108205 = 108186, (DSMP)
				AND p.join_nr is not null     -- DSMP ist Master und eine Firma im Komplex hat aktives Produkt EP
				or cc.company_nr is not null  -- Firma hat Firmenart "Konzern, Unternehmen, oder Filiale"
				)
				--  AND company.x_complex_no between TO_NUMBER(10006743) AND TO_NUMBER(16777014)
				-- for education data                  
			order by 1
		) LOOP
    
			vTextLine := REPLACE('"'||r.uk_LCM_X_COMPLEX_NO||'","'||r.uk_LCM_PERSON_NR||'","'||r.Salutation||'","'||r.Title||'","'||REPLACE(REPLACE(r.FirstName,'"',''''),'''''','''')||'","'||REPLACE(REPLACE(r.LastName,'"',''''),'''''','''')||'","'||r.Phone||'","'||r.MobilePhone||'","'||r.Fax||'","'||r.Email||'","'||r.PreferedLanguage__c||'","'||REPLACE(REPLACE(r.MailingStreet,'"',''''),'''''','''')||'","'||r.MailingPostalCode||'","'||r.MailingCity||'","'||r.MailingState||'","'||r.MailingCountry||'"','""')||cr;
                 
			utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
			utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren
  
			h := h + 1;

		END LOOP;
  
		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl lcm_contacts: '||to_char(h));

	EXCEPTION WHEN others THEN
			vErrorText := 'Fehler bei lcm_contacts: '||sqlerrm;
			dbms_output.put_line(vErrorText);
	END lcm_contacts;


	-----------------------------
	-- PROCEDURE lcm_structure --
	-----------------------------
	--
	PROCEDURE lcm_structure is
	BEGIN

		h := 0;

		SELECT 'LCM_Structure_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;
		--  vFileNamecsv := 'LCM_Structure.csv';

		dbms_output.put_line('Export lcm_structure, FileName '||vFileNamecsv);

		vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

		vTextLine := 'complex_no,complex_no_parent'||cr;   -- header
		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);  -- Schreibpuffer leeren

		for r in (
			SELECT 
				company.x_complex_no complex_no,
				co2.x_complex_no complex_no_parent
			FROM bsicrm.bsi_company_company cc 
				JOIN bsicrm.bsi_company company ON company.company_nr = cc.company_nr
				JOIN bsicrm.bsi_company co2 ON co2.company_nr = cc.group_company_nr
			WHERE company.is_active = 1  
			AND co2.is_active = 1
			-- AND company.x_complex_no between TO_NUMBER(10006743) AND TO_NUMBER(16777014)
			-- for education data                                 
			-- AND co2.x_complex_no between TO_NUMBER(10006743) AND TO_NUMBER(16777014)
			-- for education data                  
			order by 1
		) LOOP

		vTextLine := '"'||r.complex_no||'","'||r.complex_no_parent||'"'||cr;
		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren

		h := h + 1;

		END LOOP;

		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl Structures: '||to_char(h));

	EXCEPTION WHEN others THEN
		vErrorText := 'Fehler bei lcm_structure: '||sqlerrm;
		dbms_output.put_line(vErrorText);
	END lcm_structure;


	----------------------------------
	-- PROCEDURE lcm_billingprofile --
	----------------------------------
	--
	PROCEDURE lcm_billingprofile is
	BEGIN

		h := 0;

		SELECT 'sd_billing_addresses_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;

		dbms_output.put_line('Export lcm_billingprofile, FileName '||vFileNamecsv);

		vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

		vTextLine := 'uk_LCM_X_COMPLEX_NO__c,Billing_City__c,Billing_Country__c,Billing_Language__c,Billing_Name__c,Billing_Postal_Code__c,Billing_State__c,Billing_Street__c,P_O_Box__c,P_O_BoxPostalCode__c,P_O_BoxCity__c,Mail_address__c,Name,Phone__c,MobilePhone__c,BillingAddressSAMBA-Key__c,BillingAddressNx-Key__c,Allowed_comm_channel__c,Communication_Channel__c'||cr;   -- header
		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);  -- Schreibpuffer leeren

		for r in (
			SELECT /*+ ordered use_hash(company t2 ejj ej a) full(company) full(t2) full(ejj) full(ej) full(a) */
			distinct company.x_complex_no uk_LCM_X_COMPLEX_NO__c,  -- lcm_billingprofile / Komplexnummer
			am.city Billing_City__c,  -- von Kunde Rechnungsadresse EP/WP
			CASE nvl(am.country_uid,amb.country_uidb) 
				WHEN 1001119 THEN '�sterreich' 
				WHEN 1001148 THEN 'Schweiz' 
				WHEN 1001161 THEN 'Deutschland' 
				WHEN 1001179 THEN 'Frankreich' 
				WHEN 1001215 THEN 'Italien' 
				WHEN 1001234 THEN 'Liechtenstein' 
			END Billing_Country__c,  -- von Kunde Rechnungsadresse EP/WP
			t2.text Billing_Language__c,  -- von Kunde zu Rechnungsadresse EP/WP
			nvl(
				ltrim(RTRIM (am.postal_additional_line1||' '||am.postal_additional_line2)),
				ltrim(RTRIM (amb.postal_additional_line1b||' '||amb.postal_additional_line2b))
			) Billing_Name__c, 
			am.zip_code Billing_Postal_Code__c, 
			nvl(am.state,amb.stateb) Billing_State__c, 
			am.postal_display_street Billing_Street__c,
			amb.postal_po_box_text P_O_Box__c,
			amb.zip_codeb P_O_BoxPostalCode__c,
			amb.cityb P_O_BoxCity__c, 
			sadr.email Mail_address__c,  
			REPLACE(company.name1, chr(13), '') Name,  
			sadr.phone Phone__c, 
			sadr.mobile MobilePhone__c,
			CASE WHEN ej.interface_uid = 108187 THEN 
				ej.join_no 
			END BillingAddressSAMBA_Key__c, -- 'Adresse'     -- von Kunde zu Rechnungsadresse EP/WP
			CASE WHEN ej.interface_uid = 108205 THEN 
				ej.join_no 
			END BillingAddressNx_Key__c, -- 'Kunde'    -- von Kunde zu Rechnungsadresse EP/WP
			COMPANY.IS_MAILING_DISABLED Allowed_comm_channel__c,
			CASE WHEN xcrpd.LETTER_CHANNEL_UID IN (128573, 128572) THEN 
				'Email'
			WHEN xcrpd.LETTER_CHANNEL_UID IN (128575, 128574, 128571) THEN 
				'Letter'
			WHEN xcrpd.LETTER_CHANNEL_UID = 0 THEN 
				'n.a.'
			END Communication_Channel__c
		FROM bsicrm.bsi_company company 
			LEFT JOIN bsicrm.bsi_uc_text t2 on t2.uc_uid = company.language_uid AND t2.language_uid = 1303
			JOIN bsicrm.bsi_x_ext_join_join ejj on ejj.join_nr = company.company_nr
			JOIN bsicrm.bsi_x_ext_join ej on ej.ext_join_nr = ejj.ext_join_nr    -- ? AND ej.ext_join_type_uid = ejj.join_type_uid
			LEFT JOIN BSICRM.BSI_X_CORRESPONDENCE xcrpd ON xcrpd.CUSTOMER_KEY0_NR = EJj.JOIN_NR
			LEFT JOIN (
				SELECT /*+ ordered use_hash(am au ba city) full(am) full(au) full(ba) full(city) */
					am.ext_join_nr, 
					ba.item_key0_nr, 
					ba.postal_display_street, 
					city.zip_code, 
					city.city, 
					city.country_uid, 
					city.state, 
					ba.postal_additional_line1, 
					ba.postal_additional_line2, 
					ba.address_nr, 
					ba.city_nr
				FROM bsicrm.bsi_x_address_mapping am 
					JOIN bsicrm.bsi_address_usage au on au.address_nr = am.address_nr 
						AND au.usage_uid in (121625,121810)  -- 121625 Rechnungsadresse WP / 121810 Rechnungsadresse EP      
					JOIN bsicrm.bsi_address ba on ba.address_nr = am.address_nr 
					JOIN bsicrm.bsi_city city on city.city_nr = ba.city_nr
				WHERE ba.channel_uid = 113688    -- Anschrift
				-- 2315:	Hauptadresse
				-- 108363:	Korrespondenz mutiert durch User ODER Korrespondenzadresse EP
				-- 108240:	Hauptadresse (Postfach)
				-- 108364:	Korrespondenz mutiert durch User ODER Korrespondenzadresse EP (Postfach)
				AND am.type_uid not in (2315,108363,108240,108364) 
				AND (
					au.usage_uid = 121810  -- Rechnungsadresse EP
					or au.usage_uid = 121625 
					AND (ba.postal_display_street is not null or ba.postal_po_box_global_text_nr = 0)
				) -- Rechnungsadresse WP                          
			) am 
			on am.ext_join_nr = ej.ext_join_nr
			LEFT JOIN (
				SELECT /*+ ordered use_hash(amb aub bab cityb) full(amb) full(aub) full(bab) full(cityb) */
					amb.ext_join_nr, 
					bab.item_key0_nr item_key0_nrb, 
					cityb.zip_code zip_codeb, 
					cityb.city cityb, 
					cityb.country_uid country_uidb, 
					cityb.state stateb, 
					bab.postal_additional_line1 postal_additional_line1b, 
					bab.postal_additional_line2 postal_additional_line2b, 
					gt.text postal_po_box_text, 
					bab.address_nr address_nrb, 
					bab.city_nr city_nrb, 
					bab.postal_po_box_global_text_nr
				FROM bsicrm.bsi_x_address_mapping amb
					JOIN bsicrm.bsi_address_usage aub on aub.address_nr = amb.address_nr 
						-- 121625 Rechnungsadresse WP
						-- 121811 Rechnungsadresse EP (Postfach)
						AND aub.usage_uid in (121625,121811)
					JOIN bsicrm.bsi_address bab on bab.address_nr = amb.address_nr 
					JOIN bsicrm.bsi_city cityb on cityb.city_nr = bab.city_nr
					LEFT JOIN bsicrm.bsi_global_text gt on gt.global_text_nr = bab.postal_po_box_global_text_nr
				WHERE bab.channel_uid = 113688  -- Anschrift
						-- 2315:	Hauptadresse
						-- 108363:	Korrespondenz mutiert durch User ODER Korrespondenzadresse EP
						-- 108240:	Hauptadresse (Postfach)
						-- 108364:	Korrespondenz mutiert durch User (Postfach) ODER Korrespondenzadresse EP (Postfach)
				AND amb.type_uid not in (2315,108363,108240,108364)
				AND (
					aub.usage_uid = 121811 -- Rechnungsadresse EP (Postfach)
					or aub.usage_uid = 121625 
					AND bab.postal_display_street is null AND gt.global_text_nr != 0
				) -- Rechnungsadresse WP                       
			) amb 
			on amb.ext_join_nr = ej.ext_join_nr
			LEFT JOIN (
				SELECT 
					adr.item_key0_nr,
					max (CASE 
						WHEN adr.channel_uid = 113638 AND substr(adr.channel_value,1,5) not in ('+4175','+4176','+4177','+4178','+4179') THEN 
							adr.channel_value 
						else null 
						END
					) phone,
					max (CASE
						WHEN adr.channel_uid = 113640 or substr(adr.channel_value,1,5) in ('+4175','+4176','+4177','+4178','+4179') THEN 
							adr.channel_value 
						else null
						END
					) mobile,
					max (CASE 
						WHEN adr.channel_uid = 113641 AND upper(adr.channel_value) not like 'ETV@%' THEN 
							adr.channel_value 
						END
					) email
				FROM bsicrm.bsi_address adr
					WHERE adr.is_default_address = 1
					AND adr.item_type_id in (113638, 113640, 113641)
				GROUP BY adr.item_key0_nr
			) sadr
			on sadr.item_key0_nr = company.company_nr
		WHERE company.is_active = 1  
			AND ej.interface_uid in (108187,108205) 
			AND ej.active = 1  
			AND (am.ext_join_nr is not null or amb.ext_join_nr is not null)
			AND not exists (
				SELECT -- /*+ ordered use_hash(ba2 am2 ej2 au2) full(ba2) full(am2) full(ej2) full(au2) */
					null 
				FROM bsicrm.bsi_address ba2
					JOIN bsicrm.bsi_x_address_mapping am2 on am2.address_nr = ba2.address_nr
						AND am2.join_type_uid = 318594  -- Type: Firma
						AND am2.channel_uid = 113688    -- Anschrift
					JOIN bsicrm.bsi_x_ext_join ej2 on ej2.ext_join_nr = am2.ext_join_nr
						AND ej2.interface_uid in (108187, 108205) -- samba / nxdsmp
					LEFT JOIN bsicrm.bsi_address_usage au2 on au2.address_nr = am2.address_nr 
					AND au2.usage_uid = 121808  -- Korrespondenzadresse EP
				WHERE ba2.item_key0_nr = company.company_nr
				AND ba2.address_nr != nvl(am.address_nr,ba2.address_nr)
				-- 2315:	Hauptadresse
				-- 108363:	Korrespondenz mutiert durch User ODER Korrespondenzadresse EP
				AND (am2.type_uid in (2315,108363) or au2.address_nr is not null)
			AND ba2.city_nr = nvl(am.city_nr,0)
			AND nvl(ba2.postal_display_street,'null') = nvl(am.postal_display_street,'null')
			)  
			AND not exists (
				SELECT -- /*+ ordered use_hash(ba2 am2 ej2 au2) full(ba2) full(am2) full(ej2) full(au2) */
					null 
				FROM bsicrm.bsi_address ba2
					JOIN bsicrm.bsi_x_address_mapping am2 on am2.address_nr = ba2.address_nr
						AND am2.join_type_uid = 318594  -- Type: Firma
						AND am2.channel_uid = 113688    -- Anschrift
					JOIN bsicrm.bsi_x_ext_join ej2 on ej2.ext_join_nr = am2.ext_join_nr
						AND ej2.interface_uid in (108187,108205) -- samba / nxdsmp
					LEFT JOIN bsicrm.bsi_address_usage au2 on au2.address_nr = am2.address_nr 
						AND au2.usage_uid = 121809  -- Korrespondenzadresse EP (Postfach)
				WHERE ba2.item_key0_nr = company.company_nr
				AND ba2.address_nr != nvl(amb.address_nrb,ba2.address_nr)
				-- 108240:	Hauptadresse (Postfach)
				-- 108364:	Korrespondenz mutiert durch User (Postfach) ODER Korrespondenzadresse EP (Postfach)
				AND (am2.type_uid in (108240,108364) or au2.address_nr is not null)
				AND ba2.city_nr = nvl(amb.city_nrb,0)
				AND nvl(ba2.postal_po_box_global_text_nr,0) = nvl(amb.postal_po_box_global_text_nr,0)
			)
		--  AND company.x_complex_no between TO_NUMBER(10006743) AND TO_NUMBER(16777014)
		) LOOP

			vTextLine := REPLACE('"'||r.uk_LCM_X_COMPLEX_NO__c||'","'
					||r.Billing_City__c||'","'
					||r.Billing_Country__c||'","'
					||r.Billing_Language__c||'","'
					||REPLACE(REPLACE(r.Billing_Name__c,'"',''''),'''''','''')||'","'
					||r.Billing_Postal_Code__c||'","'
					||r.Billing_State__c||'","'
					||REPLACE(REPLACE(r.Billing_Street__c,'"',''''),'''''','''')||'","'
					||r.P_O_Box__c||'","'
					||r.P_O_BoxPostalCode__c||'","'
					||r.P_O_BoxCity__c||'","'
					||r.Mail_address__c||'","'
					||REPLACE(REPLACE(r.Name,'"',''''),'''''','''')||'","'
					||r.Phone__c||'","'
					||r.MobilePhone__c||'","'
					||r.BillingAddressSAMBA_Key__c||'","'
					||r.BillingAddressNx_Key__c||'","'
					|| r.Allowed_comm_channel__c|| '","'
					|| r.Communication_Channel__c || '"','""')||cr;

			utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
			utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren

			h := h + 1;

		END LOOP;

		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl Billing Profiles: '||to_char(h));

	EXCEPTION WHEN others THEN
		vErrorText := 'Fehler bei lcm_billingprofile: '||sqlerrm;
		dbms_output.put_line(vErrorText);
	END lcm_billingprofile;


	----------------------------------
	-- PROCEDURE lcm_accounts_leads --
	----------------------------------
	PROCEDURE lcm_accounts_leads is
	BEGIN

		h := 0;

		SELECT 'LCM_Leads_nx_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;

		dbms_output.put_line('Export lcm_accounts_leads, FileName '||vFileNamecsv);

		vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

		vTextLine := 'uk_LCM_X_COMPLEX_NO__c,uk_LCM_PERSON_NR__c,LCM_NX_MergeIDs__c,Name,Street,PostalCode,City,State,Country,P_O_Box__c,P_O_BoxPostalCode__c,P_O_BoxCity__c,Phone,MobilePhone,Fax,Email__c,Website,PreferedLanguage__c,ClientRating__c,SalesChannel__c,KAMType__c,Salutation,Title,FirstName,LastName,LegalEntity__c,UID__c,NOGA1__c,CompanySince__c,TurnoverClass__c,NumberOfEmployees,Allowed_comm_channel__c,Communication_Channel__c'||cr;   -- header
		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);  -- Schreibpuffer leeren

		for r in (
			WITH exported_companies AS (
				SELECT /*+ ordered use_hash(ejj ej company a sspa sspba cp_join) full(ejj) full(ej) full(company) full(a) full(sspa) full(sspba) full(cp_join) */
					company.x_complex_no,  -- leads
					company.y_uid_bur,
					TRIM(REPLACE(company.name1, chr(13), '') || ' ' 
								|| REPLACE(company.name2, chr(13), '') || ' ' 
								|| REPLACE(company.name3, chr(13), '')) 
					NAME,
					company.language_uid,
					ejj.join_nr,
					ej.ext_join_nr,
					ej.ext_join_type_uid,
					ej.interface_uid,
					sadr.fone,
					sadr.handy,
					sadr.fax,
					sadr.email,
					sadr.www,
					kam.kamtyp,
					sspa.address_nr address_nr,
					sspba.address_nr pobox_address_nr,
					company.y_legal_status_uid, 
					company.x_is_locked,
					company.x_advisory_status_uid,
					dbms_lob.substr(comp_nx.join_nos_nx, 4000, 1 ) join_nos_nx,
					collection.join_nr coll_join_nr,
					cp_join.person_nr,
					kuba_data.kuba_join_nr,
					COMPANY.IS_MAILING_DISABLED Allowed_comm_channel__c,
					CASE WHEN xcrpd.LETTER_CHANNEL_UID IN (128573, 128572) THEN 
						'Email'
					WHEN xcrpd.LETTER_CHANNEL_UID IN (128575, 128574, 128571) THEN 
						'Letter'
					WHEN xcrpd.LETTER_CHANNEL_UID = 0 THEN 
						 'n.a.'
					END Communication_Channel__c
				FROM   bsicrm.bsi_x_ext_join_join ejj
					JOIN   bsicrm.bsi_x_ext_join ej ON ejj.ext_join_nr = ej.ext_join_nr AND ejj.ext_join_type_uid = ej.ext_join_type_uid 
					LEFT JOIN BSICRM.BSI_X_CORRESPONDENCE xcrpd ON xcrpd.CUSTOMER_KEY0_NR = EJj.JOIN_NR
					JOIN   bsicrm.bsi_company company ON company.company_nr = ejj.join_nr AND company.is_active = 1
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ejj2 ej2) full(ejj2) full(ej2) */
							MIN(ej2.kam_uid) kamtyp, 
							ejj2.join_nr innerjnr
						FROM bsicrm.bsi_x_ext_join ej2
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr                    
							WHERE ej2.kam_uid != 0
						GROUP BY ejj2.join_nr
					) kam ON kam.innerjnr = ejj.join_nr  
					LEFT JOIN (
						SELECT /*+ ordered use_hash(adr am ej2) full(adr) full(am) full(ej2) */
							adr.item_key0_nr,
							max (CASE WHEN adr.channel_uid = 113638 AND adr.channel_value <> '+41999999999' THEN adr.channel_value ELSE NULL END) fone,
							max (CASE WHEN adr.channel_uid = 113640 AND adr.channel_value <> '+41999999999' THEN adr.channel_value ELSE NULL END) handy,
							max (CASE WHEN adr.channel_uid = 113639 AND adr.channel_value <> '+41999999999' THEN adr.channel_value ELSE NULL END) fax,
							max (CASE WHEN adr.channel_uid = 113641 THEN adr.channel_value ELSE NULL END) email,
							max (CASE WHEN adr.channel_uid = 113642 THEN adr.channel_value ELSE NULL END) www
						FROM bsicrm.bsi_address adr
							JOIN bsicrm.bsi_x_address_mapping am ON am.address_nr = adr.address_nr 
							JOIN bsicrm.bsi_x_ext_join ej2 ON ej2.ext_join_nr = am.ext_join_nr AND ej2.ACTIVE = 1
						WHERE adr.is_default_address = 1
							AND adr.item_type_id = 318594
						GROUP BY adr.item_key0_nr
					) sadr ON sadr.item_key0_nr = company.company_nr
					LEFT OUTER JOIN bsicrm.bsi_x_address_mapping sspa ON  sspa.ext_join_nr = ejj.ext_join_nr
						AND sspa.join_type_uid = 318594
						AND sspa.type_uid = 2315 /* Hauptadresse */
						AND sspa.channel_uid = 113688
						AND sspa.join_nr = ejj.join_nr  
					LEFT OUTER JOIN bsicrm.bsi_x_address_mapping sspba ON  sspba.ext_join_nr = ejj.ext_join_nr
						AND sspba.join_type_uid = 318594
						AND sspba.type_uid = 108240 /* Postfach */
						AND sspba.channel_uid = 113688
						AND sspba.join_nr = ejj.join_nr
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(cp_join P cpr) full(cp_join) full(P) full(cpr) */
							cp_join.company_nr, 
							max (cp_join.person_nr) person_nr
						FROM bsicrm.bsi_company_person cp_join
							JOIN bsicrm.bsi_person P ON P.person_nr = cp_join.person_nr 
								AND P.is_active = 1
							JOIN bsicrm.bsi_uc_company_person_role cpr ON cpr.company_person_role_uid = cp_join.role_uid 
								AND cpr.is_use_for_display_name = 1
						GROUP BY cp_join.company_nr
					) cp_join ON cp_join.company_nr = company.company_nr 
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(kd ej2 ejj2) full(kd) full(ej2) full(ejj2) */
							max (kd.join_nr) kuba_join_nr, 
							ejj2.join_nr             
						FROM bsicrm.bsi_x_ext_kuba_data kd
							JOIN bsicrm.bsi_x_ext_join ej2 
								inner JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr 
									AND ejj2.ext_join_type_uid = ej2.ext_join_type_uid
							ON ej2.ext_join_nr = kd.join_nr
							AND  ej2.ext_join_type_uid = kd.join_type_uid 
							AND ej2.ACTIVE = 1
						WHERE kd.status_uid = 4800511372 --aktiv  
						GROUP BY ejj2.join_nr
					) KUBA_DATA ON kuba_data.join_nr = company.company_nr
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ej2 ejj2) full(ej2) full(ejj2) */
							ejj2.join_nr, 
							RTRIM (XMLAGG(XMLELEMENT(E, ej2.join_no, CHR(44)).EXTRACT('//text()') 
								ORDER BY ej2.join_no).getclobval(),','
							) join_nos_nx
						FROM bsicrm.bsi_x_ext_join ej2
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr AND ej2.ACTIVE = 1
						WHERE ej2.active = 1
							AND ejj2.ext_join_type_uid = 108224
							AND ej2.interface_uid = 108205
						GROUP BY ejj2.join_nr
					) comp_nx ON comp_nx.join_nr = company.company_nr      
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(coll ejinner ejjinner) full(coll) full(ejinner) full(ejjinner) */
							DISTINCT ejjinner.join_nr
						FROM bsicrm.bsi_x_collection coll 
							JOIN bsicrm.bsi_x_ext_join ejinner ON ejinner.ext_join_nr = coll.ext_company_nr AND ejinner.ACTIVE = 1
							JOIN bsicrm.bsi_x_ext_join_join ejjinner ON ejjinner.ext_join_nr = ejinner.ext_join_nr
						WHERE coll.status_uid <> 137824
					) collection ON collection.join_nr = company.company_nr    
				WHERE  ejj.is_master = 1
					AND ejj.ext_join_type_uid = 108224
					AND ej.active = 1
					AND ej.interface_uid  = 108205 --nx   
					--nicht = Konzern, Unternehmen, Filiale
					AND company.company_nr NOT IN (
						SELECT 
							cc.company_nr 
						FROM bsicrm.bsi_company_company cc
						UNION SELECT 
							cc.group_company_nr
						FROM bsicrm.bsi_company_company cc)
					AND ejj.join_nr NOT IN (
						SELECT /*+ ordered use_hash(prod ejj2) full(prod) full(ejj2) */
							DISTINCT ejj2.join_nr 
						FROM bsicrm.bsi_x_ext_product prod 
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = prod.join_nr
						WHERE prod.status_uid = 109307 --aktuell
						AND prod.type_uid IN (1000408,1000409,1923083777,1923083778,1923083779,5684031909,6077978250,6077978180,6077978542,6077978285,1000415,1000419,1923083780,1923083781,1923083782,1923083783,1923083784,1923083785,5684031938,5684031911,6077978344,6599798156,6077978035,6599798005,6077978528,6599797809,6077978220,6599797644,1000427,1000428,1000429,1000623)
					)
			), --hat KEIN aktuelles Eintragsprodukt
			dunning AS (
				SELECT /*+ ordered use_hash(xrcp ej ejj) full(xrcp) full(ej) full(ejj) */
					distinct ejj.join_nr -- company.x_complex_no            
				FROM bsicrm.bsi_x_ext_receipt xrcp
					JOIN bsicrm.bsi_x_ext_join ej ON ej.ext_join_nr = xrcp.join_nr 
						AND  ej.ext_join_type_uid = xrcp.join_type_uid    -- ??? ej.active = 1
					JOIN bsicrm.bsi_x_ext_join_join ejj ON ejj.ext_join_nr = ej.ext_join_nr 
						AND ejj.ext_join_type_uid = ej.ext_join_type_uid
				WHERE xrcp.overdue_level_uid IN (137663,137664,137665) 
			)  
			SELECT /*+ ordered use_hash(kuba dnng legaladdr cy ap cyp pers tkam tlf tnc tne) full(kuba) full(dnng) full(legaladdr) full(cy) full(ap) full(cyp) full(pers) full(tkam) full(tlf) full(tnc) full(tne) */
				DISTINCT ec.x_complex_no uk_lcm_x_complex_no__c,
				ec.person_nr uk_LCM_PERSON_NR__c, 
				ec.join_nos_nx LCM_NX_MergeIDs__c, 
				ec.NAME,
				COALESCE(legaladdr.x_street_name, legaladdr.postal_display_street) Street, 
				cy.zip_code PostalCode,
				cy.city City,
				CASE WHEN cy.state IS NULL THEN cyp.state
				ELSE cy.state 
				END state,  
				CASE WHEN cy.country_uid IS NULL THEN 
					DECODE (cyp.country_uid, 
						1001148, 'Schweiz', 
						1001161, 'Deutschland', 
						1001179, 'Frankreich', 
						1001215, 'Italien', 
						1001234, 'Liechtenstein')
					ELSE DECODE (cy.country_uid, 
						1001148, 'Schweiz', 
						1001161, 'Deutschland', 
						1001179, 'Frankreich', 
						1001215, 'Italien', 
						1001234, 'Liechtenstein')
				END Country,
				DECODE (ap.postal_po_box_global_text_nr, 
					0, '', 
					(SELECT text FROM bsicrm.bsi_global_text gt WHERE gt.global_text_nr = ap.postal_po_box_global_text_nr)
				) p_o_box__c,
				cyp.zip_code P_O_BoxPostalCode__c, 
				cyp.city P_O_BoxCity__c,
				CASE WHEN ec.fone LIKE '%+4175%' 
					OR ec.fone LIKE '%+4176%'
					OR ec.fone LIKE '%+4177%'
					OR ec.fone LIKE '%+4178%'
					OR ec.fone LIKE '%+4179%'  
				THEN  NULL
				ELSE ec.fone           
				END Phone,
				CASE WHEN ec.fone LIKE '%+4175%' 
					OR ec.fone LIKE '%+4176%'  
					OR ec.fone LIKE '%+4177%'  
					OR ec.fone LIKE '%+4178%'  
					OR ec.fone LIKE '%+4179%' 
				THEN  ec.fone
				ELSE ec.handy           
				END MobilePhone, 
				ec.fax Fax, 
				CASE WHEN ec.email LIKE 'etv@%' THEN  NULL
				ELSE ec.email           
				END email__c,
				ec.www website,
				DECODE (ec.language_uid, 
					246, 'German', 
					1303, 'English', 
					7770, 'French', 
					7771, 'Italian', '?'
				) PreferedLanguage__c, 
				CASE WHEN ec.x_is_locked = 1 THEN 'D'
					WHEN dnng.join_nr IS NOT NULL THEN 'C'
					ELSE NULL           
				END clientrating__c,  
				DECODE (ec.x_advisory_status_uid, 
					117411, 'Fieldsales', 
					117413, 'KAM-Fieldsales'
				) SalesChannel__c,  
				tkam.text KAMType__c, 
				DECODE (pers.salutation_uid,
					3193, 'Herr', 
					3194, 'Frau'
				) salutation,
				pers.title title ,
				CASE WHEN trim(pers.first_name) IN ('*', '-', '.', ',', '?', '0', '', ' ') 
					OR pers.first_name IS NULL
				THEN NULL
				ELSE pers.first_name
				END firstname,
				CASE WHEN trim(pers.last_name) IN ('*', '-', '.', ',', '?', '0', '', ' ') 
					OR pers.last_name IS NULL 
				THEN 
					'unbekannt/inconnu/sconosciuto'
				ELSE pers.last_name
				END LastName,
				CASE WHEN ec.y_legal_status_uid  <> 0 THEN 
					REPLACE(REPLACE(uct_legal_status.TEXT, 'NICHT ZEFIX: ', ''), 'ZEFIX: ', '')
				END legalentity__c,
--				kuba.federal_company_id UID__c,
				ec.y_uid_bur UID__c,
				tnc.text NOGA1__c,
				CASE WHEN kuba.founding_year = 0 THEN null
				ELSE kuba.founding_year
				END CompanySince__c,
				CASE 
					WHEN kuba.turnover BETWEEN 2000001 AND 99999999 THEN  'A'
					WHEN kuba.turnover BETWEEN 1000001 AND 2000000 THEN  'B'
					WHEN kuba.turnover BETWEEN 200001 AND 1000000 THEN  'C'           
					WHEN kuba.turnover BETWEEN 5001 AND 200000 THEN  'D'             
				END TurnoverClass__c,
				tne.text NumberOfEmployees,
				EC.Allowed_comm_channel__c,
				EC.Communication_Channel__c
			FROM   exported_companies ec
				LEFT JOIN bsicrm.bsi_x_ext_kuba_data kuba ON kuba.join_nr = ec.kuba_join_nr
				LEFT JOIN dunning dnng ON dnng.join_nr = ec.join_nr     -- dnng.x_complex_no = C.x_complex_no
				LEFT JOIN bsicrm.bsi_address legaladdr ON legaladdr.address_nr = ec.address_nr
				LEFT JOIN bsicrm.bsi_city cy ON cy.city_nr = legaladdr.city_nr
				LEFT JOIN bsicrm.bsi_address ap ON ap.address_nr = ec.pobox_address_nr
				LEFT JOIN bsicrm.bsi_city cyp on cyp.city_nr = ap.city_nr
				LEFT JOIN bsicrm.bsi_person pers on pers.person_nr = ec.person_nr
				LEFT JOIN bsicrm.bsi_uc_text tkam on tkam.uc_uid = ec.kamtyp AND tkam.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tlf on tlf.uc_uid = kuba.legal_form_uid AND tlf.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tnc on tnc.uc_uid = kuba.noga_code1_uid AND tnc.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tne on tne.uc_uid = kuba.number_of_employees_uid AND tne.language_uid = 246
				--           WHERE ec.x_complex_no between TO_NUMBER(10006743) AND TO_NUMBER(16777014)
		) LOOP

			vTextLine := REPLACE('"'|| r.uk_LCM_X_COMPLEX_NO__c || '","'
					|| r.uk_LCM_PERSON_NR__c || '","'
					|| r.LCM_NX_MergeIDs__c || '","'
					|| REPLACE(REPLACE(r.Name,'"',''''),'''''','''') || '","'
					|| REPLACE(REPLACE(r.Street,'"',''''),'''''','''') || '","'
					|| r.PostalCode || '","'
					|| r.City || '","'
					|| r.State || '","'
					|| r.Country || '","'
					|| r.P_O_Box__c || '","'
					|| r.P_O_BoxPostalCode__c|| '","'
					|| r.P_O_BoxCity__c || '","'
					|| r.Phone || '","'
					|| r.MobilePhone || '","'
					|| r.Fax || '","'
					|| r.Email__c || '","'
					|| r.Website || '","'
					|| r.PreferedLanguage__c || '","'
					|| r.ClientRating__c|| '","'
					|| r.SalesChannel__c || '","'
					|| r.KAMType__c || '","'
					|| r.Salutation || '","'
					|| r.Title || '","'
					|| r.FirstName || '","'
					|| REPLACE(REPLACE(r.LastName,'"',''''),'''''','''') || '","'
					|| r.LegalEntity__c || '","'
					|| r.UID__c || '","'
					|| r.NOGA1__c || '","'
					|| r.CompanySince__c || '","'
					|| r.TurnoverClass__c|| '","'
					|| r.NumberOfEmployees|| '","'
					|| r.Allowed_comm_channel__c|| '","'
					|| r.Communication_Channel__c || '"','""') ||cr;

			utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
			utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren

			h := h + 1;
	  
		END LOOP;
  
		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl Leads: '||to_char(h));

	EXCEPTION WHEN others THEN
		vErrorText := 'Fehler bei lcm_accounts_leads: '||sqlerrm;
		dbms_output.put_line(vErrorText);
	END lcm_accounts_leads;


	---------------------------
	-- PROCEDURE lcm_accounts_nx --
	---------------------------
	PROCEDURE lcm_accounts_nx is
	BEGIN

		h := 0;

		SELECT 'LCM_Accounts_nx_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;

		dbms_output.put_line('Export lcm_accounts_nx, FileName '||vFileNamecsv);

		vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

		vTextLine := 'uk_LCM_X_COMPLEX_NO__c,LCM_Samba_MergeIDs__c,LCM_NX_MergeIDs__c,Name,Phone,MobilePhone,Fax,Email__c,Website,LegalStreet,LegalPostalCode,LegalCity,LegalState,LegalCountry,P_O_Box__c,P_O_BoxPostalCode__c,P_O_BoxCity__c,PreferedLanguage__c,Structure__c,ClientRating__c,SalesChannel__c,KAMType__c,ShippingStreet,ShippingPostalCode,ShippingCity,ShippingState,ShippingCountry,ShippingP_O_Box__c,ShippingP_O_Box_PostalCode__c,ShippingP_O_BoxCity__c,LegalEntity__c,UID__c,NOGA1__c,CompanySince__c,TurnoverClass__c,NumberOfEmployees,Allowed_comm_channel__c,Communication_Channel__c'||cr;   -- header

		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);  -- Schreibpuffer leeren

		for r in (
			WITH exported_companies AS (
				SELECT /*+ ordered use_hash(ejj ej prod company cc cc2 a sspa sspba) full(ejj) full(ej) full(prod) full(company) full(cc) full(cc2) full(a) full(sspa) full(sspba) */
					company.x_complex_no,  -- lcm_accounts_nx
					company.y_uid_bur,
					TRIM(REPLACE(company.name1, chr(13), '') || ' ' 
							|| REPLACE(company.name2, chr(13), '') || ' ' 
							|| REPLACE(company.name3, chr(13), '')) 
					NAME,
					company.language_uid,
					COMPANY.x_is_locked,
					ejj.join_nr,
					dbms_lob.substr(comp_samba.join_nos_samba, 4000, 1 ) join_nos_samba,
					dbms_lob.substr(comp_nx.join_nos_nx, 4000, 1 ) join_nos_nx, 
					sadr.fone,
					sadr.handy,
					sadr.fax,
					sadr.email,
					sadr.www,
					kam.kamtyp,
					CASE 
						WHEN cc2.relation_uid = 300 THEN 'Group'
						WHEN cc2.relation_uid = 109876 THEN 'Company' 
						WHEN cc.relation_uid  = 300 THEN 'Company'
						WHEN cc.relation_uid  = 109876 THEN 'Branch'
					ELSE 'Single Company' 
					END structure__c, 
					sspa.address_nr address_nr,
					sspba.address_nr pobox_address_nr,
					ship_adr.ship_address_nr,
					ship_po.ship_po_nr,
					company.y_legal_status_uid, 
					company.x_advisory_status_uid,  
					collection.join_nr coll_join_nr,
					kuba_data.kuba_join_nr,
					COMPANY.IS_MAILING_DISABLED Allowed_comm_channel__c,
					CASE WHEN xcrpd.LETTER_CHANNEL_UID IN (128573, 128572) THEN 
						'Email'
					WHEN xcrpd.LETTER_CHANNEL_UID IN (128575, 128574, 128571) THEN 
						'Letter'
					WHEN xcrpd.LETTER_CHANNEL_UID = 0 THEN 
						'n.a.'
					END Communication_Channel__c
                FROM bsicrm.bsi_x_ext_join_join ejj
					JOIN bsicrm.bsi_x_ext_join ej ON ejj.ext_join_nr = ej.ext_join_nr 
						AND ejj.ext_join_type_uid = ej.ext_join_type_uid 
						AND ej.active = 1
					LEFT JOIN BSICRM.BSI_X_CORRESPONDENCE xcrpd ON xcrpd.CUSTOMER_KEY0_NR = EJj.JOIN_NR
					LEFT JOIN (
						SELECT /*+ ordered use_hash(prod ejj2) full(prod) full(ejj2) */
							DISTINCT ejj2.join_nr 
						FROM bsicrm.bsi_x_ext_product prod 
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = prod.join_nr
						WHERE prod.status_uid = 109307 --aktuell
						AND prod.type_uid IN (1000408,1000409,1923083777,1923083778,1923083779,5684031909,6077978250,6077978180,6077978542,6077978285,1000415,1000419,1923083780,1923083781,1923083782,1923083783,1923083784,1923083785,5684031938,5684031911,6077978344,6599798156,6077978035,6599798005,6077978528,6599797809,6077978220,6599797644,1000427,1000428,1000429,1000623)
					) prod ON prod.join_nr = ejj.join_nr
					JOIN bsicrm.bsi_company company ON company.company_nr = ejj.join_nr AND company.is_active = 1 
					LEFT JOIN bsicrm.bsi_company_company cc ON cc.company_nr = ejj.join_nr
					LEFT JOIN (
						SELECT 
							cc2.group_company_nr, 
							MIN(cc2.relation_uid) relation_uid
						FROM bsicrm.bsi_company_company cc2 
						GROUP BY cc2.group_company_nr 
					) cc2 ON cc2.group_company_nr = ejj.join_nr     
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ej2 ejj2) full(ej2) full(ejj2) */
							MIN(ej2.kam_uid) kamtyp, 
							ejj2.join_nr innerjnr
						FROM bsicrm.bsi_x_ext_join ej2
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr                     
						WHERE ej2.active = 1
							AND ej2.kam_uid != 0
						GROUP BY ejj2.join_nr
					) kam ON kam.innerjnr = ejj.join_nr   
					LEFT JOIN (
						SELECT /*+ ordered use_hash(adr am ej2) full(adr) full(am) full(ej2) */
							adr.item_key0_nr,
							max (
								CASE WHEN adr.channel_uid = 113638 AND adr.channel_value <> '+41999999999' THEN 
									adr.channel_value 
								ELSE NULL 
								END
							) fone,
							max (
								CASE WHEN adr.channel_uid = 113640 AND adr.channel_value <> '+41999999999' THEN 
									adr.channel_value 
								ELSE NULL 
								END
							) handy,
							max (
								CASE WHEN adr.channel_uid = 113639 AND adr.channel_value <> '+41999999999' THEN 
									adr.channel_value 
								ELSE NULL 
								END
							) fax,
							max (
								CASE WHEN adr.channel_uid = 113641 THEN 
									adr.channel_value 
								ELSE NULL 
								END
							) email,
							max (
								CASE WHEN adr.channel_uid = 113642 THEN 
									adr.channel_value 
								ELSE NULL 
								END
							) www
						FROM bsicrm.bsi_address adr
							JOIN bsicrm.bsi_x_address_mapping am ON am.address_nr = adr.address_nr 
							JOIN bsicrm.bsi_x_ext_join ej2 ON ej2.ext_join_nr = am.ext_join_nr 
								AND ej2.active = 1 
								AND ej2.interface_uid IN (108187, 108205)
						WHERE adr.is_default_address = 1
							AND adr.item_type_id = 318594
						GROUP BY adr.item_key0_nr
					) sadr ON sadr.item_key0_nr = company.company_nr
					LEFT OUTER JOIN bsicrm.bsi_x_address_mapping sspa ON  sspa.ext_join_nr = ejj.ext_join_nr
						AND sspa.join_type_uid = 318594
						AND sspa.type_uid = 2315 /* Hauptadresse */
						AND sspa.channel_uid = 113688
						AND sspa.join_nr = ejj.join_nr             
					LEFT OUTER JOIN bsicrm.bsi_x_address_mapping sspba ON  sspba.ext_join_nr = ejj.ext_join_nr
						AND sspba.join_type_uid = 318594
						AND sspba.type_uid = 108240 /* Postfach */
						AND sspba.channel_uid = 113688
						AND sspba.join_nr = ejj.join_nr    

-- Shipping Adresse
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ship_adr au) full(ship_adr) full(au) */
							ship_adr.join_nr,
							max (ship_adr.address_nr) ship_address_nr
						FROM bsicrm.bsi_x_address_mapping ship_adr
							JOIN bsicrm.bsi_address_usage au ON au.address_nr = ship_adr.address_nr
							-- 121799: Korrespondenz EP
							-- 121808: (Adressnutzung von Firmen) Korrespondenz EP
							AND au.usage_uid IN (121799, 121808)
						WHERE ship_adr.join_type_uid = 318594
							AND ship_adr.channel_uid = 113688
							-- (2315:	Hauptadress)
							-- 108353:  Korrespondenz mutiert durch User
							-- 108363:	Korrespondenz mutiert durch User
							AND ship_adr.type_uid in (108353, 108363)
						GROUP BY ship_adr.join_nr
					) ship_adr ON  ship_adr.join_nr = ejj.join_nr                  

-- Shipping Postfach Adresse
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ship_ap au) full(ship_ap) full(au) */
							ship_po.join_nr,
							max (ship_po.address_nr) ship_po_nr
						FROM bsicrm.bsi_x_address_mapping ship_po
							JOIN bsicrm.bsi_address_usage au ON au.address_nr = ship_po.address_nr
							-- 121801:  Korrespondenz EP (Postfach)
							-- 121809:  (Adressnutzung von Firmen) Korrespondenzadresse EP (Postfach)
							AND au.usage_uid IN (121801, 121809)
						WHERE ship_po.join_type_uid = 318594
							AND ship_po.channel_uid = 113688
							-- (108240:	Postfach)
							-- 108354:  Korrespondenz mutiert durch User (Postfach)
							-- 108364:	Korrespondenz mutiert durch User (Postfach)
							AND ship_po.type_uid IN (108354, 108364)
						GROUP BY ship_po.join_nr
					) ship_po ON  ship_po.join_nr = ejj.join_nr

					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(kd ej2 ejj2) full(kd) full(ej2) full(ejj2) */
							max (kd.join_nr) kuba_join_nr, 
							ejj2.join_nr             
						FROM bsicrm.bsi_x_ext_kuba_data  kd
							JOIN bsicrm.bsi_x_ext_join ej2 ON ej2.ext_join_nr = kd.join_nr
								AND  ej2.ext_join_type_uid = kd.join_type_uid 
								AND ej2.active = 1
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr 
								AND ejj2.ext_join_type_uid = ej2.ext_join_type_uid
						WHERE kd.status_uid = 4800511372 --aktiv  
						GROUP BY ejj2.join_nr
					) kuba_data ON kuba_data.join_nr = company.company_nr    
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(coll ejinner ejjinner) full(coll) full(ejinner) full(ejjinner) */
							DISTINCT ejjinner.join_nr
						FROM bsicrm.bsi_x_collection coll 
							JOIN bsicrm.bsi_x_ext_join ejinner ON ejinner.ext_join_nr = coll.ext_company_nr 
								AND ejinner.active = 1
							JOIN bsicrm.bsi_x_ext_join_join ejjinner ON ejjinner.ext_join_nr = ejinner.ext_join_nr
						WHERE coll.status_uid <> 137824
					) collection ON collection.join_nr = company.company_nr 
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ej2 ejj2) full(ej2) full(ejj2) */
							ejj2.join_nr, 
							RTRIM (XMLAGG(XMLELEMENT(E,ej2.join_no,CHR(44)).EXTRACT('//text()') ORDER BY ej2.join_no).getclobval(),',') join_nos_samba
						FROM bsicrm.bsi_x_ext_join ej2
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr
						WHERE ej2.active = 1
							AND ejj2.ext_join_type_uid = 108224
							AND ej2.interface_uid = 108187
						GROUP BY ejj2.join_nr
					) comp_samba ON comp_samba.join_nr = company.company_nr 
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ej2 ejj2) full(ej2) full(ejj2) */
							ejj2.join_nr, 
							RTRIM (XMLAGG(XMLELEMENT(E,ej2.join_no,CHR(44)).EXTRACT('//text()') ORDER BY ej2.join_no).getclobval(),',') join_nos_nx
						FROM bsicrm.bsi_x_ext_join ej2
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr
						WHERE ej2.active = 1
							AND ejj2.ext_join_type_uid = 108224
							AND ej2.interface_uid = 108205
						GROUP BY ejj2.join_nr
					) comp_nx ON comp_nx.join_nr = company.company_nr  
				WHERE ejj.is_master = 1
					AND ejj.ext_join_type_uid = 108224
					AND ej.interface_uid  = 108205 --nx      
					AND (prod.join_nr IS NOT NULL     -- hat ein aktuelles Eintragsprodukt     oder
					OR NVL(cc.company_nr,cc2.group_company_nr) IS NOT NULL) -- ist in einer Struktur eingebunden 
			),
			dunning AS (
				SELECT /*+ ordered use_hash(xrcp ej ejj) full(xrcp) full(ej) full(ejj) */ 
					distinct ejj.join_nr -- company.x_complex_no            
				FROM bsicrm.bsi_x_ext_receipt xrcp
					JOIN bsicrm.bsi_x_ext_join ej ON ej.ext_join_nr = xrcp.join_nr
					AND  ej.ext_join_type_uid = xrcp.join_type_uid    -- ??? ej.active = 1
				JOIN bsicrm.bsi_x_ext_join_join ejj ON ejj.ext_join_nr = ej.ext_join_nr 
					AND ejj.ext_join_type_uid = ej.ext_join_type_uid
				WHERE xrcp.overdue_level_uid IN (137663,137664,137665) 
			)
			SELECT   /*+ ordered use_hash(kuba dnng legaladdr cy ap gt cyp shipping_addr shipping_apo cy_sh_po gt_sh_po cy_shipping tkam tlf tnc tne) 
               full(kuba) full(dnng) full(legaladdr) full(cy) full(ap) full(gt) full(cyp) full(shipping_addr) full(shipping_apo) full(cy_sh_po) full(gt_sh_po) full(cy_shipping) full(tkam) full(tlf) full(tnc) full(tne) */ 
				distinct ec.x_complex_no uk_LCM_X_COMPLEX_NO__c,
				ec.NAME,
				ec.join_nos_samba LCM_Samba_MergeIDs__c,
				ec.join_nos_nx LCM_NX_MergeIDs__c,
				CASE WHEN ec.fone LIKE '%+4175%' 
					OR ec.fone LIKE '%+4176%'  
					OR ec.fone LIKE '%+4177%'  
					OR ec.fone LIKE '%+4178%'  
					OR ec.fone LIKE '%+4179%'  
				THEN  NULL
				ELSE ec.fone           
				END Phone,
				CASE WHEN ec.fone LIKE '%+4175%' 
					OR ec.fone LIKE '%+4176%'  
					OR ec.fone LIKE '%+4177%'
					OR ec.fone LIKE '%+4178%'
					OR ec.fone LIKE '%+4179%' 
				THEN  ec.fone
				ELSE ec.handy           
				END MobilePhone, 
				ec.fax Fax, 
				CASE WHEN ec.email LIKE 'etv@%' THEN NULL
					ELSE ec.email           
				END email__c,
				ec.www Website,
				NVL(RTRIM (legaladdr.x_street_name||' '||legaladdr.x_street_house_no), legaladdr.postal_display_street) legalstreet, 
				cy.zip_code LegalPostalCode,
				cy.city LegalCity,
				CASE WHEN cy.state IS NULL THEN cyp.state
					ELSE cy.state 
				END LegalState,  
				CASE WHEN cy.country_uid IS NULL THEN
					DECODE (cyp.country_uid, 
						1001148, 'Schweiz', 
						1001161, 'Deutschland', 
						1001179, 'Frankreich', 
						1001215, 'Italien', 
						1001234, 'Liechtenstein')
					else DECODE (cy.country_uid, 
						1001148, 'Schweiz', 
						1001161, 'Deutschland', 
						1001179, 'Frankreich', 
						1001215, 'Italien', 
						1001234, 'Liechtenstein') 
				END legalcountry,
				--DECODE (AP.postal_po_box_global_text_nr, NULL, '', (SELECT text FROM bsi_global_text gt WHERE gt.global_text_nr = AP.postal_po_box_global_text_nr) ) P_O_Box__c,
				gt.text P_O_Box__c,
				cyp.zip_code P_O_BoxPostalCode__c,
				cyp.city p_o_boxcity__c,

				DECODE (ec.language_uid, 
					246, 'German', 
					1303, 'English', 
					7770, 'French', 
					7771, 'Italian', '?'
				) PreferedLanguage__c,
				ec.structure__c,
				CASE 
					WHEN ec.x_is_locked = 1 THEN 'D'
					WHEN dnng.join_nr IS NOT NULL THEN 'C'
					ELSE NULL           
				END clientrating__c,

-- START SHIPPING
				CASE WHEN shipping_addr.address_nr IS NULL
				AND shipping_apo.address_nr IS NULL THEN
					NVL(RTRIM (legaladdr.x_street_name||' '||legaladdr.x_street_house_no), legaladdr.postal_display_street)
				ELSE
					regexp_replace (
						COALESCE (
							shipping_addr.x_street_name, 
							shipping_addr.postal_display_street
							), '^([^0-9]*) (\d+[a-zA-Z]{0,3})?$', '\1'
						) ||  ' ' || 
						nvl(shipping_addr.x_street_house_no, 
							ltrim(regexp_substr (
								COALESCE (
									shipping_addr.x_street_name, 
									shipping_addr.postal_display_street
								), ' (\d+[a-zA-Z]{0,3})?$'
							)
						)
					)
				END Shippingstreet, 

				CASE WHEN shipping_addr.address_nr IS NULL
				AND shipping_apo.address_nr IS NULL THEN
					cy.zip_code
				ELSE
					cy_shipping.zip_code 
				END Shippingpostalcode,

				CASE WHEN shipping_addr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					cy.city
				ELSE
					cy_shipping.city 
				END shippingcity,

				CASE WHEN shipping_addr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					cy.state
				ELSE
					cy_shipping.state 
				END ShippingState,

				CASE WHEN shipping_addr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					CASE WHEN cy.country_uid IS NULL THEN
						DECODE (cyp.country_uid, 
							1001148, 'Schweiz', 
							1001161, 'Deutschland', 
							1001179, 'Frankreich', 
							1001215, 'Italien', 
							1001234, 'Liechtenstein')
						else DECODE (cy.country_uid, 
							1001148, 'Schweiz', 
							1001161, 'Deutschland', 
							1001179, 'Frankreich', 
							1001215, 'Italien', 
							1001234, 'Liechtenstein') 
					END 
				ELSE
					DECODE (cy_shipping.country_uid, 
						1001148, 'Schweiz', 
						1001161, 'Deutschland', 
						1001179, 'Frankreich', 
						1001215, 'Italien', 
						1001234, 'Liechtenstein') 
				END ShippingCountry,

				CASE WHEN shipping_addr.address_nr IS NULL
				AND legaladdr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					gt.text
				ELSE 
					gt_sh_po.text
				END ShippingP_O_Box__c,

				CASE WHEN shipping_addr.address_nr IS NULL
				AND legaladdr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					cyp.zip_code
				ELSE 
					cy_sh_po.zip_code
				END ShippingP_O_Box_PostalCode__c,

				CASE WHEN shipping_addr.address_nr IS NULL
				AND legaladdr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					cyp.city
				ELSE 
					cy_sh_po.city
				END ShippingP_O_BoxCity__c,
-- ENDE SHIPPING

				DECODE (ec.x_advisory_status_uid, 
					117411, 'Fieldsales', 
					117413, 'KAM-Fieldsales'
				) SalesChannel__c,
				tkam.text KAMType__c,  
				CASE WHEN ec.y_legal_status_uid  <> 0 THEN 
					REPLACE(REPLACE(uct_legal_status.TEXT, 'NICHT ZEFIX: ', ''), 'ZEFIX: ', '')
				END legalentity__c,
--				kuba.federal_company_id UID__c,
				ec.y_uid_bur UID__c,
				tnc.text NOGA1__c,
				CASE 
					WHEN kuba.founding_year = 0 THEN NULL
					ELSE kuba.founding_year
				END CompanySince__c,
				CASE 
					WHEN kuba.turnover BETWEEN 2000001 AND 99999999 THEN  'A'
					WHEN kuba.turnover BETWEEN 1000001 AND 2000000 THEN  'B'
					WHEN kuba.turnover BETWEEN 200001 AND 1000000 THEN  'C'           
					WHEN kuba.turnover BETWEEN 5001 AND 200000 THEN  'D'             
				END TurnoverClass__c,
				tne.text NumberOfEmployees,
				EC.Allowed_comm_channel__c,
				EC.Communication_Channel__c
			FROM exported_companies ec
				LEFT JOIN bsicrm.bsi_x_ext_kuba_data kuba ON kuba.join_nr = ec.kuba_join_nr
				LEFT JOIN dunning dnng ON dnng.join_nr = ec.join_nr     -- dnng.x_complex_no = C.x_complex_no
				LEFT JOIN bsicrm.bsi_address legaladdr ON legaladdr.address_nr = ec.address_nr
				LEFT JOIN bsicrm.bsi_city cy ON cy.city_nr = legaladdr.city_nr
				LEFT JOIN bsicrm.bsi_address ap ON ap.address_nr = ec.pobox_address_nr
				LEFT JOIN bsicrm.bsi_global_text gt ON gt.global_text_nr = AP.postal_po_box_global_text_nr
				LEFT JOIN bsicrm.bsi_city cyp ON cyp.city_nr = AP.city_nr

				LEFT JOIN bsicrm.bsi_address shipping_addr ON shipping_addr.address_nr = ec.ship_address_nr
				LEFT JOIN bsicrm.bsi_address shipping_apo ON shipping_apo.address_nr = ec.ship_po_nr
				LEFT JOIN bsicrm.bsi_city cy_sh_po ON cy_sh_po.city_nr = shipping_apo.city_nr
				LEFT JOIN bsicrm.bsi_global_text gt_sh_po ON gt_sh_po.global_text_nr = shipping_apo.postal_po_box_global_text_nr
				LEFT JOIN bsicrm.bsi_city cy_shipping ON cy_shipping.city_nr = shipping_addr.city_nr
				
				LEFT JOIN bsicrm.bsi_uc_text tkam on tkam.uc_uid = ec.kamtyp AND tkam.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tlf on tlf.uc_uid = kuba.legal_form_uid AND tlf.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tnc on tnc.uc_uid = kuba.noga_code1_uid AND tnc.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tne on tne.uc_uid = kuba.number_of_employees_uid AND tne.language_uid = 246
		) LOOP

			vTextLine := REPLACE('"'||r.uk_LCM_X_COMPLEX_NO__c || '","'
					|| r.LCM_Samba_MergeIDs__c || '","'
					|| r.LCM_NX_MergeIDs__c || '","'
					|| REPLACE(REPLACE(r.Name,'"',''''),'''''','''') || '","'
					|| r.Phone || '","'
					|| r.MobilePhone || '","'
					|| r.Fax || '","'
					|| r.Email__c||'","'
					|| r.Website || '","'
					|| REPLACE(REPLACE(r.LegalStreet,'"',''''),'''''','''') || '","'
					|| r.LegalPostalCode || '","'
					|| r.LegalCity || '","'
					|| r.LegalState || '","'
					|| r.LegalCountry || '","'
					|| r.P_O_Box__c || '","'
					|| r.P_O_BoxPostalCode__c||'","'
					|| r.P_O_BoxCity__c || '","'
					|| r.PreferedLanguage__c || '","'
					|| r.Structure__c || '","'
					|| r.ClientRating__c || '","'
					|| r.SalesChannel__c || '","'
					|| r.KAMType__c || '","'
					|| REPLACE(REPLACE(r.ShippingStreet,'"',''''),'''''','''')|| '","'
					||r.ShippingPostalCode || '","'
					|| r.ShippingCity || '","'
					|| r.ShippingState || '","'
					|| r.ShippingCountry || '","'
					|| r.ShippingP_O_Box__c || '","'
					|| r.ShippingP_O_Box_PostalCode__c||'","'
					||r.ShippingP_O_BoxCity__c || '","'
					|| r.LegalEntity__c || '","'
					|| r.UID__c || '","'
					|| r.NOGA1__c||'","'
					||r.CompanySince__c || '","'
					|| r.TurnoverClass__c || '","'
					|| r.NumberOfEmployees||'","'
					|| r.Allowed_comm_channel__c|| '","'
					|| r.Communication_Channel__c || '"','""')||cr;

			utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
			utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren

			h := h + 1;

		END LOOP;

		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl Accounts nx: '||to_char(h));

	EXCEPTION WHEN others THEN
		vErrorText := 'Fehler bei lcm_accounts_nx: '||sqlerrm;
		dbms_output.put_line(vErrorText);
	END lcm_accounts_nx;


	-----------------------------------
	--	PROCEDURE lcm_accounts_samba --
	-----------------------------------
	--
	PROCEDURE lcm_accounts_samba is
	BEGIN

		h := 0;

		SELECT 'LCM_Accounts_SAMBA_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;

		dbms_output.put_line('Export lcm_accounts_samba, FileName '||vFileNamecsv);

		vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

		vTextLine := 'uk_LCM_X_COMPLEX_NO__c,LCM_Samba_MergeIDs__c,LCM_NX_MergeIDs__c,Name,Phone,MobilePhone,Fax,Email__c,Website,LegalStreet,LegalPostalCode,LegalCity,LegalState,LegalCountry,P_O_Box__c,P_O_BoxPostalCode__c,P_O_BoxCity__c,PreferedLanguage__c,Structure__c,ClientRating__c,SalesChannel__c,KAMType__c,ShippingStreet,ShippingPostalCode,ShippingCity,ShippingState,ShippingCountry,ShippingP_O_Box__c,ShippingP_O_Box_PostalCode__c,ShippingP_O_BoxCity__c,LegalEntity__c,UID__c,NOGA1__c,CompanySince__c,TurnoverClass__c,NumberOfEmployees,Allowed_comm_channel__c,Communication_Channel__c'||cr;   -- header

		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);  -- Schreibpuffer leeren

		for r in (
			WITH exported_companies AS (
				SELECT /*+ ordered use_hash(ejj ej company cc cc2 a sspa sspba) full(ejj) full(ej) full(company) full(cc) full(cc2) full(a) full(sspa) full(sspba) */
					company.x_complex_no,  -- lcm_accounts_samba
					company.y_uid_bur,
					TRIM(REPLACE(company.name1, chr(13), '') || ' ' 
							|| REPLACE(company.name2, chr(13), '') || ' ' 
							|| REPLACE(company.name3, chr(13), '')) 
					NAME,
					company.language_uid,
					COMPANY.x_is_locked,
					ejj.join_nr,
					dbms_lob.substr(comp_samba.join_nos_samba, 4000, 1 ) join_nos_samba,
					dbms_lob.substr(comp_nx.join_nos_nx, 4000, 1 ) join_nos_nx, 
					sadr.fone,
					sadr.handy,
					sadr.fax,
					sadr.email,
					sadr.www,
					kam.kamtyp,
					CASE 
						WHEN cc2.relation_uid = 300 THEN 'Group'
						WHEN cc2.relation_uid = 109876 THEN 'Company' 
						WHEN cc.relation_uid  = 300 THEN 'Company'
						WHEN cc.relation_uid  = 109876 THEN 'Branch'
						ELSE 'Single Company' 
					END structure__c, 
					sspa.address_nr address_nr,
					sspba.address_nr pobox_address_nr,
					ship_a.ship_address_nr,
					ship_ap.ship_po_nr,
					company.y_legal_status_uid, 
					company.x_advisory_status_uid,  
					collection.join_nr coll_join_nr,
					kuba_data.kuba_join_nr,
					COMPANY.IS_MAILING_DISABLED Allowed_comm_channel__c,
					CASE WHEN xcrpd.LETTER_CHANNEL_UID IN (128573, 128572) THEN 
						'Email'
					WHEN xcrpd.LETTER_CHANNEL_UID IN (128575, 128574, 128571) THEN 
						'Letter'
					WHEN xcrpd.LETTER_CHANNEL_UID = 0 THEN 
						'n.a.'
					END Communication_Channel__c
				FROM bsicrm.bsi_x_ext_join_join ejj
					JOIN bsicrm.bsi_x_ext_join ej ON ejj.ext_join_nr = ej.ext_join_nr 
						AND ejj.ext_join_type_uid = ej.ext_join_type_uid 
						AND ej.active = 1
					JOIN bsicrm.bsi_company company ON company.company_nr = ejj.join_nr 
						AND company.is_active = 1
					LEFT JOIN BSICRM.BSI_X_CORRESPONDENCE xcrpd ON xcrpd.CUSTOMER_KEY0_NR = EJj.JOIN_NR
					LEFT JOIN bsicrm.bsi_company_company cc ON cc.company_nr = ejj.join_nr
					LEFT JOIN (
						SELECT 
							cc2.group_company_nr, 
							MIN(cc2.relation_uid) relation_uid
						FROM bsicrm.bsi_company_company cc2 
						GROUP BY cc2.group_company_nr
					) cc2 ON cc2.group_company_nr = ejj.join_nr     
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ej2 ejj2) full(ej2) full(ejj2) */
							MIN(ej2.kam_uid) kamtyp, 
							ejj2.join_nr innerjnr
						FROM bsicrm.bsi_x_ext_join ej2
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr                     
						WHERE ej2.active = 1
						AND ej2.kam_uid != 0
						GROUP BY ejj2.join_nr
					) kam ON kam.innerjnr = ejj.join_nr  
					LEFT JOIN (
						SELECT /*+ ordered use_hash(adr am ej2) full(adr) full(am) full(ej2) */
							adr.item_key0_nr,
							max (CASE WHEN adr.channel_uid = 113638 THEN adr.channel_value ELSE NULL END) fone,
							max (CASE WHEN adr.channel_uid = 113640 THEN adr.channel_value ELSE NULL END) handy,
							max (CASE WHEN adr.channel_uid = 113639 THEN adr.channel_value ELSE NULL END) fax,
							max (CASE WHEN adr.channel_uid = 113641 THEN adr.channel_value ELSE NULL END) email,
							max (CASE WHEN adr.channel_uid = 113642 THEN adr.channel_value ELSE NULL END) www
						FROM bsicrm.bsi_address adr
							JOIN bsicrm.bsi_x_address_mapping am ON am.address_nr = adr.address_nr 
							JOIN bsicrm.bsi_x_ext_join ej2 ON ej2.ext_join_nr = am.ext_join_nr AND ej2.active = 1 AND ej2.interface_uid IN (108187,108205)
						WHERE adr.is_default_address = 1
							AND adr.item_type_id = 318594
						GROUP BY adr.item_key0_nr
					) sadr ON sadr.item_key0_nr = company.company_nr
					LEFT OUTER JOIN bsicrm.bsi_x_address_mapping sspa ON  sspa.ext_join_nr = ejj.ext_join_nr
						AND sspa.join_type_uid = 318594
						AND sspa.type_uid = 2315 /* Hauptadresse */
						AND sspa.channel_uid = 113688
						AND sspa.join_nr = ejj.join_nr             
					LEFT OUTER JOIN bsicrm.bsi_x_address_mapping sspba ON  sspba.ext_join_nr = ejj.ext_join_nr
						AND sspba.join_type_uid = 318594
						AND sspba.type_uid = 108240 /* Postfach */
						AND sspba.channel_uid = 113688
						AND sspba.join_nr = ejj.join_nr

-- Shipping Adresse
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ship_adr au) full(ship_adr) full(au) */
							ship_adr.join_nr,
							max (ship_adr.address_nr) ship_address_nr
						FROM bsicrm.bsi_x_address_mapping ship_adr
							JOIN bsicrm.bsi_address_usage au ON au.address_nr = ship_adr.address_nr
							-- 121799: Korrespondenz EP
							-- 121808: (Adressnutzung von Firmen) Korrespondenz EP
							AND au.usage_uid IN (121799, 121808)
						WHERE ship_adr.join_type_uid = 318594
							AND ship_adr.channel_uid = 113688
							-- (2315:	Hauptadress)
							-- 108353:  Korrespondenz mutiert durch User
							-- 108363:	Korrespondenz mutiert durch User
							AND ship_adr.type_uid in (108353, 108363)
						GROUP BY ship_adr.join_nr
					) ship_a ON ship_a.join_nr = ejj.join_nr  

-- Shipping Postfach Adresse
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ship_ap au) full(ship_ap) full(au) */
							ship_po.join_nr,
							max (ship_po.address_nr) ship_po_nr
						FROM bsicrm.bsi_x_address_mapping ship_po
							JOIN bsicrm.bsi_address_usage au ON au.address_nr = ship_po.address_nr
							-- 121801:  Korrespondenz EP (Postfach)
							-- 121809:  (Adressnutzung von Firmen) Korrespondenzadresse EP (Postfach)
							AND au.usage_uid IN (121801, 121809)
						WHERE ship_po.join_type_uid = 318594
							AND ship_po.channel_uid = 113688
							-- (108240:	Postfach)
							-- 108354:  Korrespondenz mutiert durch User (Postfach)
							-- 108364:	Korrespondenz mutiert durch User (Postfach)
							AND ship_po.type_uid IN (108354, 108364)
						GROUP BY ship_po.join_nr
					) ship_ap ON  ship_ap.join_nr = ejj.join_nr

					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(kd ej2 ejj2) full(kd) full(ej2) full(ejj2) */
							max (kd.join_nr) kuba_join_nr, 
							ejj2.join_nr             
						FROM bsicrm.bsi_x_ext_kuba_data kd
						JOIN bsicrm.bsi_x_ext_join ej2 ON ej2.ext_join_nr = kd.join_nr 
							AND ej2.ext_join_type_uid = kd.join_type_uid AND ej2.active = 1
						JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr 
							AND ejj2.ext_join_type_uid = ej2.ext_join_type_uid
						WHERE kd.status_uid = 4800511372 --aktiv  
						GROUP BY ejj2.join_nr
					) kuba_data ON kuba_data.join_nr = company.company_nr    
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(coll ejinner ejjinner) full(coll) full(ejinner) full(ejjinner) */
							DISTINCT ejjinner.join_nr 
						FROM bsicrm.bsi_x_collection coll 
							JOIN bsicrm.bsi_x_ext_join ejinner ON ejinner.ext_join_nr = coll.ext_company_nr 
								AND ejinner.active = 1
							JOIN bsicrm.bsi_x_ext_join_join ejjinner ON ejjinner.ext_join_nr = ejinner.ext_join_nr
						WHERE coll.status_uid <> 137824
					) collection ON collection.join_nr = company.company_nr 
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ej2 ejj2) full(ej2) full(ejj2) */
							ejj2.join_nr, 
							RTRIM (XMLAGG(XMLELEMENT(E,ej2.join_no,CHR(44)).EXTRACT('//text()') ORDER BY ej2.join_no).getclobval(),',') join_nos_samba
						FROM bsicrm.bsi_x_ext_join ej2
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr
						WHERE ej2.active = 1
							AND ejj2.ext_join_type_uid = 108224
							AND ej2.interface_uid = 108187
						GROUP BY ejj2.join_nr
					) comp_samba ON comp_samba.join_nr =  company.company_nr 
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ej2 ejj2) full(ej2) full(ejj2) */
							ejj2.join_nr, 
							RTRIM (XMLAGG(XMLELEMENT(E,ej2.join_no,CHR(44)).EXTRACT('//text()') ORDER BY ej2.join_no).getclobval(),',') join_nos_nx
						FROM bsicrm.bsi_x_ext_join ej2
							JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr
						WHERE ej2.active = 1
							AND ejj2.ext_join_type_uid = 108224
							AND ej2.interface_uid = 108205
						GROUP BY ejj2.join_nr
					) comp_nx ON comp_nx.join_nr =  company.company_nr  
				WHERE  ejj.is_master = 1
					AND    ejj.ext_join_type_uid = 108224
					AND    ej.interface_uid  = 108187 --samba      
			),
			dunning AS (
				SELECT /*+ ordered use_hash(xrcp ej ejj) full(xrcp) full(ej) full(ejj) */
					distinct ejj.join_nr -- company.x_complex_no                    
				FROM bsicrm.bsi_x_ext_receipt xrcp
					JOIN bsicrm.bsi_x_ext_join ej ON ej.ext_join_nr = xrcp.join_nr
						AND  ej.ext_join_type_uid = xrcp.join_type_uid    -- ??? ej.active = 1
					JOIN bsicrm.bsi_x_ext_join_join ejj ON ejj.ext_join_nr = ej.ext_join_nr 
						AND ejj.ext_join_type_uid = ej.ext_join_type_uid
				WHERE xrcp.overdue_level_uid IN (137663,137664,137665) 
			)  
			SELECT /*+ ordered use_hash(kuba dnng legaladdr cy ap gt cyp shipping_addr shipping_apo cy_sh_po gt_sh_po cy_shipping tkam tlf tnc tne) 
                   full(kuba) full(dnng) full(legaladdr) full(cy) full(ap) full(gt) full(cyp) full(shipping_addr) full(shipping_apo) full(cy_sh_po) full(gt_sh_po) full(cy_shipping) full(tkam) full(tlf) full(tnc) full(tne) */
				distinct ec.x_complex_no uk_LCM_X_COMPLEX_NO__c,
				ec.NAME,
				ec.join_nos_samba LCM_Samba_MergeIDs__c,
				ec.join_nos_nx LCM_NX_MergeIDs__c,
				CASE WHEN ec.fone LIKE '%+4175%' 
					OR ec.fone LIKE '%+4176%'  
					OR ec.fone LIKE '%+4177%'  
					OR ec.fone LIKE '%+4178%'  
					OR ec.fone LIKE '%+4179%'  
				THEN  NULL
				ELSE ec.fone           
				END Phone,
				CASE WHEN ec.fone LIKE '%+4175%' 
					OR ec.fone LIKE '%+4176%'  
					OR ec.fone LIKE '%+4177%'  
					OR ec.fone LIKE '%+4178%'  
					OR ec.fone LIKE '%+4179%' 
				THEN  ec.fone
				ELSE ec.handy           
				END MobilePhone, 
				ec.fax fax, 
				CASE WHEN ec.email LIKE 'etv@%' THEN  NULL
				ELSE ec.email           
				END email__c,
				ec.www website,
				NVL(RTRIM (legaladdr.x_street_name||' '||legaladdr.x_street_house_no), legaladdr.postal_display_street) legalstreet, 
				cy.zip_code LegalPostalCode,
				cy.city legalcity,
				CASE WHEN cy.state IS NULL THEN 
					cyp.state
				ELSE 
					cy.state 
				END LegalState,  
				CASE WHEN cy.country_uid IS NULL THEN 
					DECODE (cyp.country_uid, 
						1001148, 'Schweiz', 
						1001161, 'Deutschland', 
						1001179, 'Frankreich', 
						1001215, 'Italien', 
						1001234, 'Liechtenstein')
				else 
					DECODE (cy.country_uid, 
						1001148, 'Schweiz', 
						1001161, 'Deutschland', 
						1001179, 'Frankreich', 
						1001215, 'Italien', 
						1001234, 'Liechtenstein') 
				END legalcountry, 
				gt.text P_O_Box__c,
				cyp.zip_code P_O_BoxPostalCode__c,
				cyp.city p_o_boxcity__c, 
				DECODE (ec.language_uid, 
					246, 'German', 
					1303, 'English', 
					7770, 'French', 
					7771, 'Italian', '?'
				) PreferedLanguage__c,
				ec.structure__c,
				CASE
					WHEN ec.x_is_locked = 1 THEN 'D'
					WHEN dnng.join_nr IS NOT NULL THEN 'C'
					ELSE NULL           
				END clientrating__c,  

-- START SHIPPING
				CASE WHEN shipping_addr.address_nr IS NULL
				AND shipping_apo.address_nr IS NULL THEN
					NVL(RTRIM (legaladdr.x_street_name||' '||legaladdr.x_street_house_no), legaladdr.postal_display_street)
				ELSE
					regexp_replace (
						COALESCE (
							shipping_addr.x_street_name, 
							shipping_addr.postal_display_street
							), '^([^0-9]*) (\d+[a-zA-Z]{0,3})?$', '\1'
						) ||  ' ' || 
						nvl(shipping_addr.x_street_house_no, 
							ltrim(regexp_substr (
								COALESCE (
									shipping_addr.x_street_name, 
									shipping_addr.postal_display_street
								), ' (\d+[a-zA-Z]{0,3})?$'
							)
						)
					)
				END Shippingstreet, 

				CASE WHEN shipping_addr.address_nr IS NULL
				AND shipping_apo.address_nr IS NULL THEN
					cy.zip_code
				ELSE
					cy_shipping.zip_code 
				END Shippingpostalcode,

				CASE WHEN shipping_addr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					cy.city
				ELSE
					cy_shipping.city 
				END shippingcity,

				CASE WHEN shipping_addr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					cy.state
				ELSE
					cy_shipping.state 
				END ShippingState,

				CASE WHEN shipping_addr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					CASE WHEN cy.country_uid IS NULL THEN
						DECODE (cyp.country_uid, 
							1001148, 'Schweiz', 
							1001161, 'Deutschland', 
							1001179, 'Frankreich', 
							1001215, 'Italien', 
							1001234, 'Liechtenstein')
						else DECODE (cy.country_uid, 
							1001148, 'Schweiz', 
							1001161, 'Deutschland', 
							1001179, 'Frankreich', 
							1001215, 'Italien', 
							1001234, 'Liechtenstein') 
					END 
				ELSE
					DECODE (cy_shipping.country_uid, 
						1001148, 'Schweiz', 
						1001161, 'Deutschland', 
						1001179, 'Frankreich', 
						1001215, 'Italien', 
						1001234, 'Liechtenstein') 
				END ShippingCountry,

				CASE WHEN shipping_addr.address_nr IS NULL
				AND legaladdr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					gt.text
				ELSE 
					gt_sh_po.text
				END ShippingP_O_Box__c,

				CASE WHEN shipping_addr.address_nr IS NULL
				AND legaladdr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					cyp.zip_code
				ELSE 
					cy_sh_po.zip_code
				END ShippingP_O_Box_PostalCode__c,

				CASE WHEN shipping_addr.address_nr IS NULL
				AND legaladdr.address_nr IS NULL 
				AND shipping_apo.address_nr IS NULL THEN
					cyp.city
				ELSE 
					cy_sh_po.city
				END ShippingP_O_BoxCity__c,
-- ENDE SHIPPING

				DECODE (ec.x_advisory_status_uid, 
					117411, 'Fieldsales', 
					117413, 'KAM-Fieldsales'
				) SalesChannel__c,
				tkam.text KAMType__c, 
				CASE WHEN ec.y_legal_status_uid  <> 0 THEN 
					REPLACE(REPLACE(uct_legal_status.TEXT, 'NICHT ZEFIX: ', ''), 'ZEFIX: ', '')
				END legalentity__c,
--				kuba.federal_company_id UID__c,
				ec.y_uid_bur UID__c,
				tnc.text noga1__c,
				CASE WHEN kuba.founding_year = 0 THEN NULL
				ELSE kuba.founding_year
				END  CompanySince__c,
				CASE 
					WHEN kuba.turnover BETWEEN 2000001 AND 99999999 THEN  'A'
					WHEN kuba.turnover BETWEEN 1000001 AND 2000000 THEN  'B'
					WHEN kuba.turnover BETWEEN 200001 AND 1000000 THEN  'C'           
					WHEN kuba.turnover BETWEEN 5001 AND 200000 THEN  'D'             
				END TurnoverClass__c,
				tne.text NumberOfEmployees,
				EC.Allowed_comm_channel__c,
				EC.Communication_Channel__c
			FROM exported_companies ec
				LEFT JOIN bsicrm.bsi_x_ext_kuba_data kuba ON kuba.join_nr = ec.kuba_join_nr
				LEFT JOIN dunning dnng ON dnng.join_nr = ec.join_nr
				LEFT JOIN bsicrm.bsi_address legaladdr ON legaladdr.address_nr = ec.address_nr
				LEFT JOIN bsicrm.bsi_city cy ON cy.city_nr = legaladdr.city_nr
				LEFT JOIN bsicrm.bsi_address ap ON ap.address_nr = ec.pobox_address_nr
				LEFT JOIN bsicrm.bsi_global_text gt ON gt.global_text_nr = AP.postal_po_box_global_text_nr
				LEFT JOIN bsicrm.bsi_city cyp ON cyp.city_nr = AP.city_nr

				LEFT JOIN bsicrm.bsi_address shipping_addr ON shipping_addr.address_nr = ec.ship_address_nr
				LEFT JOIN bsicrm.bsi_address shipping_apo ON shipping_apo.address_nr = ec.ship_po_nr
				LEFT JOIN bsicrm.bsi_city cy_sh_po ON cy_sh_po.city_nr = shipping_apo.city_nr
				LEFT JOIN bsicrm.bsi_global_text gt_sh_po ON gt_sh_po.global_text_nr = shipping_apo.postal_po_box_global_text_nr
				LEFT JOIN bsicrm.bsi_city cy_shipping ON cy_shipping.city_nr = shipping_addr.city_nr

				LEFT JOIN bsicrm.bsi_uc_text tkam ON tkam.uc_uid = ec.kamtyp AND tkam.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tlf ON tlf.uc_uid = kuba.legal_form_uid AND tlf.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tnc ON tnc.uc_uid = kuba.noga_code1_uid AND tnc.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tne ON tne.uc_uid = kuba.number_of_employees_uid AND tne.language_uid = 246
		) LOOP

			vTextLine := REPLACE('"'||r.uk_LCM_X_COMPLEX_NO__c || '","'
					|| r.LCM_Samba_MergeIDs__c || '","'
					|| r.LCM_NX_MergeIDs__c||'","'
					|| REPLACE(REPLACE(r.Name,'"',''''),'''''','''') || '","'
					|| r.Phone || '","'
					|| r.MobilePhone || '","'
					|| r.Fax || '","'
					|| r.Email__c||'","'
					|| r.Website||'","'
					|| REPLACE(REPLACE(r.LegalStreet,'"',''''),'''''','''') || '","'
					|| r.LegalPostalCode || '","'
					|| r.LegalCity || '","'
					|| r.LegalState || '","'
					|| r.LegalCountry || '","'
					|| r.P_O_Box__c || '","'
					|| r.P_O_BoxPostalCode__c|| '","'
					|| r.P_O_BoxCity__c || '","'
					|| r.PreferedLanguage__c || '","'
					|| r.Structure__c || '","'
					|| r.ClientRating__c || '","'
					|| r.SalesChannel__c || '","'
					|| r.KAMType__c||'","'
					|| REPLACE(REPLACE(r.ShippingStreet,'"',''''),'''''','''')|| '","'
					|| r.ShippingPostalCode || '","'
					|| r.ShippingCity || '","'
					|| r.ShippingState || '","'
					|| r.ShippingCountry || '","'
					|| r.ShippingP_O_Box__c || '","'
					|| r.ShippingP_O_Box_PostalCode__c|| '","'
					|| r.ShippingP_O_BoxCity__c || '","'
					|| r.LegalEntity__c || '","'
					|| r.UID__c || '","'
					|| r.NOGA1__c ||'","'
					|| r.CompanySince__c || '","'
					|| r.TurnoverClass__c || '","'
					|| r.NumberOfEmployees||'","'
					|| r.Allowed_comm_channel__c || '","'
					|| r.Communication_Channel__c ||'"','""')||cr;
   
			utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
			utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren

			h := h + 1;
  
		END LOOP;
  
		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl Accounts Samba: '||to_char(h));

	EXCEPTION WHEN others THEN
		vErrorText := 'Fehler bei lcm_accounts_samba: '||sqlerrm;
		dbms_output.put_line(vErrorText);
	END lcm_accounts_samba;


	PROCEDURE main IS
	BEGIN
		lcm_complex_places;
		lcm_complaints;
		lcm_cases;
		lcm_accounts_leads;
		lcm_contacts;
		lcm_accounts_nx;
		lcm_accounts_samba;
		lcm_structure;
		lcm_billingprofile;
	END main;

END export_salesforce_pkg;
/

show err

-- grant execute on bsicrm_ext.export_salesforce_pkg to tluscul1;
