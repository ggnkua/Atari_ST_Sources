mill         move.l #1000000,d1
             bsr.s bindez
htaus        move.l #100000,d1
             bsr.s bindez
ztaus        move.l #10000,d1
             bsr.s bindez
taus         move.l #1000,d1
             bsr.s bindez
hund         move.l #100,d1
             bsr.s bindez
zehn         move.l #10,d1
             bsr.s bindez
ein          move d0,d2
             bra.s dezaus
;ASCII-Wandlung
bindez       moveq #0,d2                 ;Ergebnis lîschen
\l           addq #1,d2
             sub.l d1,d0
             bhs.s \l
             add.l d1,d0            ;war einmal zuviel
             subq #1,d2
dezaus       add #48,d2             ;Ascii wandeln
             move.b d2,(a0)+        ;speichern
             rts
;Nullen ersetzen
killnull     cmpi.b #48,(a0)        ;Null ?
             bne.s rt1
             move.b #32,(a0)+       ;ersetzen
             subq.b #1,d0
             bne.s killnull
rt1          rts
;Wandlung String - BinÑr
dezbin       moveq #0,d0            ;Ergebnis lîschen
             moveq #0,d1
             moveq #0,d2            ;keine Zahl
\l0          move.b (a0)+,d1
             cmp.b #32,d1
             beq.s \l0              ;Spaces Åberlesen
             bra.s \l2
\l1          move.b (a0)+,d1        ;Zahl holen
\l2          sub.b #48,d1
             bmi.s \sto             ;keine Zahl
             cmp.b #10,d1
             bpl.s \sto             ;keine Zahl
             moveq #1,d2            ;Zahl gefunden
             mulu #10,d0
             add d1,d0
             bra.s \l1
\sto         rts
;Suchroutinen, Begriffe
suchwort     move.l a1,a2           ;Zeiger auf Vergleichswort
\l0          move.b (a2)+,d1
             beq.s suret            ;Wort gefunden
             subq #1,d0
             bmi.s suret            ;nicht da
             cmp.b (a0)+,d1
             beq.s \l0
             bra.s suchwort         ;Zeiger erneuern
suret        rts
;2-Byte-Ausdruck
suchword     cmp (a0)+,d1
             beq ok                 ;gefunden
sw           tst (a0)
             bne.s suchword
             bra fehler             ;nicht gefunden
;Byte
suchbyt      cmp.b (a0)+,d0
             beq ok
             tst.b (a0)
             beq fehler
             bra.s suchbyt          ;weiter suchen
;Textspeicher transportieren, byteweise
transfer0    sub.l d0,free
transfer     move.l txttop,a1
\l           add.l d0,(a2)+         ;Zeiger korrigieren
             cmpa.l #txttop,a2
             ble.s \l
transfer1    move.l a1,d1
             sub.l a0,d1            ;ZÑhler
             beq.s ret
             tst.l d0
             bmi.s tf3
             lea (a1,d0.l),a0           ;Transfer nach oben
tf1          move.b -(a1),-(a0)
             subq.l #1,d1
             bne.s tf1
ret          rts
tf3          lea (a0,d0.l),a1           ;Transfer nach unten
tf4          move.b (a0)+,(a1)+
             subq.l #1,d1
             bne.s tf4
             rts
;Transfer in Langworten
ltrans       move.l aktend,a1
             sub.l d0,free
             add.l d0,aktend
ltransfer    move.l a1,d1
             sub.l a0,d1
             beq.s ltret
             btst #1,d1
             beq.s lt0
             addq.l #2,d1
             addq.l #2,a1
lt0          tst.l d0
             bmi.s ltf2
             lea (a1,d0.l),a0
ltf          move.l -(a1),-(a0)
             subq.l #4,d1
             bne.s ltf
ltret        rts
ltf2         lea (a0,d0.l),a1
ltf3         move.l (a0)+,(a1)+
             subq.l #4,d1
             bne.s ltf3
             rts
;kopieren, 0 als Ende
copy         move.b (a0)+,(a1)+
             bne.s copy
             subq.l #1,a1           ;Zeiger auf Ende der Kopie
             rts
;d0 Bytes, d0 < 32 k
copy1        bra.s c1
c0           move.b (a0)+,(a1)+
c1           dbra d0,c0
             rts
