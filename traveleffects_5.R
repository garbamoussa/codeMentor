# traveleffects_5
# Code started by Quin, through 16 March 2022
# Updated by KLC, 17 March 2022
# Updated by Quin, 17-18 March 2022
# Updated by KLC, 22 March 2022 (following notes from B in Slack)
# Updated by QS, 23 through ... tbd


#Loiter flags round 4..
#step 1. for each site categorize loiter period (120s flagged 'l') and movement (60s pre-loiter and post loiter, 120seconds total)
#step 2. Summarize mean value for parameter (ie. 'pH', 'chlorophyll_a_RFU', 'specificConductance_uscm', 'oxygenDissolved_mgl' ) at each site during movement and loiter period
#step 3. Calculate difference between mean Loiter and mean Movement for each site (e. delta pH)
#step 4. Plot these values by deployment date (ie. Delta pH on y axis, deployment date on x axis)
#step 5 *BONUS* run a one-sample t-test... still figuring this one out..

# clear the memory
rm(list=ls())
gc()

setwd("/Users/garbamoussa/Downloads/China Lake deployment data/")
# define the pre-set loiter time (in seconds) that will be used to set up the pre-post loiter periods
# used in the function calls to "travel_effects_2"
preset_loiter_time <- 60


#Libraries needed
library(lubridate)
library(tidyverse)
library(ggpubr)

#China Lake data - 6 total deployments
chn.13jul21 <- read.csv(file = "CHN_2021-07-13_a_asv_processed_v2022-03-23.csv", header=T)
chn.6Aug21 <- read.csv(file = "CHN_2021-08-06_a_asv_processed_v2022-03-23.csv", header=T)
chn.28sep21 <- read.csv(file = "CHN_2021-09-28_a_asv_processed_v2022-03-23.csv", header=T)
chn.5oct21 <- read.csv(file = "CHN_2021-10-05_a_asv_processed_v2022-03-23.csv", header=T)
chn.12oct21 <- read.csv(file = "CHN_2021-10-12_a_asv_processed_v2022-03-23.csv", header=T)
chn.21oct21 <- read.csv(file = "CHN_2021-10-21_a_asv_processed_v2022-03-23.csv", header=T)

#Sabattus Data - 2 deployments
sab.26aug21 <- read.csv(file = "SAB_2021-08-26_a_asv_processed_v2022-03-23.csv", header=T)
sab.20aug21 <- read.csv(file ="SAB_2021-08-20_a_asv_processed_v2022-03-23.csv", header=T)

#Auburn data - 1 deployments
aub.30aug21 <- read.csv(file="AUB_2021-08-30_a_asv_processed_v2022-03-23.csv", header=T)

#Sunapee data - 9 deployments
sun.11jun21HC <- read.csv(file="SUN_2021-06-11_HC_asv_processed_v2022-03-23.csv", header=T)
sun.11jun21NW <- read.csv(file="SUN_2021-06-11_NW_asv_processed_v2022-03-23.csv", header=T)

#sun.11jun21 = combine(sun.11jun21HC, sun.11jun21NW) #QS - thought these could be combined beforehand but ran into an error later on... the 'combine' lines can be commented out

sun.15jun21HC <- read.csv(file="SUN_2021-06-15_HC_asv_processed_v2022-03-23.csv", header=T)
sun.15jun21NW <- read.csv(file="SUN_2021-06-15_NW_asv_processed_v2022-03-23.csv", header=T)

#sun.15jun21 = combine(sun.15jun21HC, sun.15jun21NW)

sun.21jun21HC <- read.csv(file="SUN_2021-06-21_HC_asv_processed_v2022-03-23.csv", header=T)
sun.21jun21NW <- read.csv(file="SUN_2021-06-21_NW_asv_processed_v2022-03-23.csv", header=T)

#sun.21jun21 = combine(sun.21jun21HC, sun.21jun21NW)

