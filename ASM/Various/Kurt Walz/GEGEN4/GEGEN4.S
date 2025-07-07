* WöRMER Ñhnlich DOMINO, aber n'biûchen weniger dumm 
* (computer soll Sackgassen erkennen und so).         UND: vier WÅrmer.
*
* Kurt Walz, Friedenstr.23, 7180 Crailsheim
*
* sollte auf jedem ATARI-ST laufen, wenn der HOCHAUFLôSENDE SW-Bildschirm
* angeschlossen ist.
* 
* Das nette an diesem Programm ist, daû der (schwarze) Computer-gesteuerte
* Wurm ein biûchen vorausschauen kann. Er prÅft dauernd
* (sofern ihm die Zeit dazu reicht), ob er gerade in eine Sackgasse
* hinein schlittert. Wenn er eine solche Falle erkennt, so Ñndert er
* sogleich seine Richtung. Dieses "Erkennen" findet in der Subroutine
* "wieweit" statt. Diese wird Åbrigens auch dann benutzt, wenn der Computer-
* Wurm seine Richtung sofort Ñndern muû, aber zwei Richtungen zur Wahl hat.
* Er wÑhlt das kleinere öbel, nÑmlich die Strecke, die ihm lÑnger erscheint.
* Die Informationen darÅber stammen wiederum aus der subroutine "wieweit".
* Somit passiert es selten, daû der schwarze Wurm schon am Anfang des
* Spieles in einer Spirale verendet. Wenn du die Subroutine verstehen
* willst, solltest du dir vorher das ganze Programm anschauen. Es ist
* nicht gerade vorbildlich geschrieben (es dÅrfte besser strukturiert
* sein), aber einigermaûen verstÑndlich ist es schon. Die Sackgassen-
* Erkennung ist natÅrlich ausbaufÑhig... Viel Spaû damit.

* öbrigens ist das Programm vîllig relocierbar. Es lÑuft also in
* jedem beliebigen Speicherbereich, ohne daû vorher irgendwelche
* pc-relativen Adressen oder Sprungadressen umgerechnet werden mÅssen.
* Deshalb habe ich im header des files "GEGEN4.TOS" ein biûchen
* rumgepfuscht: Das vierzehnte (=letzte) word des headers hab ich
* NICHT auf Null gelassen. Aber die vier Longwords davor hab ich auf
* Null gesetzt, sie geben an, wieviele Bytes am file_Ende stehen, die
* nur zur erwÑhnten Umrechnung dienen (und zu anderm Schnickschnack).
* Das ganze file hab ich um diese Zahl von Bytes gekÅrzt.

.text

acis:    equ $FFFFFC00 status-adr des keyb-acia
keyb:    EQU $FFFFFC02 adr empfangener daten vom keyboard
ctMIDIsy: equ $95      des MIDI-acias controlbyte vom system aus
ctMIDI:   equ 0         dito fÅr dieses Programm
aciM:     equ $FFFFFC04 MIDI-ACIA control-Adresse
Tintend:  equ $BF       an MFP, um tastatur-service-bit zu lîschen
SAend:    equ $DF       an MFP, um timA-inService-bit zu lîschen
iemA:  equ $20
iemB:  equ $60      MFP-int-masken fÅr dieses programm: timerA und timC,ACIAs
immA:  EQU $20
emAold: equ $1F
emBold: equ $64 MFP-masken fÅr sys
mmAold: equ $1E
timAvec:  equ $134  *adresse des vectors fÅr timerAinterrupt
aciINTad: equ $118  *dort vector fÅr ACIA-interrupt
vblnkad:  equ $70   *adr des vectors fÅr verticalBlankInterrupt
teiA:  EQU $FFFFFA1F
vteiA: EQU $FFFFFA19 *adr timerA Dat und control(+vorteiler)
mfpSA: equ $FFFFFA0F
mfpSB: equ $FFFFFA11
mfpEA: equ $FFFFFA07
mfpEB: equ $FFFFFA09
mfpPA: equ $FFFFFA0B
mfpPB: equ $FFFFFA0D *int-inServ,-enab,-pend,-maskRegister des MultiFunktPeriph
mfpMA: EQU $FFFFFA13
mfpMB: EQU $FFFFFA15

b: equ -200
zusam:  equ 600      fÅr mxsoviel bytes werden untenstehend adressen definiert
stack:  equ b-zusam  ab hier abwÑrts: stack

ssp:    equ b-4
mouvec: equ b-8
savACIi: equ b-12
tvb1:   equ b-16

EMPpoiL: equ b-20
EMPpoiB: equ EMPpoiL+3
FILpoiL: equ b-24
FILpoiB: equ FILpoiL+3

softim: equ b-28
ststart: equ b-32
lz:     equ b-36
_lz:    equ b-40   der letzte MatrixEintrag des Spielers/_computers

Richt:  equ b-50     aktuelle Richtung  0=abwÑrts 1=aufwÑ -1=links -2=rechts
vRicht: equ Richt+2  vorige Richtung
boing_: equ b-53
boing:  equ b-54  .b, =0,solangeNixAnboxt bit0=comp bit1=erstrSpielr bit2=zweSp
score:  equ b-58
scoradd: equ b-62
lifes:  equ b-66
_Richt: equ b-70     aktu Richtung des computerWurms
_nxR:   equ _Richt+2
gamnr:  equ b-74
teA:    equ b-78
LzKey:  equ b-82
tacho:  equ b-86
tvb11:  equ b-90
this:   equ b-94
level:  equ b-98
Lng1:  equ b-100
Lng2:  equ b-102
heych: equ b-104
chaoNr: equ b-106

Ylz:   equ b-110
YRicht: equ b-114
scor2:  equ b-118
lifs2:  equ b-122
jlz:   equ b-130
jRicht: equ b-134
scor3:  equ b-138
lifs3:  equ b-142


b1siz:   equ 102*128 vert*horz 100*127 Punkte +RandObn +RandUntn +RandLinks
b1L:    equ (b1siz-256)/4-1 fÅr LoopZwecke,um all diese MatrixPkte zu lîschn

lea      (a7),a0
lea  -256(a7),a4
move.L a4,  d2
clr.b       d2  adr des tastaturBuffers
move.L d2,  a4
sub.L #b1siz,a4  endgÅltiges a4
*                 ab jetzt wird das RAM (fast) nur noch via xx(a4) genutzt.
lea  stack(a4),a7 endgÅ stack
aa1: clr.L -(a0) lîsch alle zukÅnftigen RAM-tabellen (oberhalb stack)
   cmp.L a7,a0
   bhi  aa1
move.L d2, FILpoiL(a4)
move.L d2, EMPpoiL(a4)

pea    stack(a4)
move.w #32,-(a7)  SUPERVISORmodus, stack gleich untern tv_Bildern+tabelle
trap   #1
move.L a4,usp
move.L d0,ssp(a4) save alten superv-SP
move.b #0,vteiA   counter stop

move.w #34,  -(a7)   liefer in 16(d0): mousevector of system
trap   #14
addq.L #2,    a7
move.L d0,    a0
move.L 16(a0),mouvec(a4)  save
*bsr    tastmou        setz mouse auf tastaturmodus

move.b #ctMIDI,    aciM   disable MIDIacia
LEA    tastatur(pc),a0
move.L aciINTad,savACIi(a4)   rette sys-adresse fÅr ACIAinterrupt
move.L a0,      aciINTad  und setz dafÅr eigenen wert
LEA    timA(pc),    a0
move.L a0,     timAvec   setz auch eignen timerAvector
move.b #0,   vteiA     zunÑchst: KEINE funktion ausfÅhren, stop counter
move.b #iemA,mfpEA
move.b #iemB,mfpEB  MFP-masken neu
move.b #immA,mfpMA
 clr        level(a4)
 clr.L      gamnr(a4)
 clr       d2
 bra   neuk0_
hatkracht:
*  Wert von boing muû in d2.b stehen!
move.b d2, boing_(a4)
 cmp.b #7, d2
 beq   neukurz0  3 angeboxte & compu bei den Verlierern?
 cmp.b #$B,d2
 beq   neukurz0  comp bei Verlierern?
 cmp.b #$D,d2
 beq   neukurz0  comp bei Verlierern?
 cmp.b #$E,d2   alle drei spieler angeboxt?
 bne   LOOP
 addq.L #1, lifes(a4)
 addq.L #1, lifs2(a4)
 addq.L #1, lifs3(a4)
 bra    neuk

neukurz0:
 moveq #0, d0
 btst  #1, d2
 sne       d0
 lsr   #7, d0  so d0= 0 oder 1, je nachdem, ob spielr1 gewonn oder verlorn
 add.L d0,  lifes(a4)  also werden die verlornenLeben um 0 oder 1 erhîht
 sub.b #1, d0        255 oder 0
 lsl   #1, d0        510 oder 0 je nach gewinn oder verlier
 add.L d0,  score(a4)  also punktestand um 510 oder 0 erhîhen
 moveq #0, d0
 btst  #2, d2  dasselbe fÅr spielr2
 sne       d0
 lsr   #7, d0
 add.L d0,  lifs2(a4)
 sub.b #1, d0
 lsl   #1, d0
 add.L d0,  scor2(a4)
 moveq #0, d0
 btst  #3, d2  und noch spielr3
 sne       d0
 lsr   #7, d0
 add.L d0,  lifs3(a4)
 sub.b #1, d0
 lsl   #1, d0
 add.L d0,  scor3(a4)
neuk0_:
 addq  #1, level(a4)
 bsr   lev2tim
neuk:
add.L  #1, gamnr(a4)
move.b #0, vteiA    stop
move.b teA(a4),teiA
bsr    sound__
bsr    crash__
bsr   melde
bsr   tx1      'Q W N = quit weitr vonvorn'
bsr   newline
bsr   tx2
bsr   newline
bsr   newline
bsr   tx31
bsr   newline  'O K L = witr/neu/LaûLevel je ohne schwarz
bsr   tx32
bsr   newline
bsr   tx33
bsr   newline
bsr   waitu  cy=quit eq=neuMitCompu ne=NeuOhne ov/pl=weiterMit ov/mi=weitrOhne
bcs   abbr   mi=LaûLevelOhne  mi+eq=laûLevelMitComp
bvs   weiter
bmi   LaLe
beq   Mit
move.b #1,boing(a4)
bra   Mit_
Mit:
clr.b    boing(a4)
Mit_:
clr      teA(a4)
move  #1,level(a4)
clr.L    this(a4)
clr.L    score(a4)
clr.L    scor2(a4)
clr.L    scor3(a4)
clr.L    lifes(a4)
clr.L    lifs2(a4)
clr.L    lifs3(a4)
move.L #1,gamnr(a4)
bra    weiter_
LaLM:
 btst #0, boing(a4)
 beq  weiMit
 subq  #1,  level(a4)
 bsr   lev2tim
