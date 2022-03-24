import json
import csv
from pathlib import Path
import pandas


# Load configuration

with open('in/files/parsing_config.json') as config:
    EVENTS = json.load(config)['events']

# Get value from dictionary based on . path
def get_value(event, path, default=None):
    components = path.split('.', maxsplit=1)
    try:
        level, children = components
        try:
            deeper_level = event[level]
        except KeyError:
            raise KeyError("no value for '{}' in '{}".format(path, event))
        else:
            return get_value(deeper_level, children)
    except ValueError:
        last_level = components[0]
        return event.get(last_level, default)
    except KeyError:
        return default
        # print("no value for '{}' in '{}".format(path, event))
        # raise KeyError("no value for '{}' in '{}".format(path, event))

# parse data from rows into dictionary
def parse_row(row, fields):
    parse_result = {}
    for field in fields:
        parse_result[field] = get_value(row, field)
    return parse_result

def parse_custom_questions(custom_questions, questions_to_skip, questions_map):
    q = {}
    for question in custom_questions:
        if question["title"] not in questions_to_skip:
            try:
                q[questions_map[question["title"]]] = question["value"]
            except KeyError:
                print(f"Question {question['title']} is not in dict questions_map or questions_to_skip")
                raise
        else:
            continue
    return q


# process events
for event in EVENTS:
    input_file = event['input_file']
    output_file = event['output_file']

    question_fields = event.get('question_fields', [])
    questions_to_skip = event.get('questions_to_skip', [])
    questions_map = event.get('questions_map')

    print(f"Parsing: {input_file}...")

    with open(input_file, 'r') as fin, open(output_file, 'w') as fout:
        fieldnames = event['fields']
        writer = csv.DictWriter(fout, fieldnames + question_fields, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        for line in fin:
            tmp = json.loads(line)
            custom_questions = tmp.get('custom_questions', [])
            tmp = parse_row(tmp, fieldnames)

            if questions_map:
                tmp.update(parse_custom_questions(custom_questions, questions_to_skip, questions_map))

            writer.writerow(tmp)

    print(f"File written: {output_file}")


## Mapping from Hashtags
def parse_event_mapping(line):
    len_agenda_split = len(line['agenda'].split('#')) if 'agenda' in line.keys() else 0
    # agenda_split = line['agenda'].split('#') if 'agenda' in line.keys() else []
    # print(line)
    # print('agenda_split: {}'.format(agenda_split))
    proc_line = {
        "uuid": line["uuid"],
        "id": line["id"],
        "start_time": line["start_time"],
        "topic": line["topic"],
        "agenda": line["agenda"] if "agenda" in line.keys() else 'no_agenda',
        "event_type": line["topic"].split('_')[1] if len(line["topic"].split('_'))>=3 else 'no_event_type',
        "chapter": line["topic"].split('_')[2] if len(line["topic"].split('_'))>=3 else 'no_chapter',
        "event_topic": line["agenda"].split('#')[1].strip()  if (("agenda" in line.keys()) and ( len_agenda_split>=2)) else 'no_event_topic',
        "level": line["agenda"].split('#')[2].strip() if (("agenda" in line.keys()) and ( len_agenda_split>=2)) else 'no_level',
        "event_focus_skill": line["agenda"].split('#')[3].split("\n")[0].strip() if (("agenda" in line.keys()) and ( len_agenda_split>=2)) else 'no_event_focus_skill'
    }
    return proc_line

events_mapping_fields = ["uuid","id","start_time","topic","agenda", "event_type", "chapter","event_topic", "level","event_focus_skill"]

with open('in/files/webinars.ndjson', 'r') as fin, open('/data/out/tables/zoom_webinar_event_mapping.csv', 'w') as fout:
    fieldnames = events_mapping_fields
    writer = csv.DictWriter(fout, fieldnames)
    writer.writeheader()


    for line in fin:
        tmp = json.loads(line)
        tmp = parse_event_mapping(tmp)
        writer.writerow(tmp)


with open('in/files/meetings.ndjson', 'r') as fin, open('/data/out/tables/zoom_meeting_event_mapping.csv', 'w') as fout:
    fieldnames = events_mapping_fields
    writer = csv.DictWriter(fout, fieldnames)
    writer.writeheader()


    for line in fin:
        tmp = json.loads(line)
        tmp = parse_event_mapping(tmp)
        writer.writerow(tmp)