sun.01jul21 <- read.csv(file="SUN_2021-07-01_HC_asv_processed_v2022-03-23.csv", header=T) #only herrick cove

sun.22jul21 <- read.csv(file="SUN_2021-07-22_asv_processed_v2022-03-23.csv", header=T)

sun.05aug21HC <- read.csv(file="SUN_2021-08-05_HC_asv_processed_v2022-03-23.csv", header=T)
sun.05aug21NW <- read.csv(file="SUN_2021-08-05_NW_asv_processed_v2022-03-23.csv", header=T)

#sun.05aug21 = combine(sun.05aug21HC, sun.05aug21NW)

sun.10aug21HC <- read.csv(file="SUN_2021-08-10_HC_asv_processed_v2022-03-23.csv", header=T)
sun.10aug21NW <- read.csv(file="SUN_2021-08-10_NW_asv_processed_v2022-03-23.csv", header=T)

#sun.10aug21 = combine(sun.10aug21HC, sun.10aug21NW)

sun.27aug21HC <- read.csv(file="SUN_2021-08-27_HC_asv_processed_v2022-03-23.csv", header=T)
sun.27aug21NW <- read.csv(file="SUN_2021-08-27_NW_asv_processed_v2022-03-23.csv", header=T)

#sun.27aug21 = combine(sun.27aug21HC, sun.27aug21NW)

sun.16sep21HC <- read.csv(file="SUN_2021-09-16_HC_asv_processed_v2022-03-23.csv", header=T)
sun.16sep21NW <- read.csv(file="SUN_2021-09-16_NW_asv_processed_v2022-03-23.csv", header=T)

#sun.16sep21 = combine(sun.16sep21HC, sun.16sep21NW)

#Function created by B modified from Emily's attempts, the two lines directly below set the working directory to the project folder in dartfs
#dir = '/Volumes/EpscorBlooms/project_data/ASV_data/analysis_ready/'
#df = read.csv(file.path(dir, 'AUB/AUB_2021-08-30_a_asv_processed_v2022-01-24.csv'))

#start here Quin...

# define a function to calculate the travel effects
# input parameters are a dataframe (df) and a number of seconds to consider (n_sec)
travel_effects_2 <- function(df, n_sec){
  
  # get a list of the loiter waypoints (wp) by HEADER SEQUENCE, waypoint_seq repeats sometimes, and we want each of these to be unique
  wp_loiter = unique(df$header_seq[df$wp_command ==19 & !is.na(df$wp_command)])   
  
  # loop over way points
  # here 'i' is an iteration along 1 to the length of the value 'wp_loiter'; i therefore refers to the position 1:n of the list 'wp_loiter'
  for (i in 1:length(wp_loiter)){  
    
    #let's grab the time stamp for the loiter end using the wp_loiter list
    #here, wp_loiter[i] is grabbing the i'th position in the wp_loiter list.
    loiter_end = df$timestamp_gps_sec[which(df$header_seq == wp_loiter[i])]   
    
    #calculate loiter start from the wp param (seconds of loiter) associated with the loiter
    loiter_start = loiter_end - df$wp_param1[which(df$header_seq == wp_loiter[i])]
    
    # determine the start and end of the pre and post loiter periods 
    # uses the number of seconds away from the start or end of the loiter controlled by the user as sent into this function
    preloit_start = loiter_start - n_sec
    postloit_end = loiter_end + n_sec
    
    # should we set a flag to denote situations in which there is insufficient time available between way points to have them be distinct?
    
    #make a data frame that only includes the info we're interested in for this way point
    df_test <- df %>% 
      # keep only those timestamps from the preloiter start through the post loiter end
      # note: KC doesn't understand why the end isn't <= to match the symmetry... but that can be explained later?
      filter(timestamp_gps_sec >= preloit_start & timestamp_gps_sec < postloit_end)
    
    #calculate and label pre/post/during loiters
    df_test <- df_test %>% 
      mutate(loiter_tag = case_when(timestamp_gps_sec < loiter_start ~ 'pre-loiter',
                                    timestamp_gps_sec >= loiter_start & timestamp_gps_sec <= loiter_end ~ 'loiter',
                                    timestamp_gps_sec > loiter_end ~ 'post-loiter',
                                    TRUE ~ NA_character_))
    
    #apply the loiter id column using the current wp identifier (i) (changed 22-Mar-22 in response to B suggestion)
    df_test$loiter_num = i
    df_test$loiterID = paste(df_test$loiter_tag, df_test$loiter_num, sep = '_')
    
    # if the first time through iteration, save test as df; otherwise append!
    # KC notes: an alternative way to do this would be to define loiter_df as null before entering the loop
    if (i == 1) {
      loiter_df = df_test
    } else {
      loiter_df = full_join(loiter_df, df_test)
    }
  }
  return(loiter_df)
}


