import pandas as pd
from pandas.io.json import json_normalize
import requests

"""
# call API and convert response into Python dictionary
url = f'https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?product=water_level&application=NOS.COOPS.TAC.WL&begin_date=20180909&end_date=20180917&datum=MSL&station=8658163&time_zone=GMT&units=metric&format=json'
response = requests.get(url).json()

print(response.get('metadata'))
wl = json_normalize(response, 'data')
print (wl)

exit(0)
"""

# 8724580  Key West, FL 
# 8723970  Vaca Key, Florida Bay, FL
# 8725110  Naples, Gulf of Mexico, FL
# 8725520  Fort Myers, FL

stations = ["8724580", "8723970", "8725110", "8725520"]
WLobs = pd.DataFrame(data=[])
for stat in stations:
   df = pd.read_csv('CO-OPS_'+stat+'_met.csv',header='infer')
   WLobs['Date'] = pd.to_datetime(df['Date'].astype(str)+' '+df['Time (GMT)'].astype(str), format='%Y/%m/%d %H:00')
   WLobs[stat] = df['Verified (m)']
WLobs = WLobs.set_index('Date')
print(WLobs.head)

#WLobs.drop(WLobs.head(6).index,inplace=True)
WLobs.drop(WLobs.tail(23).index,inplace=True)
print(WLobs.shape[0])
print(WLobs.head(30))
print(WLobs.tail(30))
WLobs.to_pickle("obs_wlv.pkl")
