# Script: ttest_90_accuracy_v3.py
# Author: Andre van der Westhuysen, 08/26/19
# Purpose: Script to perform a paired t-test for assessing 90% accuracy 

import numpy as np
import pandas as pd
from scipy import stats
from sklearn.linear_model import LinearRegression
from sklearn import metrics
import matplotlib.pyplot as plt
from pandas import read_csv

# --- Parameters ---------------
# Set data directory
direc = "/scratch2/COASTAL/coastal/save/Anil.Kumar/SANDY_PLOT/"
# ------------------------------

def ttest_90_accuracy(model, observations, plotflag=False, label="model", unit="Value"):
# Function to perform the 90% accuracy test for FEMA using
# a paired t-test on the model output and observations.
# Data is partitioned into a subset before and after the 
# storm peak in order to detect 

   # Split the data into segments before and after the storm peak
#   cuttime = obs.idxmax(axis=1)
#   print("Split ts at index of max obs: "+str(cuttime))
   obs1 = observations #[:cuttime]
   mod1 = model #[:cuttime]
   obs2 = observations #[cuttime:]
   mod2 = model #[cuttime:]
    
   # Perform a paired t-test on the increasing ts segment
   m = 0.1
   alpha = 0.05
   #print("mean = "+str(np.mean((mod1-obs1)/obs1))+", stdev = "+str(stats.tstd((mod1-obs1)/obs1)))
   if np.mean(((mod1-obs1)/obs1) > 0).all():
      # Alternative hypothesis: mu_drel > 0.1 (right-tailed test)
      print("Testing Ha: mu_drel > "+str(m))
      results = stats.ttest_1samp((mod1-obs1)/obs1, m)
      #print(results[0],results[1])
      if (results[0] > 0) & (results[1]/2 < alpha):
         pvalue1 = results[1]/2
         print('p-value = '+"{:.5f}".format(pvalue1))
         print("reject null hypothesis, mean is more than "+str(m))
         test1 = 0
      else:
         if (results[0] > 0):
            pvalue1 = results[1]/2
            print('p-value = '+"{:.5f}".format(pvalue1))
         else:
            pvalue1 = 1-results[1]/2
            print('p-value = '+"{:.5f}".format(pvalue1))
         print("accept null hypothesis")
         test1 = 1
   else:
      # Alternative hypothesis: mu_drel < -0.1 (left-tailed test)
      print("Testing Ha: mu_drel < "+str(-m))
      results = stats.ttest_1samp((mod1-obs1)/obs1, -m)
      #print(results[0],results[1])
      if ((results[0] < 0) & (results[1]/2 < alpha)).all():
         pvalue1 = results[1]/2
         print('p-value = '+"{:.5f}".format(pvalue1))
         print("reject null hypothesis, mean is less than "+str(-m))
         test1 = 0
      else:
         if ((results[0] < 0)).all():
            pvalue1 = results[1]/2
            print('p-value = '+"{:.5f}".format(pvalue1))
         else:
            pvalue1 = 1-results[1]/2
#            print('p-value = '+"{:.5f}".format(pvalue1))         
         print("accept null hypothesis")   
         test1 = 1

   # Perform a paired t-test on the decreasing ts segment  
   #print("mean = "+str(np.mean((mod2-obs2)/obs2))+", stdev = "+str(stats.tstd((mod2-obs2)/obs2)))
   if np.mean(((mod2-obs2)/obs2) > 0).all():
      # Alternative hypothesis: mu_drel > 0.1 (right-tailed test)
      print("Testing Ha: mu_drel > "+str(m))
      results = stats.ttest_1samp((mod2-obs2)/obs2, m)
      #print(results[0],results[1])
      if (results[0] > 0) & (results[1]/2 < alpha):
         pvalue2 = results[1]/2
         print('p-value = '+"{:.5f}".format(pvalue2))
         print("reject null hypothesis, mean is more than "+str(m))
         test2 = 0
      else:
         if (results[0] > 0):
            pvalue2 = results[1]/2
            print('p-value = '+"{:.5f}".format(pvalue2))
         else:
            pvalue2 = 1-results[1]/2
            print('p-value = '+"{:.5f}".format(pvalue2))
         print("accept null hypothesis")
         test2 = 1
   else:
      # Alternative hypothesis: mu_drel < -0.1 (left-tailed test)
      print("Testing Ha: mu_drel < "+str(-m))
      results = stats.ttest_1samp((mod2-obs2)/obs2, -m)
      #print(results[0],results[1])
      if ((results[0] < 0) & (results[1]/2 < alpha)).all():
         pvalue2 = results[1]/2
         print('p-value = '+"{:.5f}".format(pvalue2))
         print("reject null hypothesis, mean is less than "+str(-m))
         test2 = 0
      else:
         if ((results[0] < 0)).all():
            pvalue2 = results[1]/2
            print('p-value = '+"{:.5f}".format(pvalue2))
         else:
            pvalue2 = 1-results[1]/2