;d0 Bytes,d0 gerade
copy2        move (a0)+,(a1)+
             subq.l #2,d0
             bne.s copy2
             rts

clrpuff      lsr.l #2,d0
             moveq #0,d1
cp           move.l d1,(a0)+
             dbra d0,cp
             rts

;Programmteil mittels Tabelle wÑhlen
indjump      mulu #4,d0             ;Nr*4 als Offset
             move.l (a0,d0.l),a0    ;Ziel holen
             jmp (a0)               ;und aufrufen
;Bildschirm retten & zurÅckbringen
rettsch      bsr mausaus
             move.l base,a0
             move.l diskpuff,a1
             bra.s zae
holsch       bsr mausmaf
             bsr mausaus
             move.l diskpuff,a0
             move.l base,a1
zae          move #7999,d0          ;8000*4=Bildschirmgrîûe
schl         move.l (a0)+,(a1)+
             dbra d0,schl
             bra mausan
;freien Datensatz suchen
platz        moveq #0,d6            ;Datensatznummer
             lea txtstart,a0
frei         move.l (a0)+,d0
             cmp.l (a0),d0
             beq.s ja               ;Ende = Start also frei
             addq #1,d6
             cmp #8,d6
             bne.s frei             ;weiter suchen
             lea besetzt,a2
             bra formalert
ja           lsl #2,d6              ;Nr mal 4 = Offset
             move.l d6,psel
             bra ok
;freies Fenster suchen
fenfrei      moveq #0,d6            ;Fenster 0 bis 3 sind mîglich
             lea wiop,a0
wifrei       tst.l (a0)+
             bmi.s wifound          ;Fenster ist frei
             addq #1,d6
             cmp #4,d6
             bne.s wifrei
             lea nowin,a2
             bsr formalert
             bra  fehler
wifound      move d6,wiarb          ;Fensternummer
             bra ok

speitop      move.l $44e,base       ;logischer Bildspeicher
             move.l $436,d0         ;Ramtop
             rts
;Text îffnen
docopn       lea fenster,a1
             move wiarb,d0          ;Fensternummer
             mulu #60,d0
             add.l d0,a1            ;Adresse Fensternamen
             move.b #32,(a1)+
             lea name,a0            ;Dateinamen
             move.l psel,d0
             mulu #15,d0
             add.l d0,a0
             bsr copy
             move.b #32,(a1)+
             move.b #0,(a1)         ;Endemarke
             bsr.s txtreset
             bsr txtort
             subq.l #2,a0
             move.l a0,-36(a6)      ;Adresse 1. Zeile
             bsr aktzeile
             bsr codekur
             bsr wiopen
             move #1,opnfl
             moveq #28,d5
             moveq #72,d6
             bsr menchange1
             bra.s demglob

demark       bsr bldm
             moveq #16,d6
             bclr #6,flag
             beq.s dopret  
             bra.s dem
demglob      moveq #14,d6
             btst #6,flag
             beq.s dopret
dem          moveq #0,d5
             pea (a5)
             bsr menchange0
             cmp #16,d6
             beq.s dem1
             moveq #2,d5
             moveq #2,d6
             bsr menchange1
dem1         move.l (a7)+,a5
dopret       rts

txtreset     moveq #0,d0
             move.l d0,-4(a6)       ;first,kpos
             move d0,-6(a6)         ;change
             moveq #1,d0
             move d0,-8(a6)         ;firstj
             move d0,-12(a6)        ;spa
             moveq #2,d0
             move d0,-10(a6)        ;firsti
             move d0,-14(a6)        ;zei
             rts
;Seitenlayout festlegen
neuformat    move.l #24,baumnr
             move #0,erstobj
             move #4,editobj
             move.l aktbeginn,a5
             move #1,stellen
             move #4,inindex
             move.l 20(a5),d5       ;Rand links
             bsr binin
             move #5,inindex
             move.l 24(a5),d5       ;Rand rechts
             bsr binin
             move #2,stellen
             move #6,inindex
             move.l (a5),d5         ;SeitenlÑnge
             bsr binin
             bsr draw
             move #7,erstobj        ;ibox
zeiglay      pea (a5)
             move #25,inindex
             move.l (a5)+,d6
             move #12,inindex