move.b teA(a4),teiA
 bra   weiMit
LaLe:
 beq  LaLM
 btst #0, boing(a4)
 beq  we0i
 subq #1, level(a4)
 bsr  lev2tim
weiter:
bpl      weiMit
we0i:
move.b #1,boing(a4)
bra    weiter_
weiMit:
clr.b    boing(a4)
weiter_:
clr          tacho(a4)
move.b teA(a4),teiA
bsr   strich0      lîsch BSch
bsr   melde
bsr   pos1st       erste SpielerSteinchen auf BSch
bsr   _pos1st       erste computerSteinchen
clr       LzKey(a4)
clr.L     Richt(a4)
clr.L     YRicht(a4)
clr.L     jRicht(a4)
addq  #1, jRicht(a4)
bsr   striche      senkrLin auf Bsch
bsr   melde

bsr   newline
moveq #0,d0
move.b teA(a4),d0
bsr   d0Ldez

clr.L      this(a4)
clr        chaoNr(a4)
moveq  #0,    d0
move.b $FFFA23,d0  quasiWÅrfel
addq   #6,    d0
mulu   #5,   d0
cmp    #685, d0
scs          d1
ext          d1
neg          d1    1,wenn d0 genÅgend klein
mulu   d1,   d0
move   d0,  chaoNr(a4)
move.b #4, ststart(a4) so gesamtteiler ca viertelSec wenn teiA=00
move.b #7, softim(a4)
move.w #$2700,  sr
move.b #7, vteiA   so sysTakt/200/256 auf timerA

LOOP:
 move  #$2500,sr
 move.b boing(a4),d2
 beq   nixkr
 cmp.b boing_(a4),d2
 bne   hatkracht
nixkr:
 move.b softim(a4),d0
 cmp.b  ststart(a4),d0
 bne   LOOP
 move chaoNr(a4),d0
 beq  mchao
 cmp  this+2(a4),d0
 bne  mchao
 tst.b heych(a4)
 bne  LOOP
 bsr  chaos
 st      heych(a4)
 bra  LOOP
mchao:
 clr     heych(a4)
 bsr   obsack  gib d1= MatrixAdr, bis wo jetzigRichtg hinfÅhrt; flg ne=sackgass
 bne   LOOP
 bsr   obsac   guck ab d1, in welche _Richtung mehr frei ist, richt -> d2
* obsac will in d1 MatrixPkt, nimmt als Richtung,wo's nicht weitergeht, _Richt.
* gibt d2 empfohlene WeiterRichtung, d0=platz dort, a2 Ende dieser Richtung
* d1=platz in gegenrichtung, a0 = deren EndPkt

 move  d0, Lng1(a4)  grîûre LÑnge
 move  d1, Lng2(a4)  kleinere LÑnge
 move  d2, _nxR(a4)
 tst.b softim(a4)
 beq   LOOP
 movem.L d2/a0,-(a7)
 move.L a2,   d1
 bsr    wieweit   guck das zweite hypotetische StÅckchen an: wieviel frei -> d0

* wieweit will in d1 MatrixPkt, in d2 Richtung,wo's nicht weitergeht
* gibt d2 empfohlene WeiterRichtung, d0=platz dort, a2 Ende dieser Richtung
* d1=platz in gegenrichtung, a0 = deren EndPkt

 add     d0,   Lng1(a4)
 movem.L (a7)+,d2/a0
 tst.b   softim(a4)
 beq     LOOP

 bchg   #0,d2  stell auf GegenRichtung
 move.L a0,d1   zugehîriger MatrxStartPkt
 bsr    wieweit  gib ab_dort_freie Strecke in d0
 add    Lng2(a4),d0  die (bisher) kÅrzere Strecke
 cmp    Lng1(a4),d0
 bcs    LOOP
 bchg   #0,_nxR+1(a4)
 bra   LOOP

* tastatur (INTERRUPT-routine), wenn ACIA-interrupt
*
tastatur:
 movem.L a0/a4/d0-d1,-(a7)
 move.L usp,a4
 LEA    jtab(pc),a0
 clr.w           d1
 move.b keyb,    d1      keyboard daten
 move.b d1,     LzKey(a4)    protokollier letzte Taste
 LSL.w   #1,       d1
 move.w  0(a0,d1.w),a0     rel sprungadresse aus Tabelle jtab
 jmp      k(pc,a0.w)
k: movem.L (a7)+,  a0/a4/d0-d1
 move.b   #Tintend, mfpSB    inSERVICEbit rÅcksetzen
RTE

k1D:
* - - - - - - - - - -   CONTROLtaste wie Pfeil aufwÑrts fÅr ZweitWurm
 moveq  #1,  d0
 move.w YRicht(a4),d1     steht RichtungsCode bereits auf aufwÑrts(1) odr abwÑ(0)?
 bpl    k
 cmp.b  #-2,  d1      wars bisher nach rechts?
 bne    Yoko
 subq   #1,  Ylz+2(a4)
Yoko:
 movem  d0-d1,YRicht(a4)  so landet bisheriges YRicht auf YvRicht
 bra    k
k38:
* - - - - - - - - - -   ALTERtatste wie Pfeil abwÑrts fÅr zweitWurm
 moveq  #0,  d0
 move  YRicht(a4),d1
 bpl    k           steht RichtungsCode bereits auf abwÑrts(0) odr aufwÑ(1)?
 cmp.b  #-2,  d1      wars bisher nach rechts?
 bne    Yoku
 subq   #1,  Ylz+2(a4)   Ñsthetikhalber: damit nicht weiter rechts als bisher
Yoku:
 movem  d0-d1,YRicht(a4)  so landet bisheriges Richt auf vRicht
 add   #128,  Ylz+2(a4)     wichtig, damit nicht durch untre SteinHÑlfte blockiert
 bra   k
k2A:
* - - - - - - - - - -   linkeSHIFT wie Pfeil links fÅr zweitWurm
 moveq  #-1,  d0
 move.w YRicht(a4),d1
 bmi    k          steht RichtungsCode bereits auf links oder rechts?
 tst.b  d1          wars bisher runterwÑrts?
 bne    Yokl
 sub    #128,Ylz+2(a4)     der éasthetik halber
Yokl:
 movem  d0-d1,YRicht(a4)  so landet bisheriges Richt auf vRicht
 bra    k
k36:
* - - - - - - - - - -   rechteSHIFT wie Pfeil rechts fÅr zweitwurm
 moveq  #-2,  d0
 move.w YRicht(a4),d1     steht RichtungsCode bereits auf rechts oder links?
 bmi    k
 tst.b  d1           wars bisher runterwÑrts?
 bne    Yokr
 sub    #128,Ylz+2(a4)     der éasthetik halber
Yokr:
 movem  d0-d1,YRicht(a4)  so landet bisheriges Richt auf vRicht
 addq   #1,   Ylz+2(a4)   wichtig, damit nicht durch rechteSteinhÑlfte blockiert
 bra    k

k48: 
* - - - - - - - - - -   Pfeil aufwÑrts
 moveq  #1,  d0
 move.w Richt(a4),d1     steht RichtungsCode bereits auf aufwÑrts(1) odr abwÑ(0)?
 bpl    k
 cmp.b  #-2,  d1      wars bisher nach rechts?
 bne    oko
 subq   #1,    lz+2(a4)
oko:
 movem  d0-d1,Richt(a4)  so landet bisheriges Richt auf vRicht
 bra    k
k50:
* - - - - - - - - - -   Pfeil abwÑrts
 moveq  #0,  d0
 move.w Richt(a4),d1
 bpl    k           steht RichtungsCode bereits auf abwÑrts(0) odr aufwÑ(1)?
 cmp.b  #-2,  d1      wars bisher nach rechts?
 bne    oku
 subq   #1,    lz+2(a4)   Ñsthetikhalber: damit nicht weiter rechts als bisher
oku:
 movem  d0-d1,Richt(a4)  so landet bisheriges Richt auf vRicht
 add   #128,  lz+2(a4)     wichtig, damit nicht durch untre SteinHÑlfte blockiert
 bra   k
k4B:
* - - - - - - - - - -   Pfeil links
 moveq  #-1,  d0
 move.w Richt(a4),d1
 bmi    k          steht RichtungsCode bereits auf links oder rechts?
 tst.b  d1          wars bisher runterwÑrts?
 bne    okl
 sub    #128, lz+2(a4)     der éasthetik halber
okl:
 movem  d0-d1,Richt(a4)  so landet bisheriges Richt auf vRicht
 bra    k
k4D:
* - - - - - - - - - -   Pfeil rechts
 moveq  #-2,  d0
 move.w Richt(a4),d1     steht RichtungsCode bereits auf rechts oder links?
 bmi    k
 tst.b  d1           wars bisher runterwÑrts?
 bne    okr
 sub    #128, lz+2(a4)     der éasthetik halber
okr:
 movem  d0-d1,Richt(a4)  so landet bisheriges Richt auf vRicht
 addq   #1,   lz+2(a4)      wichtig, damit nicht durch rechteSteinhÑlfte blockiert
 bra    k

t1:
* - - - - - - - - - - koystick nach oben
 moveq  #1,  d0
 move.w jRicht(a4),d1     steht RichtungsCode bereits auf aufwÑrts(1) odr abwÑ(0)?
 bpl    k
 cmp.b  #-2,  d1      wars bisher nach rechts?
 bne    joko
 subq   #1,    jlz+2(a4)
joko:
 movem  d0-d1,jRicht(a4)  so landet bisheriges Richt auf vRicht
 bra    k
t2:
* - - - - - - - - - - joystick abwÑrts
 moveq  #0,  d0
 move.w jRicht(a4),d1
 bpl    k           steht RichtungsCode bereits auf abwÑrts(0) odr aufwÑ(1)?
 cmp.b  #-2,  d1      wars bisher nach rechts?
 bne    joku
 subq   #1,  jlz+2(a4)   Ñsthetikhalber: damit nicht weiter rechts als bisher
joku:
 movem  d0-d1,jRicht(a4)  so landet bisheriges Richt auf vRicht
 add   #128, jlz+2(a4)    wichtig, damit nicht durch untre SteinHÑlfte blockiert
 bra   k
t4:
* - - - - - - - - - joystick links
 moveq  #-1,  d0
 move.w jRicht(a4),d1
 bmi    k          steht RichtungsCode bereits auf links oder rechts?
 tst.b  d1          wars bisher runterwÑrts?
 bne    jokl
 sub    #128,jlz+2(a4)   der éasthetik halber