#            print('p-value = '+"{:.5f}".format(pvalue2))         
         print("accept null hypothesis")   
         test2 = 1

   # Compare with Simple Linear Regression
   model = np.array(model)
   observations = np.array(observations)
   linreg = LinearRegression(fit_intercept=False)  # Regression through origin
   linreg.fit(observations[:, np.newaxis],model[:, np.newaxis])
   y_pred = linreg.predict(observations[:, np.newaxis])
   intercept = 0. #linreg.intercept_[0]
   slope = float(linreg.coef_[0])
   rmse = np.sqrt(metrics.mean_squared_error(model[:, np.newaxis],y_pred))
   si = rmse/np.mean(observations)
   #print("Intercept ="+str(intercept))
   #print("Slope ="+str(slope))
   #print("RMSE = "+str(rmse))
   #print("SI = "+str(si)) 
         
   if (test1 == 1 and test2 == 1):
      success = 1
      print(" => 90% accuracy criterion is met.")
   else:
      success = 0
      print(" => 90% accuracy criterion is NOT met.")
   #print("Range of rel_d1 = ["+str(min((mod1-obs1)/obs1))+", "+str(max((mod1-obs1)/obs1))+"]")
   #print("Range of rel_d2 = ["+str(min((mod2-obs2)/obs2))+", "+str(max((mod2-obs2)/obs2))+"]")

   # Plot the time series
   if plotflag:
      plt.clf()
      fig, axs = plt.subplots(2)
      axs[0].plot(obs1, 'k-o', markerfacecolor='w', markeredgecolor='k', markersize=3, label='Observations')
      axs[0].plot(mod1, 'b-', label='Model')
      axs[0].legend()
      axs[0].plot(0.9*obs1, 'k--', linewidth=0.5)
      axs[0].plot(1.1*obs1, 'k--', linewidth=0.5)
      axs[0].set(ylabel=unit, title="Station "+label+": p-values = "+"{:.5f}".format(pvalue1)+"; "+"{:.5f}".format(pvalue2))
      axs[0].set(ylim=[0,1.2*max(max(obs1),max(mod1))])
      axs[1].plot(obs2, 'k-o', markerfacecolor='w', markeredgecolor='k', markersize=3, label='Observations')
      axs[1].plot(mod2, 'b-', label='Model')
      axs[1].legend()
      axs[1].plot(0.9*obs2, 'k--', linewidth=0.5)
      axs[1].plot(1.1*obs2, 'k--', linewidth=0.5)
      axs[1].set(xlabel="Time (h)", ylabel=unit)
      axs[1].set(ylim=[0,1.2*max(max(obs2),max(mod2))])
      plt.savefig(direc+"plots/ttest_ts_"+label+".png",dpi=150,bbox_inches='tight',pad_inches=0.1)

   # Plot the histogram of the difference d
   if plotflag:
      d1 = mod1 - obs1
      d2 = mod2 - obs2
      maxdev = max(max(d1),max(d2))
      plt.clf()
      fig, axs = plt.subplots(2)
      axs[0].hist(d1, 20)
      axs[0].set(ylabel="Frequency", xlim=[-(maxdev+1),maxdev+1], title="Station "+label+": p-values = "+"{:.5f}".format(pvalue1)+"; "+"{:.5f}".format(pvalue2))
      axs[0].text(0.05, 0.8, "n="+str(len(d1)), transform = axs[0].transAxes)
      axs[1].hist(d2, 20)
      axs[1].set(xlabel="d", ylabel="Frequency", xlim=[-(maxdev+1),maxdev+1])
      axs[1].text(0.05, 0.8, "n="+str(len(d2)), transform = axs[1].transAxes)
      plt.savefig(direc+"plots/ttest_hist_"+label+".png",dpi=150,bbox_inches='tight',pad_inches=0.1)
      
   if plotflag:
      plt.clf()
      plt.plot(observations, model, 'ko', markersize=2)
      plt.plot(observations, intercept + observations*slope, 'k-')
      plt.plot([0, max(observations)], [0, max(observations)], 'k--')
      plt.plot([0, max(observations)], [0, 0.9*max(observations)], 'k:')
      plt.plot([0, max(observations)], [0, 1.1*max(observations)], 'k:')
      plt.xlabel("obs", fontsize=12)
      plt.ylabel("mod", fontsize=12)
      plt.xlim([0, max(max(model), max(observations))])
      plt.ylim([0, max(max(model), max(observations))])
      plt.gca().set_aspect('equal', adjustable='box')
      plt.text(0.15, 0.8, "Slope="+"{:.3f}".format(slope), transform = axs[0].transAxes, fontsize=12)
      plt.text(0.15, 0.6, "RMSE="+"{:.4f}".format(rmse), transform = axs[0].transAxes, fontsize=12)
      plt.text(0.15, 0.4, "SI="+"{:.4f}".format(si), transform = axs[0].transAxes, fontsize=12)
      plt.savefig(direc+"plots/ttest_scatter_"+label+".png",dpi=150,bbox_inches='tight',pad_inches=0.1) 
   
   return success

# Read and select example data
time = np.arange(43)
obs = []
mod = []

dataset = read_csv('capemay_ready.csv', delimiter = ',')
dataset.replace(to_replace=9999, value=np.nan, inplace=True)
print(dataset[['OBS_WIND_CM']])

obs = dataset[['OBS_GUST_CM']]
mod = dataset[['MODEL_GUST_CM']]
print(ttest_90_accuracy(mod,obs,plotflag=True,unit="U10 (m/s)"))