einschl      move.l (a5)+,d5
             sub.l d5,d6
             bsr binin              ;Seitenmaûe
             subq #1,inindex
             cmp #8,inindex
             bne.s einschl
             move.l d6,d5
             bmi.s f0
             bsr binin              ;Textzeilen/Seite
f0           bsr drawt
             bsr formdo
             move.l (a7)+,a5
             cmp #2,d2
             ble.s formret
             move d2,-(a7)
             move #6,inindex
             bsr binout
             move.l d0,(a5)
             move (a7)+,d2
             moveq #1,d1            ;+1
             btst #0,d2
             beq.s f1               ; war gewÑhlt
             moveq #-1,d1           ;-1
             addq #1,d2
f1           sub #18,d2             ;d2=2,4,6,8
             mulu #2,d2             ;MSW wird gelîscht
             add.l d1,(a5,d2.l)
             bpl.s f2
             sub.l d1,(a5,d2.l)     ;keine negativen Werte erlaubt
             bra.s zeiglay
f2           lsr.l #2,d0            ;SeitenlÑnge durch 4
             cmp.l (a5,d2.l),d0
             bge.s zeiglay
             move.l d0,(a5,d2.l)    ;RÑnder hîchstens 1/4 der Seitenl
             bra zeiglay
formret      beq.s formend
             move #4,inindex
             bsr binout             ;Rand links
             move.l d0,20(a5)
             move #5,inindex
             bsr binout             ;Rand rechts
             move.l d0,24(a5)
             bsr txtzeilen
             lea seitenm,a0
             moveq #6,d0
f3           move.l (a5)+,(a0)+
             dbra d0,f3
formend      bra holsch
;Text schlieûen
txtcl        tst opnfl              ;Text offen
             beq.s tcret            ;nein
             moveq #28,d5
             moveq #72,d6
             bsr menchange0
tc1          lea txtstart+4,a2
             add.l sel,a2
             move.l (a2),a0         ;Beginn nÑchster
             move.l free,d0
             neg.l d0
             bsr transfer           ;Speicher freigeben
             clr opnfl
tcret        rts
;Text îffnen
txtopn       tst opnfl
             bne.s toret
             lea txtstart+4,a2
             add.l psel,a2
             move.l -4(a2),a6
             move.l a6,aktbeginn
             lea 68(a6),a6
             moveq #28,d5
             moveq #72,d6
             bsr menchange1
to1          move.l (a2),a0         ;Beginn nÑchster Text
             move.l a0,aktend       ;= Ende des benutzten Textes
             move.l free,d0
             bsr transfer           ;Speicher zuordnen
             move #1,opnfl
toret        rts
;Text oder Tabelle auswÑhlen
auswahl      move.l #12,baumnr
             moveq #5,d2
             moveq #13,d7
             bsr namin
             cmp #1,idfl
             bne.s aw
             move grkl,d0
             bra.s aw1
aw           clr.l erstobj
             bsr formular
             bne fehler
             move #130,d1
             bsr selindex
aw1          lsl #2,d0              ;*4
             move.l d0,d1           ;=sel
             mulu #15,d0            ;Offset fÅr Namen
             lea name,a0
             add.l d0,a0            ;erweiterter Name
             tst.b (a0)
             beq fehler             ;Kein Namen,also auch keine Datei
             move.l d1,psel
             bsr wortend
aw4          cmp.b #92,-(a1)
             bne.s aw4
             addq.l #1,a1           ;Beginn eigentlicher Name
             bra ok

datnam       lea datei,a0
             lea name,a1
             move.l psel,d0
             mulu #15,d0            ;16 Byte fÅr Dateinamen
             add.l d0,a1
             bra copy               ;Namen sichern

fenhandle    moveq #-1,d3
             lea wihand,a0
fh           addq #1,d3
             cmp #4,d3
             beq fehler             ;kein Programmfenster
             cmp (a0)+,d7           ;d7=wihandle
             bne.s fh
             move d7,akthand
             move d3,wiarb
             bra ok

printzahl    bsr.s formzahl
             bra vtxt

formzahl     lea puffer,a0
formzahl1    pea (a0)
             lea ein,a1
             move stellen,d1
             mulu #8,d1
             sub.l d1,a1
             jsr (a1)
             move.b #0,(a0)           ;Endemarke
             move.l (a7)+,a0
             move stellen,d0
             bra killnull
;Druckercode in Tabelle suchen
codeort0     move.l druckcod0,a0
             bra.s codeort