jokl:
 movem  d0-d1,jRicht(a4)  so landet bisheriges Richt auf vRicht
 bra    k
t8:
* - - - - - - - - - joystick rechts
 moveq  #-2,  d0
 move.w jRicht(a4),d1     steht RichtungsCode bereits auf rechts oder links?
 bmi    k
 tst.b  d1           wars bisher runterwÑrts?
 bne    jokr
 sub    #128,jlz+2(a4)     der éasthetik halber
jokr:
 movem  d0-d1,jRicht(a4)  so landet bisheriges Richt auf vRicht
 addq   #1,  jlz+2(a4)      wichtig, damit nicht durch rechteSteinhÑlfte blockiert
 bra    k

jtab:
dc.w 0,t1-k,t2-k,0,t4-k,0,0,0,t8-k,0,0,0,0,0,0,0 1=auf 2=ab 4=Link 8=Rech
dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,k1D-k,k1D-k,0      CONTROL  A wie CONT
dc.w 0,0,0,0,0,0,0,0,0,0,k2A-k,0,k38-k,0,0,0      SHIFTli  Y wie ALTER
dc.w 0,0,0,0,0,k2A-k,k36-k,0,k38-k,0,0,0,0,0,0,0  - wie SHLi  SHre ALTERN
dc.w 0,0,0,0,0,0,0,0,k48-k,0,0,k4B-k,0,k4D-k,0,0  *pfeil ^ < >
dc.w k50-k,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0          *pfeil runter
dc.w k36-k,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0        < wie SHIre
dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

abbr:
      move.w #$2700, sr
      move.L savACIi(a4),aciINTad  ACIAvector auf sys
      move.b #ctMIDIsy,aciM    MIDIacia auf system-wert
*      bsr    sysmous          mouse auf modus des systems
      move.b #emBold, mfpEB
      move.b #emAold, mfpEA   *alte (system-)masks wiederherstellen
      move.b #mmAold, mfpMA
      move.b #Tintend,mfpPB  pending-bit des TastInt rÅcksetzen
      move.b #Tintend,mfpSB  ebenso InServiceBit
*      move.w #$2300,  sr
*      move.L ssp,    -(a7)   *wieder in user-mod
*      move.w #32,    -(a7)
*      trap   #1
      clr.w          -(a7)   terminate
      trap   #1

*subr errechnet neuen timerA-Wert aus level(a4)
lev2tim:
 move  level(a4),d1
 move  #370,d0
m: mulu #11,d0
 add    #39,d0   kompensier Rundungsfehler des nachfolgenden lsr.w
 lsr.w  #4, d0   (mal 11 durch 16) hoch level  level1:256 level2:178 etc...
 dbra   d1, m
 move.b d0,teA(a4)  jetzt ist aus dem Level das Tempo errechnet, es steigt
*                  (einigermaûen) logharithmisch zum Level. Genauer gesagt:
*                   der timerA zÑhlt kleinere Zahlen, wenn der Level steigt.
 rts

*subr zwing den computr_Wurm zu nem chaotischen Eck, falls wÅrfeln=...
chaos:
 moveq #5,    d0
 and.b $FFFA23,d0
 beq   ruchao
 tst  _Richt(a4)
 bpl  rrchao
 move _lz+2(a4), d0
 lea   (a4),   a0
 lea -127(a0,d0),a0  um 1 rauf (und 1nachRechts): dort prÅfen beginnen
 btst #1, $FFFA23
 beq   uuchao
 tst.b (a0)
 bne  uuchao
 tst.b -1(a0)
 bne  uuchao
 tst.b -2(a0)
 bne  uuchao
 tst.b 1(a0)
 bne  uuchao
 tst.b -128(a0)
 bne  uuchao
 tst.b -129(a0)
 bne  uuchao
 tst.b -130(a0)
 bne  uuchao
 tst.b 127(a0)
 bne  uuchao
 move #1,_Richt(a4)
 bra  ruchao
uuchao:
 tst.b 384(a0)
 bne   ruchao
 tst.b 383(a0)
 bne   ruchao
 tst.b 382(a0)
 bne   ruchao
 tst.b 385(a0)
 bne   ruchao
 tst.b 512(a0)
 bne   ruchao
 tst.b 513(a0)
 bne   ruchao
 tst.b 511(a0)
 bne   ruchao
 tst.b 510(a0)
 bne   ruchao
 add  #128,_lz+2(a4)
 clr       _Richt(a4)
ruchao: RTS
rrchao:
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea   2(a0,d0),a0  um 2 nachRechts: dort prÅfen beginnen
 btst #1, $FFFA23
 beq   llchao
 tst.b (a0)
 bne   llchao
 tst.b -128(a0)
 bne   llchao
 tst.b -256(a0)
 bne   llchao
 tst.b 128(a0)
 bne   llchao
 tst.b 1(a0)
 bne   llchao
 tst.b -127(a0)
 bne   llchao
 tst.b -255(a0)
 bne   llchao
 tst.b 129(a0)
 bne   llchao
 add  #1, _lz+2(a4)
 move #-2,_Richt(a4)
 bra  ruchao
llchao:
 tst.b -3(a0)
 bne   ruchao
 tst.b -131(a0)
 bne   ruchao
 tst.b 253(a0)
 bne   ruchao
 tst.b 125(a0)
 bne   ruchao
 tst.b -4(a0)
 bne   ruchao
 tst.b -130(a0)
 bne   ruchao
 tst.b 252(a0)
 bne   ruchao
 tst.b 124(a0)
 bne   ruchao
 move #-1,_Richt(a4)
 bra   ruchao

*subr guck ab d1(MatrxAdr), in welcher_Richtg mehr frei
obsac:
 move _Richt(a4),d2
*weiter in wieweit:     gib in d2 Empfehlung fÅr nÑchste _Richtung

*subr will in d1 MatrixPkt, in d2 Richtung,wo's nicht weitergeht
* gibt d2 empfohlene WeiterRichtung, d0=platz dort, a2 Ende dieser Richtung
* d1=platz in gegenrichtung, a0 = deren EndPkt
wieweit:
 move.L d1,a0
 tst.w d2
 bpl   ous
*zuerst        guck ab a0 (=d1) raufwÑrts
 moveq #-1,d0
 lea  1(a0),a1  NachbarPkt, auch zu kontrolliern, wenn bisher links(d2=-1)
 cmp  #-1, d2
 beq  v2
 subq #2,  a1  wenn bisher rechts: andrer NachbarPkt mitzukontrollieren
 exg   a1, a0
v2:add #1, d0
 suba #128,a0
 suba #128,a1
 tst.b (a1)
 bne   v7
 tst.b (a0)
 beq   v2
v7:lea 128(a0),a2
 move.L d1,a0
 moveq #-1,d1
 adda  #128,a0  nun abwÑrts
 lea  1(a0),a1  NachbarPkt, auch zu kontrolliern, wenn bisher links(d2=-1)
 cmp  #-1, d2
 beq  v3
 subq #2,  a1  wenn bisher rechts: andrer NachbarPkt mitzukontrollieren
 exg   a1, a0
v3:add #1, d1
 adda #128,a0
 adda #128,a1
 tst.b (a1)
 bne   v4
 tst.b (a0)
 beq   v3
v4:sub #128,a0
 cmp   d0, d1  d1=platzAbwÑrts d0=platzAufwÑrts
 smi       d2  set all bits,wenn aufwÑ mehr platz, sonst clear
 bmi   a1d2
 exg   d0, d1
 exg   a0, a2
a1d2:
 and   #1, d2
RTS
ous:
*zuerst        guck ab a0(=d1) nach links
 moveq  #-1, d0
 lea  128(a0),a1  mitzukontrollieren,wenn bisher aufwÑrts(d2=1)
 tst.b d2
 bgt   h2
 suba #256, a1  und dies mitkontr,wenn bisher abwÑ
 exg   a1, a0
h2:add #1, d0
 tst.b -(a0)
 bne   h7
 tst.b -(a1)
 beq   h2
h7:lea 1(a0),a2
 move.L d1,a0
 lea  128(a0),a1  mitzukontrollieren,wenn bisher aufwÑrts(d2=1)
 tst.b d2
 bgt   h4
 suba #256, a1  und dies mitkontr,wenn bisher aufwÑ
 exg   a1, a0
h4:
 moveq #-1,d1
 addq  #2, a0  nun rechts
 addq  #2, a1
h3:add #1, d1
 tst.b (a0)+
 bne   h5
 tst.b (a1)+
 beq   h3
h5:sub #2, a0
 cmp   d0, d1  d1=platzRechts d0=platzLinks
 smi       d2  set all bits,wenn links mehr platz, sonst clear
 bmi   o1d2
 exg   d0, d1
 exg   a0, a2
o1d2:
 or   #254,d2
RTS

*subr prÅft, ob computerWurm grade in Sackgasse reinlÑuft, gib d1.L
obsack:
 move _Richt(a4),d0
 beq   osu
 bpl   oso
 addq  #1,  d0
 beq   osl
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea   1(a0,d0),a0  um 1 nachRechts: dort prÅfen beginnen
 lea   128(a0), a1
f1: tst.b (a0)+
 bne     f2
 tst.b (a1)+
 beq   f1
f2: subq  #2, a0   zeige letztes freies Matrixfeld in aktu_Richtung
 move.L  a0, d1
 tst.b -128(a0)
 bne   i2sackr
 tst.b -256(a0)
 bne   i2sackr
 tst.b -129(a0)
 bne   i2sackr
 tst.b -257(a0)
 beq   okobs
i2sackr:
 tst.b 256(a0)
 bne   istsackr
 tst.b 255(a0)
 bne   istsackr
 tst.b 384(a0)
 bne   istsackr
 tst.b 383(a0)
 beq   okobs
istsackr:
*                auf abwÑrts prÅfe, obs geht
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea  0(a0,d0),a0
 tst.b 256(a0)
 bne   rsto
 tst.b 255(a0)
 bne   rsto
 tst.b 384(a0)
 bne   rsto
 tst.b 383(a0)
 bne   rsto
 move #$2700,sr
 clr      _Richt(a4)  stell auf abwÑrts
 add #127, _lz+2(a4)
 move #$2500,sr
 bra  _okobs
rsto:
*                auf raufwÑrts prÅfe, obs geht
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea -127(a0,d0),a0
 tst.b -(a0)
 bne   _okobs
 tst.b -(a0)
 bne   _okobs
 tst.b -128(a0)
 bne   _okobs
 tst.b -127(a0)
 bne   _okobs
 move #$2700,sr
 sub  #1, _lz+2(a4)
 move #1, _Richt(a4)  stell auf raufwÑrts
 move #$2500,sr
 bra  _okobs
