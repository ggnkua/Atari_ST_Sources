wiopen       move wiarb,d6          ;Fensternummer
             mulu #2,d6             ;* 2 um msw zu lîschen
             lea  wihand,a0
             move (a0,d6.l),akthand ;Fensterhandle
             lea fenster,a0
             move d6,d0
             mulu #30,d0
             add.l d0,a0            ;Fensternamen
             move.l a0,intin+4
             moveq #2,d0
             bsr wiset
             mulu #4,d6
             lea fenkoor,a0
             add.l d6,a0            ;Fensterkoordinaten
           wind_open akthand,(a0),d0
             move wiarb,d0
             move d0,wiakt          ;Fensternummer aktuell machen
             mulu #4,d0
             lea wiop,a0
             move.l psel,sel        ;Dateinr. aktuell
             move.l sel,(a0,d0.l)   ;Textnr. fÅr Fensterverwalt. notieren
             bsr fenmaû
wo0          bsr scrhor
             bra scrver

redraw       move wiarb,d0
             mulu #4,d0
             lea wiop,a0
             move.l (a0,d0.l),psel
             bsr fenmaû
             bsr mausaus
             lea clplst,a4
             moveq #11,d4
             bsr wiget              ;erstes Element Rechteckliste
rd0          tst.l (a4)
             beq rd6                ;fertig
             sub.l #4,a4            ;a4 auf x stellen
             lea fen,a3
             lea cliparr,a0
             move (a4),d0           ; clipliste
             move (a3),d1
             cmp d0,d1
             ble.s rd1
             exg d0,d1
rd1          move d0,(a0)           ;x links
             move 2(a4),d0
             move 2(a3),d1
             cmp d0,d1
             ble.s rd2
             exg d0,d1
rd2          move d0,2(a0)          ;y oben
             move 4(a4),d0
             add  (a4),d0
             move 4(a3),d1
             add (a3),d1
             cmp d1,d0
             ble.s rd3
             exg d0,d1
rd3          subq #1,d0
             move d0,4(a0)           ;x rechts
             sub (a0),d0
             bmi.s rd5               ;nicht darstellen
             move 6(a4),d0
             add 2(a4),d0
             move 6(a3),d1
             add 2(a3),d1
             cmp d1,d0
             ble.s rd4
             exg d0,d1
rd4          subq #1,d0
             move d0,6(a0)           ;y unten
             sub 2(a0),d0
             bmi.s rd5
             bsr clipan
             bsr clrwind
             bsr zeigposit
             bsr vollschirm
             bsr kursor
rd5          lea clplst,a4
             moveq #12,d4
             bsr wiget
             bra rd0
rd6          move wiakt,d0
             cmp wiarb,d0
             beq.s rd7
             move d0,wiarb
             move.l sel,psel        ;Zeiger auf akt. Fenster stellen
             mulu #2,d0
             lea wihand,a0
             move (a0,d0.l),akthand
             bsr fenmaû
rd7          bsr.s clipwork
             bra mausan

clipwork     lea work_arb,a4        ;Clipping auf ArbeitsflÑche setzen
             lea cliparr,a1
             move.l (a4)+,d0
             move.l d0,(a1)+
             add.l (a4),d0
             sub.l #$00010001,d0
             move.l d0,(a1)
             bra clipan

clrwind      move.l #1,-(a7)
             move.l #$10000,-(a7)
             bsr vsfpara
             lea ptsin,a0
             clr.l (a0)+
             move.l #$3000200,(a0)
             bra bar

topped       bsr txtcl              ;Speicher freigeben,Zeiger setzen
tp           moveq #10,d0
             bsr wiset
             move wiarb,d0          ;Fensternummer
             move d0,wiakt          ;zur aktuellen machen
             mulu #4,d0
             lea wiop,a0
             move.l (a0,d0.l),d0   ;Dateinummer holen
             move.l d0,sel
             move.l d0,psel
             bsr txtopn
tp1          bsr demglob
             btst #6,flag
             beq.s tp2
             move.l sel,d0
             cmp.l blsel,d0
             bne.s tp2
             bra ble3
tp2          rts

