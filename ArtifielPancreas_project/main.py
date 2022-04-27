import numpy as np
import pandas as pd
from datetime import datetime as dt



"""
In this method we collect the CGM and insulin data, we extract the Date time Sensor glucose columns from the CGM data then  
we delete the na value .We convert the date and time then we separate the data into manual and automatic data 
 The function returns manual and automatic data (CASE A :Manual mode) & (CASE B:Auto mode)
"""
def  Processing_data(file_CGM ,file_insuline):
    #we get the CGM and insuline data

    CGM = pd.read_csv('CGMData.csv')
    Insulin = pd.read_csv('InsulinData.csv')

    #extract column date tiime and sensor
    CGM_Data = pd.DataFrame(CGM, columns=['Date','Time','Sensor Glucose (mg/dL)'])

    Insulin_Data = pd.DataFrame(Insulin, columns=['Date','Time','Alarm'])


    ## convert to date
    CGM_Data['Date']=pd.to_datetime(CGM_Data['Date']).dt.date

    Insulin_Data['Date']=pd.to_datetime(Insulin_Data['Date']).dt.date


    # Convert to time
    CGM_Data['Time']=pd.to_datetime(CGM_Data['Time']).dt.time

    Insulin_Data['Time']=pd.to_datetime(Insulin_Data['Time']).dt.time



    CGM_Data['Sensor Glucose (mg/dL)'] = pd.to_numeric(CGM_Data['Sensor Glucose (mg/dL)'])



    Manual_Automode=Insulin_Data.loc[Insulin_Data['Alarm']=='AUTO MODE ACTIVE PLGM OFF']



    startdate_auto=Manual_Automode.iloc[1,0]

    starttime_auto=Manual_Automode.iloc[1,1]




    Manual_Mode_CGM=CGM_Data.loc[(CGM_Data['Date']<startdate_auto) | ((CGM_Data['Date']==startdate_auto) & (CGM_Data['Time']<starttime_auto) )]

    Manual_Mode_CGM=Manual_Mode_CGM.dropna()



    Auto_Mode_CGM=CGM_Data.loc[(CGM_Data['Date']>startdate_auto) | ((CGM_Data['Date']==startdate_auto) & (CGM_Data['Time']>=starttime_auto) )]

    Auto_Mode_CGM=Auto_Mode_CGM.dropna()

    return  Manual_Mode_CGM,Auto_Mode_CGM


def get_mean_value(subset_data, typeVal = -1, lessthan = 1, greaterthan = 1):
    """
    this function allows to calculate the average value of each metric. It takes as parameters three arguments
    :param subset_data: the data to be extracted
    :param typeVal: this parameter allows to know the type of value to extract ( > or > or > <) 1< 2> 3 ><>
    :param lessthan:   quantity inf
    :param greaterthan: max quantity
    :return: the average of the calculated metric
     Percentage time in hyperglycemia (CGM > 180 mg/dL) ----->typeval =2
     percentage of time in hyperglycemia critical (CGM > 250 mg/dL)----->typeval =2
    c) percentage time in range (CGM >= 70 mg/dL and CGM <= 180 mg/dL)-------> typeval =3
    d) percentage time in range secondary (CGM >= 70 mg/dL and CGM <= 150 n ------->typeval =3
    e) percentage time in hypoglycemia level 1 (CGM < 70 mg/dL), ------->and typeval =1
    f) percentage time in hypoglycemia level 2 (CGM <54 mg/dL) --------------> typeval =1
    """

    if (typeVal == 1):
        val_c=subset_data.loc[subset_data.iloc[:,2]<lessthan]
        #print(val_c)

    if (typeVal == 2):
        val_c=subset_data.loc[subset_data.iloc[:,2]>greaterthan]

       # print(val_c)


    if (typeVal == 3):
        val_c=subset_data.loc[(subset_data.iloc[:,2]>=greaterthan) & (subset_data.iloc[:,2]<=lessthan)]
      #  print(val_c)
    """
      Grouping by date since we extract these measurements for each day
     and then report the average value of each measurement over all days
    """
    cgm_date=subset_data.groupby('Date')
    #print(cgm_date)

    c=val_c.groupby('Date').size().reset_index()
    #print(c)
    """
     we index by date

    """
    c=c.set_index('Date')

    #print(p)
    c.columns=['Value']
    p=c['Value']/288
    """
        we convert it into a dataframe 

    """
    p=p.to_frame()
   # print(p)

    """
     multiply each element of the column by 100
    """
    p['Value']=p['Value']*100

    """
    finally we calculate the average
    
    """
    avg_val=(p['Value'].sum())/len(cgm_date)
   # print(avg_val)
    return avg_val

