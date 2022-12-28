import os, sys
import numpy as np
import pandas as pd

NSEMdir = os.environ['NSEMdir']
PARMnsem = os.environ['PARMnsem']
STORM = os.getenv('STORM')
COMINobs = os.getenv('COMINobs')

sys.path.append(PARMnsem+'/storms/'+STORM)
import base_info

stations = pd.read_csv(PARMnsem+'/storms/'+STORM+'/StationsWind.csv', header='infer', index_col="coordinate")

count=0
for station in stations.columns:
    df = pd.read_csv(PARMnsem+'/storms/'+STORM+'/CO-OPS_'+str(station)+'_meteo_met.csv',  usecols=['Date','Time (GMT)','Wind Speed (m/s)'],na_values=['-'])
    df = df.rename(columns={'Wind Speed (m/s)':station})
    df['DATE'] = pd.to_datetime(df['Date'].astype(str)+' '+df['Time (GMT)'].astype(str).str.zfill(4), format='%Y/%m/%d %H:%M') 
    df = df[['DATE',station]]
    df = df.rename(columns={'DATE':'Date'}) 
    mask = (df['Date'] >= base_info.analysis_start_date.strftime('%Y-%m-%d %H:%M:%S')) & (df['Date'] <= base_info.analysis_end_date.strftime('%Y-%m-%d %H:%M:%S'))
    df = df.loc[mask]
    print(df.head(10))
    if count==0:
       obs = df
    else:
       obs = pd.merge(obs, df, on='Date', how='inner')
    count+=1

obs.set_index('Date', inplace=True)
print(obs.head(10))
obs.to_csv(COMINobs+"/ObsWind.csv", float_format="%.3f")
