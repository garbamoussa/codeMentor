
#### R file for the Midterm
#Airbnb datasets


# ------------------------------------------------------------------------------------------------------
#### SET UP
# It is advised to start a new session for every case study
# CLEAR MEMORY
rm(list=ls())

# Install packages
install.packages("glmnet")
install.packages("foreign")
install.packages("xtable")
install.packages("tidyverse")

# Library packages
library(tidyverse)
library(caret)
library(glmnet)
library(stargazer)
library(foreign)
library(xtable)

# DIRECTORY SETTING (use your own path)
setwd("/Users/yzj0054/Dropbox/BUAL 5600/Midterm")

# DATA IMPORT
data <- read.dta("airbnb_mid.dta")

################################################################################
################################ Question 1 ####################################
################################################################################

#### Fit a multiple regression 

reg1 <- lm(price ~ n_accommodates + n_beds + n_review_scores_rating + n_number_of_reviews, data = data)
summary(reg1)

#### Distribution of Price

plot(density(data$price))


#### Log Transformation 

data$lnprice <- log(data$price)
reg2 <- lm(lnprice ~ n_accommodates + n_beds + n_review_scores_rating + n_number_of_reviews, data = data)
summary(reg2)

################################################################################
################################ Question 2 ####################################
################################################################################


# Basic Variables
basic_lev  <- c("n_accommodates", "n_beds", "n_review_scores_rating", "n_number_of_reviews", "n_days_since", "f_room_type")

# Factorized variables
basic_add <- c("f_bathroom","f_cancellation_policy","f_bed_type", "flag_days_since")

# Higher orders
poly_lev <- c("n_accommodates2", "n_days_since2", "n_days_since3")

# Dummy variables: Extras -> collect all options and create dummies
amenities <-  grep("^d_.*", names(data), value = TRUE)

# dummies suggested by graphs
X1  <- c("f_room_type*f_property_type",  "f_room_type*d_familykidfriendly")

# Additional interactions of factors and dummies
X2  <- c("d_airconditioning*f_property_type")
X3  <- c(paste0("(f_property_type + f_room_type + f_cancellation_policy + f_bed_type) * (",
                paste(amenities, collapse=" + "),")"))

# Create models in levels models: 1-8
model1 <- " ~ n_accommodates"
model2 <- paste0(" ~ ",paste(basic_lev,collapse = " + "))
model3 <- paste0(" ~ ",paste(c(basic_lev, basic_add),collapse = " + "))
model4 <- paste0(" ~ ",paste(c(basic_lev,basic_add,poly_lev),collapse = " + "))
model5 <- paste0(" ~ ",paste(c(basic_lev,basic_add,poly_lev,X1),collapse = " + "))
model6 <- paste0(" ~ ",paste(c(basic_lev,basic_add,poly_lev,X1,X2),collapse = " + "))
model7 <- paste0(" ~ ",paste(c(basic_lev,basic_add,poly_lev,X1,X2,amenities),collapse = " + "))
model8 <- paste0(" ~ ",paste(c(basic_lev,basic_add,poly_lev,X1,X2,amenities,X3),collapse = " + "))

#################################
# Separate hold-out set #
#################################

# create a holdout set (20% of observations)
smp_size <- floor(0.2 * nrow(data))

# Set the random number generator: It will make results reproducable
set.seed(20180123)

# create ids:
# 1) seq_len: generate regular sequences
# 2) sample: select random rows from a table
holdout_ids <- sample(seq_len(nrow(data)), size = smp_size)
data$holdout <- 0
data$holdout[holdout_ids] <- 1

#Hold-out set Set
data_holdout <- data %>% filter(holdout == 1)

#Working data set
data_work <- data %>% filter(holdout == 0)


######################################################
# Fit the eight regression models & cross validation #
######################################################

## N = 10
n_folds=10
# Create the folds
set.seed(20180124)

folds_i <- sample(rep(1:n_folds, length.out = nrow(data_work) ))
# Create results
model_results_cv <- list()


