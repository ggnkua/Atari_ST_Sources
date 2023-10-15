editor       and.l #$ff00,d2        ;MSW ausblenden
             lsr #8,d2              ;Scancode ins Lowbyte
             tst maus
             beq.s ed1              ;Maus ist aus
             bsr mausaus
             clr maus               ;anmerken 'Maus aus'
ed1          bsr kursor
             lea aktwort,a5         ;Beginn der akt. Zeile
             move mbuff+22,d7       ;Kstate
             move.l kptxt,d3
             move.l lentxt,d4
             move -2(a6),d5         ;Kursorposition
             move lenasc,d6
             cmp #58,d2
             blt tasttab
             cmp #95,d2
             bgt tasttab0
             sub #58,d2             ;F1=59
             cmp #26,d2
             bge sfu                ;Floskeln
             move.l d2,d0
             lea jumptab4,a0
             lea steuer0,a1
             bsr indjump
edret        rts
tasttab0     cmp #114,d2
             ble.s tt0
             sub #80,d2
tt0          sub #38,d2
tasttab      subq #1,d2
             lea tastbel,a0
             tst d7
             beq.s norma
             cmp #4,d7
             bmi.s shift
             cmp #8,d7
             beq.s alter
             blt.s norma
             cmp #12,d7
             bge.s norma
             lea 76(a0),a0          ;alternate-shift
alter        lea 76(a0),a0          ;alternate
shift        lea 77(a0),a0          ;shift
norma        add.l d2,a0            ;normal
             move.b (a0),d2
             beq zeige
             cmp #28,d2
             beq backsp
             cmp #29,d2
             beq tab
             cmp #13,d2
             beq return
             cmp #27,d2
             beq escape
             cmp #30,d2
             beq undo
             cmp #31,d2
             beq help
txtzeich     bsr capslock
tz0          move d5,d7             ;zeigen ab d7=kpos+first
             cmp d5,d6              ;Zeilenende ?
             beq.s tz1              ;ja
             btst #0,flag           ;EinfÅgen ?
             bne.s tz2              ;Nein
tz1          bsr.s bytein           ;Platz fÅr ein Byte besorgen
             addq.l #1,lentxt
             addq #1,lenasc
tz2          move.b d2,(a5,d3.l)    ;Wert Eintragen
             moveq #1,d0
             bsr blomark            ;wenn nîtig blanx,blenx korrigieren
             addq.l #1,kptxt
             addq #1,-2(a6)
             addq #8,xkur1          ;neue Kursorposition
             move 4(a5),d0
             subq #1,d0
             cmp d0,d5
             blt zeige1             ;kpos<mlen
             beq.s tz4
             tst trenn
             beq.s tz3              ;keine Trennhilfe
tz4          move d2,d0
             lea trennzei,a0
             bsr suchbyt
             bne zeige1
tz3          bsr wrap
             bra zeige1

kill         addq #1,d3
             moveq #-1,d0
             bra.s be0
bytein       moveq #1,d0
be0          lea (a5,d3.l),a0
             lea (a5,d4.l),a1
             bra transfer1          ;Platz schaffen

backsp       tst d5
             bne.s bs0              ;nicht Zeilenanfang
             move -14(a6),d0
             cmp #2,d0
             blt zeige              ;Kopf oder Fuû
             cmp firstzei,d0
             beq zeige              ;Textanfang
             cmp.b #28,7(a5)
             beq zeige
             bsr zeilÅber           ;Text Åbernehmen
             subq #1,-14(a6)        ;vorhergehende Zeile
             bsr aktzeile           ;zur aktuellen machen
             move lenasc,-2(a6)     ;lenasc als kurpos
             bra.s dl0
bs0          cmp.b #27,-2(a5,d3.l)
             bne.s bs1
             subq #2,d3
             bra.s bs0
bs1          subq #1,d5
             subq #8,xkur1
             subq #8,xkur
             subq #1,d3
             subq #1,-2(a6)
             bra.s dl3

