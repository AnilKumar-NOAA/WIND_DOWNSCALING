import pandas as pd

filename = 'data.h5'

hs = {'Date': [1, 2, 3], 'stat1': [1.01, 2.20, 2.95], 'stat2': [1.1, 1.6, 1.9], 'stat3': [2.5, 2.6, 2.8]}
pdir = {'Time': [1, 2, 3], 'stat1': [135, 140, 129], 'stat2': [90, 95, 91], 'stat3': [180, 185, 182]}
df1 = pd.DataFrame(data = hs)
df2 = pd.DataFrame(data = pdir)
print(df1.head())
print(df2.head())
print('Writing dataframe...')
df1.to_hdf(filename, key='hs', mode='w', float_format='%10.4f', date_format='%Y%m%d%H%M00', header=True)
df2.to_hdf(filename, key='pdir', mode='a', float_format='%10.4f', date_format='%Y%m%d%H%M00', header=True)

print('Reading dataframe...')
df3 = pd.read_hdf(filename, key='hs')
print(df3.head())
df4 = pd.read_hdf(filename, key='pdir')
print(df4.head())
