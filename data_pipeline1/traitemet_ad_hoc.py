import numpy as np
import pandas as pd
import re
import json
from json import loads
import warnings
from collections import Counter
import   data_pipeline


from Utile import *
from Traitement import *
from data_pipeline import *
#from Pipeline import *

def Count_Journal(json_file):

    #'''
    #Count the number of different drugs cited by each newspaper.

    #returns three elements:
    #    -> the newspaper that cite the most different drugs
    #    -> the number of citation for this newspaper
    #    -> a dictionary that contains the number of different drugs cited by each newspaper
    #'''

    parsed = loads(json_file)
  #  print("parsed.itemw",parsed.items())

    liste_journal = []

    for drug, items in parsed.items():
        journals = set([journal[0] for journal in items['(Journal,Date)']])
        liste_journal = liste_journal + list(journals)
       # print('list jpoural',liste_journal)

    c = Counter(liste_journal)
    c = sorted(c.items(), key=lambda x: x[1], reverse=True)
    #print(c)
    best, citation = c[0][0], c[0][1]
    #print(c[0][0])
    #print(c[0][1])

   # print(f'The newspaper that quotes the most different drugs is {c[0][0]}, it quotes {c[0][1]} drugs', {}, {})

    return best, citation , c



# json_file = Pipeline2('drugs.csv',
#                       'clinical_trials.csv',
#               'pubmed.csv')
#
# best,citation,c  =Count_Journal(json_file)
# print(c)