delete       cmp d5,d6
             bhi.s dl3              ;nicht am Zeilenende
             move -14(a6),d0        ;aktuelle Zeile
             cmp #2,d0
             blt zeige
             cmp.b #28,7(a5)        ;Grafik ?
             beq zeige
             cmp -24(a6),d0
             beq zeige              ;= letzte Zeile
             bsr zeilÅber
dl0          bsr txtort
             add.l d0,a0            ;Anfang nÑchster Zeile
             move (a0),d0           ;LÑnge nÑchste Zeile
             lea 9(a0),a0           ;ZeilenlÑnge und Beschreibung
             subq #7,d0             ;nicht Åbertragen
             move.l a5,a1
             subq.l #1,lentxt       ;Endemarke
             add.l lentxt,a1        ;Zeilenende
             tst.b -1(a1)
             bne.s dl2
             subq.l #1,a1           ;doppelte Endemarke
             subq.l #1,lentxt
dl2          add.l d0,lentxt        ;lÑnge korrigieren
             bsr copy1              ;folgende Zeile anhÑngen
             bsr zeilÅber           ;und Åbernehmen
             bsr txtort
             add.l d0,a0
             move (a0)+,d0          ;ÅbernÑchste Zeile
             bra.s fua0             ;lîschen und neu zeichnen
dl3          move d5,d7
             bsr killetter
             bsr codekur
             moveq #-1,d0
             bsr blomark            ;blockmarkierung korrigieren
             bra zeige1

fu10         move -14(a6),d0
             cmp #2,d0
             blt zeige
             bgt.s fua
             cmp -24(a6),d0
             beq zeige
fua          cmp.b #28,7(a5)
             beq zeige
             bsr txtort
             move -4(a6),-2(a6)     ;kurpos=first
fua0         bsr lîschz             ;Zeile lîschen
             move -14(a6),d0        ;Nummer aktuelle Zeile
             cmp.b #64,flag
             blt.s fua3
             cmp blan,d0
             blt.s fua1
             cmp blen,d0
             bgt.s fua3
             move blen,d0
             cmp blan,d0
             bgt.s fua2
             bsr demark
             bra.s fua3
fua1         subq #1,blan
fua2         subq #1,blen
             move -14(a6),d0
fua3         cmp -24(a6),d0
             ble is2
             subq #1,d0
             move d0,-14(a6)
             move 2(a5),d1
             mulu schrhî,d1
             sub d1,ykur1
             cmp -10(a6),d0
             bge is2
             subq #1,-10(a6)
             bra neuscreen

tabsuch      lea akttab,a0
             ext.l d5
tb           addq #1,d5
             cmp 4(a5),d5
             bge zeige              ;d5>mlen
             cmpi.b #2,(a0,d5.l)    ;nach  suchen
             bne.s tb
             rts

tab          bsr.s tabsuch
             move d5,-2(a6)         ;neue Kurpos
             cmp d5,d6
             bge.s tb3              ;kpos<=lenasc
             sub d6,d5
             tst.b -2(a5,d4.l)      ;Doppelte Endemarke ?
             bne.s tb2              ;nein
             subq #1,d4
             bra.s tb2
tb1          move.b #32,-1(a5,d4.l) ;zusÑtzliche Spaces einfÅgen
             addq #1,d4             ;lentxt + lenasc korrigieren
             addq #1,d6
tb2          dbra d5,tb1
             move d6,lenasc
             move.l d4,lentxt       ;neue Werte sichern
tb3          bsr kurpos
             bsr codekur
             bra zeige

return       cmp.b #28,7(a5)
             bne.s rtu
             addq #1,-14(a6)
             bsr aktzeile
             bra.s rt01
rtu          tst abs
             bne.s rt0
rt           bsr zeilÅber
             addq #1,-14(a6)
             bsr aktzeile
             tst rzeil
             bne is0a
rt01         bsr nlb
             bra zeige
rt0          tst rzeil
             beq.s ret1
             bset #7,flag
ret1         move d5,lenasc
             move.l d3,lentxt
             lea -1(a5,d3.l),a2
             clr trfl
             bset #7,(a5)
             bsr wr13
             bra zeige1

clrho        bsr zeilÅber
             moveq #0,d0
             move.l d0,-4(a6)         ;first
             move firstzei,d0
             move d0,-14(a6)        ;kursorzeile
             bra.s ec0

