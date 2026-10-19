
'reinit'
rc=gsfallow('on')
'set display color white'
'clear'
'set mpdset mres'
'set map 1 1 6'

*'open qv/qv.ctl'
*'open chuva/chuva.ctl'
'sdfopen tprec/tprec_2023_09.nc'

'set rgb 19  69  70  79'
'set rgb 20  30 138  16'
'set rgb 21  35 147  89' 
'set rgb 22  44 184  53'
'set rgb 23 114 214   0' 
'set rgb 24 190 232   0'
'set rgb 25 253 250   0'
'set rgb 26 250 203   0'
'set rgb 27 250 159   0'
'set rgb 28 247  36   0'
'set rgb 29 202  28   0'
'set rgb 30 156  19   0'

clevs='0.1 0.2 0.3 0.5 1.0 2.0 3.0 5.0 10 20 50'
ccols='19 20 21 22 23 24 25 26 27 28 29 30'

'set gxout grfill'
'!mkdir -p anim3/prec'

'set mproj orthogr'
'set lat -90 90'
clon=-60

t=1
*while (t<=30685)
while (t<=1)
  'clear'
  'set lon 'clon-90' 'clon+90''
  'set t 't
  'q time'
  wrd=subwrd(result,3)
  x=substr(wrd,6,7)

  'set xlint 60'; 'set ylint 30'; 'set grads off'; 'set grid off'
  'set ccols 'ccols
  'set clevs 'clevs
*  'd (tp-tp(t-1))*1e3/3'
  'd tp*1e3'
  'draw title 'wrd', Precip (mm/hr)'
  'cbarn'

  x=math_format('%03.0f',t)
  'printim anim3/prec/prec_'x'.png png'
  '!mogrify -trim +repage anim3/prec/prec_'x'.png '
  t=t+1
endwhile

*

