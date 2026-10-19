#lats4d.sh  -i u.ctl -format netcdf4 -gzip 8 -o u850_2018_aug_to_nov -v -le -levs 850 -mxtimes 50000

lev='950'
var='v'

echo "extract level"
for m in 08 09 10 11 ; do 
    cdo sellevel,${lev} ${var}_2018_${m}.nc tmp_${m}.nc
done

echo "merge"
cdo -f nc4 -z zip_8 copy tmp_*.nc ${var}${lev}_2018_aug_to_nov.nc4
rm -f tmp_*.nc

echo "day mean"
cdo daymean    ${var}${lev}_2018_aug_to_nov.nc4 temp.nc4

echo "fix time"
cdo -f nc4 -z zip_8 shifttime,-23hours temp.nc4 ${var}${lev}_2018_aug_to_nov_daily.nc4
rm -f temp.nc4

#
