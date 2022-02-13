# import libs 
import os, csv 
import pandas as pd
import numpy as pd
from google.colab import drive

# connect gdrive
drive.mount('/content/drive')
p = os.path.join(os.getcwd(), 'drive', 'MyDrive', 'SLD Global Data', 'zoom_data')
print(os.listdir(p))


def get_csvs(path, report_type):
    ''' sort csv files downloaded from zoom '''
  csv_list = []
  for i in os.listdir(path):
    # print(i.lower())
    if i.startswith('9') and 'csv' in i and report_type in i.lower():
      csv_list.append(i)
  return csv_list
  

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