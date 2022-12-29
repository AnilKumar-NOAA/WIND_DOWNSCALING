#!/bin/bash

from pandas import read_csv
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


dataset = read_csv('capemay_ready.csv', delimiter = ',')
dataset.replace(to_replace=9999, value=np.nan, inplace=True)
print(dataset[['OBS_WIND_CM']])

obs_gust = dataset[['OBS_GUST_CM']]
mod_gust = dataset[['MODEL_GUST_CM']]

#print(obs_wind)
w = 12 
h = 8 
d = 70
plt.figure(figsize=(w,h), dpi=d)
plt.plot(time,obs_gust, color='blue', label='OBS')
plt.plot(time,mod_gust, color='red', label='MODEL')
plt.ylim([0,50])
plt.xlim([0,45])
plt.xlabel('Oct 2012 (UTC/Date)', fontsize=30)
plt.ylabel('Wind Gust (m/s)', fontsize=30)
#plt.xticks(fontsize=20)
positions = (1,12,24,36)
labels = ("12/23","18/29","00/30","06/30")
plt.xticks(positions, labels, fontsize=20)
plt.yticks(fontsize=20)
plt.title('Cape May, NJ\nStation 8536110', fontsize=25)
plt.legend(prop={"size":20})
plt.show()
