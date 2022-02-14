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
  webinar_id = csv_file.split(' - ')[0]
  print(f'processing {csv_file}')
  csv_path = os.path.join(sld_path, csv_file)
  # print(csv_path)
  df = pd.read_csv(csv_path, skiprows=5)
  # print(df.columns)
  if 'First Name' not in df.columns.tolist():
    df = pd.read_csv(csv_path)

  col_list = df.columns.tolist()
  col_list = [col.replace(' ', '_').replace("'","").lower() for col in col_list]
  df.columns = col_list
  df['event_id'] = webinar_id


  # print(df.columns)
  # df.to_csv(f'remap_{file_name}')
  return df

report_name = 'registration' # attend or reg
csv_list = get_csvs(sld_path, report_name)
# csv_list = get_csvs(drive_path)
csv_cleaning(sld_path, csv_list)
df = pd.DataFrame()
df_list = list(map(lambda x: csv_to_df('cleaned_'+x,sld_path), csv_list))
df = pd.concat(df_list, ignore_index=True)
df.to_csv('{}/{}_cleaned.csv'.format(sld_path,report_name),index=False)

def csv_to_df(i, sld_path):
  webinar_id = i.split(' - ')[0]
  print(webinar_id)
        # "first_name",
        # "last_name",
        # "email",
        # "city",
        # "country_region",[
        # "age",
        # "gender",
        # "company",
        # "industry",
        # "latest_job_position",
        # "job_level",
        # "event_referral",
        # "event_id"

  col_list = ['First Name',
              'Last Name',
              'Email',
              'City',
              'Country/Region',
              'Phone',
              'Organization',
              'Registration Time',
              'Approval Status',
              'Gender',
              "What's your age bracket?",
              'In which industry do you work?',
              'What is the functional role of your latest job position?',
              'What is your Job level?',
              'How did you find out about this event?'
              ]

  # df = pd.read_csv(os.path.join(sld_path,i), header=None, names=header, skiprows=1, index_col=False)
  df = pd.read_csv(os.path.join(sld_path,f'cleaned_{i}'))
  print(df)
  df = df[col_list]
  print(df.shape)
  df['event_id'] = webinar_id
  # print(df)
  return df
