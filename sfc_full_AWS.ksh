#!/usr/bin/ksh 

typeset -Z4 yy
typeset -Z2 mm
set -A monlen 0 31 28 31 30 31 30 31 31 30 31 30 31

base='https://nsf-ncar-era5.s3.amazonaws.com/e5.oper.an.sfc/'

#for VAR in t2m td2m tcwv cbh lcc tclw ; do 
for VAR in mcc ; do 

PARAM="none"

if [[ $VAR == "10u"   ]] ; then  CODE="165"; PARAM='10m_u_component_of_wind'; fi
if [[ $VAR == "10v"   ]] ; then  CODE="166"; PARAM='10m_v_component_of_wind'; fi
if [[ $VAR == "blh"   ]] ; then  CODE="159"; PARAM='boundary_layer_height'; fi
if [[ $VAR == "sp"    ]] ; then  CODE="134"; PARAM='surface_pressure'; fi
if [[ $VAR == "tcwv"  ]] ; then  CODE="137"; PARAM='total_column_water_vapour'; fi
if [[ $VAR == "2d"    ]] ; then  CODE="168"; PARAM="2m_dewpoint_temperature"; fi
if [[ $VAR == "2t"    ]] ; then  CODE="167"; PARAM="2m_temperature"; fi

if [[ $VAR == "cbh"   ]] ; then  CODE=""; PARAM="cloud_base_height"; fi
if [[ $VAR == "lcc"   ]] ; then  CODE="186"; PARAM="low_cloud_cover"; fi
if [[ $VAR == "mcc"   ]] ; then  CODE="187"; PARAM="medium_cloud_cover"; fi
if [[ $VAR == "hcc"   ]] ; then  CODE="188"; PARAM="high_cloud_cover"; fi
if [[ $VAR == "tcc"   ]] ; then  CODE="164"; PARAM="total_cloud_cover"; fi
if [[ $VAR == "tclw"  ]] ; then  CODE="078"; PARAM="total_column_cloud_liquid_water"; fi

if [[ $VAR == "tprec" ]] ; then  CODE=""; PARAM="total_precipitation"; fi

if [[ $VAR == "tnsr"  ]] ; then  CODE=""; PARAM="top_net_solar_radiation"; fi
if [[ $VAR == "tnsrc" ]] ; then  CODE=""; PARAM="top_net_solar_radiation_clear_sky"; fi
if [[ $VAR == "tntr"  ]] ; then  CODE=""; PARAM="top_net_thermal_radiation"; fi
if [[ $VAR == "tntrc" ]] ; then  CODE=""; PARAM="top_net_thermal_radiation_clear_sky"; fi

if [[ $PARAM == "none" ]] ; then echo "variable '$VAR' is not defined!"; exit; fi

yy=2024
mm=7
while [[ $((yy*100+mm)) -le 202407 ]]; do

    mkdir -p ${VAR}
    TARGET="${VAR}/${VAR}_${yy}_${mm}.nc"
    LASTDAY=${monlen[mm]}
    bis=`expr $yy % 4`
    if [[ $mm -eq "02" && $bis -eq 0 ]]; then
        LASTDAY=29
    fi
    
    echo $TARGET" => "$LASTDAY
    FNAME="e5.oper.an.sfc.128_${CODE}_${VAR}.ll025sc.${yy}${mm}0100_${yy}${mm}${LASTDAY}23.nc" 

    if [[ ! -e $VAR/$FNAME ]] ; then
        echo "===================================================================="
        echo "YEAR=$yy"
        echo "MONTH=$mm"

	    wget "${base}${yy}${mm}/${FNAME}" -O ./${VAR}/${FNAME}
	    #ln -s ${FNAME} ${TARGET}
    fi

    ((mm++))
    if [[ $mm -gt 12 ]] ; then
        ((yy++))
        mm=1
    fi
done
done

exit

