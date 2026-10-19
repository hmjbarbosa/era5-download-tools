import numpy as np
import pandas as pd
import xarray as xr
import matplotlib.pyplot as plt
import glob
import time

plt.ion()

start_time = time.time()

# from ECMWF (variable is valid_time)

print('loading lcc...')
dslcc = xr.open_mfdataset(sorted(glob.glob('./sfc_dt1h/lcc/lcc_202*.nc')), decode_coords=False)
lcc = dslcc.lcc.sel(longitude=300, latitude=-3).rename({'valid_time': 'time'}).compute()
elapsed = time.time() - start_time
print(f"Time taken to load lcc: {elapsed:.2f} seconds")

print('loading mcc...')
dsmcc = xr.open_mfdataset(sorted(glob.glob('./sfc_dt1h/mcc/mcc_202*.nc')), decode_coords=False)
mcc = dsmcc.mcc.sel(longitude=300, latitude=-3).rename({'valid_time': 'time'}).compute()
elapsed = time.time() - start_time
print(f"Time taken to load mcc: {elapsed:.2f} seconds")

print('loading hcc...')
dshcc = xr.open_mfdataset(sorted(glob.glob('./sfc_dt1h/hcc/hcc_202*.nc')), decode_coords=False)
hcc = dshcc.hcc.sel(longitude=300, latitude=-3).rename({'valid_time': 'time'}).compute()
elapsed = time.time() - start_time
print(f"Time taken to load hcc: {elapsed:.2f} seconds")

print('loading tcc...')
dstcc = xr.open_mfdataset(sorted(glob.glob('./sfc_dt1h/tcc/tcc_202*.nc')), decode_coords=False)
tcc = dstcc.tcc.sel(longitude=300, latitude=-3).rename({'valid_time': 'time'}).compute()
#tcc = tcc.sel(time=slice(None, '2025-06-30')).compute()
elapsed = time.time() - start_time
print(f"Time taken to load tcc: {elapsed:.2f} seconds")

# Combine the four DataArrays into a single Dataset
print("creating new dataset")
ds = xr.Dataset({
    'lcc': lcc,
    'mcc': mcc,
    'hcc': hcc,
    'tcc': tcc
})

# Save the Dataset to a NetCDF file
print("saving to netcdf")
ds.to_netcdf('cloudcover_ATTO_ERA5_combined.nc')
elapsed = time.time() - start_time
print(f"Total time taken: {elapsed:.2f} seconds")

#