#running function across deployment dates for China Lake, with a 60-second pre- and post-loiter period
# (save new data frames that don't include the year as part of the name)
#removed chn.jul.13 because it was a test run 

chn.aug_6 <- travel_effects_2(chn.6Aug21,60)
chn.sep_28 <- travel_effects_2(chn.28sep21,60) #sites are wonky here... missing 1 - 3
chn.oct_5 <- travel_effects_2(chn.5oct21,60)
chn.oct_12 <- travel_effects_2(chn.12oct21,60)
chn.oct_21 <- travel_effects_2(chn.21oct21,60)


#Run function for sab
sab.aug_26 <- travel_effects_2(sab.26aug21,60)
sab.aug_20 <- travel_effects_2(sab.20aug21,60)

#run function for Auburn
aub.aug_30 <- travel_effects_2(aub.30aug21,60)

#run function for Sunapee
#sun.jun_11 <- travel_effects_2(sun.11jun21,60)
#sun.jun_15 <- travel_effects_2(sun.15jun21,60)
#sun.jun_21 <- travel_effects_2(sun.21jun21,60)
#sun.jul_01 <- travel_effects_2(sun.01jul21,60) #only herrick cove
#sun.jul_22 <- travel_effects_2(sun.22jul21,60)
#sun.aug_05 <- travel_effects_2(sun.05aug21,60)
#sun.aug_10 <- travel_effects_2(sun.10aug21,60)
#sun.aug_27 <- travel_effects_2(sun.27aug21,60)
#sun.sep_16 <- travel_effects_2(sun.16sep21,60)

sun.jun_11HC <- travel_effects_2(sun.11jun21HC,60)
sun.jun_11NW <- travel_effects_2(sun.11jun21NW,60)
sun.jun_15HC <- travel_effects_2(sun.15jun21HC,60)
sun.jun_15NW <- travel_effects_2(sun.15jun21NW,60)
sun.jun_21HC <- travel_effects_2(sun.21jun21HC,60)
sun.jun_21NW <- travel_effects_2(sun.21jun21NW,60)
sun.jul_01 <- travel_effects_2(sun.01jul21,60) #only herrick cove
sun.jul_22 <- travel_effects_2(sun.22jul21,60)
sun.aug_05HC <- travel_effects_2(sun.05aug21HC,60)
sun.aug_05NW <- travel_effects_2(sun.05aug21NW,60)
sun.aug_10HC <- travel_effects_2(sun.10aug21HC,60)
sun.aug_10NW <- travel_effects_2(sun.10aug21NW,60)
sun.aug_27HC <- travel_effects_2(sun.27aug21HC,60)
sun.aug_27NW <- travel_effects_2(sun.27aug21NW,60)
sun.sep_16HC <- travel_effects_2(sun.16sep21HC,60)
sun.sep_16NW <- travel_effects_2(sun.16sep21NW,60)

#combining transformed data from deployments
# note that this is throwing a warning error because "combine" isn't a supported command going forwards
# it's asking for vctrs::vec_v() instead 

