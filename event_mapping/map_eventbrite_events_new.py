import pandas as pd
import numpy as np

df = pd.read_csv('in/tables/events.csv')

# add_data = pd.DataFrame({'name_text': ['Test_Meet Up_SIN'], 'summary': ['#Visualization #Beginner #SQL This is a test data']})

# df=pd.concat([df,add_data], axis =0 )

df['event_type']=df.name_text.apply(lambda x: x.split('_')[1] if len(x.split('_'))>=3 else 'no_event_type')

df['chapter'] = df.name_text.apply(lambda x: x.split('_')[2] if len(x.split('_'))>=3 else 'no_chapter')

df['event_topic'] = df.summary.apply(lambda x: x.split('#')[1].strip()  if (pd.notnull(x)) and (len(x.split('#'))>=2) else 'no_event_topic')

df['level'] = df.summary.apply(lambda x: x.split('#')[2].strip()  if (pd.notnull(x)) and ( len(x.split('#'))>=3) else '')

df['event_focus_skill'] = df.summary.apply(lambda x: x.split('#')[3].split("\n")[0].strip()  if (pd.notnull(x)) and (len(x.split('#'))>=4) else '')

event_type_lookup = ['meet up','hackathon','hands-on workshop','workshop','certification program','other','podcast','internal meeting','test','networking','mentoring']

chapter_lookup = ['abv','akl','evn','sgn','hkg','cgk','jnb',
                  'kul','lax','mnl','mel','prg','rep','sin',
                  'syd','uae','lhr','dxb','del']

event_topic_lookup =['visualization','programming','soft skills','digital marketing','other','intro to data','data']

level_lookup = ['beginner', 'intermediate', 'advanced']

event_focus_skill_lookup = ['python','power bi','tableau','data storytelling'    ,'leadership','google analytics','r','sql','machine learning','google data studio','yellowfin','qlik','social media','hiring','data basics','ai']

df.event_topic = np.where(df.event_topic.str.lower().isin(event_topic_lookup), df.event_topic, '')

df.chapter = np.where(df.chapter.str.lower().isin(chapter_lookup), df.chapter, '')

df.level = np.where(df.level.str.lower().isin(level_lookup), df.level, '')

df.event_focus_skill = np.where(df.event_focus_skill.str.lower().isin(event_focus_skill_lookup), df.event_focus_skill, '')

df.event_type = np.where(df.event_type.str.lower().isin(event_type_lookup), df.event_type, '')

chapter_mapping = { 'abv':'Abuja',
                    'akl':'Auckland',
                    'evn':'Yerevan',
                    'sgn':'Ho Chi_Minh',
                    'hkg':'Hong Kong',
                    'cgk':'Jakarta',
                    'jnb':'Johannesburg',
                    'kul':'Kuala Lumpur',
                    'lax':'Los Angeles',
                    'mnl':'Manila',
                    'mel':'Melbourne',
                    'prg':'Prague',
                    'rep':'Siem Reap',
                    'sin':'Singapore',
                    'syd':'Sydney',
                    'uae':'UAE',
                    'lhr':'London',
                    'dxb':'Dubai',
                    'del':'India'
}

df.chapter= df.chapter.str.lower().map(chapter_mapping)

for_event_mapping = df[(df.event_type !='') | (df.event_topic !='') | ~(df.chapter.isnull())][['id', 'start_local', 'name_text', 'summary', 'event_type', 'chapter', 'event_topic', 'level', 'event_focus_skill']]

for_event_mapping.to_csv('/data/out/tables/eventbrite_event_mapping.csv', index=False)
