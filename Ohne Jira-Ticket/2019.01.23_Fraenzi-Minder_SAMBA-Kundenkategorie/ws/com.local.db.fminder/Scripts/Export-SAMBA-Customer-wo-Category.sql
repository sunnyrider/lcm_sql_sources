ALTER SESSION SET current_schema = bsicrm;

SELECT
    ejj.join_no,
    uc.ext_key
FROM
    bsi_x_ext_join  ej
    JOIN bsi_x_ext_join_join ejj ON ejj.ext_join_nr = ej.ext_join_nr
    JOIN bsi_company company ON company.company_nr = ejj.join_nr
    LEFT OUTER JOIN bsi_uc uc ON uc.uc_uid = company.x_customer_category_uid
WHERE
    ej.interface_uid = 108187 --type samba
    AND ej.ext_join_type_uid = 108224 --type company
    AND company.x_customer_category_uid IS NOT NULL;