osl:
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea   0(a0,d0),a0  um 1 nachLinks:durch -(a0),s.u. dort prÅfen beginnen
 lea   128(a0), a1
l1: tst.b -(a0)
 bne     l2
 tst.b -(a1)
 beq   l1
l2: addq  #1, a0   zeige letztes freies Matrixfeld in aktu_Richtung
 move.L  a0, d1
 tst.b -128(a0)
 bne   i2sackl
 tst.b -256(a0)
 bne   i2sackl
 tst.b -127(a0)
 bne   i2sackl
 tst.b -255(a0)
 beq   okobs
i2sackl:
 tst.b 256(a0)
 bne   istsackl
 tst.b 257(a0)
 bne   istsackl
 tst.b 384(a0)
 bne   istsackl
 tst.b 385(a0)
 beq   okobs
istsackl:
*                  auf abwÑrts: prÅfe, obs geht
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 tst.b 256(a0)
 bne   lsto
 tst.b 257(a0)
 bne   lsto
 tst.b 384(a0)
 bne   lsto
 tst.b 385(a0)
 bne   lsto
 move #$2700,sr
 clr      _Richt(a4)  stell auf abwÑrts
 add #128, _lz+2(a4)
 move #$2500,sr
 bra  _okobs
lsto:
*                  auf raufwÑrts: prÅfe, obs geht
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea -128(a0,d0),a0
 tst.b (a0)+
 bne   _okobs
 tst.b (a0)
 bne   _okobs
 tst.b -128(a0)
 bne   _okobs
 tst.b -129(a0)
 bne   _okobs
 move #1, _Richt(a4)  stell auf raufwÑrts
 bra  _okobs
oso:
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea  1(a0,d0),a0
o1:sub #129,  a0
 tst.b (a0)+
 bne     o2
 tst.b (a0)
 beq   o1
o2:add #127, a0   zeige letztes freies Matrixfeld in aktu_Richtung
 move.L a0, d1
 tst.b -1(a0)
 bne   i2sacko
 tst.b -2(a0)
 bne   i2sacko
 tst.b 127(a0)
 bne   i2sacko
 tst.b 126(a0)
 beq   okobs
i2sacko:
 tst.b 2(a0)
 bne   istsacko
 tst.b 3(a0)
 bne   istsacko
 tst.b 130(a0)
 bne   istsacko
 tst.b 131(a0)
 beq   okobs
istsacko:
*                auf rechts prÅfe, obs geht
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea  2(a0,d0),a0
 tst.b (a0)+
 bne   ostl
 tst.b (a0)
 bne   ostl
 tst.b 128(a0)
 bne   ostl
 tst.b 127(a0)
 bne   ostl
 move #$2700,sr
 move #-2, _Richt(a4)  stell auf rechts
 addq #1,  _lz+2(a4)
 move #$2500,sr
 bra  _okobs
ostl:
*                auf links prÅfe, obs geht
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea  0(a0,d0),a0
 tst.b -(a0)
 bne   _okobs
 tst.b -(a0)
 bne   _okobs
 tst.b 128(a0)
 bne   _okobs
 tst.b 129(a0)
 bne   _okobs
 move #-1, _Richt(a4)  stell auf links
 bra  _okobs
osu:
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea   1(a0,d0),a0
u1:add #127,  a0
 tst.b (a0)+
 bne     u2
 tst.b (a0)
 beq   u1
u2: sub #129,a0   zeige letztes freies Matrixfeld in aktu_Richtung
 move.L a0, d1
 tst.b -1(a0)
 bne   i2sacku
 tst.b -2(a0)
 bne   i2sacku
 tst.b -129(a0)
 bne   i2sacku
 tst.b -130(a0)
 beq   okobs
i2sacku:
 tst.b 2(a0)
 bne   istsacku
 tst.b 3(a0)
 bne   istsacku
 tst.b -126(a0)
 bne   istsacku
 tst.b -125(a0)
 beq   okobs
istsacku:
*                auf rechts prÅfe, obs geht
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea  2(a0,d0),a0
 tst.b (a0)+
 bne   ustl
 tst.b (a0)
 bne   ustl
 tst.b -128(a0)
 bne   ustl
 tst.b -129(a0)
 bne   ustl
 move #$2700,sr
 move #-2, _Richt(a4)  stell auf rechts
 sub #127, _lz+2(a4)
 move #$2500,sr
 bra  _okobs
ustl:
*                auf links prÅfe, obs geht
 move _lz+2(a4),  d0
 lea   (a4),    a0
 lea  0(a0,d0),a0
 tst.b -(a0)
 bne   _okobs
 tst.b -(a0)
 bne   _okobs
 tst.b -128(a0)
 bne   _okobs
 tst.b -127(a0)
 bne   _okobs
 move #$2700,sr
 sub  #128, _lz+2(a4)
 move #-1, _Richt(a4)  stell auf links
 move #$2500,sr


_okobs: moveq #-1,d0   gib also ne_flag, wenn sackgasse erkannt
okobs:  RTS

*subr gib (je nach boing) s0, s1, s2 oder s3 als sound
sound__:
 lea s3(pc),a0
 btst #3,  boing(a4)
 beq  sound
 lea s1(pc),a0
 btst #1,  boing(a4)
 beq  sound
 lea s2(pc),a0
 btst #2,  boing(a4)
 beq  sound
 lea s0(pc),a0

*subr gibt sound, a0 muss string zeigen!
sound:
 movem.L a1-a3/d0-d3,-(a7)
  pea   (a0)
 move  #32,-(a7)
 trap  #14
 addq   #6, a7
 movem.L (a7)+,a1-a3/d0-d3
RTS

*        periode A        periode B  A&B   A:hÅll B:not hÅllperiode h_form
s0: dc.b 0,9,  1,1,       2,99, 3,1, 7,252, 8,16, 9,9,  11,9, 12,19, 13,13, 130,7
    dc.b       1,2, 130,8
    dc.b       1,3, 130,9
    dc.b       1,4, 130,10,                 8,15
    dc.b       1,5, 130,11
    dc.b 7,-1,      130,3
    dc.b 7,252,1,6, 130,11
    dc.b 7,-1,      130,3
    dc.b 7,252,0,66,130,11
    dc.b 7,-1,      130,3,  7,252,8,13,9,7,130,9
    dc.b 7,-1,      130,3,  7,252,8,10,9,5,130,7
    dc.b 7,-1,      130,3,  7,252,8,7,9,3,130,6
    dc.b 7,-1,      130,3,  7,252,8,5,9,2,130,5
    dc.b 7,-1,      130,3,  7,252,8,3,9,1,130,4
    dc.b 7,-1,      130,3,  7,252,8,1,    130,3
    dc.b       7,-1, 130,0
.even

*        periode A         A&B   A:voll
s2: dc.b 0,9,  1,4,        7,254, 8,12, 130,17, 7,-1, 130,1
    dc.b 0,9,  1,3,        7,254,       130,37, 7,-1, 130,1
    dc.b 0,9,  1,4,        7,254,       130,17, 7,-1, 130,1
    dc.b 0,9,  1,3,        7,254,       130,37, 7,-1, 130,1
    dc.b 0,9,  1,4,        7,254,       130,17, 7,-1, 130,1
    dc.b 0,9,  1,3,        7,254,       130,37, 7,-1, 130,1
    dc.b       7,-1, 130,0
.even

*        periode A   A&B A:voll
s3: dc.b 0,9,  1,15,7,254,8,13,130,7, 7,-1, 130,1
    dc.b 0,9,  1,14,7,254,    130,7, 7,-1, 130,1
    dc.b 0,9,  1,13,7,254,    130,7, 7,-1, 130,1
    dc.b 0,9,  1,12,7,254,    130,7, 7,-1, 130,1
    dc.b 0,9,  1,11,7,254,    130,7, 7,-1, 130,1
    dc.b 0,9,  1,10,7,254,    130,7, 7,-1, 130,1
    dc.b 0,9,  1,9,7,254,     130,7, 7,-1, 130,1
    dc.b 0,9,  1,8,7,254,     130,7, 7,-1, 130,1
    dc.b 0,9,  1,7,7,254,     130,7, 7,-1, 130,1
    dc.b 0,9,  1,6,7,254,8,11,130,7, 7,-1, 130,1
    dc.b 0,9,  1,5,7,254,8,9, 130,7, 7,-1, 130,1
    dc.b 0,9,  1,4,7,254,8,8, 130,7, 7,-1, 130,1
    dc.b 0,9,  1,3,7,254,8,7, 130,7, 7,-1, 130,1
    dc.b 0,9,  1,2,7,254,8,6, 130,7, 7,-1, 130,1
    dc.b 0,179,1,1,7,254,8,5, 130,7, 7,-1, 130,1
    dc.b 0,99, 1,1,7,254,8,4, 130,7, 7,-1, 130,1
    dc.b 0,59, 1,1,7,254,8,3, 130,7, 7,-1, 130,1
    dc.b 0,29, 1,1,7,254,8,2, 130,7, 7,-1, 130,1
    dc.b 0,9,  1,1,7,254,8,1, 130,7, 7,-1, 130,1
    dc.b       7,-1, 130,0
.even

*        periode A  perio B   A&B   A:voll
s1: dc.b 0,9,  1,8, 2,6,3,6,  7,-4, 8,12,  9,12, 130,17, 7,-1, 130,1
    dc.b 0,9,  1,7, 2,6,3,5,  7,-4,             130,21, 7,-1, 130,1
    dc.b 0,9,  1,6, 2,6,3,4,  7,-4,            130,25, 7,-1, 130,1
    dc.b 0,9,  1,5,2,99,3,3,  7,-4,           130,29, 7,-1, 130,1
    dc.b 0,9,  1,4, 2,1,3,2,  7,-4,          130,33, 7,-1, 130,1
    dc.b 0,99, 1,3,2,99,3,2,  7,-4,         130,37, 7,-1, 130,3
    dc.b 0,9,  1,2,2,-1,3,2,  7,-4, 8,9,   130,49, 7,-1, 130,1
    dc.b       7,-1, 130,0
.even
*subr malt crash_striche
crash__:
 move jlz+2(a4), d0
 move jRicht(a4),d2
 btst #3,   boing(a4)
 beq  craSH
 bsr  crash
craSH:
 move lz+2(a4),  d0
 move Richt(a4), d2
 btst #1,   boing(a4)
 beq  crash2
 bsr  crash
