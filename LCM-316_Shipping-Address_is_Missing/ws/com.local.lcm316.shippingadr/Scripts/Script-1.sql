SELECT 
	CMP.company_no kundennummer,
	CMP.x_complex_no komplexnummer,
	lcmutl_createCompanyName(CMP.name1, CMP.name2, CMP.name3) firmenname,
	bsiutl_uctext(CMP.language_uid, 246) sprache,
	COALESCE(
		(SELECT channel_value
		FROM BSI_ADDRESS adr 
		WHERE ADR.ITEM_KEY0_NR = CMP.company_nr 
		AND item_type_id = 318594 
		AND is_default_address = 1 
		AND channel_uid = 113641
		), (
		SELECT channel_value 
		FROM bsi_address
		WHERE item_key0_nr = ar.person_nr 
		AND item_type_id = 318596 
		AND is_default_address = 1 
		AND channel_uid = 113641
		)
	) email
FROM   bsi_action_recipient ar
JOIN   bsi_company CMP ON CMP.company_nr = ar.company_nr AND CMP.is_active = 1
--WHERE  ar.action_nr = (SELECT action_nr FROM bsi_action WHERE display_name = 'SEL_B2B Newsletter DE August 17')
--AND    ar.status_uid = 315464 /* Vorgesehen */
;


SELECT /*+ ordered use_hash(ship_adr au) full(ship_adr) full(au) */
	DISTINCT
	ship_adr.join_nr,
	ship_adr.type_uid,
	au.usage_uid,
	ship_adr.address_nr ship_address_nr
--	max (ship_adr.address_nr) ship_address_nr
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
	AND SHIP_ADR.JOIN_NR IN (20881522)
--GROUP BY ship_adr.join_nr
;
--1500525702

SELECT
	DISTINCT
	ship_po.join_nr,
	au.usage_uid,
	ship_po.type_uid,
	ship_po.address_nr
--	max (ship_po.address_nr) ship_po_nr
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
	AND SHIP_PO.JOIN_NR IN (20881522)
--GROUP BY ship_po.join_nr
;




SELECT CMP.X_COMPLEX_NO, CMP.COMPANY_NO, CMP.COMPANY_NR FROM BSI_COMPANY cmp WHERE X_COMPLEX_NO IN (
16878595)
;


WITH pre_sel AS
(
	SELECT 
		ship_adr.join_nr,
		max (ship_adr.address_nr) ship_address_nr
	FROM bsicrm.BSI_X_ADDRESS_MAPPING ship_adr
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
		AND SHIP_ADR.JOIN_NR IN (21961762)
	GROUP BY ship_adr.join_nr
)
SELECT * FROM pre_sel psl
	INNER JOIN BSI_ADDRESS adr
	ON ADR.ADDRESS_NR = PSL.ship_address_nr
;

WITH pre_sel AS
(
	SELECT
		ship_po.join_nr,
		max (ship_po.address_nr) ship_po_nr
	FROM bsicrm.BSI_X_ADDRESS_MAPPING ship_po
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
		AND SHIP_PO.JOIN_NR IN (21961762)
	GROUP BY ship_po.join_nr
)
SELECT * FROM pre_sel psl
	INNER JOIN BSI_ADDRESS adr
	ON ADR.ADDRESS_NR = PSL.ship_po_nr
;