escape       bsr zeilÅber
             moveq #0,d0
             move.l d0,-4(a6)
             move -24(a6),d0        ;letzte Zeile
             move d0,-14(a6)        ;als aktuelle
             move fenho,d1
             lsr #1,d1              ;Fensterhîhe/2
             sub d1,d0
             cmp firstzei,d0
             bge.s ec0
             move firstzei,d0
ec0          move d0,-10(a6)        ;als erste Bildzeile
             bra neuscreen          ;lîschen,neu schreiben,Kursor setzen

undo         lea xstart,a0
             move (a0),4(a0)        ;xkur,xkur1 auf xstart
             move (a0),8(a0)
             move -4(a6),-2(a6)
             bsr clrline
             bsr aktzeile
             bsr codelin
             move -2(a6),d7
             bra zeige1

help         bra edret

plus         move.b #"+",d2
             bra txtzeich

minus        move.b #"-",d2
             bra txtzeich

fu4          lea futas,a0
             move.l d2,d0
             eori #1,d0
             tst.b (a0,d0.l)
             beq.s fu1              ;anderer Index ist nicht gesetzt
             move d2,-(a7)          ;retten
             move.l d4,-(a7)
             move d0,d2
             bsr.s dch              ;lîschen
             move.l (a7)+,d4
             move (a7)+,d2          ;Index zurÅck
fu1          bsr.s setdesk
             move d5,d7
             bsr clrline            ;nachfolgende schrift lîschen
             bra zeige1             ;und neu zeigen

setdesk      bsr bytein             ;Platz fÅr Steuerkommando besorgen
             move.b #27,(a5,d3.l)
             addq #1,d3
             addq #1,d4
             bsr bytein
             move.b d2,(a5,d3.l)
             addq #1,d3
             addq #1,d4
             move.l d4,lentxt
             move.l d3,kptxt
dch          lea futas,a0
             move.b (a0,d2.l),d1
             eori #1,d1
dch1         move.b d1,(a0,d2.l)
             moveq #12,d0
             sub d2,d0
             move d0,d2             ;Index
             bra deskchange

fu6          clr.l d0
             clr.l d7
             move 4(a5),d7          ;mlen
             move.b -1(a1,d2.l),d0
             mulu d0,d7
             move d2,-(a7)          ;retten
             move.b 6(a5),d2        ;alter code
             move.b -1(a1,d2.l),d0
             divu d0,d7
             move d7,4(a5)          ;neue mlen
             move d7,-18(a6)
             bsr.s dch              ;alte Taste lîschen
             move (a7)+,d2          ;code zurÅck
             move.b d2,6(a5)
             bsr.s dch              ;neue setzen
             bsr lineal
             bra zeige

pfli         tst d7
             beq.s pl0              ;nur 
             clr -2(a6)
             bsr kurpos
pl1          bsr codekur
             bra zeige
pl0          tst d5
             beq.s pl2
             subq #1,-2(a6)
             subq #8,xkur1
             bra.s pl1
pl2          move -14(a6),d0
             cmp #2,d0
             ble zeige
             move -18(a6),-2(a6)    ;Kursor ans Zeilenende
             bra.s pa0

pfauf        move -14(a6),d0
             cmp firstzei,d0
             beq zeige
pa0          bsr lastline
             bra zeige

pfre         tst d7
             beq.s pr0              ;nur 
             move lenasc,-2(a6)
             bsr kurpos
             bra.s pr2
pr0          cmp 4(a5),d5
             blt.s pr              ;kpos < mlen
             cmp d5,d6
             beq.s pr3             ;kpos=lenasc
pr           cmp d5,d6
             bne.s pr1
             move.b #32,(a5,d3.l)
             move.b #0,1(a5,d3.l)
             addq #1,lenasc
             addq.l #1,lentxt
pr1          addq #1,-2(a6)
             addq #8,xkur1
pr2          bsr codekur
             bra zeige
pr3          clr -2(a6)             ;Kursor an Zeilenanfang

pfab         bsr nextline
             bra zeige

