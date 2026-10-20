#!/usr/bin/ksh 
# This script downloads monthly means era5-single-levels 
#   - one variable per file, for a list of variables
#   - one year per file, for a range of years

typeset -Z4 yy
typeset -Z2 mm

#for VAR in u10 v10 sp t2m d2m blh ; do 
#for VAR in cbh lcc mcc hcc tcc ; do 
#for VAR in tp e ro tcw tcwv tcrw tciw tclw ; do
#for VAR in tsr tsrc ttr ttrc ; do 
for VAR in viiwd viiwe viivn vilwd vilwe vilvn vimdf viwve viwvn vimd ; do 

PARAM="none"

# ground
if [[ $VAR == "u10"   ]]  ; then  PARAM="10m_u_component_of_wind"; fi
if [[ $VAR == "v10"   ]]  ; then  PARAM="10m_v_component_of_wind"; fi
if [[ $VAR == "sp"    ]]  ; then  PARAM="surface_pressure"; fi
if [[ $VAR == "d2m"   ]]  ; then  PARAM="2m_dewpoint_temperature"; fi
if [[ $VAR == "t2m"   ]]  ; then  PARAM="2m_temperature"; fi
if [[ $VAR == "blh"   ]]  ; then  PARAM="boundary_layer_height"; fi

# clouds
if [[ $VAR == "cbh"  ]] ; then  PARAM="cloud_base_height"; fi
if [[ $VAR == "lcc"  ]] ; then  PARAM="low_cloud_cover"; fi
if [[ $VAR == "mcc"  ]] ; then  PARAM="medium_cloud_cover"; fi
if [[ $VAR == "hcc"  ]] ; then  PARAM="high_cloud_cover"; fi
if [[ $VAR == "tcc"  ]] ; then  PARAM="total_cloud_cover"; fi

# water budget
if [[ $VAR == "tp"    ]] ; then  PARAM="total_precipitation"; fi
if [[ $VAR == "e"     ]] ; then  PARAM="evaporation"; fi
if [[ $VAR == "ro"    ]] ; then  PARAM="runoff"; fi
if [[ $VAR == "tcw"   ]] ; then  PARAM="total_column_water"; fi
if [[ $VAR == "tcwv"  ]] ; then  PARAM="total_column_water_vapour"; fi
if [[ $VAR == "tcrw"  ]] ; then  PARAM="total_column_rain_water"; fi
if [[ $VAR == "tciw"  ]] ; then  PARAM="total_column_cloud_ice_water"; fi
if [[ $VAR == "tclw"  ]] ; then  PARAM="total_column_cloud_liquid_water"; fi

# radiation
if [[ $VAR == "tsr"  ]] ; then  PARAM="top_net_solar_radiation"; fi
if [[ $VAR == "tsrc" ]] ; then  PARAM="top_net_solar_radiation_clear_sky"; fi
if [[ $VAR == "ttr"  ]] ; then  PARAM="top_net_thermal_radiation"; fi
if [[ $VAR == "ttrc" ]] ; then  PARAM="top_net_thermal_radiation_clear_sky"; fi

# moisture flux
if [[ $VAR == "viiwd" ]] ; then  PARAM="vertical_integral_of_divergence_of_cloud_frozen_water_flux"; fi
if [[ $VAR == "viiwe" ]] ; then  PARAM="vertical_integral_of_eastward_cloud_frozen_water_flux"; fi
if [[ $VAR == "viivn" ]] ; then  PARAM="vertical_integral_of_northward_cloud_frozen_water_flux"; fi
if [[ $VAR == "vilwd" ]] ; then  PARAM="vertical_integral_of_divergence_of_cloud_liquid_water_flux"; fi
if [[ $VAR == "vilwe" ]] ; then  PARAM="vertical_integral_of_eastward_cloud_liquid_water_flux"; fi
if [[ $VAR == "vilvn" ]] ; then  PARAM="vertical_integral_of_northward_cloud_liquid_water_flux"; fi
if [[ $VAR == "vimdf" ]] ; then  PARAM="vertical_integral_of_divergence_of_moisture_flux"; fi
if [[ $VAR == "viwve" ]] ; then  PARAM="vertical_integral_of_eastward_water_vapour_flux"; fi
if [[ $VAR == "viwvn" ]] ; then  PARAM="vertical_integral_of_northward_water_vapour_flux"; fi
if [[ $VAR == "vimd"  ]] ; then  PARAM="vertically_integrated_moisture_divergence"; fi

if [[ $PARAM == "none" ]] ; then echo "variable '$VAR' is not defined!"; exit; fi

yy=1991
while [[ $((yy)) -le 2020 ]]; do

    TAG="sfc_mmeans"

    mkdir -p ${TAG}/${VAR}
    TARGET="${TAG}/${VAR}/${VAR}_${yy}_${TAG}.nc"
    echo $TARGET

cat <<EOF > pullyear_${VAR}$yy.py
#!/opt/miniconda3/envs/geo/bin/python

import cdsapi

c = cdsapi.Client()

c.retrieve("reanalysis-era5-single-levels-monthly-means",
{
"product_type": ["monthly_averaged_reanalysis"],
"data_format": "netcdf",
"download_format": "unarchived",
"variable": ["${PARAM}"],
"year": ["${yy}"],
"month": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
"time": ["00:00"],
},
"${TARGET}")
EOF
#'area': [15, -90, -60, -30, ],

    if [[ ! -e $TARGET ]] ; then
        echo "===================================================================="
        echo "YEAR=$yy"
    
	     chmod a+x pullyear_${VAR}$yy.py
	     ./pullyear_${VAR}$yy.py
	     rm pullyear_${VAR}$yy.py
    else
	     rm pullyear_${VAR}$yy.py
    fi

    ((yy++))
done
done

exit

