Steps TO Execute Code

1 -RUN THE COMMAND **pip install requirements.txt** or **pip3 install requirements.txt**   to install depedencies
2 RUN THE COMMAND **python main.py** to run the script


the code is composed of two methods

**Processing_data(file_CGM ,file_insuline):** 
n this method we collect the CGM and insulin data, we extract the Date time Sensor glucose columns from the CGM data then  
we delete the na value .We convert the date and time then we separate the data into manual and automatic data
The function returns manual and automatic data (CASE A :Manual mode) & (CASE B:Auto mode)


**get_mean_value(subset_data, typeVal = -1, lessthan = 1, greaterthan = 1)**

this function allows to calculate the average value of each metric. It takes as parameters three arguments
:param subset_data: the data to be extracted
:param typeVal: this parameter allows to know the type of value to extract ( > or > or > <) 1< 2> 3 ><>
:param lessthan:   quantity inf
:param greaterthan: max quantity
:return: the average of the calculated metric

we extract metric from manual mode ad auto mode .we extract data by
whole day 12 am to 12 am


overnight midnight to 6 am

daytime  6 am to midnight 

