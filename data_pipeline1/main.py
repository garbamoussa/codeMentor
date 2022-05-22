# from Utile import *
# import json
# from traitemet_ad_hoc import *
# from data_pipeline  import *
from data_pipeline import Pipeline2
from traitemet_ad_hoc import Count_Journal

print("##################  menu data  pipeline ####################")

print("1 pour voir la donnee  en JSON:  \n2 pour voir le traitement   ad_hoc : ")
result_input = input("....")
print(result_input)
if result_input == '1':
    json_file = Pipeline2('drugs.csv',
                          'clinical_trials.csv',
                          'pubmed.csv')
    print("JSON qui represente un graphe de liaison entre les différents medicaments  \n et leurs mentions respectives dans les differentes publications PubMed, \nles differentes publications scientifiques et enfin les journaux avec la date associee à chacune de ces mentions.",json_file)
elif result_input=='2':
    json_file = Pipeline2('drugs.csv',
                          'clinical_trials.csv',
                          'pubmed.csv')
    print("le json produit par la data pipeline qui  extracte le nom du journal qui mentionne le plus de médicaments différents",Count_Journal(json_file))
