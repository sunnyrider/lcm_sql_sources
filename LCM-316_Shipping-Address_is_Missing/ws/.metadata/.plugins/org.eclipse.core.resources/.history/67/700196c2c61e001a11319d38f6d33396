SELECT CMP.X_COMPLEX_NO, CMP.COMPANY_NO, CMP.COMPANY_NR FROM BSI_COMPANY cmp WHERE X_COMPLEX_NO IN (
16932835)
;
-- NX-Companies mit fehlender Shipping-Adresse
--COMPANY_NO	COMPANY_NR
--1000176050	19334775
--1000347579	19486407
--1000420670	1755785199
--1001382289	20397797
--1001412930	20424724
--1001987811	20915652
--1002326146	21173876
--1002522992	21322796
--1002577779	21363927
--1003275066	21891951
--1003421949	22002573
--1003915231	22371869
--1005184632	23280418
--1005559663	23585557
--1006061919	24010464
--1006715667	24558693
--1007573311	25268116
--1007973598	730596823


SELECT CMP.X_COMPLEX_NO, CMP.COMPANY_NO, CMP.COMPANY_NR FROM BSI_COMPANY cmp WHERE CMP.COMPANY_NO IN (
17533065)
;

select * FROM bsicrm.bsi_x_rest_sync_item WHERE item_type_id = 318594 AND root_item_type_id = 318594 
AND NOT EXISTS (SELECT 0 FROM bsicrm .bsi_company WHERE company_nr = root_item_key0_nr);
;


SELECT DISTINCT JOIN_TYPE_UID FROM bsi_x_address_mapping
;
-- KEINE Datensätze in BSI_UC
--318596
--318594


SELECT 
	UCT.UC_UID, UCT.TEXT, UC.CODE_TYPE, UC.PARENT_UID 
FROM BSI_UC uc INNER JOIN BSI_UC_TEXT uct ON UCT.UC_UID = UC.UC_UID 
--WHERE UCT.UC_UID IN (121809,121799,113501,121795)
-- Address_Type_UID
--WHERE UC.UC_UID IN (121808, 121809, 108363, 108364)
-- BSI_ADDRESS_USAGE.USAGE_UID
--WHERE UC.UC_UID IN (121625,121626,121795,113501,121801,121809,113502,121808,121811,121796,121799,142513,121810)
-- BSI_X_ADDRESS_MAPPING.TYPE_UID
WHERE UC.UC_UID IN (2315,108363,108364,108365,108240,108353,108366,2470,108354,108241)
--WHERE LOWER(UCT.TEXT) LIKE LOWER('Korrespondenz%E%')
AND UCT.LANGUAGE_UID = '246'
;

-- Address_Type_UID
-- 121808, 121809, 108363, 108364
--
-- 113497: KEINE CodeType Klasse in LCM!
--UC_UID	TEXT
--121808	Korrespondenz EP
--121809	Korrespondenz EP (Postfach)
--
-- 71068:  AddressTypeCodeType
--UC_UID	TEXT
--108363	Korrespondenz mutiert durch User
--108364	Korrespondenz mutiert durch User (Postfach)
--2315		Hauptadresse

-- 113497 = AddressUsageCodeType
--
SELECT UCT.UC_UID, UCT.TEXT, UCT.LANGUAGE_UID, UC.PARENT_UID, uc.CODE_TYPE 
FROM BSI_UC uc INNER JOIN BSI_UC_TEXT uct ON UCT.UC_UID = UC.UC_UID 
WHERE UC.CODE_TYPE IN (318593)
AND UCT.LANGUAGE_UID = '246'
;



SELECT DISTINCT XAM.TYPE_UID FROM BSI_X_ADDRESS_MAPPING xam 
;
--TYPE_UID	TEXT
--2315		Hauptadresse
--2470		Privatadresse
--108240	Hauptadresse (Postfach)
--108241	Privatadresse (Postfach)
--108353	Korrespondenz mutiert durch User
--108354	Korrespondenz mutiert durch User (Postfach)
--108363	Korrespondenz mutiert durch User
--108364	Korrespondenz mutiert durch User (Postfach)
--108365	Rechnungsadresse EP
--108366	Rechnungsadresse EP (Postfach)


SELECT DISTINCT ADRU.USAGE_UID FROM bsi_address_usage adru 
;
--USAGE_UID		TEXT
--113501		Privat
--113502		Korrespondenz WP
--121625		Rechnung WP
--121626		Vertrag WP
--121795		Hauptadresse (Postfach)
--121796		Privat (Postfach)
--121799		Korrespondenz EP
--121801		Korrespondenz EP (Postfach)
--121808		Korrespondenz EP
--121809		Korrespondenz EP (Postfach)
--121810		Rechnung EP
--121811		Rechnung EP (Postfach)
--142513		Inhaber (KüBa)


SELECT /*+ ordered use_hash(am au ba city) full(am) full(au) full(ba) full(city) */
	am.ext_join_nr, 
	am.type_uid, -- = 108365
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