#df <- combine(chn.aug_6,chn.sep_28,chn.oct_5,chn.oct_12,chn.oct_21)

#df <- combine(sab.aug_26, sab.aug_20)

#df <- combine(aub.aug_30)

#df <- combine(sun.jun_11, sun.jun_15, sun.jun_21, sun.jul_01, sun.jul_22, sun.aug_05, sun.aug_10, sun.aug_27, sun.sep_16)

#QS - temperorarily omitting sun.aug_27HC, sun.jul_22, and sun.jun_11HC --> there should be 70 variables and these three have between 71 - 74 and are causing errors...
#df <- combine(sun.jun_11NW, sun.jun_15HC, sun.jun_15NW, sun.jun_21HC, sun.jun_21NW, sun.jul_01, sun.aug_05HC, sun.aug_05NW, sun.aug_10HC, sun.aug_10NW, sun.aug_27NW, sun.sep_16HC, sun.sep_16NW)



#COLUMNS TO KEEP IN NEW DATA FRAME WHEN COMBINING - lake, date, timestamp_gps_sec, loiter_tag, loiterID, loiter_num, velocity_gps_mps, temperatureWater_degC, pH, chlorophyll_a_RFU, specificConductance_uscm, oxygenDissolved_mgl, turbidity_NTU

#FOR SUNAPEE - combine deployment_instance



# On Quin's computer, "combine" appears to add a new column "source" as a label for the source of the dataset
# however, that isn't working properly on KC's computer
# I'm going to define "source" as an as.factor(date) and see what happens....
df$source <- as.factor(df$date)

# added 22 March 2022
# Filter the data to ask questions about differences between traveling and loitering
# B suggests mitigating movement at the end of a loiter and non-movement prior to loiters
#   perhaps by dropping any observation pre/post loiter where GPS speed is less than some threshold
#   and any observation during loiter where GPS speed is greater than some threshold
# Emily suggested that true movement was >=0.9 m/s, and that loiters should be <0.5 m/s
#   the 0.9 m/s might end up being too stringent, but we can try it for now.
during_loiter_speed_threshold <- 0.5 # how fast the robot can be going in a loiter period
during_mvmt_speed_threshold <- 0.9 # how slow the robot can be going in a movement period

df_trim <- df %>%
  # keep only those rows rows which are during a movement period but gps speed is greater than the threshold
  # OR are during a loiter period & gps speed is below the too fast threshold
  filter(((loiter_tag=="pre-loiter" | loiter_tag=="post-loiter") & velocity_gps_mps > during_mvmt_speed_threshold) |
          (loiter_tag=="loiter" & velocity_gps_mps < during_mvmt_speed_threshold)) 
  # select just the columns of interest to check on the coding/output
  #select(lake, year, date, timestamp_gps_sec, loiter_tag, loiterID, velocity_gps_mps)
    

#Grouping pre/post to be just movement by site ID
df1 <-  df_trim %>%
  mutate(movement=case_when(str_detect(loiterID,"pre-loiter|post-loiter")~paste0("movement_",loiter_num),
                            TRUE~loiterID))
#  select(loiterID,loiter_tag,loiter_flag,movement)%>% View()

# Pull out the site id as a separate column in a "data frame to functions"
df_to_fxns <- df1 %>% separate(movement,c("type","siteid"),"_") %>% mutate(siteid=parse_number(siteid))

# --------------------------------------------------------
# function to create the data frames for t-tests & plotting of the central tendency for the difference between travel & loiter
# calculates both the mean & median difference 
# df_in = input data frame, name = name of the response variable
# --------------------------------------------------------

