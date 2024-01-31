import csv, re, os, datetime

# in_f = '../data/out_tables/ig.csv'

in_folder = '../data/out_tables'
out_path = '../data/out_tables/ig.csv'
out_dict = {}

def _find_item_with_regex(re_ptn, data_str):
    return re.findall(re_ptn, data_str)

def get_data(in_f):

    with open(in_f, 'r') as fr:
        # data = csv.reader(fr)
        data = csv.DictReader(fr)
        data_list = list(data)[0]
        data_dict = dict(data_list)
        fr.close()

    print(f'{in_f}\n{data_dict.keys()}')
    return data_dict

def transform_csv(data_dict):
    subset_output_list = []
    tmp_dict = {}

    values = data_dict['total_value_breakdowns']
    print(values)

    data_keys = _find_item_with_regex(r'(?<=\[\").+?(?=\"\])', values)    
    data_values = _find_item_with_regex(r'(?<=:value ).+?(?=\})', values)

    print(f'{data_keys}\n{data_values}')

    for k, v in zip(data_keys[1:], data_values):
        tmp_dict = {}
        tmp_dict['date_time'] = datetime.date.today().strftime("%Y-%m-%d")
        tmp_dict['name'] = k
        tmp_dict['fan_count'] = v
        tmp_dict['page'] = data_keys[0] 
        subset_output_list.append(tmp_dict)

    return subset_output_list


def post_csv(out_path, output_dict):
    with open(out_path, 'w', encoding='utf-8') as fw:
        csv_writer = csv.writer(fw)
        csv_writer.writerow([h for h in ['date_time','name','fan_count','page']])
        for each in output_dict:

            csv_writer.writerow(each.values())

        fw.close()

def main():
    csv_list = [f for f in os.listdir(in_folder) if f.endswith('.csv') and 'insights' in f]
    output_list = []

    for f in csv_list:
        f_path = os.path.join(in_folder, f)
        data_dict = get_data(f_path)
        subset_output_list = transform_csv(data_dict)
        output_list += subset_output_list
    print(f'{f}\n{output_list}')

    post_csv(out_path, output_list)

main()