wiclose      move wiarb,d0
             bsr txtcl
sch1         wind_close akthand,d0
             lea wiop,a0
             move wiarb,d0
             mulu #4,d0
             move.l #-1,(a0,d0.l)   ;Fenster freigeben
           scf_aes 104,2,5,0,0      ;Wind_get 10
             move #10,intin+2
           aes
             move intout+2,d7       ;wihandle
             bsr fenhandle
             beq tp                 ;neues aktives Fenster
sch2         moveq #-1,d0           ;Kein Fenster mehr auf
             move d0,wiarb
             move d0,wiakt
             move.l d0,sel
sch3         bra demark

full         lea fenkoor,a0
             lea fenkoor+32,a1
             move wiakt,d0
             mulu #8,d0
             add.l d0,a0            ;Zeiger auf momentane Werte
             lea intin+4,a2
             move.l (a1),(a2)
             move.l 4(a1),4(a2)
             move.l (a1)+,(a0)+
             move.l (a1),(a0)
             moveq #5,d0
             bsr wiset
             bsr fenmaû
             bsr curinfen
             bsr verposit
             bra wo0

arrow        move.l #0,scrh         ;flags zurÅck
             bsr mausaus
             bsr kursor
             lea jumptab3,a0
             move fen,d0
             bsr indjump
ar1          bsr kursor             ;setzen
             bra mausan

hslid        move fen,d0
             bne.s hsl0
             moveq #1,d0
hsl0         sub #1,d0
             mulu xres,d0
             divu #999,d0
             move d0,-4(a6)
             bsr vollschirm
             lea xmax,a0
             bsr kposx
             bsr kursor
             bsr scrhor
             bra lineal

vslid        move fen,d0
             bne.s vs0
             moveq #1,d0
vs0          move -24(a6),d1        ;letzte Textzeile
             cmp fenho,d1
             ble.s vsret
             sub fenho,d1
             mulu d1,d0
             divu #999,d0
             cmp firstzei,d0
             bge.s vs1
             moveq #2,d0
vs1          move d0,-10(a6)
             addq #1,d0
             move d0,-14(a6)
             bsr scrver
             bsr vollschirm
             bsr kursor
vsret        rts

size         bsr.s wimove
             bra wo0

wimove       lea fen,a0
             lea intin+4,a1
             andi #$fff0,(a0)
             move.l (a0),(a1)+      ;neue Koordinaten fÅr
             move.l 4(a0),(a1)      ;wiset Åbertragen
             lea fenkoor,a1
             move wiarb,d0
             mulu #8,d0
             move.l (a0)+,(a1,d0.l) ;und als Fensterkoordinaten
             move.l (a0),4(a1,d0.l)
             moveq #5,d0
             bsr wiset              ;Fenster neu zeichnen
             bsr fenmaû             ;neue Maûe setzen
             bsr clipwork
             bsr curinfen
             bra verposit
;Unterprogramme
sidup        move -28(a6),d0
             sub -10(a6),d0
             subq #2,d0
             move -10(a6),d1
             sub firstzei,d1
             cmp d1,d0
             ble.s su0
             move d1,d0
su0          sub d0,-10(a6)
             sub d0,-14(a6)
             bra.s sd0

siddown      move -28(a6),d0
           cmp -24(a6),d0
           ble.s sd
           move -24(a6),d0
sd             subq #2,d0             ;letzte Fensterzeile
             move d0,-10(a6)        ;zur ersten machen
             move d0,-14(a6)
sd0          bsr scrver
             bra vollschirm

zeilup       move -10(a6),d0
             cmp firstzei,d0
             beq.s zuret
             bsr bitab
             subq #1,-14(a6)
             bsr erstzeil
             bsr aktzeile           ;neue aktuelle Zeile
             bsr kplinks            ;Kursor im Fenster
             bsr kurkoord           ;Koordinaten berechnen
             bsr codekur            ;Schriftart bestimmen
zu0          bsr scrver             ;Srollbalken setzen
zuret        rts

zeildown     move -28(a6),d0
             cmp -24(a6),d0
             bge.s zuret
             bsr bitauf
             move -28(a6),-(a7)
             bsr scrver
             addq #2,-14(a6)
             move (a7)+,d0
             bra neuschirm