insert       tst d7
             bne.s is0              ;shift oder control
             moveq #32,d2
             bsr einfÅgen           ;Platz holen & Space eintragen
             move d5,d7
             bra zeige1
is0          tst -30(a6)            ;Text ?
             beq zeige              ;nein
             move -14(a6),d0
             cmp #2,d0
             blt zeige
             cmp.b #28,7(a5)
             beq zeige
             bsr zeilÅber           ;aktuelle Zeile einfÅgen
             bne zeige              ;kein Platz
is0a         cmpi.l #12,free
             ble zeige              ;kein platz
             bsr.s neuezeile
             bsr blokor             ;Blockadressen korrigieren
is2          cmp -10(a6),d0
             bge.s is3
             move d0,-10(a6)
is3          bsr neuschirm
             bsr scrver
             bra zeige

neuezeile    bsr txtort
             subq.l #2,a0
             moveq #10,d0
             pea (a0)
             move.l aktend,a1
             bsr ltransfer          ;Platz fÅr Leerzeile schaffen
             move.l (a7)+,a1

zeilin       lea neuzeil,a0
             moveq #10,d0
             bsr copy1              ;Leerzeile eintragen
             move 4(a5),-4(a1)
             add.l #10,aktend       ;Zeiger korrigieren
             sub.l #10,free
             addq #1,-24(a6)
             move -4(a6),-2(a6)
             rts

einfÅgen     bsr bytein             ;Platz holen
             move.b d2,(a5,d3.l)    ;eintragen
             addq #1,d3             ;Zeiger berichtigen
             addq #1,d4
             addq.l #1,lentxt
             addq #1,lenasc
             rts

sfu          sub #26,d2
             mulu #66,d2
             lea floskeln,a2
             add.l d2,a2
             bra.s sf1
sf0          pea (a2)
             move.l kptxt,d3
             move.l lentxt,d4
             move -2(a6),d5
             move lenasc,d6
             bsr tz0
             bsr kursor             ;aus
             move.l (a7)+,a2
sf1          move.b (a2)+,d2
             bne.s sf0
             bra kursor             ;ein

imfenster    lea xmax,a0
             move 12(a0),d0         ;xkur1
             cmp 4(a0),d0           ;xstart
             blt scrrechts          ;Fensterinhalt nach rechts scrollen
             move (a0),d1
             subq #8,d1
             cmp d1,d0
             bgt scrlinks           ;nach links scrollen
             move 14(a0),d0         ;ykur1
             cmp 6(a0),d0           ;ystart
             ble scrab              ;abwÑrts scrollen
             move 26(a0),d1
             cmp d1,d0
             blt ok                 ;kein Scrolling nîtig
             bra scrauf             ;aufwÑrts scrollen

zeige1       move #3,-6(a6)
             bsr.s imfenster        ;ist Kursor noch im Fenster ?
             bne.s zg               ;Fenster wurde gescrollt
             bsr showzeil           ;énderung anzeigen
             bra.s zg
zeige        bsr.s imfenster
zg           move.l xkur1,xkur
             bsr kursor
             bra edret

txtsteuer    lea steuer0,a0
             moveq #0,d0
             move.b (a2)+,d0
             cmp #4,d0
             bge.s ts0              ;Indexschrift
             move.b -1(a0,d0.l),d0
             eor d0,d5
             rts
ts0          move.b -1(a0,d0.l),d0
             move d0,d1
             and.b d5,d1
             bne.s ts1              ;gleicher Index
             and #15,d5             ;alter Index lîschen
ts1          eor d0,d5              ;Index setzen - lîschen
             moveq #0,d0
             btst #7,d5
             beq.s ts3
             move schrhî,d0
             lsr #1,d0
             neg d0
ts3          move d0,yversatz
             rts

aktzeile     lea aktwort,a5
             move -24(a6),d0        ;lasti
             cmp -14(a6),d0         ;zei
             bge.s az1
             cmpi.l #1024,free
             ble zÅfehl
             move.l aktend,a1
             bsr zeilin
az1          move.l a5,a0
             move.l #512,d0
             bsr clrpuff
             bsr txtort
             move.l d0,lentxt       ;ZeilengesamtlÑnge speichern
             move.l a5,a1
             bsr copy1              ;-zur aktuellen Zeile machen
             bsr.s aktlen           ;lenasc und kptxt holen
             bra ok

