txtout       lea ptsin,a0
             move.l xkur,(a0)
             move yversatz,d0
             add d0,2(a0)
vtxt         bsr mausaus
             lea puffer,a0
vtxt1      scf_vdi 8,1,127,handle
             lea intin,a3
             moveq #127,d3
             clr d4
vt0          move.b (a0)+,d4
             cmp.b #31,d4
             bne.s vt1
             moveq #32,d4
vt1          move d4,(a3)+
             dbeq d3,vt0
             sub d3,contrl+6
           vdi
             clr yversatz
             bra mausan

vollschirm   move -10(a6),d0        ;erste Fensterzeile
neuschirm    move -14(a6),-(a7)     ;Nr aktuelle Zeile retten
             move d0,-14(a6)        ;erste zu zeichnende Zeile
             move.l lentxt,-(a7)
             move -2(a6),-(a7)      ;gewÅnschte Kurpos
             move.l #1,-(a7)
             move.l #$10000,-(a7)
             bsr vsfpara
             bsr ypos
             lea xstart,a0
             move (a0),4(a0)        ;xkur
             move d2,6(a0)          ;ykur in  d3
             lea ptsin,a1
             move (a0),(a1)+
             addq #3,d2
             move d2,(a1)+
             move.l -4(a0),(a1)
             bsr mausaus
             bsr bar
             bsr txtort
             move.l a0,a5
ns0          move.l d0,lentxt
             move 2(a5),d0
             mulu schrhî,d0
             add d0,ykur
             move ymax,d0
             cmp ykur,d0
             blt.s ns1
             move xstart,xkur
             move -4(a6),d7         ;Zeile ab first ausgeben
             bsr showzeil
             add.l lentxt,a5        ;Adresse nÑchste Zeile
             move (a5)+,d0          ;ZeilenlÑnge
             ext.l d0
             addq #1,-14(a6)        ;nÑchste Zeile
             move -24(a6),d1        ;letzte Zeile
             cmp -14(a6),d1
             bge.s ns0              ;Textende nicht erreicht
ns1          bsr mausan
             move (a7)+,-2(a6)
             move.l (a7)+,lentxt
             move (a7)+,-14(a6)     ;aktuelle Nr. zurÅck
             move wiarb,d0
             cmp wiakt,d0
             bne.s nsret
             bsr aktzeile
             bsr kplinks
             bsr codelin
kurkoord     move -2(a6),d0         ;kpos
             sub -4(a6),d0          ;-first
             mulu #8,d0
             lea xstart,a0
             add (a0),d0            ;+xstart
             move d0,4(a0)          ;=xkur
             move d0,8(a0)          ;xkur1
             bsr ypos
             lea xstart,a0
             move d3,6(a0)          ;=ykur
             move d3,10(a0)         ;ykur1
nsret        rts

showzeil     bsr txtbeginn
             bsr txteffect
             clr zeinr
             lea (a5,d2.l),a2
zg3          lea puffer,a0
             move xkur,d3           ;momentane Kurpos
zg4          move.b (a2)+,d0
             beq.s zg5              ;Zeilenende
             cmp.b #27,d0           ;Steuerzeichen ?
             bne.s zg7
             bra.s zg6
zg5          clr d3                 ;Ausgabe fertig
zg6          move d3,-(a7)          ;Kurpos retten
             move.b #0,(a0)         ;Endemarke
             bsr txtout
             move (a7)+,d3
             beq.s shbl
             move d3,xkur           ;Kurpos anpassen
             bsr txtsteuer          ;Steuerzeichen auswerten
             bsr txteffect          ;Schrift anpassen
             bra.s zg3
zg7          addq #1,zeinr
             cmp zeinr,d7
             bge.s zg4              ;nicht zeigen
             move.b d0,(a0)+        ;in Puffer schreiben
             addq #8,d3             ;kpos
             btst #6,d5
             bne.s zg7a
             btst #7,d5
             beq.s zg4
             move schrhî,d0
             lsr #1,d0
             neg d0
             move d0,yversatz
