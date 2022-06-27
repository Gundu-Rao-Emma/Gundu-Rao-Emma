CREATE TABLE db_maint
(
	db_nm                nvarchar(100)  NOT NULL ,
	schema_nm            nvarchar(100)  NULL ,
	tbl_nm               nvarchar(100)  NULL ,
	db_maint_tp_ind      nvarchar(2)  NOT NULL ,
	rtntn_dur            integer  NOT NULL ,
	rtntn_dur_ut_cd      nvarchar(10)  NOT NULL ,
	biz_eff_strt_dtm     timestamp with time zone  NOT NULL ,
	biz_eff_end_dtm      timestamp with time zone  NOT NULL ,
	etl_strt_ts          timestamp with time zone  NOT NULL ,
	etl_end_ts           timestamp with time zone  NOT NULL
);