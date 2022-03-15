

DO $$
DECLARE
    i INTEGER := 1;
BEGIN
    WHILE i < 100 loop
    
		insert into public.test_data
		SELECT lfile_seq + i * 1000, "time" + i * INTERVAL '1 hour' dtime , gps_lon, gps_lat, tech_type, technology, technology_ca, qc_serving_pci, qc_serving_rsrp, qc_serving_sinr, qc_serving_rssi, bin_x, bin_y, operator_seq 
		FROM public.init_data;

        i := i + 1;
    END LOOP;
END $$;