zg7a         move.b #0,(a0)
             move d3,-(a7)          ;Indexschriften mÅssen Byteweise
             bsr txtout             ;ausgegeben werden
             move (a7)+,d3
             move d3,xkur
             bra.s zg3
shbl         bsr show_img           ;Grafik zeigen
             cmp.b #64,flag         ;Block definiert ?
             blt shret
             move.l blsel,d0
             cmp.l sel,d0
             bne shret
             move -14(a6),d0
             cmp blan,d0
             blt shret
             cmp blen,d0
             bgt shret
             bsr setwrmod2          ;or-Modus
             move.l #$20001,-(a7)
             move.l #$10000,-(a7)
             bsr vsfpara
             lea ptsin,a0
             lea xmax,a1
             move 4(a1),(a0)        ;xstart
             move 10(a1),d0         ;ykur
             addq #2,d0
             move d0,2(a0)
             move (a1),4(a0)        ;xmax
             move 2(a5),d1
             mulu schrhî,d1
             sub d1,d0
             move d0,6(a0)
             move -14(a6),d0
             cmp blan,d0
             bne.s sz
             move blanx,d1
             sub -4(a6),d1
             bpl.s sz0
             moveq #0,d1
sz0          mulu #8,d1
             add d1,(a0)
sz           cmp blen,d0
             bne.s sz1
             move blenx,d1
             addq #1,d1
             sub -4(a6),d1
             bpl.s sz2
             moveq #0,d1
sz2          mulu #8,d1
             add 4(a1),d1
sz3          move d1,4(a0)
sz1          bsr bar
shret        bra setwrmod1          ;replace-Modus

show_img     moveq #7,d2
si           cmp.b #28,(a5,d2.l)
             bne.s shret
si0          move 13(a5,d2.l),d5    ;Nr der Grafik
             bsr bildnr
si2          bsr grainfen           ;Grafik im Fenster ?
             bne si6                ;nein
             move 12(a3),bytes      ;Bytebreite der Grafik
             add.l (a3),a3          ;Beginn Adressen
             move 9(a5,d2.l),d0     ;Zeilennummer
             mulu zlabst,d0         ;mal Pixel/Zeile
             lsl #2,d0              ;mal 4=Offset zu erster Adresse
             add.l d0,a3            ;erste Adresse
             move.l diskpuff,a1     ;Ablage
             move zlabst,d7
             subq #1,d7
si3          move.l (a3)+,a0        ;Adresse holen
             add.l filezg,a0        ;Basisadresse addieren
             bsr depac              ;Zeile lesen und Åbertragen
             dbra d7,si3
             move.l diskpuff,a0
             lea $4000(a0),a1
             move.l a1,a3           ;Beginn Bitblock
             moveq #0,d1
             move d1,allfl
             move 7(a5,d2.l),d6     ;gewÅnschte Breite in Byte
             ext.l d6
             move d6,d5
             lsl #3,d5              ;Breite in Pixel
hpa          bsr horpac             ;Zeichnungsbreite anpassen
hpa5         btst #0,8(a5,d2.l)     ;ZeilenlÑnge gerade ?
             beq.s hpa6
             clr.b (a1)+
hpa6         move bytes,d1
             add.l d1,a0            ;nÑchste Zeile
             move zlabst,d0
             addq #1,allfl
             cmp allfl,d0
             bne.s hpa              ;noch eine Zeile
             lea quellbl,a0
             move.l a3,(a0)+
             add #15,d5
             and #$fff0,d5          ;Pixelzahl vielfaches von 16
             move d5,(a0)+
             move zlabst,(a0)+
             move d5,d0
             lsr #4,d0              ;Breite in Worten
             move d0,(a0)
             move #7,intin
             bsr zielgr             ;Grenzen Zielblock holen
             move d0,14(a0)         ;y1
             move d1,10(a0)         ;y
             move d0,-(a7)
             move d1,-(a7)
             move d7,d0             ;kpos
             sub -4(a6),d0
             bmi.s bltr0
             moveq #0,d0
