import json
import csv
from pathlib import Path
import pandas as pd


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

        reader = csv.DictReader(fin)
        tmp = dict()

        # for line in fin:
        #     tmp = json.loads(line)
        for rows in reader:
            for line in rows:
                print(rows, line)
                # tmp = json.loads(line)
                # tmp[rows] = lines
                custom_questions = tmp.get('custom_questions', [])
                tmp = parse_row(tmp, fieldnames)

        print(tmp)

        if questions_map:
            tmp.update(parse_custom_questions(custom_questions, questions_to_skip, questions_map))

        writer.writerow(tmp)

    print(f"File written: {output_file}")
