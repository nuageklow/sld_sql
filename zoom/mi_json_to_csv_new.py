import json
import csv
from pathlib import Path
import pandas
import re


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
    invalid_q = []
    for question in custom_questions:
        if question["title"].strip().lower() not in list(map(lambda qs: qs.strip().lower(), questions_to_skip)):
            question_key = questions_map.get(question["title"].strip(), '')
            if question_key:
                q[question_key] = question.get("value", "")
            else:
                invalid_q.append(question["title"])

        else:
            continue
    return q, invalid_q

def parse_split_fields(row, split_fields, defaults=None):
    parse_result = {}
    for split_field in split_fields:
        name = split_field['name']
        field = split_field['field']
        delimeter = split_field.get('delimeter')
        position = split_field['position']
        regex = split_field.get('regex')

        value = get_value(row, field)
        split_value = None

        if delimeter:
            split_values = value.split(delimeter) if value else []
            try:
                split_value = split_values[position]
            except IndexError:
                split_value = None
        elif regex:
            pattern = re.compile(regex)
            match = re.search(pattern, value) if value else None
            split_value = match.group(position) if match else None

        if split_value:
            parse_result[name] = split_value.strip()
        else:
            parse_result[name] = defaults.get(name, '') if defaults else ''

    return parse_result

# process events
for event in EVENTS:
    input_file = event['input_file']
    output_file = event['output_file']

    question_fields = event.get('question_fields', [])
    questions_to_skip = event.get('questions_to_skip', [])
    questions_map = event.get('questions_map')

    split_fields = event.get('split_fields', [])
    defaults = event.get('defaults')

    print(f"Parsing: {input_file}...")

    with open(input_file, 'r') as fin, open(output_file, 'w') as fout:
        fieldnames = event['fields']
        split_field_names = list(map(lambda x: x['name'], split_fields))
        writer = csv.DictWriter(fout, fieldnames + question_fields + split_field_names, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        for line in fin:
            tmp = json.loads(line)
            custom_questions = tmp.get('custom_questions', [])
            res = parse_row(tmp, fieldnames)

            if questions_map:
                q, invalid_q = parse_custom_questions(custom_questions, questions_to_skip, questions_map)
                res.update(q)

                if len(invalid_q) > 0:
                    # print(f"{input_file} has invalid questions. Please check.")
                    error = f"{custom_questions}\n{input_file} has invalid questions. Please check."
                    print("Questions not found:")
                    for inv_q in invalid_q:
                        print(f'{inv_q}')
                    with open('/data/out/files/error_log.ndjson', 'a') as error_log:
                        error_log.write(line + '\n')
                    raise KeyError(error)

            if split_fields:
                res.update(parse_split_fields(tmp, split_fields, defaults))

            writer.writerow(res)

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