aktlen       moveq #0,d0
             lea 7(a5),a1           ;Beginn eigentlicher Text
             moveq #0,d7            ;lenasc=Zeichenzahl ohne Steuerz.
             move -2(a6),d4         ;gewÅnschte Kursorposition
al0          move.b (a1),d0
             beq.s alret            ;Leerzeile
             cmp.b #28,d0           ;Grafik ?
             bne.s al1
             add.l 1(a1),a1         ;Zeiger korrigieren
             bra.s al0              ;noch eine Grafik ?
al1          move.b (a1)+,d0
             beq.s alret            ;fertig
             cmp.b #27,d0           ;Steuerzeichen ?
             bne.s al2
             addq.l #1,a1
             bra.s al1              ;nÑchstes Zeichen
al2          subq #1,d4
             addq #1,d7
             bra.s al1
alret        cmp #0,d4
             ble.s al4
             sub d4,-2(a6)          ;Kursorposition war zu groû
al4          move d7,lenasc
             rts

codekur      lea futas,a0
             clr.l 10(a0)
             clr.l 14(a0)
             clr.l d2
             move.b 1(a5),d0
             beq.s ck
             moveq #0,d1
             lea steuer0,a1
ck00         move.b (a1,d1.l),d5
             addq #1,d1
             and.b d0,d5
             beq.s ck01
             bset #0,10(a0,d1.l)
ck01         cmp #5,d1
             bne.s ck00
ck           move -2(a6),d6         ;Kursorposition
             moveq #7,d5
ck0          move.b (a5,d5.l),d0
             cmp.b #28,d0
             bne.s ck1
             add.l 1(a5,d5.l),d5
             bra.s ck0
ck1          move.b (a5,d5.l),d0
             cmp.b #27,d0
             bne.s ck3              ;kein Steuercode
             move.b 1(a5,d5.l),d2
             cmp.b #4,d2
             blt.s ck2              ;kein Index
             move.l d2,d0
             eori #1,d0
             clr.b 10(a0,d0.l)      ;anderer Index auf 0
ck2          bchg #0,10(a0,d2.l)
             addq #2,d5
             bra.s ck1              ;weiter prÅfen
ck3          addq #1,d5
             subq #1,d6
             bcc.s ck1
             subq #1,d5
ckret        move.l d5,kptxt
             moveq #1,d2
ck4          move.b (a0,d2.l),d0
             cmp.b 10(a0,d2.l),d0
             beq.s ck5
             move d2,-(a7)
             pea (a0)
             bsr dch
             move.l (a7)+,a0
             move (a7)+,d2
ck5          addq #1,d2
             cmp #6,d2
             bne.s ck4
             rts

codelin      bsr codekur

prÅflin      moveq #0,d2
             move.b 6(a5),d2
             lea futas,a0
             tst.b (a0,d2.l)
             bne.s pln1
             moveq #6,d2
pln0         move d2,-(a7)
             moveq #0,d1
             lea futas,a0
             bsr dch1               ;alle Buttons lîschen
             move (a7)+,d2
             addq #1,d2
             cmp #10,d2
             bne.s pln0
             move.b 6(a5),d2
             moveq #1,d1
             lea futas,a0
             bsr dch1               ;richtigen setzen
             move 4(a5),d0
             bra.s pln2
pln1         move 4(a5),d0
             cmp -18(a6),d0
             beq.s plret
pln2         move d0,-18(a6)
             bsr lineal             ;Lineal neu zeigen
plret        moveq #13,d2
             moveq #0,d1
             btst #7,(a5)
             beq.s zeigabs
             moveq #1,d1
zeigabs      cmp absatz,d1
             bne.s zga
             rts
zga          move d1,absatz
             bra deskchange

killetter    bsr kill
             subq.l #1,lentxt
             subq #1,lenasc

