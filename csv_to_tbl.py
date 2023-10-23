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
        value = self._get_data(self.csv_file)
        self._data = value

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
        clean_dict = {
        '-': '_',
        ',|\n': '',
        'name': 'd_name',
        'period': 'd_period'
        }

        cleaned_col_list = []
        for col in col_list:
            for k, v in clean_dict.items():
                col = re.sub(k, v, col)
            cleaned_col_list.append(col)

        return cleaned_col_list

    def clean_data(self):
        pass

    def create_tbl_sql(self, col_list, num_cols=[]):
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


    def run(self):
        new_col_list = self.clean_col(self.col_list)
        new_table = self.create_tbl_sql(new_col_list)
        print(new_table)


if __name__ == '__main__':
    csv_file = './data/post_info.csv'
    CSV2TBL(csv_file).run()