crash2:
 move Ylz+2(a4), d0
 move YRicht(a4),d2
 btst #2,   boing(a4)
 beq  crash0
 bsr  crash
crash0:
 move _lz+2(a4), d0
 move _Richt(a4),d2
 btst #0,   boing(a4)
 beq  crash00
 bsr  crash
crash00: RTS

crash:
 lea  (a4),    a0
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 addq  #1, d2
 beq   crli
 bmi   crre
 subq  #2, d2
 beq   crra
 lsr.w #1, d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
 adda  d1, a0
 adda #160,a0
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   hc2u
 moveq #3,  d1
hc2ul:
 and.b #$AB,(a0)
 or.b  #$28,(a0)+
 adda #79,a0
 dbra d1, hc2ul
RTS
hc2u:
 moveq #3, d1
hc3ul
 or.b  #$2,(a0)
 and.b #$FA,(a0)+
 and.b #$BF,(a0)
 or.b  #$80,(a0)
 adda  #79,a0
 dbra d1, hc3ul
RTS
crra:
 lsr.w #1, d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
 adda  d1, a0
 adda #240,a0
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   hc2o
 moveq #3,  d1
hc2ol:
 and.b #$AB,(a0)
 or.b  #$28,(a0)
 suba #80, a0
 dbra d1, hc2ol
RTS
hc2o:
 moveq #3, d1
hc3ol
 or.b  #$2,(a0)
 and.b #$FA,(a0)+
 and.b #$BF,(a0)
 or.b  #$80,(a0)
 suba  #81,a0
 dbra d1, hc3ol
RTS
crre:
 lsr  #1,    d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
 lea 80(a0,d1),a0  = add#80 + add_d1
* falls gesetztes bit rausgeschobn: untres halfByte
 bcs   hc2r
 and.b #3,(a0)
 and.b #3,80(a0)
 or.b #$38,80(a0)
 and.b #3,160(a0)
 and.b #3,240(a0)
 or.b #$38,240(a0)
 and.b #3,320(a0)
RTS
hc2r:
 and.b #$F0,(a0)
 and.b #$F0,80(a0)
 or.b  #3, 80(a0)
 and.b #$F0,160(a0)
 and.b #$F0,240(a0)
 or.b  #3, 240(a0)
 and.b #$F0,320(a0)
RTS
crli:
 lsr  #1,    d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
 lea 80(a0,d1),a0  = add#80 + add_d1
* falls gesetztes bit rausgeschobn: untres halfByte
 bcs   hc2l
 and.b #15,(a0)
 and.b #15,80(a0)
 or.b #$E0,80(a0)
 clr.b    79(a0)
 and.b #15,160(a0)
 and.b #15,240(a0)
 or.b #$E0,240(a0)
 clr.b    239(a0)
 and.b #15,320(a0)
RTS
hc2l:
 and.b #$C0,(a0)
 and.b #$C0,80(a0)
 or.b  #$1E,80(a0)
 and.b #$C0,160(a0)
 and.b #$C0,240(a0)
 or.b  #$1E,240(a0)
 and.b #$C0,320(a0)
RTS


*subr gibt d0.b(ascii) auf BSch
chou:
 movem.L a0/d0,-(a7)
 move.w  d0,  -(a7)
 move.w  #2,  -(a7)
 trap    #1
 addq    #4,   a7
 movem.L (a7)+,a0/d0
RTS

*subr gibt carrRet_LinFeed auf BSch
newline:
 move.L d0,-(a7)
 moveq  #13, d0   carrRet
 bsr    chou
 moveq  #10, d0   LineFeed
 bra    ou1ch

*sub gibt nen BLANK aufn BSchirm
blankou:
move.L d0, -(a7)
 moveq #32,  d0  blank
ou1ch:
 bsr   chou
move.L (a7)+,d0
rts

*subr gibt "!cursor nach links oben!"
curhome:
 move.L d0,-(a7)
 moveq  #27, d0   escape
 bsr    chou
 moveq  #72, d0
 bra    ou1ch


*sub malt senkrStriche bei xPixl= 130,131    !a0d0d1
* somit Begrenzungslinie auf linkesten Punkten des Spielfeldes
striche:
move.w  #399,  d0      soviel+1 tvZeilen pro Bild
move.L  tvb1(a4),    a0
stchl2:
move.L #$60000000,(a0)  pixel 129,130
adda.w  #80,     a0
move   #2654,    d1     verzîg Schleife
stchl3:
dbra    d1,    stchl3
dbra    d0,    stchl2
RTS

*subr lîsch BSchirm, setz tvb1 etc   !aod0d1
strich0:
move.w #$8200,a0
movep.w 1(a0),d0
lsl.L   #8,    d0
move.L  d0,    a0  tvBase
add.L   #16,   d0  quasi die tvBase fÅrs Spielfeld: erst ab dem 16.byte
move.L  d0,  tvb1(a4)
subq.L  #1,    d0
move.L  d0,  tvb11(a4)
move.w  #399,  d0  soviel+1 tvZeilen pro Bild
stchlo:
moveq   #19,   d1
stchl1:
clr.L        (a0)+   nun 80bytes durchgenudelt  = eine tvZeile
dbra   d1,  stchl1
dbra   d0,  stchlo
RTS

*subr malt die ersten SpielrSteinchen aufs tv, zuvor lîsch Matrix  !a0a1d0
pos1st:
 lea   (a4),   a0
 move  #b1L, d0
p1: clr.L  (a0)+
  dbra   d0, p1   nun ist HauptMatrix(incl Rand) gelîscht
 lea  -128(a4),a0
 moveq #127, d0
p2: st      (a0)+
  dbra   d0, p2  nun ist oberer Rand markiert
 lea  -256(a4),a0
 add.L #b1siz,a0
 moveq #127, d0
p4: st      (a0)+
  dbra   d0, p4  nun ist unterer Rand markiert
 lea   (a4), a0
 moveq #99,  d0
p3: st      (a0)
 add   #128, a0
  dbra   d0, p3  nun ist linker Rand (und zugleich rechter) markiert

 move.L #7*128+38,d0   7*128 + 38 = dreieinhalb SteinbreitenVert +Drittel horiz
 move.L d0,-(a7)
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
 adda.w d1, a0
 suba.w #80,a0
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   Yhalf21
 move.b #-1,(a0)
 bra   Yha22
Yhalf21:
 or.b   #15,(a0)+
 or.b  #$F0,(a0)
Yha22:
 move.L (a7),d0
 bsr   Ystmalu     setz punkte in Matrix gemÑû d0 bei Fahrt nach unten
 move.L (a7)+,d0
 add.L  #128, d0   wenn vorher 5*128 + 62, dann jetzt 6*128 + 62
 move.L d0, Ylz(a4)   protokollier letztgesetzten Matrixpunkt
 bsr   Ystmalu

 move.L #81*128+99,d0   81*128 + 99 = weitUnten + weitRechts
 move.L d0,-(a7)
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
 adda.w d1, a0
 suba.w #80,a0
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   jhalf21
 move.b #-1,(a0)
 bra   jha22
jhalf21:
 or.b   #15,(a0)+
 or.b  #$F0,(a0)
jha22:
 move.L (a7),d0
 bsr   jstmalo     setz punkte in Matrix gemÑû d0 bei Fahrt nach oben
 move.L (a7)+,d0
 sub.L  #128, d0   wenn vorher 5*128 + 62, dann jetzt 6*128 + 62
 move.L d0, jlz(a4)   protokollier letztgesetzten Matrixpunkt
 bsr   jstmalo

 move.L #713,d0   5*128 + 73 = zweieinhalb Steinbreiten vert + Mitte horiz
 move.L d0,-(a7)
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
 adda.w d1, a0
 suba.w #80,a0
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   half21
 move.b #-1,(a0)
 bra   ha22
half21:
 or.b   #15,(a0)+
 or.b  #$F0,(a0)
ha22:
 move.L (a7),d0
 bsr   stmalu     setz punkte in Matrix gemÑû d0 bei Fahrt nach unten
 move.L (a7)+,d0
 add.L  #128, d0   wenn vorher 5*128 + 62, dann jetzt 6*128 + 62
 move.L d0, lz(a4)   protokollier letztgesetzten Matrixpunkt
 bsr   stmalu
RTS

*subr setzt MatrixPunkte gemÑû d0.L bei SpielerFahrtrichtung   !a0d0d1
* nach unten und mal entsprechndes aufs tv
stmalu:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 st     1(a0,d0.w)  so Platz fÅr waagrechtes Steinchen belegt: zweiPkt nebndr
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   half2u
 adda.w d1, a0
 moveq #129,d1 
 move.b d1,(a0)+
 adda.w #79,a0
 move.b d1,(a0)+
 adda.w #79,a0
 move.b d1,(a0)+
 adda.w #79,a0
 move.b #-1,(a0)  also so neArt breites u gemalt
RTS
half2u:
 adda.w d1, a0
 moveq  #8, d1
 moveq  #16,d0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   #15,(a0)+
 or.b   #$F0,(a0)
RTS

*subr setz MatrixPunkte gemÑû d0.L bei Fahrtrichtung   !a0d0d1
* nach oben und mal entsprechndes aufs tv
stmalo:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 st     1(a0,d0.w)  so Platz fÅr waagrechtes Steinchen belegt: zweiPkt nebndr
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   half2o
 adda.w d1, a0
 move.b #-1,(a0)+
 adda.w #79,a0
 moveq #129,d1 
 move.b d1,(a0)+
 adda.w #79,a0
 move.b d1,(a0)+
 adda.w #79,a0
 move.b d1,(a0)    also so neArt breites n gemalt
RTS
half2o:
 adda.w d1, a0
 or.b   #15,(a0)+
 or.b   #$F0,(a0)
 adda.w #79,a0
 moveq  #8, d1
 moveq  #16,d0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   d1,(a0)+
 or.b   d0,(a0)
RTS


*subr setz MatrixPunkte gemÑû d0.L bei Fahrtrichtung   !a0d0d1
* nach rechts und mal entsprechndes aufs tv
stmalr:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 addq #1,a0
 st    127(a0,d0.w)  so Platz fÅr aufrechtes Steinchen belegt: zweiPkt untrndr
 subq #1,a0
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
* falls gesetztes bit rausgeschobn: untres halfByte
 bcs   half2r
 adda.w d1, a0
 or.b  #$F0,(a0)+
 adda.w #79,a0
 moveq #$10,d1
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b  #$F0,(a0)  also so ne Art ] auf tv
RTS
half2r:
 adda.w d1, a0
 or.b   #15,(a0)+
 adda.w #79,a0
 moveq  #1, d1
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   #15,(a0)  also so ne Art ] auf tv
RTS