bltr0        neg d0
             lsl #3,d0
             move d0,(a0)           ;x Quelle
             add 12(a0),d0
             sub 8(a0),d0
             move d0,4(a0)          ;x1
             clr 2(a0)              ;y
             move d6,6(a0)          ;y1
             bsr bitblock
             bsr setwrmod2
             clr.l -(a7)            ;Linienparameter
             move.l #$30001,-(a7)
             move #3,-(a7)
             bsr vslpara            ;setzen
             lea ptsin,a2
             move (a7),2(a2)        ;y
             move 2(a7),6(a2)       ;y1
             sub -4(a6),d7
             muls #8,d7
             bmi.s bltr2
             add xstart,d7
             move d7,(a2)           ;x
             move d7,4(a2)          ;x1
             moveq #2,d0
             bsr polyline           ;linke Bildgrenze
bltr2        move 5(a5,d2.l),d0
             add 7(a5,d2.l),d0
             sub -4(a6),d0
             lsl #3,d0
             add xstart,d0
             move (a7)+,2(a2)
             move (a7)+,6(a2)
             addq #8,d0
             cmp xmax,d0
             bgt.s si6              ;auûerhalb Fenster
             move d0,(a2)
             move d0,4(a2)
             moveq #2,d0
             bsr polyline           ;rechte Bildgrenze
si6          add.l 1(a5,d2.l),d2
             bra si                 ;noch eine Grafik ?

horpac       moveq #-1,d7           ;Pixel Nr
hpa1         moveq #7,d4            ;BitzÑhler
             clr d3
hpa2         addq #1,d7
             cmp d5,d7
             bne.s hpa3
             rts                     ;Zeile ist fertig
hpa3         move bytes,d0
             mulu d7,d0
             divu d6,d0
             move d0,d1
             lsr #3,d1              ;Quellbyte
             and #7,d0
             eori #7,d0             ;Quellpixel
             btst d0,(a0,d1.l)      ;Bit gesetzt ?
             beq.s hpa4
             bset d4,d3             ;Zielbit setzen
hpa4         dbra d4,hpa2
             move.b d3,(a1)+        ;Zielbyte speichern
             bra.s hpa1             ;nÑchstes Byte

grainfen     lea xmax,a0
             move 5(a5,d2.l),d0     ;linker Rand
             sub -4(a6),d0          ;- first
             move d0,d1
             bpl.s gif
             moveq #0,d0            ;Rand links vom Fenster
gif          lsl #3,d0              ;in Pixel
             add 4(a0),d0           ;+ xstart
             cmp (a0),d0
             bge fehler             ;Rand grîûer xmax
             add 7(a5,d2.l),d1      ;+ Breite=rechter Rand
             ble fehler             ;Rand kleiner als xstart
             bra ok

bildnr       move.l a6,a3
bnr          move.l (a3)+,d0
             cmp 6(a3),d5           ;richtige Grafik ?
             bne.s bnr0             ;nein
             move.l a3,filezg
             add.l #16,filezg       ;Beginn IMG-Daten
             rts
bnr0         add.l d0,a3
             bra.s bnr

zielgr       lea ptsin,a0
             lea xmax,a1
             move zlabst,d6
             subq #1,d6             ;ZÑhlung beginnt bei 0
             move 5(a5,d2.l),d7
             move d7,d0
             sub -4(a6),d0
             move d0,d1
             bpl.s zgr
             moveq #0,d0
zgr          lsl #3,d0
             add 4(a1),d0
             move d0,8(a0)          ;x
             add 7(a5,d2.l),d1
             lsl #3,d1
             add 4(a1),d1
             cmp (a1),d1
             ble.s zgr0
             move (a1),d1           ;xmax als Grenze
zgr0         move d1,12(a0)         ;x1
             move 10(a1),d0         ;ykur
             add rez,d0             ;y1
             move d0,d1
             sub d6,d1              ;y
             rts

pzadr        mulu zlabst,d1
             move.l diskpuff,a1
             clr allfl              ;Pixelnr fÅr Bildschirm
             clr zeinr              ;Pixelnr im IMG-Bild
             clr d3
             move.l a0,d5
txpa         move zeinr,d0
             move allfl,d4          ;Pixelzeilennr
             mulu d7,d4             ;Pixelhîhe
             divu d1,d4             ;gewÅnschte Hîhe
             move d4,zeinr          ;Nr der Pixelzeile merken
             sub d0,d4              ;d4 Zeilen weiter
