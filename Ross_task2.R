library(readr)
library(dplyr)
library(tidyverse)
library(tidyr)
library(data.table)
library(ggplot2)
library(scales)
library(ggtext)
library(readxl)

setwd("C:/Users/vibsi/Desktop/2020/Other/Ross Mike/Task 2")
files <- list.files(pattern = "*csv", full.names = T)

#read in CSV one by one and bind them together

tbl <- sapply(files, read.csv, simplify=FALSE) %>%
  bind_rows(.id = "id")

#removing unwanted columns
df <- tbl[-c(2:3, 451:496)]

#tranpose data
t_df <- data.table::transpose(df)

t_df2 <- t_df %>% 
  select(V1,V2)

myplot <- function(t_df2) {
  df <- tibble(x=rep(NA,56),
               `2.7% in 50y`=rep(NA,56),
               `5% in 50y`=rep(NA,56),
               `9.5% in 50y`=rep(NA,56),
               `86.5% in 50y`=rep(NA,56),
               `10% in 50y`=rep(NA,56),
               `2% in 50y`=rep(NA,56),
               `0.5% in 50y`=rep(NA,56),
               `0.2% in 50y`=rep(NA,56))
  
  df$`Period (T)` <- c(0,seq(0.02,0.09,0.01),seq(0.1,4,0.1),4.5,seq(5,9,1),9.9)
  df$`2.7% in 50y` <- as.numeric(t_df2$V2[2:57])
  df$`5% in 50y` <- as.numeric(t_df2$V2[58:113])
  df$`9.5% in 50y` <- as.numeric(t_df2$V2[114:169])
  df$`86.5% in 50y` <- as.numeric(t_df2$V2[170:225])
  df$`10% in 50y` <- as.numeric(t_df2$V2[226:281])
  df$`2% in 50y` <- as.numeric(t_df2$V2[282:337])
  df$`0.5% in 50y` <- as.numeric(t_df2$V2[338:393])
  df$`0.2% in 50y` <- as.numeric(t_df2$V2[394:449])
  
  #creating plot  
  df %>% 
    ggplot(aes(x=`Period (T)`))+
    geom_line(aes(y=`2.7% in 50y`,col="2.7% in 50y"))+
    geom_point(aes(y=`2.7% in 50y`),col="yellow")+
    geom_line(aes(y=`5% in 50y`,col="5% in 50y"))+
    geom_point(aes(y=`5% in 50y`),col="blue")+
    geom_line(aes(y=`9.5% in 50y`,col="9.5% in 50y"))+
    geom_point(aes(y=`9.5% in 50y`),col="red")+
    geom_line(aes(y=`86.5% in 50y`,col="86.5% in 50y"))+
    geom_point(aes(y=`86.5% in 50y`),col="green")+
    geom_line(aes(y=`10% in 50y`,col="10% in 50y"))+
    geom_point(aes(y=`10% in 50y`),col="black")+
    geom_line(aes(y=`2% in 50y`,col="2% in 50y"))+
    geom_point(aes(y=`2% in 50y`),col="brown")+
    geom_line(aes(y=`2% in 50y`,col="2% in 50y"))+
    geom_point(aes(y=`2% in 50y`),col="orange")+
    geom_line(aes(y=`0.5% in 50y`,col="0.5% in 50y"))+
    geom_point(aes(y=`0.5% in 50y`),col="grey")+
    geom_line(aes(y=`0.2% in 50y`,col="0.2% in 50y"))+
    geom_point(aes(y=`0.2% in 50y`),col="purple")+
    scale_x_continuous(breaks=c(0.1,1,10))+
    # scale_y_continuous(breaks=c(0.1,1,10),
    #                    labels = c(0.1,1,10))+
    labs(x="Period T(s)",
         y="SA(T) (g)",
         title="WCL Uniform hazard spectra",
         color="")+
    theme_light()+
    scale_color_manual(values=c("yellow", "blue","red","green","black","brown",
                                "orange","grey"))  +
    coord_cartesian(ylim=c(0.01,10))+
    theme(legend.position = "bottom")
  
  
}

myplot(t_df2)

    
    
    
    
    
  


