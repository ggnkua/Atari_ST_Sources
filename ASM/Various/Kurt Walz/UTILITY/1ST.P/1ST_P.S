*holt FILE gibts auf drucker "P6", zeigts auch auf tv
 .text

ttr: equ -90    ab echt_hier bytes von tastatur
mxt: equ ttr+77 also maximal 77bytes
*hndl: equ -94  handleNr
EE:  equ -98  ab hier KEIN eingelesner Text mehr
tut: equ -100  flagByteLow(eq=Pause) Hi(eq=specials)
unz: equ -104
un_: equ -108 protokoll,ab wo unterste tvTextZeile und die folgende
AA:  equ -112 Anfang der augenblicklichDruckendenZeile
sty: equ -114  letztes styleInfo
st_: equ -116 styleAtrribut der letzten Ausgabe an P6
sst: equ -118  weitre style bits (breit,proport,12cpi)
vor: equ -120
inf: equ -124  adr,ab wo infos aus aufrufendem programm
reR: equ -126  rechtrRand
rR_: equ -128  =0,wenn am Zeilenende Blank war
BlE: equ -130  =FF,wenn am Ende Blank sein wird,sonst0
BlS: equ -132  =0, wenn kein Blocksatz

begi:
 move.L 4(a7),a0  ab hier eventuell Infos (falls aus 1stword.prg gestartet)
 link  a4,#-900  platz Åbrm stack fÅrdiverse variablen
 subq  #8, a4
 move.L a0,inf(a4)
 move.b #107,reR(a4)
 clr        BlS(a4)

 bsr   iniP6
 bne   okanf
 moveq #13,d0  warne: drucker antw nicht
 bsr   tx_rd
 bsr   iniP6
okanf:
 moveq #73,d0
 bsr   pE1
 moveq #1,d0    P6 auf IBMzeichnsatz
 bsr   pr1
 moveq #10, d0     frag nach filename
 bsr   tx
 move.L inf(a4),a0
 LEA   150(a0),a1   *zwi a0 und a1 kînnte evtl ein pathname stehen
 cmp.l a0,     a7
 bcs  h9
hh: cmp.b #'.',(a0)+
 beq  h2
 cmp.L a1,     a0
 bcc  h9
 bra  hh
