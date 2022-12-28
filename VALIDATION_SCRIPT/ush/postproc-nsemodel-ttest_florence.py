# ----------------------------------------------------------- 
# Python Script File
# Tested Operating System(s): RHEL 7, Python 3.7.5
# Tested Run Level(s): 
# Shell Used: BASH shell
# Original Author(s): Andre van der Westhuysen
# File Creation Date: 05/15/2020
# Date Last Modified:
#
# Version control: 1.00
#
# Support Team:
#
# Contributors: 
#
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Python script to perform 90% accuracy validation of NSEM output
#
# -----------------------------------------------------------

import os, sys
import numpy as np
import pandas as pd
import netCDF4
import matplotlib.pyplot as plt
from datetime import datetime

RUNdir = os.getenv('RUNdir')
FIXnsem = os.getenv('FIXnsem')
USHnsem = os.getenv('USHnsem')
STORM = os.getenv('STORM')
sys.path.append(USHnsem)
import nsem_ttest
import nsem_utils

os.chdir(RUNdir)
print("Executing in", RUNdir)

def run_ttest(model, obs, label, units, lon, lat):
   
   p_array = np.zeros(model.shape[1])
   success_array = np.zeros(model.shape[1])
   
   for station in range(0,model.shape[1]):
      print('Processing '+model.columns[station])
      success, pvalue1, pvalue2 = nsem_ttest.test_90_accuracy(model.iloc[:,station],obs.iloc[:,station], \
                                                              plotflag=True,direc=RUNdir, \
                                                              label=label+"_station_"+model.columns[station],unit=units)
      print(station, success, pvalue1, pvalue2)
      p_array[station] = min(pvalue1, pvalue2)
      success_array[station] = success

   # Bar chart
   plt.figure(figsize = [6.4, 3.8])
   plt.rc('xtick',labelsize=9)
   plt.rc('ytick',labelsize=9)
   plt.bar(model.columns[:],p_array)
   plt.axhline(y=0.05,linewidth=1, color='r')
   #plt.yscale('log')
   plt.ylim([0.0, 0.06])
   plt.grid(axis='y', linestyle=':')
   plt.xticks(rotation=90)
   plt.xlabel("Stations",fontsize=9)
   plt.ylabel("p-value (Prob of falsely rejecting H0, while true)",fontsize=9)
   plt.title(label,fontsize=11)
   plt.savefig(RUNdir+"/ttest_summary_"+label+".png",dpi=150,bbox_inches='tight',pad_inches=0.1)
   
   # Map display
   landbound = np.loadtxt(USHnsem+'/coastal_bound_high.txt')
   #locations = pd.read_csv(RUNdir+'/ndbc_locations.txt', delim_whitespace=True)
   
   fig, ax = plt.subplots(figsize = [6.5, 5.5])
   plt.scatter(lon.iloc[0,:].values, lat.iloc[0,:].values, c=success_array, cmap='bwr_r')
   
   x=lon.iloc[0,:]
   y=lat.iloc[0,:]
   plt.rc('xtick',labelsize=9)
   plt.rc('ytick',labelsize=9)
   for i, txt in enumerate(lon.columns[:]):
       ax.annotate(txt, (x[i]+0.3, y[i]), fontsize=6)
   plt.plot(landbound[:,0]-360., landbound[:,1], 'k', linewidth=1.0)
   plt.xlim([-84.00, -60.00])
   plt.ylim([20.00, 45.00])
   plt.title(label,fontsize=11)
   plt.savefig(RUNdir+"/ttest_map_"+label+".png",dpi=150,bbox_inches='tight',pad_inches=0.1)

   return p_array, success_array

# 1. Specify tests for covered data
# (a) HWRF winds
#model = pd.read_csv(RUNdir+'/ModelWind.txt', delim_whitespace=True)
#obs = pd.read_csv(RUNdir+'/ObsWind.txt', delim_whitespace=True)

# Read in file through stores
md = netCDF4.Dataset(RUNdir+'/waveMODEL.h5', 'r')
amd = netCDF4.Dataset(RUNdir+'/atmMODEL.h5', 'r')
od = netCDF4.Dataset(RUNdir+'/waveObs.h5', 'r')
aod = netCDF4.Dataset(RUNdir+'/atmObs.h5', 'r')

print(od.variables.keys())

###############################################################################
### MODEL DATA PREP ###
###############################################################################

modelFP = md.variables['fp'][:]
modelTP = 1/modelFP
modelHS = md.variables['hs'][:]
modelMDIR = md.variables['mdir'][:]

modelWSPD = amd.variables['wnd'][:]
modelWDIR = amd.variables['wnddir'][:]

modelLON = md.variables['longitude'][:]
modelLAT = md.variables['latitude'][:]