*subr setz MatrixPunkte gemÑû d0.L bei Fahrtrichtung   !a0d0d1
* nach links und mal entsprechndes aufs tv
stmall:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 addq #1,a0
 st    127(a0,d0.w)  so Platz fÅr aufrechtes Steinchen belegt: zweiPkt untrndr
 subq #1,a0
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
* falls gesetztes bit rausgeschobn: untres halfByte
 bcs   half2l
 adda.w d1, a0
 or.b  #$F0,(a0)+
 adda.w #79,a0
 moveq #$80,d1
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b  #$F0,(a0)  also so ne Art ] auf tv
RTS
half2l:
 adda.w d1, a0
 or.b   #15,(a0)+
 adda.w #79,a0
 moveq  #8, d1
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   #15,(a0)  also so ne Art ] auf tv
RTS

*subr setzt Y_MatrixPunkte gemÑû d0.L bei SpielerFahrtrichtung   !a0d0d1
* nach unten und mal entsprechndes aufs tv
Ystmalu:
Ystmalo:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 st     1(a0,d0.w)  so Platz fÅr waagrechtes Steinchen belegt: zweiPkt nebndr
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   Yhalf2u
 adda.w d1, a0
 move.b #$AA,(a0)+
 adda.w #79,a0
 move.b #$54,(a0)+
 adda.w #79,a0
 move.b #$AA,(a0)+
 adda.w #79,a0
 move.b #-2,(a0)  also so neArt breites,graugefÅlltes u gemalt
RTS
Yhalf2u:
 adda.w d1, a0
 moveq  #10,d1
 moveq #$A0,d0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   #5,(a0)+
 or.b  #$40,(a0)
 adda.w #79,a0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   #15,(a0)+
 or.b   #$E0,(a0)
RTS

*subr setz MatrixPunkte gemÑû d0.L bei Fahrtrichtung   !a0d0d1
* nach rechts und mal entsprechndes aufs tv
Ystmalr:
Ystmall:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 addq #1,a0
 st    127(a0,d0.w)  so Platz fÅr aufrechtes Steinchen belegt: zweiPkt untrndr
 subq #1,a0
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
* falls gesetztes bit rausgeschobn: untres halfByte
 bcs   Yhalf2r
 adda.w d1, a0
 moveq #$B0,d0
 moveq #$50,d1
 or.b   d0,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d0,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d0,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d0,(a0)+   also so ne Art graues ] auf tv
RTS
Yhalf2r:
 adda.w d1, a0
 moveq  #11,d0
 moveq  #5, d1
 or.b   d0,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d0,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d0,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d0,(a0)  also so ne Art ] auf tv
RTS

*subr setzt j_MatrixPunkte gemÑû d0.L bei SpielerFahrtrichtung   !a0d0d1
* nach unten und mal entsprechndes aufs tv
jstmalu:
jstmalo:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 st     1(a0,d0.w)  so Platz fÅr waagrechtes Steinchen belegt: zweiPkt nebndr
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   jhalf2u
 adda.w d1, a0
 move.b #$92,(a0)+
 adda.w #79,a0
 move.b #$44,(a0)+
 adda.w #79,a0
 move.b #$92,(a0)+
*  also so neArt breites,hellgraugefÅlltes u gemalt
RTS
jhalf2u:
 adda.w d1, a0
 moveq  #2,d1
 moveq #$90,d0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   #4,(a0)+
 or.b  #$40,(a0)
 adda.w #79,a0
 or.b   d1,(a0)+
 or.b   d0,(a0)
RTS

*subr setz MatrixPunkte gemÑû d0.L bei Fahrtrichtung   !a0d0d1
* nach rechts und mal entsprechndes aufs tv
jstmalr:
jstmall:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 addq #1,a0
 st    127(a0,d0.w)  so Platz fÅr aufrechtes Steinchen belegt: zweiPkt untrndr
 subq #1,a0
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
* falls gesetztes bit rausgeschobn: untres halfByte
 bcs   jhalf2r
 adda.w d1, a0
 moveq #$90,d0
 moveq #$60,d1
jjj: or.b d0,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d0,(a0)+
 adda.w #159,a0
 or.b   d0,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d0,(a0)+   also so ne Art hellgraues ] auf tv
RTS
jhalf2r:
 adda.w d1, a0
 moveq  #9, d0
 moveq  #6, d1
 bra    jjj

*subr malt die ersten computrSteinchen aufs tv    !a0a1d0d1d2
_pos1st:
 move.L #84*128+59,d2  84*128+59= weitUnten  + etwa Mitte horiz
 clr         _Richt(a4)   stell abwÑrts
 moveq  #3,   d0
 and.b $FFFA23,d0    quasi WÅrfel: anfangsRichtung
 beq    _okW
 addq   #1,  _Richt(a4)  stell aufwÑrts
 subq.b #1,  d0
 beq    _prauf
 subq   #2,  _Richt(a4)  stell Links
 subq.b #1,  d0
 beq    _plinks
 subq   #1,  _Richt(a4)  stell Rechts
 move.L d2,   d0
 bsr   _stmalr     setz punkte in Matrix gemÑû d0 bei Fahrt nach rechts
 add    #1,   d2
r_: move.L d2, _lz(a4)   protokollier letztgesetzten Matrixpunkt
 move.L d2,   d0
 bsr   _stmalr
RTS
_plinks:
 move.L d2,   d0
 bsr   _stmall
 sub    #1,   d2
 bra    r_
_prauf:
 move.L d2,   d0
 bsr   _stmalu     setz punkte in Matrix gemÑû d0 bei Fahrt nach unten/oben
 sub    #128, d2   =1MatrxZeil hîher
 bra    o_
_okW:
 move.L d2,   d0
 bsr   _stmalu     setz punkte in Matrix gemÑû d0 bei Fahrt nach unten
 add    #128, d2    =1MatrxZeil tiefer
o_: move.L d2, _lz(a4)   protokollier letztgesetzten Matrixpunkt
 move.L d2,   d0
 bsr   _stmalu
RTS

*subr setzt MatrixPunkte gemÑû d0.L bei computrFahrtrichtung   !a0d0d1
* nach unten und mal entsprechndes aufs tv
_stmalu:
_stmalo:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 st     1(a0,d0.w)  so Platz fÅr waagrechtes Steinchen belegt: zweiPkt nebndr
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w  #1, d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
 adda.w d1, a0
* falls gesetztes bit rausgeschobn: nur untres halfByte + obres auf nÑcAdr
 bcs   _half2u
 moveq #$FE,d1
 move.b d1,(a0)+
 adda.w #79,a0
 move.b d1,(a0)+
 adda.w #79,a0
 move.b d1,(a0)  also schwarz gemalt
RTS
_half2u:
 moveq #15, d1
 moveq #$E0,d0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   d1,(a0)+
 or.b   d0,(a0)
 adda.w #79,a0
 or.b   d1,(a0)+
 or.b   d0,(a0)
RTS

*subr setz MatrixPunkte gemÑû d0.L bei computrFahrtrichtung   !a0d0d1
* nach rechts und mal entsprechndes aufs tv
_stmalr:
_stmall:
 lea   (a4), a0       MatrixBase
 st     0(a0,d0.w)
 addq #1,a0
 st    127(a0,d0.w)  so Platz fÅr aufrechtes Steinchen belegt: zweiPkt untrndr
 subq #1,a0
 moveq #127,d1
 and.b d0,  d1      MatrixSpaltenNr
 lsr.w #7,  d0      divDurch128= MatrixZeilnNr
 mulu  #320,d0      soviele tvBytes aus ZeilNr berechnet (4zeiln a 80Bytes)
 move.L tvb1(a4),a0   Adr des ersten Bytes des Spielfeldes aufm tv
 adda.w d0, a0    ab diesem tvByte beginnt die aktuelle SpielfeldZeile
 lsr.w #1,  d1    um soviel Bytes noch nach rechts: aktuSpielfeldDopplPkt
 adda.w d1, a0
* falls gesetztes bit rausgeschobn: untres halfByte
 bcs   _half2r
 moveq #$E0,d1
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)  also schwarz auf tv
RTS
_half2r:
 moveq  #14, d1
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)+
 adda.w #79,a0
 or.b   d1,(a0)
RTS

*subr gibt d0.L als neun dezZiffern auf tv     !d0
d0Ldez:
 move.L d0, -(a7)
 moveq  #47, d0            vor '0'
zh7:
 addq   #1,  d0           mindest '0'
 sub.L  #10000000,(a7)
 bcc    zh7
 add.L  #10000000,(a7)
 bsr    chou
 moveq  #47, d0            vor '0'
zh6:
 addq   #1,  d0
 sub.L  #1000000,(a7)
 bcc    zh6
 add.L  #1000000,(a7)
 bsr    chou
 moveq  #47, d0            vor '0'
zh5:
 addq   #1,  d0           mindest '0'
 sub.L  #100000,(a7)
 bcc    zh5
 add.L  #100000,(a7)
 bsr    chou
 moveq  #47, d0            vor '0'
zh4:
 addq   #1,  d0
 sub.L  #10000,(a7)
 bcc    zh4
 add.L  #10000,(a7)
 bsr    chou
 moveq  #47, d0            vor '0'
zh3:
 addq   #1,  d0           mindest '0'
 sub.L  #1000,(a7)
 bcc    zh3
 add.L  #1000,(a7)
 bsr    chou
 moveq  #47, d0            vor '0'
zh2:
 addq   #1,  d0
 sub.L  #100,(a7)
 bcc    zh2
 add.L  #100,(a7)
 bsr    chou
 moveq  #47, d0            vor '0'
zh1:
 addq   #1,  d0           mindest '0'
 sub.L  #10,(a7)
 bcc    zh1
 add.L  #10,(a7)
 bsr    chou
 moveq  #47, d0            vor '0'
zh0:
 addq   #1,  d0
 sub.L  #1, (a7)
 bcc    zh0
 add.L  #1, (a7)
 bsr    chou
 addq   #4,  a7
RTS

* (INTERRUPTrout) durch timerA ausgelîst
timA:
 move.L a4,-(a7)
 move.L usp, a4
 subq.b #1,softim(a4)
 bpl    RtA
 move  ststart(a4),softim(a4)  softTimer wieder mit startwert laden

