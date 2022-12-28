#!/bin/bash

from pandas import read_csv
import numpy as np
import matplotlib.pyplot as plt
import array
from scipy import stats
from sklearn.linear_model import LinearRegression
from sklearn import metrics

date = []
time = np.arange(20)
obs_wind = []
obs_gust = []
obs_wdir = []
obs_psfc = []
mod_wind = []
mod_gust = []
mod_wdir = []
mod_psfc = []


dataset = read_csv('CLKN7_ready.csv', delimiter = ',')
dataset.replace(to_replace=9999, value=np.nan, inplace=True)

obs_gust = dataset[['OBS_GUST_WV']].fillna(0)
mod_gust = dataset[['MODEL_GUST_WV']].fillna(0)

print(obs_gust, mod_gust)

'''
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
'''

w = 12
h = 8
d = 70
plt.figure(figsize=(w,h), dpi=d)
 # Compare with Simple Linear Regression
model = np.array(mod_gust)
observations = np.array(obs_gust)
linreg = LinearRegression(fit_intercept=False)  # Regression through origin
linreg.fit(observations[:],model[:])
y_pred = linreg.predict(observations[:])
intercept = 0. #linreg.intercept_[0]
slope = float(linreg.coef_[0])
rmse = np.sqrt(metrics.mean_squared_error(model[:],y_pred))
si = rmse/np.mean(observations)
print("Intercept ="+str(intercept))
print("Slope ="+str(slope))
print("RMSE = "+str(rmse))
print("SI = "+str(si))

plt.clf()
plt.plot(observations, model, 'ko', markersize=2)
plt.plot(observations, intercept + observations*slope, 'k-')
plt.plot([0, max(observations)], [0, max(observations)], 'k--')
plt.plot([0, max(observations)], [0, 0.9*max(observations)], 'k:')
plt.plot([0, max(observations)], [0, 1.1*max(observations)], 'k:')
plt.xlabel("obs", fontsize=25)
plt.ylabel("model", fontsize=25)
plt.yticks(fontsize=18)
plt.xticks(fontsize=18)
plt.xlim([0, max(max(model)+5, max(observations)+5)])
plt.ylim([0, max(max(model)+5, max(observations)+5)])
plt.gca().set_aspect('equal', adjustable='box')
plt.text(1.0,  30.0, "Slope="+"{:.3f}".format(slope), fontsize=16)
plt.text(1.0,  28.0, "RMSE="+"{:.4f}".format(rmse), fontsize=16)
plt.text(1.0,  26.0, "SI="+"{:.4f}".format(si), fontsize=16)
plt.title('CLKN7, Cape Lookout, NC \nWind Gust (10m) m/s', fontsize=20)
plt.legend()
plt.savefig('CLKN7_gust_D01.png')
plt.show()