# Creating array of time for plotting
times = md.variables['time_interval'][:]
# Write time to dataframe
timeSetup2 = pd.DataFrame(data=times[:])
# Convert to datetime format
timeSetup3 = pd.to_datetime(timeSetup2[0])

timeIndex = timeSetup3
    
# Create same for stations so can pull station ID
Modelstations = md.variables['station_name']
stationModIndex = []

for stationMod in range(0,len(Modelstations)):
    s = Modelstations[stationMod][0]
    stationModIndex.append(s)    
    
TPmodelData = pd.DataFrame(data=modelTP[:,:], columns=stationModIndex, index=timeIndex)
HSmodelData = pd.DataFrame(data=modelHS[:,:], columns=stationModIndex, index=timeIndex)
MDIRmodelData = pd.DataFrame(data=modelMDIR[:,:], columns=stationModIndex, index=timeIndex)

WSPDmodelData = pd.DataFrame(data=modelWSPD[:,:], columns=stationModIndex, index=timeIndex)
WDIRmodelData = pd.DataFrame(data=modelWDIR[:,:], columns=stationModIndex, index=timeIndex)

LONmodelData = pd.DataFrame(data=modelLON[:,:], columns=stationModIndex, index=timeIndex)
LATmodelData = pd.DataFrame(data=modelLAT[:,:], columns=stationModIndex, index=timeIndex)

###############################################################################
### OBSERVATIONAL DATA PREP ###
###############################################################################

obsTP = od.variables['tp'][:]
obsHS = od.variables['hs'][:]
obsMDIR = od.variables['mwd'][:]

obsWSPD = aod.variables['wspd'][:]
obsWDIR = aod.variables['wdir'][:]

# Create same list for stations so can pull station ID
ObsStations = od.variables['station']
stationObsIndex = []

for stationObs in range(0,len(ObsStations)):
    s = ObsStations[stationObs][0]
    stationObsIndex.append(s)   

# Create dataFrame for all observational variables    
TPobsData = pd.DataFrame(data=obsTP[:,:], columns=stationObsIndex, index=timeIndex)
TPobsData = TPobsData.mask(-999 > TPobsData)

HSobsData = pd.DataFrame(data=obsHS[:,:], columns=stationObsIndex, index=timeIndex)
HSobsData = HSobsData.mask(-999 > HSobsData)

MDIRobsData = pd.DataFrame(data=obsMDIR[:,:], columns=stationObsIndex, index=timeIndex)
MDIRobsData = MDIRobsData.mask(-999 > MDIRobsData)

WSPDobsData = pd.DataFrame(data=obsWSPD[:,:], columns=stationObsIndex, index=timeIndex)
WSPDobsData = WSPDobsData.mask(-999 > WSPDobsData)

WDIRobsData = pd.DataFrame(data=obsWDIR[:,:], columns=stationObsIndex, index=timeIndex)
WDIRobsData = WDIRobsData.mask(-999 > WDIRobsData)

"""
# Stations where obs are available
model = WSPDmodelData[['44005', '41010', '42058', '41025', '42059', '41062',
       '42035', '42003', '44017', '41043', '42001', '42020', '41008', '42060',
       '44025', '44018', '44100', '41044', '44008', '44020', '41049', '42039',
       '41009', '44066', '41047', '42057', '44014', '44088', '42012', '41048',
       '42040', '44095', '42002', '44009', '41004', '41046', '44007', '41013',
       '44027', '44011', '42055', '41002', '42019', '42056', '44013', '44065']]
obs = WSPDobsData[['44005', '41010', '42058', '41025', '42059', '41062',
       '42035', '42003', '44017', '41043', '42001', '42020', '41008', '42060',
       '44025', '44018', '44100', '41044', '44008', '44020', '41049', '42039',
       '41009', '44066', '41047', '42057', '44014', '44088', '42012', '41048',
       '42040', '44095', '42002', '44009', '41004', '41046', '44007', '41013',
       '44027', '44011', '42055', '41002', '42019', '42056', '44013', '44065']]
"""

"""
# Stations in the region of Hurrican Florence
stations = ['41010', '41025','42035', '42003', '44017', '41043', '42001', '42020', '41008',
            '42060', '44025', '44018', '41044', '44020', '41049', '42039',
            '41009', '44066', '41047', '42057', '44014', '42012', '41048',
            '42040', '42002', '44009', '41004', '41046', '44007', '41013',
            '44027', '42055', '41002', '42019', '42056', '44013', '44065']
"""

stations = ['41002', '41004', '41008', '41009', '41010', '41013', '44018', '41025', 
            '41043', '41044', '41046', '41047', '41048', '41049', '44007', '44009', 
            '44013', '44014', '44017', '44020', '44025', '44027', '44065', '44066']

model = WSPDmodelData[stations]
obs = WSPDobsData[stations]
lon = LONmodelData[stations]
lat = LATmodelData[stations]

