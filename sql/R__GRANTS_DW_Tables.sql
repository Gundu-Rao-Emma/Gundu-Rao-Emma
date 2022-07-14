CREATE OR REPLACE PROCEDURE public.GRANT_ALL_TABLES_VIEWS(i_schema varchar(25))
LANGUAGE plpgsql AS $$
declare
    -- The procedure would be created under PUBLIC schema.
    -- To Grant access to all the Tabes and Views in the schema passed as an Input parameter
	-- Since there are Multiple schema´s in the DB, this PROCEDURE is designed to be called for a SCHEMA explicitly
    rec_objects   record;
    stmt_schema_rw varchar(250);
    stmt_schema_read varchar(250);
    stmt_table_rw varchar(250);
    stmt_table_read varchar(250);    
begin
	stmt_schema_rw := 'grant usage on schema '||i_schema||' to group data_engineering_rw';
	stmt_schema_read := 'grant usage on schema '||i_schema||' to group data_engineering_read';
	
	EXECUTE stmt_schema_rw;
    EXECUTE stmt_table_read;   
	
	FOR rec_objects IN
        SELECT distinct table_schema||'.'||table_name as tab_det
		FROM information_schema.tables
		WHERE table_type in ('BASE TABLE','VIEW')
		AND table_schema in (i_schema)
    LOOP
       -- GRANT USAGE ON  SCHEMA fc_fulfilments_chile to group data_engineering_rw;
	   -- grant all on rec_objects.table_name to group data_engineering_rw;
	   -- grant select on rec_objects.table_name to group data_engineering_read;
	   
       stmt_table_rw := 'grant all on '||rec_objects.tab_det||' to group data_engineering_rw';
       --  RAISE NOTICE 'stmt1 is % ', stmt_rw;       
       
       stmt_table_read := 'grant select on '||rec_objects.tab_det||' to group data_engineering_read';
      
       EXECUTE stmt_table_rw;      
       EXECUTE stmt_schema_read;     
       
       
    END LOOP;   
exception 
    when others then 
        raise notice 'Exception occurred executing GRANT_ALL_TABLES_VIEWS';  
END
$$;


GRANT USAGE ON SCHEMA public to group data_engineering_rw;
GRANT USAGE ON SCHEMA public to group data_engineering_read;
GRANT EXECUTE ON PROCEDURE public.GRANT_ALL_TABLES_VIEWS(VARCHAR) TO GROUP data_engineering_rw;
GRANT EXECUTE ON PROCEDURE public.GRANT_ALL_TABLES_VIEWS(VARCHAR) TO GROUP data_engineering_read;



CREATE OR REPLACE PROCEDURE public.grant_individual_objects(i_object varchar)
	LANGUAGE plpgsql
AS $$
	
declare
    -- procedures and functions would be created under PUBLIC schema
    -- To Grant access to individual Table, View or Procedure passed as an Input parameter assuming the user has access to the schema
    rec_objects   record;
    stmt_table_rw varchar(250);
    stmt_table_read varchar(250);  
    stmt_proc_rw varchar(250);
    stmt_proc_read varchar(250);  
begin
	FOR rec_objects IN
        SELECT distinct 'Non_Procedure' object_type, table_schema||'.'||table_name as tab_det
		FROM information_schema.tables
		WHERE table_type in ('BASE TABLE','VIEW')
		AND table_name in (i_object)
		union 
		SELECT 'Procedure' object_type, proname 
        FROM pg_proc_info 
        WHERE proname in (i_object)
    loop
	    
	    if rec_objects.object_type = 'Non_Procedure'
	    then 
		   stmt_table_rw := 'grant all on '||rec_objects.tab_det||' to group data_engineering_rw';
	       stmt_table_read := 'grant select on '||rec_objects.tab_det||' to group data_engineering_read';
           EXECUTE stmt_table_rw;
	       EXECUTE stmt_table_read;
	   
	    elsif rec_objects.object_type = 'Procedure'
	    then
	        stmt_proc_rw := 'grant EXECUTE on PROCEDURE public.'||rec_objects.proname||' to group data_engineering_rw';
            stmt_proc_read := 'grant EXECUTE on PROCEDURE public. '||rec_objects.proname||' to group data_engineering_read';
            EXECUTE stmt_proc_rw;
            EXECUTE stmt_proc_read;
	    
	    end if;
       
    END LOOP;   
   
exception 
    when others then 
        raise notice 'Exception occurred executing grant_individual_objects';  
END

$$
;

GRANT EXECUTE ON PROCEDURE public.grant_individual_objects(VARCHAR) TO GROUP data_engineering_rw;
GRANT EXECUTE ON PROCEDURE public.grant_individual_objects(VARCHAR) TO GROUP data_engineering_read;

CREATE OR REPLACE PROCEDURE public.Analyse_Collect_Statistics(i_object varchar)
	LANGUAGE plpgsql
AS $$

declare
    -- The procedure collects STATISTICS for the object passed as parameter routinely at the end of every regular load or update cycle
	-- STATISTICS would be used by query planner uses to choose optimal plans
    rec_objects   record;
    stmt_analyse varchar(250);

begin
	-- Parameter analyze_threshold_percent parameter gives flexibilty if the percentage of 
	-- table rows that have changed since the last ANALYZE command run is lower than the threshold specified 
	set analyze_threshold_percent to 20; -- This value can be modified
	
	FOR rec_objects IN
        SELECT distinct table_schema||'.'||table_name as tab_det
		FROM information_schema.tables
		WHERE table_type in ('BASE TABLE')
		AND table_name in (i_object)
    LOOP 
		stmt_analyse := 'analyze '||rec_objects.tab_det;
		
	    EXECUTE stmt_analyse;
	
        -- analyze verbose;  -- To Analyze all tables in given Redshift database
    END LOOP;   
exception 
    when others then 
        raise notice 'Exception occurred executing Analyse_Collect_Statistics';  
END

$$
;

GRANT EXECUTE ON PROCEDURE public.Analyse_Collect_Statistics(VARCHAR) TO GROUP data_engineering_rw;
GRANT EXECUTE ON PROCEDURE public.Analyse_Collect_Statistics(VARCHAR) TO GROUP data_engineering_read;