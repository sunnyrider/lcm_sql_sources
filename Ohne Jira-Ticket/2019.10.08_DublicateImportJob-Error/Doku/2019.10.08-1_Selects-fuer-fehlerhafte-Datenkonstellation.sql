-- gibt es Firma ohne Komplexnummer?
--
select * from bsicrm.bsi_company
where X_COMPLEX_NO IS NULL
;

-- schauen ob für rest-job items vorhanden sind
--
select rsync.* FROM bsicrm.bsi_x_rest_sync_item rsync
	WHERE rsync.item_type_id = 318594
	AND rsync.root_item_type_id = 318594 
	AND NOT EXISTS (
		SELECT 0 FROM bsicrm.bsi_company WHERE company_nr = rsync.ROOT_ITEM_KEY0_NR
	)
;


-- falls etwas vorhanden, löschen
--DELETE FROM bsicrm .bsi_x_rest_sync_item rsync
--	WHERE rsync.item_type_id = 318594
--	AND rsync.root_item_type_id = 318594 
--	AND NOT EXISTS (
--		SELECT 0 FROM bsicrm.bsi_company WHERE company_nr = rsync.ROOT_ITEM_KEY0_NR
--	)
--;


-- gibt es doppelte Master in einem Komplex
--
select ejj.join_nr,
	ejj.is_master, ej.*
from bsicrm.bsi_x_ext_join ej, 
	bsicrm.bsi_x_ext_join_join ejj
where ej.ext_join_nr = ejj.ext_join_nr
and ej.ext_join_nr
in (select xejj.ext_join_nr
    	from bsicrm.bsi_x_ext_join_join xejj
    where join_nr in (select join_nr
                         from bsicrm.bsi_x_ext_join_join
                         where is_master = 1
                         group by join_nr
                         having count(1) > 1))
order by ejj.join_no
;