'reinit'
'set display color white'
'set mpdset brmap_hires'

lev.1=850
lev.2=900
lev.3=950

i=1
while (i<=3)
  'sdfopen u/u'lev.i'_2018_aug_to_nov.nc4'
  'sdfopen v/v'lev.i'_2018_aug_to_nov.nc4'


  p.1='time=0z28aug2018,time=12z28sep2018'
  p.2='time=12z28sep2018,time=12z5nov2018'

  j=1
  while  (j<=2)

    'clear'
    'set grads off'
    'set grid off'
    'set lev 'lev.i
    'set lat -30 0'
    'set gxout shaded'
    'd mag(ave(u.1,'p.j'), ave(v.2,'p.j'))'
    'cbarn'
    'set gxout vector'
    'd ave(u.1,'p.j');skip(ave(v.2,'p.j'),3)'
    'set ccolor 2'
    'drawmark 3 -67.8076 -9.974 0.2'
    'draw title 'lev.i' hPa'
    'printim era5_winds_'lev.i'hpa_period'j'.png png x1100 y850'

    j=j+1
  endwhile

  'close 2'
  'close 1'

  i=i+1
endwhile
*