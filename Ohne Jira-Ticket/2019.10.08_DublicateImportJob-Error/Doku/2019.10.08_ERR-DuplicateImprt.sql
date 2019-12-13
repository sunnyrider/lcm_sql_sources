
SELECT table_0_.EXT_JOIN_TYPE_UID AS col_0_,
table_0_.EXT_JOIN_NR AS col_0__1,
table_2_.IS_MASTER AS col_1_,
table_0_.EVT_INSERT AS col_2_,
table_1_.NAME AS col_3_,
table_1_.JOIN_NO AS col_4_,
CASE WHEN 
(
  table_1_.EXT_JOIN_TYPE_UID=108224 
)
THEN 
(
  table_3_.DISPLAY_NAME 
)
ELSE 
(
  table_4_.DISPLAY_NAME 
)
END AS col_5_,
CASE WHEN 
(
  table_1_.EXT_JOIN_TYPE_UID=108224 
)
THEN 
(
  table_3_.COMPANY_NO 
)
ELSE 
(
  table_4_.PERSON_NO 
)
END AS col_6_,
table_2_.JOIN_NR AS col_7_,
table_0_.STATUS_UID AS col_8_,
CASE WHEN 
(
  table_1_.EXT_JOIN_TYPE_UID=108224 
)
THEN 
(
  table_5_.DISPLAY_NAME 
)
ELSE 
(
  table_6_.DISPLAY_NAME 
)
END AS col_9_,
CASE WHEN 
(
  table_1_.EXT_JOIN_TYPE_UID=108224 
)
THEN 
(
  table_5_.COMPANY_NO 
)
ELSE 
(
  table_6_.PERSON_NO 
)
END AS col_10_,
nvl
(
  (
    table_5_.COMPANY_NO 
  )
  ,
  (
    table_6_.PERSON_NO 
  )
)
AS col_11_,
table_0_.TARGET_JOIN_NR AS col_12_,
nvl
(
  table_9_.POSTAL_DISPLAY_STREET,
  ' '
)
AS col_13_,
table_10_.CITY AS col_14_,
nvl
(
  table_15_.POSTAL_DISPLAY_STREET,
  ' '
)
AS col_15_,
table_16_.CITY AS col_16_,
table_0_.CURRENT_JOIN_NR AS col_17_,
table_0_.TARGET_JOIN_NR AS col_18_,
table_7_.IS_ACTIVE AS col_19_,
table_20_.INTERFACE_UID AS col_20_ 
FROM BSI_X_DUPLICATE_REPORT table_0_ 
JOIN BSI_X_EXT_JOIN table_1_ ON table_1_.EXT_JOIN_TYPE_UID=table_0_.EXT_JOIN_TYPE_UID AND table_1_.EXT_JOIN_NR=table_0_.EXT_JOIN_NR 
JOIN BSI_X_EXT_JOIN_JOIN table_2_ ON table_2_.EXT_JOIN_TYPE_UID=table_1_.EXT_JOIN_TYPE_UID AND table_2_.EXT_JOIN_NR=table_1_.EXT_JOIN_NR 
LEFT OUTER JOIN BSI_COMPANY table_3_ ON table_3_.COMPANY_NR=table_2_.JOIN_NR AND 108224=table_1_.EXT_JOIN_TYPE_UID and table_3_.DTYPE=2000 and 
(
  (
    table_3_.COMPANY_NR = 0 
  )
  OR 
  (
    1 = CASE 
    (
      SELECT max
      (
        rxtable_2_.PERMISSION_LEVEL
      )
      AS rxcol_1_ 
      FROM BSI_COMPANY_PARTITION rxtable_1_ 
      JOIN BSI_USER_ACL rxtable_2_ ON rxtable_2_.PARTITION_UID=rxtable_1_.PARTITION_UID AND rxtable_2_.USER_NR = 1002727 AND rxtable_2_.PERMISSION_NAME = 'ReadCompanyPermission' 
      WHERE rxtable_1_.COMPANY_NR=table_3_.COMPANY_NR 
    )
    WHEN 
    (
      100 
    )
    THEN 
    (
      1 
    )
    WHEN 
    (
      30 
    )
    THEN 
    (
      CASE WHEN 
      (
        EXISTS 
        (
          SELECT 1 AS rxcol_2_ 
          FROM BSI_COMPANY_ADVISOR rxtable_3_ 
          JOIN BSI_UC_ADVISOR rxtable_4_ ON rxtable_4_.ADVISOR_UID=rxtable_3_.ADVISOR_UID 
          JOIN BSI_UC rxtable_5_ ON rxtable_5_.UC_UID=rxtable_4_.ADVISOR_UID 
          WHERE rxtable_3_.COMPANY_NR=table_3_.COMPANY_NR AND rxtable_4_.IS_ACCESS_CHECK_ROLE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND rxtable_4_.ADVISED_TYPE_UID IN 
          (
            113697,
            113698 
          )
          AND rxtable_5_.IS_ACTIVE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND 1 = nvl
          (
            (
              SELECT 1 AS rxcol_3_ 
              FROM BSI_DUAL rxtable_6_ 
              WHERE 
              (
                (
                  rxtable_3_.ADVISOR_USER_NR = 1002727 
                )
                OR 
                (
                  EXISTS 
                  (
                    SELECT 1 AS rxcol_4_ 
                    FROM BSI_USER_SUBSTITUTE rxtable_7_ 
                    WHERE rxtable_7_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_7_.USER_NR=rxtable_3_.ADVISOR_USER_NR 
                  )
                )
              )
            )
            ,
            nvl
            (
              (
                SELECT 1 AS rxcol_5_ 
                FROM BSI_X_STRUCTURE_SALES rxtable_8_ 
                WHERE rxtable_8_.USER_NR=rxtable_3_.ADVISOR_USER_NR AND 
                (
                  (
                    rxtable_8_.LEADER_NR = 1002727 
                  )
                  OR 
                  (
                    EXISTS 
                    (
                      SELECT 1 AS rxcol_6_ 
                      FROM BSI_USER_SUBSTITUTE rxtable_9_ 
                      WHERE rxtable_9_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_9_.USER_NR=rxtable_8_.LEADER_NR 
                    )
                  )
                )
              )
              ,
              nvl
              (
                (
                  SELECT 1 AS rxcol_7_ 
                  FROM BSI_X_STRUCTURE_SALES rxtable_10_ 
                  WHERE rxtable_10_.USER_NR=rxtable_3_.ADVISOR_USER_NR AND 
                  (
                    (
                      rxtable_10_.DIRECTOR_NR = 1002727 
                    )
                    OR 
                    (
                      EXISTS 
                      (
                        SELECT 1 AS rxcol_8_ 
                        FROM BSI_USER_SUBSTITUTE rxtable_11_ 
                        WHERE rxtable_11_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_11_.USER_NR=rxtable_10_.DIRECTOR_NR 
                      )
                    )
                  )
                )
                ,
                (
                  0 
                )
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    WHEN 
    (
      10 
    )
    THEN 
    (
      CASE WHEN 
      (
        EXISTS 
        (
          SELECT 1 AS rxcol_9_ 
          FROM BSI_COMPANY_ADVISOR rxtable_12_ 
          JOIN BSI_UC_ADVISOR rxtable_13_ ON rxtable_13_.ADVISOR_UID=rxtable_12_.ADVISOR_UID 
          JOIN BSI_UC rxtable_14_ ON rxtable_14_.UC_UID=rxtable_13_.ADVISOR_UID 
          WHERE rxtable_12_.COMPANY_NR=table_3_.COMPANY_NR AND rxtable_13_.IS_ACCESS_CHECK_ROLE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND rxtable_13_.ADVISED_TYPE_UID IN 
          (
            113697,
            113698 
          )
          AND rxtable_14_.IS_ACTIVE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND 
          (
            (
              rxtable_12_.ADVISOR_USER_NR = 1002727 
            )
            OR 
            (
              EXISTS 
              (
                SELECT 1 AS rxcol_10_ 
                FROM BSI_USER_SUBSTITUTE rxtable_15_ 
                WHERE rxtable_15_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_15_.USER_NR=rxtable_12_.ADVISOR_USER_NR 
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    ELSE 
    (
      0 
    )
    END 
  )
)
LEFT 
OUTER JOIN BSI_PERSON table_4_ ON table_4_.PERSON_NR=table_2_.JOIN_NR AND 108236=table_1_.EXT_JOIN_TYPE_UID and table_4_.DTYPE=2000 and 
(
  (
    table_4_.PERSON_NR = 0 
  )
  OR 
  (
    table_4_.PERSON_NR = 1002727 
  )
  OR 
  (
    1 = CASE 
    (
      SELECT max
      (
        rxtable_2_.PERMISSION_LEVEL
      )
      AS rxcol_1_ 
      FROM BSI_PERSON_PARTITION rxtable_1_ 
      JOIN BSI_USER_ACL rxtable_2_ ON rxtable_2_.PARTITION_UID=rxtable_1_.PARTITION_UID AND rxtable_2_.USER_NR = 1002727 AND rxtable_2_.PERMISSION_NAME = 'ReadPersonPermission' 
      WHERE rxtable_1_.PERSON_NR=table_4_.PERSON_NR 
    )
    WHEN 
    (
      100 
    )
    THEN 
    (
      1 
    )
    WHEN 
    (
      30 
    )
    THEN 
    (
      CASE WHEN 
      (
        (
          (
            EXISTS 
            (
              SELECT 1 AS rxcol_2_ 
              FROM BSI_USER rxtable_3_ 
              WHERE rxtable_3_.USER_NR=table_4_.PERSON_NR 
            )
          )
          OR 
          (
            NOT EXISTS 
            (
              SELECT 1 AS rxcol_3_ 
              FROM BSI_COMPANY_PERSON rxtable_4_ 
              WHERE rxtable_4_.PERSON_NR=table_4_.PERSON_NR 
            )
          )
          OR 
          (
            EXISTS 
            (
              SELECT 1 AS rxcol_4_ 
              FROM BSI_PERSON_ADVISOR rxtable_5_ 
              JOIN BSI_UC_ADVISOR rxtable_6_ ON rxtable_6_.ADVISOR_UID=rxtable_5_.ADVISOR_UID 
              JOIN BSI_UC rxtable_7_ ON rxtable_7_.UC_UID=rxtable_6_.ADVISOR_UID 
              WHERE rxtable_5_.PERSON_NR=table_4_.PERSON_NR AND rxtable_6_.IS_ACCESS_CHECK_ROLE = cast
              (
                1 as number
                (
                  1,
                  0
                )
              )
              AND rxtable_6_.ADVISED_TYPE_UID IN 
              (
                113697,
                113699 
              )
              AND rxtable_7_.IS_ACTIVE = cast
              (
                1 as number
                (
                  1,
                  0
                )
              )
              AND 1 = nvl
              (
                (
                  SELECT 1 AS rxcol_5_ 
                  FROM BSI_DUAL rxtable_8_ 
                  WHERE 
                  (
                    (
                      rxtable_5_.ADVISOR_USER_NR = 1002727 
                    )
                    OR 
                    (
                      EXISTS 
                      (
                        SELECT 1 AS rxcol_6_ 
                        FROM BSI_USER_SUBSTITUTE rxtable_9_ 
                        WHERE rxtable_9_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_9_.USER_NR=rxtable_5_.ADVISOR_USER_NR 
                      )
                    )
                  )
                )
                ,
                nvl
                (
                  (
                    SELECT 1 AS rxcol_7_ 
                    FROM BSI_X_STRUCTURE_SALES rxtable_10_ 
                    WHERE rxtable_10_.USER_NR=rxtable_5_.ADVISOR_USER_NR AND 
                    (
                      (
                        rxtable_10_.LEADER_NR = 1002727 
                      )
                      OR 
                      (
                        EXISTS 
                        (
                          SELECT 1 AS rxcol_8_ 
                          FROM BSI_USER_SUBSTITUTE rxtable_11_ 
                          WHERE rxtable_11_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_11_.USER_NR=rxtable_10_.LEADER_NR 
                        )
                      )
                    )
                  )
                  ,
                  nvl
                  (
                    (
                      SELECT 1 AS rxcol_9_ 
                      FROM BSI_X_STRUCTURE_SALES rxtable_12_ 
                      WHERE rxtable_12_.USER_NR=rxtable_5_.ADVISOR_USER_NR AND 
                      (
                        (
                          rxtable_12_.DIRECTOR_NR = 1002727 
                        )
                        OR 
                        (
                          EXISTS 
                          (
                            SELECT 1 AS rxcol_10_ 
                            FROM BSI_USER_SUBSTITUTE rxtable_13_ 
                            WHERE rxtable_13_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_13_.USER_NR=rxtable_12_.DIRECTOR_NR 
                          )
                        )
                      )
                    )
                    ,
                    (
                      0 
                    )
                  )
                )
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    WHEN 
    (
      10 
    )
    THEN 
    (
      CASE WHEN 
      (
        (
          (
            EXISTS 
            (
              SELECT 1 AS rxcol_11_ 
              FROM BSI_USER rxtable_14_ 
              WHERE rxtable_14_.USER_NR=table_4_.PERSON_NR 
            )
          )
          OR 
          (
            EXISTS 
            (
              SELECT 1 AS rxcol_12_ 
              FROM BSI_PERSON_ADVISOR rxtable_15_ 
              JOIN BSI_UC_ADVISOR rxtable_16_ ON rxtable_16_.ADVISOR_UID=rxtable_15_.ADVISOR_UID 
              JOIN BSI_UC rxtable_17_ ON rxtable_17_.UC_UID=rxtable_16_.ADVISOR_UID 
              WHERE rxtable_15_.PERSON_NR=table_4_.PERSON_NR AND rxtable_16_.IS_ACCESS_CHECK_ROLE = cast
              (
                1 as number
                (
                  1,
                  0
                )
              )
              AND rxtable_16_.ADVISED_TYPE_UID IN 
              (
                113697,
                113699 
              )
              AND rxtable_17_.IS_ACTIVE = cast
              (
                1 as number
                (
                  1,
                  0
                )
              )
              AND 
              (
                (
                  rxtable_15_.ADVISOR_USER_NR = 1002727 
                )
                OR 
                (
                  EXISTS 
                  (
                    SELECT 1 AS rxcol_13_ 
                    FROM BSI_USER_SUBSTITUTE rxtable_18_ 
                    WHERE rxtable_18_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_18_.USER_NR=rxtable_15_.ADVISOR_USER_NR 
                  )
                )
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    ELSE 
    (
      0 
    )
    END 
  )
)
LEFT 
OUTER JOIN BSI_COMPANY table_5_ ON table_5_.COMPANY_NR=table_0_.TARGET_JOIN_NR AND 108224=table_1_.EXT_JOIN_TYPE_UID and table_5_.DTYPE=2000 and 
(
  (
    table_5_.COMPANY_NR = 0 
  )
  OR 
  (
    1 = CASE 
    (
      SELECT max
      (
        rxtable_2_.PERMISSION_LEVEL
      )
      AS rxcol_1_ 
      FROM BSI_COMPANY_PARTITION rxtable_1_ 
      JOIN BSI_USER_ACL rxtable_2_ ON rxtable_2_.PARTITION_UID=rxtable_1_.PARTITION_UID AND rxtable_2_.USER_NR = 1002727 AND rxtable_2_.PERMISSION_NAME = 'ReadCompanyPermission' 
      WHERE rxtable_1_.COMPANY_NR=table_5_.COMPANY_NR 
    )
    WHEN 
    (
      100 
    )
    THEN 
    (
      1 
    )
    WHEN 
    (
      30 
    )
    THEN 
    (
      CASE WHEN 
      (
        EXISTS 
        (
          SELECT 1 AS rxcol_2_ 
          FROM BSI_COMPANY_ADVISOR rxtable_3_ 
          JOIN BSI_UC_ADVISOR rxtable_4_ ON rxtable_4_.ADVISOR_UID=rxtable_3_.ADVISOR_UID 
          JOIN BSI_UC rxtable_5_ ON rxtable_5_.UC_UID=rxtable_4_.ADVISOR_UID 
          WHERE rxtable_3_.COMPANY_NR=table_5_.COMPANY_NR AND rxtable_4_.IS_ACCESS_CHECK_ROLE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND rxtable_4_.ADVISED_TYPE_UID IN 
          (
            113697,
            113698 
          )
          AND rxtable_5_.IS_ACTIVE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND 1 = nvl
          (
            (
              SELECT 1 AS rxcol_3_ 
              FROM BSI_DUAL rxtable_6_ 
              WHERE 
              (
                (
                  rxtable_3_.ADVISOR_USER_NR = 1002727 
                )
                OR 
                (
                  EXISTS 
                  (
                    SELECT 1 AS rxcol_4_ 
                    FROM BSI_USER_SUBSTITUTE rxtable_7_ 
                    WHERE rxtable_7_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_7_.USER_NR=rxtable_3_.ADVISOR_USER_NR 
                  )
                )
              )
            )
            ,
            nvl
            (
              (
                SELECT 1 AS rxcol_5_ 
                FROM BSI_X_STRUCTURE_SALES rxtable_8_ 
                WHERE rxtable_8_.USER_NR=rxtable_3_.ADVISOR_USER_NR AND 
                (
                  (
                    rxtable_8_.LEADER_NR = 1002727 
                  )
                  OR 
                  (
                    EXISTS 
                    (
                      SELECT 1 AS rxcol_6_ 
                      FROM BSI_USER_SUBSTITUTE rxtable_9_ 
                      WHERE rxtable_9_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_9_.USER_NR=rxtable_8_.LEADER_NR 
                    )
                  )
                )
              )
              ,
              nvl
              (
                (
                  SELECT 1 AS rxcol_7_ 
                  FROM BSI_X_STRUCTURE_SALES rxtable_10_ 
                  WHERE rxtable_10_.USER_NR=rxtable_3_.ADVISOR_USER_NR AND 
                  (
                    (
                      rxtable_10_.DIRECTOR_NR = 1002727 
                    )
                    OR 
                    (
                      EXISTS 
                      (
                        SELECT 1 AS rxcol_8_ 
                        FROM BSI_USER_SUBSTITUTE rxtable_11_ 
                        WHERE rxtable_11_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_11_.USER_NR=rxtable_10_.DIRECTOR_NR 
                      )
                    )
                  )
                )
                ,
                (
                  0 
                )
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    WHEN 
    (
      10 
    )
    THEN 
    (
      CASE WHEN 
      (
        EXISTS 
        (
          SELECT 1 AS rxcol_9_ 
          FROM BSI_COMPANY_ADVISOR rxtable_12_ 
          JOIN BSI_UC_ADVISOR rxtable_13_ ON rxtable_13_.ADVISOR_UID=rxtable_12_.ADVISOR_UID 
          JOIN BSI_UC rxtable_14_ ON rxtable_14_.UC_UID=rxtable_13_.ADVISOR_UID 
          WHERE rxtable_12_.COMPANY_NR=table_5_.COMPANY_NR AND rxtable_13_.IS_ACCESS_CHECK_ROLE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND rxtable_13_.ADVISED_TYPE_UID IN 
          (
            113697,
            113698 
          )
          AND rxtable_14_.IS_ACTIVE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND 
          (
            (
              rxtable_12_.ADVISOR_USER_NR = 1002727 
            )
            OR 
            (
              EXISTS 
              (
                SELECT 1 AS rxcol_10_ 
                FROM BSI_USER_SUBSTITUTE rxtable_15_ 
                WHERE rxtable_15_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_15_.USER_NR=rxtable_12_.ADVISOR_USER_NR 
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    ELSE 
    (
      0 
    )
    END 
  )
)
LEFT 
OUTER JOIN BSI_PERSON table_6_ ON table_6_.PERSON_NR=table_0_.TARGET_JOIN_NR AND 108236=table_1_.EXT_JOIN_TYPE_UID and table_6_.DTYPE=2000 and 
(
  (
    table_6_.PERSON_NR = 0 
  )
  OR 
  (
    table_6_.PERSON_NR = 1002727 
  )
  OR 
  (
    1 = CASE 
    (
      SELECT max
      (
        rxtable_2_.PERMISSION_LEVEL
      )
      AS rxcol_1_ 
      FROM BSI_PERSON_PARTITION rxtable_1_ 
      JOIN BSI_USER_ACL rxtable_2_ ON rxtable_2_.PARTITION_UID=rxtable_1_.PARTITION_UID AND rxtable_2_.USER_NR = 1002727 AND rxtable_2_.PERMISSION_NAME = 'ReadPersonPermission' 
      WHERE rxtable_1_.PERSON_NR=table_6_.PERSON_NR 
    )
    WHEN 
    (
      100 
    )
    THEN 
    (
      1 
    )
    WHEN 
    (
      30 
    )
    THEN 
    (
      CASE WHEN 
      (
        (
          (
            EXISTS 
            (
              SELECT 1 AS rxcol_2_ 
              FROM BSI_USER rxtable_3_ 
              WHERE rxtable_3_.USER_NR=table_6_.PERSON_NR 
            )
          )
          OR 
          (
            NOT EXISTS 
            (
              SELECT 1 AS rxcol_3_ 
              FROM BSI_COMPANY_PERSON rxtable_4_ 
              WHERE rxtable_4_.PERSON_NR=table_6_.PERSON_NR 
            )
          )
          OR 
          (
            EXISTS 
            (
              SELECT 1 AS rxcol_4_ 
              FROM BSI_PERSON_ADVISOR rxtable_5_ 
              JOIN BSI_UC_ADVISOR rxtable_6_ ON rxtable_6_.ADVISOR_UID=rxtable_5_.ADVISOR_UID 
              JOIN BSI_UC rxtable_7_ ON rxtable_7_.UC_UID=rxtable_6_.ADVISOR_UID 
              WHERE rxtable_5_.PERSON_NR=table_6_.PERSON_NR AND rxtable_6_.IS_ACCESS_CHECK_ROLE = cast
              (
                1 as number
                (
                  1,
                  0
                )
              )
              AND rxtable_6_.ADVISED_TYPE_UID IN 
              (
                113697,
                113699 
              )
              AND rxtable_7_.IS_ACTIVE = cast
              (
                1 as number
                (
                  1,
                  0
                )
              )
              AND 1 = nvl
              (
                (
                  SELECT 1 AS rxcol_5_ 
                  FROM BSI_DUAL rxtable_8_ 
                  WHERE 
                  (
                    (
                      rxtable_5_.ADVISOR_USER_NR = 1002727 
                    )
                    OR 
                    (
                      EXISTS 
                      (
                        SELECT 1 AS rxcol_6_ 
                        FROM BSI_USER_SUBSTITUTE rxtable_9_ 
                        WHERE rxtable_9_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_9_.USER_NR=rxtable_5_.ADVISOR_USER_NR 
                      )
                    )
                  )
                )
                ,
                nvl
                (
                  (
                    SELECT 1 AS rxcol_7_ 
                    FROM BSI_X_STRUCTURE_SALES rxtable_10_ 
                    WHERE rxtable_10_.USER_NR=rxtable_5_.ADVISOR_USER_NR AND 
                    (
                      (
                        rxtable_10_.LEADER_NR = 1002727 
                      )
                      OR 
                      (
                        EXISTS 
                        (
                          SELECT 1 AS rxcol_8_ 
                          FROM BSI_USER_SUBSTITUTE rxtable_11_ 
                          WHERE rxtable_11_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_11_.USER_NR=rxtable_10_.LEADER_NR 
                        )
                      )
                    )
                  )
                  ,
                  nvl
                  (
                    (
                      SELECT 1 AS rxcol_9_ 
                      FROM BSI_X_STRUCTURE_SALES rxtable_12_ 
                      WHERE rxtable_12_.USER_NR=rxtable_5_.ADVISOR_USER_NR AND 
                      (
                        (
                          rxtable_12_.DIRECTOR_NR = 1002727 
                        )
                        OR 
                        (
                          EXISTS 
                          (
                            SELECT 1 AS rxcol_10_ 
                            FROM BSI_USER_SUBSTITUTE rxtable_13_ 
                            WHERE rxtable_13_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_13_.USER_NR=rxtable_12_.DIRECTOR_NR 
                          )
                        )
                      )
                    )
                    ,
                    (
                      0 
                    )
                  )
                )
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    WHEN 
    (
      10 
    )
    THEN 
    (
      CASE WHEN 
      (
        (
          (
            EXISTS 
            (
              SELECT 1 AS rxcol_11_ 
              FROM BSI_USER rxtable_14_ 
              WHERE rxtable_14_.USER_NR=table_6_.PERSON_NR 
            )
          )
          OR 
          (
            EXISTS 
            (
              SELECT 1 AS rxcol_12_ 
              FROM BSI_PERSON_ADVISOR rxtable_15_ 
              JOIN BSI_UC_ADVISOR rxtable_16_ ON rxtable_16_.ADVISOR_UID=rxtable_15_.ADVISOR_UID 
              JOIN BSI_UC rxtable_17_ ON rxtable_17_.UC_UID=rxtable_16_.ADVISOR_UID 
              WHERE rxtable_15_.PERSON_NR=table_6_.PERSON_NR AND rxtable_16_.IS_ACCESS_CHECK_ROLE = cast
              (
                1 as number
                (
                  1,
                  0
                )
              )
              AND rxtable_16_.ADVISED_TYPE_UID IN 
              (
                113697,
                113699 
              )
              AND rxtable_17_.IS_ACTIVE = cast
              (
                1 as number
                (
                  1,
                  0
                )
              )
              AND 
              (
                (
                  rxtable_15_.ADVISOR_USER_NR = 1002727 
                )
                OR 
                (
                  EXISTS 
                  (
                    SELECT 1 AS rxcol_13_ 
                    FROM BSI_USER_SUBSTITUTE rxtable_18_ 
                    WHERE rxtable_18_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_18_.USER_NR=rxtable_15_.ADVISOR_USER_NR 
                  )
                )
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    ELSE 
    (
      0 
    )
    END 
  )
)
LEFT 
OUTER JOIN BSI_COMPANY table_7_ ON table_7_.COMPANY_NR=table_0_.TARGET_JOIN_NR and table_7_.DTYPE=2000 and 
(
  (
    table_7_.COMPANY_NR = 0 
  )
  OR 
  (
    1 = CASE 
    (
      SELECT max
      (
        rxtable_2_.PERMISSION_LEVEL
      )
      AS rxcol_1_ 
      FROM BSI_COMPANY_PARTITION rxtable_1_ 
      JOIN BSI_USER_ACL rxtable_2_ ON rxtable_2_.PARTITION_UID=rxtable_1_.PARTITION_UID AND rxtable_2_.USER_NR = 1002727 AND rxtable_2_.PERMISSION_NAME = 'ReadCompanyPermission' 
      WHERE rxtable_1_.COMPANY_NR=table_7_.COMPANY_NR 
    )
    WHEN 
    (
      100 
    )
    THEN 
    (
      1 
    )
    WHEN 
    (
      30 
    )
    THEN 
    (
      CASE WHEN 
      (
        EXISTS 
        (
          SELECT 1 AS rxcol_2_ 
          FROM BSI_COMPANY_ADVISOR rxtable_3_ 
          JOIN BSI_UC_ADVISOR rxtable_4_ ON rxtable_4_.ADVISOR_UID=rxtable_3_.ADVISOR_UID 
          JOIN BSI_UC rxtable_5_ ON rxtable_5_.UC_UID=rxtable_4_.ADVISOR_UID 
          WHERE rxtable_3_.COMPANY_NR=table_7_.COMPANY_NR AND rxtable_4_.IS_ACCESS_CHECK_ROLE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND rxtable_4_.ADVISED_TYPE_UID IN 
          (
            113697,
            113698 
          )
          AND rxtable_5_.IS_ACTIVE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND 1 = nvl
          (
            (
              SELECT 1 AS rxcol_3_ 
              FROM BSI_DUAL rxtable_6_ 
              WHERE 
              (
                (
                  rxtable_3_.ADVISOR_USER_NR = 1002727 
                )
                OR 
                (
                  EXISTS 
                  (
                    SELECT 1 AS rxcol_4_ 
                    FROM BSI_USER_SUBSTITUTE rxtable_7_ 
                    WHERE rxtable_7_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_7_.USER_NR=rxtable_3_.ADVISOR_USER_NR 
                  )
                )
              )
            )
            ,
            nvl
            (
              (
                SELECT 1 AS rxcol_5_ 
                FROM BSI_X_STRUCTURE_SALES rxtable_8_ 
                WHERE rxtable_8_.USER_NR=rxtable_3_.ADVISOR_USER_NR AND 
                (
                  (
                    rxtable_8_.LEADER_NR = 1002727 
                  )
                  OR 
                  (
                    EXISTS 
                    (
                      SELECT 1 AS rxcol_6_ 
                      FROM BSI_USER_SUBSTITUTE rxtable_9_ 
                      WHERE rxtable_9_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_9_.USER_NR=rxtable_8_.LEADER_NR 
                    )
                  )
                )
              )
              ,
              nvl
              (
                (
                  SELECT 1 AS rxcol_7_ 
                  FROM BSI_X_STRUCTURE_SALES rxtable_10_ 
                  WHERE rxtable_10_.USER_NR=rxtable_3_.ADVISOR_USER_NR AND 
                  (
                    (
                      rxtable_10_.DIRECTOR_NR = 1002727 
                    )
                    OR 
                    (
                      EXISTS 
                      (
                        SELECT 1 AS rxcol_8_ 
                        FROM BSI_USER_SUBSTITUTE rxtable_11_ 
                        WHERE rxtable_11_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_11_.USER_NR=rxtable_10_.DIRECTOR_NR 
                      )
                    )
                  )
                )
                ,
                (
                  0 
                )
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    WHEN 
    (
      10 
    )
    THEN 
    (
      CASE WHEN 
      (
        EXISTS 
        (
          SELECT 1 AS rxcol_9_ 
          FROM BSI_COMPANY_ADVISOR rxtable_12_ 
          JOIN BSI_UC_ADVISOR rxtable_13_ ON rxtable_13_.ADVISOR_UID=rxtable_12_.ADVISOR_UID 
          JOIN BSI_UC rxtable_14_ ON rxtable_14_.UC_UID=rxtable_13_.ADVISOR_UID 
          WHERE rxtable_12_.COMPANY_NR=table_7_.COMPANY_NR AND rxtable_13_.IS_ACCESS_CHECK_ROLE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND rxtable_13_.ADVISED_TYPE_UID IN 
          (
            113697,
            113698 
          )
          AND rxtable_14_.IS_ACTIVE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND 
          (
            (
              rxtable_12_.ADVISOR_USER_NR = 1002727 
            )
            OR 
            (
              EXISTS 
              (
                SELECT 1 AS rxcol_10_ 
                FROM BSI_USER_SUBSTITUTE rxtable_15_ 
                WHERE rxtable_15_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_15_.USER_NR=rxtable_12_.ADVISOR_USER_NR 
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    ELSE 
    (
      0 
    )
    END 
  )
)
LEFT 
OUTER JOIN BSI_DUAL table_8_ ON cast
(
  1 as number
  (
    1,
    0
  )
)
= cast
(
  1 as number
  (
    1,
    0
  )
)
LEFT 
OUTER JOIN BSI_ADDRESS table_9_ ON 318594=table_9_.ITEM_TYPE_ID AND table_7_.COMPANY_NR=table_9_.ITEM_KEY0_NR AND table_9_.ADDRESS_NR <> 0 AND table_9_.CHANNEL_UID in 
(
  113688
)
AND table_9_.IS_DEFAULT_ADDRESS=1 and table_9_.DTYPE=2000 
LEFT OUTER JOIN BSI_CITY table_10_ ON table_9_.CITY_NR = table_10_.CITY_NR and table_10_.DTYPE=2000 
LEFT OUTER JOIN BSI_CITY table_11_ ON table_9_.CITY_NR = table_11_.CITY_NR and table_11_.DTYPE=2000 
LEFT OUTER JOIN BSI_GLOBAL_TEXT table_12_ ON table_9_.POSTAL_PO_BOX_GLOBAL_TEXT_NR = table_12_.GLOBAL_TEXT_NR 
LEFT OUTER JOIN BSI_COMPANY table_13_ ON table_13_.COMPANY_NR=table_0_.CURRENT_JOIN_NR and table_13_.DTYPE=2000 and 
(
  (
    table_13_.COMPANY_NR = 0 
  )
  OR 
  (
    1 = CASE 
    (
      SELECT max
      (
        rxtable_2_.PERMISSION_LEVEL
      )
      AS rxcol_1_ 
      FROM BSI_COMPANY_PARTITION rxtable_1_ 
      JOIN BSI_USER_ACL rxtable_2_ ON rxtable_2_.PARTITION_UID=rxtable_1_.PARTITION_UID AND rxtable_2_.USER_NR = 1002727 AND rxtable_2_.PERMISSION_NAME = 'ReadCompanyPermission' 
      WHERE rxtable_1_.COMPANY_NR=table_13_.COMPANY_NR 
    )
    WHEN 
    (
      100 
    )
    THEN 
    (
      1 
    )
    WHEN 
    (
      30 
    )
    THEN 
    (
      CASE WHEN 
      (
        EXISTS 
        (
          SELECT 1 AS rxcol_2_ 
          FROM BSI_COMPANY_ADVISOR rxtable_3_ 
          JOIN BSI_UC_ADVISOR rxtable_4_ ON rxtable_4_.ADVISOR_UID=rxtable_3_.ADVISOR_UID 
          JOIN BSI_UC rxtable_5_ ON rxtable_5_.UC_UID=rxtable_4_.ADVISOR_UID 
          WHERE rxtable_3_.COMPANY_NR=table_13_.COMPANY_NR AND rxtable_4_.IS_ACCESS_CHECK_ROLE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND rxtable_4_.ADVISED_TYPE_UID IN 
          (
            113697,
            113698 
          )
          AND rxtable_5_.IS_ACTIVE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND 1 = nvl
          (
            (
              SELECT 1 AS rxcol_3_ 
              FROM BSI_DUAL rxtable_6_ 
              WHERE 
              (
                (
                  rxtable_3_.ADVISOR_USER_NR = 1002727 
                )
                OR 
                (
                  EXISTS 
                  (
                    SELECT 1 AS rxcol_4_ 
                    FROM BSI_USER_SUBSTITUTE rxtable_7_ 
                    WHERE rxtable_7_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_7_.USER_NR=rxtable_3_.ADVISOR_USER_NR 
                  )
                )
              )
            )
            ,
            nvl
            (
              (
                SELECT 1 AS rxcol_5_ 
                FROM BSI_X_STRUCTURE_SALES rxtable_8_ 
                WHERE rxtable_8_.USER_NR=rxtable_3_.ADVISOR_USER_NR AND 
                (
                  (
                    rxtable_8_.LEADER_NR = 1002727 
                  )
                  OR 
                  (
                    EXISTS 
                    (
                      SELECT 1 AS rxcol_6_ 
                      FROM BSI_USER_SUBSTITUTE rxtable_9_ 
                      WHERE rxtable_9_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_9_.USER_NR=rxtable_8_.LEADER_NR 
                    )
                  )
                )
              )
              ,
              nvl
              (
                (
                  SELECT 1 AS rxcol_7_ 
                  FROM BSI_X_STRUCTURE_SALES rxtable_10_ 
                  WHERE rxtable_10_.USER_NR=rxtable_3_.ADVISOR_USER_NR AND 
                  (
                    (
                      rxtable_10_.DIRECTOR_NR = 1002727 
                    )
                    OR 
                    (
                      EXISTS 
                      (
                        SELECT 1 AS rxcol_8_ 
                        FROM BSI_USER_SUBSTITUTE rxtable_11_ 
                        WHERE rxtable_11_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_11_.USER_NR=rxtable_10_.DIRECTOR_NR 
                      )
                    )
                  )
                )
                ,
                (
                  0 
                )
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    WHEN 
    (
      10 
    )
    THEN 
    (
      CASE WHEN 
      (
        EXISTS 
        (
          SELECT 1 AS rxcol_9_ 
          FROM BSI_COMPANY_ADVISOR rxtable_12_ 
          JOIN BSI_UC_ADVISOR rxtable_13_ ON rxtable_13_.ADVISOR_UID=rxtable_12_.ADVISOR_UID 
          JOIN BSI_UC rxtable_14_ ON rxtable_14_.UC_UID=rxtable_13_.ADVISOR_UID 
          WHERE rxtable_12_.COMPANY_NR=table_13_.COMPANY_NR AND rxtable_13_.IS_ACCESS_CHECK_ROLE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND rxtable_13_.ADVISED_TYPE_UID IN 
          (
            113697,
            113698 
          )
          AND rxtable_14_.IS_ACTIVE = cast
          (
            1 as number
            (
              1,
              0
            )
          )
          AND 
          (
            (
              rxtable_12_.ADVISOR_USER_NR = 1002727 
            )
            OR 
            (
              EXISTS 
              (
                SELECT 1 AS rxcol_10_ 
                FROM BSI_USER_SUBSTITUTE rxtable_15_ 
                WHERE rxtable_15_.SUBSTITUTE_USER_NR = 1002727 AND rxtable_15_.USER_NR=rxtable_12_.ADVISOR_USER_NR 
              )
            )
          )
        )
      )
      THEN 
      (
        1 
      )
      ELSE 
      (
        0 
      )
      END 
    )
    ELSE 
    (
      0 
    )
    END 
  )
)
LEFT 
OUTER JOIN BSI_DUAL table_14_ ON cast
(
  1 as number
  (
    1,
    0
  )
)
= cast
(
  1 as number
  (
    1,
    0
  )
)
LEFT 
OUTER JOIN BSI_ADDRESS table_15_ ON 318594=table_15_.ITEM_TYPE_ID AND table_13_.COMPANY_NR=table_15_.ITEM_KEY0_NR AND table_15_.ADDRESS_NR <> 0 AND table_15_.CHANNEL_UID in 
(
  113688
)
AND table_15_.IS_DEFAULT_ADDRESS=1 and table_15_.DTYPE=2000 
LEFT OUTER JOIN BSI_CITY table_16_ ON table_15_.CITY_NR = table_16_.CITY_NR and table_16_.DTYPE=2000 
LEFT OUTER JOIN BSI_CITY table_17_ ON table_15_.CITY_NR = table_17_.CITY_NR and table_17_.DTYPE=2000 
LEFT OUTER JOIN BSI_GLOBAL_TEXT table_18_ ON table_15_.POSTAL_PO_BOX_GLOBAL_TEXT_NR = table_18_.GLOBAL_TEXT_NR 
LEFT OUTER JOIN BSI_X_EXT_JOIN_JOIN table_19_ ON table_19_.EXT_JOIN_TYPE_UID=table_0_.EXT_JOIN_TYPE_UID AND table_19_.EXT_JOIN_NR=table_0_.EXT_JOIN_NR 
JOIN BSI_X_EXT_JOIN table_20_ ON table_20_.EXT_JOIN_TYPE_UID=table_19_.EXT_JOIN_TYPE_UID AND table_20_.EXT_JOIN_NR=table_19_.EXT_JOIN_NR 
LEFT OUTER JOIN BSI_X_EXT_ADDRESS table_21_ ON table_20_.EXT_JOIN_TYPE_UID=table_21_.JOIN_TYPE_UID AND table_20_.EXT_JOIN_NR=table_21_.JOIN_NR AND table_21_.TYPE_UID in 
(
  2315,
  2470
)
WHERE table_0_.TARGET_JOIN_NR <> 0 AND table_0_.IS_MANUAL_MATCH = cast
(
  0 as number
  (
    1,
    0
  )
)
AND 
(
  CASE WHEN 
  (
    table_1_.EXT_JOIN_TYPE_UID=108224 
  )
  THEN 
  (
    table_5_.COMPANY_NR 
  )
  ELSE 
  (
    table_6_.PERSON_NR 
  )
  END 
)
IS NOT NULL AND table_0_.STATUS_UID in 
(
  115564
)
AND table_1_.EXT_JOIN_TYPE_UID in 
(
  108224
)
AND table_1_.ACTIVE=1
;