codeort1     move.l druckcod1,a0
codeort      moveq #0,d0
             bra.s co
co0          add.l d0,a0
co           move.b (a0),d0
             dbra d6,co0
cdret        rts
;File auf Disk ?
suchfile   sfirst #0,(a1)
             tst d0
             beq.s firet
             bsr formalert         ;Datei nicht gefunden
             tst d0
firet        rts
;Datei îffnen und Daten in Puffer holen
openin       bsr mausf2
           getdta
             move.l d0,dta          ;Adresse DTA-Buffer
             add.l #30,d0           ;Adresse Filenamen
             clr -(a7)
             move.l d0,-(a7)
             move #$3d,-(a7)        ;open
             trap #1
             addq.l #8,a7
             tst d0
             bmi.s lesef
             move d0,diskhand       ;handle speichern
             move.l dta,a0
             move.l 26(a0),d1       ;Dateigrîûe holen
             move.l d1,d3           ;sichern
             move.l #$10000,d2
             cmp.l d1,d2
             bcc.s \l3              ;Datei ist < als 64 k
             exg d1,d2
\l3          sub.l d1,d3            ;Zahl zu lesender Bytes
             move.l d1,bytes
             move.l d3,rest         ;verbleibender Rest
             move.l diskpuff,a0

liesdisk     move.l a0,-(a7)        ;Ablageadresse
             move.l d1,-(a7)        ;Anzahl Bytes
             move diskhand,-(a7)    ;handle
             move #$3f,-(a7)        ;read
             trap #1
             lea 12(a7),a7
             tst.l d0
             bpl ok
lesef        bsr.s closedisk
             lea readerr,a2
             bra formalert

closedisk  close diskhand
             bra mausf0

zeilenend    move.b #0,(a1)+        ;Endemarke
             addq #1,d7
             btst #0,d7
             beq.s zl0              ;bereits gerade
             move.b #0,(a1)+
             addq #1,d7
zl0          move.l txtzg,a0
             move d7,(a0)           ;LÑnge speichern
             move.l a1,txtzg
zeret        bra ok

ladeasc      bsr wpinit
             move.l filezg,a0       ;Zeiger in Diskpuffer
at1          subq.l #1,bytes
             bmi.s puffleer         ;alles gelesen ?
             move.b (a0)+,d0
             beq.s atfÅll
             cmp.b #13,d0           ;Zeilentrennung ?
             bne.s at4
             cmp.b #10,(a0)         ;nÑchstes Zeichen LF ?
             bne.s atfÅll           ;nein,weiter auswerten
             addq.l #1,a0
at2          move.l a0,filezg
             bsr.s zeilenend
             bne.s atret            ;Speicher ist voll
             subq #8,d7
             cmp -18(a6),d7
             ble.s at3
             move d7,-18(a6)
at3          move.l a1,txtzg
             subq.l #1,bytes        ;fÅr LF
             beq.s pleer
             addq #1,-24(a6)        ;noch eine Zeile
             bra.s ladeasc
at4          cmp.b #27,d0
             blt.s at5
             cmp.b #31,d0
             bgt.s at5
atfÅll       moveq #32,d0           ;0 und 27-30 ersetzen
at5          move.b d0,(a1)+        ;Zeichen speichern
             addq #1,d7
             cmp #261,d7
             bne.s at1              ;ZeilenlÑnge <255
             addq.l #1,bytes
             bra.s at2              ;Zeilenende setzen
pleer        moveq #0,d7            ;anmerken Zeile fertig
puffleer     move.l rest,d1
             beq.s atfert           ;nichts mehr zu laden
             pea (a1)               ;Zeiger in Zeile retten
             move.l diskpuff,a0
             move.l a0,filezg       ;neu setzen
             bsr.s ldisk            ;nÑchsten Block lesen
             move.l (a7)+,a1        ;Zeiger zurÅck
             bne.s atfert           ;lesefehler
             addq #1,-24(a6)
             tst.l d7
             beq ladeasc            ;neue Zeile
             subq #1,-24(a6)
             move.l filezg,a0       ;sonst alte Zeile
             bra at1                ;fertig schreiben
atfert       tst.l d7
             bne zeilenend          ;erst Zeilenende bilden
atret        rts

