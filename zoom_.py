import csv, os
import pandas as pd

def remapping_cols(zoom_csv):
    df = pd.read_csv(zoom_csv)
    print(df.columns)


data_path = "D:\Documents\volunteer\SLD\data"
csv_list = [csv_file for csv_file in os.listdir(data_path) if csv_file[0].isdigit()]
print(csv_list)
