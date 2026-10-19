import numpy as np
import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

plt.ion()

def addmap(p): 
    '''Take a plot handle p and adds geoaxis coast and grid lines.'''
    p.axes.coastlines(resolution="110m", color="black", linewidth=1)
    p.axes.gridlines(draw_labels=True, dms=True, x_inline=False, y_inline=False)


def plot2Dmap(da):
    '''Plot a 2D lat/lon map of a DataArray. '''

    p = da.plot(
        subplot_kws={"projection": ccrs.PlateCarree()},
        transform=ccrs.PlateCarree(),
    )

    p.axes.coastlines(resolution="110m", color="black", linewidth=1)
    p.axes.gridlines(draw_labels=True, dms=True, x_inline=False, y_inline=False)

    plt.show()

    return(p)


def plotVcross(da, yscale='linear'):
    '''Plot a vertical crossection of a DataArray.'''

    ylim = da.level.values[[0,-1]] # first and last levels

    p = da.plot()

    p.axes.set_ylim(ylim)
    p.axes.invert_yaxis()
    p.axes.set_yscale(yscale)

    return(p)
