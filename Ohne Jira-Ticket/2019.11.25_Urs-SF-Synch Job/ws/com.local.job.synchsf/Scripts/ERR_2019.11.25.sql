--Nov 21, 2019 8:41:15 PM org.hibernate.engine.jdbc.spi.SqlExceptionHelper logExceptions
--ERROR: ORA-00001: unique constraint (BSICRM.BSI_X_USER_LOGINX1) violated
--
SELECT 
	XUL.LOGIN_USER_NR,
	count(XUL.LOGIN_USER_NR) Anzahl 
FROM BSI_X_USER_LOGIN xul
GROUP BY XUL.LOGIN_USER_NR
HAVING COUNT(XUL.LOGIN_USER_NR) > 1
;
-- 1000

SELECT 
	XUL.USER_LOGIN_NR,
	count(XUL.USER_LOGIN_NR) Anzahl 
FROM BSI_X_USER_LOGIN xul
GROUP BY XUL.USER_LOGIN_NR
HAVING COUNT(XUL.USER_LOGIN_NR) > 1
;
-- 0

 SELECT le.complexNo FROM Bsi_X_Legal_Entity_View AS le WHERE le.key = 23748181
 ;


alter session set current_schema=bsicrm;
SET SERVEROUTPUT ON SIZE 100000;

DECLARE
	match_count INTEGER;
