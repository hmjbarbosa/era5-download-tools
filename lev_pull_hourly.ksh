#!/usr/bin/ksh

typeset -Z4 yy
typeset -Z2 mm
set -A monlen 0 31 28 31 30 31 30 31 31 30 31 30 31

#for VAR in q t u v z w ur ; do
for VAR in v  ; do

PARAM="none"

if [[ $VAR == "z"    ]] ; then  PARAM="geopotential" ; fi
if [[ $VAR == "q"    ]] ; then  PARAM="specific_humidity" ; fi
if [[ $VAR == "t"    ]] ; then  PARAM="temperature" ; fi
if [[ $VAR == "u"    ]] ; then  PARAM="u_component_of_wind" ; fi
if [[ $VAR == "v"    ]] ; then  PARAM="v_component_of_wind" ; fi
if [[ $VAR == "pvor" ]] ; then  PARAM="potential_vorticity"  ; fi
if [[ $VAR == "rvor" ]] ; then  PARAM="vorticity" ; fi
if [[ $VAR == "ur"   ]] ; then  PARAM="relative_humidity" ; fi
if [[ $VAR == "w"    ]] ; then  PARAM="vertical_velocity"; fi

if [[ $PARAM == "none" ]] ; then echo "$VAR is not defined!"; exit; fi

#./findproblem.ksh $VAR

yy=2014
mm=1
while [[ $((yy*100+mm)) -le 201512 ]]; do
    
    TAG="lev4_dt6h"

    mkdir -p ${TAG}/${VAR}
    TARGET="${TAG}/${VAR}/${VAR}_${yy}_${mm}_${TAG}.nc"
    echo $TARGET

# most levels
#    '1', '2', '3', '5', '7', '10', '20', '30', '50',
#    '70', '100', '125', '150', '175', '200',
#    '225', '250', '300', '350', '400', '450',
#    '500', '550', '600', '650', '700', '750',
#    '775', '800', '825', '850', '875', '900',
#    '925', '950', '975', '1000',

# 17 levels
#     '10',  '50', '100', '200', '300', 
#    '500', '700', '750', '800', '825', 
#    '850', '875', '900', '925', '950', 
#    '975', '1000',

# 4 levels
#    "200", "500", 
#    "850", "950", 

# all times
#    '00:00', '01:00', '02:00','03:00', '04:00', '05:00',
#    '06:00', '07:00', '08:00','09:00', '10:00', '11:00',
#    '12:00', '13:00', '14:00','15:00', '16:00', '17:00',
#    '18:00', '19:00', '20:00','21:00', '22:00', '23:00',
#

#'area': [15, -90, -60, -30, ],

cat <<EOF > pull_${VAR}$yy$mm.py
#!/opt/miniconda3/envs/geo/bin/python

import cdsapi

c = cdsapi.Client()

c.retrieve("reanalysis-era5-pressure-levels",
{
"product_type": ["reanalysis"],
"data_format": "netcdf",
"download_format": "unarchived",
"variable": ["${PARAM}"],
"pressure_level": [
    "200", "500", 
    "850", "950", 
],
"year": ["${yy}"],
"month": ["${mm}"],
"day": [f"{d:02d}" for d in range(1, 32)],
"time": [
    "00:00", 
    "06:00", 
    "12:00", 
    "18:00", 
],
},
"${TARGET}")
EOF
exit

    if [[ ! -e $TARGET ]]; then
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

