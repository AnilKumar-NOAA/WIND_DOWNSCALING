import numpy as np
a = np.fromfile('USGS_13_n23w160.bin', dtype='f4')
b = np.clip(a, -9999.0, None).astype('>i2')
b.tofile('10801-21600.43201-54000')