clrline      bsr mausaus
             move.l #1,-(a7)
             move.l #$10000,-(a7)
             bsr vsfpara
             lea ptsin,a0
             lea xmax,a1
             move 8(a1),(a0)+       ;xkur
             move 10(a1),d0         ;ykur
             add rez,d0
             move d0,(a0)+
             move (a1),(a0)+        ;xmax
             move -10(a6),d1
             cmp -14(a6),d1
             bne.s cl
             move 6(a1),d0
             addq #1,d0
             bra.s cl0
cl           add rez,d0;
             sub zlabst,d0
cl0          move d0,(a0)
             bsr bar
             bra mausan

capslock     tst cap
             beq.s cpret
             cmp #97,d2             ;a
             blt.s cpret
             cmp #122,d2            ;z
             bgt.s tz01
             sub #32,d2
             rts
tz01         cmp #132,d2            ;Ñ
             bne.s tz02
             move #142,d2
             rts
tz02         cmp #129,d2            ;Å
             bne.s tz03
             move #154,d2
             rts
tz03         cmp #148,d2            ;î
             bne.s cpret
             move #153,d2
cpret        rts

lastline     bsr zeilÅber
             bne nlret            ;kein Platz
lli             move 2(a5),d0
             mulu schrhî,d0
             sub d0,ykur1
             subq #1,-14(a6)        ;Kursorzeile
             bsr aktzeile
             bra.s nlc

nextline     bsr zeilÅber
             bne nlret
nla          addq #1,-14(a6)
             bsr aktzeile
             bne.s nlf
nlb          move 2(a5),d0
             mulu schrhî,d0
             add d0,ykur1
nlc          bsr codelin
kurpos       move -2(a6),d0         ;kpos
             sub -4(a6),d0          ;first
             bpl.s nl3
             neg d0
             ext.l d0
             moveq #32,d2
             add.l d0,kptxt
             add.l d0,lentxt
             add d0,lenasc
             move -4(a6),-2(a6)
             move.l a5,a0
             add.l kptxt,a0
             bra.s nl1
nl0          move.b d2,(a0)+
nl1          dbra d0,nl0
             move.b #0,(a0)+
             btst #0,lentxt+3
             beq.s nl2
             addq.l #1,lentxt
             move.b #0,(a0)
nl2          clr d0
nl3          mulu #8,d0
             add xstart,d0
             move d0,xkur1
             rts
nlf          subq #1,-14(a6)
nlret        rts

wr13         move -14(a6),zeile     ;Zeilennummer sichern
             bset #5,flag           ;CR merken
             lea (a5,d4.l),a0
wr           move.b -(a0),d0
             beq.s wr
             cmp.b #32,d0
             bne.s wr1
             subq #1,d6
             move.b #0,(a0)
             bra.s wr
wr1          bsr uebtr              ;Wortteil ab Kursor merken usw
             move ascrest,kpos
             bra.s format
wrap         move -14(a6),zeile
             move #1,wrfl
wr0          bsr langwrap           ;erlaubtes Zeilenende holen,öbertrag
             move -14(a6),d0        ;bilden
             cmp zeile,d0
             bne.s format
             move ascrest,d1        ;kpos
             add einrÅ,d1
             move d1,kpos
format       bsr formatiere
             bsr nÑchstz
             tst ascrest
             bgt.s wr0
             bsr zeilÅ
             clr wrfl
wr2          move zeile,d0
             move d0,-14(a6)
             tst -4(a6)
             beq.s wr3
             clr -4(a6)
             bsr scrhor
             bsr lineal
             move -10(a6),d0        ;ganzen Schirm zeichnen
wr3          bsr neuschirm
wrret        move kpos,-2(a6)
             bra nla

blomark      move.l blsel,d1
             bmi blmret             ;kein block
             cmp.l sel,d1
             bne blmret             ;nicht in diesem text
             move blan,d1
             cmp -14(a6),d1
             bne.s blmrk            ;blockanfang nicht in dieser zeile
             move -2(a6),d1
             cmp blanx,d1
             bge.s blmrk            ;kursorposition hinter blockanfang
             add d0,blanx
blmrk        move blen,d1
             cmp -14(a6),d1
             bne.s blmret
             move -2(a6),d1
             cmp blenx,d1
             bge.s blmret
             add d0,blenx
blmret       rts


 end
 