for (i in (1:8)){
  model_name <-  paste0("model",i)
  model_pretty_name <- paste0("(",i,")")
  
  yvar <- "price"
  xvars <- eval(parse(text = model_name))
  formula <- formula(paste0(yvar,xvars))
  
  # Initialize values
  rmse_train <- c()
  rmse_test <- c()
  
  model_work_data <- lm(formula,data = data_work)
  BIC <- BIC(model_work_data)
  nvars <- model_work_data$rank -1
  r2 <- summary(model_work_data)$r.squared
  
  # Do the k-fold estimation
  for (k in 1:n_folds) {
    test_i <- which(folds_i == k)
    # Train sample: all except test_i
    data_train <- data_work[-test_i, ]
    # Test sample
    data_test <- data_work[test_i, ]
    # Estimation and prediction
    model <- lm(formula,data = data_train)
    prediction_train <- predict(model, newdata = data_train)
    prediction_test <- predict(model, newdata = data_test)
    
    # Criteria evaluation
    rmse_train[k] <- sqrt(mean((data_train[,yvar] - prediction_train)^2))
    rmse_test[k] <- sqrt(mean((data_test[,yvar] - prediction_test)^2))
    
  }
  
  model_results_cv[[model_name]] <- list(yvar=yvar,xvars=xvars,formula=formula,model_work_data=model_work_data,
                                         rmse_train = rmse_train,rmse_validation = rmse_test,BIC = BIC,
                                         model_name = model_pretty_name, nvars = nvars, r2 = r2)
}

t1 <- imap(model_results_cv,  ~{
  as.data.frame(.x[c("rmse_validation", "rmse_train")]) %>%
    dplyr::summarise_all(.funs = mean) %>%
    mutate("model_name" = .y ,  "adj.r2" = .x[["r2"]], "BIC" = .x[["BIC"]])
}) %>%
  bind_rows()

table1 <- subset(t1, selec=c("model_name", "adj.r2", "BIC"))
table1

table2 <- subset(t1, selec=c("model_name", "rmse_train", "rmse_validation"))
table2 

#################################
#           Ridge               #
#################################
options(scipen = 999)

vars_model_8 <- c("price", basic_lev,basic_add,poly_lev,X1,X2,amenities,X3)

train_control <- trainControl(method = "cv", number = n_folds)

# Possible values of Lambda
tune_grid <- expand.grid("alpha" = c(0), "lambda" = seq(0.05, 1, by = 0.05))

# We use model 8 
formula <- formula(paste0("price ~ ", paste(setdiff(vars_model_8, "price"), collapse = " + ")))

set.seed(1234)
ridge_model <- caret::train(formula,
                            data = data_work,
                            method = "glmnet",
                            preProcess = c("center", "scale"),
                            trControl = train_control,
                            tuneGrid = tune_grid,
                            na.action=na.exclude)

print(ridge_model$bestTune$lambda) # optimal lambda

ridge_coeffs  <- coef(ridge_model$finalModel, ridge_model$bestTune$lambda) %>%
  as.matrix() %>%
  as.data.frame() %>%
  rownames_to_column(var = "variable") 
 # rename(coefficient = `1`)  # the column has a name "1", to be renamed

print(ridge_coeffs)

# Evaluate model. CV error:
ridge_cv_rmse <- ridge_model$results %>%
  filter(lambda == ridge_model$bestTune$lambda) %>%
  dplyr::select(RMSE)
print(ridge_cv_rmse[1, 1])


#################################
#           LASSO               #
#################################

# Set lasso tuning parameters
train_control <- trainControl(method = "cv", number = n_folds)
tune_grid <- expand.grid("alpha" = c(1), "lambda" = seq(0.05, 1, by = 0.05))

# We use model 8 
formula <- formula(paste0("price ~ ", paste(setdiff(vars_model_8, "price"), collapse = " + ")))

set.seed(1234)
lasso_model <- caret::train(formula,
                            data = data_work,
                            method = "glmnet",
                            preProcess = c("center", "scale"),
                            trControl = train_control,
                            tuneGrid = tune_grid,
                            na.action=na.exclude)

print(lasso_model$bestTune$lambda)

lasso_coeffs <- coef(lasso_model$finalModel, lasso_model$bestTune$lambda) %>%
  as.matrix() %>%
  as.data.frame() %>%
  rownames_to_column(var = "variable") 
 # rename(coefficient = `1`)  # the column has a name "1", to be renamed

print(lasso_coeffs)

# Evaluate model. CV error:
lasso_cv_rmse <- lasso_model$results %>%
  filter(lambda == lasso_model$bestTune$lambda) %>%
  dplyr::select(RMSE)
print(lasso_cv_rmse[1, 1])

# number of coefficients that are not zero 
lasso_coeffs_nz<-lasso_coeffs %>%
  filter(s1!=0)
print(nrow(lasso_coeffs_nz))

###################################################
# Diagnostics #
###################################################

# RMSE for Ridge (holdout set)
pred.ridge <- predict(ridge_model, newdata = data_holdout)
rmse_ridge <- sqrt(mean((data_holdout[,yvar] - pred.ridge)^2))

# RMSE for Lasso (holdout set)
pred.lasso <- predict(lasso_model, newdata = data_holdout)
rmse_lasso <- sqrt(mean((data_holdout[,yvar] - pred.lasso)^2))

rmse_ridge
rmse_lasso
