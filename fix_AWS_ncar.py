import numpy as np
import xarray as xr
import time

# NOTE: metadata in the AWS files changed from Nov-2024 to Dec-2024, likely because
# of the different NCO versions used (5.1.9 vs 5.3.1). This causes 
# issues with xarray reading and merging multiple files with open_mfdataset. 

def _fix_quantized(ds):
    """Normalize/drop quantization metadata that differs between files.

    - Drop short char/string variables like 'quantization_info' or 'quantization'
    - Remove differing quantization attributes from data variables
    """
    for q in ('quantization_info'):
        if q in ds:
            try:
                ds = ds.drop_vars(q)
            except Exception:
                pass

    for v in list(ds.data_vars):
        for a in ('QuantizeBitGroomNumberOfSignificantDigits', 'quantization_nsd', 'quantization'):
            if a in ds[v].attrs:
                try:
                    del ds[v].attrs[a]
                except Exception:
                    pass

    return ds


# default dask chunking to avoid eager loads
dask_chunks = {'time': 24}

oct = 'mcc/e5.oper.an.sfc.128_187_mcc.ll025sc.2024100100_2024103123.nc'
nov = 'mcc/e5.oper.an.sfc.128_187_mcc.ll025sc.2024110100_2024113023.nc'
dec = 'mcc/e5.oper.an.sfc.128_187_mcc.ll025sc.2024120100_2024123123.nc'
jan = 'mcc/e5.oper.an.sfc.128_187_mcc.ll025sc.2025010100_2025013123.nc'

print('old files...')
start_time = time.time()
ds = xr.open_mfdataset([oct, nov])
mcc = ds.MCC.sel(longitude=300, latitude=-3).compute()
elapsed = time.time() - start_time
print(f"Time to read old files: {elapsed:.2f} seconds")

print('new files...')
start_time = time.time()
ds = xr.open_mfdataset([dec, jan])
mcc = ds.MCC.sel(longitude=300, latitude=-3).compute()
elapsed = time.time() - start_time
print(f"Time to read new files: {elapsed:.2f} seconds")

# print('mixed files...')
# start_time = time.time()
# ds = xr.open_mfdataset([nov, dec])
# mcc = ds.MCC.sel(longitude=300, latitude=-3).compute()
# elapsed = time.time() - start_time
# print(f"Time to read mixed files: {elapsed:.2f} seconds")

# print('mixed files, solution 1...')
# start_time = time.time()
# ds = xr.open_mfdataset([nov, dec], 
#                         preprocess=_fix_quantized)
# mcc = ds.MCC.sel(longitude=300, latitude=-3).compute()
# elapsed = time.time() - start_time
# print(f"Time to read mixed files, solution 1: {elapsed:.2f} seconds")
# 69s

# print('mixed files, solution 2...')
# start_time = time.time()
# ds = xr.open_mfdataset([nov, dec], 
#                         preprocess=_fix_quantized,
#                         combine='nested', 
#                         concat_dim='time')
# mcc = ds.MCC.sel(longitude=300, latitude=-3).compute()
# elapsed = time.time() - start_time
# print(f"Time to read mixed files, solution 2: {elapsed:.2f} seconds")
# 1.7s

# print('mixed files, solution 3...')
# start_time = time.time()
# ds = xr.open_mfdataset([nov, dec], 
#                         combine='nested', 
#                         concat_dim='time')
# mcc = ds.MCC.sel(longitude=300, latitude=-3).compute()
# elapsed = time.time() - start_time
# print(f"Time to read mixed files, solution 3: {elapsed:.2f} seconds")
# 1.63s

print('mixed files, solution 4...')
start_time = time.time()
ds = xr.open_mfdataset([nov, dec], 
                        combine='nested', 
                        concat_dim='time', 
                        data_vars='minimal', 
                        coords='minimal',
                        compat='no_conflicts')
mcc = ds.MCC.sel(longitude=300, latitude=-3).compute()
elapsed = time.time() - start_time
print(f"Time to read mixed files, solution 4: {elapsed:.2f} seconds")
# 1.63s


#                         preprocess=_fix_quantized,
#                         combine='nested', 
#                         concat_dim='time', 
#                         data_vars='minimal', 
#                         coords='minimal',
#                         compat='no_conflicts')