sidleft      move fenbr,d0
             subq #8,d0
sl           move -4(a6),d1
             cmp d1,d0
             ble.s sl0
             move d1,d0
sl0          sub d0,-4(a6)
             bra.s fl1

sidright     move fenbr,d0
             subq #8,d0
sr0          add d0,-4(a6)
fl1          bsr vollschirm
             lea xmax,a0
             bsr kposx
             bsr scrhor
             bra lineal

spalleft     moveq #8,d0
             bra.s sl

spalright    moveq #8,d0
             bra.s sr0

fenmaû       lea txtstart,a0
             add.l psel,a0
             move.l (a0),a6
             lea 68(a6),a6          ;aktstart
             lea work_arb,a4
             moveq #4,d4
             bsr wiget              ;Arbeitsbereich holen
             subq.l #4,a4           ;a4 auf x
             move (a4)+,d0          ;x
             move (a4)+,d1          ;y
             move (a4)+,d2          ;breite
             move (a4),d3           ;hîhe
             move d0,d4
             add d2,d4
             subq #1,d4
             lea xmax,a0
             move d4,(a0)           ;'xmax'
             move d4,24(a0)
             move d4,32(a0)
             move d4,40(a0)
             move d4,48(a0)
             move d4,64(a0)
             move d4,72(a0)
             move d1,d4
             add d3,d4
             subq #1,d4
             move d4,2(a0)          ;'ymax'
             move d4,26(a0)
             move d4,50(a0)
             move d4,58(a0)
             move d4,66(a0)
             move d4,74(a0)
             move d4,82(a0)
             ext.l d2               ;wegen teilen vorzeichenrichtig
             ext.l d3               ;erweitern
             addq #2,d0
             move d0,-6(a0)         ;Start Seitenbeschriftung 'seitx'
             add #26,d0
             move d0,-4(a0)         ;Senkrechte fÅr Seitenlineal
             addq #3,d0
             move d0,4(a0)          ;Beginn Beschriftung 'xstart'
             move d0,20(a0)
             move d0,28(a0)
             move d0,36(a0)
             move d0,44(a0)
             move d0,52(a0)
             move d0,76(a0)
             sub d0,d2              ;Breite NutzflÑche
             divu #8,d2
             move d2,16(a0)         ;Buchstaben/Zeile 'fenbr'
             move #255,d4
             sub d2,d4
             move d4,84(a0)         ;unsichtbarer Anteil des Schirms
             mulu #1000,d2
             divu #255,d2
             move d2,86(a0)         ;Grîûe horizontaler Schieber
             add zlabst,d1
             addq #2,d1
             sub rez,d1
             move d1,-2(a0)         ;Spaltenlineal 'horlin'
             addq #1,d1
             move d1,6(a0)          ;'ystart'
             move d1,30(a0)
             move d1,38(a0)
             move d1,54(a0)
             move d1,62(a0)
             move d1,70(a0)
             move d1,78(a0)
             divu schrhî,d3
             lsr #1,d3
             subq #1,d3
             move d3,18(a0)         ;Zeilen/Schirm 'fenho'
             moveq #64,d0
             move 4(a0),d1          ;xstart
             add d0,d1
             move d1,68(a0)
             move (a0),d0           ;xmax
             sub #64,d0
             move d0,80(a0)

scrhor       move horsch,intin+4
             moveq #15,d0
             bsr wiset
             move -4(a6),d0
             mulu #999,d0
             add xres,d0
             divu xres,d0
             move d0,intin+4
             moveq #8,d0
             bra wiset

scrver       bsr verposit
scrver1      move -28(a6),d0
             sub -10(a6),d0
             mulu #1000,d0
             moveq #1,d1
             add -24(a6),d1
             sub firstzei,d1
             divu d1,d0
             cmp altgr,d0
             beq.s scv
             move d0,intin+4
             move d0,altgr
             moveq #16,d0
             bsr wiset
scv          move -10(a6),d0
             sub firstzei,d0
             mulu #999,d0
             move -24(a6),d1
             sub firstzei,d1
             sub -28(a6),d1
             add -10(a6),d1
             bgt.s sv0
             moveq #1,d1