txpa0        move bytes,d6          ;Originalbreite in Byte
             mulu d4,d6             ;Zahl der Bytes,die zu Åberlesen ist
             tst d3                 ;gleiche Zeilen ?
             beq.s txpa2
txpa1        sub d4,d3
             bgt txpa9              ;Adresse Speichern
             neg d3
             move d3,d4
             move bytes,d3          ;diese Zeilen ganz auslassen
             moveq #0,d0
pza          sub d0,d3
             beq.s txpa0            ;fertig,neue Bytezahl berechnen
             move.b (a0)+,d0
             beq.s pza0
             andi #127,d0
             bne.s pza
             move.b (a0)+,d0
             add.l d0,a0
             bra.s pza
pza0         move.b (a0)+,d0
             addq.l #2,a0
             add d0,d0
             bra.s pza
txpa2        tst.b (a0)             ;prÅfen auf gleiche Zeilen
             bne.s txpa4
             tst.b 1(a0)
             bne.s txpa4
             addq.l #3,a0
txpa3        move.b (a0)+,d3        ;Zeilenzahl
             move d6,d4
             ext.l d4
             divu bytes,d4          ;benîtigte Zeilenzahl
             bra.s txpa1
txpa4        moveq #0,d0
txpa5        sub d0,d6
             bne.s txpa6
             tst.b (a0)
             bne.s txpa9
             tst.b 1(a0)
             bne.s txpa9
             addq.l #3,a0
             move.b (a0)+,d3
             bra.s txpa9
txpa6        bsr holbz
             bne.s txpa5            ;Bytes
             bra.s txpa3            ;Zeilen
txpa9        move.l a0,(a1)         ;Adresse speichern
             sub.l d5,(a1)+         ;in relative Adr. wandeln
             addq #1,allfl
             cmp allfl,d1           ;fertig ?
             bne txpa
             sub.l diskpuff,a1
             rts

holbz        move.b (a0)+,d0
             beq.s hbz0
             andi #127,d0
             bne.s hbz              ;weiûe oder Schwarze
             move.b (a0)+,d0        ;unterschiedliche Bytes
             add.l d0,a0
hbz          rts
hbz0         move.b (a0)+,d0
             bne.s hbz1             ;gleiche Worte
             adda.l #1,a0           ;gleiche Zeilen
             rts
hbz1         addq.l #2,a0           ;Wortwert
             add d0,d0
             rts

depac        move bytes,d3
             moveq #0,d0
dp1          sub d0,d3
             bne.s dp2              ;noch nicht fertig
             rts
dp2          move.b (a0)+,d0
             beq.s dpwz             ;Worte
             move #255,d4           ;schwarz
             cmp.b #128,d0
             beq.s dpv              ;Verschiedene Bytes
             bhi.s dpw1
dpw          moveq #0,d4            ;weiû
dpw1         and #127,d0
             move d0,d1
             subq #1,d1
dpw2         move.b d4,(a1)+
             dbra d1,dpw2
             bra.s dp1
dpv          move.b (a0)+,d0
             move d0,d1
             subq #1,d1
dpv1         move.b (a0)+,(a1)+
             dbra d1,dpv1
             bra.s dp1
dpwz         move.b (a0)+,d0
             move d0,d1
             subq #1,d1
dpwz1        move.b (a0),(a1)+      ;Wort Byteweise Åbertragen
             move.b 1(a0),(a1)+
             dbra d1,dpwz1
             addq.l #2,a0
             add d0,d0
             bra.s dp1

scrrechts    bsr mausaus
             bsr bitrechts
             bra.s sli

scrlinks     bsr mausaus
             bsr bitlinks
sli          bsr clipan
             bsr zeilÅber
             bsr vollschirm
             bsr clipwork
             bsr scrhor
             bsr lineal
             bra.s sa2

scrab        bsr mausaus
             bsr bitab
             bsr erstzeil
             bsr scrver
             bra.s sa2

