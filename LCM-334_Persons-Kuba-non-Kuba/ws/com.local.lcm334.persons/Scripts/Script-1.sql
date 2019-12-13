WITH pre_select AS (
		SELECT MAX(load_nr) load_nr
	FROM
		s2_kuba_person_in) SELECT
		s2kb.*,
		xadr.street,
		xadr.po_box,
		xadr.address_nr,
		2470 new_type_uid,
		COALESCE(ej.interface_uid, 131310) interface_uid,
		COALESCE(ej.join_no, get_next_pers_no()) join_no
	FROM
		s2_kuba_person_in s2kb
	JOIN pre_select psel ON
		psel.load_nr = s2kb.load_nr
	JOIN bsi_x_ext_address xadr ON xadr.join_nr = s2kb.cr_id_nr
		AND xadr.join_type_uid = 108224
		AND xadr.type_uid = 2315
		AND xadr.address_nr > 0
		-- falls K�Ba zu LCM wird (aufgrund einer Modifikation), kann dieser auch zu Firma werden (mit einem DSMP)
	LEFT OUTER JOIN bsi_x_ext_join ej ON s2kb.person_cr_id_nr = ej.ext_join_nr
		AND ej.ext_join_type_uid IN (108224, 108236)
UNION ALL SELECT
		s2kb.*,
		xadr.street,
		xadr.po_box,
		xadr.address_nr,
		108241 new_type_uid,
		COALESCE(ej.interface_uid, 131310) interface_uid,
		COALESCE(ej.join_no, get_next_pers_no()) join_no
	FROM
		s2_kuba_person_in s2kb
	JOIN pre_select p2sel ON p2sel.load_nr = s2kb.load_nr
	JOIN bsi_x_ext_address xadr ON xadr.join_nr = s2kb.cr_id_nr
		AND xadr.join_type_uid = 108224
		AND xadr.type_uid = 108240
		AND xadr.address_nr > 0
	LEFT OUTER JOIN bsi_x_ext_join ej ON s2kb.person_cr_id_nr = ej.ext_join_nr
		AND ej.ext_join_type_uid IN (108224, 108236)
		-- falls K�Ba zu LCM wird (aufgrund einer Modifikation), kann dieser auch zu Firma werden (mit einem DSMP)
		WHERE NOT EXISTS (
			SELECT 0
		FROM
			bsi_x_ext_address ea2
		WHERE
			ea2.join_nr = s2kb.cr_id_nr
			AND ea2.type_uid = 2315
			AND ea2.address_nr > 0)
;

SELECT COMPANY_NR, COMPANY_NO FROM BSI_COMPANY WHERE COMPANY_NR IN (19867501,19997690,20088465,23116811,19308664,20717715,20964639,22724089,22482734,20198733,22105048,19778794,22100448,20839386,21962358,20546168,23212168,24577269,19213885,20775594,23778019,21706764)
;