sv0          ext.l d1
             add.l d1,d0
             divu d1,d0
             and #$fffc,d0
             cmp altpos,d0
             beq vpret
             move d0,intin+4
             move d0,altpos
             moveq #9,d0
             bra wiset

zeigposit    bsr lineal

verposit0    clr.l -(a7)
             move.l #$10001,-(a7)
             move #1,-(a7)
             bsr vslpara
             lea ptsin,a0           ;Ablage fÅr Polyline-Punkte
             lea xmax,a2
             lea work_arb,a4
             move (a4),d0
             move d0,(a0)+
             move -2(a2),(a0)+
             add 4(a4),d0
             move d0,(a0)+
             move -2(a2),(a0)
             moveq #2,d0
             bsr polyline           ;Horizontale
             lea ptsin,a0
             move -4(a2),(a0)+
             move 2(a4),d0
             move d0,(a0)+
             move -4(a2),(a0)+
             add 6(a4),d0
             move d0,(a0)
             moveq #2,d0
             bsr polyline           ;und vertikale Fenstergrenze
verposit     clr.l -(a7)
             move.l #$10001,-(a7)
             move #1,-(a7)
             bsr vslpara
             bsr txteffect0
             move -10(a6),d1
             bsr txtort1
             subq.l #2,a0
             move.l a0,-36(a6)      ;Adresse 1. Zeile
             move.l a0,fen+8
             move 4(a0),d0          ;Zeilenhîhe
             mulu schrhî,d0
             add ystart,d0
             move d0,-20(a6)        ;Druckort 1. Zeile
             moveq #2,d1            ;erste Textzeile
             bsr txtort1
             move -10(a6),d1        ;Nr. erste Bildschirmzeile
             moveq #1,d7            ;Seite
sp0          moveq #1,d6            ;Zeile
             moveq #0,d5            ;Pixelposition
sp1          move 2(a0),d3
             mulu schrhî,d3
             add d3,d5              ;+ Zeilenhîhe
             subq #1,d1
             cmp #2,d1
             blt.s sp2              ;fertig
             addq #1,d6
             add.l d0,a0            ;nÑchste Zeile
             move (a0)+,d0
             cmp -30(a6),d5         ;SeitenlÑnge in Pixeln
             blt.s sp1
             addq #1,d7             ;Seite +1
             bra.s sp0
sp2          move d5,-16(a6)        ;Pixelposition 1. Zeile
             move -10(a6),-28(a6)
             move.l #1,-(a7)
             move.l #$10000,-(a7)
             bsr vsfpara
             lea xmax,a2
             lea ptsin,a0
             move -6(a2),(a0)
             subq #2,(a0)+
             move 6(a2),(a0)+
             move -6(a2),(a0)+
             move 2(a2),(a0)
             add #25,-2(a0)
             bsr bar
             move -30(a6),d0        ;SeitenlÑnge in Pixel
             sub -16(a6),d0         ;- Pixelwert erste Zeile
             add -20(a6),d0         ;+ Druckort erste Zeile
             cmp 2(a2),d0           ;mit ymax vergleichen
             bhi.s vp3
             lea ptsin,a0
             move d0,2(a0)
             move d0,6(a0)
             move -6(a2),(a0)
             move -4(a2),4(a0)
             subq #2,(a0)
             moveq #2,d0
             bsr polyline           ;Seitengrenze markieren
vp3          move.l d7,d0           ;Seitennr
             move #2,stellen
             lea ptsin,a0
             move -6(a2),(a0)+      ;seitx
             move -2(a2),(a0)
             subq #3,(a0)           ;horlin-2
             bsr printzahl
             move 2(a2),d7          ;ymax
             move -20(a6),ptsin+2   ;Druckort
             tst -10(a6)
             bne.s zp0
             move schrhî,d3
             lsl #2,d3
             add d3,ptsin+2         ;Bei kopf-fuû verschieben
zp0          move.l d6,d0           ;Zeilennummer
             bsr printzahl
             moveq #0,d0
             moveq #4,d1            ;5 Zeilen weiter
             move -28(a6),d2        ;absolute Zeilennummer