center.bydate <- function(df_in,name) {
  
  # (1) calculate the mean travel/loiter at a site on a date, then get the difference between them
  # df_int = intermediate data frame
  df_int <- df_in %>% 
    # group by sample date/source, site ID, and type of movement (loiter/travel) 
    group_by(source, siteid, type) %>% 
    # get the mean & then ungroup
    summarise(mean.x= mean(!!name)) %>% ungroup()

  # now, create a new data frame that makes separate columns for each type
  # (note: need to reprogram this with meaningful names for id_cols)
  df_int_mean <- df_int %>% 
    pivot_wider(id_cols=c("source","siteid"),names_from = type, values_from = mean.x) %>%
    # calculate the difference between loitering and moving at each site
    mutate(mean.loiter=loiter,
           mean.movement=movement,
           mean.diff=loiter-movement,
           mean.pctdiff=mean.diff/loiter) %>%
    select(source, siteid, mean.loiter, mean.movement, mean.diff, mean.pctdiff)

  # (2) calculate the median travel/loiter at a site on a date, then get the difference between them
  # df_int = intermediate data frame
  df_int <- df_in %>% 
    # group by sample date/source, site ID, and type of movement (loiter/travel) 
    group_by(source, siteid, type) %>% 
    # get the mean & then ungroup
    summarise(median.x= median(!!name)) %>% ungroup()
  
  # now, create a new data frame that makes separate columns for each type
  df_int_median <- df_int %>% 
    pivot_wider(id_cols=c("source","siteid"),names_from = type, values_from = median.x) %>%
    # calculate the difference between loitering and moving at each site
        mutate(median.loiter=loiter,
           median.movement=movement,
           median.diff=loiter-movement,
           median.pctdiff=median.diff/loiter) %>%
    select(source, siteid, median.loiter, median.movement, median.diff, median.pctdiff)
  
    # (3) combine the means & medians
  df_int_both=full_join(df_int_mean, df_int_median, by=c("source","siteid"))
  
  # return the updated matrix
  center.bydate <- df_int_both

} # end function


# --------------------------------------------------------
# Function to conduct t-tests on the mean & the median difference between travel & loiter
# calculate the t-tests for each sample date, for a stated response variable of interest
# the t-test here needs to loop over the dates and compare the "type" (loiter vs. travel) as a two-sided one-sample t
# df_in = input data frame, name = name of the response variable; test.mean.bydate = name of the function
# some of the coding in here is adapted from work by Ian McGrory during Winter 2021
# --------------------------------------------------------

test.bydate <- function(df_in) {

  #pull out the list of possible dates to be stepped through (and number of them)
  datelist <- unique(df_in$source)
  
  # get the number of rows/dates to be analyzed
  ndates <- as.numeric(length(datelist))
  
  # create a matrix to store the t-test output
  test_output <- data.frame(matrix(ncol=11, nrow=ndates))
  #name the columns for each coefficient we will store
  x <- c("Date", "mean_t.Statistic", "mean_DF", "mean_P.Value", "mean_CI.Low", "mean_CI.High",
         "median_t.Statistic", "median_DF", "median_P.Value", "median_CI.Low", "median_CI.High")
  colnames(test_output) <- x
  
  # loop over the dates
  for (i in seq_along(datelist)){
    
    # get the date & create a subset of the dataset for this date
    thisdate <- datelist[i]
    thisdate_sub <- df_in[df_in$source == datelist[i],] 
    
    # calculate the t-test for the mean for this date, two-sided against the mean=0
    tout_mean <- t.test(thisdate_sub$mean.diff, alternative="two.sided", mu=0, conf.level=0.95)
   
    # calculate the t-test for the median for this date, two-sided against the mean=0
    tout_median <- t.test(thisdate_sub$median.diff, alternative="two.sided", mu=0, conf.level=0.95)
    
    # save the relevant output to the matrix
    test_output[i,] <- cbind(as.character(thisdate), tout_mean$statistic, tout_mean$parameter, tout_mean$p.value, tout_mean$conf.int[1], tout_mean$conf.int[2],
                             tout_median$statistic, tout_median$parameter, tout_median$p.value, tout_median$conf.int[1], tout_median$conf.int[2])

  } # end the for-do-loop for dates

  view(test_output)
  
  test.bydate=test_output
  
} # end the function


