from Utile import *
from Traitement import *
import json


def Pipeline2(drugs_filepath,
              clinical_filepath,
              pubmed_filepath):

    #'''
    #drugs_filpath: str, filepath of the dataset containing the drugs.
    #clinical_filepath: str, filepath of the dataset containing the scientific publications.
    #pubmed_filepath: str, filepath of the dataset conatining the arcticles.

    #Returns the graph between articles, Newspapers, and drugs in json format
    #'''


    traitement_data = Traitement(drugs_filepath,
                      clinical_filepath,
                      pubmed_filepath)


    print('Creation du graph...')
    df = traitement_data.create_graph()
    print(df)

    #with concurrent.futures.ProcessPoolExecutor() as executor:
    #
    #    f1 = executor.submit(Count_Journal, df, pubmed_df, 'title', 'journal', 'date', drugs)
    #    f2 = executor.submit(Count_Scientific, df, clinical_df, 'scientific_title', 'journal', 'date', drugs)
    #
    #    for f in concurrent.futures.as_completed([f1,f2]):
    #        print(f.result())



    df = traitement_data.Extraction(df, 'Science', True)

    df = traitement_data.Extraction(df, 'PubMed', True)
    print(df)
    #df['(Journal,Date)'] = df['(Journal,Date)'].apply(set)


    print('Done')

    return to_json(df)





# json_file = Pipeline2('drugs.csv',
#                       'clinical_trials.csv',
#                       'pubmed.csv')
#
#
# print(json_file)