ldisk        move.l #32000,d0
             cmp.l d0,d1
             ble.s ldi
             move.l d0,d1
ldi          move.l d1,bytes
             sub.l d1,rest
             bra liesdisk           ;nÑchsten Block lesen

wpzeile      move.l filezg,a1
             move.l a1,a4
             moveq #0,d1
wz           subq.l #1,bytes
             bmi.s wz2              ;Puffer ist leer
             cmp.b #13,(a1)+
             beq.s wz1
             addq #1,d1
             bra.s wz
wz1          addq.l #1,a1           ;fÅr LF
             subq.l #1,bytes
             move.l a1,filezg
             bra ok
wz2          move.l rest,d1
             beq fehler             ;alles gelesen
             move.l diskpuff,a1
             move.l a4,a0
             move.l d1,d3           ;LÑnge retten
             bsr copy1              ;Zeilenrest an Pufferbeginn
             move.l a1,a0           ;Ablageort fÅr Dateirest
             bsr.s ldisk            ;Block lesen
             move.l d3,d1           ;ZeilenlÑnge
             move.l diskpuff,a4     ;Zeilenanfang
             bra.s wz               ;weiter lesen

wpsform      move.l a4,a0           ;Formatwerte lesen
             lea puffer,a1
             bsr copy1
             move.l a0,a4
             move.b #0,(a1)         ;Endemarke
             lea puffer,a0
             bsr dezbin
             tst d2
             beq fehler             ;war keine Zahl
             move.l txtzg,a0
             move.l d0,(a0)+
             move.l d0,d1
             move.l a0,txtzg
             bra ok

wpkopf       bsr.s wpinit
             bsr wpzeile            ;Zeilengrîûe holen
             addq.l #2,a4           ;'31,49/50' Åberlesen
             subq #2,d1
             add d1,d7
             move d1,d0
             move.l a4,a0
             move.l a3,a1
             bsr copy1
             bsr zeilenend
             move.l a1,txtzg
             rts

wpinit       lea neuzeil,a0
             move.l txtzg,a1
             moveq #9,d0
             bsr copy1
             moveq #7,d7            ;ZeilenlÑnge
             move.l a1,a3
             rts

wplineal     subq #1,d1
             cmp.b #"]",-(a1)       ;Linealende ?
             bne.s wplineal
             addq #1,d1
             move.b 1(a1),d0
             sub.b #42,d0           ;in 6-9 wandeln
             bpl.s wpl0
             moveq #6,d0
wpl0         move.b d0,nzeile       ;und speichern
             move d1,fenbr          ;LÑnge speichern
             rts

ypos         move -14(a6),d3        ;Zeilennummer
ypos1        moveq #0,d0
             move -10(a6),d1        ;erste Fensterzeile
             move.l -36(a6),a0      ;Adresse
             move ystart,d2
yp0          cmp d1,d3
             beq.s yp1              ;fertig
             move 4(a0),d0
             mulu schrhî,d0
             add d0,d2              ;+ Zeilenhîhe
             addq #1,d1
             move (a0)+,d0
             add.l d0,a0
             bra.s yp0
yp1          move d2,d3
             move 4(a0),d0
             mulu schrhî,d0
             add d0,d3              ;ykur
ypret        rts

kursor       move wiakt,d0
             cmp wiarb,d0
             bne.s ypret            ;nicht aktuelles Fenster
             bsr mausaus
             bsr setwrmod3
             move.l #$10000,-(a7)
             move.l #$10001,-(a7)
             bsr vsfpara
             lea ptsin,a3
             move.l xkur,d0
             addq #2,d0
             move.l d0,(a3)+
             add.l #$80001,d0
             sub zlabst,d0
             move.l d0,(a3)
             bsr recfl
             bsr setwrmod1
             bra mausan

txtbeginn    clr d5
             move.b 1(a5),d5        ;GÅltige Schriftform
tbg0         moveq #7,d2            ;Textbeginn
tb0          cmpi.b #28,(a5,d2.l)   ;Grafik ?
             bne.s tbret
             add.l 1(a5,d2.l),d2
             bra.s tb0
tbret        rts

zeilÅ        lea aktwort,a5
             move.l lentxt,d7
             lea (a5,d7.l),a0
             bra.s zÅ

zeilÅber     lea aktwort,a5
             bsr killend            ;ÅberflÅssige Zeichen lîschen
