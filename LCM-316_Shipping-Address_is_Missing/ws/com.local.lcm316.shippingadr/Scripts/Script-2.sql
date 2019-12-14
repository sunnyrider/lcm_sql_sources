CASE WHEN ec.ship_address_nr IS NULL
AND ec.address_nr IS NULL 
AND ec.ship_po_nr IS NULL THEN
	gt.text
ELSE 
	gt_sh_po.text
END ShippingP_O_Box__c,
;

SELECT 
	dbms_lob.getlength(DOC.X_LOCATION_LOB) lob_len,
	dbms_lob.SUBSTR(DOC.X_LOCATION_LOB, 20, 3) sub_location,
	DOC.X_LOCATION_LOB
FROM BSI_DOCUMENT doc
WHERE DOC.X_LOCATION_LOB IS NOT NULL
AND dbms_lob.getlength(DOC.X_LOCATION_LOB) > 25
AND dbms_lob.SUBSTR(LOWER(DOC.X_LOCATION_LOB), 3, 20) LIKE LOWER('sg1473p\Archive\2018%')
;

--WHERE lower(doc.X_LOCATION_LOB) LIKE '%sg1473p%'