h2:
 LEA  (a0), a1       *also . des filename gefunden  (funktioniert bei fast
h3: cmp.b #'.',(a0)+     allen TOS-Versionen)
 bhs   h3
 clr.b -(a0)   *hier text des pathname zuende
H4:
 CMP.B #'.',-(a1)
 BHS   H4
 ADDQ.L #1,A1
 lea  (a1),a0
 bsr  tx_
 lea  (a1),a0
 bra  ooo

h9: bsr rd

ooo:
 pea   (a0)
 move  #$3D,-(a7)  * open
 trap  #1
 tst   d0
 bmi   fehler
opnOK:
* move  d0,  hndl(a4)
 move d0,d4
 pea   LL(pc)       ab hier memory beschriftbar
 lea  -998(a7),a0   bis hier
 sub.L (a7),  a0
 move.L a0, -(a7)   RAMlÑnge
 move.w d0, -(a7)   handle-Nr des file
 move  #$3F,-(a7)  read
 trap   #1
 adda.w #12,a7
 move.L d0,d3
 bpl   readOK
fehler:
 moveq #11,d0   fehlermeldung
 bra   das__wars
specials:

 moveq #24,d0
 bsr   tx_r
 bpl   nixdirekt
 moveq #25,d0
 bsr   tx
dRD:
 bsr   rd1
 cmp.b #13,d0
 beq   dCR
 cmp.b #1,d0
 beq   anfng
 cmp.b #8,d0
 bne   ok1
 moveq #$7F,d0  BackSpace=DELETE
ok1:
 cmp.b #$DD,d0  ›_ATARI
 bne   ok2
 moveq #$15,d0  ›_P6
ok2:
 cmp.b #$9E,d0  û_ATARI
 bne   ok3
 moveq #$E1,d0
ok3:
 cmp.b #2,d0
 bne   okd
 moveq #8,d0  CONTR B = 1zurÅck
okd:
 bsr   pr1
 bra   dRD
dCR:
 bsr  pnewline
 bsr  newline
 bra  dRD

nixdirekt:
 clr.b       BlS+1(a4)
 move.L AA(a4),a0
 bsr  ZeiLang  guck nach LÑnge der ersten echten TextZeile,protok reR(a4)

 moveq #0,d1
 moveq #9,d0  proportionalSchrift?
 bsr   tx_r
 smi      d1
 bpl   okReRa
 moveq #0,d0
 move.b reR(a4),d0
 mulu  #213,d0
 lsr   #8, d0     soBeiPropSchrift mal213durch256 also ca90% des ÅblReRand
 addq.b #1,d0     aufrunde
 move.b d0,reR(a4)
okReRa:
 lsl   #1,d1
 moveq #7,d0  ob reRand Ñndern
 bsr   tx_r
 bmi   rec9
 move.b #107,reR(a4)
 bsr   snrer
 bra   _rRa
rec9:
 moveq #8,d0   wie reRandéndern?
 bsr   tx
 move.b reR(a4),d1
 bsr   dezout
 bsr   snrer
 moveq #23,d0
 bsr   tx_r
 beq   _rRa
 bmi   rec1
 bvs   rec2
 bra   rec9
rec1: addq.b #1,reR(a4)
 bcc rec9
rec2: subq.b #1,reR(a4)
 bgt rec9
 beq rec1
 bra rec9

_rRa:
 clr.b    d1
 move  d1,-(a7) s.o: info ob propSchrift in bit8_d0
 moveq #0, d1
 moveq #14,d0  BlocksatzP6?
 bsr   tx_r
 smi      BlS(a4) protokoll
 smi       d1
 lsl   #1, d1
 or   (a7)+,d1
 moveq #97,d0
 bsr   pES
 move  d1, d0
 lsr.b #6, d0   nun 3/0 in d0.b, zus mit escSeq: Blocksatz/linksbÅnd
 bsr   pr1
 
 moveq #15,d0  10odr12cpi?
 bsr   tx_r   gib mi,wenn 12cpi
 smi       d1
 lsl   #4, d1   nun bit12=prop&Blocksa bit11=12cpi
 moveq #16,d0  doppeltBreit?
 bsr   tx_r
 smi       d1
 and.b #1, d1
 rol   #5, d1     nun bit5=Breit bit1=prop bit0=12cpi
 move.b d1,sst(a4)
 moveq #17,d0     Schmalschrift draufstÅlp?
 bsr   tx_r
 smi       d1
 and   #4, d1
 or.b  d1,sst(a4) bit2
 moveq #18,d0     Schatten dazustÅlp?
 bsr   tx_r
 smi       d1
 and   #8, d1
 or.b  d1,sst(a4) bit3
 moveq #19,d0      (vert) Verfettung dazustÅlp?
 bsr   tx_r
 smi       d1
 and   #16,d1
 or.b  d1,sst(a4) bit4

 moveq #86,d0
 bsr   pE1
 moveq #20,d0  vert doppel?
 bsr   tx_r
 smi      d0
 lsr.b #7,d0
 bsr   pr1

 moveq #69,d0
 bsr   pE1
 moveq #21,d0  dreifachBreit?
 bsr   tx_r
 smi      d0
 lsr.b #7,d0
 lsl.b #1,d0  0(normal) oder 2(dreifachBreit)
 bsr   pr1

vor9:
 moveq #22,d0   zeilenabstandéndern?
 bsr   tx
 move.b vor(a4),d1
 bsr   dezout
 moveq #23,d0
 bsr   tx_r
 beq   anfng
 bmi   vor1
 bvs   vor2
 bra   vor9
vor1: addq.b #1,vor(a4)
 bpl vor9
vor2: subq.b #1,vor(a4)
 bcc vor9
 bra vor1

close:
* move hndl(a4),-(a7)
 move d4,-(a7)       in d4 handle-Nummer
 move #$3E,-(a7)
 trap #1
 addq #4,a7
 rts

readOK:
 bsr  close
 lea  LL(pc),   a0
 move.L a0,  AA(a4)
 lea -1(a0,d3.L),a0  d3=LÑnge des files (textes)
 move.L a0,EE(a4)   hier letztesByte des textes
 move.b #31,vor(a4) papierVorschub bei carRet
 clr.b    sst(a4)
 moveq #$80,d1
 move.b d1,sty(a4)  style zuAnfang $80=normal
anfng:
 move.b sst(a4),d1
 bsr    setstyl    so auch st_(a4) =d1.b

 moveq #12, d0   erklÑr steuernde Tasten
 bsr   tx
anfangn:
 bsr   rd1
 cmp.b #'1',d0
 seq     tut(a4)
 beq   anfangen
 cmp.b #'8',d0
 beq   specials
 cmp.b #'0',d0
 bne   anfangn
anfangen:
 move.L AA(a4),a0
 moveq  #24,  d2
anfloop:
 bsr   bisCR
 dbra  d2,  anfloop

 tst.b tut(a4)
 beq   pause
weiter:
 bsr   nxZeile
 bgt   das_wars   timeout(eq) fileEnd(gt) tut(a4)=0:newPage&pause
 move.L un_(a4),a0
 bsr   bisCR
 tst.b tut(a4)
 beq   pause
 tst.b tut+1(a4)
 beq   specials
 bsr   obtast
 beq   weiter
 cmp.b #'0',d0
 bne   weiter
 
pause:
 bsr   obtast
 beq   pause
 cmp.b #'1',d0
 beq   weiter
 cmp.b #'2',d0
 beq   alsoweg
 cmp.b #'8',d0
 beq   specials
 cmp.b #'9',d0
 bne   pause

das_wars:
 moveq #4,d0
das__wars:
 bsr   tx_rd
daswars:
 moveq #$2F,d4
N1nn:
 bsr   close
 tst.w d0
 dbpl  d4,N1nn
 clr.w -(a7)
 trap  #1

* also eine Zeile weglassen
alsoweg:
 move.L AA(a4),a0
wloo:
 cmp.L EE(a4),a0
 bgt   das_wars
 cmp.b #13,(a0)  dann carrRt (und sicher LinFeed dahinter)
 beq   wCR
 cmp.b #12,(a0)  formfeed
 beq   wpage
 cmp.b #$1F,(a0)
 beq   wformaLin
 cmp.b #11,(a0)
 beq   w1noc
 cmp.b #$1B,(a0)
 beq   wstyle
 addq #1,a0
 bra  wloo
wstyle:
 addq  #1,a0
 move.b (a0)+,sty(a4)
 bra   wloo
wformaLin:
 cmp.b #10,(a0)+  Laû solche Zeilen einfach weg
 bne  wformaLin
 bra  wloo
w1noc:
 addq #2,a0
 bra  wloo
wpage:
 pea  -1(a0)
 moveq #5,d0
 bsr   tx
wnewp:
 bsr   rd0
 cmp.b #'3',d0
 bne   wnewp
 move.L (a7)+,a0
wCR:
 addq  #2,a0
 move.L a0,AA(a4)
 move.L un_(a4),a0
 bsr    bisCR
 bra   pause

*subr setzt neuen rechten Rand  !d0 
snrer:
 moveq #81,d0
 bsr   pES
 move.b reR(a4),d0  so esc_sequenz setz rechtnRand
 bsr   pr1
rts

*subr gibt style_pakete an P6,protokollierts(1stwrdCODE) auf st_(a4)
setstyl:
 movem.L d0-d1,-(a7)
 move.b d1,st_(a4)
 moveq #33,d0  also 'ESC !'
 bsr  pES
 btst #3,d1
 sne     d0  Unterstr?
 lsl  #1,d0
 btst #2,d1
 sne     d0  kursiv?
 lsl  #1,d0
 sf      d0
 lsl  #1,d0  die Breitschrift des P6 hier noch OFF
 btst #0,d1
 sne     d0  fett?
 lsr  #7,d0
 lsl  #4,d0
*                bit7=untrstr b6=kursv b5=b3=b1=b0=0 b4=fett b2=schmal 
 or.b sst(a4),d0  evtl weitre bits (breit,schatt,schmal,proport,12cpi)
 bsr  pr1
*               nochmal ESCsequenz anfangen
 moveq #120,d0  code: es folgt 0=Draft/1=LettrQuality
 bsr  pES
 btst #1, d1  schwach_flag des 1stwordCode
 seq      d0
 lsr.b #7,d0
 bsr   pr1

 moveq #27,d0
 bsr   pr1     nochmal ESCsequenz anfangen
 moveq #$54,d0  code fÅr INDEXschrift AUSschalten
 or.b  #$C0,d1
 cmp.b #$CF,d1
 bls   oki
 moveq #$53,d0  code: index ON
 bsr   pr1
 btst  #5,d1  indexUNTEN?
 sne      d0
 lsr.b #7,d0
oki:
 bsr   pr1
movem.L (a7)+,d0-d1
rets:
RTS

iniP6:
 moveq #64,d0  initial P6
 bsr   pE1
 beq   rets
 bra   zeito9

pE1:
 move d0,-(a7)
 moveq #28,d0
 bra  p9
pES:
 move d0,-(a7)
 moveq #27,d0
p9: bsr pr1
 move (a7)+,d0

*subr gib einByte(d0) an printerPort, gib eq=timeout   !d0
pr1:
move.L a0,-(a7)
 move d0,-(a7)
 move #5,-(a7)
 trap #1
 addq #4,a7
 move d0,-(a7)
 bsr  zeitot
 move (a7)+,d0
move.L (a7)+,a0
 tst  d0
RTS

zeito9:
 bsr zeito8
 bsr zeito8
 bsr zeito8
 bra zeito2
zeito8: bsr zeito2
bra zeito2

*subr gib newline an printer  !d0
pnewline:
 moveq #$33,d0  papierTransport (um wieviel: nÑchByt) festleg
 bsr   pES
 move.b vor(a4),d0
 bsr   pr1

 moveq #13,d0
 bsr   pr1
 moveq #10,d0
 bsr   pr1
zeito2:
 moveq #-1,d0
 bsr   ztot
 bsr   ztot
 bsr   ztot
 bsr   ztot

*subr wartt,umZeichen anDrucker soschnell zu sendn,wie gedrucktwird !d0
zeitot:
 move #15999,d0
ztot: dbra d0,ztot
 rts

*subr gibt nÑchsteZeile an drucker,protok in AA(a4)    !a0d0d1
*  --- auch hier: formfeedByte als eine Zeile fÅrsich, aber ohne pnewline
* mach tut(a4).b zu 0, wenn Einstieg in neue Seite mit 0(=pause)
*     tut+1(a4).b zu 0, wenn Einstg mit 8. 
* gib eq=timeout,gt=endeFile
nxZeile:
 move.L AA(a4),a0
* nun guck, ob bisher Blocksatz, jetzt aber Abschnittsende.
 tst.b BlS(a4)  Blocksatz Åberhaupt eingeschaltet?
 beq   f_CR_
 bsr   a0CRLF   liefere BlE(a4)=FF, wenn nÑZeile mit Blank odr - endet
 moveq #97,d0
 bsr   pES
 move.b BlE(a4),d0  0 oder FF
 lsr.b #6,d0       zus mit escSeq: linksbÅnd=0 odr Blocksatz=3
 bsr   pr1
f_CR_:
 move.L AA(a4),a0
 move  #-1,  tut(a4)
 bsr    pisCR_
 movem.L a0,AA(a4)
 rts
pisCR_:
 cmp.L EE(a4),a0
 bgt   rpCR
 cmp.b #13,(a0)  dann carrRt (und sicher LinFeed dahinter)
 beq   fCR
 cmp.b #$1F,(a0)
 beq   formaLin
 cmp.b #11,(a0)
 beq   condPag
 cmp.b #$1B,(a0)
 beq   style
 cmp.b #12,(a0)  pagebrake
 beq   newpage
 cmp.b #$1E,(a0)  umzucodierende kleine asciiWerte?
 bls   umcokl
 moveq #6,  d0
 cmp.b #127,(a0)
 beq   ersetz
 cmp.b #$DE,(a0) ^
 beq   ersetz
 moveq #$E1,d0
 cmp.b #$9E,(a0) û
 beq   ersetz
 moveq #$15,d0
 cmp.b #$DD,(a0) ›
 beq   ersetz
 moveq #$EC,d0
 cmp.b #$DF,(a0)  oo
 beq   ersetz
 moveq #$E8,d0
 cmp.b #$EC,(a0)  Phi
 beq   ersetz
* moveq #$B3,d0   braucht nachUnten zuvielPlatz, zeilenabstandVerfÑlsch
* cmp.b #124,(a0)  |
* beq   ersetz
 moveq #126,d0
 cmp.b #-1,(a0)  ˇ
 beq   ersetz

 moveq #0,   d0
 move.b (a0)+,d0
opCR:
 move.b sty(a4),d1
 cmp.b st_(a4),d1
 beq   okpCR
 bsr   setstyl   dort auch auf st_(a4) protokolliert
okpCR: 
 bsr   EndBlank  gib eq=diesWarEinBlankAmEndeDerZeile
 beq   pisCR_
 bsr   pr1
 beq   toCR
 bra   pisCR_
formaLin:
 cmp.b #13,(a0)+  Laû solche Zeilen einfach weg
 bne  formaLin
 subq #1,a0
condPag:
 addq #2,a0
 bra  pisCR_
newpage:
 pea   1(a0)
 moveq #6,d0
 bsr   tx
newp:
 bsr   obtast
 beq   newp
 cmp.b #'0',d0
 sne       tut(a4)
 beq   zrnp
 cmp.b #'8',d0
 sne      tut+1(a4)
 beq   zrnp
 cmp.b #'3',d0
 bne   newp
zrnp:
 bra   f_CR
style:
 addq   #1,  a0
 move.b (a0)+,sty(a4)
 bra    pisCR_
ersetz:
 addq   #1,  a0
 bra    opCR
toCR:
 bsr    a0CRLF
 moveq  #0,  d0
 bra    rpCR    eq=timeout
umcokl:
 moveq  #0,  d0
 move.b (a0)+,d0
 move.b uc(pc,d0),d0
 bra    opCR
fCR:
 addq  #2,a0
 move.L a0,-(a7)
 bsr   pnewline
f_CR:
 move.L (a7)+,a0
 moveq #-1,d0    ne, not gt
rpCR:
 rts
uc:
dc.b 32,6,3,$AF,$AE,-2,124,4,$FB,32,32,32,32,32,4,5,48,49,50,51,52,53,54,55,56,57,32,32,32,32,32
.even

a0n2:
 addq #2,a0
*subr setz a0 hinter nÑchstes CarRet-LinFeed oder PageFeed oder TextEnd
* gib BlE(a4)=FF wenn hinten Blank(varSpace) oder -
a0CRLF:
 cmp.b #$1F,(a0)
 bne   a9n9
a8n8:
 cmp.b #10,(a0)+
 bne   a8n8
 bra   a0CRLF
a9n9:
 cmp.b #11, (a0)
 beq   a0n2
 cmp.b #$1B,(a0)
 beq   a0n2
 cmp.b #13,(a0)
 beq   ffC
 cmp.b #12,(a0)
 beq   fPC
 cmp.L EE(a4),a0
 bhs   ffC
 cmp.b #$1E,(a0)
 seq      BlE(a4)
 cmp.b #'-',(a0)+
 bne  a0CRLF
 seq      BlE(a4)
 bra  a0CRLF
fPC: addq #1,a0
 cmp.b   #13,(a0) danach CarRt?
 beq ffR
 bra a0CRLF
ffC: addq #1,a0
ffA: addq #1,a0
ffR: rts

*subr protokliert in reR(a4) LÑng dr erstnEchtTxtZeile(mit 1E endnd) ab a0
ZeiLang:
 clr.b        reR(a4)
 movem.L a0/d0,-(a7)
ZL: moveq #0, d0
ZLa:
 cmp.L EE(a4),a0
 bgt   o1
 cmp.b #13,(a0)  carrRt
 beq   fff
 cmp.b #$1F,(a0)
 beq   foff
 cmp.b #11,(a0)
 beq   f1f
 cmp.b #$1B,(a0)
 beq   f1f
 cmp.b #12,(a0)  pagebrake, davor MUSS doch was vernÅnftges gstandn habn
 beq   f2
addq #1,a0
addq #1,d0
 bra ZLa 
f1f: addq #2,a0
 bra ZLa
foff: bsr a0CRLF
 bra ZL
fff: addq #1,a0
f2: addq #1,a0
 tst d0
 beq ZLa
cmp.b reR(a4),d0
ble   nixpro
move.b d0,reR(a4) hier nur protokollier, wenn grîûer als bisher
nixpro:
 cmp.b #$1E,-2(a0)  pagebrake und vorher 1E?
 beq   ee2
 cmp.b #$1E,-3(a0)  Zeile endend mit typischem 1stword: 1E
 bne ZL
 subq #1,a0
ee2:subq #1,a0
eee:subq #1,a0
 cmp.b #32,(a0)  blank am schluû?
 bhi ok
 cmp.b #28,(a0)
 bcs ok
 subq #1, d0
ok:move.b d0,reR(a4)
o1: movem.L (a7)+,a0/d0
 rts

*gib eq und rR_(a4)=0, wenn d0=' ' am Ende einer Zeile. a0 muû nÑcByte zeign
EndBlank:
 st        rR_(a4)
 cmp.b #' ',d0
 bne   rEB
 movem.L a0/d0,-(a7)
wEB:
 move.b (a0)+,d0
 cmp.b  #13,d0
 beq    fEB
 cmp.b  #11,d0 condPage
 beq    fEB
 cmp.b  #12,d0 page
 beq    fEB
 cmp.b  #31,d0 formLine
 beq    fEB
 cmp.b  #27,d0 stylChange
 beq    EBsty
 cmp.b  #28,d0 space
 beq    wEB
 cmp.b  #29,d0 space
 beq    wEB
 cmp.b  #30,d0 space
 beq    wEB
 cmp.b  #32,d0 space
 beq    wEB
*                   also nicht ZeilenEnde
 moveq  #1, d0      deshalb ne
_EB:
 movem.L (a7)+,a0/d0
rEB: rts
EBsty:
 addq #1,a0
 bra  wEB
fEB: clr.b rR_(a4)  eq=blank am zeilenende
 bra _EB

*subr hol tastaturbytes, bis nix mehr da  eq= es war garnix da
obtast:
 bsr obtst
 beq robt
 move d0,-(a7)
ob1noc:
 bsr obtst
 beq r_obt
 move d0, (a7)
 bra  ob1noc
r_obt:
 move (a7)+,d0
 bne  robt
 moveq #-1,d0
robt: rts

*subr guck, ob tastatur betÑtigt, ja: byte in d0, nein: eq  !a0d0
obtst:
 move #11,-(a7)
 trap #1
 addq #2, a7
 move d0,-(a7)
 beq  nixda
 bsr  rd0
nixda:
 tst (a7)+ 
 rts

*subr holt einen ascii von tastatur  !a0d0
rd1:
 move #1,-(a7)  readTastaturWithEcho
 trap #1
 addq #2,a7
 RTS

*subr holt OHNE ECHO einen ascii von tastatur  !a0d0
rd0:
 move #8,-(a7)  readTastatur
 trap #1
 addq #2,a7
 RTS

*subr aufs tv txt ab a0 bis carrRtLF. a0 dann anfang neue Zeile  !a0d0
* protok in unz(a4) den Anfng der aktuellenUnterstenZeile
* in un_(a4) die nÑchste Zeile
*  gib gt wenn textfile zuende
bisCR:
 move.L a0,unz(a4)
 bsr    newline
 move.L unz(a4),a0
 bsr    bisCR_
 movem.L a0,un_(a4)
 RTS
bisCR_:
 cmp.L EE(a4),a0
 bgt   rtCR
 cmp.b #13,(a0)  dann carrRt (und sicher LinFeed dahinter)
 beq   fouCR
 cmp.b #$1F,(a0)
 beq   formatLin
 cmp.b #11,(a0)
 beq   folgt1
 cmp.b #$1B,(a0)
 beq   folgt1
 cmp.b #12,(a0)
 beq   foupage
 cmp.b #$1C,(a0)
 beq   blank_
 cmp.b #$1D,(a0)
 beq   blank_
 cmp.b #$1E,(a0)
 beq   blank_

 moveq #0,   d0
 move.b (a0)+,d0
vorCR:
 bsr    tv1
 bra    bisCR_
blank_:
 addq #1, a0
 moveq #32,d0
 bra  vorCR
formatLin:
 cmp.b #13,(a0)+  Laû solche Zeilen einfach weg
 bne  formatLin
 subq #1, a0
folgt1:
 addq #2, a0
 bra  bisCR_
foupage:
 pea 1(a0)
 moveq #78,d1
marpage:
 moveq #-1,d0  '_'
 bsr   tv1
 dbra d1, marpage
 move.L (a7)+,a0
 moveq  #0, d0   setz eq
 bra   rtCR
fouCR:
 addq #2,a0
rtCR:
 RTS
 
*subr gibt einen character (d0) stetsDruckbar aufs tv
tv1:
 movem.L a0-a3/d0-d3,-(a7)
 move    d0,        -(a7)
 move.L  #$30005,   -(a7)  ausgabe nur druckend auf tv
 trap    #13
 addq    #6,    a7
 movem.L (a7)+, a0-a3/d0-d3
RTS

*subr gibt d1.b als drei dezZiffern aufs tv     !d0d1
dezout:
 moveq #47,d0  vor'0'
hdzo:
 addq  #1,  d0
 sub.b #100,d1
 bcc   hdzo
 add.b #100,d1
 bsr   tv1
 moveq #47,d0  vor'0'
zdzo:
 addq  #1, d0
 sub.b #10,d1
 bcc   zdzo
 add.b #10,d1
 bsr   tv1
 moveq #48,d0  '0'
edzo:
 or.b  d1,d0
 bsr   tv1
rts

*subr ruft tx und obtast bis TastaturAntwort da !a0a1d0
* gib mi=Taste1 ov=Taste2 eq=0
tx_r:
 bsr tx
not_
 bsr obtast
 beq not_
 cmp.b #'1',d0
 beq   fou1
 cmp.b #'2',d0
 beq   fou2
 cmp.b #'0',d0
 beq   fou0
 move  #0, ccr
 rts
fou1: move #8,ccr
 rts
fou2: move #2,ccr
 rts
fou0: move #4,ccr
 rts


*subr ruft tx und rd     !a0a1d0
tx_rd:
 bsr tx

*subr gib a0=a4+ttr, ab hier tastaturEinles  !a0a1d0
rd:
 bsr newline
 lea ttr(a4),a1  ab hier tastatur einles
 bra no1rd
de1rd:
 cmp.b #8,d0  BACKSPACE?
 bne   n1rd
 lea  mxt(a4),a0
 cmp.L a0,   a1  ganz hintn im EinlesBuffr(cc)?
 bcs  ok1li
 bsr  cu1re     vom sys ist cursor bereits 1links gestellt, hintn nichtsinnvoll
ok1li:
 bsr  blank
 bsr  cu1li
 lea ttr(a4),a0
 cmp.L a1,  a0   ganz vorn im EinlesBuffer?
 bcc  no1rd
 bra  cl1rd
n1rd:
 lea  mxt(a4),a0  ab hier dÅrfen KEINE zeichen mehr hin
 cmp.L a0,   a1
 bcs  noc1rd
 subq #1,    a1
noc1rd:
 move.b d0, (a1)+
 beq   cl1rd      asciis=0 nicht registrieren
 lea  mxt(a4),a0  ab hier dÅrfen KEINE zeichen mehr hin
 cmp.L a0,   a1
 bcs   no1rd
 bsr   cu1li
 bra   no1rd
cl1rd:
 subq #1,  a1
no1rd:
 bsr  rd1
 cmp  #13,d0    carrRt?
 bne  de1rd
 clr.b       (a1)
 lea  ttr(a4),a0
 RTS

blank:
moveq #1,d0
bra   tx

cu1li:
moveq #2,d0
bra   tx

cu1re:
moveq #3,d0
bra   tx

newline:
moveq #0,d0

*subr sucht ab "dat:" nach sovielNullen,wie d0 angibt.TXTabDORTauf tv !a0d0
tx:
 lea dat(pc),a0
tsx: tst.b (a0)+
 bne  tsx
 dbra d0, tsx
tx_:
 pea  (a0)
 move #9,-(a7)
 trap #1
 addq #6, a7
 RTS
dat:
dc.b 0
dc.b 10,13,0
dc.b ' ',0
dc.b 27,68,0
dc.b 27,67,0
dc.b 13,10,10,27,112,'Return',27,113,27,102,0
dc.b 27,106,27,89,32,32,27,112,' neue Seite, weiter mit 3 ',27,113,27,107,0
dc.b 27,106,27,89,32,32,27,112,'neueSeite, weiterdruck3 pause0 specials8',27,113,27,107,0
dc.b 'eine RechteRandGrenze setz? ja=1',13,10,0
dc.b 'rechtrRand gsetz auf char ',0
dc.b 'proprtionSchrift einschalt? ja=1',13,10,0
dc.b 27,119,27,69,'file auf P6 ausdrucken: ',27,101,0  *10
dc.b 10,10,13,'## flopFEHLER ##',0
dc.b 10,10,10,10,13,'nun tippe',13,10,10,10
dc.b '0 gleich Pause machen  1 drucken',13,10
dc.b 'jederzeit mit 0 wieder Pause',13,10,10
dc.b 'in Pause: 1weiterdruck  2ZeileWeglassn  9abbrech 8specials',0
dc.b 27,69,'beachte: DRUCKER REAGIERT NICHT!',0
dc.b 'P6Methode des Blocksatz? ja=1',13,10,0
dc.b 'BuchstabGrundGrîû Ñndrn? ja=1(12cpi) 0=normal=10cpi',13,10,0
dc.b 'davonausgehnd vrbreitrn? ja=1',13,10,0
dc.b 'Schmalschrft draufstÅlp? ja=1',13,10,0
dc.b 'horizontl leicht dicker? ja=1',13,10,0
dc.b 'vertik etwas dck(=fett)? ja=1',13,10,0
dc.b 'Buchstbenhîhe verdoppln? ja=1',13,10,0    *20
dc.b 'auf dreifach verbreitrn? ja=1',13,10,0
dc.b 'aktuellZeilnAbstnd(180telZoll)',0
dc.b 13,10,'1=grîûr 0=OK 2=kleinr',13,10,0
dc.b 27,69,'Nun kann einiges eingstellt werden:',13,10,10
dc.b 'direktTip von AtariTastatur ja=1',13,10,0
dc.b 10,'CONTa=beend backs=1lîsch CONTb=1zrÅck',13,10,'nun text:',13,10,10,0

.even
LL: dc.w 0
.end

