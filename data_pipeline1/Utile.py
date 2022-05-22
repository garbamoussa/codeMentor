import pandas as pd
import json



def to_json(Dataset: pd.DataFrame)->json:
    #'''
    #Convert the Dataset in json format
    #'''
    return Dataset.to_json(orient="index")