BEGIN
	FOR t IN (
		SELECT atc.OWNER, ATC.TABLE_NAME, ATC.COLUMN_NAME
		FROM SYS.ALL_TAB_COLUMNS atc
		WHERE upper(ATC.OWNER) = 'BSICRM'
		and UPPER(atc.table_name) not LIKE ('BSI_UC_%')
		AND UPPER(ATC.TABLE_NAME) NOT IN ('BSI_USER', 'BSI_USER_ACL', 'BSI_USER_LIST', 'BSI_USER_NOTIFY', 'BSI_USER_PARTITION', 'BSI_USER_READ', 'BSI_USER_ROLE', 'BSI_USER_SUBSTITUTE', 'BSI_USER_TARGET', 'BSI_X_ACCOUNT_STATEMENT', 'BSI_X_ACCOUNT_STATEMENT_ITEM', 'BSI_X_ACTION_LEAD', 'BSI_X_ADDRESS_MAPPING', 'BSI_X_ADVISORY_STATUS', 'BSI_X_AUSZAHLUNGEN', 'BSI_X_AUTO_MERGE_CANDIDATE', 'BSI_X_BACK_OFFICE_ASSIGNMENT', 'BSI_X_BAD_GEOLOCATION', 'BSI_X_BAD_GEOLOCATION', 'BSI_X_BAD_HOUSENUMBER', 'BSI_X_BAD_HOUSENUMBER_ALT', 'BSI_X_BAD_STREET', 'BSI_X_BAD_STREET_ALT', 'BSI_X_BAD_ZIP', 'BSI_X_BANK_INFORMATION', 'BSI_X_BUDG_PER_REF_GR_CHANGE', 'BSI_X_BUDG_PERIOD_REF_GROWTH', 'BSI_X_BUDGETING_COMPANY', 'BSI_X_BUDGETING_POTENTIAL', 'BSI_X_CASE_COMPLAINT', 'BSI_X_CASE_FRAME_CSV_LOG', 'BSI_X_CASE_FRAME_RESP_HIST', 'BSI_X_CASE_STEP_HISTORY', 'BSI_X_CITY_CHANGE', 'BSI_X_CITY_MOD_RESP_TASK', 'BSI_X_COLLECTION', 'BSI_X_COLLECTION_CHANGE', 'BSI_X_COLLECTION_RECEIPT', 'BSI_X_COMMUNICATION_OUTPUT', 'BSI_X_COMMUNICATION_PROTOCOL', 'BSI_X_COMPANY_SECTOR', 'BSI_X_COMPANY_SPOC_ADVISOR_1', 'BSI_X_COMPANY_SPOC_ADVISOR_2', 'BSI_X_COMPANY_STRUCT_CSV_LOG', 'BSI_X_COMPANY_STRUCTURE_0', 'BSI_X_COMPANY_STRUCTURE_1', 'BSI_X_COMPANY_STRUCTURE_2', 'BSI_X_COMPANY_STRUCTURE_3', 'BSI_X_COMPANY_STRUCTURE_4', 'BSI_X_COMPANY_TOKEN_RAW', 'BSI_X_COMPANY_VARIETY', 'BSI_X_COMPLAINT', 'BSI_X_COMPLAINT_CHANGE', 'BSI_X_COMPLAINT_COMMUNICATION', 'BSI_X_COMPLAINT_LIST', 'BSI_X_COMPLAINT_SOLUTION', 'BSI_X_COMPLEX_HISTORY', 'BSI_X_COMPLEX_PUBLISH', 'BSI_X_CONNECTION_ADR', 'BSI_X_CONNECTION_ADR', 'BSI_X_CONNECTION_ADR_DUPLICATE', 'BSI_X_CONTRACT', 'BSI_X_CONTRACT_CHANGE', 'BSI_X_CONTRACT_DATA', 'BSI_X_CORRESPONDENCE', 'BSI_X_CREDIT_RST_AMNT_GUT_VIEW', 'BSI_ACTION', 'BSI_ACTION_ADDRESSING', 'BSI_ACTION_LANGUA_ATTACHMENT', 'BSI_ACTION_LANGUA_ATTACHMENT', 'BSI_ACTION_LANGUAGE', 'BSI_ACTION_LIST', 'BSI_ACTION_REACTION', 'BSI_ACTION_REACTION_LANGUAGE', 'BSI_ACTION_RECIPIENT', 'BSI_ACTION_RECIPIENT_HISTORY', 'BSI_ACTION_SEARCH', 'BSI_ADDRESS', 'BSI_ADDRESS_USAGE', 'BSI_ADDRESS_USAGE_PRIOR_VIEW', 'BSI_BAD_CITY', 'BSI_BANK_CONNECTION', 'BSI_BANK_CONNECTION_CHANGE', 'BSI_BANK_CONNECTION_LIST', 'BSI_BOOKMARK', 'BSI_BOOKMARK_USER', 'BSI_BUSINESS', 'BSI_BUSINESS_CHANGE', 'BSI_BUSINESS_COMPANY', 'BSI_BUSINESS_LIST', 'BSI_BUSINESS_PERSON', 'BSI_BUSINESS_PHAS_GROUP_ROLE', 'BSI_BUSINESS_PHASE', 'BSI_BUSINESS_PRODUCT', 'BSI_BUSINESS_PRODUCT_LIST', 'BSI_BUSINESS_ROLE_VIEW', 'BSI_BUSINESS_STATUS', 'BSI_BUSINESS_TOKEN', 'BSI_CAMPAIGN', 'BSI_CAMPAIGN_LIST', 'BSI_CAPTURE_PLAN_CATEGORY', 'BSI_CAPTURE_PLAN_EVALUATION', 'BSI_CAPTURE_PLAN_INFLUENCE', 'BSI_CAPTURE_PLAN_RED_FLAG', 'BSI_CASE', 'BSI_CASE_FRAME', 'BSI_CASE_FRAME_ITEM', 'BSI_CASE_FRAME_STATS_VIEW', 'BSI_CASE_FRAME_STEP', 'BSI_CASE_LIST', 'BSI_CASE_STEP', 'BSI_CASE_STEP_ITEM', 'BSI_CASE_STEP_OUTPUT', 'BSI_CATEGORY', 'BSI_CATEGORY_ITEM', 'BSI_CATEGORY_USER', 'BSI_CHILD', 'BSI_CITY', 'BSI_COMMUNICATION', 'BSI_COMMUNICATION_CHANGE', 'BSI_COMMUNICATION_LIST', 'BSI_COMMUNICATION_PERSON', 'BSI_COMMUNICATION_REACT_LIST', 'BSI_COMMUNICATION_REACTION', 'BSI_COMMUNICATION_STATUS', 'BSI_COMMUNICATION_TOKEN', 'BSI_COMPANY', 'BSI_COMPANY_ADVISOR', 'BSI_COMPANY_CHANGE', 'BSI_COMPANY_COMPANY', 'BSI_COMPANY_COMPANY_LIST', 'BSI_COMPANY_FIGURE', 'BSI_COMPANY_IMPORT', 'BSI_COMPANY_LIST', 'BSI_COMPANY_PARTITION', 'BSI_COMPANY_PERSON', 'BSI_COMPANY_SEGMENTATION', 'BSI_COMPANY_TOKEN', 'BSI_COURSE', 'BSI_COURSE_PERSON', 'BSI_COURSE_QUESTION', 'BSI_COURSE_QUESTION_PERSON', 'BSI_CTI_CALL', 'BSI_DEFAULT_ADDRESS_VIEW', 'BSI_DELIVERY', 'BSI_DISTRIBUTOR', 'BSI_DISTRIBUTOR_PERSON', 'BSI_DOCUMENT', 'BSI_DUAL', 'BSI_DWH_INDEX', 'BSI_EMAIL_ACCOUNT', 'BSI_EMAIL_MESSAGE', 'BSI_EMAIL_MESSAGE_ATTACHMENT', 'BSI_EMAIL_MESSAGE_LOG', 'BSI_EMAIL_SMTP', 'BSI_EMPLOYEE', 'BSI_EMPLOYEE_HISTORY', 'BSI_EMPLOYEE_LIST', 'BSI_EMPLOYEE_MONTH', 'BSI_EMPLOYEE_YEAR', 'BSI_FILE_IMPORT', 'BSI_FILE_IMPORT_LOG', 'BSI_FOLDER', 'BSI_FOLDER_CONTENT', 'BSI_GLOBAL_COUNTER', 'BSI_GLOBAL_COURSE_QUESTION', 'BSI_GLOBAL_DATABASE_CONSTANT', 'BSI_GLOBAL_IMPORT_FILTER', 'BSI_GLOBAL_INTERFACES_LOG', 'BSI_GLOBAL_INTERFACES_LOG', 'BSI_GLOBAL_KEY_MERGE', 'BSI_GLOBAL_TEXT', 'BSI_GLOBAL_TEXT_SUBSTITUTION', 'BSI_GLOBAL_VERSION', 'BSI_GROUPWARE_LINK', 'BSI_IMPORT_CITY', 'BSI_IMPORT_COMPANY', 'BSI_IMPORT_DATA', 'BSI_IMPORT_DATA_DUPLICATE', 'BSI_IMPORT_DATA_EXISTING', 'BSI_IMPORT_META', 'BSI_IMPORT_PERSON', 'BSI_INDEXES', 'BSI_INSTALLED_BASE', 'BSI_ITEM_SUMMARY', 'BSI_JOB', 'BSI_JOB_CHANGE', 'BSI_JOB_LOCK', 'BSI_JOB_LOG', 'BSI_JOB_NOTIFICATION', 'BSI_JOB_RUN', 'BSI_JOB_RUN_FILE', 'BSI_KNOWLEDGE', 'BSI_KNOWLEDGE_LANGUAGE', 'BSI_KNOWLEDGE_PERSON', 'BSI_KNOWLEDGE_PROCESS', 'BSI_LEGAL_ENTITY_ADVISO_VIEW', 'BSI_LEGAL_ENTITY_CHANNEL', 'BSI_LEGAL_ENTITY_VIEW', 'BSI_LUNCH', 'BSI_LUNCH_PERSON', 'BSI_MONTHLY_WORK', 'BSI_PARAMETER', 'BSI_PARAMETER_20150430', 'BSI_PARAMETER_PARTITION', 'BSI_PAYMENT', 'BSI_PAYMENT_CHANGE', 'BSI_PAYMENT_LIST', 'BSI_PAYMENT_POSITION', 'BSI_PAYMENT_STATUS', 'BSI_PERSON', 'BSI_PERSON_ADVISOR', 'BSI_PERSON_CHANGE', 'BSI_PERSON_COMPAN_TOKEN_VIEW', 'BSI_PERSON_IMPORT', 'BSI_PERSON_INTEREST', 'BSI_PERSON_INTEREST_REPORTER', 'BSI_PERSON_LIST', 'BSI_PERSON_RELATION', 'BSI_PERSON_TOKEN', 'BSI_PHYSICAL_ADDR_USAGE_VIEW', 'BSI_PORTFOLIO', 'BSI_PORTFOLIO_BUSINESS', 'BSI_PORTFOLIO_EMPLOYEE_WEEK', 'BSI_PORTFOLIO_WEEK', 'BSI_PROJECT_ACTIVITY', 'BSI_PROJECT_ACTIVITY_LIST', 'BSI_RECEIPT_CUST_BALANCE_MVIEW', 'BSI_RELATION', 'BSI_RELATION_LIST', 'BSI_RESOURCE', 'BSI_S1_CITY', 'BSI_S2_CITY', 'BSI_SEMAPHORE', 'BSI_SERIES_PATTERN', 'BSI_SERVICE_LIN_EMAI_ACCOUNT', 'BSI_SERVICE_LINE', 'BSI_SERVICE_LINE_CHAN_STATUS', 'BSI_SERVICE_LINE_PROCESS', 'BSI_SERVICE_LINE_ROUTING', 'BSI_SERVICE_LINE_TEAM', 'BSI_SERVICE_LINE_WEEKDAY', 'BSI_SERVICELINE_EMAIL_ACCOUNT', 'BSI_SHARING', 'BSI_SOURCE_MAPPING', 'BSI_STEP_BINDING_DYNAMIC', 'BSI_TARGET_PLAN', 'BSI_TARGET_PLAN_ANALYSIS', 'BSI_TARGET_PLAN_COMPETITOR', 'BSI_TARGET_PLAN_PERSON', 'BSI_TARGET_PLAN_RED_FLAG', 'BSI_TASK', 'BSI_TASK_CHANGE', 'BSI_TASK_LIST', 'BSI_TASK_TOKEN', 'BSI_TEAM_USER', 'BSI_TEMPLATE_RT_CASE_STEP', 'BSI_TESTCASE', 'BSI_TESTCASE_TICKET', 'BSI_TESTCYCLE', 'BSI_TICKER', 'BSI_TICKER_USER', 'BSI_TICKET', 'BSI_TICKET_HISTORY', 'BSI_TICKET_LIST', 'BSI_TICKET_TOKEN', 'BSI_TWITTER_JOB_RUN_CASE', 'BSI_TWITTER_SEARCH', 'BSI_X_CUSTOMER_CHURNING', 'BSI_X_CUSTOMER_LOCAL_CH', 'BSI_X_CUSTOMER_ONL_CHURNING', 'BSI_X_CUSTOMER_QUADRANT', 'BSI_X_CUSTOMER_SEARCH_CH', 'BSI_X_DEPARTMENT_DETAIL', 'BSI_X_DSMP_OB_CUSTOMER', 'BSI_X_DUPLICATE_RELATIONS', 'BSI_X_DUPLICATE_RELATIONS_U', 'BSI_X_DUPLICATE_RELATIONS0', 'BSI_X_DUPLICATE_RELATIONS1', 'BSI_X_DUPLICATE_REPORT', 'BSI_X_EDIT_COMPLAINT_STEP', 'BSI_X_EXT_ACTIVE_DIR_LOC', 'BSI_X_EXT_ACTIVE_PROD_SECTOR', 'BSI_X_EXT_ADDRESS', 'BSI_X_EXT_COMPANY_EXT_COMPANY', 'BSI_X_EXT_COMPANY_SECTOR', 'BSI_X_EXT_CUSTOMER_PRODUCT', 'BSI_X_EXT_INITIAL_PRODUCT', 'BSI_X_EXT_INVOICE', 'BSI_X_EXT_JOIN', 'BSI_X_EXT_JOIN_HASH', 'BSI_X_EXT_JOIN_JOIN', 'BSI_X_EXT_JOIN_JOIN_UPDATES', 'BSI_X_EXT_JOIN_MASTER', 'BSI_X_EXT_JOIN_TOKEN', 'BSI_X_EXT_JOIN_TOKENS_1', 'BSI_X_EXT_JOIN_TOKENS_2', 'BSI_X_EXT_JOIN_TOKENS_3', 'BSI_X_EXT_JOIN_TOKENS_4', 'BSI_X_EXT_KUBA_DATA', 'BSI_X_EXT_LCM_ADDRESS', 'BSI_X_EXT_LCM_JOIN_UPDATES', 'BSI_X_EXT_LISTING_RANGE', 'BSI_X_EXT_LTV_SD_MAPPING', 'BSI_X_EXT_PCA_SCA_ADDRESS', 'BSI_X_EXT_PROD_PROD_CONDENSED', 'BSI_X_EXT_PRODUCT', 'BSI_X_EXT_PRODUCT_CONDENSED', 'BSI_X_EXT_PRODUCTPERIOD', 'BSI_X_EXT_RECEIPT', 'BSI_X_EXT_SCA_ADDRESS', 'BSI_X_EXT_TENTATIVE_JOIN', 'BSI_X_FIRSTNAME', 'BSI_X_FS_UPDATE_COMPANY', 'BSI_X_FS_UPDATE_PERSON', 'BSI_X_HOUSENUMBER', 'BSI_X_HOUSENUMBER_ALTERNATIVE', 'BSI_X_IBAN', 'BSI_X_INSTALLMENT', 'BSI_X_INSTALLMENT_AGREEMENT', 'BSI_X_INVOICE', 'BSI_X_INVOICE_AGREEMENT', 'BSI_X_INVOICE_COPY_ORDER', 'BSI_X_INVOICE_DETAIL', 'BSI_X_ITEM_SUMMARY_SCHEMA', 'BSI_X_JOIN_DUPLICATE_MVIEW', 'BSI_X_JOIN_DUPLICATE_MVIEW1', 'BSI_X_JOIN_PRODUCT', 'BSI_X_JOIN_SELECTION', 'BSI_X_LEAD_CONTRACT', 'BSI_X_LISTING', 'BSI_X_LISTING_RANGE', 'BSI_X_LOCATION_ADDRESS_MAP', 'BSI_X_MASTER_SWITCH_HISTORY', 'BSI_X_MATERIALIZED_VIEW', 'BSI_X_MUNICIPALITY', 'BSI_X_NOVIS_ACTION_STATUS', 'BSI_X_NOVIS_AD_STAR_ACTION', 'BSI_X_NOVIS_CONTACT_ACTION', 'BSI_X_NOVIS_CREATE_OFFER', 'BSI_X_NOVIS_CUST_DATA_PAY_FLAG', 'BSI_X_NOVIS_DIRECTORY_LOC', 'BSI_X_NOVIS_INVOICE_HISTORY', 'BSI_X_NOVIS_LCM_ACTION_STATUS', 'BSI_X_NOVIS_LETTER_CHAN_ACTION', 'BSI_X_NOVIS_LISTING_HISTORY', 'BSI_X_NOVIS_LISTTYPE_ACTION', 'BSI_X_NOVIS_MODIFY_ENTRY', 'BSI_X_NOVIS_MONITORING', 'BSI_X_NOVIS_OFFER_REPLACE', 'BSI_X_NOVIS_OVERDUE_BLK_ACTION', 'BSI_X_NOVIS_PRODUCT_HISTORY', 'BSI_X_NOVIS_PRODUCT_TO_PURGE', 'BSI_X_NOVIS_PURGE_PROD_ACTION', 'BSI_X_NOVIS_REV_INVOICE_ACTION', 'BSI_X_NOVIS_SECTOR', 'BSI_X_NOVIS_SEND_INVOICE', 'BSI_X_NOVIS_SEND_LETTER_ACTION', 'BSI_X_NOVIS_UPD_ENTRY_OVERVIEW', 'BSI_X_NOVIS_WS_DATA', 'BSI_X_OFFER', 'BSI_X_OFFER_CHANGE', 'BSI_X_OFFER_CONTRACT', 'BSI_X_OFFER_DATA', 'BSI_X_OFFER_DIR_LOC', 'BSI_X_OFFER_DIRECTORY', 'BSI_X_OFFER_DOCUMENT', 'BSI_X_PERFORMANCE_MONITOR', 'BSI_X_PERSON_TOKEN_RAW', 'BSI_X_PERSON_TOKENS', 'BSI_X_PERSON_TYPE', 'BSI_X_PRECOMP_CUST_DATA', 'BSI_X_PRECOMP_CUST_DATA_LIST', 'BSI_X_PRODUCT', 'BSI_X_PRODUCT_CONDENSED', 'BSI_X_PRODUCT_TREE_META', 'BSI_X_RECEIPT_CHANGE', 'BSI_X_RECEIPT_CUST_BALANCE', 'BSI_X_REPLACE_PO_BOX_STRING', 'BSI_X_REST_LOG', 'BSI_X_REST_SYNC_ITEM', 'BSI_X_S1_GEOLOCATION', 'BSI_X_S1_HOUSENUMBER', 'BSI_X_S1_HOUSENUMBER_ALT', 'BSI_X_S1_STREET', 'BSI_X_S1_STREET_ALT', 'BSI_X_S1_ZIP', 'BSI_X_S2_GEOLOCATION', 'BSI_X_SERVICE_OVERVIEW', 'BSI_X_SET_MASTER_1', 'BSI_X_SET_MASTER_2', 'BSI_X_SHORT_URL_MAPPING', 'BSI_X_SILOSUB2_CREATE_OFFER', 'BSI_X_SILOSUB2_OFFER_DIR', 'BSI_X_STREET', 'BSI_X_STRUCTURE_SALES', 'BSI_X_SWITCH_ADDRESS_TYPE', 'BSI_X_SWITCH_COM_PERS_HELPER', 'BSI_X_SWITCH_COMPANY_COMPANY', 'BSI_X_SWITCH_COMPANY_HELPER', 'BSI_X_SWITCH_EXT_JOIN_NR', 'BSI_X_SWITCH_JOIN_NR', 'BSI_X_SWITCH_PERSON_COMPANY', 'BSI_X_SWITCH_PERSON_PERSON', 'BSI_X_TASK_REACTION', 'BSI_X_TOUR', 'BSI_X_TOUR_MAPPING', 'BSI_X_TYPE_USAGE_MAPPING', 'BSI_X_UC_BUDGETING_PERIOD', 'BSI_X_UC_BUDGETING_PERIOD_REF', 'BSI_X_UC_COMPL_CAT_PROD_TYPE', 'BSI_X_UC_COMPL_CAUSE_CAUSER', 'BSI_X_UC_COMPLAINT_CAUSE', 'BSI_X_UC_DIRECTORY', 'BSI_X_UC_DIRECTORY_EDITION', 'BSI_X_UC_DIRECTORY_LANGUAGE', 'BSI_X_UC_DIRECTORY_LOCATION', 'BSI_X_UC_DISTRIBUTION_AREA', 'BSI_X_UC_NOGA_CODE', 'BSI_X_UC_PRECOMP_CUST_DATA_COL', 'BSI_X_UC_PROCESS_REJECT_O_INFO', 'BSI_X_UC_PRODUCT_TYPE', 'BSI_X_UC_STRUCTURE_SALES', 'BSI_X_UNION_FIND_RELATIONS', 'BSI_X_USER_LOGIN', 'BSI_X_WEBSERVICE_LOG', 'BSI_X_WEBSERVICE_QUEUE')
		AND upper(ATC.TABLE_NAME) like 'BSI_%'
		and ATC.DATA_TYPE = 'NUMBER'
	) LOOP

	EXECUTE IMMEDIATE
		'SELECT COUNT(*) FROM ' || t.owner || '.' || t.table_name ||
		' WHERE '||t.column_name||' = :1'
		INTO match_count
		USING '8111262126';

	IF match_count > 0 THEN
		dbms_output.put_line( t.table_name ||' '||t.column_name||' '||match_count );
	END IF;
END LOOP;

END;