movem.L d0-d3/a0-a3,-(a7)
add.L  #5,  this(a4)
add.w  #1,  tacho(a4)  ZÑhler, der zur grafischen Anzeige verhilft
moveq  #0,  d0
move   tacho(a4),d0
move.L tvb11(a4),a0   ab dort quasiTachometer(abwÑrts) auf BSchirm
lsr.w  #3,  d0    nur jedes achte Steinchen fÅhrt zu mehr TachoAnzeige
lsl.L  #4,  d0
add.L  d0,  a0  das 16fache
lsl.L  #2,  d0   das 64fache
st     0(a0,d0.L)   zusammen das 80fache: 80byte pro tvZeile

btst   #3, boing(a4)
bne    jRtAv
add.L  #5,  scor3(a4)  spieler3
move.L jlz(a4),    d0  letztgesetztr Matrixpkt
tst    jRicht(a4)
beq    jnachu
bpl    jnacho
cmp    #-1, jRicht(a4)
beq    jnachli

 addq  #1,   d0
 lea   (a4),    a0
 lea   0(a0,d0),a0  obrerMatrixPkt des neuen Steinchens
 tst.b (a0)
 bne   jRAAZr1
 tst.b 128(a0)
 bne   jRAAZr2
jRr:move d0, jlz+2(a4)
 bsr   jstmalr
 bra   jRtAv
jRAAZr1:
 tst.b 128(a0)
 bne   jRtAz
 tst.b 256(a0)
 bne   jRtAz
 add   #128, d0   um einen MPkt nach unten ausweichen
 bra   jRr
jRAAZr2:
 tst.b -128(a0)
 bne   jRtAz
 sub   #128, d0   um einen MPkt nach oben ausweichen
 bra   jRr

jnachli:
 subq.L #1,   d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   jRAAZl1
 tst.b 128(a0)
 bne   jRAAZl2
jRl: move d0, jlz+2(a4)
 bsr   jstmall
 bra   jRtAv
jRAAZl1:
 tst.b 128(a0)
 bne   jRtAz
 tst.b 256(a0)
 bne   jRtAz
 add   #128, d0   um einen MPkt nach unten ausweichen
 bra   jRl
jRAAZl2:
 tst.b -128(a0)
 bne   jRtAz
 sub   #128, d0   um einen MPkt nach oben ausweichen
 bra   jRl

jnachu:
 add   #128,  d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   jRAAZu1
 tst.b 1(a0)
 bne   jRAAZu2
jRu: move d0, jlz+2(a4)
 bsr   jstmalu
 bra   jRtAv
 bra   jRu
jRAAZu1:
 tst.b 1(a0)
 bne   jRtAz
 tst.b 2(a0)
 bne   jRtAz
 addq  #1,  d0   um einen MPkt nach rechts ausweichen
 bra   jRu
jRAAZu2:
 tst.b -1(a0)
 bne   jRtAz
 subq  #1,  d0   um einen MPkt nach li ausweichn
 bra   jRu
jRAAZo1:
 tst.b 1(a0)
 bne   jRtAz
 tst.b 2(a0)
 bne   jRtAz
 addq  #1,  d0   um einen MPkt nach rechts ausweichen
 bra   jRu
jRAAZo2:
 tst.b -1(a0)
 bne   jRtAz
 subq  #1,  d0   um einen MPkt nach li ausweichn
 bra   jRo
jnacho:
 sub   #128,  d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   jRAAZo1
 tst.b 1(a0)
 bne   jRAAZo2
jRo: move d0, jlz+2(a4)
 bsr   jstmalo
jRtAv:

btst   #2, boing(a4)
bne    jswurm
add.L  #5,  scor2(a4)  spieler2
move.L Ylz(a4),    d0     letztgesetztr Matrixpkt
tst    YRicht(a4)
beq    Ynachu
bpl    Ynacho
cmp    #-1, YRicht(a4)
beq    Ynachli

 addq  #1,   d0
 lea   (a4),    a0
 lea   0(a0,d0),a0  obrerMatrixPkt des neuen Steinchens
 tst.b (a0)
 bne   YRAAZr1
 tst.b 128(a0)
 bne   YRAAZr2
YRr:move d0, Ylz+2(a4)
 bsr   Ystmalr
 bra   YRtAv
YRAAZr1:
 tst.b 128(a0)
 bne   YRtAz
 tst.b 256(a0)
 bne   YRtAz
 add   #128, d0   um einen MPkt nach unten ausweichen
 bra   YRr
YRAAZr2:
 tst.b -128(a0)
 bne   YRtAz
 sub   #128, d0   um einen MPkt nach oben ausweichen
 bra   YRr

Ynachli:
 subq.L #1,   d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   YRAAZl1
 tst.b 128(a0)
 bne   YRAAZl2
YRl: move d0, Ylz+2(a4)
 bsr   Ystmall
 bra   YRtAv
YRAAZl1:
 tst.b 128(a0)
 bne   YRtAz
 tst.b 256(a0)
 bne   YRtAz
 add   #128, d0   um einen MPkt nach unten ausweichen
 bra   YRl
YRAAZl2:
 tst.b -128(a0)
 bne   YRtAz
 sub   #128, d0   um einen MPkt nach oben ausweichen
 bra   YRl

Ynachu:
 add   #128,  d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   YRAAZu1
 tst.b 1(a0)
 bne   YRAAZu2
YRu: move d0, Ylz+2(a4)
 bsr   Ystmalu
 bra   YRtAv
 bra   YRu
YRAAZu1:
 tst.b 1(a0)
 bne   YRtAz
 tst.b 2(a0)
 bne   YRtAz
 addq  #1,  d0   um einen MPkt nach rechts ausweichen
 bra   YRu
YRAAZu2:
 tst.b -1(a0)
 bne   YRtAz
 subq  #1,  d0   um einen MPkt nach li ausweichn
 bra   YRu
YRAAZo1:
 tst.b 1(a0)
 bne   YRtAz
 tst.b 2(a0)
 bne   YRtAz
 addq  #1,  d0   um einen MPkt nach rechts ausweichen
 bra   YRu
YRAAZo2:
 tst.b -1(a0)
 bne   YRtAz
 subq  #1,  d0   um einen MPkt nach li ausweichn
 bra   YRo
Ynacho:
 sub   #128,  d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   YRAAZo1
 tst.b 1(a0)
 bne   YRAAZo2
YRo: move d0, Ylz+2(a4)
 bsr   Ystmalo
YRtAv:

jswurm:
btst   #1, boing(a4)
bne    RtAv
add.L  #5,  score(a4)  zÑhle Steinchen spieler1
move.L  lz(a4),d0     letztgesetztr Matrixpkt
tst    Richt(a4)
beq    nachu
bpl    nacho
cmp    #-1, Richt(a4)
beq    nachli

 addq  #1,   d0
 lea   (a4),    a0
 lea   0(a0,d0),a0  obrerMatrixPkt des neuen Steinchens
 lea   128(a0), a1  untrer MPkt
 tst.b (a0)
 bne   RAAZr1
 tst.b (a1)
 bne   RAAZr2
Rr: move d0, lz+2(a4)
 bsr   stmalr
 bra   RtAv
RAAZr1:
 tst.b (a1)
 bne   RtAz
 tst.b 128(a1)
 bne   RtAz
 add   #128, d0   um einen MPkt nach unten ausweichen
 bra   Rr
RAAZr2:
 tst.b -128(a0)
 bne   RtAz
 sub   #128, d0   um einen MPkt nach oben ausweichen
 bra   Rr

nachli:
subq.L  #1,    d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 lea   128(a0), a1
 tst.b (a0)
 bne   RAAZl1
 tst.b (a1)
 bne   RAAZl2
Rl: move d0, lz+2(a4)
 bsr   stmall
 bra   RtAv
RAAZl1:
 tst.b (a1)
 bne   RtAz
 tst.b 128(a1)
 bne   RtAz
 add   #128, d0   um einen MPkt nach unten ausweichen
 bra   Rl
RAAZl2:
 tst.b -128(a0)
 bne   RtAz
 sub   #128, d0   um einen MPkt nach oben ausweichen
 bra   Rl

nachu:
 add   #128,  d0
 lea   (a4),    a0
 lea   1(a0,d0),a1
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   RAAZu1
 tst.b (a1)
 bne   RAAZu2
Ru: move d0, lz+2(a4)
 bsr   stmalu
 bra   RtAv
 bra   Ru
RAAZu1:
 tst.b (a1)
 bne   RtAz
 tst.b 1(a1)
 bne   RtAz
 addq  #1,  d0   um einen MPkt nach rechts ausweichen
 bra   Ru
RAAZu2:
 tst.b -1(a0)
 bne   RtAz
 subq  #1,  d0   um einen MPkt nach li ausweichn
 bra   Ru
RAAZo1:
 tst.b (a1)
 bne   RtAz
 tst.b 1(a1)
 bne   RtAz
 addq  #1,  d0   um einen MPkt nach rechts ausweichen
 bra   Ru
RAAZo2:
 tst.b -1(a0)
 bne   RtAz
 subq  #1,  d0   um einen MPkt nach li ausweichn
 bra   Ro
nacho:
 sub   #128,  d0
 lea   (a4),    a0
 lea   1(a0,d0),a1
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   RAAZo1
 tst.b (a1)
 bne   RAAZo2
Ro: move d0,  lz+2(a4)
 bsr   stmalo
RtAv:
 btst  #0,   boing(a4)
 bne   _RtAv
move.L  _lz(a4),  d0    letztgesetztr Matrixpkt
tst    _Richt(a4)
beq    _nachu
bpl    _nacho
cmp    #-1, _Richt(a4)
beq    _nachli

addq.L  #1,    d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 lea   128(a0), a1
 tst.b (a0)
 bne   _RtAre
 tst.b (a1)
 bne   _RtAre
move.w  d0,   _lz+2(a4)
bsr     _stmalr
bra     _RtAv

_nachli:
subq.L  #1,    d0
 lea   (a4),    a0
 lea   0(a0,d0),a0
 lea   128(a0), a1
 tst.b (a0)
 bne   _RtAli
 tst.b (a1)
 bne   _RtAli
move.w  d0,   _lz+2(a4)
bsr     _stmall
bra     _RtAv

_nachu:
 add   #128,  d0
 lea   (a4),    a0
 lea   1(a0,d0),a1
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   _RtAab
 tst.b (a1)
 bne   _RtAab
 move.w d0,  _lz+2(a4)
 bsr   _stmalu
 bra   _RtAv
_nacho:
 sub   #128,  d0
 lea   (a4),    a0
 lea   1(a0,d0),a1
 lea   0(a0,d0),a0
 tst.b (a0)
 bne   _RtAauf
 tst.b (a1)
 bne   _RtAauf
 move.w d0,  _lz+2(a4)
 bsr   _stmalo
