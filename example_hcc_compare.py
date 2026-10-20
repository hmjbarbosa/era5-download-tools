import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

plt.ion()

# CORRECT DATASET, BUT WRONG PRODUCT AND NO TIME 
# ERA5 API RETURNS DATA ACCORDING TO PRODUCT, WITHOUT ANY WARNINGS
#                  DATA AT 12:00 INSTEAD OF ERROR FOR MISSING HOUR
#
ds_bad = xr.open_dataset('example_hcc_2022_mmeans_bad.nc')

# CORRECT DATASET, CORRECT PRODUCT AND TIME
#
ds_good = xr.open_dataset('example_hcc_2022_mmeans_good.nc')

# REFERENCE DATASET (HOURLY DATA)
ds_hour = xr.open_dataset('example_hcc_2022_hourly.nc')

# ============ First plot, just the BAD data
# Note how the cloud fraction is just "0" or "1", without intermediate values. 
# This is clearly a single time-step, and not a monthly average. 
plt.figure(1, clear=True)
p = ds_bad["hcc"].isel(valid_time=0).plot(
    subplot_kws={"projection": ccrs.PlateCarree()},
    transform=ccrs.PlateCarree())
p.axes.coastlines(resolution="110m", color="black", linewidth=1)
p.axes.gridlines(draw_labels=True, dms=True, x_inline=False, y_inline=False)

# ============ Second plot, just the GOOD data
# Note how the cloud fraction vary smoothly between 0 and 1
plt.figure(2, clear=True)
p = ds_good["hcc"].isel(valid_time=0).plot(
    subplot_kws={"projection": ccrs.PlateCarree()},
    transform=ccrs.PlateCarree())
p.axes.coastlines(resolution="110m", color="black", linewidth=1)
p.axes.gridlines(draw_labels=True, dms=True, x_inline=False, y_inline=False)

# ============ Thirs plot, try to find out which 1-hour time corresponds to the bad data
# Note the perfect match between the "bad" data and the 1-hour data for time=12:00
fig, axs = plt.subplots(4, 4, figsize=(10, 6), num=3)
for hour, ax in enumerate(axs.flat):
    ax.pcolormesh((ds_bad["hcc"].isel(valid_time=0) - ds_hour["hcc"].isel(valid_time=hour)).values)
    ax.set_title(f'{hour} h')

