import pandas as pd
from pandas.io.json import json_normalize
import requests

# 42036 (LLNR 855) - WEST TAMPA - 112 NM WNW of Tampa, FL
# 42039 (LLNR 115) - PENSACOLA - 115NM SSE of Pensacola, FL
# 41009 (LLNR 840) - CANAVERAL 20 NM East of Cape Canaveral, FL

colnames = ["YY","MM","DD","hh","mm","WDIR","WSPD","GST","WVHT","DPD","APD","MWD","PRES","ATMP","WTMP","DEWP","VIS","TIDE"]

stations = ["42036","42039"] #, "41009"]
HSobs = pd.DataFrame(data=[])
for stat in stations:
   df = pd.read_csv(stat+'h2017.txt', sep='\s+', skiprows=1, header=0, names=colnames)
   HSobs['Date'] = pd.to_datetime(df['YY'].astype(str)+' '+df['MM'].astype(str)+' '+df['DD'].astype(str)+' '+df['hh'].astype(str)+' '+df['mm'].astype(str), format='%Y %m %d %H %M')
   HSobs[stat] = df['WVHT']
HSobs = HSobs.set_index('Date')
#print(HSobs.head(10))

#WLobs.drop(WLobs.head(6).index,inplace=True)
HSobs.drop(HSobs.tail(1).index,inplace=True)
print(HSobs.head(10))
print(HSobs.tail(10))
HSobs.to_pickle("obs_hs.pkl")

stations = ["42036","42039","venf1","npsf1","vcaf1","kywf1"] #, "41009"]
WNDobs = pd.DataFrame(data=[])
for stat in stations:
   df = pd.read_csv(stat+'h2017.txt', sep='\s+', skiprows=1, header=0, names=colnames)
   WNDobs['Date'] = pd.to_datetime(df['YY'].astype(str)+' '+df['MM'].astype(str)+' '+df['DD'].astype(str)+' '+df['hh'].astype(str)+' '+df['mm'].astype(str), format='%Y %m %d %H %M')
   # Correct for elevation
   # See https://en.wikipedia.org/wiki/Wind_profile_power_law
   if stat=="npsf1":
      WNDobs[stat] = df['WSPD']*(10/4.666)**0.143  # Open land
   elif stat=="kywf1":
      WNDobs[stat] = df['WSPD']*(10/3.712)**0.11  # Open water
   else:
      WNDobs[stat] = df['WSPD']
WNDobs = WNDobs.set_index('Date')
#print(HSobs.head(10))

#WLobs.drop(WLobs.head(6).index,inplace=True)
WNDobs.drop(WNDobs.tail(1).index,inplace=True)
print(WNDobs.head(10))
print(WNDobs.tail(10))
WNDobs.to_pickle("obs_wnd.pkl")