zp1          cmp -24(a6),d2         ;letzte Zeile
             bge.s zp2
             move.l fen+8,a0        ;Zeilenadresse
             move (a0)+,d0
             add.l d0,a0
             move 4(a0),d3          ;Zeilenhîhe
             mulu schrhî,d3
             move.l a0,fen+8
             bra.s zp3
zp2          move zlabst,d3
zp3          add d3,ptsin+2         ;Druckort
             add d3,d5              ;Pixelposition
             cmp -30(a6),d5         ;SeitenlÑnge
             ble.s zp4
             move d3,d5
             moveq #0,d6
zp4          addq #1,d2             ;Zeilennummer absolut
             addq #1,d6             ;und in der Seite
             cmp ptsin+2,d7
             dblt d1,zp1
             move d2,-28(a6)        ;abs. Nummer+1 letzte Fensterzeile
             tst d1
             bmi.s zp0              ;noch kein Fensterende
             move ptsin+2,d0
             sub d3,d0
             move d0,-26(a6)        ;Druckort letzte Zeile
vpret        rts

lineal       bsr txteffect0
             move.l #1,-(a7)
             move.l #$10000,-(a7)
             bsr vsfpara
             lea xmax,a2
             lea ptsin,a0
             move 4(a2),(a0)+
             move work_arb+2,(a0)+
             move (a2),(a0)+
             move -2(a2),(a0)
             subq #1,(a0)
             bsr bar
             move -18(a6),d0
             subq #1,d0
             lea tabul,a0
             lea akttab,a1
             bsr copy1              ;Lineal Åbertragen
             move.b #"]",(a1)+
             move.l a1,a0
             move #2,stellen
             move -18(a6),d0
             ext.l d0
             bsr formzahl1
             lea akttab,a0          ;akttab als Quelle
             move -4(a6),d1         ;first
             ext.l d1
             add.l d1,a0
             move -18(a6),d0        ;lineallÑnge
             addq #3,d0
             sub d1,d0
             bmi.s liret            ;first>Lineal
li0          lea puffer,a1
             bsr copy1
             move.b #0,(a1)         ;Endemarke
             lea ptsin,a0
             move 4(a2),(a0)
             move -2(a2),2(a0)
             subq #3,2(a0)
             bsr vtxt               ;anzeigen
liret        rts

curinfen     bsr kursor
             move wiarb,d0
             cmp wiakt,d0
             bne.s liret            ;nicht aktuell
             lea xmax,a0
             bsr.s kposx
             bsr.s kposy
             bsr codekur
             bra kursor

kposx        move (a0),d0           ;xmax
             subq #8,d0
             cmp 8(a0),d0           ;xkur
             bge.s kx0
             sub 4(a0),d0           ;xstart
             lsr #3,d0
             subq #2,d0
             move d0,d1
             add -4(a6),d0
             move d0,-2(a6)         ;kpos
             lsl #3,d1
             add 4(a0),d1
             move d1,8(a0)
             move d1,12(a0)         ;xkur1
kx0          rts

kposy        lea xmax,a0
             move 10(a0),d0         ;ykur
             move 2(a0),d1          ;ymax
             subq #2,d1
             cmp d0,d1
             bge.s kyret
             sub #12,d1
             bsr butzeile
             move d2,10(a0)
             move d2,14(a0)         ;ykur1
             move d4,-14(a6)        ;aktuelle Zeile
             bsr aktzeile

kplinks      move -2(a6),d0         ;kpos
             sub -4(a6),d0          ;first
             bpl.s ky0
             move -4(a6),-2(a6)     ;kpos=first
             bsr aktzeile
             bsr codekur
             move -4(a6),d0
             sub lenasc,d0
             ble.s ky
             move -4(a6),-2(a6)
             bsr spaceanf           ;Spaces anfÅgen
ky           moveq #0,d0
ky0          lea xmax,a0
             lsl #3,d0              ;* 8
             add 4(a0),d0           ;xstart
             move d0,8(a0)          ;xkur
             move d0,12(a0)         ;xkur1
kyret        rts

 end
 