print("start saving result.csv file ")
"""
    We will extract the metrics in two ways: manual mode and automatic mode 

"""

"""

    then we start by collecting the two types of data (manual mode and automatic mode)


"""

Manual_Mode_CGM,Auto_Mode_CGM  = Processing_data('CGMData.csv','InsulinData.csv')

"""
We extract the metric according to the manual mode
"""
Manual_Mode_CGM_fullDay180 =get_mean_value(Manual_Mode_CGM, 2, 0, 180)

Manual_Mode_CGM_fullDay250 =get_mean_value(Manual_Mode_CGM, 2, 0, 250)

Manual_Mode_CGM_fullDay70_180 =get_mean_value(Manual_Mode_CGM, 3, 180, 70)

Manual_Mode_CGM_fullDay70_150 =get_mean_value(Manual_Mode_CGM, 3, 150, 70)

Manual_Mode_CGM_fullDay70 =get_mean_value(Manual_Mode_CGM, 1, 70, 0)

Manual_Mode_CGM_fullDay54 =get_mean_value(Manual_Mode_CGM, 1, 54, 0)

"""
The metric is extracted in the automatic mode
"""

Auto_Mode_CGM_fullDay180 =get_mean_value(Auto_Mode_CGM, 2, 0, 180)

Auto_Mode_CGM_fullDay250 =get_mean_value(Auto_Mode_CGM, 2, 0, 250)

Auto_Mode_CGM_fullDay70_180 =get_mean_value(Auto_Mode_CGM, 3, 180, 70)

Auto_Mode_CGM_fullDay70_150 =get_mean_value(Auto_Mode_CGM, 3, 150, 70)

Auto_Mode_CGM_fullDay70 =get_mean_value(Auto_Mode_CGM, 1, 70, 0)

Auto_Mode_CGM_fullDay54 =get_mean_value(Auto_Mode_CGM, 1, 54, 0)

"""
6 to midnight   
we start by recovering the interval 6 am to midnight
"""

start=dt.strptime('06:00:00','%H:%M:%S').time()

end=dt.strptime('23:59:00','%H:%M:%S').time()

"""
we extract the daily data for the manual case

"""
Manual_Mode_daytime_CGM=Manual_Mode_CGM.loc[(Manual_Mode_CGM['Time']>=start) & (Manual_Mode_CGM['Time']<=end)]

Manual_Mode_daytime_CGM_180 =get_mean_value(Manual_Mode_daytime_CGM, 2, 0, 180)

Manual_Mode_daytime_CGM_250 =get_mean_value(Manual_Mode_daytime_CGM, 2, 0, 250)

Manual_Mode_daytime_CGM_70_180 =get_mean_value(Manual_Mode_daytime_CGM, 3, 180, 70)

Manual_Mode_daytime_CGM_70_150 =get_mean_value(Manual_Mode_daytime_CGM, 3, 150, 70)

Manual_Mode_daytime_CGM_70 =get_mean_value(Manual_Mode_daytime_CGM, 1, 70, 0)

Manual_Mode_daytime_CGM_54 =get_mean_value(Manual_Mode_daytime_CGM, 1, 54, 0)

"""
    we extract the daily data for the auto case
"""

Auto_Mode_daytime_CGM=Auto_Mode_CGM.loc[(Auto_Mode_CGM['Time']>=start) & (Auto_Mode_CGM['Time']<end)]


Auto_Mode_daytime_CGM180 =get_mean_value(Auto_Mode_daytime_CGM, 2, 0, 180)

Auto_Mode_daytime_CGM250 =get_mean_value(Auto_Mode_daytime_CGM, 2, 0, 250)

Auto_Mode_daytime_CGM70_180 =get_mean_value(Auto_Mode_daytime_CGM, 3, 180, 70)

Auto_Mode_daytime_CGM70_150 =get_mean_value(Auto_Mode_daytime_CGM, 3, 150, 70)

Auto_Mode_daytime_CGM70 =get_mean_value(Auto_Mode_daytime_CGM, 1, 70, 0)

Auto_Mode_daytime_CGM54 =get_mean_value(Auto_Mode_daytime_CGM, 1, 54, 0)

"""
midnight to 6 am
We start by retrieving the interval midnight to 6 am 

"""

