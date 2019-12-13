SELECT value FROM V$PARAMETER
--where lower(VALUE) like lower('sf_ex%') 
;

ALTER system SET utl_file_dir = '/u02/oracle/fast_recovery_area/CRMTER/controlfile/control1.ctl', '/u02/oracle/oradata/CRMTER/controlfile/control2.ctl' SCOPE = spfile;

DECLARE
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

begin

	h := 0;

	SELECT 'LCM_contacts_'||SUBSTR(global_name,1,6)||'_'||TO_CHAR(sysdate,'YYYYMMDD_HH24MI')||'.csv' into vFileNamecsv FROM global_name;

	dbms_output.put_line('Export lcm_contacts, FileName '||vFileNamecsv);

	vCntrlFilecsv := utl_file.fopen(vDirectoryPath, vFileNamecsv,'w', buffer_size);

	vTextLine     := 'uk_LCM_X_COMPLEX_NO,uk_LCM_PERSON_NR,Salutation,Title,FirstName,LastName,Phone,MobilePhone,Fax,Email,PreferedLanguage__c,MailingStreet,MailingPostalCode,MailingCity,MailingState,MailingCountry';
			
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
				WHEN 1001119 THEN 'Österreich' 
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
				AND trim(ps.last_name) not in ('$','*','**','*/',',,','-','--','---','-.',':',';','?','??','^','¨',':','-','0','00')
				AND ps.last_name not like '%?%'
			group by cp_join.company_nr, RTRIM (trim(ps.first_name),chr(9)), RTRIM (TRIM(ps.last_name),chr(9))
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
	) loop

		vTextLine := REPLACE('"'||r.uk_LCM_X_COMPLEX_NO||'","'||r.uk_LCM_PERSON_NR||'","'||r.Salutation||'","'||r.Title||'","'||REPLACE(REPLACE(r.FirstName,'"',''''),'''''','''')||'","'||REPLACE(REPLACE(r.LastName,'"',''''),'''''','''')||'","'||r.Phone||
                    '","'||r.MobilePhone||'","'||r.Fax||'","'||r.Email||'","'||r.PreferedLanguage__c||'
					","'||REPLACE(REPLACE(r.MailingStreet,'"',''''),'''''','''')||'","'||r.MailingPostalCode||'","'||r.MailingCity||
					'","'||r.MailingState||'","'||r.MailingCountry||
					'"','""')||cr;
             
		utl_file.put_line(vCntrlFilecsv, convert(vTextLine,c_Charakterset_Out,c_Charakterset_DB));
		utl_file.fflush(vCntrlFilecsv);    -- Schreibpuffer leeren
  
			h := h + 1;

		END loop;
  
		utl_file.fclose(vCntrlFilecsv);  -- Close the file
		dbms_output.put_line('Anzahl lcm_contacts: '||to_char(h));

	exception WHEN others THEN
		vErrorText := 'Fehler bei lcm_contacts: '||sqlerrm;
		dbms_output.put_line(vErrorText);
END;