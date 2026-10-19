#!/usr/bin/ksh 

typeset -Z4 yy
typeset -Z2 mm

#for VAR in t2m td2m sp u10m v10m cbh ; do 
#for VAR in tnsr tnsrc tntr tntrc ; do 
#for VAR in viwve viwvn vimd ; do 
#for VAR in tcc tcwv blh tclw ; do 
#for VAR in hcc lcc mcc tprec ; do 
for VAR in tprec  ; do 

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

yy=1991
while [[ $((yy)) -le 2020 ]]; do

    TAG="sfc_mmeans"

    mkdir -p ${TAG}/${VAR}
    TARGET="${TAG}/${VAR}/${VAR}_${yy}_${TAG}.nc"
    echo $TARGET

   # "product_type": ["monthly_averaged_reanalysis_by_hour_of_day"],
#     "product_type": ["monthly_averaged_reanalysis"],

cat <<EOF > pullyear_${VAR}$yy.py
#!/opt/miniconda3/envs/geo/bin/python

import cdsapi

c = cdsapi.Client()

c.retrieve("reanalysis-era5-single-levels-monthly-means",
{
"product_type": ["reanalysis"],
"data_format": "netcdf",
"download_format": "unarchived",
"variable": ["${PARAM}"],
"year": ["${yy}"],
"month": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
},
"${TARGET}")
EOF
#'area': [15, -90, -60, -30, ],

    if [[ ! -e $TARGET ]] ; then
        echo "===================================================================="
        echo "YEAR=$yy"
    
	     chmod a+x pullyear_${VAR}$yy.py
	     ./pullyear_${VAR}$yy.py
    else
	     rm pullyear_${VAR}$yy.py
    fi

    ((yy++))
done
done

exit

