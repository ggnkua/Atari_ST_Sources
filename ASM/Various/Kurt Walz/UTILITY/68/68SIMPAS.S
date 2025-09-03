* dieser einfachst-Assembler will ein file namens "P.S" einlesen und dazu
*  das (lauffÑhige) File "PP.TOS" erzeugen. Ein paar EinschrÑnkungen sind
*    (Stand: July 89) zu beachten, z.B: eine Grîûenkontrolle der Operanden
*    findet (noch) nicht statt/ es sollten nur voll-relocierbare Programme
*    geschrieben werden, denn ein Anhang fÅr den Linker wird nicht erzeugt!
*
* um file "PP.TOS" wirklich abzuspeichern: tippe  ':'  gleich nach start.
*jed andre Taste verzichtt aufsSpeichrn.Dann tip  '.'  um abzubrechen,
* jede andre (zweite) Taste fÅhrt zur Ausgabe des codes und der Symbol-
* Tabelle auf dem Bildschirm.


LKN: EQU 9  *Kennung eines (noch zu berechnenden) Longwords,
WKN: EQU 7  ..words oder
BKN: EQU 13  ..bytes, das im instr-stream bisher nur nen Platzhalter hat.
LKD: EQU $19
WKD: EQU $17
BKD: EQU $13  * wie oben, aber zusÑtz Kenng, daû es 'DC.x' war

* Adr-Offsets, via xx(A3) verwendet:
QAN: EQU 72
QEN: EQU 76
QAK: EQU 80
AZE: EQU 84
S00: EQU 88
SP0: EQU 92
AKS: EQU 96
L00: EQU 100
LPC: EQU 104
WERT: EQU 108
OREL: EQU 112

LEA  (A7),A0  so hat dies Prorgamm den sp gekriegt
SUBA #224,A7
LEA  (A7),A3  soviel RAM abzwacken fÅr xx(A3)-Zwecke.

MOVEQ #3,D0
ROR.L #2,D0
CLR.L    -(A7)
CLR.L    -(A7)
CLR.L    -(A7)
MOVE.L D0,-(A7)
MOVE.L D0,-(A7)  "Prellbîcke", damit ich spÑter -beim stackDurchsuchen-
MOVE.L D0,-(A7)  bemerke, wenn ich Åbern stack rausgeraten bin.

MOVE.L A7,SP0(A3) oberes Ende des (durchsuchbaren) stackbereichs.
MOVE.L A7,AKS(A3) derzeit noch gleich dem unteren Ende. (AKtuellerStack)
MOVE.L A0,S00(A3) ursprÅnglicher sp.
 CLR.L    LPC(A3) virtueller pc des herzustellenden lauffÑhigen files.
 CLR.L    AZE(A3) zÑhlt die Zeilen im Quelltext.
 LEA  TE(PC),A0
MOVE.L A0,QAN(A3) Quelltext-Anfang
MOVE.L A0,QAK(A3) Aktuelle Stelle im Quelltext.
CLR.L    (A0)+
MOVE.L A0,QEN(A3) Quelltext-Ende


***********************************
* dies filezeug: nur vorlÑufig!:
READ:
 LEA -88(A7),A7
 LEA  (A7),  A4
 move.L #$502E5300,(A4) 'P.S'
 MOVE  #2, -(A7) *verwende les/schreibdateien
 MOVE.L A4,-(A7) *name
 MOVE  #$3D,-(A7) *open
 TRAP  #1
 ADDQ  #8, A7
 MOVE  D0, D5 *code, evtl Fehlercode, sonst handleNr
 MOVE  D5, D7
 BMI   OPERR
 MOVE.L QAN(A3),-(A7) start
 LEA    -5678(A7), A0
 SUB.L  (A7),A0
 MOVE.L A0,-(A7)  LÑnge
 MOVE  D5, -(A7) *handle
 MOVE  #$3F,-(A7) *read
 TRAP  #1
 ADDA.W #12, A7
 MOVE.L D0,  D7 *TATSéCHLICHE LéNGE
 BSR   CLOSE
BACKREAD:
 LEA  88(A7),A7
 MOVE.L D7, D0
 bra BEGINN

CLOSE:
 MOVE.W D5,-(A7)  *handle
 MOVE.W #$3E,-(A7) *close
 TRAP   #1
 ADDQ.L #4, A7
RTS

OPERR:
CRERR:
 bsr newline
 move d7,d0
 bsr wout
 bra vorEnde

BEGINN:
 add.L QAN(a3),d0
 move.L d0,  QEN(a3)

* bis hier nur sehr vorlÑufig !!
*********


 MOVE.L QEN(A3),A0
 MOVEQ #35,D0
JAJA00:
 CLR.B   (A0)+
 DBRA D0,JAJA00
MOVE.L A0,D0
AND.B  #-2,D0
MOVE.L D0,A0      gradzahlige Adresse
 CLR.B   (A0)
MOVE.L A0,L00(A3) ab hier soll LauffÑhiger code hin.

MOVE.L QAK(A3),A0
 BRA  SO0REIN


NIXWARS1:
NIXWARS2:
NIXWARS3:
***|| spÑter mehr Fehlermeld.
 moveq #-3,d1
 bsr  ERRMELD
*** vorerst fÅnf nops einbau, wenn instru ungeklÑrt.
 move #$4E71,D2
 bsr CODEREIN
 bsr CODEREIN
 bsr CODEREIN
 bsr CODEREIN
 bsr CODEREIN

GONXZEI:
 BSR  SUCHLFEE  sucht LineFeed, gibt hs, wenn bis TextEnde keins gefundn.
 BHS  QZUENDE
 BSR  STPLATZ  ob noch stackplatz? not=hs (kann zurNot entfallen)
 BLO  SO0REIN
***
 bsr newline
move.L #'few ',D0
move.L #'RAM!',D1
 bsr ASC4OU
 bra vorEnde

SO0REIN:
 ADDQ.L #1,AZE(A3)
SOREIN:
 BSR  IGNOSOME  ignorier Blnk,Tab. '.even' selber mach. Dann (und <'0'): mi
 BMI  GONXZEI
MOVE.L A0,QAK(A3)
 BSR  DCLABINS  meld obs 'DC.x' odr 'SYMBNAME:' oder 68000INSTRUCTION ist.
 BPL  ISTLAIN   mi= ist DC.x, dann a0 zeigHinter DC.x, d3.w=pl,d3.B=-1/0/1
NOCMDC:
 BSR  WORKDC    Term berechne und in instrStream einfÅge, sonst gib d0d1&ne
 BEQ  OBNOCMDC  ne= Berechnung noch nicht mîglich, deshalb bemÅhe stack:
 MOVE.L D0,-(A7)
 MOVE.L D1,-(A7)
 MOVE.L A7,AKS(A3)
OBNOCMDC:
 MOVE D3, D3     Kennzeichen, daû alles innerhalb Hochkommas?
 BMI  NOCMDC
 CMP.B #',',(A0)+ folgt dem Term ein Komma? Dann gibts noch mehr Terme.
 BEQ  NOCMDC
 BRA  GONXZEI
ISTLAIN:
 BNE  ISTINSTR  ne= muû wohl 68000-instruction sein. eq= ist ein 'LABEL:'
 MOVE.L D1,-(A7)     merk auf stack, daû D1 zeigend symbolDef
 MOVE.L LPC(A3),-(A7) und deren Wert (der nur stimmt, wenns ein Label war!)
 MOVE.L A7, AKS(A3)  merk auch die Adr diesesEintrags (weil evt zu korrig.)
 BSR   LABOWAS      nachprÅfen,obs equ ist, auch ob redefined. equ: korrig!
 BPL  NOREDEF      mi= redefined symbol
******|| spÑtermal mehr Meldung.
 moveq #-2,d1
 bsr ERRMELD

NOREDEF:
 LEA (A1),A0   a1 hintern ':' zeigend (LABEL) oder hintern Term (EQU).
 BRA SOREIN

ISTINSTR:
 LEA (A0),A1    merk instruction-Anfang
 BSR ENKEY
 BNE NIXWARS1
 CMP.W NACHLZCO-8(PC),D3 verschlÅsselung zu groû?
 BHI NIXWARS2
 MOVEQ #$DF,D0
 AND.B 2(A1),D0 merk dritten ascii der instruction
 LEA ICODTAB(PC),A1
 CMP #$169,D3   wars instruction CLR bzw BLS?
 BHI GUCK9A9
 BLO SUCH0ICO
 LEA WGCLR(PC),A1  es war CLR oder BLS.
 CMP.B #'R',D0    CLR?
 BEQ EINZEL
 LEA WGBLS(PC),A1  dann also BLS
 BRA EINZEL
GUCK9A9:
 LEA WG9A9(PC),A1
 CMP #$9A9,D3   wars RTR oder RTS?
 BHI SUCH0ICO   keines von beiden, sondern spÑter im Alphabet
 LEA WG169(PC),A1
 BLO SUCH0ICO   bzw hier: frÅher im Alphabet.
 LEA WGRTR(PC),A1
 CMP.B #'R',D0  Wars nun RTR?
 BEQ EINZEL
 LEA WGRTS(PC),A1  dann wars also RTS.
 BRA EINZEL

SUCH0ICO:
 SUBQ #8, A1
SUCHICO:
 ADDQ #8, A1
 CMP  (A1),D3
 BHI  SUCHICO
 BNE  NIXWARS3
EINZEL:

* 5(a1).B sagt: 0 oder 4 oder 7 = jede extension erlaubt.
* 1=nurByte 2=nurWord 3=nurLong.
*   D3_hiWord sagt, was im Text steht: 0=keineAngabe, 1=byte 2=word 3=Long.
 MOVE.L D3,D0
 SWAP     D0
 MOVE  D0,D0
 BEQ   EXTEOK
 MOVE.B 5(A1),D1
 BEQ   EXTEOK   weil alle extensions erlaubt
 CMP.B #4,D1
 BEQ   EXTEOK   weil alle extensions erlaubt
 CMP.B #7,D1
 BEQ   EXTEOK   weil extension ignoriert
 CMP.B D0,D1
 BNE   SUCHICO  weil unzulÑssige extension

EXTEOK:
 MOVE.L A1,-(A7)
 MOVE  6(A1),D0  adrOffset,der zu einer operandenprÅfenden INNR SUBR fÅhrt.
 LEA   T(PC),A1
 JSR   0(A1,D0)
 MOVE.L (A7)+,A1
 BMI   SUCHICO
 OR.W  2(A1),D2  dies ist nun der instrCode, inclusive effAdr-feld,
* allerdings fehlt noch die Extension, auch immed-Werte (die in den Code
* direkt reinverschlÅsselt werden) fehlen.
* D0.w sagt, ob sowas Åberhaupt anliegt, siehe "INNER SOUBROUTINES".
* aus d0.B und dem HiByt_d0.w ist auch ersichtlich, ob auf den instr-Code
* weitere words folgen werden (offsets oder Daten oder...).
*   nun aber erstmal die extension verschlÅsseln. Falls 5(A1)=1or2or3or7:
*   codierung ist im iCode enthalten. ansonsten kanns nur 0 oder 4 sein:
 TST.B 5(A1)
 BEQ   ITS76   also wird der Wunsch aus d3-hiWord in bit_7_6 (D2) codiert,
 CMP.B #4,5(A1) ...bzw in bit_13_12 reincodiert.
 BNE   OKEXTBIT in allen andern FÑllen ist codierung bereits drin.
 OR  #$3000,D2  setz bits, als wÑre es word-extension
 BTST #16,D3   eq=word
 BEQ  OKEXTBIT
 AND #$DFFF,D2 setz auf byte-ext.
 BTST #17,D3   eq=byte
 BEQ  OKEXT_P
 EOR #$3000,D2 setz auf Long-ext.
 BRA  OKEXTBIT
ITS76:
 OR  #$40,D2  setz bits, als wÑre es word-extension
 BTST #16,D3   eq=word
 BEQ  OKEXTBIT
 AND.B #$3F,D2 setz auf byte-ext.
 BTST #17,D3   eq=byte
 BEQ  OKEXT_P
 OR  #$80,D2 setz auf Long-ext.
 BRA OKEXTBIT
VOKEXB:
 ADDQ #2,A7
 BRA OKEXTBIT
OKEXT_P:
* bei byte-extension uU noch prÅfe, ob adrReg-direkt im effadr-feld!
 MOVE.W #$F080,-(A7) um herauszumaskieren,ob ADD,CMP,SUB,MOVE
 CMP.W #$1000,(A7)
 BLO  VOKEXB
 CMP.W #$D000,(A7)  add..?
 BEQ  OKMUSS
 CMP.W #$B000,(A7)  cmp..?
 BEQ  OKMUSS
 CMP.W #$9000,(A7)  sub..?
 BEQ  OKMUSS
 CMP.W #$3080,(A7)  move..?
 BHI  VOKEXB
OKMUSS:
 MOVE.W #$38,(A7)
 AND.W  D2, (A7)  somit nur diemodusBits des effadr-felds geblieben
 CMP.W  #8, (A7)  eq= adrReg-direkt
 ADDQ.W #2,  A7
 BEQ   SUCHICO   weil hier keine byteExt zulÑssig!

OKEXTBIT:
 BSR  CODEREIN  schreibt D2.w in den instr-stream rein
 BSR  OBMULTI   gib rol#8,d0  und erledig RegListe, falls diese verlangt.
 MOVE.W D0,-(A7)
 BSR  WASFOLGT  gibt ne,wenn noch was zu berechnen ist
 MOVEM.W (A7)+,D0
 BEQ  OKWFO
 MOVE.L D2,-(A7)
 MOVE.L D1,-(A7)
 MOVE.L A7,AKS(A3)
OKWFO:
 ROL.W #8,D0
 BSR  ZU2O
 BSR  WASFOLGT
 BEQ  OKWFO2
 MOVE.L D2,-(A7)
 MOVE.L D1,-(A7)
 MOVE.L A7,AKS(A3)
OKWFO2:
 BRA  GONXZEI

QZUENDE:
* das "LauffÑhige file" steht jetzt einigermaûen, in der symbol-Tabelle
* sind aber noch ein paar Stellen vermerkt, die wir noch abklappern mÅssn:

 MOVEQ  #3, D0
 ROR.L  #2, D0
 MOVE.L D0,-(A7)
 MOVE.L D0,-(A7)  Prellbîcke unterhalb der symbolTabl. AKS(A3) zeigt drÅber!
 MOVE.L D0,-(A7)

* im folgenden wird die symbol-Tabelle nochmals durchgegangen, um
* nun alle Werte zu berechnen (und evt in LauffÑ.File einzufÅgen), die
* bisher als 'noch-nicht-berechenbar' markiert waren.

MOVE.L SP0(A3),A2 zeig Åbern obersten Eintrag in SymbolTabelle
 ADDQ  #4, A2
WEI9INTA:
NOC9INTA:
 SUBQ  #8, A2
 TST.B (A2)
 BPL   NOC9INTA    mi= noch kein Wert zugewiesen, also jetzt berechnen!
 CMP.L AKS(A3),A2   wenn allerdings untresTabellenende erreicht: aufhîrn.
 BLO   G9OK
 MOVEQ #-1,D1
 LSR.L #3, D1    so d2.L=#$1FffFFff
 AND.L (A2),D1    offset pur.
 ADD.L QAN(A3),D1  Adr des ersten byte der Namensdef dazu: zeig name.
 MOVE.L D1,A0
 BTST  #6,(A2)
 BEQ   AUCHEIN  ne= es war symbDef, also Wert nur in der Tabelle eintragen.
 MOVEQ #$3A,D0  ':' suchen
NOC9DO:
 CMP.B (A0)+,D0
 BNE  NOC9DO
 BSR  AUSWERTE
 TST.B D2
 BEQ  OK9
****||  spÑter hier Abfrage, obs Åberhaupt berechenbar war... evt mehrMelde
 moveq #-17,d1
 BSR ERRMELD
OK9:
 BCLR  #7, (A2)
 MOVE.L D1,-4(A2)
 BRA   WEI9INTA
AUCHEIN:
 BSR  AUSWEREL  hier: nimm uU jmpLabels relativ zum aktuellen pc!
 TST.B D2
 BEQ  OK9AU9
****||  hier spÑtermal ausfÅhrliche Fehlermeldung
moveq #-19,D1
  BSR  ERRMELD
OK9AU9:
* nun in D1 eine Zahl, die in den instrStream rein muû. wo genau:
 MOVE.L -4(A2),D0
 ROL.L  #8,  D0   dies d0.B gibt Auskunft Åber die Stelle im instrStream:
* 1=Typus x(A,R)  2=xx(A)  3=x(pc,R)  4=xx(PC)-
* 5=relBRANCHtyp,wobei statt des words iCodBits verwendbar,wenn -$80<lab<$7F.
* 6=relBRANCH-Typ.w  7=word  8=#wert.w ohne Kontrolle
* 10=absAdr.L,wobei iCodeBit0 lîschbar,um doch absAdr.w zu verwenden.
* 9=#wert.L
* 11 #wert 0..15 unten in instrCodeBits einzufÅgen
* 12 #wert 1..8 in instrCode bits _11_10_9 einzufÅgen
* 13 #wert -$80..$FF, der ins untre instrCodeByte einzufÅg.

 MOVE.L D0,D2
 LSR.L  #8,D2  virtuelle Adr im LauffÑhigen file,
 MOVE.L D2,A1
 ADD.L L00(A3),A1  reale Adresse.
 CMP.B #13,D0
 BEQ   AUBYREI
 CMP.B #12,D0
 BEQ   AUBI119
 CMP.B #11,D0
 BEQ   AUBI30
 CMP.B #9,D0
 BHS   AULOREI
 CMP.B #7,D0
 BHS   AUWOREI
 CMP.B #4,D0
 BHS   AURBREI
 CMP.B #3,D0
 BEQ   AUPCREG
 CMP.B #2,D0
 BEQ   AUAREL
* also #1, also x(A,R)-Typ. a0 zeigt '('

U9U9:
AUPCREG:
 MOVE.B D1,1(A1)
 BSR   ZWTREG   gibt in D1_7_6_5_4 die RegNr des zweitnReg. _3=1 wenn Long.
 BVS   AUXAROK
*****|| spÑtermal mehrFehlermelde wenn VC
 moveq #-21,d1
 bsr  ERRMELD
AUXAROK:
 MOVE.B D1,(A1)
 BRA   WEI9INT
AUBYREI:
 MOVE.B D1,(A1)
