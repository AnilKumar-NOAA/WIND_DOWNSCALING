import numpy as np
import pandas as pd

import matplotlib as mpl
mpl.use('Agg')

import matplotlib.pyplot as plt
from matplotlib import cm
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import sys

initdate=sys.argv[1]
trackfile=sys.argv[2]

landbound = np.loadtxt('coastal_bound_high.txt')

runupdat = pd.read_csv('20m_CG1_runup.'+initdate, delim_whitespace=True, skiprows=7, header=None, names=['DATE','Xp','Yp','Hs','pp','slope','twl','runup','setup','swash','inc. swash','infrag. swash','dune crest','dune toe','50% overwash','50% erosion'])
runupdat['DATE'] = pd.to_datetime(runupdat['DATE'].astype(str).str.pad(width=13, side='right', fillchar='0'), format='%Y%m%d.%H%M')
runupdat.set_index('DATE', inplace=True)
print(runupdat.shape)
print(runupdat.head(50))
print(runupdat.tail(50))
#print(runupdat.index)
#print(runupdat.index.unique().tolist())

df = pd.read_csv(trackfile, header='infer')
df['Date'] = pd.to_datetime(initdate[0:4]+'/'+initdate[4:6]+'/'+df['Date'].astype(str), format='%Y/%m/%d/%H%M')
df.set_index('Date', inplace=True)
print(df.head(50))

df_resampled = df.resample('1H').ffill()
print(df_resampled.head(50))

plt.figure(dpi=300)

for idx in runupdat.index.unique().tolist():     #TESTING:  for idx in ['2012-10-22 06:30:00', '2012-10-22 06:40:00', '2012-10-22 06:50:00']:
    plotdate = str(idx).replace('-','').replace(':','').replace(' ','_')
    print('Plotting '+plotdate)
    
    contour = runupdat.loc[idx]
    #print(contour.head(10))
    eye = df_resampled.loc[idx]

    #plt.figure(dpi=300)
    ax = plt.axes(projection=ccrs.Mercator())
    #plt.gca().coastlines('10m')
    cmap = plt.cm.get_cmap('RdYlBu_r')
    sc = plt.scatter(contour[['Xp']].values-360., contour[['Yp']].values, c=contour[['runup']].values, vmin=0., vmax=3.50, cmap=cmap, transform=ccrs.PlateCarree())
    plt.colorbar(sc, cmap=cmap, orientation='vertical',ticklocation='auto')
    plt.plot(-df[['Longitude']].values, df[['Latitude']].values, 'k--', transform=ccrs.PlateCarree())
    plt.plot(-eye[['Longitude']].values, eye[['Latitude']].values, 'ko', markerfacecolor='black', transform=ccrs.PlateCarree())
    ax.set_aspect('auto', adjustable=None)
    #ax.set_extent([-74.20, -73.00, 39.75, 40.80])
    ax.set_extent([-90.00, -64.50, 24.00, 45.60])    
    #coast = cfeature.GSHHSFeature(scale='high',edgecolor='black')
    #ax.add_feature(coast)
    plt.plot(landbound[:,0]-360., landbound[:,1], 'k', transform=ccrs.PlateCarree())
    gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                  linewidth=0.5, color='gray', alpha=0.5, linestyle='--')
    gl.xlabels_top = False
    gl.ylabels_right = False
    gl.xlabel_style = {'size': 7}
    gl.ylabel_style = {'size': 7}
    plt.title('Wave Runup contribution (m): '+str(idx))

    plt.savefig('runup_contour'+plotdate+'.png', bbox_inches='tight')
    plt.clf()
