
#
# Data preprocessing
#

import os
import pandas as pd
import numpy as np

# paths

dirname = os.path.dirname(__file__).replace("\\", "/") + "/"

raw_data_folder_path = dirname + "../../Sample_Data/Raw/"
processed_data_folder_path = dirname + "../../Sample_Data/Processed/"
modelling_data_folder_path = dirname + "../../Sample_Data/For_Modelling/"

raw_file_name = "mushrooms_v2 (prob 0.05).csv"

# read raw data

mushrooms = pd.read_csv(raw_data_folder_path + raw_file_name, sep = ',')

# translate codes into names

code_value_dictionary = pd.read_csv(dirname + "code_value_dictionary.csv")
column_names = set(code_value_dictionary["column"])

for column_name in column_names:
    filtered_dictionary = code_value_dictionary[code_value_dictionary["column"] == column_name]

    for index, row in filtered_dictionary.iterrows():
        format = lambda value: row['name'] if value == row['code'] else value
        mushrooms[column_name] = mushrooms[column_name].map(format)

# drop first colum (index)

mushrooms.drop(mushrooms.columns[[0]], axis = 1, inplace = True)

# save as csv

mushrooms.to_csv(processed_data_folder_path + "Mushrooms.csv")

print("-------- End ---------")