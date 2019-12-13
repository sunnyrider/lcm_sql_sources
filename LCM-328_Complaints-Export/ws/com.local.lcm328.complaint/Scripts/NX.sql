			WITH exported_companies AS (
				SELECT /*+ ordered use_hash(ejj ej prod company cc cc2 a sspa sspba) full(ejj) full(ej) full(prod) full(company) full(cc) full(cc2) full(a) full(sspa) full(sspba) */
					company.x_complex_no,  -- lcm_accounts_nx
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
					ship_a.ship_anr  ship_address_nr,
					ship_ap.ship_apnr ship_apo_nr,
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
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ship_a au) full(ship_a) full(au) */
							ship_a.join_nr, 
							max (ship_a.address_nr) ship_aNr
						FROM bsicrm.bsi_x_address_mapping ship_a
							JOIN bsicrm.bsi_address_usage au ON au.address_nr = ship_a.address_nr
							AND au.usage_uid = 121808 --Adressnutzung von Firmen Korrespondenzadresse EP                     
						WHERE ship_a.join_type_uid = 318594
							AND ship_a.channel_uid = 113688
							-- 2315:	Hauptadress
							-- 108363:	LcmAddressTypeCodeType.CompanyMailingAddressMutatedCode
							AND (ship_a.type_uid = 2315 OR  ship_a.type_uid = 108363)
						GROUP BY ship_a.join_nr
					) ship_a ON  ship_a.join_nr = ejj.join_nr                  
					LEFT OUTER JOIN (
						SELECT /*+ ordered use_hash(ship_ap au) full(ship_ap) full(au) */
							ship_ap.join_nr, 
							max (ship_ap.address_nr) ship_apnr
						FROM bsicrm.bsi_x_address_mapping ship_ap
							JOIN bsicrm.bsi_address_usage au ON au.address_nr = ship_ap.address_nr
							AND au.usage_uid = 121808 --Adressnutzung von Firmen Korrespondenzadresse EP                     
						WHERE ship_ap.join_type_uid = 318594
							AND ship_ap.channel_uid = 113688
							-- 108240:	Postfach
							-- 108364:	LcmAddressTypeCodeType.CompanyMailingAddressMutatedPoBoxCode
							AND (ship_ap.type_uid = 108240 OR  ship_ap.type_uid = 108364)
					GROUP BY ship_ap.join_nr
					) ship_ap ON  ship_ap.join_nr = ejj.join_nr 
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
				regexp_replace(
					coalesce(shipping_addr.x_street_name, shipping_addr.postal_display_street), '^([^0-9]*) (\d+[a-zA-Z]{0,3})?$', '\1'
					) ||  ' ' 
					|| nvl(shipping_addr.x_street_house_no, 
						ltrim(regexp_substr(
							coalesce(shipping_addr.x_street_name, shipping_addr.postal_display_street), ' (\d+[a-zA-Z]{0,3})?$')
					)
				) Shippingstreet, 
				cy_shipping.zip_code Shippingpostalcode,
				cy_shipping.city shippingcity,
				cy_shipping.state ShippingState,
				DECODE (cy_shipping.country_uid, 
					1001148, 'Schweiz', 
					1001161, 'Deutschland', 
					1001179, 'Frankreich', 
					1001215, 'Italien', 
					1001234, 'Liechtenstein'
				) ShippingCountry,
				gt_sh_po.text ShippingP_O_Box__c,
				cy_sh_po.zip_code ShippingP_O_Box_PostalCode__c,
				cy_sh_po.city ShippingP_O_BoxCity__c,
				DECODE (ec.x_advisory_status_uid, 
					117411, 'Fieldsales', 
					117413, 'KAM-Fieldsales'
				) SalesChannel__c,
				tkam.text KAMType__c,  
				CASE WHEN kuba.legal_form_uid IS NOT NULL THEN 
					REPLACE (tlf.text, 'K' || chr(50108) || 'Ba: ', '') 
				WHEN ec.y_legal_status_uid  <> 0 THEN 
					DECODE (ec.y_legal_status_uid, 
						875976469, 'AG', 
						875976471, 'Einzelunternehmen', 
						875976476, 'Genossenschaft', 
						875976472, 'GmbH', 
						875976474, 'Kollektivgesellschaft', 
						5714572491, 'Kommanditgesellschaft', 
						875976464, 'Stiftung', 
						875976459, 'Verein', 
						null
					)  
				END legalentity__c,  
				kuba.federal_company_id UID__c,
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
				LEFT JOIN bsicrm.bsi_address shipping_apo ON shipping_apo.address_nr = ec.ship_apo_nr
				LEFT JOIN bsicrm.bsi_city cy_sh_po ON cy_sh_po.city_nr = shipping_apo.city_nr
				LEFT JOIN bsicrm.bsi_global_text gt_sh_po ON gt_sh_po.global_text_nr = shipping_apo.postal_po_box_global_text_nr
				LEFT JOIN bsicrm.bsi_city cy_shipping ON cy_shipping.city_nr = shipping_addr.city_nr
				LEFT JOIN bsicrm.bsi_uc_text tkam on tkam.uc_uid = ec.kamtyp AND tkam.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tlf on tlf.uc_uid = kuba.legal_form_uid AND tlf.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tnc on tnc.uc_uid = kuba.noga_code1_uid AND tnc.language_uid = 246
				LEFT JOIN bsicrm.bsi_uc_text tne on tne.uc_uid = kuba.number_of_employees_uid AND tne.language_uid = 246
;