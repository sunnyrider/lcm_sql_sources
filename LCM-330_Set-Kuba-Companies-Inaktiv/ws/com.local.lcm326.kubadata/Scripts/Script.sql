-- MERGE INTO bsi_company_person cp
--      USING    (
  SELECT sm2.join_nr person_nr,
                   ejj.join_nr    company_nr,
                  (SELECT MIN(company_person_role_uid) FROM bsi_uc_company_person_role WHERE is_use_for_display_name = 1) role_uid
            FROM bsi_x_set_master_2 sm2
            JOIN bsi_x_ext_join ej ON ej.ext_join_nr = sm2.ext_join_nr 
            	AND sm2.ext_join_type_uid = 108236 
            	AND ej.ext_join_type_uid = 108236 
            	AND ej.ext_company_nr <> 0
            JOIN bsi_x_ext_join ejc ON ejc.ext_join_nr = ej.ext_company_nr 
            	AND ejc.ext_join_type_uid = 108224
            JOIN bsi_x_ext_join_join ejj ON ejj.ext_join_nr = ejc.ext_join_nr 
            	AND ejj.ext_join_type_uid = ejc.ext_join_type_uid
            GROUP BY (sm2.join_nr, ejj.join_nr)
;
--    ) x
--  ON       (cp.company_nr = x.company_nr AND cp.person_nr = x.person_nr AND cp.role_uid = x.role_uid)
--      WHEN NOT MATCHED THEN
--         INSERT     (company_nr, person_nr, role_uid)
--         VALUES     (x.company_nr, x.person_nr, x.role_uid);