zÅ           btst #0,d7
             beq.s zÅ1
             addq #1,d7             ;lentxt muû gerade sein
             move.b #0,(a0)+
zÅ1          bsr txtort
             pea (a0)               ;Zeilenbeginn retten
             move.l d0,d1
             sub.l d7,d0            ;alte LÑnge - neue
             beq.s zÅ2              ;Platzbedarf unverÑndert
             neg.l d0
             cmp.l free,d0
             bge.s zÅfehl
             move d7,-2(a0)         ;neue LÑnge eintragen
             move.l d7,lentxt
             add.l d1,a0            ;Beginn nÑchste Zeile
             bsr ltrans             ;Platz schaffen
zÅ2          move.l (a7)+,a1        ;Zeilenbeginn
             move.l a5,a0
             move.l d7,d0
             bsr copy1              ;Zeile eintragen
             bra ok
zÅfehl       add.l d0,free
             lea ramfull,a2
             bsr formalert
             bra fehler

killend      move.l a5,a0
             add.l lentxt,a0
zÅ0          move.b -(a0),d0
             beq.s zÅ0
             subq #1,lenasc
             cmp.b #32,d0
             beq.s zÅ0
             addq #1,lenasc         ;einmal zuoft abgezogen
             move lenasc,d6
             addq.l #1,a0
             move.b #0,(a0)+        ;neue Endemarke
             move.l a0,d7
             sub.l a5,d7
             rts

;Textzeilenadresse suchen
txtort       move -14(a6),d1        ;Zeilennummer
txtort1      move.l a6,a0
txo          move.l (a0)+,d0
             beq.s noch
             addq.l #1,d0
             and #$fffe,d0
             add.l d0,a0
             bra.s txo
noch         add.l d0,a0
             move (a0)+,d0          ;StringlÑnge
             dbra d1,noch
             rts

butzeile     move -10(a6),d4        ;erste Fensterzeile
             move.l -36(a6),a3      ;Adresse
             move -20(a6),d2        ;Druckort
             move (a3)+,d3          ;ZeilenlÑnge
             ext.l d3
bz0          cmp d2,d1              ;Mausy
             bhi.s bz1
             bra ok                 ;Zeile gefunden
bz1          addq #1,d4             ;nÑchste Zeile
             cmp -24(a6),d4         ;letzte Textzeile
             ble.s bz2
             cmpi.l #10,free
             ble zÅfehl             ;kein Platz
             move.l aktend,a1
             bsr zeilin
             lea xmax,a0
             move schrhî,d0
             add d0,d0
             add d0,d2
             bra.s bz0
bz2          add.l d3,a3            ;Adresse
             move (a3)+,d3          ;LÑnge
             move 2(a3),d0
             mulu schrhî,d0
             add d0,d2              ;druckort
             bra.s bz0
;Leerzeichen anhÑngen
spaceanf     lea aktwort,a0
             add.l kptxt,a0
             moveq #32,d2
             bra.s spa2
spa          move.b d2,(a0)+
             addq.l #1,kptxt
             addq.l #1,lentxt
             addq #1,lenasc
spa2         dbra d0,spa
             move.b #0,(a0)         ;Endemarke
             rts
;Textzeilen pro Seite
txtzeilen    move.l aktbeginn,a1
             move.l (a1)+,d0        ;SeitenlÑnge
             moveq #3,d1
ab           sub.l (a1)+,d0
             dbra d1,ab
             add.l d0,d0            ; *2
             mulu schrhî,d0
             move d0,-30(a6)
             rts

grafik       move d4,d1
             bsr txtort1
             moveq #7,d2
grf          cmp.b #28,(a0,d2.l)
             bne fehler             ;
             move 5(a0,d2.l),d0     ;linker Bildrand
             cmp d3,d0
             bgt.s grf0             ;nicht dieses Bild
             add 7(a0,d2.l),d0      ;rechter Rand
             cmp d3,d0
             bge ok                 ;gefunden
grf0         add.l 1(a0,d2.l),d2
             bra.s grf

invert       bsr kursor
             bsr mausaus
             bsr zielgr             ;Grenzen fÅr Blocktransfer
             move 9(a5,d2.l),d3     ;Zeilennummer
             move zlabst,d4
             mulu d4,d3
             sub d3,d1
             cmp 6(a1),d1           ;ystart
             bgt.s inv
             move 6(a1),d1
