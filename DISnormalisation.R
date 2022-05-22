library('SciViews')
library('tidyverse')


df <- read.csv("poe.csv", header = FALSE)



#remove unnecessary rows
df <- df[-c(1,2), ]

#renaming columns
colnames(df) <- c("mag", "dist", "poe")

df <- df[ -c(4:8) ]

#calculations

rates_of_exceedance <- function(x){
  #converting columns to numeric
  x$poe = as.numeric(x$poe)
  x$mag = as.numeric(x$mag)
  x$dist = as.numeric(x$dist)
  #creating the roe column
  x <- x %>% mutate(roe = (-1/50) * log(1 - (x$poe)))
  #creating contribution & normalised poe column
  return  (x %>% mutate(normalised_poe = roe/mean(roe), contribution = roe /mean(roe) *100))
}




final_answer <- rates_of_exceedance(df)

final_answer


