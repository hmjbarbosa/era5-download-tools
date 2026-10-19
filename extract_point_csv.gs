'reinit'
'set display color white'
'set mpdset brmap_hires'

lev.1=850
lev.2=900
lev.3=950

'sdfopen u/u850_2018_aug_to_nov.nc4'
'sdfopen v/v850_2018_aug_to_nov.nc4'
'sdfopen u/u900_2018_aug_to_nov.nc4'
'sdfopen v/v900_2018_aug_to_nov.nc4'
'sdfopen u/u950_2018_aug_to_nov.nc4'
'sdfopen v/v950_2018_aug_to_nov.nc4'

'set lon -67.8076'
'set lat  -9.974'
'set t 1 last'
'q dims'
lin=sublin(result,5)
t1=subwrd(lin,11)
t2=subwrd(lin,13)

rc=write('winds_era5.csv','yyy,mm,dd,HH,u850,v850,u900,v900,u950,v950')

t=t1
while(t<=t2)

  'set t 't
  tmp=subwrd(result,4)

  out=strrep(tmp,':',',')

  'd u.1(z=1)'; out=out','subwrd(result,4)
  'd v.2(z=1)'; out=out','subwrd(result,4)
  'd u.3(z=1)'; out=out','subwrd(result,4)
  'd v.4(z=1)'; out=out','subwrd(result,4)
  'd u.5(z=1)'; out=out','subwrd(result,4)
  'd v.6(z=1)'; out=out','subwrd(result,4)

  rc=write('winds_era5.csv',out,1)

  rc=math_mod(t,100)
  if (rc=0)
    say t' / 't2
  endif

  t=t+1
endwhile

function strrep(inword,oldc,newc)

outword=''

i=0
while (1)
  i=i+1
  tmp=substr(inword,i,1)

  if (tmp='')
    return(outword)
  else
    if (tmp=oldc)
      outword=outword''newc
    else
      outword=outword''tmp
    endif
  endif

endwhile

*