##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
##                    ENSEMBLE-STACKING  
##::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

source('ScriptBase/ScriptsV2/Preprocessing.R')
source('utils/utils_oblig.R')

if(!require('caretEnsemble')) install.packages("caretEnsemble")
library(caretEnsemble)
library('gbm')
library('glmnet')
library('caret')
set.seed(117)

thr_vec <- seq(0.1, 0.9, 0.05)

fn_summary <- function(data, lev = NULL, model = NULL) {
  fn_summaryUtilityThr(data, thr_vec)
}

algoritmos <- c("glmnet", "ranger","rpart")

trainctr <- trainControl(method = 'cv',
                         number = 5,
                         verboseIter = TRUE,
                         classProbs = TRUE, 
                         search = 'grid', 
                         summaryFunction = fn_summary)

modelos <- caretList(Formula, data = train, trControl = trainctr, methodList = algoritmos)

stacking <- caretStack(modelos, method= 'glm', trControl = trainctr)

summary(stacking)

prediccion_stacking <- predict(stacking ,dev)

matriz_stacking <- confusionMatrix(as.factor(dev$Churn), prediccion_stacking)

matriz_stacking

Utility_stacking <- fn_utility(prediccion_stacking,dev$Churn)
Utility_stacking
