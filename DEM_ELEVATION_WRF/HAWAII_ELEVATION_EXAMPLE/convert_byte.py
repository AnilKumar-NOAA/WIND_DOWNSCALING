import numpy as np
a = np.fromfile('64801-75600.10801-21600', dtype='f4')
b = a.astype('>i2')
b.tofile('new.dat')