#-------------------------------------------------------------------
# Functions to make plots : one by mean and one by median 
#create function for plotting parameters - change "lake name" to match 
# note there were changes by KLC for this to make things run on her computer 3/17/2022 --> QS kept changes for consistency
# this will do both the mean & the median, as the calculation happens upstream of calling this function...

##major issue for sunapee upstream - sites are not all being included
#-------------------------------------------------------------------

# WANT TO ADD: Overlays of the mean & of the median amongst the data points
# WANT TO ADD: CIs from the t-test output around those lines
# WANT TO ADD: A firm line at 0 to show where no effect would be.

plot_param <- function(df4,name) {
  
  df4 <- df4 %>%
    # treat the source column as a date :-)
    mutate(plotdate=as.Date.factor(source)) 

    # make the plot for the means
    meanplot <- ggplot(data=df4, aes(x=plotdate,y=mean.diff))+
      geom_point()+
      theme_light()+
      labs(title=paste("Lake Sunapee",str_replace(deparse(substitute(name)),"quo","")),
          x="Date",
          y="Mean Loiter-Movement",str_replace(deparse(substitute(name)),"quo",""))

    # make the plot for the medians
    medianplot <- ggplot(data=df4, aes(x=plotdate,y=median.diff))+
      geom_point()+
      theme_light()+
      labs(x="Date",
           y="Median Loiter-Movement",str_replace(deparse(substitute(name)),"quo",""))
    
    # combine them
    ggarrange(meanplot, medianplot, nrow=2, ncol=1)
    
    }

# -----------------------------
# Call the functions
# -----------------------------

# test the creation of the data frame with the information for t-tests and plotting
df_for_analysis <- center.bydate(df_to_fxns,quo(chlorophyll_a_RFU))
plot_param(df_for_analysis,quo(chlorophyll_a_RFU))
#test t test function... note that I _do not_ have the variable name as part of this b/c I don't understand the "quo" parts
ttests_chl <- test.bydate(df_for_analysis)

#code for brute forcing all variables

df_for_analysis <- center.bydate(df_to_fxns,quo(chlorophyll_a_RFU))
ttests_chl <- test.bydate(df_for_analysis)
plot_param(df_for_analysis,quo(chlorophyll_a_RFU))

df_for_analysis <- center.bydate(df_to_fxns,quo(pH))
ttests_pH <- test.bydate(df_for_analysis)
plot_param(df_for_analysis,quo(pH))

df_for_analysis <- center.bydate(df_to_fxns,quo(specificConductance_uscm))
ttests_specond <- test.bydate(df_for_analysis)
plot_param(df_for_analysis,quo(specificConductance_uscm))

df_for_analysis <- center.bydate(df_to_fxns,quo(oxygenDissolved_mgl))
ttests_DO <- test.bydate(df_for_analysis)
plot_param(df_for_analysis,quo(oxygenDissolved_mgl))

df_for_analysis <- center.bydate(df_to_fxns,quo(turbidity_NTU))
ttests_turb <- test.bydate(df_for_analysis)
plot_param(df_for_analysis,quo(turbidity_NTU))

df_for_analysis <- center.bydate(df_to_fxns,quo(temperatureWater_degC))
ttests_temp <- test.bydate(df_for_analysis)
plot_param(df_for_analysis,quo(temperatureWater_degC))





# next, need to create the code that will loop over the various response variables of interest
RV <- c("temperatureWater_degC", "pH", "chlorophyll_a_RFU", "specificConductance_uscm", "oxygenDissolved_mgl",
        "turbidity_NTU")

# loop over the columns, save the t-test output into a combined matrix, save the figures

# need to learn how to pull from here and the quo and !! macros

