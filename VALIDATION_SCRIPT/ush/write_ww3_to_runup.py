from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import netCDF4
import sys

initdate=sys.argv[1] # '20121022_0600'
ncdir=sys.argv[2]
ncfile21=sys.argv[3] # '/scratch2/COASTAL/coastal/save/Ali.Abdolali/ww3.T1.4.2012_tab.nc'
ncfile22=sys.argv[4] # '/scratch2/COASTAL/coastal/save/Ali.Abdolali/ww3.T1.4.2012_tab.nc'
print('Init date: ', initdate)
print('Input dir: ', ncdir)
print('Input file ww3 type 2.1: ', ncfile21)
print('Input file ww3 type 2.2: ', ncfile22)

# Target format for runup input files:
# Time   Lon   Lat   Hs   Tp  Dir_mean   X-Vel   Y-Vel  Water_level  X-wind   Y-wind

nc4_type21 = netCDF4.Dataset(ncdir+ncfile21)
nc4_type22 = netCDF4.Dataset(ncdir+ncfile22)
print('NetCDF file type 2.1 contains the following fields:')
print(nc4_type21.variables.keys())
print('NetCDF file type 2.2 contains the following fields:')
print(nc4_type22.variables.keys())

#print(nc3.variables['station'])
#station_name = nc.variables['station_name']
#print(type(station_name))

#stations = np.loadtxt('/scratch2/COASTAL/coastal/save/Andre.VanderWesthuysen/runup/scripts/station_list.txt', dtype='int')
#stations = np.arange(2645,2648)
#stations = np.arange(2645,3109) 
stations = np.arange(0,3677)
#stations = np.arange(3000,3677)
print('Extracting 20m contours for the following stations:')
print(stations)

lon = nc4_type22.variables['longitude']
lat = nc4_type22.variables['latitude']
hs = nc4_type22.variables['hs']
fp = nc4_type22.variables['fp']
mdir = nc4_type22.variables['th1m']
dpt = nc4_type21.variables['dpt']
wnd = nc4_type21.variables['wnd']
wnddir = nc4_type21.variables['wnddir']
cur = nc4_type21.variables['cur']
curdir = nc4_type21.variables['curdir']
times = nc4_type22.variables['time']
jd = netCDF4.num2date(times[:],times.units)
jd = np.repeat(np.reshape(jd, (jd.shape[0],1)), len(stations), axis=1).flatten()
print(jd.shape)
print(jd)

#for station in stations:
#   print('Extracting Station '+str(station)+'...')

lon = 360. + np.array(lon[:,stations]).flatten()
tp = 1/np.array(fp[:,stations]).flatten()
xvel = cur[:,stations].flatten()*np.cos((curdir[:,stations])*np.pi/180.).flatten()
yvel = cur[:,stations].flatten()*np.sin((curdir[:,stations])*np.pi/180.).flatten()
xwind = wnd[:,stations].flatten()*np.cos((270. - wnddir[:,stations])*np.pi/180.).flatten()
ywind = wnd[:,stations].flatten()*np.sin((270. - wnddir[:,stations])*np.pi/180.).flatten()

statdata = pd.DataFrame({'Lon': lon, 'Lat': lat[:,stations].flatten(), 'Hs': hs[:,stations].flatten(), 'Tp': tp, 'Dir_mean': mdir[:,stations].flatten(),

'X-vel': xvel, 'Y-vel': yvel, 'Depth': dpt[:,stations].flatten(), 'X-wind': xwind, 'Y-wind': ywind}, index=jd)

print(statdata.head(5))
print(statdata.tail(5))

print('Number of NaNs in extracted dataset:\n'+str(statdata.isna().sum()))
statdata = statdata.dropna()

print(statdata.head(5))
print(statdata.tail(5))

statdata_hourly = statdata.groupby('Lat').resample('1H').mean()   #.resample('60min').mean()
statdata_hourly = statdata_hourly.reset_index(level='Lat', drop=True)
print(statdata_hourly.head(5))
print(statdata_hourly.tail(5))

statdata_hourly.to_csv('20m_contour_CG1.'+initdate, float_format='%10.4f', date_format='%Y%m%d.%H%M00', header=False, na_rep='  -99.0000')