scrauf       bsr mausaus
             bsr bitauf
             move -28(a6),-(a7)
             bsr scrver
             move (a7)+,d0           ;Ausgabezeile
             bsr neuschirm
sa2          bsr mausan
             bra fehler

bitrechts    moveq #8,d0
             cmp -4(a6),d0
             ble.s sre
             move -4(a6),d0         ;first war < 8
sre          sub d0,-4(a6)
             lsl #3,d0
             lea xmax,a1
             lea fenauf+32,a0
             move (a0),d1           ;xstart
             add d0,d1
             move d1,8(a0)
             move (a1),d1           ;xmax
             sub d0,d1
             move d1,4(a0)
             lea cliparr,a1
             move.l (a0),(a1)+
             move 8(a0),(a1)+
             move 14(a0),(a1)
             bra.s bitfenst

bitlinks     addq #8,-4(a6)         ;first
             lea fenauf+48,a0
             lea cliparr,a1
             move 12(a0),(a1)       ;Cliparray setzen
             sub #16,(a1)+
             move 10(a0),(a1)+
             move.l 4(a0),(a1)
             bra.s bitfenst

bitab        subq #1,-10(a6)
             move -10(a6),d1
             bsr txtort1
             move 2(a0),d6          ;Zeilenhîhe der neuen Zeile
             lea fenauf+16,a0
             bsr bitgrenz
             move d0,10(a0)
             move d1,6(a0)
             bra.s bitfenst

bitauf       move -10(a6),d1
             bsr txtort1
             move 2(a0),d6          ;Zeilenhîhe 1.Zeile
             add.l d0,a0
             add 4(a0),d6           ;+ Hîhe 2.Zeile
             lea fenauf,a0
             bsr.s bitgrenz
             move d0,2(a0)
             move d1,14(a0)
             bsr.s bitfenst         ;Blocktransfer
             addq #2,-10(a6)
             rts

bitfenst     lea ptsin,a1
             moveq #3,d0
bf1          move.l (a0)+,(a1)+     ;Koordinaten eintragen
             dbra d0,bf1
             move #3,intin          ;replace
bitbl        lea zielbl,a3
             lea quellbl,a4
             moveq #4,d0
bf0          move.l (a3)+,(a4)+     ;Quelle = Ziel
             dbra d0,bf0
bitblock   scf_vdi 109,4,1,handle
             move.l #quellbl,14(a3)
             move.l #zielbl,18(a3)
           vdi
             rts

bitgrenz     mulu schrhî,d6
             lea xmax,a1
             move 2(a1),d1          ;ymax
             sub d6,d1
             move 6(a1),d0          ;ystart
             add d6,d0
             rts

erstzeil     lea xstart,a0
             add d6,10(a0)          ;ykur1
             move d6,d0
             add 2(a0),d0
             move d0,6(a0)          ;ykur = ystart+Zeilenhîhe(d6)
             move (a0),4(a0)        ;xkur = xstart
             move -14(a6),-(a7)     ;akt. Zeilennummer retten
             move -10(a6),-14(a6)   ;Zeile aktuell machen
             bsr txtort
             move.l a0,a5
             move.l #1,-(a7)
             move.l #$10000,-(a7)
             bsr vsfpara
             lea xstart,a0
             lea ptsin,a1
             move (a0)+,(a1)+
             move (a0),d0             ;ystart
             move d0,(a1)+
             move -6(a0),(a1)+        ;xmax
             add d6,d0
             move d0,(a1)
             bsr bar
             move -4(a6),d7
             bsr showzeil
             move (a7)+,-14(a6)     ;Nummer zurÅck
ezret        rts

einrÅck      move einrÅ,d0
             moveq #31,d1           ;FÅllbyte
             move d0,d6
             ext.l d0
             move.l d0,d4
             bne.s nÑz0
             bclr #5,(a5)           ;keine EinrÅckung
             rts
nÑz          move.b d1,(a1)+
nÑz0         dbra d0,nÑz
             bset #5,(a5)           ;EinrÅckung
             rts

