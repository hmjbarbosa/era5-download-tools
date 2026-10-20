#!/opt/miniconda3/envs/geo/bin/python

import cdsapi

c = cdsapi.Client()

# This is how the monthly-means should be downloaded. 
# Product type is specified as "monthly_averaged_reanalysis"
# and time is set to the only one possible for a monthly mean: "00:00"

c.retrieve("reanalysis-era5-single-levels-monthly-means",
{
"product_type": ["monthly_averaged_reanalysis"],
"time": ["00:00"],
"data_format": "netcdf",
"download_format": "unarchived",
"variable": ["high_cloud_cover"],
"year": ["2022"],
"month": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
},
"example_hcc_2022_mmeans_good.nc")
