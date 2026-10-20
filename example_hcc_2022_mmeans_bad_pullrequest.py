#!/opt/miniconda3/envs/geo/bin/python

import cdsapi

c = cdsapi.Client()

# This shows the problem with the API. 
#
# Dataset is "reanalysis-era5-single-levels-monthly-means"
# Product type is wrongly set to "reanalysis", without a "time" specification
#
# The ideal behaviout would be for the API to issue an error, since
# there is no "renalysis" product in the "monthly means" dataset... and 
# the "time" is missing 
# 
# However, it finishes without a warning, and the returned data is
# not even a monthly-means... it is the 12Z of day 1st of the 
# hourly data. 
#
c.retrieve("reanalysis-era5-single-levels-monthly-means",
{
"product_type": ["reanalysis"],
"data_format": "netcdf",
"download_format": "unarchived",
"variable": ["high_cloud_cover"],
"year": ["2022"],
"month": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
},
"example_hcc_2022_mmeans_bad.nc")
