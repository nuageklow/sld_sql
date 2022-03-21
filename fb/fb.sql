/* 

post_clicks_unique
post_engaged_users
post_reactions_like_total
post_impressions


Command Line Interface Code
FB_csv
id	ex_account_id	fb_graph_node	parent_id	name	key1	key2	value	period	end_time	title	description

*/


WITH 
p_clicks AS 
 id AS id,
 value AS metric
WHERE 


CREATE OR REPLACE FUNCTION metrictbl()
    RETURNS void AS $$
DECLARE
    columnNames RECORD;
    value RECORD;
BEGIN
    /* clear table */
    FOR columnNames IN  SELECT * from pg_tables where tablename = 'tmptable'
        LOOP
            DROP TABLE tmptable ;        
        END LOOP;
    CREATE TABLE tmptable (id TEXT PRIMARY KEY, metric TEXT);
    FOR columnNames IN 
        SELECT DISTINCT(value)
    


CREATE OR REPLACE FUNCTION taxamount() RETURNS void as $$
DECLARE
        columnNames RECORD;
    invoiceids RECORD;
BEGIN
    FOR columnNames IN  SELECT * from pg_tables where tablename = 'tmptable'
        LOOP
            DROP TABLE tmptable ;        
        END LOOP;
    CREATE TABLE tmptable (invoiceid integer PRIMARY KEY);
    FOR columnNames IN SELECT distinct(replace(taxname,' ','')) as taxnames from tbltaxamount
        LOOP
                EXECUTE 'ALTER TABLE tmptable ADD ' || columnNames.taxnames || ' numeric(9,2) DEFAULT 0';
        END LOOP;
    FOR invoiceids IN SELECT distinct(invoiceid) from tbltaxamount
    LOOP
        EXECUTE 'INSERT INTO tmptable (invoiceid) VALUES (' || invoiceids.invoiceid || ')';
    END LOOP;
    FOR invoiceids IN SELECT * from tbltaxamount
    LOOP
        EXECUTE 'UPDATE tmptable SET ' || replace(invoiceids.taxname,' ','') || ' = ' || invoiceids.taxamt  || ' WHERE invoiceid = ' || invoiceids.invoiceid;
    END LOOP ;
RETURN;
END;
$$ LANGUAGE plpgsql;