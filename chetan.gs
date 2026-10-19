reinit

'sdfopen t2m/t2m_2014_12.nc'
'sdfopen td2m/td2m_2014_12.nc'

'set lat -20 10'
'set lon -80 -30'
'set time 0z16dec2014 0z27dec2014'

'set mpdset brmap_hires'
'set gxout grfill'

* temperature in C
'tc = t2m.1-273.15'
'tcd = d2m.2 - 273.15'

* vapor pressure hPa
'esat=6.112*exp(17.62*tc/(243.12 + tc))'

* relative humidity
'RH = 100 * exp(17.625 *tcd/(243.04 + tcd))/exp(17.625 *tc/(243.04 + Tc))'

* specific humidity
'q=RH*esat*100/100/t2m.1/461.5*1000'

'set lat -3.21'
'set lon -60.59'

'set t 361 384'
'qm=mean(q, t+0, t=625, 24)'
'tm=mean(tc, t+0, t=625, 24)'
'tdm=mean(tcd, t+0, t=625, 24)'
'rhm=mean(RH, t+0, t=625, 24)'

'set vrange 22 35'
'set vrange 60 100'
day=16
while(day<=26)
  'set line 2 3 4'
  'set time 0z'day'dec2014 23z'day'dec2014'
  'd rh'
  day=day+1
endwhile

'set t 361 384'

*'d qm'


