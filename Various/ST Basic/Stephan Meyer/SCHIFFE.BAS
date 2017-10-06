50    ' schiffe versenken
60    ' (c) K.H. Lumma
70    ' GEM-Routinen aus ST 03/04/86 benutzt
100   gosub TITEL
105   START: gosub INIT
110   gosub BILDAUFBAU
120   gosub COMPSCHIFFE
125   gotoxy 3,18:?string$(20," ")
130   gosub SCHIFFEINGABE
140   spielerzug=1
150   while spielerzug < 2
155   modus=4:gosub GRAFIKMODUS:gotoxy 21,16:?" Eingabe Spieler "
156   modus=1:gosub GRAFIKMODUS
160   while spielerzug=1
170   gosub SP.EINGABE
180   wend
185   gotoxy 21,16:?string$(20," ")
190   while spielerzug=0
195   gotoxy 3,16:?"Bitte warten ..."
200   gosub COMP.EINGABE
210   wend
214   for i=0 to 2:gotoxy 16,tpos(i):?string$(8," "):next
216   gotoxy 3,16:?string$(20," ")
220   wend
225   gotoxy 1,18:?string$(75," "):modus=4:gosub GRAFIKMODUS:gotoxy 1,16
230   if spielerzug=3 then ?" G e w o n n e n ! ":goto WEITER
235   if spielerzug=4 then ?" Leider verloren ":goto WEITER
240   ?" Fehler bei Antwort - daher verloren ! ";:modus=1:gosub GRAFIKMODUS
250   if za>2 then ?"Schiffgroesse max. 4 Felder":goto WEITER
260   if z0>2 then ?"Schiff muesste versenkt sein":goto WEITER
270   ?"Keine freien Felder mehr vorhanden"
290   WEITER: modus=1:gosub GRAFIKMODUS
300   gotoxy 1,18:?"Noch ein Spiel (j/n) ?":d=inp(2)
310   if (d and &hdf) = asc("J") then goto START
999   gosub mousean:   end
40000 '------------------------
40005 TITEL:
40010 fullw 2:clearw 2:gosub MOUSEAUS
40020 groesse=20:gosub SCHRIFTGROESSE:schrifttyp=13:gosub SCHRIFTART
40030 txpos=150:typos=150:txt$="Schiffe versenken"
40035 gosub TEXTAUSGABE
40040 groesse=9:gosub SCHRIFTGROESSE:schrifttyp=0:gosub SCHRIFTART
40050 txpos=50:typos=300:txt$=chr$(&hbd)+" 1986 Karl-Heinz Lumma"
40060 gosub TEXTAUSGABE
40070 txpos=107:typos=310:txt$="Nelkenweg 35":gosub TEXTAUSGABE
40080 typos=320:txt$="D-2072 Bargteheide":gosub TEXTAUSGABE
40090 typos=330:txt$="Tel: 04532 / 2 27 02":gosub TEXTAUSGABE
40100 groesse=11:gosub SCHRIFTGROESSE
41000 for i=0 to 10000:next
41010 return
50000 '------------------------
50001 INIT:
50010 clearw 2: color 1,1,1,1,0: clear
50015 gotoxy 3,18:?"Bitte warten ..."
50020 width 77:fw=1:fs=1:b.alt=0
50030 dim sch.comp(12,12), sch.spiel(12,12),c(7),htext$(7)
50040 dim mdata(10),tpos(3),text$(3):restore
50050 for i=0 to 9:read mdata(i):next
50055 for i=0 to 2:read tpos(i),text$(i):next
50056 for i=0 to 6:read c(i),htext$(i):next
50060 randomize 0
50070 for i=0 to 11:for j=0 to 11:sch.comp(i,j)=0:sch.spiel(i,j)=0:next j,i
50080 markertyp=3:markergroesse=25:gosub POLYMARKER
50899 return
50900 ' datas
50910 data 7,8,8,9,9,9,10,10,10,10
50930 data 5,Vorbei,7,Treffer,9,Versenkt
50940 data 11,vorbei,3,Schiff,6,Treffer,6,0,11,vorbei,3,Treffer,6,versenkt
51000 '-------------------------
51010 BILDAUFBAU:
51015 'Rahmen
51020 staerke = 3: gosub LINIENSTAERKE
51025 x1 = 50: x2 = 250: x3 = 350: x4 = 550: y1 = 50: y2 = 250
51030 xpos1 = x1-2: ypos1 = y1-1: xpos2 = x2+2: ypos2 = y2+1: gosub RECHTECK2
51040 xpos1 = x3-2: ypos1 = y1-1: xpos2 = x4+2: ypos2 = y2+1: gosub RECHTECK2
51050 staerke = 1: gosub LINIENSTAERKE
51055 'Quadrate
51060 for xpos = x1 + 20 to x2 - 20 step 20
51070 linef xpos, y1, xpos, y2
51080 next xpos
51090 for xpos = x3 + 20 to x4 - 20 step 20
51100 linef xpos, y1, xpos, y2
51110 next xpos
51120 for ypos = y1 + 20 to y2 - 20 step 20
51130 linef x1, ypos, x2, ypos: linef x3, ypos, x4, ypos
51140 next ypos
51999 return
52000 RECHTECK2: '-----------
52020 linef xpos1,ypos1,xpos1,ypos2
52030 linef xpos1,ypos1,xpos2,ypos1
52040 linef xpos1,ypos2,xpos2,ypos2
52050 linef xpos2,ypos1,xpos2,ypos2
52099 return
53000 '----------------------
53010 COMPSCHIFFE:
53020 for sch = 0 to 9
53030 gosub ZUFALL
53040 xm = mdata(sch):ym = xm:felder = 11-xm
53045 L1: if z <> 0 then goto L2
53050 if y>ym then y=ym
53060 for i=y to y+felder: if sch.comp(x,i)>0 then gosub ZUFALL: goto L1
53065 next i
53070 for i=y to y+felder:sch.comp(x,i)=1:sch.comp(x-1,i)=2
53080 sch.comp(x+1,i)=2:next
53090 for i=x-1 to x+1:sch.comp(i,y-1)=2:sch.comp(i,y+felder)=2:next:goto L4
53100 L2: if x>xm then x=xm
53110 for i=x to x+felder: if sch.comp(i,y)>0 then gosub ZUFALL: goto L1
53120 next i
53130 for i=x to x+felder
53140 sch.comp(i,y)=1:sch.comp(i,y+1)=2:sch.comp(i,y-1)=2
53150 next
53160 for i=y-1 to y+1:sch.comp(x-1,i)=2:sch.comp(x+felder,i)=2:next
53164 L4: next sch
53170 for i=0 to 11:sch.spiel(0,i)=2:sch.spiel(11,i)=2
53180 sch.spiel(i,0)=2:sch.spiel(i,11)=2:next
53190 return
53900 ZUFALL: '-----------
53910 x = int(rnd(1)*10)+1:y=int(rnd(1)*10)+1:z=int(rnd(1)+.5)
53911 if x < 1 then x = 1
53912 if y < 1 then y = 1
53913 if x > 10 then x=10
53914 if y > 10 then y=10
53920 return
54000 '--------------------
54001 SCHIFFEINGABE:
54002 groesse=9:gosub SCHRIFTGROESSE
54003 gotoxy 3,18:?"1x4er, 2x3er, 3x2er, 4x1er"
54004 groesse=11:gosub SCHRIFTGROESSE
54010 anz=0:gotoxy 3,16:?"Eingabe Schiff Nr"
54015 y01=y1:x01=x1
54020 while anz < 20
54025 gotoxy 11,16:anz=anz+1:?anz:gosub MAUSTASTE
54055 xpos2=x1+x*20:xpos1=xpos2-20:ypos2=y1+y*20:ypos1=ypos2-20
54060 if sch.spiel(x,y)=0 then sch.spiel(x,y)=1:color 1,1,1,3,2:goto W
54065 sch.spiel(x,y)=0:anz=anz-2:color 1,1,1,2,0
54067 W: gosub RECHTECK
54080 wend:gotoxy 3,16:?string$(25," "):gotoxy 3,18:?string$(30," ")
54090 txpos=x1+80:txt$="0":gosub TR.AUSG:txpos=x3+80:gosub TR.AUSG
54095 groesse=9:gosub SCHRIFTGROESSE
54100 ypos1=310:ypos2=320:xpos1=x1:typos=ypos2:for j=0 to 6:if j=3 then goto HL1
54110 xpos2=xpos1+10:color 1,1,1,c(j),2:gosub RECHTECK
54120 txpos=xpos2+3:txt$=htext$(j):gosub TEXTAUSGABE
54130 HL1: xpos1=xpos1+75:next j
54990 groesse=11:gosub SCHRIFTGROESSE
54998 return
55000 '------------------
55010 SP.EINGABE:
55020 y01=y1:x01=x3
55030 gosub MAUSTASTE
55040 xpos2=x3+x*20:xpos1=xpos2-20:ypos2=y1+y*20:ypos1=ypos2-20
55050 if sch.comp(x,y)=1 then gosub SP.TREFFER: goto W1
55060 if sch.comp(x,y)=9 then return
55070 color 1,1,1,11,2:spielerzug=0:gosub RECHTECK
55100 W1: return
55200 SP.TREFFER: '--------------
55210 sch.comp(x,y)=9:tr.spiel=tr.spiel+1:versenkt=1
55214 txpos=x3+80:txt$=str$(tr.spiel):gosub TR.AUSG
55215 if tr.spiel=20 then spielerzug=3
55220 sx=x:sy=y:rx=1:ry=0:gosub PR.VERSENKT:rx=-1:gosub PR.VERSENKT
55230 rx=0:ry=1:gosub PR.VERSENKT:ry=-1:gosub PR.VERSENKT
55240 if versenkt=0 then color 1,1,1,3,2:gosub RECHTECK:return
55250 color 1,1,1,6,2:gosub RECHTECK
55260 gosub TREFFER:ry=1:gosub TREFFER:rx=1:ry=0:gosub TREFFER
55270 rx=-1:gosub TREFFER
55280 return
55400 PR.VERSENKT: '---------------
55410 sx=sx+rx:sy=sy+ry:if sch.comp(sx,sy)=9 then goto PR.VERSENKT
55420 if sch.comp(sx,sy)=1 then versenkt=0
55430 sx=x:sy=y:return
55500 TREFFER:     '--------
55510 sx=sx+rx:sy=sy+ry:if sch.comp(sx,sy) <> 9 then sx=x:sy=y:return
55520 xpos2=x3+sx*20:xpos1=xpos2-20:ypos2=y1+sy*20:ypos1=ypos2-20
55530 gosub RECHTECK
55540 goto TREFFER
56000 MAUSTASTE:   '---------
56001 gosub MOUSEAN
56010 MABFRAGE: gosub MOUSE: if button=b.alt then goto MABFRAGE
56020 b.alt=button:if button=0 then goto MABFRAGE
56030 y=int((ypos-y01)/20)+1:x=int((xpos-x01)/20)+1
56040 if y>10 or x>10 or ypos<y01 or xpos<x01 then goto MABFRAGE
56050 gosub MOUSEAUS: return
57000 '-----------------------
57001 COMP.EINGABE:
57010 LC1: if ma=1 then goto WEITERSUCHEN
57020 gosub ZUFALL
57025 LC11: if sch.spiel(x,y) > 1 then m0=1:goto LC1
57030 xpos2=x1+x*20:xpos1=xpos2-20:ypos2=y1+y*20:ypos1=ypos2-20
57045 pxpos=xpos1+10:pypos=ypos1+10:gosub MARKERSETZEN
57046 pxpos=xpos1+11:gosub MARKERSETZEN
57047 pypos=ypos1+11:gosub MARKERSETZEN
57048 gotoxy 3,16:?string$(20," ")
57060 row=76:feldanzahl=3:feld.alt=99
57070 gosub MAUST
57080 if feld=0 then m0=1:sch.spiel(x,y)=2:spielerzug=1:color 1,1,1,11,2:            goto LC2
57085 gotoxy 3,16:?"Bitte warten ..."
57090 gosub TR.EINTR:color 1,1,1,6,2:if feld=2 then goto VERS
57100 if ma=0 then ma=1:mx=x:my=y:za=0:z0=0:goto LC2
57110 za=za+1:z0=2:if za>2 then spielerzug=2
57120 goto LC2
57200 VERS:  '-----------
57210 ma=0:mr=0:mx=x:my=y:z0=0
57220 VL1: xd1=0:yd1=0:sch.spiel(mx,my)=8:xx=mx+1:yy=my:gosub FELDERBELEGEN
57225 xx=mx-1:gosub FELDERBELEGEN
57230 xx=mx:yy=my+1:gosub FELDERBELEGEN:yy=my-1:gosub FELDERBELEGEN
57240 xx=mx+1:gosub FELDERBELEGEN:xx=mx-1:gosub FELDERBELEGEN
57250 yy=my+1:gosub FELDERBELEGEN:xx=mx+1:gosub FELDERBELEGEN
57260 if xd1=0 then gosub PR.FREI:goto LC2
57270 mx=xd1:my=yd1:goto VL1
57280 FELDERBELEGEN: '---
57285 if sch.spiel(xx,yy)=9 then xd1=xx:yd1=yy:return
57290 if sch.spiel(xx,yy)<8 then sch.spiel(xx,yy)=2
57295 return
57300 LC2: gosub RECHTECK
57310 return
57400 WEITERSUCHEN:  '---
57410 if mr=0 then mr=int(rnd(1)*2+1)
57420 if m0=0 or ma=0 then goto LC3
57430 x=mx:y=my:if m0=1 and mr<=1 then fw=-fw
57440 if m0=1 and mr> 1 then fs=-fs
57450 if sch.spiel(mx,my)=9 and sch.spiel(mx,my+1)=2 and sch.spiel(mx,my-1)=2        then mr=2
57460 if sch.spiel(mx,my)=9 and sch.spiel(mx+1,my)=2 and sch.spiel(mx-1,my)=2        then mr=1
57470 z0=z0+1:if z0>3 then spielerzug=2:return
57480 LC3: if mr<=1 then y=y+fw else x=x+fs
57490 goto LC11
57600 TR.EINTR: '--------
57610 sch.spiel(x,y)=9:m0=0:tr.comp=tr.comp+1:if tr.comp=20 then spielerzug=4
57615 txpos=x1+80:txt$=str$(tr.comp):gosub TR.AUSG
57620 PR.FREI:  '--------
57630 m.frei=1:for i=1 to 10:for j=1 to 10
57640 if sch.spiel(i,j) < 2 then m.frei=0
57650 next j,i:return
58000 MAUST:    '--------
58001 gosub MOUSEAN
58010 gosub MOUSE
58060 feld=int((ypos-row)/34):if ypos<row then feld=0
58061 if feld>=feldanzahl then feld=0
58062 if feld=feld.alt then goto BABFR
58065 feld.alt=feld:modus=1:gosub GRAFIKMODUS:gosub T.AUSG
58072 gotoxy 16,tpos(feld):?string$(8," "):modus=4:gosub GRAFIKMODUS
58074 gotoxy 16,tpos(feld):?text$(feld):modus=1:gosub GRAFIKMODUS
58075 BABFR: if button=b.alt then goto MAUST
58076 b.alt=button:if button=0 then goto MAUST
58080 gosub MOUSEAUS: return
59000 T.AUSG:   '---------
59010 for tnr=0 to 2
59020 gotoxy 16,tpos(tnr):?text$(tnr)
59030 next tnr
59040 return
60000 TR.AUSG:  '---------
60010 typos=y1-20:groesse=18:gosub SCHRIFTGROESSE:gosub TEXTAUSGABE
60020 groesse=10:gosub SCHRIFTGROESSE
60030 return
64000 '----- GEM-Routinen ----
64001 RECHTECK:
64002 ' --> xpos1, ypos1, xpos2, ypos2
64004 poke contrl   ,11
64006 poke contrl+ 2, 2
64008 poke contrl+ 6, 0
64010 poke contrl+10, 1
64012 poke ptsin  ,xpos1+1
64014 poke ptsin+2,ypos1+38
64016 poke ptsin+4,xpos2+1
64018 poke ptsin+6,ypos2+38
64020 vdisys
64022 return
64220 LINIENSTAERKE: '---------------
64222 ' --> staerke (1, 3, 5, 7 ....)
64224 poke contrl  ,16
64226 poke contrl+2, 1
64228 poke contrl+6, 0
64230 poke ptsin  ,staerke
64232 poke ptsin+2,0
64234 vdisys
64236 return
64240 LINIENMUSTER:  '------------
64242 ' --> linientyp (1 ... 7)
64246 poke contrl  ,15
64248 poke contrl+2, 0
64250 poke contrl+6, 1
64252 poke intin  ,linientyp
64254 vdisys
64256 return
64500 POLYMARKER:    '-------------
64510 ' --> markertyp, markergroesse
64512 poke contrl  ,18
64514 poke contrl+2, 0
64516 poke contrl+6, 1
64518 poke intin  ,markertyp
64520 vdisys
64522 poke contrl  ,19
64524 poke contrl+2, 1
64526 poke contrl+6, 0
64528 poke ptsin  ,  0
64530 poke ptsin+2, markergroesse
64532 vdisys
64534 return
64600 MARKERSETZEN:  '-------------
64610 ' --> pxpos, pypos
64612 poke contrl  , 7
64614 poke contrl+2, 1
64616 poke ptsin  ,  pxpos+1
64618 poke ptsin+2,  pypos+38
64620 vdisys
64622 return
65000 SCHRIFTART:    '--------------
65005 ' --> schrifttyp (0 normal, 1 fett, 2 hell, 4 kursiv, 8 unterstreichen
65010 '                 16 hohl sowie jede Kombination
65012 poke contrl  ,106
65014 poke contrl+2,  0
65016 poke contrl+6,  1
65018 poke intin,schrifttyp
65020 vdisys
65022 return
65030 SCHRIFTGROESSE: '-------------
65035 ' --> groesse (<9 sehr klein, 9 klein, 10-15 normal, 16-17 gross
65040 '              18-19 sehr gross)
65042 poke contrl  ,107
65044 poke contrl+2,  0
65046 poke contrl+6,  1
65048 poke intin, groesse
65050 vdisys
65052 return
65060 TEXTAUSGABE:   '---------------
65062 ' --> txt$, txpos, typos
65066 for i=0 to len(txt$)-1
65068 poke intin+i*2, asc(mid$(txt$, i+1, 1))
65070 next
65072 poke intin+i*2, 0
65074 poke contrl   , 8
65076 poke contrl+2 , 1
65078 poke contrl+6 , len(txt$)+1
65080 poke ptsin    , txpos+1
65082 poke ptsin+2  , typos+38
65084 vdisys
65086 return
65130 GRAFIKMODUS:   '---------------
65132 '--> Modus (1 ueberschreiben, 2 mischen, 3 xor, 4 revers mischen)
65138 poke contrl  ,32
65140 poke contrl+2, 0
65142 poke contrl+6, 1
65144 poke intin   , modus
65146 vdisys
65148 return
65200 MOUSE: '------------------------
65210 poke contrl  ,124
65220 poke contrl+2,  0
65230 poke contrl+6,  0
65240 vdisys
65250 button=peek(intout)
65260 xpos  =peek(ptsout)-1
65270 ypos  =peek(ptsout+2)-38
65280 return
65300 MOUSEAUS: '--------------
65310 poke contrl  ,123
65320 poke contrl+2,  0
65330 poke contrl+6,  0
65340 vdisys
65350 return
65400 MOUSEAN:  '---------------
65410 poke contrl  ,122
65435 poke intin   ,  0
65440 vdisys
65450 return
