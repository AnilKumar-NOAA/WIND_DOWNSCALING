#!/bin/bash
#from pandas import read_csv
import csv
import numpy as np
import matplotlib.pyplot as plt
import array

date = []
time = np.arange(43) 
obs_wind = []
obs_gust = []
obs_wdir = []
obs_psfc = []
mod_wind = []
mod_gust = []
mod_wdir = []
mod_psfc = []

data_path = 'capemay_ready.csv'
with open(data_path, 'r') as f:
 reader=csv.reader(f, delimiter=',')
# reader=read_csv('capemay_ready.csv', delimiter=',')
# next(reader, None)
 headers=next(reader)
 data=np.array(list(reader)).astype(float)
 print(headers)
 print(data.shape)
 print(time)
 obs_wind = data[:,3] 
 mod_wind = data[:,6]
 print(obs_wind)
 obs_wind.replace(9999, np.NaN)
plt.plot(time,obs_wind, color='blue')
plt.plot(time,mod_wind, color='red')
plt.xlabel('time')
plt.ylabel('wind')
plt.title('Wind vs time')
plt.legend()
plt.show()

