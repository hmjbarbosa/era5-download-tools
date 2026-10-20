#!/opt/miniconda3/envs/geo/bin/python

import argparse
import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import numpy as np

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

    return(p)


def plotVcross(da, yscale='linear'):
    '''Plot a vertical crossection of a DataArray.'''

    level = find_dimension(da, 'level')
    horizontal = next(dim for dim in da.dims if dim != level)
    p = da.plot(x=horizontal, y=level)

    orient_vertical(p.axes, da[level])
    p.axes.set_yscale(yscale)

    return(p)


def orient_vertical(axes, coordinate):
    """Pressure increases downward; height increases upward."""
    units = str(coordinate.attrs.get('units', '')).lower()
    pressure = (coordinate.name in ('pressure_level', 'isobaricInhPa')
                or units in ('pa', 'hpa', 'mbar', 'millibar')
                or (coordinate.name in ('level', 'lev') and not units))
    downward = coordinate.attrs.get('positive', '').lower() == 'down'
    low, high = float(coordinate.min()), float(coordinate.max())
    axes.set_ylim((high, low) if pressure or downward else (low, high))


def plotHov(da, yscale='linear'):
    """Plot time on x and the remaining spatial coordinate on y."""
    time = find_dimension(da, 'time')
    spatial = next(dim for dim in da.dims if dim != time)
    p = da.plot(x=time, y=spatial)
    if spatial == find_dimension(da, 'level'):
        orient_vertical(p.axes, da[spatial])
        p.axes.set_yscale(yscale)
    return p


DIMENSIONS = {
    'time': ('time', 'valid_time', 'start_time', 'datetime'),
    'level': ('level', 'lev', 'pressure', 'plev', 'height', 'altitude', 'z'),
    'latitude': ('degrees_north', 'latitude', 'lat'),
    'longitude': ('degrees_east', 'longitude', 'lon'),
}


def find_dimension(da, kind):
    """Find a dimension name, ignoring capitalization."""
    for name in da.dims:
        if name.lower() in DIMENSIONS[kind]:
            return name
    return None

def validate_plot_data(da, plot):
    """Validate the remaining dimensions and order map axes."""
    dimensions = {kind: find_dimension(da, kind) for kind in DIMENSIONS}

    # Singleton dimensions need no explicit selector, unless they are plot axes.
    required = {'map': ('latitude', 'longitude'), 'vcr': ('level',), 'hov': ('time',)}[plot]
    for kind in required:
        if dimensions[kind] is None or dimensions[kind] not in da.dims:
            raise ValueError(f'{plot} requires an unselected {kind} dimension')
    protected = {dimensions[kind] for kind in required}
    for dim in list(da.dims):
        if da.sizes[dim] == 1 and dim not in protected:
            da = da.isel({dim: 0})
    remaining = {kind for kind, dim in dimensions.items() if dim in da.dims}
    valid = (remaining == {'latitude', 'longitude'} if plot == 'map' else
             remaining in ({'level', 'latitude'}, {'level', 'longitude'}) if plot == 'vcr' else
             remaining in ({'time', 'latitude'}, {'time', 'longitude'}, {'time', 'level'}))
    if da.ndim != 2 or not valid:
        raise ValueError(
            f'{plot} needs exactly two plot dimensions; remaining: {da.dims}. '
            'Fix other dimensions using -t/-z/-y/-x (indices) '
            'or --time/--level/--lat/--lon (coordinates).'
        )
    if any(size < 2 for size in da.sizes.values()):
        raise ValueError('Each plotted dimension must contain at least two points')
    if plot == 'map':
        da = da.transpose(dimensions['latitude'], dimensions['longitude'])
    return da


