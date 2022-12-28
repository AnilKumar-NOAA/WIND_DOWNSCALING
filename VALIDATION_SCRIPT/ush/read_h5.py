import pandas as pd

filename = '/scratch2/COASTAL/coastal/save/Autumn.Poisson/Pre-Processing/Model-HDF5-Files/atmMODEL.h5'

model = pd.read_hdf(filename)
amd = netCDF4.Dataset(ATMmodelFile, 'r')
print(model.head(20))
