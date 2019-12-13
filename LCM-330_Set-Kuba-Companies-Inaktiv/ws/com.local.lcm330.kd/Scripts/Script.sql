SELECT /*+ ordered use_hash(kd ej2 ejj2) full(kd) full(ej2) full(ejj2) */
	max (kd.join_nr) kuba_join_nr, 
	ejj2.join_nr             
FROM bsicrm.bsi_x_ext_kuba_data kd
	JOIN bsicrm.bsi_x_ext_join ej2 
		inner JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr 
			AND ejj2.ext_join_type_uid = ej2.ext_join_type_uid
	ON ej2.ext_join_nr = kd.join_nr
	AND  ej2.ext_join_type_uid = kd.join_type_uid 
	AND ej2.ACTIVE = 1
WHERE kd.status_uid = 4800511372 --aktiv
AND ej2.JOIN_NO IN (406727287)
GROUP BY ejj2.join_nr
;

SELECT * FROM bsi_x_ext_kuba_data kd 
--WHERE KD.JOIN_NR IN (1009557548, 65942158, 406700584)
WHERE KD.JOIN_NR IN (505787, 17550096, 406727287)
;

SELECT
	ej2.JOIN_NO ej_Join_no,
	ej2.ACTIVE,
	ejj2.JOIN_NR ejj_join_nr,
	KD.JOIN_NR kuba_data_join_nr
FROM bsicrm.bsi_x_ext_kuba_data kd
	JOIN bsicrm.BSI_X_EXT_JOIN ej2 
		inner JOIN bsicrm.bsi_x_ext_join_join ejj2 ON ejj2.ext_join_nr = ej2.ext_join_nr 
			AND ejj2.ext_join_type_uid = ej2.ext_join_type_uid
	ON ej2.ext_join_nr = kd.join_nr
	AND  ej2.ext_join_type_uid = kd.join_type_uid 
	AND ej2.ACTIVE = 1
	AND ejj2.IS_MASTER = 0
;

select count(*) as Anzahl from BSI_X_EXT_JOIN where JOIN_NO = 406727287
;
update BSI_X_EXT_JOIN set ACTIVE = 0 where JOIN_NO = 406727287
;