inv          move d1,10(a0)
             move 11(a5,d2.l),d3    ;Nummer letze Grafikzeile
             sub 9(a5,d2.l),d3
             mulu d4,d3
             add d3,d0
             cmp 2(a1),d0           ;ymax
             ble.s inv0
             move 2(a1),d0
inv0         move d0,14(a0)
             move.l 8(a0),(a0)      ;Quelle=Ziel
             move.l 12(a0),4(a0)
             move #10,intin         ;invertieren
             bsr bitbl              ;ausfÅhren
             bsr kursor
             bra mausan

blokor       move -14(a6),d0        ;neu zeichnen ab aktueller Zeile
             cmp blan,d0
             ble.s ist
             cmp blen,d0
             ble.s ist0
             rts
ist          addq #1,blan
ist0         addq #1,blen
             rts

bildneu      move.l diskpuff,a1
             bsr txtort
             subq.l #2,a0
             move.l a0,filezg       ;Beginn Grafikblock
             move grazeil+20,d1     ;ZeilenzÑhler
bn           bsr bildein
             dbra d1,bn
             move.l a1,d0
             sub.l diskpuff,d0
             move d0,-(a7)          ;neue Blockgrîûe
             sub.l a0,d0
             add.l filezg,d0        ;Platzbedarf
             bsr ltrans
             move.l filezg,a1
             move.l diskpuff,a0
             move (a7)+,d0
             bra copy1              ;Block eintragen

bildein      move d0,-(a7)
             moveq #9,d0
             bsr copy1              ;Zeilenkopf mit ZeilenlÑnge
             addi #16,-9(a1)        ;neue ZeilenlÑnge
             pea (a0)
             lea grazeil+9,a0
             moveq #16,d0
             bsr copy1              ;Grafikzeilenheader
             addq #1,grazeil+18     ;Zeilennummer +1
             move.l (a7)+,a0
             move (a7)+,d0
             subq #7,d0
             bsr copy1              ;Zeilenrest
             move (a0),d0           ;LÑnge nÑchste Zeile
             rts

neuhead      lea grazeil+14,a1
             moveq #10,d0
             bsr copy1
             clr grazeil+18          ;Zeilennr
             rts

anfend       move blan,d0
             cmp blen,d0
             beq.s ae0
             blt.s ae
             move blanx,d1
             move blen,blan
             move blenx,blanx
             move d0,blen
             move d1,blenx
ae           rts
ae0          move blenx,d0
             cmp blanx,d0
             bge.s ae
             move blanx,blenx
             move d0,blanx
             rts

setkur       bsr zeilÅber           ;Zeile Åbernehmen
             bsr kursor             ;kursor lîschen
             move nzeile,-14(a6)    ;akt. Zeile
             move kpos,-2(a6)       ;und Kursorposition setzen
             bsr aktzeile           ;Zeile aktuell machen
             bsr codelin            ;Schriftform & kptxt holen
             move kpos,d0
             sub lenasc,d0
             ble.s tf2              ;Kursor ist in Zeile
             move kpos,-2(a6)
             bsr spaceanf           ;Spaces anfÅgen
tf2          bsr kurkoord
             bra kursor

neuadr       move 14(a2),d7         ;IMG Pixelhîhe
             move d7,d1
             ext.l d1
             divu 10(a2),d1         ;durch Pixel/Zeile
             cmp.l #$ffff,d1        ;Rest ?
             ble.s nad
             addq #1,d1             ;eine Zeile mehr
nad          move 12(a2),bytes      ;IMG Breite in Byte
             lea 16(a2),a0          ;Beginn Bilddaten
             bsr pzadr              ;Zeilenadressen im IMG suchen
             pea (a1)               ;Grîûe Adressspeicher
             move.l (a2),d0         ;LÑnge IMG
             add.l a1,d0
             move.l d0,-4(a2)       ;Gesamtgrîûe Bild
             move.l ersadr,d1       ;alte Bildgrîûe
             lea (a2,d1.l),a0
             sub.l d1,d0
             bsr ltrans
             move.l a2,a1
             add.l (a1),a1          ;Beginn Adressbereich
             move.l (a7)+,d0        ;LÑnge Adressbereich
             move.l diskpuff,a0
             bra copy1

 end

 