#[['41004','41008','41009','41013','41025']]

pd.set_option('display.max_columns', None)
print(model.shape)
print(obs.shape)
print(lon.shape)
print(lat.shape)
print(model.columns)
print(obs.columns)
print(lon.columns)
print(lat.columns)
print(model.head(20))
print(obs.head(20))
print(lon.head(20))
print(lat.head(20))

label = "HWRF"
units = "U10 (m/s)"
### Clean obs data by setting all exception values (99.00) and zeros to nan, and forward-filling these values
obs = obs[obs < 99.00]
obs = obs[obs > 0.00]
obs = obs.fillna(method='ffill')
p_array, success_array = run_ttest(model, obs, label, units, lon, lat)
u10_best = model.columns[np.argmax(p_array)]  
u10_worst = model.columns[np.argmin(p_array)]
print('All stations:')
print(model.columns)
print('p-values for all stations:')
print(p_array)
print('Pass (1) or fail (0) for all stations:')
print(success_array)
print('Best station is '+u10_best)
print('Worst station is '+u10_worst)

# (b) WW3 Hs
#model = pd.read_csv(RUNdir+'/ModelHs.txt', delim_whitespace=True)
#obs = pd.read_csv(RUNdir+'/ObsHs.txt', delim_whitespace=True)

model = HSmodelData[stations]
obs = HSobsData[stations]

label = "WW3"
units = "Hs (m)"
p_array, success_array = run_ttest(model, obs, label, units, lon, lat)
hs_best = model.columns[np.argmax(p_array)]  
hs_worst = model.columns[np.argmin(p_array)] 
print('All stations:')
print(model.columns)
print('p-values for all stations:')
print(p_array)
print('Pass (1) or fail (0) for all stations:')
print(success_array)
print('Best station is '+hs_best)
print('Worst station is '+hs_worst)

exit(0)

# 2. Compile automated validation report
# (a) Find best and worst performing stations in terms of p-values

# (b) Populate report by setting paths to result figures
dc_valreport={}
dc_valreport.update({'storm'                  :STORM })
dc_valreport.update({'date'                   :datetime.today().strftime('%B %e, %Y') })
dc_valreport.update({'fig_hwrf_summary'       :RUNdir+"/ttest_summary_HWRF.png" })
dc_valreport.update({'fig_hwrf_map'           :RUNdir+"/ttest_map_HWRF.png" })
dc_valreport.update({'fig_ww3_summary'        :RUNdir+"/ttest_summary_WW3.png" })
dc_valreport.update({'fig_ww3_map'            :RUNdir+"/ttest_map_WW3.png" })
dc_valreport.update({'fig_u10_ts_best'        :RUNdir+"/ttest_ts_HWRF_station_"+u10_best+".png" })
dc_valreport.update({'fig_u10_ts_worst'       :RUNdir+"/ttest_ts_HWRF_station_"+u10_worst+".png" })
dc_valreport.update({'fig_u10_hist_best'      :RUNdir+"/ttest_hist_HWRF_station_"+u10_best+".png" })
dc_valreport.update({'fig_u10_hist_worst'     :RUNdir+"/ttest_hist_HWRF_station_"+u10_worst+".png" })
dc_valreport.update({'fig_u10_scatter_best'   :RUNdir+"/ttest_scatter_HWRF_station_"+u10_best+".png" })
dc_valreport.update({'fig_u10_scatter_worst'  :RUNdir+"/ttest_scatter_HWRF_station_"+u10_worst+".png" })
dc_valreport.update({'fig_hs_ts_best'        :RUNdir+"/ttest_ts_WW3_station_"+hs_best+".png" })
dc_valreport.update({'fig_hs_ts_worst'       :RUNdir+"/ttest_ts_WW3_station_"+hs_worst+".png" })
dc_valreport.update({'fig_hs_hist_best'      :RUNdir+"/ttest_hist_WW3_station_"+hs_best+".png" })
dc_valreport.update({'fig_hs_hist_worst'     :RUNdir+"/ttest_hist_WW3_station_"+hs_worst+".png" })
dc_valreport.update({'fig_hs_scatter_best'   :RUNdir+"/ttest_scatter_WW3_station_"+hs_best+".png" })
dc_valreport.update({'fig_hs_scatter_worst'  :RUNdir+"/ttest_scatter_WW3_station_"+hs_worst+".png" })
##
tmpname = os.path.join(FIXnsem,'templates','validation_report.tex.tmpl')
val_report = os.path.join(RUNdir,'validation_report_'+STORM+'_'+datetime.today().strftime('%Y-%m-%d')+'.tex')
nsem_utils.tmp2scr(filename=val_report,tmpname=tmpname,d=dc_valreport)
# (c) Compile the validation report to PDF
os.system('pdflatex '+val_report)

