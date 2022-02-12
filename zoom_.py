import csv, os
import pandas as pd

def remapping_cols(zoom_csv):
    file_name = os.path.basename(zoom_csv)
    df = pd.read_csv(zoom_csv)
    col_list = df.columns.tolist()
    col_list = [col.replace(' ', '_').replace("'","").lower() for col in col_list]
    df.columns = col_list

    print(df.columns)
    df.to_csv(f'remap_{file_name}')
    # return df

data_path = os.path.join(os.getcwd(), '..', 'data')
csv_list = [os.path.join(data_path, csv_file) for csv_file in os.listdir(data_path) if csv_file[0].isdigit()]

for each_csv in csv_list:
    remapping_cols(each_csv)
