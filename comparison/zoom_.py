import csv, os
# import pandas as pd

print(os.getcwd())

def get_headers(csv_file):
    '''  '''
    with open(csv_file, 'r') as f:
        header = f.readlines()[0]
        header = header.replace(',', ' text NULL,')+ ' text NULL,'.replace('&','')
        # header = [f'{col} text NULL,\n' for col in header]
        print(header)

    return header
        
def create_table(header, csv_file):
    table_name = os.path.basename(csv_file).split('_')[0]
    sql = '''
    DROP TABLE IF EXISTS zoom.{}_raw;

    CREATE TABLE zoom.{}_raw (
        {}
    CONSTRAINT {}_raw_pkey PRIMARY KEY (_id)
    );
     
    \COPY zoom.{}_raw FROM '{}' DELIMITER ',' CSV HEADER;
    '''.format(table_name, table_name, header, table_name, table_name,csv_file)
    print(sql)

    return sql    

data_path = os.path.join(os.getcwd(), '..', 'data')
csv_list = [os.path.join(data_path, csv_file) for csv_file in os.listdir(data_path)]
print(csv_list)

with open('zoom_raw.sql', 'w') as f:
    f.write('''
    CREATE SCHEMA IF NOT EXISTS zoom;

    ''')
    f.close()

for each_csv in csv_list:
    header = get_headers(each_csv)
    sql = create_table(header, each_csv)
    with open('zoom_raw.sql', 'a') as f:
        f.write(sql)
        f.close()


