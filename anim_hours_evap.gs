
'reinit'
rc=gsfallow('on')
'set display color white'
'clear'
'set mpdset mres'
'set map 1 1 6'

'open u/u.ctl'
'open v/v.ctl'
'open chuva/chuva.ctl'

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

'colors  6  75  75  75 255 255 255 20'
'colors  6 255 255 255  70  140 230 25'

clevs='0.1 0.2 0.3 0.5 0.7 1.0 2.0 3.0 5.0   7  10 '
ccols=' 20  21  22  23  24  25  26  27  28  29  30  31'

'set gxout grfill'
'!mkdir -p anim3/evap'
t=30685
*while (t<=30685)
while (t<=30801)
  'clear'
  'set t 't
  'q time'
  wrd=subwrd(result,3)
  x=substr(wrd,6,7)

  'set xlint 60'; 'set ylint 30'; 'set grads off'; 'set grid off'
  'set ccols 'ccols
  'set clevs 'clevs
  'd -(e.3-e.3(t-1))*1e3*8'
  'draw title 'wrd', Evap (mm/day)'
  'cbarn'

  'set arrscl 0.5 30'
  'set arrlab off'
  'd maskout(u.1,mag(u.1,v.2)-5);skip(v.2,5)'

  x=math_format('%03.0f',t)
  'printim anim3/evap/evap_'x'.png png'
  '!mogrify -trim +repage anim3/evap/evap_'x'.png '
  t=t+1
endwhile

*

