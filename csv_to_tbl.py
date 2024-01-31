import os, csv, re

class TBL:
    def __init__(self, csv_file, tbl_name):
        self.csv_file = csv_file
        self.data = []
        self.tbl_name = tbl_name
        self.col_list = []

    @property
    def tbl_name(self):
        return self._tbl_name

    @tbl_name.setter
    def tbl_name(self, value):
        value = value if value is not None else self._get_tbl_name()
        self._tbl_name = value

    @property
    def col_list(self):
        return self._col_list

    @col_list.setter
    def col_list(self, value):
        value = self._get_columns(self.data)
        self._col_list = value

    def _get_tbl_name(self):
        tbl_name = os.path.basename(self.csv_file).split('.')[0]
        print(f'tbl_name: {tbl_name}')
        return tbl_name

    def _get_columns(self, data_list):
        print(data_list)
        return list(data_list[0].keys())

    def __str__(self):
        return f'Table {self.tbl_name} retrieved from {self.csv_file} with columns {self.col_list}'

    def __repr__(self):
        return f"TBL(\'{self.csv_file}\', \'{self.tbl_name}\', \'{self.col_list}\')"

class TBLData(TBL):
    def __init__(self, csv_file, tbl_name):
        super().__init__(csv_file, tbl_name)
        self.data = []

    @property
    def data(self):
        return self._data

    @data.setter
    def data(self, value):
        self._setup(self.csv_file)
        value = self._get_data(self.csv_file)
        self._data = value

    def _setup(self, csv_file):
        print(f'set up ')

    def _get_data(self, csv_file):
        with open(csv_file, 'r') as fr:
            data = csv.DictReader(fr)
            data_list = list(data)
            fr.close()

        return data_list

    

class CSV2TBL(TBLData):
    def __init__(self, csv_file, tbl_name=None):
        super().__init__(csv_file, tbl_name)

    def _concat_list(self, sql_list):
        return ' '.join(sql_list)


    def clean_col(self, col_list):
        cleaned_col_list = []

        clean_dict = {
        '-': '_',
        ',|\n': '',
        'name': 'd_name',
        'period': 'd_period'
        }

        for col in col_list:
            for k, v in clean_dict.items():
                col = re.sub(k, v, col)
            cleaned_col_list.append(col)

        return cleaned_col_list

    def clean_data(self, dp):
        cleaned_dict = {}

        for k, v in dp.items():
            new_v = re.sub(r'\n','<br/>', v)
            new_v = re.sub(r',|"',' ', new_v)
            cleaned_dict[k] = new_v
        # print(cleaned_dict)

        return cleaned_dict

    def clean_data_whole(self, data_list):
        cleaned_data_list = []

        clean_dict = {
        ',|\n': ''
        }

        for dp in data_list:
            cleaned_dict = {}
            print(dp)
            for mk, mv in clean_dict.items():
                # dp = dict(map(lambda (k,v) : re.sub(mk, mv, v), dp.iteritems()))
                dp = list(map(lambda x: re.sub(mk, mv, x), dp.values()))
                dp = dict(map(lambda x: ()))
                a = dict(map(lambda x: (x, {}), ins))
                # {map(lambda x: f(x),bill.values())}

                # dp = re.sub(k, v, map(lambda x: x, dp.values()))
                # print(dp)
            cleaned_data_list.append(dp)

        return cleaned_data_list


    def generate_tbl_sql(self, col_list, num_cols=[]):
        sql_list = []

        sql_prefix = f"CREATE TABLE IF NOT EXISTS {self.tbl_name}(\n"
        sql_list.append(sql_prefix)

        for idx, col in enumerate(col_list):
            if idx == 0:
                sql_line = f"\t{col} text NOT NULL DEFAULT ''::text,\n"
            elif col in num_cols:
                sql_line = f"\t{col} INTEGER NULL,\n"
            elif idx == len(col_list) - 1:
                sql_line = f"\t{col} text NOT NULL"
            else:
                sql_line = f"\t{col} text NULL,\n"
            sql_list.append(sql_line)
        sql_suffix = f"\n)"
        sql_list.append(sql_suffix)

        return self._concat_list(sql_list)

    def generate_new_csv(self, csv_path, col_list, data_list):
        with open(csv_path, 'w') as fw:
            writer = csv.DictWriter(fw, fieldnames=col_list)

            writer.writeheader()
            writer.writerows(data_list)

            fw.close()

    def run(self):
        new_col_list = self.clean_col(self.col_list)
        new_table = self.generate_tbl_sql(new_col_list)
        print(new_table)

        new_data_list = []
        for dp in self.data:
            cleaned_dp = self.clean_data(dp)
            new_data_list.append(cleaned_dp)

        # new_data_list = self.clean_data(self.data)

        data_path = os.path.dirname(self.csv_file)
        new_csv_name = f'sql_{self.tbl_name}.csv'
        new_csv_path = os.path.join(data_path, new_csv_name)

        self.generate_new_csv(new_csv_path, new_col_list, new_data_list)





if __name__ == '__main__':
    csv_file = './data/post_info.csv'
    CSV2TBL(csv_file).run()
