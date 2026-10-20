#!/usr/bin/ksh
# This script downloads monthly means era5-pressure-levels
#   - one variable per file, for a list of variables
#   - one month per file, for a range of dates
#   - selected levels
#   - selected hours of the day

typeset -Z4 yy
typeset -Z2 mm

#for VAR in q t u v z w ur ; do
for VAR in u v z w t q pvor rvor ; do

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

yy=1991
mm=1
while [[ $((yy*100+mm)) -le 199112 ]]; do
    
    TAG="lev17_mmeans"

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

cat <<EOF > pullmonth_${VAR}$yy$mm.py
#!/opt/miniconda3/envs/geo/bin/python

import cdsapi

c = cdsapi.Client()

c.retrieve("reanalysis-era5-pressure-levels-monthly-means",
{
"product_type": ["reanalysis"],
"data_format": "netcdf",
"download_format": "unarchived",
"variable": ["${PARAM}"],
"pressure_level": [
     "10",  "50", "100", "200", "300", 
    "500", "700", "750", "800", "825", 
    "850", "875", "900", "925", "950", 
    "975", "1000",
],
"year": ["${yy}"],
"month": ["${mm}"],
},
"${TARGET}")
EOF

    if [[ ! -e $TARGET ]]; then
        echo "===================================================================="
        echo "YEAR=$yy"
        echo "MONTH=$mm"
        chmod a+x pullmonth_${VAR}$yy$mm.py
        ./pullmonth_${VAR}$yy$mm.py
    else
        rm pullmonth_${VAR}$yy$mm.py
    fi
    
    ((mm++))
    if [[ $mm -gt 12 ]] ; then
        ((yy++))
        mm=1
    fi
done
done

exit

