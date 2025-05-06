1000  '******************************************************
1010  '                   soundcomputer
1020  '******************************************************
1030  fullw 2:clearw 2
1040  gosub init
1050  gosub maske
1060  '
1070  schleife:
1080  gosub berechnen
1090  gosub werteausgabe
1100  gosub soundausgabe
1110  gosub mausabfrage
1120  gosub bereich
1130  if a$(2,6)="stop" then goto finish
1140  goto schleife
1150  '******************************************************
1160  finish:
1170  '******************************************************
1180  wave 0,0,0,0,0
1190  groesse=10:gosub schriftgroesse
1200  mausnr=0:gosub mausform
1210  clearw 2
1220  xpos=-1:ypos=-20
1230  text$="                               "
1240  text$=text$+"                                 "
1250  gosub textausgabe
1260  xpos=-1:ypos=-24
1270  text$="   Desk  File  Run  Edit  Debug"
1280  text$=text$+"                                 "
1290  gosub textausgabe
1300  end
1310  '******************************************************
1320  maske:
1330  '******************************************************
1340  groesse=20:gosub schriftgroesse
1350  text$="                                        "
1360  xpos= -1:ypos= -6:gosub textausgabe
1370  text$="             Soundcomputer              "
1380  xpos= -1:ypos=- 9:gosub textausgabe
1390  groesse=09:gosub schriftgroesse
1400  text$="Der mausgesteuerte"
1410  xpos=  30:ypos= -15:gosub textausgabe
1420  text$="(c) by Gebr Stumm 4/1986"
1430  xpos= 430:ypos=-15:gosub textausgabe
1440  '
1450  color 1,1,1,1,2:fuell=1
1460  ypos1=10:ypos2=250
1470  for i=0 to 2
1480  xpos1=10+i*205:xpos2=xpos1+180
1490  gosub rechteckrund
1500  next
1510  xpos1=005:ypos1=260
1520  xpos2=600:ypos2=295
1530  gosub rechteckrund:
1540  color 1,1,1,6,2
1550  xpos1=005:ypos1=305
1560  xpos2=600:ypos2=340
1570  gosub rechteckrund:
1580  '
1590  groesse=19:gosub schriftgroesse
1600  ypos=40
1610  xpos= 45:text$="Kanal A":gosub textausgabe
1620  xpos=250:text$="Kanal B":gosub textausgabe
1630  xpos=455:text$="Kanal C":gosub textausgabe
1640  '
1650  groesse=10:gosub schriftgroesse
1660  for i=0 to 5
1670  ypos=80+i*30:text$=t$(i)
1680  for k=0 to 2 :xpos=25+k*205:gosub textausgabe:next
1690  next
1700  '
1710  ypos=283:for i=0 to 2
1720  xpos=25+i*205:text$=t$(i+6)
1730  gosub textausgabe:next
1740  return
1750  '******************************************************
1760  init:
1770  '******************************************************
1780  restore
1790  for ay=0 to 6 :for ax=0 to 2
1800  read a$(ax,ay)
1810  next:next
1820  for bx=0 to 7 : for by=0 to 1
1830  read b$(bx,by)
1840  next:next
1850  for i=0 to 8 : read t$(i) :next
1860  return
1870  '******************************************************
1880  werteausgabe:
1890  '******************************************************
1900  for i=0 to 2
1910  if len(a$(i,0))<2 then a$(i,0)=" "+a$(i,0)
1920  if len(a$(i,2))<2 then a$(i,2)=" "+a$(i,2)
1930  next
1940  if len(a$(0,6))<2 then a$(0,6)=" "+a$(0,6)
1950  marke:
1960  if len(a$(1,6))<5 then a$(1,6)=" "+a$(1,6):goto marke
1970  '
1980  for i=0 to 6
1990  if i=0 or i=2 then zs=0 else zs=8
2000  if i=6 then ypos=283 else ypos=80+i*30
2010  for K=0 to 2
2020  xpos=160+zs+k*205:text$=a$(k,i)
2030  gosub textausgabe:next:next
2040  '
2050  text$="sound 1,"+a$(0,0)+","+a$(0,2)+","+a$(0,1)+":"
2060  text$=text$+"sound 2,"+a$(1,0)+","+a$(1,2)+","+a$(1,1)+":"
2070  text$=text$+"sound 3,"+a$(2,0)+","+a$(2,2)+","+a$(2,1)+":"
2080  text$=text$+"wave "+str$(wa1)+","+str$(wa2)
2090  text$=text$+","+a$(0,6)+","+a$(1,6)
2100  xpos= 24:ypos=329:gosub textausgabe
2110  return
2120  '******************************************************
2130  berechnen:
2140  '******************************************************
2150  wa1$=a$(2,4)+a$(1,4)+a$(0,4)+a$(2,3)+a$(1,3)+a$(0,3):wa1=0
2160  for i=6 to 1 step -1
2170  wa1=wa1+val(mid$(wa1$,i,1))*2^(6-i)
2180  next
2190  wa2$=a$(2,5)+a$(1,5)+a$(0,5):wa2=0
2200  for i=3 to 1 step -1
2210  wa2=wa2+val(mid$(wa2$,i,1))*2^(3-i)
2220  next
2230  wa3=val(a$(0,6)):wa4=val(a$(1,6))
2240  return
2250  '******************************************************
2260  soundausgabe:
2270  '******************************************************
2280  for i=0 to 2
2290  sound i+1,val(a$(i,0)),val(a$(i,2)),val(a$(i,1))
2300  next:wave wa1,wa2,wa3,wa4
2310  return
2320  '******************************************************
2330  mausabfrage:
2340  '******************************************************
2350  mausnr=0:gosub mausform
2360  gosub showmaus
2370  loop:
2380  gosub maus
2390  if key=0 then goto loop
2400  mausnr=2:gosub mausform
2410  gosub showmaus
2420  ax=-1:ay=-1:z=1
2430  if xmaus<190 then ax=0
2440  if xmaus>190 and xmaus<407 then ax=1
2450  if xmaus>407 then ax=2
2460  for i=0 to 5
2470  y=60+i*30
2480  if ymaus>y and ymaus<y+30 then ay=i:z=1
2490  next
2500  if ymaus>260 and ymaus<290 then ay=6
2510  if ax=1 and ay=6 then z=100
2520  if ax=-1 or ay=-1 then goto mausabfrage
2530  '
2540  if key=1 then x$=str$(val(a$(ax,ay))-z)
2550  if key=2 then x$=str$(val(a$(ax,ay))+z)
2560  if left$(x$,1)="-" then x$=" "+x$
2570  a$(ax,ay)=right$(x$,len(x$)-1)
2580  if key=3 then a$(2,6)="stop" else a$(2,6)=chr$(5)
2590  return
2600  '******************************************************
2610  bereich:
2620  '******************************************************
2630  if z=100 then by=7 else by=ay
2640  if val(a$(ax,ay))<val(b$(by,0)) then a$(ax,ay)=b$(by,1)
2650  if val(a$(ax,ay))>val(b$(by,1)) then a$(ax,ay)=b$(by,0)
2660  return
2670  '------------------------------------------------------
2680  maus:
2690  '------------------------------------------------------
2700  poke contrl,124
2710  vdisys
2720  xmaus=peek(ptsout  )-1
2730  ymaus=peek(ptsout+2)-38
2740  key  =peek(intout)
2750  return
2760  '------------------------------------------------------
2770  showmaus:
2780  '------------------------------------------------------
2790  poke contrl,122
2800  poke intin,0
2810  vdisys
2820  return
2830  '------------------------------------------------------
2840  mausform:
2850  '------------------------------------------------------
2860  add#=gb
2870  gintin=peek(add#+8)
2880  addrin=peek(add#+16)
2890  poke gintin,mausnr
2900  poke addrin,0
2910  gemsys (78)
2920  return
2930  '------------------------------------------------------
2940  rechteckrund:
2950  '------------------------------------------------------
2960  poke contrl  ,11
2970  poke contrl+2,2
2980  poke contrl+6,0
2990  if fuell = 0 then poke contrl+10,8 else poke contrl+10,9
3000  poke ptsin  ,xpos1 +1
3010  poke ptsin+2,ypos1 +38
3020  poke ptsin+4,xpos2 +1
3030  poke ptsin+6,ypos2 +38
3040  vdisys
3050  return
3060  '------------------------------------------------------
3070  schriftgroesse:
3080  '------------------------------------------------------
3090  poke contrl ,107
3100  poke contrl+2,0
3110  poke contrl+6,1
3120  poke intin ,groesse
3130  vdisys
3140  return
3150  '------------------------------------------------------
3160  textausgabe:
3170  '------------------------------------------------------
3180  for ii=0 to len(text$)-1
3190  poke intin+ii*2,asc(mid$(text$,ii+1,1))
3200  next
3210  poke intin+ii*2,0
3220  poke contrl  ,8
3230  poke contrl+2,1
3240  poke contrl+6,len(text$)
3250  poke ptsin,xpos+1
3260  poke ptsin+2,ypos+38
3270  vdisys
3280  return
3290  '------------------------------------------------------
3300  'Datas fÅr Erstbelegung, Grenzwerte und Texte
3310  '------------------------------------------------------
3320  data "10","10","10"
3330  data  "4", "1", "8"
3340  data "10"," 1","12"
3350  data  "1", "0", "0"
3360  data  "0", "0", "0"
3370  data  "0", "0", "0"
3380  data "14"," 3000",""
3390  '---[CRTL-E]-------^
3400  '
3410  data " 0","15"
3420  data  "1", "8"
3430  data " 1","12"
3440  data  "0", "1"
3450  data  "0", "1"
3460  data  "0", "1"
3470  data " 0","15"
3480  data "    0","65535"
3490  '
3500  data "Volumen","Oktave","Note"
3510  data "Ton-Osz.","Rausch-Osz.","HÅllkurve"
3520  data "HÅllkurvenform","Periodendauer","Programmende"
