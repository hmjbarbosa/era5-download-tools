#!/usr/bin/ksh 
# This script downloads hourly era5-single-levels
#   - one variable per file, for a list of variables
#   - one month per file, for a range of dates
#   - all 24 hours of the day

typeset -Z4 yy
typeset -Z2 mm

#for VAR in t2m td2m sp u10m v10m cbh ; do 
#for VAR in tnsr tnsrc tntr tntrc ; do 
#for VAR in viwve viwvn vimd ; do 
#for VAR in tcc tcwv blh tclw ; do 
for VAR in hcc lcc mcc tprec ; do 

PARAM="none"

if [[ $VAR == "u10"  ]]  ; then  PARAM='10m_u_component_of_wind'; fi
if [[ $VAR == "v10"  ]]  ; then  PARAM='10m_v_component_of_wind'; fi
if [[ $VAR == "blh"   ]]  ; then  PARAM='boundary_layer_height'; fi
if [[ $VAR == "sp"    ]]  ; then  PARAM='surface_pressure'; fi
if [[ $VAR == "tcwv"  ]]  ; then  PARAM='total_column_water_vapour'; fi
if [[ $VAR == "d2m"  ]]  ; then  PARAM="2m_dewpoint_temperature"; fi
if [[ $VAR == "t2m"   ]]  ; then  PARAM="2m_temperature"; fi

if [[ $VAR == "cbh"  ]] ; then  PARAM="cloud_base_height"; fi
if [[ $VAR == "lcc"  ]] ; then  PARAM="low_cloud_cover"; fi
if [[ $VAR == "mcc"  ]] ; then  PARAM="medium_cloud_cover"; fi
if [[ $VAR == "hcc"  ]] ; then  PARAM="high_cloud_cover"; fi
if [[ $VAR == "tcc"  ]] ; then  PARAM="total_cloud_cover"; fi
if [[ $VAR == "tclw" ]] ; then  PARAM="total_column_cloud_liquid_water"; fi

if [[ $VAR == "tp"  ]] ; then  PARAM="total_precipitation"; fi

if [[ $VAR == "tsr"   ]] ; then  PARAM="top_net_solar_radiation"; fi
if [[ $VAR == "tsrc"  ]] ; then  PARAM="top_net_solar_radiation_clear_sky"; fi
if [[ $VAR == "ttr"   ]] ; then  PARAM="top_net_thermal_radiation"; fi
if [[ $VAR == "ttrc"  ]] ; then  PARAM="top_net_thermal_radiation_clear_sky"; fi

if [[ $VAR == "viwve"  ]] ; then  PARAM="vertical_integral_of_eastward_water_vapour_flux"; fi
if [[ $VAR == "viwvn"  ]] ; then  PARAM="vertical_integral_of_northward_water_vapour_flux"; fi
if [[ $VAR == "vimd"  ]] ; then  PARAM="vertically_integrated_moisture_divergence"; fi

if [[ $PARAM == "none" ]] ; then echo "variable '$VAR' is not defined!"; exit; fi

yy=2014
mm=1
while [[ $((yy*100+mm)) -le 201512 ]]; do

    TAG="sfc_dt1h"

    mkdir -p ${TAG}/${VAR}
    TARGET="${TAG}/${VAR}/${VAR}_${yy}_${mm}_${TAG}.nc"
    echo $TARGET
    
    echo $TARGET


cat <<EOF > pull_${VAR}$yy$mm.py
#!/opt/miniconda3/envs/geo/bin/python

import cdsapi

c = cdsapi.Client()

c.retrieve("reanalysis-era5-single-levels",
{
"product_type": ["reanalysis"],
"data_format": "netcdf",
"download_format": "unarchived",
"variable": ["${PARAM}"],
"year": ["${yy}"],
"month": ["${mm}"],
"day": [f"{d:02d}" for d in range(1, 32)],
"time": [
    "00:00", "01:00", "02:00","03:00", "04:00", "05:00",
    "06:00", "07:00", "08:00","09:00", "10:00", "11:00",
    "12:00", "13:00", "14:00","15:00", "16:00", "17:00",
    "18:00", "19:00", "20:00","21:00", "22:00", "23:00",
],
},
"${TARGET}")
EOF
#'area': [15, -90, -60, -30, ],

    if [[ ! -e $TARGET ]] ; then
        echo "===================================================================="
        echo "YEAR=$yy"
        echo "MONTH=$mm"
    
	     chmod a+x pull_${VAR}$yy$mm.py
	     ./pull_${VAR}$yy$mm.py
    else
	     rm pull_${VAR}$yy$mm.py
    fi

    ((mm++))
    if [[ $mm -gt 12 ]] ; then
        ((yy++))
        mm=1
    fi
done
done

exit