"""
for  manual case
"""
Manual_Mode_CGM_overnight=Manual_Mode_CGM.loc[(Manual_Mode_CGM['Time']>=start) & (Manual_Mode_CGM['Time']<end)]

Manual_Mode_CGM_overnight_180 =get_mean_value(Manual_Mode_CGM_overnight, 2, 0, 180)

Manual_Mode_CGM_overnight_250 =get_mean_value(Manual_Mode_CGM_overnight, 2, 0, 250)

Manual_Mode_CGM_overnight_70_180 =get_mean_value(Manual_Mode_CGM_overnight, 3, 180, 70)

Manual_Mode_CGM_overnight_70_150 =get_mean_value(Manual_Mode_CGM_overnight, 3, 150, 70)

Manual_Mode_CGM_overnight_70 =get_mean_value(Manual_Mode_CGM_overnight, 1, 70, 0)

Manual_Mode_CGM_overnight_54 =get_mean_value(Manual_Mode_CGM_overnight, 1, 54, 0)

"""
We extract the data for the auto case
"""
Auto_Mode_CGM_overnight=Auto_Mode_CGM.loc[(Auto_Mode_CGM['Time']>=start) & (Auto_Mode_CGM['Time']<end)]

Auto_Mode_CGM_overnight_180 =get_mean_value(Auto_Mode_CGM_overnight, 2, 0, 180)

Auto_Mode_CGM_overnight_250 =get_mean_value(Auto_Mode_CGM_overnight, 2, 0, 250)

Auto_Mode_CGM_overnight_70_180 =get_mean_value(Auto_Mode_CGM_overnight, 3, 180, 70)

Auto_Mode_CGM_overnight_70_150 =get_mean_value(Auto_Mode_CGM_overnight, 3, 150, 70)

Auto_Mode_CGM_overnight_70 =get_mean_value(Auto_Mode_CGM_overnight, 1, 70, 0)

Auto_Mode_CGM_overnight_54 =get_mean_value(Auto_Mode_CGM_overnight, 1, 54, 0)

"""
we put the extracted data in a list that we will convert into a csv file

"""

metrics_extracted = [ [    Manual_Mode_CGM_overnight_180
                      ,Manual_Mode_CGM_overnight_250
                      ,Manual_Mode_CGM_overnight_70_180
                      ,Manual_Mode_CGM_overnight_70_150
                      ,Manual_Mode_CGM_overnight_70
                      ,Manual_Mode_CGM_overnight_54
                      ,Manual_Mode_daytime_CGM_180
                      ,Manual_Mode_daytime_CGM_250
                      ,Manual_Mode_daytime_CGM_70_180
                      ,Manual_Mode_daytime_CGM_70_150
                      ,Manual_Mode_daytime_CGM_70
                      ,Manual_Mode_daytime_CGM_54
                      ,Manual_Mode_CGM_fullDay180
                      ,Manual_Mode_CGM_fullDay250
                      ,Manual_Mode_CGM_fullDay70_180
                      ,Manual_Mode_CGM_fullDay70_150
                      ,Manual_Mode_CGM_fullDay70
                      ,Manual_Mode_CGM_fullDay54
                      , 1.1],
                  [   Auto_Mode_CGM_overnight_180
                      ,Auto_Mode_CGM_overnight_250
                      ,Auto_Mode_CGM_overnight_70_180
                      ,Auto_Mode_CGM_overnight_70_150
                      ,Auto_Mode_CGM_overnight_70
                      ,Auto_Mode_CGM_overnight_54
                      ,Auto_Mode_daytime_CGM180
                      ,Auto_Mode_daytime_CGM250
                      ,Auto_Mode_daytime_CGM70_180
                      ,Auto_Mode_daytime_CGM70_150
                      ,Auto_Mode_daytime_CGM70
                      ,Auto_Mode_daytime_CGM54
                      ,Auto_Mode_CGM_fullDay180
                      ,Auto_Mode_CGM_fullDay250
                      ,Auto_Mode_CGM_fullDay70_180
                      ,Auto_Mode_CGM_fullDay70_150
                      ,Auto_Mode_CGM_fullDay70
                      ,Auto_Mode_CGM_fullDay54
                      , 1.1]
                  ]

Results = pd.DataFrame(metrics_extracted)

"""
    We save it in the file Result.csv

"""
print("start saving file ")
Results.to_csv('Results.csv', header=False, index=False)
print("##############   file saving successfully  ####################")



