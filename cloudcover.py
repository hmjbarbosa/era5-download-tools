import numpy as np
import pandas as pd
import xarray as xr
import matplotlib.pyplot as plt

plt.ion()

print('loading data...')

data = xr.open_dataset('./cloudcover_ATTO_ERA5_combined.nc')
lcc = data.lcc
mcc = data.mcc 
hcc = data.hcc
tcc = data.tcc

print('plotting...')
plt.figure(num=1, clear=True)
plt.plot(lcc.time, lcc, label='Low')
plt.plot(mcc.time, mcc, label='Mid')
plt.plot(hcc.time, hcc, label='High')
plt.plot(tcc.time, tcc, label='Total', linewidth=2)
plt.legend()
plt.xlabel('Time')
plt.ylabel('Cloud Cover')
plt.title('TCC vs Time at lon=-60, lat=-3')

#