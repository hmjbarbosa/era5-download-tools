
'reinit'
rc=gsfallow('on')
'set display color white'
'clear'
'set mpdset mres'
'set map 1 1 6'

'open qv/qv.ctl'
*'open chuva/chuva.ctl'

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

*'colors  6 255   0   0  50  50  50 20'
'colors  6 255 161  91  10  10  10 20'
'colors  6  10  10  10 255 255 255 25'
'colors  7 255 255 255   0   0 205 30'

*clevs=' 0 5 10 15 20 25 30 35 40 45 50 55 60 65 70 '
*clevs='  0 .1 .2 .3 .5 .7  1  2  3  5  7 10 20 30 50 70'
clevs='  1  2  3  5  7 10 15 20 25 30 35 40 45 50 55 60'
ccols=' 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36'

'set gxout grfill'
*'set mproj mollweide'
'!mkdir -p anim3/pwqv'
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
  'd qt.1'
  'set arrscl 0.5 800'
  'set arrlab off'
  'd maskout(qu.1,mag(qu.1,qv.1)-100);skip(qv.1,5)'
  'draw title 'wrd', Precipitable Water (kg/m2)'
  'cbarn'

  x=math_format('%03.0f',t)
  'printim anim3/pwqv/pwqv_'x'.png png'
  '!mogrify -trim +repage anim3/pwqv/pwqv_'x'.png '
  t=t+1
endwhile

*