nÑchstz      lea puffer,a0
             move.l a5,a1           ;aktwort
             moveq #7,d0
             bsr copy1              ;Zeilenkopf
             bsr.s einrÅck
             move.l zeirest,d0
             subq.l #1,d0           ;ohne Endemarke
             add.l d0,d4
             add ascrest,d6
             subq.l #7,d0           ;Kopf ist bereits Åbertragen
             bsr copy1              ;Rest Åbertragen
             move -14(a6),d0
             cmp -24(a6),d0
             bgt.s zanf0            ;es ist Textende
             bsr trenspac           ;"-" lîschen oder " " anfÅgen

zeilanfÅg    move -18(a6),d0
             cmp ascrest,d0
             blt.s zanf0            ;Rest ist zu groû
             move.b puffer,d0
             cmp.b #63,d0
             bhi.s zanf0            ;Absatz oder Blockende
             bclr #7,flag
             bne.s zanf0
zan          bsr txtort
             cmp #8,-2(a0)
             beq.s zanf0            ;Leerzeile folgt
             cmp.b #28,7(a0)
             bne.s zeianf           ;keine Grafik
zanf0        cmpi.l #1024,free
             bgt.s zanf1
             bsr zÅfehl
             clr ascrest
             clr idfl
             bset #6,(a5)
             bra.s zanfrt           ;Abbruch
zanf1        pea (a1)
             bsr neuezeile          ;zusÑtzliche Zeile einfÅgen
             move.l (a7)+,a1
zeianf       bsr txtort
             move.b (a0),d0
             andi.b #224,d0         ;Absatz+Blockende+EinrÅckung
             or.b d0,(a5)           ;Åbernehmen
             addq.l #7,a0
             tst wrfl
             bne.s zanf
             tst einrÅ
             bne.s zanf
             btst #5,d0
             beq.s zanf
zanf2        move.b (a0)+,d0
             cmp.b #31,d0
             bne.s zanf3
             addq.l #1,d4
             addq #1,d6
             move.b d0,(a1)+
             bra.s zanf2
zanf         move.b (a0)+,d0
             beq.s zanfret          ;fertig
             cmp.b #31,d0           ;FÅllbyte
             beq.s zanf             ;auslassen
zanf3        addq.l #1,d4
             addq #1,d6
             move.b d0,(a1)+
             cmp.b #27,d0           ;Steuerzeichen
             bne.s zanf
             move.b (a0)+,(a1)+
             addq.l #1,d4
             subq #1,d6             ;war eins zuviel
             bra.s zanf
zanfret      move.b #0,(a1)+
             addq.l #1,d4
             move.l d4,lentxt
             move d6,lenasc
zanfrt       rts

nochz        subq.l #1,a1           ;Endemarke
             subq.l #1,d4
             bsr.s trenspac
             pea (a1)
             bsr txtort
             bsr lîschz             ;Textzeile entfernen
             move.l (a7)+,a1
             bra.s zeianf           ;nÑchste Zeile anhÑngen

trenspac     move.b -1(a1),d0
             cmp.b #"-",d0
             bne.s ts
             moveq #1,d0
             sub.l d0,a1            ;"-" entfernen
             sub.l d0,d4
             sub d0,d6
             rts
ts           lea trennzei,a0
             bsr suchbyt            ;Trennzeichen ?
             beq.s tsp0
             move.b #32,(a1)+       ;sonst Space einfÅgen
             addq.l #1,d4
             addq #1,d6
tsp0         rts

lîschz       add.l d0,a0            ;Beginn nÑchste Zeile
             addq.l #2,d0           ;fÅr Zeiger ZeilenlÑnge
             neg.l d0
             subq #1,-24(a6)        ;Zeilengesamtzahl
             bra ltrans             ;Zeile lîschen

langwrap     move lenasc,d6
             move.l lentxt,d3
             lea -1(a5,d3.l),a2
             move -18(a6),d4        ;erlaubte ZeilenlÑnge
             cmp d4,d6
             bgt.s lw0              ;zu groû,also Umbruch
             subq.l #1,a2
             clr trfl
             bra uebtr
lw0          move d6,d5
lw1          subq #1,d3
             move.b -(a2),d0
             beq.s lw1              ;doppelte Endemarke
             cmpi.b #27,-1(a2)      ;Steuerzeichen
             bne.s lw3              ;nein
             subq #1,d3
             subq.l #1,a2
             bra.s lw1
