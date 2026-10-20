#!/opt/miniconda3/envs/geo/bin/python

import cdsapi

c = cdsapi.Client()

c.retrieve("reanalysis-era5-single-levels",
{
"product_type": ["reanalysis"],
"time": ["00:00", "01:00", "02:00", "03:00", "04:00", "05:00", 
         "06:00", "07:00", "08:00", "09:00", "10:00", "11:00", 
         "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", 
         "18:00", "19:00", "20:00", "21:00", "22:00", "23:00", ],
"data_format": "netcdf",
"download_format": "unarchived",
"variable": ["high_cloud_cover"],
"year": ["2022"],
"month": ["1"],
"day": ["1"],
},
"example_hcc_2022_hourly.nc")