_RtAv:
 movem.L (a7)+,d0-d3/a0-a3
RtA:
 move.b #SAend,mfpSA       lîsch inServicBit
 move.L (a7)+,a4
 RTE

jRtAz:
 bset #3, boing(a4)  drittrSpieler angeboxt
 bra _RtAv
YRtAz:
 bset #2, boing(a4)  zweitrSpieler angeboxt
 bra _RtAv
RtAz:
 bset #1, boing(a4)  erstrSpieler angeboxt
 bra _RtAv
_RtAz:
 bset #0, boing(a4)  computr angeboxt
 bra _RtAv
*compWurm kann li/re nicht weiter:
_RtAli:
 addq.L #3,d0
 addq.L #3,a0   somit zus mit subq(s.u.): zeig letzten matrxPkt
_RtAre:
 subq.L #2,d0
 subq.L #2,a0       fÅr li: s.o.  fÅr re: zeig vorletzten MatrxPkt
 cmp   #799,this+2(a4)  wenn Wurm noch kurz: wÅrfeln
 bcs   wuou
 tst.b _nxR+1(a4)       guck,ob hier was vernÅnftiges steht
 bmi   wuou
 btst #0, _nxR+1(a4)
 bne  nwo
 bra  RAreUn
wuou:
 btst #0, $FFFA23  timerC: quasi wÅrfeln
 bne  RAreUn
nwo: tst.b -256(a0)   gehts nach obn weiter?
 bne  RAreU
 tst.b -255(a0)   gehts obn weiter zum zweiten(mind zwei steinchn weit)?
 bne  RAreU
RAreO:
 tst.b -128(a0)   zum drittn
 bne  RAreUU
 tst.b -127(a0)   und zum vierten
 bne  RAreUU
 move #1, _Richt(a4)  also gehts obn weiter
 sub  #128, d0
 move  d0,  _lz+2(a4)
 bsr  _stmalo
 bra  _RtAv
RAreOO:
 tst.b -128(a0)
 bne   _RtAz
 tst.b -127(a0)
 bne   _RtAz
 move #1, _Richt(a4)  also gehts obn weiter
 sub  #128, d0
 move  d0,  _lz+2(a4)
 bsr  _stmalo
 bra  _RtAv
RAreUn:
 tst.b 384(a0)
 bne   RAreO
 tst.b 385(a0)     wenn nach unten keine zwei Steinchen passen: evt nach obn weitr
 bne   RAreO
RAreU:
 tst.b 256(a0)
 bne   RAreOO
 tst.b 257(a0)     wenn nach unten keine Steinchen passen: nach obn weitr
 bne   RAreOO
 clr        _Richt(a4)  also nach unten weiter
 add   #256, d0
 move  d0,   _lz+2(a4)
 bsr   _stmalu
 bra   _RtAv
RAreUU:
 tst.b 256(a0)
 bne   _RtAz
 tst.b 257(a0)
 bne   _RtAz
 clr        _Richt(a4)  also nach unten weiter
 add   #256, d0
 move  d0,   _lz+2(a4)
 bsr   _stmalu
 bra   _RtAv

*compWurm kann aufw/abwÑrts nicht weiter
_RtAauf:
 add  #384,d0
 add  #384,a0   somit zus mit sub(s.u.): zeig letzten matrxPkt
_RtAab:
 sub  #256,d0
 sub  #256,a0       fÅr auf: s.o.  fÅr ab: zeig vorletzten MatrxPkt
 cmp  #999,this+2(a4)  wenn Wurm noch kurz: wÅrfeln
 bcs   wulr
 tst.b _nxR+1(a4)     guck,ob hier was vernÅnftiges steht
 bpl   wulr
 btst #0, _nxR+1(a4)
 bne  nwl
 bra  RA_re
wulr:
 btst #0, $FFFA23   timerC quasi wÅrfle: nach re odr nach li weitermachen?
 bne  RA_re
nwl: tst.b -2(a0)   gehts nach li weiter?
 bne  RA_r
 tst.b 126(a0)   gehts li weiter zum zweiten(mind zwei steinchn weit)?
 bne  RA_r
RA_l:
 tst.b -1(a0)   zum drittn
 bne  RA_rr
 tst.b 127(a0)   und zum vierten
 bne  RA_rr
 move #-1, _Richt(a4)  also gehts links weiter
 subq #1, d0
 move  d0,  _lz+2(a4)
 bsr  _stmall
 bra  _RtAv
RA_ll:
 tst.b -1(a0)
 bne   _RtAz
 tst.b 127(a0)
 bne   _RtAz
 move #-1, _Richt(a4)  also gehts li weiter
 subq  #1, d0
 move  d0,  _lz+2(a4)
 bsr  _stmall
 bra  _RtAv
RA_re:
 tst.b 3(a0)
 bne   RA_l
 tst.b 131(a0)  wenn nach re keine zwei Steinchen passen: evt nach li weitr
 bne   RA_l
RA_r:
 tst.b 2(a0)
 bne   RA_ll
 tst.b 130(a0)     wenn nach re keine Steinchen passen: nach li weitr
 bne   RA_ll
 move  #-2, _Richt(a4)  also nach re weiter
 add   #2, d0
 move  d0,   _lz+2(a4)
 bsr   _stmalr
 bra   _RtAv
RA_rr:
 tst.b 2(a0)
 bne   _RtAz
 tst.b 130(a0)
 bne   _RtAz
 move  #-2,  _Richt(a4)  also nach re weiter
 add   #2, d0
 move  d0,   _lz+2(a4)
 bsr   _stmalr
 bra   _RtAv

*subr wartet bis w oder v oder q  losgelassen
waitu:
 clr        -(a7)
wa_u:
 move.b LzKey(a4),d0
 bpl    wa_u
 cmp.b  #$90,d0 also stand im tastatur-Buffer q-loslaû?
 beq    cqpoi
 cmp.b  #$D2,d0 insert wie w behandeln
 beq    cwpoi
 cmp.b  #$F4,d0 mouseLi wie w behandeln
 beq    cwpoi
 cmp.b  #$F5,d0 mousRe wie w behandeln
 beq    cwpoi
 cmp.b  #$92,d0 joyst wie w behandln
 bcs    cwpoi
 cmp.b  #$B1,d0 N?
 beq    cepoi
 cmp.b  #$B0,d0 B?
 beq    cBpoi
 cmp.b  #$98,d0 O?
 beq    cOpoi
 cmp.b  #$A5,d0 K?
 beq    cpr
 cmp.b  #$A6,d0 L?
 beq    cL
 bra    wa_u
cqpoi: move #1,(a7)  setz cyFlag (und nur diese)
 bra    cpr
cwpoi: move #2,(a7)  overflowFlag
 bra    cpr
cOpoi: move #10,(a7)  overflowFlag und miFlg
 bra    cpr
cL:   move #8,(a7)  miFlg
 bra   cpr
cBpoi: move #12,(a7)  miFlg+eq
 bra   cpr
cepoi: move #4,(a7)   zeroFlag
cpr:   clr       LzKey(a4)
       move (a7)+,ccr
       RTS

*subr gibt text ab a0 aufs tv    !a0d0
*txout:
* bra     ch2ou
ch1ou:
 movem.L a0-a3/d0-d3,-(a7)
 move.w  d0,        -(a7)
 move.L  #$30005,  -(a7)   ausgabe(3) auf tv nur druckbar(5)
 trap    #13
 addq    #6,       a7
 movem.L (a7)+,a0-a3/d0-d3
txout:
ch2ou:
 move.b  (a0)+,      d0
 bne     ch1ou
RTS

*subr gibt drunterstehenden text aus, weiter bei txout      !a0
tx1: lea 4(pc),a0
     bra txout
dc.b 'Q   W    N  B',0
.even
tx2: lea 4(pc),a0
     bra txout
dc.b 'QuitWeitrNeuBleib',0
.even
tx10: lea 4(pc),a0
     bra txout
dc.b ' Score',0
.even
tx11: lea 4(pc),a0
     bra txout
dc.b ' Lost',0
.even
tx12: lea 4(pc),a0
     bra txout
dc.b ' Game',0
.even
tx13: lea 4(pc),a0
     bra txout
dc.b ' Level',0
.even
tx14: lea 4(pc),a0
txo:  bra txout
dc.b 1,3,2,4,' =joystick',0
.even
tx22: lea 4(pc),a0
     bra txo
dc.b 'auf: A, CONTR',0
.even
tx23: lea 4(pc),a0
     bra txo
dc.b 'ab:  Y, ALTERN',0
.even
tx24: lea 4(pc),a0
     bra txo
dc.b 'Li:  -, LiSHIFT',0
.even
tx25: lea 4(pc),a0
txq:  bra txo
dc.b 'Re:  <, ReSHIFT',0
.even
tx1_: lea 4(pc),a0
     bra txq
dc.b ' Scor2',0
.even
tx31: lea 4(pc),a0
     bra txq
dc.b 'O    K  L',0
.even
tx32: lea 4(pc),a0
     bra txq
dc.b 'WeitrNeuLaûLevel',0
.even
tx33: lea 4(pc),a0
     bra txq
dc.b 'je ohne Schwarz',0
.even
tx41: lea 4(pc),a0
     bra txq
dc.b ' Lost2',0
.even
tx51: lea 4(pc),a0
     bra txq
dc.b ' Lost3',0
.even
tx1__: lea 4(pc),a0
     bra txq
dc.b ' Scor3',0
.even

*subr melde diverse parameter aufs tv  !a0d0d1
melde:
bsr   curhome
move.L score(a4),d0
bsr   d0Ldez
bsr   tx10
bsr   newline
move.L scor2(a4),d0
bsr   d0Ldez
bsr   tx1_
bsr   newline
move.L scor3(a4),d0
bsr   d0Ldez
bsr   tx1__
bsr   newline
bsr   newline
move.L lifes(a4),d0
bsr   d0Ldez
bsr   tx11
bsr   newline
move.L lifs2(a4),d0
bsr   d0Ldez
bsr   tx41
bsr   newline
move.L lifs3(a4),d0
bsr   d0Ldez
bsr   tx51
bsr   newline
move.L gamnr(a4),d0
bsr   d0Ldez
bsr   tx12
bsr   newline
moveq  #0, d0
move  level(a4),d0
bsr   d0Ldez
bsr   tx13
bsr   newline
bsr   newline
bsr   tx14
bsr   newline
bsr   newline
bsr   tx22
bsr   newline
bsr   tx23
bsr   newline
bsr   tx24
bsr   newline
bsr   tx25
bsr   newline
bsr   newline
bsr   newline
RTS

c_s:
dc.w 0