lw3          subq #1,d5
             beq lwganz             ;kein Trennzeichen in Zeile
             cmp d4,d5
             bgt.s lw1              ;Zeile ist noch zu lang
             bne.s lw4
             move.l d3,kptxt
             cmp.b #32,d0           ;nur Space erlaubt
             bne.s lw1
             move.b #0,(a2)
             subq #1,d6
             bra.s uebertrag
lw4          lea trennzei,a0
             bsr suchbyt            ;Trennzeichen ?
             bne.s lw1              ;nein
             addq #1,d5
uebertrag    move d5,lenasc
             addq #1,d3             ;fÅr Endemarke
             move.l d3,lentxt
             tst trenn
             beq uebtr
             clr trfl
             sub d5,d4
tr           lea 1(a2),a3
             moveq #0,d2
tr0          cmp #3,d4
             blt uebtr              ;Silbe + "-" mind. 3 Byte
tr1          moveq #0,d7            ;ZÑhler Zeichen
tr2          move.b (a3)+,d0
             addq #1,d3
tr3          subq #1,d4
             ble uebtr              ;erlaubtes Zeilenende erreicht
             addq #1,d5             ;lenasc
             addq #1,d7             ;SilbenlÑnge
             lea vokal,a0
             bsr suchbyt
             beq.s tr4
             move.b -1(a3),d0       ;Zeichen nochmals holen
             lea konson,a0
             bsr suchbyt
             bne uebtr
             bra.s tr2
tr4          lea -1(a3),a4          ;Zeiger auf Vokal
             move.b (a3)+,d0        ;nÑchstes Zeichen
tr5          lea vokal,a0
             bsr suchbyt
             beq.s tr5a
             subq.l #1,a3
             bra.s tr9
tr5a         move.b (a4),d1         ;Zeichen nach d1
             lsl #8,d1              ;verschieben
             move.b 1(a4),d1        ;nÑchstes Zeichen dazu
             lea doppelv,a0
             bsr suchword
             bne.s tr7
             subq #1,d7             ;Doppelvokal
tr6          lea 1(a4),a3
             bra.s tr2
tr7          cmp #2,d7
             blt.s tr6              ;Silbe zu kurz
tr8          move.b (a3)+,d0
             lea trennzei,a0
             bsr suchbyt            ;Wortende suchen
             bne.s tr8
             sub.l a4,a3
             sub.l d2,a3
             cmp #4,a3
             blt uebtr              ;Silbe nach Trennung zu kurz
             move.l d3,lentxt
             move d5,lenasc
             move.l a4,a2
             move #1,trfl           ;anmerken Trennung gefunden
             bra tr                 ;nach weiterer Trennung suchen
tr9          move.b (a3)+,d0
             lea konson,a0
             bsr suchbyt
             beq.s tr9
tr10         move.b -(a3),d0
             lea vokal,a0
             bsr suchbyt
             bne.s uebtr
             move.l a3,d0
             sub.l a4,d0
             subq #2,d0
             beq.s tr7
             move.b -2(a3),d1
             lsl #8,d1
             move.b -1(a3),d1
             cmp #"st",d1
             beq.s trst
             cmp #"ch",d1
             beq.s trch
             cmp #"ck",d1
             beq.s trck
tr11         sub d0,d4
             ble.s uebtr
             add.l d0,a4
             add d0,d7
             add d0,d3
             add d0,d5
             bra tr7
trch         subq #1,d0
             beq tr7
             cmp.b #"s",-3(a3)
             bne.s tr11
trst         subq #1,d0
             bra.s tr11
trck         move.b #"k",-2(a3)
             bra.s tr11
uebtr        sub lenasc,d6
             bpl.s uet
             moveq #0,d6
uet             move d6,ascrest
             move d6,idfl
             lea puffer,a1
             move.l (a5),(a1)
             btst #5,flag           ;Zeile mit neuem Absatz ?
             bne.s ut0a
             andi.b #$c0,(a1)       ;fester Absatz & Blockende
             andi.b #63,(a5)        ;in alter Zeile lîschen
             bra.s ut0
