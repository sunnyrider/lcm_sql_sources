SELECT ext_join_nr from BSI_X_ADDRESS_MAPPING group by ext_join_nr, join_type_uid, type_uid, channel_uid having count(*) > 1;

SELECT * from BSI_X_ADDRESS_MAPPING 
WHERE EXT_JOIN_NR IN (
	SELECT ext_join_nr from bsi_x_address_mapping group by EXT_JOIN_NR, JOIN_TYPE_UID, TYPE_UID, CHANNEL_UID having count(*) > 1
);


SELECT * FROM  BSI_X_ADDRESS_MAPPING am
WHERE AM.ADDRESS_NR IN (7505145947, 6915541245, 5079653861);
--DELETE FROM  BSI_X_ADDRESS_MAPPING am
--WHERE AM.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);


SELECT * FROM BSI_ADDRESS adr
WHERE ADR.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);
--DELETE FROM BSI_ADDRESS adr
--WHERE ADR.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);


SELECT * FROM BSI_X_EXT_ADDRESS adr WHERE adr.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);
-- keine Daten

SELECT * FROM BSI_ADDRESS_USAGE adr
WHERE ADR.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);
-- keine Daten

SELECT * FROM BSI_X_EXT_LCM_ADDRESS adr
WHERE ADR.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);
-- keine Daten

SELECT * FROM BSI_X_EXT_SCA_ADDRESS adr
WHERE ADR.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);
-- keine Daten

SELECT * FROM BSI_X_LOCATION_ADDRESS_MAP adr
WHERE ADR.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);
-- keine Daten


SELECT DISTINCT ATC.TABLE_NAME 
	FROM sys.ALL_TAB_COLUMNS atc
WHERE lower(ATC.OWNER) = lower('BSICRM') 
AND lower(ATC.COLUMN_NAME) = lower('ADDRESS_NR');

SELECT * FROM BSI_ACTION_RECIPIENT adr WHERE ADR.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);
-- keine Daten
SELECT * FROM BSI_PERSON_INTEREST adr WHERE ADR.ADDRESS_NR IN (7505145947, 7505145943, 5079653861);
-- keine Daten





------------------------------------
--Delete Ext Address    
Delete FROM bsicrm.bsi_x_ext_address adr
WHERE adr.join_nr IN (SELECT ej.ext_join_nr
             FROM bsicrm.bsi_x_ext_join ej
            JOIN bsicrm.bsi_x_ext_join_join ejj ON ejj.ext_join_nr = ej.ext_join_nr
            JOIN bsicrm.bsi_company company ON company.company_nr = ejj.join_nr  
            WHERE company.company_nr = 20107401);
            
-- Delete address Mapping
Delete FROM  bsicrm.bsi_x_address_mapping am
WHERE  am.address_nr IN ( SELECT A.address_nr 
                        FROM bsicrm.bsi_address A
                        JOIN bsicrm.bsi_x_address_mapping am ON A.address_nr = am.address_nr
                        JOIN  bsicrm.bsi_company company ON   company.company_nr = A.item_key0_nr        
            WHERE company.company_nr = 20107401);

--Delete address 
Delete  FROM bsicrm.bsi_address A
WHERE A.item_key0_nr IN (SELECT company.company_nr
                        FROM bsicrm.bsi_company company 
            WHERE company.company_nr = 20107401);


select ejj.join_no, count(ejj.join_no) as Anzahl from bsi_x_ext_join_join ejj
group by ejj.join_no
having count(ejj.join_no) > 1;

select ejj.* from bsi_x_ext_join_join ejj
where ejj.join_no in (
  select ijj.join_no from bsi_x_ext_join_join ijj
  group by ijj.join_no
  having count(*) > 1)
;

select ejj.* from bsi_x_ext_join_join ejj
where ejj.join_no in (
  select ijj.join_no from bsi_x_ext_join_join ijj
  group by ijj.join_no 
  having count(*) > 1)
and ejj.is_master = 1;