WEI9INT:
 BRA   WEI9INTA
AUBI30:
 AND  #15,D1
 OR.B D1,(A1)
 BRA  WEI9INT
AUBI119:
 AND #7,D1
 ADD D1,D1
 OR.B D1,-(A1)
 BRA WEI9INT
AULOREI:
 BSR DCR1B4  schreib die vier D1_bytes auf (A1)+
 BRA WEI9INT
AURBREI:
AUWOREI:
AUAREL:
 BSR CDR1
 BRA WEI9INT

G9OK: BRA ABSCHLUS



ZWTREG:
*subroutine will a0 zeigend hinter eine Klammer_auf, die zum x(A,R) oder
* x(pc,R)-Typus gehîrt. gibt in d1_7_6_5_4 die regNr.
*     gib flag vs, wenn OK.  stets d0= voriges a0
 MOVE.L A0,-(A7)
ZWTLOO:
 CMP.B #',',(A0)+
 BNE ZWTLOO
 BSR PRUEFD
 BVS PLISS
 BSR PRUEFA
 BVC RPLISS
 ADDQ #8,D1
PLISS:
 LSL #4,D1
 CMP.B #'.',0(A0,D0)
 BNE RRRPLIS
 CMP.B #'L',1(A0,D0)
 BEQ LLLPLIS
 CMP.B #'l',1(A0,D0)
 BNE RRRPLIS
LLLPLIS:
 BSET #3,D1  dies bit setzen, wenn das zweite Register "LONG" zu nehmen.
RRRPLIS:
 MOVE #2,CCR  vs
RPLISS:
 MOVEM.L (A7)+,D0
 RTS

ZU2O:
*subroutine stellt a0 (das bisher auf 1stOp zeigt) auf zweitn Operandn.
ZU2OLOO:
 MOVE.B (A0)+,D1
 CMP.B #$27,D1   Hochkomma? dann weiterstell zum zweiten Hochkomma.
 BNE   Z2ONHK
 BSR   TOHKE     gib eq wenn Zeilenende
 BEQ   OOZU1O
Z2ONHK:
 CMP.B #'(',D1
 BNE   Z2ONKA
 BSR   TOKZU
 BEQ   OOZU1O
Z2ONKA:
 CMP.B #' ',D1
 BLO  OOZU1O
 CMP.B #',',D1  erstmal Komma suchen.
 BNE  ZU2OLOO
EVTZU1O:
 CMP.B #' ',(A0)+  und nun Blanks und Tabs Åbergehen.
 BEQ  EVTZU1O
 CMP.B #9,-1(A0)
 BEQ  EVTZU1O
OOZU1O:
 SUBQ #1,A0
 RTS

TOHKE:
*subroutine sucht das nÑchste Hochkomma  gib eq wenn stattdessen Zeilenende
 MOVEQ #$27,D2
 BRA   TOKZUL

TOKZU:
*subroutine sucht nÑc Klammer_zu  gib eq wenn stattdessen Zeilenende
 MOVEQ #$29,D2 ')'
TOKZUL:
 MOVE.B (A0)+,D1
 CMP.B #13, D1
 BEQ   ZTOKZU
 CMP.B D2,D1
 BNE   TOKZUL
 MOVE.B (A0)+,D1  hier stets ne. nÑc Byte gleich geladen
ZTOKZU:
 RTS

CODEREIN:
*subroutine
 MOVE.L L00(A3),A1
 ADD.L LPC(A3),A1  zeig,wo nÑchstes codeWord hinsoll
 ADDQ.L #2,LPC(A3)
CDR:
 ROL.W  #8,  D2
 MOVE.B D2, (A1)+  und da kommt es schon.
 ROL.W  #8,  D2
 MOVE.B D2,  (A1)+
RTS

OBMULTI:
*subroutine erkennt aus d0.B oder d0_hiByte, ob Registerliste folgen muû.
 CMP.B #15,D0
 BNE  NOBMUI
 BSR  RGLIRAN
NOBMUI:
 ROL.W #8,D0
 CMP.B #15,D0
 BNE  RROBM
 BSR  RGLIRAN
RROBM:
 RTS
RGLIRAN:
 CLR.B  D0
CODEREI1:
 MOVE.L L00(A3),A1
 ADD.L LPC(A3),A1  zeig,wo Word hinsoll
 ADDQ.L #2,LPC(A3)
CDR1:
 ROL.W  #8, D1
 MOVE.B D1,(A1)+  und da kommt es schon.
 ROL.W  #8, D1
 MOVE.B D1,(A1)+
RTS

WASFOLGT:
*subroutine, erkennt aus d0.B, ob Zahlen direkt folgen mÅssen:
* 0= keine Zahlenwerte aus diesem Op.
* 1= der Op erfordert, daû ein word des Typus x(A,R) anhÑngt.
* 2= Op will, daû ein word des Typus xx(A) anhÑngt
* 3= daû word des Typs x(pc,R) folgt
* 4= daû word des xx(PC)-Typs anhÑngen muû.
* 5= daû word des LABEL-Typs ahÑngt, wobei statt des words auch das untre
*         Byte des iCodes selbst verwendet werden darf,wenn -$80<lab<$7F.
* 6= daû word des LABEL-Typs anhÑngen muû.
* 7= es muû word folgen
* 8 daû #wert.w folgt ohne Kontrolle, ob angegebne Zahl grîûer als 16bit.
* 10= will, daû absAdr.L folgt, wobei im effAdrFeld bit0 gelîscht werden
*         darf, um doch shortAdr (also absAdr.w) zu verwenden.
* 9 daû #wert.BWL folgen muû, abhÑngig von der instruction-Extension
* 11 daû #wert 0..15 unten in instrCode einzufÅgen
* 12 daû #wert 1..8 in instrCode bits _11_10_9 einzufÅgen
* 13 daû #wert -$80..$FF folgn muû, der ins untre instrCodeByte einzufÅg.
*
* obige Kennungen werden weitgehend Åbernommen ins highestByte des
* Longwords eines Eintrags in die symbol-Tabelle (=labelTabelle).
* Ausnahme: 9 bedeutet jetzt: es folgt #wert.L (vgl "LKN" und "LKD")
*
 TST.B D0
 BEQ   OK1OP0
 CMP.B #9,D0
 BLO  AHA1O8
 BHI  OB1O11  eq= kennung9= es kommt auf die extension an!
 MOVE.L A0,D2
 SUB.L QAN(A3),D2
 BSET  #31,  D2    spÑter auf stack, weil hier noch was zu berechnen ist,
 MOVE.L LPC(A3),A1 und die Stelle, wo es (im LauffÑhg.file) hinsoll.
 MOVE.L A1, -(A7)
 ADD.L  L00(A3),A1
 CLR.B      (A1)
 MOVE.B #WKN,(A7)
 ADDQ.L #2, LPC(A3)
*   D3_hiWord sagt, was im Text steht: 0=keineAngabe, 1=byte 2=word 3=Long.
 BTST #16, D3  eq= es war word-ext. ne= byte ODER Long!
 BEQ  OK1OOPP
* falls byte-ext: ebenfalls 16bit im instrStream! aber UNTERE 8bit relevant!
 ADDQ.L #1, (A7)
 MOVE.B #BKN,(A7)
 BTST #17, D3
 BEQ  OK1OOPP
 SUBQ.L #1, (A7)
 MOVE.B #LKN,(A7)
 ADDQ.L #2, LPC(A3) somit insgesamt 32 bit freigehalten.
 BRA  OK1OOPP

OB1O11:
 CMP.B #11,D0
 BLO  L1OPN
*  also Kennung >= 11, also in instrCode einzufÅgen
 MOVE.L A0,D2
 SUB.L QAN(A3),D2
 BSET  #31,  D2      spÑter auf stack, weil hier noch was zu berechnen ist,
 MOVE.L LPC(A3),-(A7) und die Stelle, wo es (im LauffÑhg.file) hinsoll.
 SUBQ.L #1,(A7)      so spÑter zeigend lowByte des instrWords!
 MOVE.B D0,(A7)      hier Kennungen 11 odr 12 odr 13
 BRA   OK1OOPP

L1OPN:
 MOVE.L A0,D2
 SUB.L QAN(A3),D2
 BSET  #31,  D2      spÑter auf stack, weil hier noch was zu berechnen ist,
 MOVE.L LPC(A3),-(A7) und die Stelle, wo es (im LauffÑhg.file) hinsoll.
 MOVE.B D0,(A7)      hier 10 als Kennung von absAdr.L
 ADDQ.L #4,LPC(A3)
 BRA   OK1OOPP

AHA1O8:
 MOVE.L A0, D2
 SUB.L QAN(A3),D2
 BSET  #31,  D2      nachher auf stack: hier ist noch was zu berechnen,
 MOVE.L LPC(A3),-(A7) und die Stelle, wo es (im lauffÑhg.file) hinsoll,merk
 MOVE.B D0,(A7)     und merk, welche Art von word dies werden wird.
 ADDQ.L #2,LPC(A3)  weil Platz fÅr word freizuhalten.
OK1OOPP:
 MOVE.L (A7)+,D1
OK1OPN:
 MOVEQ #1,D0  ne= es ist noch was zu berechnen
 RTS
OK1OP0:
 MOVEQ #0,D0
 RTS



ABSCHLUS:

****

move #1,-(a7)
trap #1
cmp.b #':',d0
bne NOWRITE
WRITE:
 LEA  -88(A7),A7
 LEA  (A7),  A4
 MOVE.L #$50502E54,(A4)
 MOVE.L #$4F530000,4(A4) 'PP.TOS'
 MOVE  #0, -(A7)        *verwende les/schreibdateien
 MOVE.L A4,-(A7)  *name
 MOVE  #$3C,-(A7) *create
 TRAP  #1
 ADDQ  #8, A7
 MOVE  D0, D5 *code, evtl Fehlercode, sonst handleNr
 MOVE  D5, D7
 BPL   CREOK
* BSR   OUT4HEX
 BRA   BACKWRIT
CREOK:
 MOVE.L L00(A3),A1  *so startadr in a1
 SUBA.W #$1C, A1   zeig (noch zu erstellenden) header
 MOVE  #$601A,(A1)
 MOVE.L LPC(A3),D7 *so LÑnge (ohne header) in d7.L
 MOVE.L D7, 2(A1)
 MOVE  #$DADA,$1A(A1)  markiere als "vîllig relocierbar"
 ADD.L #$1C, D7
 MOVE.L A1,-(A7) startadr (incl header)
 MOVE.L D7,-(A7) LÑnge   (incl header)
 MOVE  D5, -(A7) *handle
 MOVE  #$40,-(A7) *WRITE
 TRAP  #1
 ADDA.W #12, A7
 MOVE.L D0,  D7 *TATSéCHLICHE LéNGE
 BSR   CLOSE
BACKWRIT:
 LEA  88(A7),A7
NOWRITE:

move #1,-(a7)
trap #1
cmp.b #'.',d0
beq setEnde
***********

bsr newline
move.L L00(A3),A2
move.L LPC(A3),D3
moveq #0,d2
ncLCou:
move.L (A2)+,d1
bsr woutmit
subq.L #4,D3
bhs  ncLCou

bsr newline
move.L SP0(A3),A2
moveq #0,d2
ncSTou:
move.L -(A2), D1
bsr  woutmit
cmp.L AKS(A3),A2
bhs  ncSTou

bsr newline
move.L AZE(A3),d0
bsr wout
move.L L00(A3),d0
bsr wout
move.L LPC(A3),d0
bsr wout
move.L SP0(A3),d0
bsr wout
move.L AKS(A3),d0
bsr wout

vorEnde:
move #1,-(a7)
trap #1
bra setEnde


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
 movem.L a0/d0,-(a7)
 moveq  #13, d0   carrRet
 bsr    chou
 moveq  #10, d0   LineFeed
 bsr    chou
 movem.L (a7)+,a0/d0
rts

*sub gibt nen BLANK aufn BSchirm
blankou:
movem.L d0/a0,-(a7)
 moveq #32,  d0     blank
ou1ch:
 bsr   chou
movem.L (a7)+,d0/a0
rts

woutmit:
 move.L d1,d0
 swap d0
 bsr wout
 move d1,d0
 bsr wout
 addq #1,d2
 cmp #8,d2
 blo rwmit
 bsr newline
 moveq #0,d2
rwmit: rts

wout:
 bsr blankou
 swap d0
 clr.w d0
 rol.L #4,d0
 add.B #'0',d0
 cmp.B #'9',d0
 bls  okwout
 addq.B #7,d0
okwout:
 bsr chou
 clr  d0
 rol.L #4,d0
 add.B #'0',d0
 cmp.B #'9',d0
 bls  okwou
 addq.B #7,d0
okwou:
 bsr chou
 clr  d0
 rol.L #4,d0
 add.B #'0',d0
 cmp.B #'9',d0
 bls  okwo
 addq.B #7,d0
okwo:
 bsr chou
 clr  d0
 rol.L #4,d0
 add.B #'0',d0
 cmp.B #'9',d0
 bls  okw
 addq.B #7,d0
okw:
 bsr chou
rts


setEnde:
 clr -(a7)
 trap #1  abbrechen


AUSWEREL:
*subroutine fast wie AUSWERTE, kriegt aber a2 zeigend in symbTabelle so, daû
* -4(a2)= aktuellerPC. Dieser wird uU subtrahiert von jmpLabel-Typen, die
*              echten jmpLabels werden also "relativiert".
 BCLR #4,-4(A2)  ists 'DC.x' (=ne)?  dann ohnehin keine Relativierung.
 BNE  AUSWERTE
 MOVE.L #$FFFFFF,D2
 AND.L -4(A2),D2
 MOVE.L D2,OREL(A3)
 BRA   NOCAUBL

AUSWERTE:
*subroutine kriegt a0 zeigend auf string-Anfang, welcher einen Term
* darstellen soll. Åbergehe Blanks/Tabs/#. gib a0 zeigend hintern Term,
* d0 zeigend TermAnfang (excl. `#`).
*   d1.L=wert & d2.B=0 nur dann, wenns vollstÑndig berechenbar war!
 CLR.L OREL(A3)   so setz, daû keinerlei relativierung.
NOCAUBL:
 CMP.B #' ',(A0)+
 BEQ  NOCAUBL
 CMP.B #9,-1(A0)
 BEQ  NOCAUBL
 CMP.B #'#',-1(A0)
 BEQ  TRMANF
 SUBQ #1, A0
TRMANF:
 MOVE.L A0,-(A7)
 CLR.L WERT(A3)
 MOVEQ #$2B,D2  zumZeichen, daû erste Zahl auf obige Null draufzuaddieren.
 BRA  OKAUWZ
NOCTERM:
 MOVEQ #0,  D2
 MOVE.B (A0)+,D2  welcher ascii kommt hinterm ersten TeilString?
 CMP.B #'+',D2
 BEQ   OKAUWZ
 CMP.B #'*',D2
 BEQ   OKAUWZ
 CMP.B #'/',D2
 BEQ   OKAUWZ
 CMP.B #';',D2
 BEQ   OKAUWZ
 CMP.B #'\',D2
 BEQ   OKAUWZ
 CMP.B #'`',D2
 BEQ   OKAUWZ
 CMP.B #'^',D2
 BEQ   OKAUWZ
 CMP.B #'|',D2
 BEQ   OKAUWZ
 CMP.B #'-',D2
 BNE   MIAUWZ
 MOVE #$FF2B,D2  behandle wie +, aber flag, daû Operand vorher negiere
OKAUWZ:
 CMP.B #'-',(A0)
 BNE  OOKAUZ
 BCHG #15,D2
 ADDQ #1, A0
OOKAUZ:
 MOVE.W D2,-(A7)
 BSR  OBZAHLAU    wenn Zahl: a0 zeigend dahinter, sonst (ne) a0 laû
 MOVEM.W (A7)+,D2 laû flags
 BEQ WARZZ
ISNOTZ:
* ne= es war keine Zahlen(oder ASCII)angabe, sondern ein Name (=symbol). FÅr
* diese gibts eine Tabelle. Adresse Åber der Tabelle: in SP0(a3), unterste
* TabellAdr in AKS(a3). FÅr jeden Eintrag sind zwei Longs verwendet.
* Namensdefinitionen, deren Wert bereits feststeht, erkennst du daran:
* ihr oberes Longword beginnt mit %01, also bit31=0 bit 30=1. Die Åbrigen
* bits geben den adrOffset an zum Beginn des Quelltextes und zeigen so den
*          Namens-string im Quelltext. Das untere Longword enthÑlt den Wert.
 BSR GUCKINTA  Laû a0. gib a1 zeignd +-/ oderso und d0=Wert, wenns ihn gibt,
*             wobei Relativierung um OREL(A3), wenns jmpLabel ist.
 BNE MISTAUWZ  ne= gibt (noch) keinen Wert.
 LEA (A1),A0
WARZZ:
 MOVE.L WERT(A3),D1
 BSR VERARBEI      verknÅpf mit d0, wobei D2.B sagt,ob add,mul,div,shift etc
 MOVE.L D1,WERT(A3)  nun ist weiterer Term in aktuellerZahl berÅcksichtigt.
 BRA NOCTERM

MISTAUWZ:
 MOVEQ #-1,D2    Zeichen,daû Berechnung noch nicht mîglich. such stringEnde:
MWZNO1:
 CMP.B #'$',(A0)+
 BLO  MAUWZ
 CMP.B #',',-1(A0)
 BNE  MWZNO1
 BRA MAUWZ
MIAUWZ:
 MOVEQ #0,  D2   Zeichen,daû alles OK.
MAUWZ:
 SUBQ   #1,  A0  zeig hinter Term-string.
 MOVE.L (A7)+,D0 anfangsAdr des string.
 RTS


OBZAHLAU:
*subroutine will a0 zeigend ZahlenString, gib flag ne, wenn nicht,
* sonst gib D0.L = Zahl. a0 zeigend hinter den (Teil)string;
*    behandle auch asciis innerhalb Hochkomma als "Zahl".
 CMP.B #$27,(A0)
 BEQ  OOSTRING  weil Hochkomma zu Beginn.
 CMP.B #'$',(A0)
 BEQ  HXAU
 CMP.B #'%',(A0)
 BEQ  BNAU
 CMP.B #'0',(A0)
 BLO  NXZAHL
 CMP.B #'9',(A0)
 BHI  NXZAHL
 BSR  DEZAUSW
WARZAHL:
 MOVEQ #0,D1   flag eq