ut0a         bclr #7,(a1)
ut0          move.l 4(a5),4(a1)     ;Zeilenhîhe & LÑnge Åbernehmen
             addq.l #7,a1
             lea 1(a2),a0
ut           move.b (a0)+,(a1)+     ;Zeichen ab Kursor retten
             bne.s ut
ut2          tst trfl               ;Trennung setzen ?
             beq.s ut2a
             addq.l #1,a2
             move.b #"-",(a2)       ;Trennzeichen setzen
             addq #1,lenasc
             addq.l #1,lentxt
ut2a         move.b #0,1(a2)        ;Endemarke in aktwort setzen
             suba.l #puffer,a1
             move.l a1,zeirest      ;LÑnge des Zeilenrestes
             lea 7(a5),a2
             move.b 1(a5),d5        ;Schrift am Zeilenanfang
             btst #5,flag
             beq.s ut3
             clr d5
             bra.s ut4
ut3          move.b (a2)+,d0
             beq.s ut4              ;Ende gefunden
             cmp.b #27,d0
             bne.s ut3
             bsr txtsteuer          ;Steuerzeichen auswerten
             bra.s ut3
ut4          move.b d5,puffer+1     ;und eintragen
ut5          rts
lwganz       move.l kptxt,d3
             subq.l #1,d3
             lea -1(a5,d3.l),a2
             move -18(a6),d5
             bra uebertrag

formatiere   move -18(a6),d7
             sub lenasc,d7          ;Gesamtzahl FÅllbuchstaben
             move.l lentxt,d0
             lea -1(a5,d0.l),a1;0     ;Zeilenende
fmt3         move.b -(a1),d0
             beq.s fmt3
             cmp.b #32,d0           ;letztes Zeichen Space
             bne.s fmt5
             tst d7
             bne.s fmt4
             move #1,idfl           ;ZeilenlÑnge = erlaubter LÑnge
fmt4         addq #1,d7             ;dann ein FÅllbuchstabe mehr
             move.b #0,(a1)         ;Space lîschen
             bra.s fmt3
fmt5         move zeile,d1
             addq #1,d1
             cmp -14(a6),d1
             bne.s fmt7
             tst ascrest
             bne.s fmt7
             lea trennzei,a0
             bsr suchbyt
             beq.s fmt7
             move.b #32,1(a1)
fmt7         tst d7
             beq.s fmtnl            ;nichts zu formatieren
fmtz         tst zentr              ;zentrieren ?
             beq.s fmtb             ;nein
             lsr #1,d7
             beq.s fmtnl
             bra.s fmtre
fmtb         tst blocks
             beq.s fmtr
             btst #7,(a5)           ;Fester Absatz
             bne.s fmtnl            ;ja, kein Blocksatz
             btst #5,flag           ;letzte Eingabe CR ?
             bne.s fmtnl            ;auch kein Blocksatz
             tst idfl
             beq.s fmtnl
fmtb1        moveq #8,d3            ;Zeilenbeginn
             add einrÅ,d3
fmtb2        move.b (a5,d3.l),d0
             beq.s fmtb1            ;Zeilenende
             addq #1,d3
             cmp.b #32,d0
             bne.s fmtb2
             move.l lentxt,d4
             moveq #31,d2
             bsr einfÅgen
             subq #1,d7
             bne.s fmtb2
             bra.s fmtnl
fmtr         btst #1,flag           ;rechtsbÅndig ?
             beq.s fmtnl
             btst #7,(a5)
             bne.s fmtre
             tst idfl
             beq.s fmtnl
fmtre        moveq #7,d2
             bsr.s fb0
fmtnl        bsr zeilÅ
             beq.s fmtnxt
             clr ascrest
             bset #6,(a5)
             rts                    ;abbrechen,da Speicher voll
fmtnxt       addq #1,-14(a6)
fmtret       bclr #5,flag
             rts

fb0          move.l d2,d3
             move.l lentxt,d4
             moveq #31,d2
             subq #1,d7
fb1          bsr einfÅgen
             dbra d7,fb1
             rts

 end
 