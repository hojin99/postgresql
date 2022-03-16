CREATE TABLE public.init_data (
	lfile_seq int4 NULL,
	dtime timestamp NULL,
	gps_lon numeric(10,6) NULL,
	gps_lat numeric(10,6) NULL,
	tech_type int2 NULL,
	technology int2 NULL,
	technology_ca int2 NULL,
	qc_serving_pci int2 NULL,
	qc_serving_rsrp numeric NULL,
	qc_serving_sinr numeric NULL,
	qc_serving_rssi numeric NULL,
	bin_x int4 NULL,
	bin_y int4 NULL,
	operator_seq int2 NULL
);

CREATE TABLE public.test_data (
	lfile_seq int4 NULL,
	dtime timestamp NULL,
	gps_lon numeric(10,6) NULL,
	gps_lat numeric(10,6) NULL,
	tech_type int2 NULL,
	technology int2 NULL,
	technology_ca int2 NULL,
	qc_serving_pci int2 NULL,
	qc_serving_rsrp numeric NULL,
	qc_serving_sinr numeric NULL,
	qc_serving_rssi numeric NULL,
	bin_x int4 NULL,
	bin_y int4 NULL,
	operator_seq int2 NULL
);