NXZAHL:
 RTS    mit flag ne, wenns kein ZahlenString ist
HXAU:
 ADDQ #1,A0
 BSR  HEXAUSW
 BRA  WARZAHL
BNAU:
 ADDQ #1,A0
 BSR  BINAUSW
 BRA  WARZAHL
OOSTRING:
 MOVEQ #0,D0
 ADDQ  #1,A0
ONSTRIN:
 MOVE.B (A0)+,D1
 CMP.B #$27,D1 erneutes Hochkomma = stringEnde
 BEQ   WARZAHL
 CMP.B #13,D1  carrRet hier nicht erlaubt
 BEQ   WARZAHL
 LSL.L #8, D0  wenn der string Åber 4 asciis hat: nur letzte 4 nehmen
 OR.B  D1, D0
 BRA  ONSTRIN

BINAUSW:
*subroutine wertet ab a0 binÑr aus (a0 muû hinter ein `%` zeigen),
* solange, bis auf was andres als 0 oder 1 gestoûen. gib a1 dies zeigend.
 MOVEQ #1,D0
 SUBQ  #1,D0  lîscht xflag
NOCNE0:
 ADDX.L D0,D0    lîscht im allgemeinen xflag
 CMP.B #'0',(A0)+
 BEQ   NOCNE0
 CMP.B #'1',-1(A0)
 BEQ   NOCNE1
 SUBQ  #1, A0  zeig das byte, das weder '0' noch '1' ist.
 RTS
NOCNE1:
 ORI #$10,CCR  setz xflag
 BRA NOCNE0

DEZAUSW:
*subroutine wertet ab a0 dez aus (a0 muû auf dezZiffer zeigen),
* solange, bis auf was andres als 0odr1odr...9 gestoûen. gib a1 dies zeigend.
 MOVEQ #0,D0
NOCNDEZ:
 MOVE.B (A0)+,D2
 CMP.B #'0', D2
 BLO   RDEZA
 CMP.B #'9', D2
 BHI   RDEZA
 MOVE.L D0,D1
 SWAP   D1
 MULU #10,D1
 LSL.L #8,D1
 LSL.L #8,D1  hiWord mit 10 multipliziert
 MULU #10,D0
 ADD.L D1,D0  gesamtErgebnis: D0.L mit 10 multipliziert.
 AND.L #15,D2
 ADD.L D2, D0  und dadrauf die neueste Ziffer draufadd.
 BRA   NOCNDEZ
RDEZA:
 SUBQ #1,A0
 RTS

HEXAUSW:
*subroutine wertet ab a0 hex aus (a0 muû auf dezZiffer zeigen),
* solange, bis auf was andres als 0odr1odr...F gestoûen. gib a1 dies zeigend.
 MOVEQ #0,D0
NOCNHEX:
 MOVE.B (A0)+,D2
 CMP.B #'0', D2
 BLO   RHEXA
 CMP.B #'9', D2
 BLS   GEFHEX
 AND.B #$DF, D2  Groûbuchstaben erzwingen
 CMP.B #'A', D2
 BLO   RHEXA
 CMP.B #'F', D2
 BHI   RHEXA
 SUBQ  #7, D2  bei `A` ... `F`: umrechnen.
GEFHEX:
 AND.L #15,D2
 LSL.L #4, D0
 ADD.L D2, D0  und dazu die neueste hexZiffer draufaddiere.
 BRA   NOCNHEX
RHEXA:
 SUBQ #1,A0
 RTS

VERARBEI:
*subroutine kriegt d1.L=Ziel d0.L=quelle d2.B=code,wasZuTun
* wobei bit15(vonD2)=1 bedeutet, daû d0 vorher zu negieren. d2.B:
* + Addition  * Multipl  / Division  ; DivRest  (diese alle signed)
* \ Oderiere  ` excl-or  ^ Undiere   | shift(d0<0:arithShiftRight)
 BCLR #15,D2
 BEQ  OK2B7
 NEG.L   D0
OK2B7:
 ADD.L D0, D1
 CMP.B #'+',D2
 BEQ   OKVRARB
 SUB.L D0, D1
 EOR.L D0, D1
 CMP.B #'`',D2
 BEQ   OKVRARB
 EOR.L D0, D1
 CMP.B #'\',D2
 BEQ   VRODR
 CMP.B #'^',D2
 BEQ   VRUND
 CMP.B #'|',D2
 BEQ   VRSHIFT
* die ÅbrigenMîglichkeiten wollen unsigned rechnen, d.h:
* Åbergib nur BetrÑge in d0d1, in bit15vond2 das Vorzeichen des Ergebnisses.
 BCLR  #15,D2
 MOVE.L D0,D0
 BPL   ERSTBETR
 NEG.L D0
 BCHG  #15,D2
ERSTBETR:
 MOVE.L D1,D1
 BPL   ZWEITBET
 NEG.L D1
 BCHG  #15,D2
ZWEITBET:
 CMP.B #'*',D2
 BEQ   VRMUL
 CMP.B #'/',D2
 BEQ   VRDIV
 CMP.B #';',D2
 BEQ   VRMOD
BRA VRNIXDA

VRODR:
 OR.L D0,D1
 RTS
VRUND:
 AND.L D0,D1
 RTS
VRSHIFT:
 NEG D0
 BEQ OKVRARB
 BPL VRSHRIGH
 NEG D0
VRSHLEFT:
 ASL.L #1,D1
 SUBQ #1,D0
 BNE VRSHLEFT
 RTS
VRSHRIGH:
 SUBQ  #1,D0   DBRA vorbereite
VRSHRIG:
 ASR.L #1,D1
 DBRA  D0,VRSHRIG
 MOVEQ #0,D0
 ADDX.L D0,D1  aufrunden, falls leztes rausgeschobnes bit =1 (=xFlag)
 RTS

VRMUL:
 MOVE  D2,-(A7) weil bit15 = Vorzeichen
 MOVE.L D1,D2  Ziel-Zahl
 SWAP   D2
 MULU   D0,D2  LowWord mal HiWord soherum
 MOVE.L D2,D3  und aufheben
 MOVE.L D1,D2
 SWAP   D0
 MULU   D0,D2  LowWord mal HiWord andersrum
 ADD.L  D2,D3  und zum vorigen dazu.
 SWAP   D0     wiederherstelle.
 LSL.L  #8,D3
 LSL.L  #8,D3  angemessener Stellenwert fÅr die ersten Teilprodukte.
 MULU   D0,D1  Letztes (sinnvolles) Teilprodukt: LowWord mal LowWord
 ADD.L  D3,D1  und bisherige dazu.
 MOVE  (A7)+,D2
 BRA   VRNOCSIG
VRDIV:
 MOVE D0,-(A7) merk den Nenner (maximal 15 bit)
 BSR  TEILE    gib Quotient in d1 und Rest in d0
 ADD.L D0,D0
 EXG  A0, D0
 CMP (A7)+,A0  ist derDopplRest > derNenner? dann aufrunden!
 EXG  A0, D0
 SHS   D0
 EXT.W D0
 EXT.L D0
 SUB.L D0,D1   subtrahiere also 0 (=laû) oder -1 (=aufrunde)
 BRA  VRNSIGN
VRMOD:
 BSR  TEILE    gib DivRest in d0
 EXG  D0,D1
VRNSIGN:
 MOVE D2,D2  wenn neg, dann auch d1.L neg zu nehmen
VRNOCSIG:
 BPL   OKVRARB
 NEG.L D1
OKVRARB:
VRNIXDA:
 RTS



TEILE:
*subroutine, die nur zum dividieren dient, eigentlich "DIVU D0,D1". Aber
* hier darf das Ergebnis ein Longword=D1.L sein! Rest wird in D0.L gegebn.
 MOVE   D0,D0    Nenner=0?
 BEQ    NIXDADIV
MOVEM.L D2/D3/A0,-(A7)
 MOVE.L D1,D2         Kopie des ZÑhlers
 CLR.W  D2
 SWAP   D2   dadurch kann ich das hiword dividieren ohne Risiko des OVERFL.
 DIVU   D0,D2
 MOVE.W D2,A0 Teil-Quotient aufheben.
 MOVE.W D1,D2 zum DivRest das ZÑhler-LowWord dazu. im hiWord: divisRest, sogar mit korrektem Stellenwert.
 LSR.L  #8,D2 dadurch wieder: overflow vermeiden.
 DIVU   D0,D2
 MOVEQ  #0,D3
 MOVE.W D2,D3 auch diesen TeilQuotienten aufheben.
 LSR.L  #8,D2 diesen DivRest erst auf korrekten Stellenwert.
 MOVE.B D1,D2 und letzer Teil des ZÑhlers dazu.
 DIVU   D0,D2
 MOVE.L D2,D0
 CLR.W  D0
 SWAP   D0    endgÅltiger DivRest nun in D0.L
 MOVE  A0,D1
 SWAP  D1
 LSL.L #8,D3  die ersten beiden TeilQuotienten auf richtigen Stellenwert.
 MOVE  D2,D1  zum ersten TeilQ den letzten TeilQ einfach untenrein.
 ADD.L D3,D1           das ist der GesamtQuotient.
 MOVEM.L (A7)+,D2/D3/A0
NIXDADIV: RTS

GUCKINTA:
* kriegt aktuellen name (stringAnfang=a0), sucht gleichen
* Name (=symbol) weiter oben im Quelltext, genauer: in zugehîrgr Tabelle.
*  in SP0(a3):Adresse Åber der Tabelle, unterste TabellAdr in AKS(a3).
* FÅr jeden Eintrag sind zwei Longs verwendet. Namensdefinitionen,
* deren Wert bereits feststeht (und nur die suchen), erkennst du daran:
* ihr oberes Longword beginnt mit %01, also bit31=0 bit 30=1. Bits_28..0
* geben den adrOffset an zum Beginn des Quelltextes und zeigen so auf
* den Namens-string im Quelltext. Das untere Longword enthÑlt den Wert.
* gib a1 zeigend hinter das symbol (auf dessen Anfang a0 zeigt).
*       gib flag eq und Wert in d0, wenn du einen findest. sonst flag ne.
*          subtrahiert OREL(A3) vom Wert(in d0) wenns jmpLabel war.
 MOVEM.L D2/D3/D4/A2,-(A7)
 MOVEQ #-1,D2
 LSR.L #3, D2    so d2.L=#$1FffFFff
MOVE.L QAN(A3),D3 QuelltextAnfangsAdr
MOVE.L SP0(A3),D4 Adr Åber der SymbolTabelle
MOVE.L AKS(A3),D1 zeig untersten Eintrag in SymbolTabelle
 SUBQ  #4, D1     durch spÑteren add#8: zeig quellOffset eines nameString
NOCGINTA:
 ADDQ  #8, D1
 MOVE.L D1,A1
 TST.B (A1)
 BMI   NOCGINTA  mi= noch kein Wert zuweisbar, also uninteressant.
 CMP.L D4, D1
 BHS   GUNOTOK
 MOVE.L D2,D0    $1FffFFff
 AND.L (A1),D0   Q-offset pur.
 ADD.L  D3,D0    QuelltxtAnfang dazu: zeig erstes byte dieser namensdef.
 MOVE.L D0,A2
 MOVE.L A0,A1    zeig aktuellen string
N1GGINTA:
 CMPM.B (A2)+,(A1)+
 BEQ   N1GGINTA
 CMP.B #':',-(A2)
 BNE   NOCGINTA   die strings sollen gleich sein bis auf den Doppelpkt.
 CMP.B #'0',-(A1) der aktuelle string hat stattdessen code<'0' oder
 BLO   GUWERTOK   ; odr \ odr ` odr ^ odr |
 CMP.B #';',(A1)
 BEQ   GUWERTOK
 CMP.B #'\',(A1)
 BEQ   GUWERTOK
 CMP.B #'`',(A1)
 BEQ   GUWERTOK
 CMP.B #'^',(A1)
 BEQ   GUWERTOK
 CMP.B #'|',(A1)
 BNE   NOCGINTA
GUWERTOK:
 MOVE.L D1, A2
 MOVE.L -(A2),D0  dieshier ist der zugehîrige Wert.
 BTST  #5, 4(A2)  symbTabellenEintrag als equ-Label gekennzeichnet(ne)?
 BNE   GUWOKOK     diesBit gesetzt = es war equ-Wert, kein jmpLabel
 SUB.L OREL(A3),D0 evtl "relativieren", da OREL= 0 oder aktueller PC.
GUWOKOK:
 CMP   D0,   D0   flag eq
 BRA   GURUU
GUNOTOK:
 MOVEQ #-1,  D0   flag ne
GURUU:
 MOVEM.L (A7)+,D2/D3/D4/A2
 RTS

LABOWAS:
*subroutine weiû, daû ab a0 ein string mit Doppelpunkt steht.
* und daû a1 zeigend hinter Doppelpunkt.
*    schau, obs Label oder EQU-Definition ist. und prÅfe, ob redefined.
NOBLLAOW:
 CMP.B #' ',(A1)+
 BEQ   NOBLLAOW
 CMP.B #9,-1(A1)
 BEQ   NOBLLAOW
 SUBQ #1, A1
* nun muû A1 aufs 'E' vom 'EQU' zeigen, wenn sichs um equ-Def handelt.
 MOVEP 0(A1),D0
 MOVEP 1(A1),D1
 AND  #$DFDF,D0
 AND  #$DFFF,D1
 CMP  #$4555,D0 'EU'
 BNE  SWARLAB
 CMP  #$5120,D1 'Q '
 BNE  SWARLAB
*                also ist es ne equ-Definition.
 MOVE.L A0,-(A7)
 LEA  4(A1),A0   und ich versuch, den Wert sogleich zu ermitteln
 BSR  AUSWERTE    gib d2=-1, wenn noch nicht ermittelbar. sonst D1=wert.
 MOVE.L AKS(A3),A1 hier bisher (falscher) Wert
 MOVE.L D1,   (A1) ..korriegiert.
 BSET   #5, 4(A1)   kennzeichne als equSymbol
 TST.B D2          obs etwa immer noch falsch ist (ne)?
 BEQ   OKEQU
 BSET   #7,  4(A1) dann kennzeichne Verkehrtheit durch dieses bit
 MOVE.L AZE(A3),(A1) und merk statt des Wertes halt die QZeilennummer.
OKEQU:
 LEA (A0),A1     bei equDef wird a1 (=a0 aus AUSWERTE) zeigend hinter Term.
 MOVE.L (A7)+,A0  a0 wieder zeigend den Namen.
SWARLAB:
*          hier wichtig: laû a1 zeigend hinter Doppelpunkt!

* weiter in VGLINTA:  prÅfe,ob dieser symbolName schonmal verwendet ja= mi.


VGLINTA:
*subroutine kriegt aktuName (stringAnfang=a0), mit ':' dahintr. such gleiche
* NameDef weiter oben im Quelltext, genauer: in zugehîrgr Tabelle.
*  Adresse Åber der Tabelle: in SP0(a3), unterste TabellAdr in AKS(a3).
* FÅr jeden Eintrag sind zwei Longs verwendet. Namensdefinitionen erkennst
* du so: ihr oberes Longword hat bit30=1. bit 31=uninteressant.
* bits29..0 geben den adrOffset an (relativ zum QuellTxtAnf), daraus also
* Namens-def-string im Quelltext ermittelbar.
*       gib flag mi, wenn du einen findest.

 MOVEM.L D2/D3/D4/A1/A2/A3,-(A7)
 MOVEQ #-1,D2
 LSR.L #3, D2     $1fFFffFF
 MOVEQ #58,D0     ':'
MOVE.L QAN(A3),D3
MOVE.L SP0(A3),D4
MOVE.L AKS(A3),A3
 ADDQ  #4, A3     zeig quellOffset DIESES nameStrings
NOCVINTA:
 ADDQ  #8, A3
 BTST  #6,(A3)
 BEQ   NOCVINTA   eq= keine NamensDefinition, also uninteressant.
 CMP.L D4, A3
 BHS   VGLOK
 MOVE.L D2,D1     $1FffFFff
 AND.L (A3),D1    offset pur.
 ADD.L  D3,D1     Adr des ersten byte der Namensdef dazu: zeig name.
 MOVE.L D1,A1
 MOVE.L A0,A2     zeig aktuellen string
N1VINTA:
 CMPM.B (A2)+,(A1)+
 BNE   NOCVINTA
 CMP.B -1(A1),D0  ':'
 BNE   N1VINTA    sind die strings gleich EINSCHLIEûLICH Doppelpkt?
 MOVEQ #-1,  D0   also gibts diese NamensDef mehrfach. ERROR, flag mi
VGLOK:
 MOVEM.L (A7)+,D2/D3/D4/A1/A2/A3  auf 'VGLOK' nur via hs, also flag pl
 RTS

IGNOSOME:
*subroutine will a0 zeigend in Quelltext, stell weiter,bis keine Blanks odr
* Tabs mehr kommen. Wenn dann code =< '.': eventuelles `.even` selber
*  erledigen und mit flag mi zurÅckgeben.
IGNOBT:
 CMP.B #' ',(A0)+
 BEQ   IGNOBT
 CMP.B #9,-1(A0)
 BEQ   IGNOBT
 CMP.B #'.',-(A0)  ist erstes ernsthaftes Zeichen ein Punkt?
 BEQ   OBEEVEN
RTS flag pl, wenn einigermaûn vernÅnftge Zeichen.

OBEEVEN:
 MOVEP 1(A0),D0
 MOVEP 2(A0),D1
 AND  #$DFDF,D0
 AND  #$DFDF,D1
 CMP  #$4545,D0  waren erster und dritter Buchstabe ='E'?
 BNE  NOEVE
 CMP  #$564E,D1  zweiter und vierter = `V` und `N`?
 BNE  NOEVE
 MOVE.L LPC(A3),A1
 ADD.L  L00(A3),A1
 CLR.B       (A1)
 ADDQ.L #1,LPC(A3)
 ANDI.L #-2,LPC(A3) geradzahligen virtuellen pc erzwinge
NOEVE:
 MOVEQ #-1,D0      flag mi
RTS

DCLABINS:
*subroutine prÅft ab a0, ob hier 'DC.x' steht, oder ein 'LABEL:' oder
* eine 68000-instruction (wie MOVE oder CMP ...).
 MOVEP 0(A0),D0
 MOVEP 1(A0),D1
 AND  #$DFFF,D0
 AND  #$DFDF,D1
 CMP  #$442E,D0  'D.'
 BNE  NODC
 CMP #$4342,D1  'CB'
 BEQ DCBFOUND
 CMP #$4357,D1  'CW'
 BEQ DCWFOUND
 CMP #$434C,D1  'CL'
 BEQ DCLFOUND
