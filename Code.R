#Removed 3 indistries, and updated age to get 963 observations, 107 firms.

library(tidyverse)
library(plm)
library(DescTools) # for comprehensive summary()
library(gplots)    # for plotmeans etc
library(sandwich)
library(lmtest)
library(sjPlot)    # for tab_model()
library(broom)
library(ggstatsplot)   # fancy boxplots aka violin plots
library(readr)

# set working directory
setwd("D:/UOL/Year 4/Semester 2/Dissertation/R_Data")

Updated_Age_Data <- read_csv("Updated_Age_Data.csv", 
                                               col_types = cols(Year = col_date(format = "%Y")))
View(Updated_Age_Data)                                                                  
Updated_Age_Data <-Updated_Age_Data
Updated_Age_Data %>% View()
Updated_Age_Data %>% head()

#Set data as panel data
pdata <-pdata.frame(Updated_Age_Data, index=c("Firm_ID","Year"))
pdata %>% head()

#Dummy Variable Region+Industry for ROE
dummyvar = lm(ROE~ESG+Leverage+Age+Size+factor(Industry)+factor(Region), data=Updated_Age_Data)
summary(dummyvar)

#Dummy Variable Region+Industry for ROA
dummyvarroa = lm(ROA~ESG+Leverage+Age+Size+factor(Industry)+factor(Region), data=Updated_Age_Data)
summary(dummyvarroa)

#Random effects model for Tobin_Q Fixed Year+Firm ID
random1 <-plm(Tobin_Q~ESG+Leverage+Age+Size+Region,index=c("Firm_ID","Year"), model="random", data=Updated_Age_Data)
summary(random1)

#Random effects model for Tobin_Q (Correct one?)
random2 <-plm(Tobin_Q~ESG+Leverage+Age+Size+factor(Industry)+factor(Region),data=Updated_Age_Data, model="random")
summary(random2)