def main(argv=None):
    
    parser = argparse.ArgumentParser(
        description='Plot two NetCDF dimensions as a map, vertical cross-section, or Hovmoller diagram.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='Examples:\n'
               '  gplots.py data.nc\n'
               '  gplots.py data.nc -v t -t 2 -z 3\n'
               '  gplots.py data.nc --time "2022-07-01T12:00:00" --level 850\n'
               '  gplots.py data.nc -v t --vcr -t 0 --lat -3\n'
               '  gplots.py data.nc -v t --hov --lat -3 -z 0\n'
               '  gplots.py data.nc -v t --hov --lat -3 --lon 300\n'
               '  gplots.py data.nc --output map.png',
    )
    # Filename 
    parser.add_argument('filename', help='NetCDF file to open')

    # Variable name
    parser.add_argument('-v', '--variable', dest='var', help='Data variable (default: first in file)')

    # Time
    time_group = parser.add_mutually_exclusive_group()
    time_group.add_argument('-t', dest='itime', type=int,
                            help='Fix time index')
    time_group.add_argument('--time', dest='time', type=np.datetime64,
                            help='Fix time using a string, e.g. "2022-07-01T12:00:00"')

    # Vertical
    level_group = parser.add_mutually_exclusive_group()
    level_group.add_argument('-z', dest='ilevel', type=int,
                             help='Fix vertical coordinate index')
    level_group.add_argument('--level', dest='level', type=float,
                             help='Fix vertical coordinate using units, e.g. "850" with file units in hPa')

    # North
    latitude_group = parser.add_mutually_exclusive_group()
    latitude_group.add_argument('-y', dest='ilat', type=int,
                                help='Fix latitude index')
    latitude_group.add_argument('--lat', dest='lat', type=float,
                                help='Fix latitude in degrees north')

    # East
    longitude_group = parser.add_mutually_exclusive_group()
    longitude_group.add_argument('-x', dest='ilon', type=int,
                                 help='Fix longitude index')
    longitude_group.add_argument('--lon', dest='lon', type=float,
                                 help='Fix longitude in degrees east')

    # Plot type
    plots = parser.add_mutually_exclusive_group()
    plots.add_argument('--map', dest='plottype', action='store_const', const='map', 
                       help='Map with projection and borders (lon x lat)')
    plots.add_argument('--vcr', dest='plottype', action='store_const', const='vcr', 
                       help='Vertical cross-section (lat/lon x level)')
    plots.add_argument('--hov', dest='plottype', action='store_const', const='hov', 
                       help='Hovmoller diagram (lev/lat/lon x time)')
    parser.set_defaults(plottype='map')

    # axis scales
    parser.add_argument('--xlog', dest='xlog', action='store_const', const=True,
                        help='X-axis scale in log')
    parser.set_defaults(xlog=False)
    parser.add_argument('--ylog', dest='ylog', action='store_const', const=True,
                        help='Y-axis scale in log')
    parser.set_defaults(ylog=False)

    # print
    parser.add_argument('-o', '--output', help='Save figure to this path instead of opening a window')
    args = parser.parse_args(argv)

    try:
        # try to open the file
        with xr.open_dataset(args.filename) as ds:

            # gets either the user's variable, or the first on the file
            variable = args.var or next(iter(ds.data_vars))

            # check if the user variable exists
            if variable not in ds.data_vars:
                raise ValueError(f"Unknown variable {variable!r}; available: {', '.join(ds.data_vars)}")

            # select the variable, and find the 4-Dimensions
            da = ds[variable]
            time = find_dimension(da, 'time')
            level = find_dimension(da, 'level')
            lat = find_dimension(da, 'latitude')
            lon = find_dimension(da, 'longitude')

            # Apply each requested index or coordinate selection directly.
            if args.itime is not None:
                da = da.isel({time: args.itime})
            if args.time is not None:
                da = da.sel({time: args.time}, method='nearest')
            if args.ilevel is not None:
                da = da.isel({level: args.ilevel})
            if args.level is not None:
                da = da.sel({level: args.level}, method='nearest')
            if args.ilat is not None:
                da = da.isel({lat: args.ilat})
            if args.lat is not None:
                da = da.sel({lat: args.lat}, method='nearest')
            if args.ilon is not None:
                da = da.isel({lon: args.ilon})
            if args.lon is not None:
                da = da.sel({lon: args.lon}, method='nearest')

            # Maps default to the first time and level only when unspecified.
            if args.plottype == 'map':
                if time is not None and args.itime is None and args.time is None:
                    da = da.isel({time: 0})
                if level is not None and args.ilevel is None and args.level is None:
                    da = da.isel({level: 0})

            da = validate_plot_data(da, args.plottype).load()
            if args.plottype == 'map':
                p = plot2Dmap(da)
            elif args.plottype == 'vcr':
                p = plotVcross(da)
            else:
                p = plotHov(da)

            # apply log-scale to the axis, if asked
            if args.xlog:
                p.axes.set_xscale('log')
            if args.ylog:
                p.axes.set_yscale('log')

            # print the figure, if asked
            if args.output:
                p.figure.savefig(args.output, dpi=150, bbox_inches='tight')
                plt.close(p.figure)
            else:
                plt.show(block=True)

    except (OSError, ValueError, KeyError, IndexError) as exc:
        parser.error(str(exc))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