NODC:
 LEA (A0),A1
 MOVEQ #58,D0 ':'
 MOVEQ #48,D1 '0'
NOCSLAB:
 CMP.B (A1),D1
 BHI  NOLABL
 CMP.B (A1)+,D0
 BNE  NOCSLAB
 MOVE.L A0,D1    AnfangsAdr dieses strings, der einen Label darstellt.
 SUB.L QAN(A3),D1 daraus offset zum QuellTextAnfang berechnen.
 BSET  #30,D1     kennzeichnen als "SymbolDef"
 MOVEQ #0, D0  flag pl eq um anzuzeigen,daû hier ein Label steht.
RTS
NOLABL:
 MOVEQ #1, D0  flag pl ne um anzuzeigen: muû wohl instruction sein.
RTS
DCBFOUND:
 MOVE.W #$FF,D3  signalisiere "DC.B-found"
 BRA  RDCXFOU
DCWFOUND:
 MOVEQ #0,D3  DC.W-found
 BRA  RDCXFOU
DCLFOUND:
 MOVEQ #1,D3  stets bit15 von d3 = 0
RDCXFOU:
 ADDQ #4, A0  zeig hinter 'dc.x'
 MOVEQ #-1,D0 mi= DC.x found.
 RTS


WORKDC:
*subroutine weiû, daû    'DC.B' odr `DC.W` oder 'DC.L' irgendwo vor a0,
* kriegt entsrechnd d3.B= mi (-1)   eq (0)     pl ne (1)
* gib LPC(a3) weitergezÑhlt und protokollier in LPC-Liste, gib aber
* d2.B=0 nur dann, wenn Berechnung vollstÑndig war. Denn uU. ist es zwar
* korrekt, daû Listenplatz belegt wurde, aber der protokollierte Wert
* ist nicht OK.  gib a0 zeigend hinter (gesamt)Term
 *       mach am Schluû: TST.B D2   mach zuAnfang: guck ob innerhalb string.
MOVE  D3,-(A7)
BPL   NICHIMST  mi= wir befinden uns innerhalb von Hochkommas!
MOVE  (A7)+,D3
TTTOOBS:
MOVE.B (A0)+,D0
CMP.B #$27, D0  schon wieder drauûen, weil zweites Hochkomma?
BEQ   TJAIMST
CMP.B #13, D0
BEQ   TJAIMST
MOVE.L L00(A3),A1
ADD.L LPC(A3),A1  zeig,wo nÑchstes ascii hinsoll
MOVE.B D0,  (A1)  und da kommt es schon.
ADDQ.L #1,LPC(A3)
RTJAI:
 MOVEQ #0,D2  signalisiere code OK.
 RTS
TJAIMST:
 BCLR #15,D3  signalisiere: wir sind nicht (mehr) im string.
 TST.B D3
 BMI   RTJAI      pl= vorne war dc.w oder dc.L, also even LPC(a3) erzeuge!
 MOVE.L L00(A3),A1
 ADD.L  LPC(A3),A1  zeig,wo nÑchstes ascii hinwÅrde..
 CLR.B        (A1)  und schreib 0.
 ADDQ.L #1,LPC(A3)
 AND   #-2,LPC+2(A3) so sicher gradzahlig
 BRA RTJAI

NICHIMST:
* erstmal prÅfen, ob grade hier ein string anfÑngt (also Hochkomma prÅfe!)
NICHISLO:
 CMP.B #' ',(A0)+
 BEQ  NICHISLO
 CMP.B #9,-1(A0)
 BEQ  NICHISLO
 CMP.B #$27,-(A0) erstes echtes Zeichen ein Hochkomma?
 BNE  TATSNIST
 ADDQ #1,A0
 MOVE (A7)+,D3
 BSET #15,D3
 BRA TTTOOBS
TATSNIST:
BSR   AUSWERTE  gibt d2.B=mi wenn noc nicht berechnbar. d0=nameAdr d1=wert
MOVE  (A7)+,D3
MOVE.L L00(A3),A1
ADD.L LPC(A3),A1 zeig,wo nÑchster code hinsoll.
SUB.L QAN(A3),D0 so d0= adrOffset zum string hinterm DC.x bzw hinterm Komma.
BSET  #31,   D0  kennzeichne als "nochZuBerechnen".
TST.B D3
BMI  ISTDCB
BEQ  ISTDCW
* ansonsten ists `DC.L`
 BSR   DCR1B4
 MOVE.L LPC(A3),D1
 ADDQ.L #4,LPC(A3) zÑhl um Long weiter.
 ROL.L  #8,D1      mach oberstesByte zugÑnglich, falls offset auf stack muû,
 MOVE.B #LKD,D1    dann nÑmlich Kennung "LONG_DC.x" hier rein.
 BRA    RWORKDC
DCR1B4:
 ROL.L  #8, D1
 MOVE.B D1,(A1)+
 ROL.L  #8, D1
 MOVE.B D1,(A1)+
 ROL.L  #8, D1
 MOVE.B D1,(A1)+
 ROL.L  #8, D1
 MOVE.B D1,(A1)+
RTS

ISTDCW:
 BSR    CDR1
 MOVE.L LPC(A3),D1
 ADDQ.L #2,LPC(A3) ZÑhle 2, weil word.
 ROL.L  #8,D1
 MOVE.B #WKD,D1
 BRA    RWORKDC
ISTDCB:
 MOVE.B D1,(A1)   byte in instruction-stream reinschreiben
 MOVE.L LPC(A3),D1
 ADDQ.L #1,LPC(A3) ZÑhler fÅr ebendiesen stream, add#2 auch bei byte.
 ROL.L  #8,D1
 MOVE.B #BKD,D1    Kennung fÅr nachzutragende Bytes. s.u.
RWORKDC:
 ROR.L #8,D1 hiByte=Kennzeichnung BWL, weitre 24bit=offset im instStream.
 TST.B D2    gib flags pl eq, wenn Berechnung OK.
 RTS

SUCHLFEE:
*subroutine, stellt a0 weiter, bis es hinters nÑchste LineFeed (=code $A)
* zeigt. Kontrolliere, ob Åbern Quelltext hinausgeraten: dann flag ne.
FL88GUC:
 MOVEQ #88,D0  spÑtestens nach 88 bytes: kontrolle, ob QText zuende.
 MOVEQ #10,D1  dieser code (=LineFeed) wird gesucht
FLNOCGUC:
 CMP.B (A0)+,D1
 DBEQ  D0, FLNOCGUC
 BEQ   OBQTZUE
 CMP.L QEN(A3),A0
 BLO   FL88GUC
 RTS            hier RÅckkehr hs, zeigend, daû QText zuEnde
OBQTZUE:
 CMP.L QEN(A3),A0  hier hs oder lo (=nichtZuEnde)
 RTS



T:
 MOVEQ #0,D0
 MOVEQ #0,D2
 RTS

ENKEY:
*subroutine erwartet string ab a0, mind zwei Byte lang, dahinter
* (sozusagen als Abschluû) Punkt oder Blank oder Tab oder carRet.
* gib flags eq pl, wenn OK.
* Letzte drei Mîglichkeiten: gib d3_hiWord=0, bei Punkt untersuche
* den folgenden char, gib d3_hiW=1/2/3 bei B/W/L. In den FÑllen Pkt,Blnk,Tab:
* a0 auf Anfang des nÑc string stellen (odr auf nÑc carRet).
* In allen vier FÑllen: in d3.w den string hineinverschlÅsseln,
* so wie die jsr_OFFSET_tabelle der INNER SUBROUTINES es braucht, also:
*
* jeder ascii wird zu einem nibble (=4bit_Einheit), wobei bits _4_3_2_1
* des characters verwendet! (also zB. 'B'='C'=1 oder 'T'='U'=$A).
* Daraus wird ein vier-nibble-word, wobei die nibbles der letzten beiden
* Zeichen stets ganz unten reinkommen. Wenn es drei Zeichen waren, so
* kommt obenrein ins word der nibble 0 und dann der nibble des ersten ascii.
* Waren es mehr Zeichen, so kommt der nibble des ersten obenrein ins word,
* der nibble des zweiten folgt sogleich. Dann der nibble des zweitletzten
* und schlieûlich der des letzten Zeichens, wie gehabt. Beispiel:
* nibbleCode fÅr 'ADD': bits _15_14_13_12 = 0, weil nur drei ascii.
* 'A'= %01000000, verwende 0000. von 'D': 0010, also d3.w= $0022.

 MOVEQ #$1E,D3
 AND.B (A0)+,D3  beim erten ascii noch keine Kontrolle
 LSL.W #3,  D3   sondern gleich vier seiner bits auf D3_7_6_5_4 Åbernehmen.
 MOVE.B (A0)+,D0
 CMP.B #'A',D0   nun aber Kontrolletti, ob zweiter char wirklich Buchstabe
 BLO   ERRENKEY
 LSL.B #3,  D0
 LSR.B #4,  D0   so bleiben nur die gewÅnschten vier bit Åbrig
 OR.B  D0,  D3   und werden ganz unten ins D3 Åbernommen.
 MOVE.B (A0)+,D0
 CMP.B #'A',D0   Kontrolle, ob dritter char wirklich Buchstabe, wobei
 BLO   OBEENKEY  hier auch ein regulÑres stringEnde dahinterstecken kînnte!
 LSL.W #4,  D3   Platz schaffen im unteren Nibble
 LSL.B #3,  D0
 LSR.B #4,  D0
 OR.B  D0,  D3   Nibble ganz unten ins D3 Åbernommen.
 MOVE.B (A0)+,D0
 CMP.B #'2',D0   Kontrolle, ob vierter char vernÅnftig (hier ziff legal), 
 BLO   OBEENKEY  aber auch ein regulÑres stringEnde kînnte dahinterstecken.
 LSL.W #4,  D3   Platz schaffen im unteren Nibble
 LSL.B #3,  D0
 LSR.B #4,  D0
 OR.B  D0,  D3   Nibble ganz unten ins D3 Åbernommen.
NOCENKEY:
 MOVE.B (A0)+,D0
 CMP.B #'2',D0   Kontrolle, ob nÑchster char vernÅnftig (ziff legal), 
 BLO   OBEENKEY  aber auch ein regulÑres stringEnde kînnte dahinterstecken.
 LSL.B #4,  D3   diesmal hi_Byte laû! Nur Platz schaffen innerhalb des d3.B!
 LSL.B #3,  D0
 LSR.B #4,  D0
 OR.B  D0,  D3   Nibble ganz unten ins D3 Åbernommen.
 BRA   NOCENKEY  aber auch ein regulÑres stringEnde kînnte dahinterstecken.
OBEENKEY:
 CMP.B #13, D0   carRet?
 BEQ   FERTNL
 CMP.B #' ',D0
 BEQ   FERTOHNE
 CMP.B #9,  D0   Tab?
 BEQ   FERTOHNE
 CMP.B #'.',D0
 BEQ   FERTMIT
ERRENKEY:
 MOVEQ #-1,D0    flag ne
 RTS

FERTMIT:
 MOVEQ #$DF, D0
 AND.B (A0)+,D0
 ADD.L #$10000,D3  hiWord von d3 auf 1 setzen, falls `.B` folgt
 CMP.B #'B', D0    wars `.B`?
 BEQ   NXSTRENK
 ADD.L #$10000,D3  hiWord von d3 auf 1 setzen, falls `.W` folgt
 CMP.B #'W', D0    wars `.W`?
 BEQ   NXSTRENK
 ADD.L #$10000,D3  hiWord von d3 auf 1 setzen, falls `.L` folgt
 CMP.B #'L', D0    wars `.L`?
 BEQ   NXSTRENK
 BRA   ERRENKEY
FERTOHNE:
NXSTRENK:
 CMP.B #' ',(A0)+  folgt Blank? Åbergehe.
 BEQ   NXSTRENK
 CMP.B #9,-1(A0)   oder wars Tab, was folgte? auch Åbergehen.
 BEQ   NXSTRENK
FERTNL:
 SUBQ  #1, A0     so zeigts auf nÑchsten string.
 MOVEQ #0, D0    flag eq
 RTS


