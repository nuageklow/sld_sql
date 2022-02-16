import os, csv
import pandas as pd
import numpy as np
from google.colab import drive

# connect gdrive
drive.mount('/content/drive')
sld_path = os.path.join(os.getcwd(), 'drive', 'MyDrive', 'SLD Global Data', 'zoom_data')
print(os.listdir(sld_path))

def get_csvs(path, report_type):
  ''' sort csv files downloaded from zoom '''
  csv_list = []
  for i in os.listdir(path):
    # print(i.lower())
    if i.startswith('9') and 'csv' in i and report_type in i.lower():
      csv_list.append(i)
  return csv_list

def csv_cleaning(sld_path, csv_list):
  for i in csv_list:
    csv_p = os.path.join(sld_path, i)
    with open(csv_p, 'r') as fin, open(f'{sld_path}/cleaned_{i}', 'w') as fout:
      line_list = fin.readlines()
      print(i, len(line_list))
      # print(line_list)
      for line in line_list:
        if len(line) > 2:
          if line[-2] == ',':
            fout.write(line[:-2] + '\n')
          else:
            fout.write(line)
        else:
          fout.write(line)
 
      # new_line_list = [line[:-1] for line in line_list if line[-1] == ',']
      # fout.write(new_line_list)
      fin.close()
      fout.close()

def csv_to_df(csv_file, sld_path):
  webinar_id = csv_file.split(' - ')[0].split('_')[1]
  print(f'processing {csv_file}')
  csv_path = os.path.join(sld_path, csv_file)
  # print(csv_path)
  if 'attendee' in csv_file.lower():
    df = pd.read_csv(csv_path)  
  else:
    df = pd.read_csv(csv_path, skiprows=5)
    # print(df.columns) 
    if 'First Name' not in df.columns.tolist():
      df = pd.read_csv(csv_path)

  col_list = df.columns.tolist()
  # col_list = [col.replace('?','').rstrip(' ').replace(' ', '_').replace('/','_').replace("'","").lower() for col in col_list]
  col_list = [col.replace(' ','_').lower() for col in col_list]
  col_list = [''.join((w for w in col if w.isalpha() or w == '_')) for col in col_list]
  df.columns = col_list
  df['_id'] = df.index
  df['_id'] = df['_id'].map(lambda x: '_'.join((webinar_id[:-4],str(x))))
  df['event_id'] = webinar_id
  print(col_list)
  return df

report_types = ['registration', 'attendee']
for report_name in report_types:
  print(f'processing report type: {report_name}')
# report_name = 'registration' # attend or reg
  csv_list = get_csvs(sld_path, report_name)
  # csv_list = get_csvs(drive_path) 
  csv_cleaning(sld_path, csv_list)
  df = pd.DataFrame()
  df_list = list(map(lambda x: csv_to_df('cleaned_'+x,sld_path), csv_list))
  print('numbers of df ', len(df_list))
  df = pd.concat(df_list, ignore_index=True)
  df.to_csv('{}/{}_cleaned.csv'.format(sld_path,report_name),index=False)