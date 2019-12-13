--SEVERE: (START - ComplexResolveService.resolveComplexNo): Query:  
--		SELECT le.complexNo FROM BsiXLegalEntityView AS le WHERE le.key = :b__0 
--		with COMPANY_NR = CompanyKey[8111262126]
--Dec 03, 2019 6:44:25 AM ch.local.crm.server.interfaces.restsync.customer.LcmRestSyncCustomerItemsBaseService.loadCustomerItem(
--		LcmRestSyncCustomerItemsBaseService.java:92)
--SEVERE: ERROR (LcmRestSyncCustomerItemsBaseService.loadCustomerItem) 
--		No COMPLEX_NO found for CUSTOMER_NR = ch.local.crm.server.interfaces.restsync.LcmCustomerSyncItem@7d4c0c0c 
--		*** CONTINUE WITH NEXT COMPANY_NR ***
--Dec 03, 2019 6:44:25 AM ch.local.crm.server.interfaces.restsync.customer.LcmRestSyncCustomerItemsBaseService.loadCustomerItems(
-- 		LcmRestSyncCustomerItemsBaseService.java:59)
--SEVERE: LcmRestSyncCustomerItemsBaseService.loadCustomerItems:  
--		Accessed NULL for CustomerItem with COMPANY_NR = ch.local.crm.server.interfaces.restsync.LcmCustomerSyncItem@7d4c0c0c Continue.
--
 
SELECT LE.X_COMPLEX_NO FROM BSI_LEGAL_ENTITY_VIEW le WHERE LE.COMPANY_NR = 8111262126
;
SELECT CMP.X_COMPLEX_NO FROM BSI_COMPANY cmp WHERE CMP.COMPANY_NR = 8111262126
;


SELECT * FROM BSI_X_JOIN_PRODUCT xjp WHERE XJP.JOIN_KEY0_NR = '8111262126'
;
SELECT * FROM BSI_X_REST_SYNC_ITEM rsi WHERE RSI.ROOT_ITEM_KEY0_NR = '8111262126'
;
SELECT * FROM BSI_DOCUMENT doc WHERE doc.ITEM_KEY0_NR = '8111262126'
;
SELECT * FROM BSI_RECEIPT_CUST_BALANCE_MVIEW rcb WHERE RCB.COMPANY_NR = '8111262126' 
;
SELECT * FROM BSI_X_CONTRACT xcn WHERE XCN.JOIN_NR = '8111262126'
;
SELECT * FROM BSI_X_CONTRACT xcn WHERE XCN.BILLTO_JOIN_NR = '8111262126'
;
SELECT * FROM BSI_X_CUSTOMER_LOCAL_CH clc WHERE CLC.JOIN_NR = '8111262126' 
;
SELECT * FROM BSI_X_INVOICE xiv WHERE XIV.BILLTO_JOIN_NR = '8111262126' 
;
SELECT * FROM BSI_X_INVOICE xiv WHERE XIV.JOIN_NR = '8111262126'
;
SELECT * FROM BSI_X_PRODUCT xpd WHERE XPD.JOIN_NR = '8111262126'
;
SELECT * FROM BSI_X_PRODUCT xpd WHERE XPD.BILLTO_JOIN_NR = '8111262126'
;
SELECT * FROM BSI_X_COMPLEX_PUBLISH xcp WHERE xcp.JOIN_NR = '8111262126'
;
SELECT * FROM BSI_X_COMPLEX_PUBLISH xcp WHERE xcp.JOIN_NR = '8111262126'
;
SELECT * FROM BSI_X_EXT_JOIN_JOIN ejj WHERE EJJ.JOIN_NR = '8111262126'
;
SELECT * FROM BSI_X_CUSTOMER_SEARCH_CH csc WHERE CSC.JOIN_NR = '8111262126'
;
