
![Servier](download.jpeg "Legend")

Objectif : Réaliser un code clair et proprement structuré. Mettre en avant les  éléments considérés comme essentiels pour du code utilisable dans un environnement de production. Mettre l’accent sur vos connaissances en conception de jobs de manipulation de données ainsi que les bonnes pratiques python.



<h1 align=center>Python et Data Engineering</h1>






<h1 align=center>Données</h1>

drugs.csv : contient les noms de drugs (des médicaments) avec un id (atccode) et un nom (drug)

pubmed.csv : contient des titres d’articles PubMed (title) associés un journal (journal)   une date donnée (date) ainsi qu’un id (id)

pubmed.json : même structure que pubmed.csv mais en format JSON

clinical_trials.csv : contient des publications scientifiques avec un titre (scientific_title), un id (id), un journal (journal) et une date (date).



<h2 align=center> Test Python DE Servier :</h2>

<h3>Auteur: </h3>

GARBA Moussa<br>



<h2>Objectifs</h2>

L’objectif est de construire une data pipeline permettant de traiter les données définies dans la partie précédente afin de générer le résultat décrit dans la partie 3.

Data pipeline

Votre data pipeline doit produire en sortie un fichier JSON qui représente un graphe de liaison entre les différents médicaments et leurs mentions respectives dans les différentes publications PubMed, les différentes publications scientifiques et enfin les journaux avec la date associée   chacune de ces mentions. La représentation ci-dessous permet de visualiser ce qui est attendu. Il peut y avoir plusieurs manières de modéliser cet output et vous pouvez justifier votre vision


<h2>Démarches</h2>

Classe Traitement


Cette classe est utilisée pour extraire les articles pour chaque médicament. 

Cette classe contient 3 fonctions :
    
    - create_graph() : Cette fonction crée un Dataframe afin de représenter le graphique. 
    Nous choisissons de représenter le graphique sous forme de Dataframe car nous pouvons facilement le convertir en json et il est plus facile à manipuler.


    - traitement_datase() : prétraitement du jeu de données afin d'éviter les doublons et de supprimer les lignes inutiles afin de gagner du temps si nous traitons des jeux de données plus importants.

    - Extraction() : Pour chaque médicament, on extrait les articles qui le citent.
    
    
Les fonctions d'extraction et de prétraitement traitent un seul jeu de données à la fois. 



J'ai choisi de les construire ainsi afin de paralléliser l'exécution pour chaque jeu de données. En effet, le graphe est créé de telle manière que nous pouvons être remplis simultanément avec les publications médicales et les articles scientifiques. Nous appliquons ensuite 'set' à la colonne journal afin d'éviter de la compter deux fois (dans le cas où deux articles du même journal citent le même médicament le même jour).



Adhoc  fonction très simple qui récupère tous les journaux dans notre graphique et utilise Counter pour avoir le nombre d'occurrences pour chaque journal.




                                            ############# INSTALLATION DE LOGICIELS  ##############

1. INSTALLER PYTHON
2. INSTALLER DOCKER





################################################################### LANCEMENT DU PROJET ################################################


                                                     ##################### Docker ##################


Docker Hub :  

1. Aller à la racine du projet (repertoire du projet )
2. Lancer la commande "**docker build -t <nom_image> .**" pour  creer l'image
3. Une fois l'image creéé vous pouvez  lancez la commande **docker  push** pour le  publier sur le docker hub ( dans mon cas garbam/servierdatapipeline)
4. Demarrer le projet en lançant la commande **docker run -it <nom_image>**
5. Une menu est proposé 
6. Tapez la commande 1 sur le terminal pour voir la donné en format json ou 2   pour voir le traitement ad_hoc


                                                   ########################  EN LOCALE ##################


Pour lancer le projet en locale
1. Installer d'abord les requirements.txt en executant la commande pip install requiremets.txt
2. Une fois le requiremets installés exutez la commade "**python main.py**" pour lancer le projet
3. Une menu est proposé
6. Tapez la commande 1 sur le terminal pour voir la donéé json ou 2   pour voir le traitement ad_hoc


<h1 align=center>Axes d'amélioration dans un contexte de Big data</h1>

Mettre en place ETL  qui consiste à récupérer des données d’une source, à les transformer dans un nouveau format, puis à les renvoyer dans une seconde source adaptée à ce nouveau format.


Créer des User defined Functions pour automatiser des  ETL avec Airflow pour orchestrer  de workflows et de tâches.

Créer de DAG pour besoin et tâches 




