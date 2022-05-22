import numpy as np
import pandas as pd
import re
import json
import warnings
"""
La classe traitement recupére les fichier drug ,pubmed et et clinival 
"""
class Traitement():
    def __init__(self,chemin_fichier_drug,chemin_fichier_clinical_trials,chemin_fichier_pubmed):
        self.drugs_df = pd.read_csv(chemin_fichier_drug)
        self.clinical_df = pd.read_csv(chemin_fichier_clinical_trials)
        self.pubmed_df = pd.read_csv(chemin_fichier_pubmed)
        self.drugs = self.drugs_df['drug'].map(lambda x: x.lower()).to_list()

    def create_graph(self):
        # '''
        # drugs: list des medicaments que nous voulons trouver dans le corpus

        # Retourne la dataframe qu'on  utilise pour modeliser la graph.

        # creer a pd.Dataframe pour representer la graph.On utilise pd.Dataframe
        # puisque on peut utiliser la fonction  _tojson pour transformer le dataframe en json

        # '''

        df = pd.DataFrame()
        df['drugs'] = self.drugs
        df['(PubMed,Date)'] = pd.Series([[] for i in range(len(self.drugs))])
        df['(Science,Date)'] = pd.Series([[] for i in range(len(self.drugs))])
        df['(Journal,Date)'] = pd.Series([[] for i in range(len(self.drugs))])
        df.set_index('drugs', drop=True, inplace=True)

        return df

    def traitement_datase(self, var: str) -> pd.DataFrame:

        '''
       Un drug est considéré comme mentionné dans un article PubMed ou un essai clinique(publication scietifique) s’il est mentionné dans le titre de la publication.
       var: str doit etre egale à Science ou PubMed
        '''

        if var == 'Science':
            Dataset = self.clinical_df
            Title_Column_Name = 'scientific_title'

        elif var == 'PubMed':
            Dataset = self.pubmed_df
            Title_Column_Name = 'title'

        else:
            warnings.warn("desolé les inputs doit etre 'Science' or 'PubMed'.")

        # On elimine les doublons
        Dataset.drop_duplicates(subset=[Title_Column_Name], inplace=True)

        # conversion de la date en format datetime et mettre tous les date sur un meme formatb jour/mois/année.
        Dataset['date'] = pd.to_datetime(Dataset['date']).dt.strftime('%d/%m/%Y')

        # suprimer les  NaN value dans le titre , convertir les autres  NaN en  'Unknown' pour pemettre aux utilisateur de savoir
        # que nous connaissons pas l'information.
        Dataset.dropna(subset=[Title_Column_Name], inplace=True)
        Dataset.replace(float("NaN"), 'Unknown', inplace=True)

        # Transformer  UNICODE charactere
        Dataset[Title_Column_Name] = Dataset[Title_Column_Name].apply(lambda x: x.encode("ascii", "ignore").decode())
        Dataset['journal'] = Dataset['journal'].apply(lambda x: x.encode("ascii", "ignore").decode())

        # comme nous voulons avoir les mêmes journaux indépendamment de la ponctuation.
        # on utilise une regex pour ne garder que les lettres
        Dataset['journal'] = Dataset['journal'].apply(lambda x: re.sub(r'[^\w\s]', '', x))

        if var == 'Science':
            self.clinical_df = Dataset
        else:
            self.pubmed_df = Dataset


    def Extraction(self, df:pd.DataFrame, var: str, preprop: bool = True) -> pd.DataFrame:


        '''
        df: pd.Dataframe, Le Dataframe que nous voulons remplir, il représente notre graphique.
        var: str, Si nous voulons regarder la publication scientifique ou la publication médicale, il faut que ce soit 'Science ou 'PubMed'..
        preprop: bool, Vraie si nous voulons prétraiter nos données avant l'extraction.

        La fonction d'extraction associe les médicaments aux articles et journaux qui les citent sous la forme d'une liste de tuple de la forme [(article ou journal,date)].
        '''


        if preprop == True:
            self.traitement_datase(var)

        if var == 'Science':
            Dataset = self.clinical_df
            Title_Column_Name = 'scientific_title'

        elif var == 'PubMed':
            Dataset = self.pubmed_df
            Title_Column_Name = 'title'

        else:
            warnings.warn("Désolé, l'entrée var doit être 'Science' ou 'PubMed'")


        for j in range(len(self.drugs)):

           # print(f'{self.drugs[j]} is being processed')

            condition = Dataset[Title_Column_Name].apply(lambda x : x.lower().find(self.drugs[j])) != -1
            IS_CITED = Dataset[condition].index.tolist()

            for element in zip(
                    Dataset[Title_Column_Name][IS_CITED].tolist(),
                    Dataset['date'][IS_CITED].tolist()
            ):
                df[f'({var},Date)'].loc[self.drugs[j]].append(element)

            for element in zip(
                    Dataset['journal'][IS_CITED].tolist(),
                    Dataset['date'][IS_CITED].tolist()
            ):
                df['(Journal,Date)'].loc[self.drugs[j]].append(element)

        return df


# traitement = Traitement('drugs.csv',
# 	'clinical_trials.csv',
# 	'pubmed.csv')
#
# #print(traitement.pubmed_df.drop_duplicates(subset=['title'], inplace=True))
# #print(traitement.drugs_df©)
# df =traitement.create_graph()
# print(range(len(traitement.drugs)))
# conditiion=traitement.pubmed_df['title'].apply(lambda x : x.lower().find('diphenhydramine'))!= -1
# IS_CITED=traitement.pubmed_df[conditiion].index.tolist()
# print(traitement.pubmed_df[conditiion].index.tolist())
# print(IS_CITED)
# Title_Column_Name='title'
# #print(pd.Series([[] for i in  range(0,7)]))
# print( traitement.pubmed_df['title'][2])
# #print(traitement.pubmed_df['date'][IS_CITED].tolist())
# for element in zip(
#             traitement.pubmed_df[Title_Column_Name][IS_CITED].tolist(),
#             traitement.pubmed_df['date'][IS_CITED].tolist()
#     ):
#         print(df[f'(PubMed,Date)'].loc['diphenhydramine'].append(element))
#