* es folgt die jsr_OFFSET_tabelle zu den INNER SUBROUTINES,
* genauer:
*
* jeder Tabelleneintrag besteht aus vier words, im ersten word ist
* die instruction verschlÅsselt, im zweiten das mindestBitMuster des
* zugehîrigen codes. Im dritten word wird mitgeteilt, welche Extensions
* erlaubt sind (also .B und/oder .w und/oder .L). Im vierten word erst
* kommt der pc_offset, der auf den Label "k:" draufaddiert wird, um
* in der passenden Operanden_Kombinations_subroutine zu landen
* (also in einer der ca 50 "inner_subroutines".
*
* zum ertsen word: es geht um alle instructions, wie zB. MOVE oder
* MOVEA oder BCLR oder CLR..., also ursprÅnglich um asciistrings, die mehr
* als 16 bit beanspruchen. Diese werden nun in die 16 bit so hinein-
* verschlÅsselt:
* jeder ascii wird zu einem nibble (=4bit_Einheit), wobei bits _4_3_2_1
* des characters verwendet! (also zB. 'B'='C'=1 oder 'T'='U'=$A).
* Daraus wird ein vier-nibble-word, wobei die nibbles der letzten beiden
* Zeichen stets ganz unten reinkommen. Wenn es drei Zeichen waren, so
* kommt obenrein ins word der nibble 0 und dann der nibble des ersten ascii.
* Waren es mehr Zeichen, so kommt der nibble des ersten obenrein ins word,
* der nibble des zweiten folgt sogleich. Dann der nibble des zweitletzten
* und der des letzten Zeichens, wie gehabt. Beispiel:
* nibbleCode fÅr 'ADD': bits _15_14_13_12 = 0, weil nur drei ascii.
* 'A'= %01000000, verwende 0000. von 'D': 0010, gibt $0022.
* instrCode= % 1101 000j 00ee eeee, mit eeeeee= effAdr_feld.
* .B .w .L erlaubt, also code 0 fÅrs dritte word.
* Opernd: 'D,mv' (dann j=1) oder 'u,D' (dann j=0)
*wobei D=DatRegister u=univ_effAdr mv=memoryVerÑndrb.
ICODTAB:
dc.w $0022,$D0C0,2,u_A-T * ADD  u,A
dc.w $0022,$D1C0,3,u_A-T * ADD.L u,A
dc.w $0022,$D000,0,u_D-T * ADD u, D
dc.w $0022,$D100,0,Dmv-T * ADD D, mv
dc.w $0022,$0600,0,F_vd-T *ADDI  #x,vd
dc.w $0072,$C000,0,d_D-T * AND d, D
dc.w $0072,$C100,0,Dmv-T * AND D, mv
dc.w $0072,$027C,2,G_SR-T *ANDI #x,SR  x als word verwenden
dc.w $0072,$023C,2,GCCR-T *ANDI #x,CCR
dc.w $0072,$0200,0,F_vd-T *ANDI #x,vd
dc.w $0079,$8000,0,d_D-T * OR  d, D
dc.w $0079,$8100,0,Dmv-T * OR  D, mv
dc.w $0079,$007C,2,G_SR-T *ORI #x,SR   x (selbst wenn Long) als word verw!
dc.w $0079,$003C,2,GCCR-T *ORI #x,CCR
dc.w $0079,$0000,0,F_vd-T *ORI #x,vd
dc.w $0093,$51C0,1,vd-T  * SF  vd
dc.w $0096,$E120,0,D_D-T * ASL D, D   ziel in _2_1_0
dc.w $0096,$E100,0,F3_D-T *ASL #x,D   x muû in drei bit reinpassen
dc.w $0096,$E1C0,2,vd-T  * ASL vd
dc.w $0099,$E020,0,D_D-T * ASR D, D
dc.w $0099,$E000,0,F3_D-T *ASR #x,D   x muû in drei bit reinpassen
dc.w $0099,$E0C0,2,vd-T  * ASR vd
dc.w $009A,$50C0,1,vd-T  * ST  vd
dc.w $0111,$6400,7,lab-T * BCC label
dc.w $0112,$C100,1,DDD-T * ABCD D,D       quelle in _2_1_0
dc.w $0112,$C108,1,MIMI-T *ABCD -(A),-(A)
dc.w $0119,$6500,7,lab-T * BCS label
dc.w $0128,$6700,7,lab-T * BEQ label
dc.w $0132,$6C00,7,lab-T * BGE label
dc.w $013A,$6E00,7,lab-T * BGT label
dc.w $0144,$6200,7,lab-T * BHI label
dc.w $0145,$4180,2,d_D-T * CHK d, D
dc.w $0149,$6400,7,lab-T * BHS label (=bcc)
dc.w $0162,$6F00,7,lab-T * BLE label
dc.w $0164,$6B00,7,lab-T * BMI label
dc.w $0167,$6500,7,lab-T * BLO label (=bcs)
dc.w $0168,$B000,0,u_D-T * CMP u, D
dc.w $0168,$B0C0,2,u_A-T * CMP  u,A
dc.w $0168,$B1C0,3,u_A-T * CMP.L u,A
dc.w $0168,$0C00,0,F_vd-T *CMPI #x,vd
WG169:
dc.w $016A,$6D00,7,lab-T * BLT label
dc.w $0172,$6600,7,lab-T * BNE label
dc.w $0186,$6A00,7,lab-T * BPL label
dc.w $0190,$6000,7,lab-T * BRA label
dc.w $0199,$6100,7,lab-T * BSR label
dc.w $01B1,$6800,7,lab-T * BVC label
dc.w $01B9,$6900,7,lab-T * BVS label
dc.w $0213,$51C8,2,D_l-T * DBF D,label
dc.w $021A,$50C8,2,D_l-T * DBT D,label
dc.w $0220,$D0C0,2,u_A-T * ADDA  u,A
dc.w $0220,$D1C0,3,u_A-T * ADDA.L u,A
dc.w $0224,$0600,0,F_vd-T *ADDI  #x,vd
dc.w $0228,$5048,2,F3_A-T *ADDQ  #x,A  x muû in drei bit passen
dc.w $0228,$5088,3,F3_A-T *ADDQ.L #x,A  x muû in drei bit passen
dc.w $0228,$5000,0,F3_vd-T *ADDQ  #x,vd  x muû in drei bit passen
dc.w $022C,$D100,0,DDD-T * ADDX  D, D    quelle in _2_1_0
dc.w $022C,$D180,0,MIMI-T *ADDX -(A),-(A)
dc.w $0279,$B100,0,D_vd-T *EOR D, vd
dc.w $0279,$0A7C,2,G_SR-T *EORI #x,SR  x als word verwenden
dc.w $0279,$0A3C,2,GCCR-T *EORI #x,CCR
dc.w $0279,$0A00,0,F_vd-T *EORI #x,vd
dc.w $02C3,$C140,3,D_D-T * EXG D, D
dc.w $02C3,$C148,3,A_A-T * EXG A, A
dc.w $02C3,$C188,3,D_A-T * EXG D, A
dc.w $02C3,$C188,3,A_D-T * EXG A, D
dc.w $02CA,$4880,2,NURD-T *EXT.w D
dc.w $02CA,$48C0,3,NURD-T *EXT.L D
dc.w $0568,$4EC0,3,nurk-T *JMP k
dc.w $0599,$4E80,3,nurk-T *JSR k
dc.w $0620,$41C0,3,k_A-T * LEA k, A
dc.w $0696,$E128,0,D_D-T * LSL D, D
dc.w $0696,$E108,0,F3_D-T *LSL #x,D   x muû in drei bit reinpassen
dc.w $0696,$E3C0,2,vd-T  * LSL vd
dc.w $0699,$E028,0,D_D-T * LSR D, D
dc.w $0699,$E008,0,F3_D-T *LSR #x,D   x muû in drei bit reinpassen
dc.w $0699,$E2C0,2,vd-T  * LSR vd
dc.w $0723,$4400,0,vd-T  * NEG vd
dc.w $0724,$027C,2,G_SR-T *ANDI #x,SR  x als word verwenden
dc.w $0724,$023C,2,GCCR-T *ANDI #x,CCR
dc.w $0724,$0200,0,F_vd-T *ANDI #x,vd
dc.w $0778,$4E71,7,0     * NOP
dc.w $077A,$4600,0,vd-T  * NOT vd
dc.w $0794,$007C,2,G_SR-T *ORI #x,SR   x (selbst wenn Long) als word verw!
dc.w $0794,$003C,2,GCCR-T *ORI #x,CCR
dc.w $0794,$0000,0,F_vd-T *ORI #x,vd
dc.w $0820,$4840,3,nurk-T *PEA k
dc.w $0911,$54C0,1, vd-T * SCC vd
dc.w $0919,$55C0,1, vd-T * SCS vd
dc.w $0928,$57C0,1, vd-T * SEQ vd
dc.w $0932,$5CC0,1, vd-T * SGE vd
dc.w $093A,$5EC0,1, vd-T * SGT vd
dc.w $0944,$52C0,1, vd-T * SHI vd
dc.w $0949,$54C0,1, vd-T * SHS vd hs=cc
dc.w $0962,$5FC0,1, vd-T * SLE vd
dc.w $0964,$5BC0,1, vd-T * SMI vd
dc.w $0967,$55C0,1, vd-T * SLO vd lo=cs
dc.w $0969,$53C0,1, vd-T * SLS vd
dc.w $096A,$5DC0,1, vd-T * SLT vd
dc.w $0972,$56C0,1, vd-T * SNE vd
dc.w $0976,$E138,0,D_D-T * ROL D, D
dc.w $0976,$E118,0,F3_D-T *ROL #x,D   x muû in drei bit reinpassen
dc.w $0976,$E7C0,2,vd-T  * ROL vd
dc.w $0979,$E038,0,D_D-T * ROR D, D
dc.w $0979,$E018,0,F3_D-T *ROR #x,D   x muû in drei bit reinpassen
dc.w $0979,$E6C0,2,vd-T  * ROR vd
dc.w $0986,$5AC0,1, vd-T * SPL vd
dc.w $09A1,$90C0,2,u_A-T * SUBA  u,A
dc.w $09A1,$91C0,3,u_A-T * SUBA.L u,A
dc.w $09A1,$9000,0,u_D-T * SUB   u, D
dc.w $09A1,$9100,0,Dmv-T * SUB   D, mv
dc.w $09A1,$0400,0,F_vd-T *SUBI  #x,vd
dc.w $09A2,$4E73,7,0     * RTE
WG9A9:
dc.w $09B1,$58C0,1, vd-T * SVC vd
dc.w $09B9,$59C0,1, vd-T * SVS vd
dc.w $0A09,$4AC0,1, vd-T * TAS vd
dc.w $0A9A,$4A00,0, vd-T * TST vd
dc.w $1143,$0140,3,D_D-T * BCHG D,D
dc.w $1143,$0140,1,Dmv-T * BCHG D,mv
dc.w $1143,$0840,3,G_D-T * BCHG #x,D   x stets als word verwende!
dc.w $1143,$0840,1,G_mv-T *BCHG #x,mv
dc.w $1169,$0180,3,D_D-T * BCLR D,D
dc.w $1169,$0180,1,Dmv-T * BCLR D,mv
dc.w $1169,$0880,3,G_D-T * BCLR #x,D   x stets als word verwende!
dc.w $1169,$0880,1,G_mv-T *BCLR #x,mv
dc.w $1680,$B0C0,2,u_A-T * CMPA  u,A
dc.w $1680,$B1C0,3,u_A-T * CMPA.L u,A
dc.w $1684,$0C00,0,F_vd-T *CMPI  #x,vd
dc.w $1686,$B108,0,PLPL-T *CMPM (A)+,(A)+
dc.w $192A,$01C0,3,D_D-T * BSET D,D
dc.w $192A,$01C0,1,Dmv-T * BSET D,mv
dc.w $192A,$08C0,3,G_D-T * BSET #x,D   x stets als word verwende!
dc.w $192A,$08C0,1,G_mv-T *BSET #x,mv
dc.w $1A9A,$0100,3,D_D-T * BTST D,D
dc.w $1A9A,$0100,1,Dmv-T * BTST D,mv
dc.w $1A9A,$0800,3,G_D-T * BTST #x,D   x stets als word verwende!
dc.w $1A9A,$0800,1,G_mv-T *BTST #x,mv
dc.w $2111,$54C8,2,D_l-T * DBCC D,label
dc.w $2119,$55C8,2,D_l-T * DBCS D,label
dc.w $2128,$57C8,2,D_l-T * DBEQ D,label
dc.w $2132,$5CC8,2,D_l-T * DBGE D,label
dc.w $213A,$5EC8,2,D_l-T * DBGT D,label
dc.w $2144,$52C8,2,D_l-T * DBHI D,label
dc.w $2149,$54C8,2,D_l-T * DBHS D,label hs=cc
dc.w $2162,$5FC8,2,D_l-T * DBLE D,label
dc.w $2164,$5BC8,2,D_l-T * DBMI D,label
dc.w $2167,$55C8,2,D_l-T * DBLO D,label lo=cs
dc.w $2169,$53C8,2,D_l-T * DBLS D,label
dc.w $216A,$5DC8,2,D_l-T * DBLT D,label
dc.w $2172,$56C8,2,D_l-T * DBNE D,label
dc.w $2186,$5AC8,2,D_l-T * DBPL D,label
dc.w $2190,$51C8,2,D_l-T * DBRA D,label
dc.w $21B1,$58C8,2,D_l-T * DBVC D,label
dc.w $21B9,$59C8,2,D_l-T * DBVS D,label
dc.w $24B9,$81C0,2,d_D-T * DIVS d,D
dc.w $24BA,$80C0,2,d_D-T * DIVU d,D
dc.w $2794,$0A7C,2,G_SR-T *EORI #x,SR  x als word verwenden
dc.w $2794,$0A3C,2,GCCR-T *EORI #x,CCR
dc.w $2794,$0A00,0,F_vd-T *EORI #x,vd
dc.w $4606,$4AFC,7,0     * ILLEGAL
dc.w $6475,$4E50,3,A_F-T * Link A, #x
dc.w $6720,$3040,2,u_A-T * MOVEA  u,A
dc.w $6720,$2040,3,u_A-T * MOVEA.L u,A
dc.w $6726,$4880,2,lis_-T    * MOVEM  RListe,vk oder MOVEM RListe,-(A)
dc.w $6726,$48C0,3,lis_-T    * MOVEM.L RList,vk odr MOVEM.L RList,-(A)
dc.w $6726,$4C98,2,KPL_lis-T * MOVEM   (A)+,RegListe
dc.w $6726,$4CD8,3,KPL_lis-T * MOVEM.L (A)+,RegListe
dc.w $6726,$4C80,2,k_lis-T   * MOVEM   k,RListe
dc.w $6726,$4CC0,3,k_lis-T   * MOVEM.L k,RListe
dc.w $6728,$7000,3,F8_D-T * MOVEQ #x,D  x muû in 8 bit passen
dc.w $6728,$0188,2,DXXA-T * MOVEP  D,xx(A)
dc.w $6728,$01C8,3,DXXA-T * MOVEP.L D,xx(A)
dc.w $6728,$0108,2,XXAD-T * MOVEP  xx(A),D
dc.w $6728,$0148,3,XXAD-T * MOVEP.L xx(A),D
dc.w $67B2,$42C0,2,CCR_vd-T * MOVE CCR,vd
dc.w $67B2,$40C0,2,SR_vd-T  * MOVE SR,vd
dc.w $67B2,$4E68,3,USPA-T * MOVE USP,A
dc.w $67B2,$4E60,3,AUSP-T * MOVE A, USP
dc.w $67B2,$3040,2,u_A-T  * MOVE  u,A
dc.w $67B2,$2040,3,u_A-T  * MOVE.L u,A
dc.w $67B2,$44C0,2,d_CCR-T *MOVE d,CCR
dc.w $67B2,$46C0,2,d_SR-T  *MOVE d,SR
dc.w $67B2,$0000,4,u_D-T  * MOVE u,D
dc.w $67B2,$0080,4,u_KLA-T *MOVE u,(A)
dc.w $67B2,$00C0,4,u_KPL-T *MOVE u,(A)+
dc.w $67B2,$0100,4,u_MIK-T *MOVE u,-(A)
dc.w $67B2,$0140,4,uXXA-T * MOVE u,xx(A)
dc.w $67B2,$0180,4,uXAR-T * MOVE u,x(A,R)
dc.w $67B2,$03C0,4,u_abs-T *MOVE u,xxxx
dc.w $6A69,$C1C0,2,d_D-T  * MULS d,D
dc.w $6A6A,$C0C0,2,d_D-T  * MULU d,D
dc.w $7112,$4800,1,vd-T   * NBCD vd
dc.w $723C,$4000,0,vd-T   * NEGX vd
dc.w $9112,$8100,1,DDD-T  * SBCD D,D      quelle in _2_1_0
dc.w $9112,$8108,1,MIMI-T * SBCD -(A),-(A)
dc.w $922A,$4E70,7,0      * RESET
dc.w $97C6,$E130,0,D_D-T  * ROXL D, D
dc.w $97C6,$E110,0,F3_D-T * ROXL #x,D   x muû in drei bit reinpassen
dc.w $97C6,$E5C0,2,vd-T   * ROXL vd
dc.w $97C9,$E030,0,D_D-T  * ROXR D, D
dc.w $97C9,$E010,0,F3_D-T * ROXR #x,D   x muû in drei bit reinpassen
dc.w $97C9,$E4C0,2,vd-T   * ROXR vd
dc.w $9A10,$90C0,2,u_A-T  * SUBA  u,A
dc.w $9A10,$91C0,3,u_A-T  * SUBA.L u,A
dc.w $9A14,$0400,0,F_vd-T * SUBI  #x,vd
dc.w $9A18,$5148,2,F3_A-T * SUBQ  #x,A  x muû in drei bit passen
dc.w $9A18,$5188,3,F3_A-T * SUBQ  #x,A  x muû in drei bit passen
dc.w $9A18,$5100,0,F3_vd-T *SUBQ #x,vd  x muû in drei bit passen
dc.w $9A1C,$9100,0,DDD-T  * SUBX  D, D    quelle in _2_1_0
dc.w $9A1C,$9180,0,MIMI-T * SUBX -(A),-(A)
dc.w $9A78,$4E72,7,nurG-T * STOP #x   x belegt auf jeden Fall ein Word.
dc.w $9B08,$4840,2,NURD-T * SWAP D
dc.w $A765,$4E58,3,NURA-T * UNLK A
dc.w $A908,$4E40,7,nurF4-T *TRAP #x  x muû in 4 bit passen
dc.w $A98B,$4E76,7,0      * TRAPV
NACHLZCO:
dc.w -1  * Tabellen-Ende
WGBLS:
dc.w $0169,$6300,7,lab-T,-1  * BLS label
WGCLR:
dc.w $0169,$4200,0,vd-T,-1   * CLR vd
WGRTR:
dc.w $09A9,$4E77,7,0,-1  * RTR
WGRTS:
dc.w $09A9,$4E75,7,0,-1  * RTS


* im folgenden die ca 50 INNER SUBROUTINES,
*
* jede prÅft  ob eine bestimmte Kombination von 1stOperand,2ndOperand
* vorliegt  beispielsweise Dj,Ai oder USP,Ai etc pp.
*
* gib flag mi, wenn Op nicht stimmen. sonst gib D2=oderierMaske und
*  D0=info, ob noch mehr zu beachten (zB. "Zahl_folgt" usw)
* gib D0_bits so, daû sie im HiByte folgendes aussagen:
* 0= keine Zahlenwerte aus erstem Op.
* 1= der ertseOp erfordert, daû ein word des Typus x(A,R) anhÑngt.
* 2= 1stOp will, daû ein word des Typus xx(A) anhÑngt
* 10= will, daû absAdr.L folgt, wobei im effAdrFeld bit0 gelîscht werden
*         darf, um doch shortAdr (also absAdr.w) zu verwenden.
* 4= daû word des xx(PC)-Typs anhÑngen muû.
* 5= daû word des LABEL-Typs ahÑngt, wobei statt des words auch das untre
*         Byte des iCodes selbst verwendet werden darf,wenn -$80<lab<$7F.
* 6= daû word des LABEL-Typs anhÑngen muû.
* 3= daû word des Typs x(pc,R) folgt.
*
* 9 daû #wert.BWL folgen muû, abhÑngig von der instruction-Extension
* 10 daû #wert.w folgt ohne Kontrolle, ob angegebne Zahl grîûer als 16bit.
* 11 daû #wert 0..15 unten in instrCode einzufÅgen
* 12 daû #wert 1..8 in instrCode bits _11_10_9 einzufÅgen
* 13 daû #wert -$80..$FF folgn muû, der ins untre instrCodeByte einzufÅg.
*
* 15 daû D1.w an instrCode anzuhÑngen
*
* im LowByte von D0 desgleichen fÅr den zweiten Operanden.
*
* Auch ganze Teilmengen von Operanden werden abgefragt, nÑmlich
* u= universeller effAdr_Operand (=alles,was ins effektivadr-Feld paût).
* d= daten=    u ohne AdrRegDirekt.
* m= memory=    d ohne DatRegDirekt.
* k= kontrl=     m ohne #Wert und ohne (A)+ und ohne -(A).
* v= verÑnderbar= u ohne #Wert und ohne xx(PC) und ohne x(PC,R).
* Im folgenden meint beispielsweise "vd" die Schnittmenge aus v und d.


lis_:
*subroutine wÅnscht ab a0 die OpKombi `RegListe,vk` oder `RLis,-(A)`
* gib D2= Maske fÅrs effAdr-Feld. gib D1= 16BitCode der Liste. D0=F00

 BSR  PRUEFLIS
 BNE  NIXlis_
 BCC  NIXlis_
 MOVEM.L D1/A0,-(A7)
 LEA  (A1), A0
 MOVEQ #0,  D2

 BSR PRUEFKLA  Typ (A) ?
 BEQ vk2KLA
 BSR PRUEFMIK -(A) ?
 BEQ vk2MIK
 BSR PRUEFOTH Term vornweg?
 BNE NIXvk2   ne= kein Term
 BMI NIXvk2   mi= #Wert
 BVC vk2ABS   vs= KlammerAuf folgt
 BSR PRUEFXXA
 BEQ vk2XXA
 BSR PRUEFXAR
 BNE NIXvk2   eq= Typus x(Ai,Rj)
 OR.B D1, D2  so kommt die RegNummer ins effAdr-feld
 OR.B #$30,D2  und so der ModusCode
 MOVE #$F01,D0  zeige,daû word des x(A,R)-Typus folgen muû
 BRA  Rvk2
vk2XXA:
 OR.B D1, D2  so kommt die RegNummer ins effAdr-feld
 OR.B #$28,D2  und so der ModusCode fÅr xx(A)-Typen
 MOVE #$F02,D0  zeige,daû ein word des xx(A)-Typus folgen muû
 BRA  Rvk2
vk2ABS:
 OR.B #$39,D2   Code fÅr absAdr Long
 MOVE #$F08, D0 zeige,daû word und absAdr folgen muû
 BRA  Rvk2
NIXvk2:
 ORI  #8,  CCR  mi-flag: das war nix.
 BRA  Rvk2
vk2MIK:
 MOVEM.L (A7)+,D0/A1  um in D0 die Listenbits zu kriegen zwecks umdrehen
 MOVEM D1/D2,-(A7)
 MOVEQ #15,D2
NOC2MIK:
 ROXL #1,D0
 ROXR #1,D1
 DBRA D2,NOC2MIK  16mal bits aus D0 verkehrtherum in D1 reinschieben
 MOVE D1,D0
 MOVEM (A7)+,D1/D2
 MOVEM.L D0/A1,-(A7)
 MOVEQ #$20,D0  diese bits zeigen Typus -(A) an.
 BRA  vk2NOCR
vk2KLA:
 MOVEQ #$10,D0  die bits des ModusCodes, die (A)-Typ anzeigen.
vk2NOCR:
 OR.B D1,D2  so kommt die RegisterNummer ins effAdr-Feld
 OR.B D0,D2  und so der ModusCode.
ROvk2:
 MOVE #$F00,D0  pl=OK
Rvk2:
 MOVEM.L (A7)+,D1/A0
 RTS
NIXlis_:
 MOVEQ #-1, D0  mi
 RTS

k_lis:
*subroutine will a0 zeigend OpKombi `k,RegListe`
 BSR  OBVORNdk
 BNE  NIXlis_
 BCC  NIXlis_
 MOVEM.L D2/A0,-(A7)  effAdrMaske in D2
 LEA  (A1), A0
 BSR  PRUEFLIS        gib D1= 16bitCode der RegListe
 MOVEM.L (A7)+,D2/A0  effAdrMaske in D2
 BNE  NIXlis_
 MOVE D1,-(A7)
 BSR  EVTLZAHL
 MOVE (A7)+,D1
 LSL  #8,  D0  codierung, ob erster Operand eine Zahl nach instCode braucht
 OR.B #$F, D0  code, daû zweiter Op das D1.w als Zahl nach instruction will
RTS

KPL_lis:
*subroutine will a0 zeigend OpKombi `(A)+,RegListe`
 BSR  PRUEFKPL
 BNE  NIXlis_
 BCC  NIXlis_
 MOVEM.L D1/A0,-(A7)  bisher RegNummer in D1
 LEA  (A1), A0
 BSR  PRUEFLIS          gib D1= 16bitCode der RegListe
 MOVEM.L (A7)+,D2/A0  nun RegNummer in D2
 BNE  NIXlis_
 MOVEQ #$F,D0  code, daû zweiter Op das D1.w als Zahl nach instruction will
RTS

nurk:
 BSR OBVORNdk
 BNE NIXlis_
 BCS NIXlis_
 BSR  EVTLZAHL gib zugehîrgen SchlÅssl in D0, ob dem instrCode Zahl folgt
 LSL.W #8,D0   die SchlÅsselZahl betrifft den erstn (hier: einzgen) Oprand.
 MOVE #0, CCR
RTS


MIMI:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf -(Ai),-(Aj).
* gib D2 bit_2_1_0=i bit_11_10_9=j

 MOVE.L A0,-(A7)
 BSR   PRUEFMIK  ne oder cc: ertser Op schon anders. sonst a1 zeig zweiten
 BCC  NIXMIMI
 BNE  NIXMIMI
 LEA (A1), A0  also zweiten Operanden auch prÅfen
 MOVE D1,  D2  zuvor Nummer des ersten AdReg merken
 BSR  PRUEFMIK
MIWIEPL:
 BNE  NIXMIMI  eq: OpKombination stimmt: -(Ai)+,-(Aj)+  mit i=D2 j=D1
 ADD   D1, D1
 LSL   #8, D1  Nummer des zweitenAdReg in die bits _11_10_9
 MOVE.B D2,D1  und die erste Numemr in die bits _2_1_0.
 MOVE  D1, D2
 MOVEQ #0, D0  Zeig,daû nur D2_Maske zu verwenden (keine sonstigen Zahlen)
 BRA  RMIMI
NIXMIMI:
 MOVEQ #-1,D0  melde,daû Operanden nicht so, wie erwartet.
RMIMI:
 MOVE.L (A7)+,A0
 RTS


PLPL:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf (Ai)+,(Aj)+.
* gib D2 bit_2_1_0=i bit_11_10_9=j

 MOVE.L A0,-(A7)
 BSR   PRUEFKPL  ne oder cc: ertser Op schon nix. sonst a1 zeig zweiten
 BCC  NIXMIMI
 BNE  NIXMIMI
 LEA (A1), A0  also zweiten Operanden auch prÅfen
 MOVE D1,  D2  zuvor Nummer des ersten AdReg merken
 BSR  PRUEFKPL
 BRA  MIWIEPL

D_l:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf Di,LABEL
* gib D2 bit_2_1_0=i, D0=#6 (weil word des labelTyps folgen muû)
 MOVE.L A0,-(A7)
 BSR   PRUEFD  ne oder cc: ertser Op kein DReg oder kein Komma dahinter
 BCC  NIXD_D
 BNE  NIXD_D
 MOVE D1,D2
 LEA (A1),A0
 BSR  PRUEFOTH
 BNE  NIXD_D
 MOVE.L (A7)+,A0
 MOVEQ #6,D0
 RTS

DDD:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf Di,Dj.
* gib D2 bit_2_1_0=i bit_11_10_9=j
 BSR D_D
 BMI rDDD
 ROL #1,D2
 ROL #8,D2 
 LSR.B #2,D2 so richtige BitPositionen und flag pl
rDDD:
 RTS

A_A:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf Ai,Aj.
* gib D2 bit_2_1_0=j bit_11_10_9=i
 MOVE.L A0,-(A7)
 BSR   PRUEFA   ne oder cc: ertser Op schon nix. sonst a1 zeig zweiten
A_AWEITR:
 BCC  NIXD_D
 BNE  NIXD_D
 LEA (A1), A0  also zweiten Operanden auch prÅfen
 MOVE D1,  D2  zuvor Nummer des ersten Reg merken
 BSR PRUEFA
DWIEA:
 BNE  NIXD_D  eq: OpKombination stimmt: Ri,Rj  mit i in D2, j in D1
DW2A:
 ADD   D2, D2
 LSL   #8, D2  Nummer des erstenReg in die bits _11_10_9
 MOVE.B D1,D2  und die zweite Numemr in die bits _2_1_0.
 MOVEQ #0, D0  Zeig,daû nur D2_Maske zu verwenden (keine sonstigen Op)
 BRA  RD_D
NIXD_D:
 MOVEQ #-1,D0  melde,daû Operanden nicht so, wie erwartet.
RD_D:
 MOVE.L (A7)+,A0
 RTS

D_D:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf Di,Dj.
* gib D2 bit_2_1_0=j bit_11_10_9=i
 MOVE.L A0,-(A7)
 BSR   PRUEFD  ne oder cc: ertser Op schon anders. sonst a1 zeig zweiten
D_DWEITR:
 BCC  NIXD_D
 BNE  NIXD_D
 LEA (A1), A0  also zweiten Operanden auch prÅfen
 MOVE D1,  D2  zuvor Nummer des ersten Reg merken
 BSR PRUEFD
 BRA DWIEA

D_A:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf Di,Aj.
* gib D2 bit_2_1_0=j bit_11_10_9=i
 MOVE.L A0,-(A7)
 BSR    PRUEFD   ne oder cc: ertser Op schon nix. sonst a1 zeig zweiten
 BRA   A_AWEITR

A_D:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf Ai,Dj.
* gib D2 bit_2_1_0=i bit_11_10_9=j
 MOVE.L A0,-(A7)
 BSR   PRUEFA   ne oder cc: ertser Op schon nix. sonst a1 zeig zweiten
 BCC  NIXD_D
 BNE  NIXD_D
 LEA (A1), A0  also zweiten Operanden auch prÅfen
 MOVE D1,  D2  zuvor Nummer des ersten Reg merken
 BSR  PRUEFD
 BNE  NIXD_D  eq: OpKombination stimmt: Ri,Rj  mit i in D2, j in D1
 EXG  D1, D2  damit diesmal erste Nummer (=i) in unterste bits gelangt
 BRA  DW2A


XXAD:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf xx(Ai),Dj.
* gib D2 bit_2_1_0=i bit_11_10_9=j
 MOVE.L A0,-(A7)
 BSR    PRUEFXXA   ne oder cc: ertser Op schon nix. sonst a1 zeig zweiten
 BNE   NIXD_D
 BCC  NIXD_D
 LEA (A1), A0
 MOVE D1,  D2  RegNummer des ersten Operanden merken und
 BSR  PRUEFD   zweiten prÅfen. dessen Nummer in D1, falls es ihn gibt.
 BNE  NIXD_D
 ADD   D1, D1
 LSL   #8, D1  Nummer des zweitenReg in die bits _11_10_9
 MOVE.B D2,D1  und die erste Numemr in die bits _2_1_0.
 MOVE  D1, D2
 MOVE #$200,D0  Zeig,daû word des xx(A)-Typus im erstnOp folgt
 BRA   RD_D

DXXA:
*subroutine will a0 zeigend 1stOperand. PrÅft OpKombination auf Di,xx(Aj).
* gib D2 bit_2_1_0=j bit_11_10_9=i
 BSR NURD
 BMI NIXNUR
 MOVE.L A0,-(A7)
 BSR PRUEFXXA      ne: Op is nix.
 BNE NIXD_D                          dort auch (A7)++ !!
 ADD   D2, D2
 LSL   #8, D2 ersteRegNr in _11_10_9
 MOVE.B D1,D2 zweiteNr in bits _2_1_0.
 MOVEQ #2, D0 Zeig,daû word des xx(A)-Typus im zweitenOp folgt
 BRA  RD_D


NURD:
*subroutine wÅnscht sich ab a0 string `D1` oder `D2` ... oder `D7`
* gib flag mi, wenn nicht so, sonst
* gib in untersten drei bits von D2 (und D1) die RegNummer
 BSR PRUEFD
NDWIENA:
 BNE NIXNUR
NUR0:
 MOVEQ #0,D2
 OR.B  D1,D2
 MOVEQ #0,D0
 RTS
NIXNUR:
 MOVEQ #-1,D0
 RTS

NURA:
*subroutine wÅnscht sich ab a0 string `A1` oder `A2` ... oder `A7`
* gib flag mi, wenn nicht so, sonst
* gib in untersten drei bits von D2 die RegNummer
 BSR PRUEFA
 BRA NDWIENA

USPA:
*subroutine guckt, ob Operanden  USP,A0 oder USP,A1 ... oder USP,A7
* gib flag mi, wenn nicht so, sonst
* gib in untersten drei bits von D2 die RegNummer
 BSR PRUEFUSP
 BNE NIXNUR
 BCC NIXNUR
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR NURA
 MOVE.L (A7)+,A0
 RTS

AUSP:
*subroutine guckt, ob Operanden  A0,USP oder A1,USP ... oder A7,USP
* gib flag mi, wenn nicht so, sonst
* gib in untersten drei bits von D2 die RegNummer
 BSR NURA
 BMI NIXNUR
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR PRUEFUSP
 MOVE.L (A7)+,A0
 BNE NIXNUR
 MOVEQ #0,D0
 RTS

A_F:
*subroutine guckt, ob Operanden  A0,# oder A1,# ... oder A7,#
* gib flag mi, wenn nicht so, sonst
* gib in untersten drei bits von D2 die RegNummer und D0=7, das
* heiût, daû #.w folgt und auf 16bit kontrolliert wird
 BSR NURA
 BMI NIXNUR
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR PRUEFOTH
 MOVE.L (A7)+,A0
 BNE NIXNUR
 BPL NIXNUR  denn dann fehlts #
 MOVEQ #7,D0
 RTS

nurG:
*subroutine hofft, daû nur #wert als Operand folgt, sonst flag mi
 BSR PRUEFOTH
 BNE NIXNUR
 BPL NIXNUR denn # fehlt
 MOVE #$800,D0 zeichen,daû word anzuhÑngen,ohne Kontrolle ob zahl paût.
 MOVEQ #0, D2
 RTS

Dmv:
*subroutine testet ab a0 auf OpKombination Di,y mit y=memory&verÑnderbar
 BSR PRUEFD   ne oder cc: ertser Op schon anders. sonst a1 zeig zweiten
 BCC NIXD_mv
 BNE NIXD_mv
 MOVE D1, D2  Nummer des ersten DatReg merken
 ADD D2, D2
 LSL #8, D2  und bereits auf den richtigen MaskenBits
 MOVEQ #0,D0
 BRA mv2
NIXD_mv:
 MOVEQ #-1,D0  melde,daû Operanden nicht so, wie erwartet.
 RTS

G_mv:
*subroutine erhofft ab a0 `#wert,y` mit y=memory&verÑnderbar
 BSR PRUEFOTH
 BNE NIXD_mv
 BPL NIXD_mv denn dann fehlts #
 BCC NIXD_mv    denn dann fehlts Komma
 MOVE.W #$800,D0 ersterOp verlangt #word (aber keine Grîûenkontrolle)
 MOVEQ #0,D2
* BRA mv2

mv2:
*subr-Ende, gemeinsame MÅndung einiger INNER SUBROUTINES. in D2 sind
* bereits die bits des ersten Operanden gesetzt, aber die bits0..5 sind
* noch frei, denn hier schreibt mv2 sein eaffAdr-Ergebnis; in D0_HiByte sind bereits
* HinweisBits,was auûer der D2Maske erwartet wird. nun soll noch der zweite
* Op darauf untersucht werden, ob er "memory&verÑnderbar" ist.
*  will A1 zeigend zweiten Op.
* gib flag mi= war nix, wenn kein mvOperand vorliegt. sonst:
* gib D0_bits so, daû sie im HiByte folgendes aussagen:
* 0= keine Zahlenwerte aus erstem Op.
* 1= der ertseOp erfordert, daû ein word des Typus x(A,R) anhÑngt.
* 2= 1stOp will, daû ein word des Typus xx(A) anhÑngt
*  etc, s.o. allgemeine Beschreibung der INNER SUBROUTINES
* im LowByte von D0 desgleichen fÅr den zweiten Operanden.

 MOVE.L A0,-(A7) string merken
 MOVE  D0,-(A7)  in HiByte HinweisBits (Anforderungen des erste Op) merken
 LEA  (A1), A0  string des zweiten Op
vdwiemv:
 BSR PRUEFKLA  Typ (A) ?
 BEQ mv2KLA
 BSR PRUEFKPL  (A)+ ?
 BEQ mv2KPL
 BSR PRUEFMIK -(A) ?
 BEQ mv2MIK
 BSR PRUEFOTH Term vornweg?
 BNE NIXmv2   ne= kein Term
 BMI NIXmv2   mi= #Wert
 BVC mv2ABS   vs= KlammerAuf folgt
 BSR PRUEFXXA
 BEQ mv2XXA
 BSR PRUEFXAR
 BNE NIXmv2   eq= Typus x(Ai,Rj)
 OR.B D1, D2  so kommt die RegNummer ins effAdr-feld
 OR.B #$30,D2  und so der ModusCode
 MOVE (A7)+,D0
 OR.B #1,  D0  zeige,daû word des x(A,R)-Typus folgen muû
 BRA  ROmv2
mv2XXA:
 OR.B D1, D2  so kommt die RegNummer ins effAdr-feld
 OR.B #$28,D2  und so der ModusCode fÅr xx(A)-Typen
 MOVE (A7)+,D0
 OR.B #2,  D0  zeige,daû ein word des xx(A)-Typus folgen muû
 BRA  ROmv2
mv2ABS:
 OR.B #$39,D2  Code fÅr absAdr Long
 MOVE (A7)+,D0
 OR.B #10, D0  zeige,daû absAdr folgen muû
 BRA  ROmv2
NIXmv2:
 MOVE (A7)+,D0
 ORI  #8,  CCR  mi-flag: das war nix.
 BRA  Rmv2
mv2KLA:
 MOVEQ #$10,D0  die bits des ModusCodes, die (A)-Typ anzeigen.
 BRA  mv2NOCR
mv2KPL:
 MOVEQ #$18,D0  diese bits zeigen Typus (A)+
 BRA  mv2NOCR
mv2MIK:
 MOVEQ #$20,D0  diese zeigen Typus -(A).
mv2NOCR:
 OR.B D1,D2  so kommt die RegisterNummer ins effAdr-Feld
 OR.B D0,D2  und so der ModusCode.
RLmv2:
 MOVE (A7)+,D0   in diesem Fall keine Zahlenwerte fÅrn zweiten Op.
ROmv2:
 ANDI  #$F7,CCR  pl=OK
Rmv2:
 MOVE.L (A7)+,A0
 RTS

nurF4:
*subroutine hofft auf #wert zwi 1 und 8, diesen in
*bits _11_10_9 des instrCode zu packen. sonst flag mi.
 BSR PRUEFOTH
 BNE NID
 BPL NID denn # fehlt
 MOVE #$B00,D0 zeichen,daû 3bitCode in instrCode einzufÅgen
 MOVEQ #0,D2
 RTS

D_vd:
*subroutine testet ab a0 auf OpKombination Di,y mit y=verÑnderbareDaten
 BSR  PRUEFD   ne oder cc: ertser Op schon anders. sonst a1 zeig zweiten
 BCC  NID
 BNE  NID
 MOVE D1, D2  Nummer des ersten DatReg merken
 ADD  D2, D2
 LSL  #8, D2  und bereits auf den richtigen MaskenBits
 MOVEQ #0,D0
 BRA  vd2
NID:
 MOVEQ #-1,D0  melde,daû Operanden nicht so, wie erwartet.
 RTS

F3_vd:
*subroutine wÅnscht OpKombi `#x,vd` mit x=1..8
 BSR PRUEFOTH
 BNE NID
 BPL NID denn # fehlt vorn
 BCC NID denn Komma fehlt hinten
 MOVE #$C00,D0 zeichen,daû 3bit in instrCode reinmÅssen
 BRA  vd20

F_vd:
*subroutine hofft, daû nur `#wert,vd` als Operanden folgen, sonst flag mi
 BSR PRUEFOTH
 BNE NID
 BPL NID denn # fehlt
 BCC NID
 MOVE #$900,D0 zeichen,daû was anzuhÑngen, je nach .B odr .w oder .L
 BRA  vd20

vd:
*subroutine wÅnscht nur einen Operanden, der muû verÑndrbar&daten sein
 MOVEQ #0,D0
 MOVEQ #0,D2
 LEA (A0),A1
 BSR vd2
 BMI ZRvd
 LSL #8,D0  weil vd2 so tat, als obs den zweiten Operanden untersuchte.
 CLR.B  D0  flag pl
ZRvd:
 RTS

SR_vd:
*subroutine wÅnscht OperandenKombi SR,y mit y=verÑndrb&daten
 BSR PRUEFSR
 BRA CCRwieSR

CCR_vd:
*subroutine wÅnscht OperandenKombi CCR,y mit y=verÑndrb&daten
 BSR PRUEFCCR
CCRwieSR:
 BNE NID
 MOVEQ #0,D0
vd20:
 MOVEQ #0,D2

vd2:
*subr-Ende, gemeinsame MÅndung einiger INNER SUBROUTINES. in D2 sind
* bereits die bits des ersten Operanden gesetzt, aber die bits0..5 sind
* noch frei, denn hier schreibt vd2 sein eaffAdr-Ergebnis; in D0_HiByte sind bereits
* HinweisBits,was auûer der D2Maske erwartet wird. nun soll noch der zweite
* Op darauf untersucht werden, ob er "verÑnderbar&daten" ist.
*  will A1 zeigend zweiten Op.
* gib flag mi= war nix, wenn kein mvOperand vorliegt. sonst:
* gib D0_bits so, daû sie im LoByte folgendes aussagen:
* 0= keine Zahlenwerte aus erstem Op.
* 1= der ertseOp erfordert, daû ein word des Typus x(A,R) anhÑngt.
* 2= 1stOp will, daû ein word des Typus xx(A) anhÑngt
*  etc, s.o. allgemeine Beschreibung der INNER SUBROUTINES

 MOVE.L A0,-(A7) string merken
 MOVE  D0,-(A7)  in HiByte HinweisBits (Anforderungen des erste Op) merken
 LEA  (A1), A0  string des zweiten Op
 BSR PRUEFD
 BNE vdwiemv  eq= DatReg folgt
 MOVEQ #0,D0  so zeigen _5_4_3 (bits des ModusCodes) D-Typ an.
 BRA  mv2NOCR

G_SR:
*subroutine wÅnscht `#x,SR`, reserviert word fÅr zahl, egal wie lang x ist.
 BSR PRUEFOTH
 BNE NIFD
 BPL NIFD denn dann fehlts #
 BCC NIFD denn dann fehlts Komma
 MOVE.L A0,-(A7) 
 LEA (A1),A0
 BSR PRUEFSR
 MOVE.L (A7)+,A0
 BNE NIFD
 MOVE #$800,D0 ersterOp verlangt #word (aber keine Grîûenkontrolle)
 MOVEQ #0, D2
RTS

GCCR:
*subroutine wÅnscht `#x,CCR`, reserviert word fÅr zahl, egal wie lang x ist.
 BSR PRUEFOTH
 BNE NIFD
 BPL NIFD denn dann fehlts #
 BCC NIFD denn dann fehlts Komma
 MOVE.L A0,-(A7) 
 LEA (A1),A0
 BSR PRUEFCCR
 MOVE.L (A7)+,A0
 BNE NIFD
 MOVE #$800,D0 ersterOp verlangt #word (aber keine Grîûenkontrolle)
 MOVEQ #0, D2
RTS

lab:
*subroutine ÅberprÅft ab a0 auf LABEL-Typus
 BSR PRUEFOTH
 BNE NIFD
 MOVE #$500,D0  zeichn fÅr LABEL-Typ,der in der Kurzform auch in iCode darf.
 MOVEQ #0,D2
 RTS

G_D:
*subroutine wÅnscht `#x,D`, reserviert word fÅr zahl, egal wie lang x ist.
 BSR PRUEFOTH
 BNE NIFD
 BPL NIFD denn dann fehlts #
 BCC NIFD  denn dann fehlts Komma
 MOVE #$800,D0 ersterOp verlangt #word (aber keine Grîûenkontrolle)
 BRA dannD
NIFD:
 MOVEQ #-1,D0
 RTS

F3_D:
*subroutine wÅnscht OpKombi `#x,D` mit x=1..8
 BSR PRUEFOTH
 BNE NIFD
 BPL NIFD denn # fehlt vorn
 BCC NIFD denn Komma fehlt hinten
 MOVE #$C00,D0 zeichen,daû 3bit in instrCode reinmÅssen
dannD:
 MOVE.L A0,-(A7)
 MOVE  D0,-(A7)
 LEA  (A1), A0
 BSR  PRUEFD
danDwA:
 BNE  NIDD
 MOVE D1, D2  Nummer des Reg.
 MOVE (A7)+,D0
 MOVE.L (A7)+,A0
 RTS

F8_D:
*subroutine wÅnscht OpKombi `#x,D` mit x=-$80..$FF
 BSR PRUEFOTH
 BNE NIFD
 BPL NIFD denn # fehlt
 BCC NIFD denn Komma fehlt
 MOVE #$D00,D0 zeichen,daû 8bit in instrCode reinmÅssen
 MOVE.L A0,-(A7)
 MOVE  D0,-(A7)
 LEA  (A1), A0
 BSR  PRUEFD
 BNE  NIDD
 MOVE D1, D2  Nummer des DatReg..
 ADD  D2, D2
 LSL  #8, D2  auf die richtigen MaskenBits schieben
 MOVE (A7)+,D0
 MOVE.L (A7)+,A0
 RTS
NIDD:
 MOVE (A7)+,D0
 MOVE.L (A7)+,A0
 BRA   NIFD

F3_A:
*subroutine wÅnscht OpKombi `#x,A` mit x=1..8
 BSR PRUEFOTH
 BNE NIFD
 BPL NIFD denn # fehlt vorn
 BCC NIFD denn Komma fehlt hinten
 MOVE #$C00,D0 zeichen,daû 3bit in instrCode reinmÅssen
 MOVE.L A0,-(A7)
 MOVE  D0,-(A7)
 LEA  (A1), A0
 BSR  PRUEFA
 BRA danDwA

OBVORNu:
*subroutine, die von einigen INNER SUBROUTINES zu Anfang aufgerufen wird.
*prÅft, ob a0 auf einen Operanden des univers-effAdr-Typs zeigt,
* also       D       A       (A)+  -(A)   #wert
* oder   (A)   xx(A)   x(A,R)   abs   xx(PC)   x(PC,R).
*
* gibt flag ne, wenns sowas nicht sein kann. Ansonsonsten:
*  gib D2=maske (fÅr Bits des effAdr-felds) je nach Operand,
* wenn ok & Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
*
 BSR PRUEFA
 BNE OBVORNd
* also gehts um ein AdrReg, also darfs keine `.B-Extension` sein! prÅfsnach:
 LEA  (A0), A1
NOCPR:
 CMP.B #' ',-(A1)  zurÅck im Text, Blanks Åbergehen.
 BEQ  NOCPR
 CMP.B #'B',(A1)
 BEQ  ERRVORNA
 CMP.B #'b',(A1)
 BEQ  ERRVORNA
 MOVEQ #8,D2   kennzeichne das effAdr-feld als "AdrReg-direkt"
OKVORNa:
 OR.B  D1,D2
 BRA  WIEOPEND  um A1 und flags wiederherzustellen
ERRVORNA:
 MOVEQ #-1,D0
 RTS

OBVORNd:
*subroutine, die von einigen INNER SUBROUTINES zu Anfang aufgerufen wird.
*prÅft, ob a0 auf einen Operanden des daten-Typs zeigt,
* also       D      (A)+    -(A)  #wert
* oder   (A)   xx(A)   x(A,R)   abs   xx(PC)   x(PC,R).
*
* gibt flag ne, wenns sowas nicht sein kann. Ansonsonsten:
*  gib D1=maske (fÅr Bits des effAdr-felds) je nach Operand,
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
*
 MOVEQ #0,D2   Typ DatReg
 BSR PRUEFD
 BEQ OKVORNa
 MOVEQ #$10,D2 Typ (A)
 BSR PRUEFKLA
 BEQ OKVORNa
 MOVEQ #$18,D2 kennzeichne Nummer als Typus (A)+
 BSR PRUEFKPL
 BEQ OKVORNa
 MOVEQ #$20,D2 kennzeichne Nummer als Typus -(A)
 BSR PRUEFMIK
 BEQ OKVORNa
 MOVEQ #$3C,D2
 BSR PRUEFOTH  Term?
 BNE OOVORNT   ne= kein Term  mi= #xx-Typus
 BPL OBVdk
OOVORNT:
 RTS

OBVORNdk:
*subroutine, die von vielen INNER SUBROUTINES zu Anfang aufgerufen wird.
*prÅft, ob a0 auf einen Operanden des dk-Typs zeigt,
* also   (A)   xx(A)   x(A,R)   abs   xx(PC)   x(PC,R).
*
* gibt flag ne, wenns sowas nicht sein kann. Ansonsonsten:
*  gib D1=maske (fÅr Bits des effAdr-felds) je nach Operand,
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
*
 MOVEQ #$10,D2
 BSR PRUEFKLA
 BEQ KLAdk
OBVdk:
 MOVEQ #$28,D2
 BSR PRUEFXXA
 BEQ XXAdk
 MOVEQ #$30,D2
 BSR PRUEFXAR
 BEQ XARdk
 MOVEQ #$3A,D2
 BSR PRUEFXXP
 BEQ XXPdk
 MOVEQ #$3B,D2
 BSR PRUEFXPR
 BEQ XPRdk
 MOVEQ #$39,D2
 BSR PRUEFOTH
 BEQ absdk
NOTdk:
 ANDI #$FB,CCR ne= kein dk-Typ (daten und zugleich kontroll-Typ)
 RTS
absdk:
 BMI NOTdk weil mit # beginnend
 RTS
KLAdk:
XXAdk:
XARdk:
 OR.B D1,D2    so modusbits im effAdr-Feld setzen
 BRA  WIEOPEND  wegen flags!
XXPdk:
XPRdk:
 RTS

uXXA:
*subroutine prÅft OpKombi `u,xx(A)`
 BSR OBVORNu
 BNE NIXUUU
 BCC NIXUUU
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR   PRUEFXXA
 MOVE.L (A7)+,A0
 BNE  NIXUUU
 ADD  D1, D1
 LSL  #8, D1  Nummer des Reg(ausZweitmOp) auf richtige Position
 OR   D1, D2  ..und reinin die oderier-Maske
 BSR  EVTLZAHL
 LSL   #8, D0   wenn dieseZahl an instCode, dann betriffts ersten Operanden.
 MOVE.B #2,D0      und diese Zahl vom xx(A)-Typ betrifft den zweiten Op.
 ANDI  #$F7,CCR pl
 RTS
NIXUUU:
 MOVEQ #-1,D0
 RTS

uXAR:
*subroutine prÅft OpKombi `u,x(A,R)`
 BSR OBVORNu
 BNE NIXUUU
 BCC NIXUUU
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR   PRUEFXAR
 MOVE.L (A7)+,A0
 BNE  NIXUUU
 ADD  D1, D1
 LSL  #8, D1  Nummer des Reg(ausZweitmOp) auf richtige Position
 OR   D1, D2  ..und reinin die oderier-Maske
 BSR  EVTLZAHL
 LSL   #8, D0   wenn dieseZahl an instCode, dann betriffts ersten Operanden.
 MOVE.B #1,D0      und diese Zahl vom x(A,R)-Typ betrifft den zweiten Op.
 ANDI  #$F7,CCR pl
 RTS

u_abs:
*subroutine prÅft OpKombi `u,abs`
 BSR OBVORNu
 BNE NIXUUU
 BCC NIXUUU
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR   PRUEFOTH
 MOVE.L (A7)+,A0
 BNE  NIXUUU    kein Term
 BVS  NIXUUU   Klammer folgt
 BMI  NIXUUU  # davor
 BSR  EVTLZAHL
 LSL   #8, D0   wenn dieseZahl an instCode, dann betriffts ersten Operanden.
 MOVE.B #10,D0 und diese Zahl vom absAdr-Typ betrifft den zweiten Op.
*             zugleich pl
 RTS

d_SR:
*subroutine prÅft OpKombi `d,SR`

 BSR OBVORNd
 BNE NIXUD
 BCC NIXUD
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR   PRUEFSR
 MOVE.L (A7)+,A0
 BRA   UAUA

d_CCR:
*subroutine prÅft OpKombi `d,CCR`

 BSR OBVORNd
 BNE NIXUD
 BCC NIXUD
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR   PRUEFCCR
 MOVE.L (A7)+,A0
UAUA:
 BNE   NIXUD
 BRA   AUAUAU

k_A:
*subroutine prÅft OpKombi `k,A`

 BSR OBVORNdk
 BNE NIXUD
 BCC NIXUD
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR  PRUEFA
 MOVE.L (A7)+,A0
 BRA uAwieuD

d_D:
*subroutine prÅft OpKombi `d,D`

 BSR OBVORNd
 BNE NIXUD
 BCC NIXUD
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR  PRUEFD
 MOVE.L (A7)+,A0
 BRA uAwieuD

u_KLA:
*subroutine prÅft OpKombi `u,(A)`

 BSR OBVORNu
 BNE NIXUD
 BCC NIXUD
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR  PRUEFKLA
 MOVE.L (A7)+,A0
 BRA uAwieuD

u_KPL:
*subroutine prÅft OpKombi `u,(A)+`

 BSR OBVORNu
 BNE NIXUD
 BCC NIXUD
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR  PRUEFKPL
 MOVE.L (A7)+,A0
 BRA uAwieuD

u_MIK:
*subroutine prÅft OpKombi `u,-(A)`

 BSR OBVORNu
 BNE NIXUD
 BCC NIXUD
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR  PRUEFMIK
 MOVE.L (A7)+,A0
 BRA uAwieuD

u_A:
*subroutine prÅft OpKombi `u,A`

 BSR OBVORNu
 BNE NIXUD
 BCC NIXUD
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR  PRUEFA
 MOVE.L (A7)+,A0
 BRA uAwieuD

u_D:
*subroutine prÅft OpKombi `u,D`

 BSR OBVORNu
 BNE NIXUD
 BCC NIXUD
 MOVE.L A0,-(A7)
 LEA   (A1), A0
 BSR  PRUEFD
 MOVE.L (A7)+,A0
uAwieuD:
 BNE  NIXUD
 ADD  D1, D1
 LSL  #8, D1  Nummer des DatReg(ausZweitmOp) auf richtige Position
 OR   D1, D2  ..und reinin die oderier-Maske
AUAUAU:
 BSR  EVTLZAHL
 LSL  #8, D0   wenn Zahl an instCode, dann betriffts ersten Operanden.
 ANDI #$F7,CCR pl
 RTS
NIXUD:
 MOVEQ #-1,D0
 RTS

EVTLZAHL:
*subroutine ÅberprÅft D2, obs im effAdr-feld einen code hat, der      ! D1
* eine Zahl zum instructionCode verlangt. Gib entsprechenden
* SchlÅssel in D0.B
 MOVEQ #0, D0  info Åber anzuhÑngende Zahlen zunÑchst auf `NIXanzuÑngen`
 MOVEQ #$38,D1
 AND   D2, D1
 CMP.B #$28,D1
 BLO   OKEVZ
 MOVEQ #2, D0  interner code fÅr xx(A)
 CMP.B #$28,D1
 BEQ   OKEVZ
 MOVEQ #1, D0  intern fÅr x(A,R)
 CMP.B #$30,D1
 BEQ   OKEVZ
 MOVEQ #$3F,D1
 AND   D2, D1
 MOVEQ #10,D0  intern fÅr abs.L, das auf .w gewandelt werden darf.
 CMP.B #$39,D1
 BEQ   OKEVZ
 MOVEQ #4, D0  fÅr xx(PC)
 CMP.B #$3A,D1
 BEQ   OKEVZ
 MOVEQ #3,D0  fÅr x(PX,R)
 CMP.B #$3B,D1
 BEQ   OKEVZ
 MOVEQ #9, D0  fÅr #wert abhÑngig von der .BWL-Extension
 CMP.B #$3C,D1
 BEQ   OKEVZ
 MOVEQ #-1,D0
OKEVZ:
 RTS


* im folgenden die OPERANDENPRöFER
*
* also die subroutines eines Assemblers, die einen string
* angucken, ob er eine bestimmte Sorte von Operand darstellt.
* Beim 68000 gehe ich von 15 Sorten aus:
* D A (A) (A)+ -(A) xx(A) x(A,R) absAdr xx(pc) x(pc,R)
* ccr sr usp Liste #Wert
* wobei jedes x oder xx oder absAdr oder #Wert
* eine Def-Anw oder Direktzahl sein darf oder ein Term, wobei
* Term= arithmetischer Ausdruck aus DefAnw und DirektZahlen.
*
* alle PRöFER gebn flag eq, wenn die ersten paar Bytes "ihrem" Operandentyp
* entsprechen und wenn dahinter Blank oder Tab oder cRet kommt odr Komma;
* bei letzteremzusÑtzlich a1 zeignd nÑc string und flags cs und vs.
*  meist auch:
* Wenns zwar soweit gestimmt hÑtte, aber was anderes als Blank-Tab-CRet-Komm
* folgt, dann gibts flags ne und vs und cc.
* Wenn schon der Typ nicht gestimmt hat, gibts ne und vc.


PRUEFOTH:
*subroutine will A0 zeigend Operanden (ersten character!)  prÅft obs was
* andres seinkann als D A (A) (A)+ -(A), also obs (vorneweg) ein Term ist,
* wobei Term= Zahl oder definierterName(Label/Equ) oder Mischmasch,
* verbunden mit mathZeichen wie + - * /.
* gibt flag ne, wenns sowas nicht sein kann. Ansonsonsten:
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
* wenn KlammrAuf dahinter: flag vs und A1 zeigend hinter Klammer.
* wenn mit # begonnen, also immediate-Wert: zusÑtzlich flag mi.
*  stets a1 zeigend hinter Term.

 CLR        -(A7)  dummy, weiter unten: hier flags rein
 MOVE.L A0, -(A7)

 MOVE.B (A0)+,D0
 CMP.B #'*', D0  solcher stringbeginn kennzeichnet Kommentar
 BEQ   ROTH
 CMP.B #'#', D0
 BNE   OTHABSAD
 ORI   #8, 4(A7) im lobByte flag (die im ccr =mi), daûTerm mit # beginnt.
WOTHNOST:
 MOVE.B (A0)+,D0
OTHABSAD:
 CMP.B #$27,D0  erstmal auf Hochkomma untersuchen, und
 BNE  HKOOK     evt flag im hiByte einrichten.
 BCHG #7,  4(A7)
 BRA  WOTHNOST
HKOOK:
 TST.B 4(A7)
 BPL  NOHOKOMM  solange innerhalb Hochkomma(mi): Blank & drÅber akzeptieren!
 CMP.B #' ',D0
 BHS  WOTHNOST
NOHOKOMM:
 CMP.B #',', D0
 BHI  WOTHNOST
 BEQ  OTHKOMM
 CMP.B #'+', D0  asciiCode unterhalb Komma: nur + ' * $ % akzeptieren!
 BEQ  WOTHNOST
 CMP.B #'*', D0
 BEQ  WOTHNOST
 CMP.B #'%', D0
 BEQ  WOTHNOST
 CMP.B #'$', D0
 BEQ  WOTHNOST  ne: diesZeichen gehîrt nicht mehr zum Term.
OTHOBK:
 CMP.B #'(', D0
 BEQ  OTHKLAA
 ORI  #4,  4(A7)  flag eq: es kînnte einTerm sein
 LEA  -1(A0),A1
 BRA  ROTH
OTHKLAA:
 LEA (A0), A1   zeig Zeichen hinter der Klammer
 ORI #6, 4(A7)  zwecks RÅckgabe mit flag eq und vs.
 BRA ROTH
OTHKOMM:
 LEA  (A0),A1   zeig ascii hinterm Komma
ONKNXS:
 CMP.B #' ',(A1)+ Blanks Åbergehen
 BEQ  ONKNXS
 CMP.B #9, -1(A1) ebenso Tab Åbergehen
 BEQ  ONKNXS
 SUBQ #1,   A1   zeigend nÑchsten string-Anfang
 OR   #5, 4(A7)  so RÅckgabe mit flag eq und cs.
* BRA  ROTH
ROTH:
 MOVE.L (A7)+,A0
 RTR

PRUEFXXA:
*subroutine will A0 zeigend Operanden (ersten character!) prÅft ob xx(A0..7)
* gibt flag ne, wenn nicht
* sonst D1= Nummer des AdrReg
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.

MOVE.L A0,-(A7)
 BSR   PRUEFOTH  gib a1 zeigend hinter klammr &vs,wenn Klammer hinterm Term
 BNE   NOXXA
 BVC   NOXXA
 CMP.B #')',2(A1)
 BEQ   WEIXXA
 CMP.B #')',3(A1)
 BNE   NOXXA
WEIXXA:
 LEA  (A1),A0
 BSR  PRUEFA   kînnte es ein A0 ... A7 sein? dann vs und a1 zeigend dahintr
 BVC  NOXXA
 LEA  0(A0,D0),A1  zeig hinter 'Ai' oder 'Ri', also zeig ')'
 CMP.B #')',(A1)+
 BNE  NOXXA
 MOVE.L A1,  D0
 MOVE.L (A7)+,A0
 SUB.L   A0, D0  soviele character bisher untersucht
 BRA   WIEOPEND

NOXXA:
 MOVEQ  #-1,  D0  so flag ne und vc
 MOVE.L (A7)+,A0
 RTS


PRUEFXAR:
*subroutine will A0 zeigend Operanden (erstn char!) prÅft ob x(A,R)
* gibt flag ne, wenn nicht
* sonst D1= Nummer des AdrReg
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.

MOVE.L A0,-(A7)
 BSR PRUEFOTH
 BNE NOXAR
 BVC NOXAR
 LEA (A1),A0
 BSR PRUEFA  kînnt es ein A0,... A7, sein? dann eq,cs, a1 zeig hintr Komma
 BCC NOXAR
 BNE NOXAR
FOLGTREG:
 MOVEQ #$DF,D0
 AND.B (A1)+,D0
 CMP.B #'A', D0
 BEQ   ONXAR
 CMP.B #'D', D0
 BEQ   ONXAR
 CMP.B #'R', D0
 BNE   NOXAR
ONXAR:
 MOVE.B (A1)+,D0
 CMP.B  #13, D0
 BEQ    NOXAR
 CMP.B  #')',D0
 BNE    ONXAR
 MOVE.L A1,  D0
 MOVE.L (A7)+,A0
 SUB.L   A0, D0  soviele character bisher untersucht
 BRA   WIEOPEND

NOXAR:
 MOVEQ  #-1,  D0  so flag ne und vc
 MOVE.L (A7)+,A0
 RTS

PRUEFXPR:
*subroutine will A0 zeigend Operanden (erstn char!) prÅft ob x(PC,R)
* gibt flag ne, wenn nicht. sonst: eq und
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
 BSR PRUEFOTH
 BNE NOXP
 BMI NOXP
 BVC NOXP
 BSR OB1PC  zeigt a1 auf 'PC'? dann eq und a1 nun zeigend dahinter
 BNE NOXP
 CMP.B #',',(A1)+ folgt Komma?
 BNE  NOXP
 MOVE.L A0,-(A7)
 BRA  FOLGTREG
NOXP:
 MOVEQ #-1,D0   ne
 RTS


PRUEFXXP:
*subroutine will A0 zeigend Operanden (erstn char!) prÅft ob xx(PC)
* gibt flag ne, wenn nicht. sonst: eq und
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
 BSR PRUEFOTH
 BNE NOXP
 BMI NOXP
 BVC NOXP
 BSR OB1PC       zeigt A1 auf 'PC'? dann eq und a1 nun zeigend dahinter
 BNE NOXP
 CMP.B #')',(A1)+
 BNE  NOXP
 MOVE.L A1,D0
 SUB.L  A0,D0  soviele character bisher untersucht
 BRA   WIEOPEND

OB1PC:
 CMP.B #'P',(A1)+
 BEQ  OB2PC
 CMP.B #'p',-1(A1)
 BNE  RT1PC
OB2PC:
 CMP.B #'C',(A1)+
 BEQ  RT1PC
 CMP.B #'c',-1(A1)
RT1PC:
 RTS

PRUEFUSP:
*subroutine will A0 zeigend Operanden (ersten character!)  prÅft ob USP
* gibt flag ne, wenn nicht. sonst:
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
 MOVE.L #$55535000,D1 'USP'
 BRA    PRUE0000

PRUEFCCR:
 MOVE.L #$43435200,D1 'CCR'
 BRA    PRUE0000

PRUEFSR:
 MOVE.L #$53520000,D1 'SR'
* BRA    PRUE0000

PRUE0000:
 ROL.L #8, D1  so soll das erste Zeichen sein.
 MOVEQ #$DF,D0
 AND.B (A0),D0  groûbuchstabe erzwing
 CMP.B D1, D0
 BNE   NOT0000
 ROL.L #8, D1   zweites Zeichen
 TST.B D1
 BEQ   NOTNOT1  also war nur ein Zeichen zu untersuchen
 MOVEQ #$DF,D0
 AND.B 1(A0),D0
 CMP.B D1, D0
 BNE   NOT0000
 ROL.L #8, D1   drittes
 TST.B D1
 BEQ   NOTNOT2
 MOVEQ #$DF,D0
 AND.B 2(A0),D0
 CMP.B D1, D0
 BNE   NOT0000
 ROL.L #8, D1   viertes Zeichen
 TST.B D1
 BEQ   NOTNOT3
 MOVEQ #$DF,D0
 AND.B 3(A0),D0
 CMP.B D1, D0
 BNE   NOT0000
 MOVEQ #4, D0
 BRA   WIEOPEND
NOTNOT3:
 MOVEQ #3, D0
 BRA   WIEOPEND
NOTNOT2:
 MOVEQ #2, D0
 BRA   WIEOPEND
NOTNOT1:
 MOVEQ #1, D0
 BRA   WIEOPEND
NOT0000:
 MOVE #0, CCR  RÅckgabe flag ne und vc.
 RTS

PRUEFD:
*subroutine will A0 zeigend Operanden (ersten character!)  prÅft ob D0..D7
* gibt flag ne, wenn nicht
* sonst D1= Nummer des DatReg
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
 MOVEQ #$DF,D0
 AND.B (A0),D0  groûbuchstabe erzwing
 CMP.B #'D',D0
 BEQ   DREGOK
 CMP.B #'R',D0  R oder D hier gleichermaûen als Symbol fÅr DatRegister
 BNE   DRNOTOK
DREGOK:
 MOVE.B 1(A0),D1 folgt eine Ziffer zwischn 0 und 7 ?
 CMP.B #'7', D1
 BHI   DRNOTOK
 CMP.B #'0',D1
 BLO   DRNOTOK
 CMP.B #'1',D1 kînnte es R10 oder R11 oderso sein?
 BNE   DREGKK
 CMP.B #'5',2(A0)
 BHI   DREGKK
 CMP.B #'0',2(A0)
 BHS   DRNOTOK
DREGKK:
 AND.w #7,  D1 die Nummer des Registers
 MOVEQ #2,  D0 soviele char bisher untersucht
 BRA   WIEOPEND
DRNOTOK:
 MOVE #0, CCR  RÅckgabe flag ne und vc.
 RTS

PRUEFA:
*subroutine will A0 zeigend Operanden (ersten character!)  prÅft ob A0..A7
* gibt flag ne, wenn nicht
* sonst D1= Nummer des AdrReg
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
 MOVEQ #$DF,D0
 AND.B (A0),D0  groûbuchstabe erzwing
 CMP.B #'A',D0
 BEQ   AREGOK
 CMP.B #'R',D0  
 BEQ   OBOB815
 CMP.B #'S',D0  es kînnte SP statt A7 verwendet worden sein
 BNE   ARNOTOK
 MOVEQ #$DF,D0
 AND.B 1(A0),D0
 CMP.B #'P',D0
 BNE   ARNOTOK
 MOVEQ #7,  D1  dann ist die RegNummer = 7
 BRA   AWEITR

OBOB815:
 MOVE.B 1(A0),D1  folgt 8 oder 9 ?
 CMP.B  #'8', D1
 BEQ   AWEITR
 CMP.B #'9', D1
 BEQ   AWEITR
 CMP.B #'1', D1  oder folgt 1 ?
 BNE   ARNOTOK
 MOVE.B 2(A0),D1  folgt eine weitere Ziffer zwischn 0 und 5 ?
 ADDQ.B #2,   D1  dies entsprÑche AReg 2..7
 CMP.B  #'7', D1
 BHI    ARNOTOK
 CMP.B  #'2',D1
 BLO    ARNOTOK
 MOVEQ  #3,  D0   soviele char bisher untersucht
 BRA    AWEI3

AREGOK:
 MOVE.B 1(A0),D1 folgt eine Ziffer zwischn 0 und 7 ?
 CMP.B #'7', D1
 BHI   ARNOTOK
 CMP.B #'0',D1
 BLO   ARNOTOK
AWEITR:
 MOVEQ #2,  D0  soviele char bisher untersucht
AWEI3:
 AND.w #7,  D1  die Nummer des Registers
 BRA   WIEOPEND
ARNOTOK:
 MOVE  #0, CCR  RÅckgabe flag ne und vc.
 RTS

PRUEFKLA:
*subroutine will A0 zeigend Operanden (ersten character!)  prÅft ob (A0..7)
* gibt flag ne, wenn nicht
* sonst D1= Nummer des AdReg
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
 CMP.B #'(',(A0) beginnts mit KlammrAuf?
 BNE  ARNOTOK
 ADDQ #1, A0    zeig hinter die Klammer
 BSR  PRUEFA
 SUBQ #1, A0    laû flags
 BVC  ARNOTOK      vs= es ist AdrRegister und 1(A0,D0) zeigt dahinter
 CMP.B #')',1(A0,D0)
 BNE  ARNOTOK
 ADDQ #2, D0
 BRA WIEOPEND

PRUEFKPL:
*subroutine will A0 zeigend Operanden (ersten character!)  prÅft ob (A0..7)+
* gibt flag ne, wenn nicht
* sonst D1= Nummer des AdReg
* wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
 BSR  PRUEFKLA
 BVC  ARNOTOK         vs= es ist "(A)"-Typus  und 0(A0,D0) zeigend dahinter
 CMP.B #'+',0(A0,D0)
 BNE  ARNOTOK
 ADDQ #1,D0
 BRA  WIEOPEND

PRUEFMIK:
*subroutine will A0 zeigend Operanden (ersten character!)  prÅft ob -(A0..7)
* gibt flag ne, wenn nicht
* sonst D1= Nummer des AdReg
*  wenn Komma dahinter: flag cs und A1 zeigend nÑchsten string. A0 laû.
 CMP.B #'-',(A0)
 BNE  ARNOTOK
 ADDQ #1, A0
 BSR  PRUEFKLA
 SUBQ #1, A0
 BNE  ARNOTOK
 ADDQ #1,D0
 BRA  WIEOPEND

PRUEFLIS:
*subroutine checkt auf R1-R5/R12-A6 oder auf D6/A0/R9-R11 oderso.
* gib in D1 die zugehîrige Maske.
 MOVEM.L D2/D3/A0,-(A7)
 MOVEQ  #127,D2       zeig,daû bisher kein `-` (also kein 'bis')
 MOVEQ #0, D3
 BRA   WEISESE
NOCSESE:
 LEA 1(A0,D0),A0
WEISESE:
 BSR  PRUEFD
 BVS  PLISD
 BSR  PRUEFA
 BVC  NIXLIS
 ADDQ #8,D1  ARegister kriegen Nummern 8..15  ohne flags zu Ñndern!
PLISD:
 BSR  SETSET
 CMP.B #'-',0(A0,D0)
 BEQ  NOCSESE        und laû D2 auf niedrigem Wert (aus SETSET)
 MOVEQ #127,D2       sonst setz D2 hoch, um zu zeigen, daû kein `-`
 CMP.B #'/',0(A0,D0)
 BEQ  NOCSESE
*               nun Liste abgearbeitet, Maske in D3
 MOVE  D3,  D1
 LEA 0(A0,D0),A0
 MOVE.L A0, D0
 MOVEM.L (A7)+,D2/D3/A0
 SUB.L  A0, D0          soviele char untersucht
 BRA   WIEOPEND
NIXLIS:
 MOVEM.L (A7)+,D2/D3/A0
 RTS

SETSET:
* setzt in D3 das bit, welches D1 angibt, dann guck dir D2 an, ist
* D2<D1, dann decr D1 und setz auch dies bit von D3 usw, bis D1 den
* Wert von D2 erreicht hat. Danach setz D2 auf 7F.
* Wenn D2>=D1 war, so Åbernimm in den D2 den Wert von D1.

 BSET  D1,D3
 CMP.B D2,D1
 BHI   MEHRSESE
 MOVE  D1,D2
 RTS
MEHRSESE:
 SUBQ  #1,D1
 BSET  D1,D3
 CMP.B D2,D1
 BGT   MEHRSESE
 MOVEQ #127,D2
RTS
  
WIEOPEND:
*soubr-Ende, gemeinsame MÅndung vieler OperandenprÅfer.
* braucht d0= Anzahl der char des Operanden, so daû 0(A0,D0)=Zeichn dahintr.
* kontrolliert, ob hinterm Operanden was vernÅnftiges steht,
* also Blank oder carReturn oder Tabulator oder Komma. Dann flag eq.
* im letzteren Falle zusÑtzlich flag cs und A1 an Anfang des nÑc string.
*  stets vs-flag.
 CMP.B #',',0(A0,D0)
 BEQ   KOMFOUN
 CMP.B #' ',0(A0,D0)
 BEQ   OPENDOK
 CMP.B #13, 0(A0,D0)
 BEQ   OPENDOK
 CMP.B #9,  0(A0,D0)
OPENDOK:
 ORI  #2,  CCR    eq-flag bei Tab oder carRt oder Blank.  Und stets vs.
 ANDI #$FE,CCR    Und hier stets cc.
 RTS

KOMFOUN:
 LEA  1(A0,D0),A1  zeig hinters Komma
NKNXS:
 CMP.B #' ',(A1)+  Blanks Åbergehen
 BEQ   NKNXS
 CMP.B #9, -1(A1)  ebebso Tab Åbergehen
 BEQ   NKNXS
 SUBQ  #1,  A1    A1 zeigend nÑchsten string-Anfang
 MOVE  #7,  CCR  so RÅckgabe mit flag eq und vs und cs
 RTS

ERRMELD:
*subroutine will d1= error Code
* -2= redefined
* -3= komische instruction
*
* -17..-21 = symbol endgÅltig nicht auswertbar. hier muû d0 zeigend string!
*
 MOVEM.L D0-D3/A0,-(A7)
 bsr newline
 bsr blankou
 bsr blankou
 bsr blankou
 bsr blankou
 bsr blankou
 bsr blankou
 bsr blankou
 CMP  #-16,D1
 BLT  ENACHQ
 MOVE.L AZE(A3),D0
 BSR  DEZOUT
EMOB2:
 CMP  #-2,D1
 BNE  EMOB3
 MOVE.L #' RED',D0
 MOVE.L #'EFIN',D1
 BRA REMELD
ENACHQ:
* hier fehler behandeln, die auftreten, nachdem der Quelltext abgehakt ist:
*  setz voraus, daû d0 zeigend TermAnfang
 MOVE.L D0,A0
 BSR TEISTROU
 MOVE.L #' etc',D0
 MOVE.L #' =? ',D1
 BRA REMELD
EMOB3:
 MOVE.L #' INS',D0
 MOVE.L #'TRU?',D1
REMELD:
 BSR    ASC4OU
 MOVE.L D1,D0
 BSR    ASC4OU
 MOVEM.L (A7)+,D0-D3/A0
RTS

ASC4OU:
 ROL.L #8,D0
 bsr  chou   lÑût D0 !!!
 ROL.L #8,D0
 bsr  chou
 ROL.L #8,D0
 bsr  chou
 ROL.L #8,D0
 bra  chou

DEZOUT:
*subroutine gibt maximal fÅnf dezimalStellen gemÑû d0.L aus
 MOVE.L D0,D2
 MOVEQ #$2F,D0
M10T:
 ADDQ  #1,D0
 SUB.L #10000,D2  wie oft paût 10000 in die Zahl?
 BHS  M10T
 ADD.L #10000,D2
 BSR  chou
 MOVEQ #$2F,D0
M1T:
 ADDQ  #1,D0
 SUB #1000,D2  wie oft paût tausend in die Zahl?
 BHS  M1T
 ADD #1000,D2
 BSR  chou
 MOVEQ #$2F,D0
M100:
 ADDQ  #1,D0
 SUB #100,D2  wie oft paût 100 in die Zahl?
 BHS  M100
 ADD #100,D2
 BSR  chou
 MOVEQ #$2F,D0
M10:
 ADDQ #1,D0
 SUB #10,D2  wie oft paût 10 in die Zahl?
 BHS  M10
 ADD #10,D2
 BSR  chou
 MOVEQ #$30,D0
 ADD  D2,D0
 BSR  chou
BRA  blankou

TEISTROU:
 MOVE.B (A0)+,D0
 CMP.B #13, D0
 BLS   RTEIS
 CMP.B #',',D0
 BEQ  RRTEIS
 CMP.B #'$',D0
 BLO  RRTEIS
 BSR chou
 BRA TEISTROU
RRTEIS:
 BSR chou
RTEIS:
 RTS

STPLATZ:
*** ÅberprÅfung, ob noch stackplatz (kann zurNot entfallen)
 MOVEQ #127,D1
 LSL.W #3,  D1
 ADD.L L00(A3),D1
 ADD.L LPC(A3),D1  zeig,wo nÑc codeWord hinkommen wird + ca 1000 reserve
 CMP.L A7, D1     flag hs, wenn zuwenig Platz
 RTS

TE:

dc.L -1,-1


