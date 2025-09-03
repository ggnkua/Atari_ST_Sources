*
* wolln wir Etiketten mit Adressen versehen? na denn..
*

WO2: EQU 37   soviel character vom ersten Etikett bis zum zweiten
WOU: EQU 8     soviel Zeilen bis zum nÑchstunteren Etikett
WNZ: EQU 299678 wartezeit bei Drucker-newline

ZWR: EQU 9
*CHR: EQU 10  vorerst D4
ZEI: EQU 12
OIG: EQU 14
FET: EQU 15
ZAD: EQU 16

N:  EQU 20
NN: EQU 0
VN: EQU 4
ZN: EQU 8
ST: EQU 12
OO: EQU 16
NNA: EQU N+NN  fÅnf starts: Nachname Vorname ZusÑtze Straûe Ort
VNA: EQU N+VN
ZNA: EQU N+ZN
STR: EQU N+ST
ORT: EQU N+OO
NN2: EQU ORT+4+NN  die nÑchsten fÅnf = 1 set von AdressenStrings
VN2: EQU NN2+VN
ZN2: EQU NN2+ZN
ST2: EQU NN2+ST
OR2: EQU NN2+OO
NN3: EQU OR2+4+NN
VN3: EQU NN3+VN
ZN3: EQU NN3+ZN
ST3: EQU NN3+ST
OR3: EQU NN3+OO
NN4: EQU OR3+4+NN
VN4: EQU NN4+VN
ZN4: EQU NN4+ZN
ST4: EQU NN4+ST
OR4: EQU NN4+OO
NN5: EQU OR4+4+NN =ca100  maximal 4 sets von Adressenstrings,hier nur 0 rein

W2: EQU NN5+4 wieweit nach rechts bis zum zweiten Etikett
WU: EQU NN5+6 wieweit nach unten zum nÑc Etikett
WV: EQU NN5+8 wieviele Etikett(paare) pro Blatt
ZV: EQU NN5+12 zÑhle diese

 LINK A4,#-988
LOELI:
 CLR.L -(A4)
 CMP.L A7,A4
 BHI  LOELI   die xx(A4)-Parameter alle auf 0, nun a4=a7
 MOVE.W #WO2,W2(A4)
 MOVE.W #WOU,WU(A4)

VORAGAI:
 LEA  VORSTLL(PC),A0
 BSR  ANTVVIEL

 LEA -98(A7),A7
 LEA (A7), A0       platz auf stack nun via xx(a0) benutzbar
 MOVE.L #'KART',(A0)
 MOVE.L #'EI.D',4(A0)
 MOVE.L #$4F430000,8(A0) 'OC'  default des filename: KARTEI.DOC
 BSR  GRTASTE
 CMP.B #'J',D0
 BEQ  EINFACH
 CMP.B #13,D0
 BEQ  EINFACH
 CMP.B #'N',D0
 BEQ  KOMPLIZ
 LEA  98(A7),A7
 CMP.B #'A',D0
 BEQ  HOERAUF
 BRA  VORAGAI
VVORAGA:
 LEA  98(A7),A7
 BRA  VORAGAI
 
KOMPLIZ:
 LEA NEUNAM(PC),A0
 BSR ANTVVIEL
 LEA (A7), A0    platz auf stack nun via xx(a0) benutzbar
 BSR HOLZEIL
 BEQ SOODERSO
 CMP.L D0,A0   was unvernÅnftges getippt?
 BEQ  VVORAGA
 MOVE.L D0,A0
 CLR.B (A0)    0 hintern filenamen
SOODERSO:
 LEA DRODERET(PC),A0
 BSR ANTVVIEL
 BSR GRTASTE
 CMP.B #'J',D0
 BEQ SOOD
 CMP.B #13,D0
 BEQ SOOD
 LEA ETGR1(PC),A0
 BSR ANTVVIEL
 BSR GRTASTE
 CMP.B #'J',D0
 SNE ZWR(A4)
OBOK3E:
 LEA ETGR2(PC),A0
 BSR ANTVVIEL
 MOVE.W W2(A4),D0
 BSR DEZMM10
 LEA ETGR3(PC),A0
 BSR ANTVVIEL
 BSR GRTASTE
 CMP.B #'G',D0
 BEQ OK3E3
 SUBQ.W #1,W2(A4)
 CMP.B #'W',D0
 BEQ OBOK3E
 ADDQ.W #2,W2(A4)
 CMP.B #'M',D0
 BEQ OBOK3E
 SUBQ.W #1,W2(A4)
 BRA OBOK3E
OK3E3:
 LEA ETGR5(PC),A0
 BSR ANTVVIEL
 BSR GRTASTE   '0'=endlos 1=1Reihe etc
 AND.W #127,D0
 SUB.B #'0',D0
 MOVE.W D0,WV(A4)
 CMP.B #9,D0
 BLS OBOK5E
 SUBQ.W #7,WV(A4)
OBOK5E:
 LEA ETGR4(PC),A0
 BSR ANTVVIEL
 MOVE.W WU(A4),D0
 BSR DEZMM401
 LEA ETGR3(PC),A0
 BSR ANTVVIEL
 BSR GRTASTE
 CMP.B #'G',D0
 BEQ OK5E5
 SUBQ.W #1,WU(A4)
 CMP.B #'W',D0
 BEQ OBOK5E
 ADDQ.W #2,WU(A4)
 CMP.B #'M',D0
 BEQ OBOK5E
 SUBQ.W #1,WU(A4)
 BRA OBOK5E
OK5E5:


SOOD:
EINFACH:
 LEA (A7),A0  dort steht filename
 BSR FILEHER
 LEA 98(A7),A7
 BMI VORAGAI
 LEA LL(PC),A0
 ADD.L D4, A0  hier AdressKartei zuende
 CLR.B (A0)
 CLR.B 1(A0)   markiers Ende mit Nullen
 CLR.B 2(A0)
 LEA  SOVIELE(PC),A0
 BSR  ANTVVIEL
 CLR.W ZAD(A4)
 LEA  LL(PC),A0
ZAEHLSE:
 BSR  OBADR
 BEQ  WARNSE
 ADD.W D0,ZAD(A4)
 BRA  ZAEHLSE
WARNSE:
 MOVE.W ZAD(A4),D0
 BSR   DEZIMAL
 LEA  SOWEIOK(PC),A0
 BSR  ANTVVIEL
 BSR  GRTASTE
 CMP.B #'J',D0
 BEQ  RAUSMIT
 CMP.B #13,D0
 BEQ  RAUSMIT
 CMP.B #'A',D0
 BEQ  HOERAUF
 BRA  VORAGAI
RAUSMIT:
 LEA  NADENN(PC),A0
 BSR  ANTVVIEL
 LEA LL(PC),A0
WEIWV:
 MOVE.W WV(A4),ZV(A4)  zÑhl Etiketten(paare)
 BNE WEIWEI          eq= Zeichen fÅr Endlospapier
 MOVE.W #32000,ZV(A4)
WEIWEI:
 SUBQ.W #1,ZV(A4)
 BPL WIWIW
 MOVE.L A0,-(A7)
 LEA WIII(PC),A0
 BSR ANTVVIEL
 BSR GRTASTE
 MOVE.L (A7)+,A0
 CMP.B #'A',D0
 BEQ HOERAUF
 BRA WEIWV
WIWIW:
 LEA NNA(A4),A2
 BSR  OBGRTA
 CMP.B #'P',D0
 BEQ  WAUFW
 CMP.B #'A',D0
 BEQ HOERAUF
WWIEA:
 BSR FERTIGE
 BEQ HOERAUF
 LEA NN2(A4),A2
 CLR.L (A2)
 CLR.W ZEI(A4)
 TST.B ZWR(A4)
 BNE  OK2ETIKE
 BSR FERTIGE
 BNE OK2ETIKE
 BSR DRUCK2ET
 BRA HOERAUF
WAUFW:
 BSR  GRTASTE
 CMP.B #'A',D0
 BEQ HOERAUF
 CMP.B #'W',D0
 BNE  WAUFW
 BRA WWIEA

OK2ETIKE:
 BSR DRUCK2ET
 BRA WEIWEI

******************
*LEA LL(PC),A0
*noc1:
*LEA NNA(A4),A2
*bsr FERTIGE
*beq wunde
*bsr NEWLINTV
*MOVE.L VNA(A4),A1
*BSR OUTBISK
*MOVE.L NNA(A4),A1
*BSR OUTBISK
*MOVE.L STR(A4),A1
*BSR OUTBISK
*MOVE.L ORT(A4),A1
*BSR OUTBISMX
*BRA noc1
*wunde:
*bsr GRTASTE

HOERAUF:
 MOVEQ #$2F,D4
HHOOEE:
 MOVE D4,D0
 BSR CLOSE
 DBPL D4,HHOOEE

 CLR.W -(A7)
 TRAP #1

HOLZEIL:
 MOVE.L A0,-(A7)
 MOVE.L A0,-(A7)
 BSR   GRTASTE
 MOVE.L (A7),A0
 CMP.B #' ',D0
 BLS   NXDAZEIL
 BRA   N2Z2O2
NOCZEIL:
 BSR   GRTASTE
 MOVE.L (A7),A0
 CMP.B #13,D0
 BEQ   DAZEIL
 CMP.B #8,D0
 BNE   ZSWOK0
 CMP.L 4(A7),A0
 BEQ   NOCZEIL
 SUBQ.L #1,(A7)
 LEA   MAPLA(PC),A0
 BSR   ANTVVIEL
 BRA   NOCZEIL
ZSWOK0:
 CMP.B #' ',D0
 BLO   NOCZEIL   andere Steuerzeichen ignorieren
N2Z2O2:
 BSR   ANTV1
 MOVE.B D0,(A0)+
 MOVE.L A0,(A7)
 BRA   NOCZEIL
DAZEIL:
* CLR.B (A0)      besser, wenn diese 0 der Aufrufer setzt
 MOVE.L (A7)+,D0  adr der 0 
 MOVE.L (A7)+,A0  adr des ersten Zeichens
 RTS             hier stets ne
NXDAZEIL:
 ADDQ.L #4,A7
 MOVE.L (A7)+,A0
 MOVEQ #0,D0     eq also nur, wenn quasi nix getippt
 RTS

OBGRTA:
 MOVE.L A0,-(A7)
 MOVE.W #11,-(A7)  ob Tastatur betÑtigt?
 TRAP   #1
 ADDQ.L #2,A7
 TST.W D0
 BEQ   RTOGR    nein(ne): hol den code
 BSR   GRTASTE
RTOGR:
 MOVE.L (A7)+,A0
 RTS

GRTASTE:
 MOVE.L A0,-(A7)
 MOVE.W #7,-(A7)
 TRAP   #1
 ADDQ.L #2,A7
 CMP.B #'z',D0
 BHI   RTGRT
 CMP.B #'a',D0
 BLO   RTGRT
 AND.B #$DF,D0
RTGRT:
 MOVE.L (A7)+,A0
 RTS


FILEHER:
 PEA  (A0)
 MOVE.W #$3D,-(A7)  * open
 TRAP  #1
 ADDQ.L #6,A7
 MOVE.W D0,D4   handl-Nr
 BMI   FILFEHL

 PEA   LL(PC)     ab hier memory beschriftbar.
 LEA -998(A7),A0  bis hier memory.
 SUB.L (A7),A0    RAMlÑnge
 PEA   (A0)
 MOVE.W D4,-(A7)  handle-Nr des file
 MOVE.W #$3F,-(A7) * read file
 TRAP   #1
 ADDA.W #12,A7
 EXG    D0,D4
 MOVE.L D4,D4
 BPL    FILRDOK

FILFEHL:
 LEA  FIFEH(PC),A0
 BSR  ANTVVIEL
 MOVEQ #-1,D0     flag mi
 RTS

FILRDOK:
CLOSE:
 MOVE.W D0,-(A7)  handle
 MOVE.W #$3E,-(A7) close
 TRAP  #1
 ADDQ.L #4,A7   fileLÑnge (vgl obn "EXGd0d4") noch in d4
 TST.W D0
 RTS 

NEWLINTV:
 MOVEM.L A0/D0,-(A7)
 LEA  NLTV(PC),A0
 BSR  ANTVVIEL
 MOVEM.L (A7)+,D0/A0
 RTS

NEWLINDR:
 MOVEM.L A0/D0,-(A7)
 MOVEQ #13,D0
 BSR   ANDROHN
 MOVEQ #10,D0
 BSR   ANDROHN
 MOVE.L #WNZ,D0
WNLWW:
 SUBQ.L #1,D0
 BNE   WNLWW
 ADDQ.W #1,ZEI(A4)
 MOVEM.L (A7)+,D0/A0
 RTS

ANTVVIEL:
TV1NOC:
 MOVEQ  #0,  D0
 MOVE.B (A0)+,D0
 BEQ   RTANTVV
 BSR   ANTV1
 BRA   TV1NOC
RTANTVV:
 RTS

ANDR1:
 MOVEM.L A0/D0,-(A7)
 TST.B OIG(A4)
 BEQ   WANDR1
 SUBQ.B #1,OIG(A4)
 BRA   NIANDR
WANDR1:
 cmp.b #11,D0
 beq   FF1
 cmp.b #$1B,D0
 beq   FF1
 cmp.b #12,D0
 beq   NIANDR
 cmp.b #$1C,D0
 beq   BBLANK
 cmp.b #$1D,D0
 beq   BBLANK
 cmp.b #$1E,D0
 beq   BBLANK
 BRA  WWANDR
FF1:
 ADDQ.B #1,OIG(A4)
 BRA   NIANDR
BBLANK:
 MOVEQ #32,D0

WWANDR:
 ADDQ.W #1, D4   zÑhlt die character
 TST.B FET(A4)
 BEQ  OKZWW
 ADDQ.W #1, D4
 MOVE.W D0,-(A7)
 MOVEQ #28,D0
 BSR   ANDROHN
 MOVEQ #86,D0
 BSR   ANDROHN
 MOVEQ #1,D0
 BSR   ANDROHN
 MOVEQ #27,D0
 BSR   ANDROHN
 MOVEQ #33,D0
 BSR   ANDROHN
 MOVEQ #32,D0
 BSR   ANDROHN
 MOVE.W (A7)+,D0
 BRA   OKOKZW
OKZWW:
 MOVE.W D0,-(A7)
 MOVEQ #28,D0
 BSR   ANDROHN
 MOVEQ #86,D0
 BSR   ANDROHN
 MOVEQ #0,D0
 BSR   ANDROHN
 MOVEQ #27,D0
 BSR   ANDROHN
 MOVEQ #33,D0
 BSR   ANDROHN
 MOVEQ #0,D0
 BSR   ANDROHN
 MOVE.W (A7)+,D0
OKOKZW:
 BSR ANDROHN
NIANDR:
 MOVEM.L (A7)+,D0/A0
 RTS

OBNIAND:
 MOVE.W W2(A4),-(A7)
 SUBQ.W #2, (A7)
 CMP.W (A7),D4
 ADDQ.L #2, A7
 RTS          mit hs, wenn schon zuviele char (fÅrs erste Etikett) an Dru.


ANDROHN:
 MOVE.W D0, -(A7)
 MOVE.W #5, -(A7)
 TRAP  #1
 ADDQ.L #4, A7
 RTS

VIELBLNK:
N1VBLA:
 CMP.W W2(A4),D4
 BHS   RVBLA
 MOVEQ #32,D0
 BSR  ANDR1
 BRA N1VBLA
RVBLA:
 RTS

VIELNEWL:
N1VNL:
 MOVE.W WU(A4),D0
 CMP.W ZEI(A4),D0
 BLO  RVNL
 BSR NEWLINDR
* diese subr macht auch  ADDQ.W #1,ZEI(A4)
 BRA N1VNL
RVNL:
 RTS

OBADR:
*       such in Zeile, ob z.B PostLeitZahl, deren adr in a1, a0=nxtZeile
OBFORMA:
 CMP.B #$1F,(A0)
 BNE   NOFORMA  "formatZeilen" ignorieren
N1IGNOR:
 MOVE.B (A0)+,D0
 BEQ   RTOBA
 CMP.B #10,D0
 BNE   N1IGNOR
 BRA   OBFORMA
NOFORMA:
 MOVEQ #0,D1  zÑhl bytes bis zum Komma
N1RU1:
 MOVE.B (A0)+,D0
 BEQ   RTOBA
 CMP.B #10,D0
 BEQ   NIXNEXZ
 CMP.B #',',D0
 BEQ   KOMM1F
 CMP.B #'@',D0
 BLO   N1RU1
 ADDQ.W #1,D1  zÑhl echte Buchstaben
 BRA   N1RU1
KOMM1F:
 CMP.W #3,D1
 BLO  NIXNEX  vorm ersten Komma: mindestens drei Buchstabn erwartet

N1RU2:
 MOVE.B (A0)+,D0
 BEQ   RTOBA
 CMP.B #10,D0
 BEQ   NIXNEXZ
 CMP.B #',',D0
 BNE   N1RU2
KOMM2F:
* ab jetzt vier Ziffern suche (PostLeitZahl)
N1RU3:
 MOVE.B (A0)+,D0
 BEQ   RTOBA
 CMP.B #10,D0
 BEQ   NIXNEXZ
 CMP.B #'9',D0
 BHI   N1RU3
 CMP.B #'.',D0
 BLO   N1RU3
 CMP.B #'9',(A0)
 BHI   N1RU3
 CMP.B #'.',(A0)
 BLO   N1RU3
 CMP.B #'9',1(A0)
 BHI   N1RU3
 CMP.B #'.',1(A0)
 BLO   N1RU3
 CMP.B #'9',2(A0)
 BHI   N1RU3
 CMP.B #'.',2(A0)
 BLO   N1RU3
* also vier Ziffern gefunden
 LEA -1(A0),A1
N1XN4X:
 MOVE.B (A0)+,D0
 BEQ   RTOBA
 CMP.B #10,D0
 BNE   N1XN4X
 MOVEQ #1,D0  summand=1 und flag ne
 BRA  RTOBA

NIXNEX:
N1XNX:
 MOVE.B (A0)+,D0
 BEQ   RTOBA
 CMP.B #10,D0
 BNE   N1XNX
NIXNEXZ:
 MOVEQ #0,D0  summand=0, aber..
 MOVEQ #1,D1  ..flag ne
RTOBA:
 RTS        hier eq nur, wenn TextEnde erreicht

FERTIGE:
*subr will a2= ea NNA(a4) oder NN2(a4), ab dort werden nun fÅnf Longwords
* protokolliert, nÑhmlich start von Nachname,Vorname,Zusatz,Straûe,Ort.
* will a0=ZeilenAnfang.  gib eq, wenn textEnde.

 CLR.L NN(A2)  NachnamenStart zunÑchst als "Kartei-zu-Ende" kennzeichnen
WSUCH:
 MOVE.L A0,-(A7)  Zeilenanfang
 BSR   OBADR
 MOVEM.L (A7)+,D1 merk in D1 den Zeilenanfang
 BEQ   RFERTIGE
 TST.W D0
 BEQ   WSUCH    bis a1 zeigend Postleitzahl
 MOVE.L A0,D0   merk dir in D0 den Anfang der nÑc Zeile
W2SUCH:
 CMP.B #',',-(A1)
 BNE   W2SUCH     bis a1 zeignd Komma vor dr Postleitzahl
 LEA  1(A1),A0
W3SUCH:
 CMP.B #' ',(A0)+  Blanks Åbergehen
 BLS   W3SUCH
 SUBQ.L #1, A0    a0 zeigt ersten charactr der PLZ_Ort-Zeile
 MOVE.L A0,OO(A2) start des Ortsnamens, genauer: der Postleitzahl
W4SUCH:
 CMP.B #',',-(A1)
 BNE   W4SUCH    bis a1 zeignd Komma vorm Straûennamen
 LEA  1(A1),A0
W5SUCH:
 CMP.B #' ',(A0)+  Blanks Åbergehen
 BLS   W5SUCH
 SUBQ.L #1, A0    a0 zeigt ersten charactr des StraûennamenString
 MOVE.L A0,ST(A2) start des Straûennamen

 MOVE.L D1,A0    anfang der Zeile (i.a. vorm start des Nachnamen)

OFRMA:
 CMP.B #$1F,(A0)
 BNE   NOFRMA  "formatZeilen" ignorieren
N1IGN:
 CMP.B #10,(A0)+  suchs ZeilenEnde
 BNE   N1IGN
 BRA   OFRMA
NOFRMA:

*hier noch nicht vollerkenne esc, formfeed ..., aber bei druckRoutine dann.

WZSUCH:
 CMP.B #'@',(A0)+  Nachnamen-Beginn suchen (also echteBuchstbn,keineZiffrn)
 BHI   WZWZ
 CMP.B #11,-1(A0)
 BEQ   WFOLGT1
 CMP.B #$1B,-1(A0)
 BNE   WZSUCH
WFOLGT1:
 ADDQ.L #1,A0
 BRA   WZSUCH
WZWZ:
 SUBQ.L #1,A0
 MOVE.L A0,NN(A2)  der Nachname startet vermutlich hier
W8SUCH:
 CMP.B #',',(A0)+
 BNE   W8SUCH     bis a0 zeignd hinters Komma hinterm Nachnamen
W9SUCH:
 CMP.B #' ',(A0)+  Blanks Åbergehen
 BLS   W9SUCH
 SUBQ.L #1,A0
 MOVE.L A0,VN(A2)  Der Vorname startet hier
WXSUCH:
 CMP.B #',',(A0)+
 BNE   WXSUCH     bis a0 zeignd hinters Komma hinterm Vornamen
WYSUCH:
 CMP.B #' ',(A0)+  Blanks Åbergehen
 BLS   WYSUCH
 SUBQ.L #1,A0
 MOVE.L A0,ZN(A2)  Wenns nZusatz zum Namen gibt, so startet er hier
 MOVE.L D0,A0     gib a0= anfang des nÑchsten set (Zeile), s.o. BSR OBADR

RFERTIGE:
 RTS      flag eq, wenn Textende

OUTBISK:
*subr will a1=string, gibt ihn aufs tv, bis Komma kÑme
N1OBK:
 MOVE.B (A1)+,D0
 CMP.B #',',D0
 BEQ  ROBK
 BSR  ANTV1
 BRA  N1OBK
ROBK:
 MOVEQ #32,D0
 BSR  ANTV1
 RTS

OUTBISMX:
*subr will a1=string, gibt ihn (VORLéUFIG!!) auf tv,bis '  ' odr steur kommt
* odr(wenn schon 15 byts ausgegbn) bis ' S' odr '.S' odr ' $' odr '.$' kommt
 MOVEQ #15,D1
N1OBX:
 MOVE.B (A1)+,D0
 CMP.B #' ',D0
 BHI  OUXX
 CMP.B #' ',(A1)
 BHI  OUXX     also Blank(und kleiner) verdÑchtign,daû nun nixmehrvernÅnftgs
 CMP.B #27,D0
 BNE  ROBX     allenfalls escapeSeq zulassen
OUXX:
 SUBQ.W #1,D1
 BPL   OUOX
 CMP.B #' ',D0
 BLS  OB0S
 CMP.B #'.',D0  . odr Blank(odr kleinr) gefolgt von S odr s odr $?
 BNE  OUOX      gilt auch nicht mehr als Adr-zugehîrig
OB0S:
 CMP.B #'S',(A1)
 BEQ  ROBX
 CMP.B #'s',(A1)
 BEQ  ROBX
 CMP.B #'$',(A1)
 BEQ  ROBX
OUOX:
 BSR  ANTV1
 BRA  N1OBX
ROBX:
 RTS

DEZMM401:
*subr geht davon aus, daû d0=DruckrZeiln , rechne um in mm, via 1z=4,01mm
 MULU #513,D0 513=128*4,01
 LSR.L #7,D0  div durch 128
 BRA  DEZIMAL

DEZMM10:
*subr geht davon aus, daû d0= charAnzahl, rechne um in mm, via 1char=2,54mm
 MULU #650,D0 650=256*2,54
 LSR.L #8,D0  div durch 256

DEZIMAL:
 MOVEM.L D0/D1/A0,-(A7)
 MOVE.W D0,D1
 MOVEQ #47,D0  vor'0'
hdzo:
 addq  #1,  d0
** sub.b #100,d1
 sub.w #100,d1
 bcc   hdzo
 add.b #100,d1
 CMP.B #'0',D0
 BEQ   LASSWEG
 bsr   ANTV1
LASSWEG:
 moveq #47,d0  vor'0'
zdzo:
 addq  #1, d0
 sub.b #10,d1
 bcc   zdzo
 add.b #10,d1
 bsr   ANTV1
 moveq #48,d0  '0'
edzo:
 or.b  d1,d0
 bsr   ANTV1
 MOVEM.L (A7)+,D0/D1/A0
 RTS

DRUCK2ET:
 MOVEQ #0,D4       zÑhl ausgegebne Zeichen der aktuellen Druckzeile
 MOVE.L VNA(A4),A1
 CMP.L STR(A4),A1  gibts gar keinen Vornamen?
 BHS  DU2NNN
 BSR DRBISK
DU2NNN:
 MOVE.L NNA(A4),A1
 BSR DRBISK
 MOVE.L ZNA(A4),A1  gibts gar keinen Zusatz?
 CMP.L STR(A4),A1
 BHS  DU2N
 BSR DRBISK
DU2N:
 MOVE.L NN2(A4),D0
 BEQ   DU22N
 BSR VIELBLNK      Blanks,bis D4 so, daû Druckkopf sicher aufs nÑc Etikett
 MOVE.L VN2(A4),A1
 CMP.L ST2(A4),A1  gibts gar keinen Vornamen?
 BHS  DU22NNN
 BSR DRBISK
DU22NNN:
 MOVE.L NN2(A4),A1
 BSR DRBISK
 MOVE.L ZN2(A4),A1  gibts gar keinen Zusatz?
 CMP.L ST2(A4),A1
 BHS  DU22N
 BSR DRBISK
DU22N:
 BSR NEWLINDR      jetzt wieder aufm ersten Etikett
 MOVEQ #0,D4
 MOVE.L STR(A4),A1
 BSR DRBISK
 MOVE.L NN2(A4),D0
 BEQ   DU23N
 BSR VIELBLNK      aufm zweiten
 MOVE.L ST2(A4),A1
 BSR DRBISK
DU23N:
 BSR NEWLINDR
 BSR NEWLINDR      aufm erstn
 MOVEQ #0,D4
 MOVE.L ORT(A4),A1
 BSR DRBIXX
 MOVE.L NN2(A4),D0
 BEQ   DU24N
 BSR VIELBLNK      aufm zweitn
 MOVE.L OR2(A4),A1
 BSR DRBISMX
DU24N:
 BSR VIELNEWL
 RTS

DRBISK:
*subr will a1=string, gibt ihn auf Drucker, bis Komma kÑme
N1OBKDR:
 MOVE.B (A1)+,D0
 CMP.B #',',D0
 BEQ  ROBKDR
 BSR  ANDR1
 BRA  N1OBKDR
ROBKDR:
 MOVEQ #32,D0
 BSR  ANDR1
 RTS

DRBIXX:
*subr wie DRBISMX, aber prÅfe, ob nicht schon zuviele Zeichen
 BSR OBNIAND
 BHS ROBXD
 ADDQ.W #1, ZEI(A4)  weil mit FET (s.u.) auch doppelthoher Druck eingesch.

DRBISMX:
*subr will a1=string, gibt ihn an Drucker,bis '  ' odr 2steurzchn kommen
* odr(wenn schon 15 byts ausgegbn) bis ' S' odr '.S' odr ' $' odr '.$' kommt

 MOVE.B #-1, FET(A4)
 MOVE.B (A1)+,D0
 BSR   ANDR1
 MOVE.B (A1)+,D0
 BSR   ANDR1
NOCHPLZ:
 MOVE.B (A1)+,D0
 BSR   ANDR1
 CMP.B #'9',(A1)
 BHI   PLZE
 CMP.B #'0',(A1)
 BHS  NOCHPLZ
PLZE:
 CLR.B FET(A4)
 MOVEQ #10,D1
DR1OBX:
 MOVE.B (A1)+,D0
 CMP.B #' ',D0
 BHI  OUXXD
 CMP.B #' ',(A1)
 BHI  OUXXD    also Blank(und kleiner) verdÑchtign,daû nun nixmehrvernÅnftgs
 CMP.B #27,D0
 BNE  ROBXD    allenfalls escapeSeq zulassen
OUXXD:
 SUBQ.W #1,D1
 BPL   OUOXD
 CMP.B #' ',D0
 BLS  OB0SD
 CMP.B #'.',D0  . odr Blank(odr kleinr) gefolgt von S odr s odr $?
 BNE  OUOXD     gilt auch nicht mehr als Adr-zugehîrig
OB0SD:
 CMP.B #'S',(A1)
 BEQ  ROBXD
 CMP.B #'s',(A1)
 BEQ  ROBXD
 CMP.B #'$',(A1)
 BEQ  ROBXD
OUOXD:
 BSR  ANDR1
 BRA  DR1OBX
ROBXD:
 RTS

ANTV1:
 MOVEM.L A0/D0,-(A7)
 MOVE.W D0, -(A7)
 MOVE.W #2, -(A7)
 TRAP  #1
 ADDQ.L #4, A7
 MOVEM.L (A7)+,D0/A0
 RTS


VORSTLL:
 DC.B 27,102,13,10,10,'   Laû uns Etiketten bedrucken.',13,10,10
 DC.B ' Am einfachsten lÑufts folgendermaûen:',13,10
 DC.B ' Endlospapier mit den zwei Reihen 88x35-Etiketten',13,10
 DC.B ' ist bereits im Drucker, am besten ein P6 oder so.',13,10
 DC.B '  ! Walze so drehen, daû Druckkopf ganz oben auf nem Etikett beginnt.',13,10
 DC.B ' Die Diskette mit den Adressen ist eingelegt, im file',13,10
 DC.B ' "KARTEI.DOC" befinden sich die Adressen; und zwar so,',13,10
 DC.B ' daû jede eine Zeile fÅr sich hat, und in jeder kommt',13,10
 DC.B ' eine Postleitzahl vor, die mindestens vierstellig ist,',13,10
 DC.B ' davor kommt die Straûe, davor Vorname, davor Nachname',13,10
 DC.B ' (Vorname muû nicht unbedingt sein). Alles durch Kommas getrennt.',13,10,10
 DC.B ' Kann ich das voraussetzen?  bitte j oder n (oder a [abbruch])',0

FIFEH:
 DC.B 13,10,10,10,'  ooh! Fehler beim file-Lesen von floppy. Vonvorn:',0
NEUNAM:
 DC.B 13,10,10,' tipp filename: ',0
SOVIELE:
 DC.B 13,10,10,' mal nachsehn, wieviele EintrÑge ich als ADRESSE gelten',13,10
 DC.B ' laû. Ich komm auf ',0
SOWEIOK:
 DC.B '. Kînnte die Anzahl stimmen? (j/n/a)',13,10,10,0
NADENN:
 DC.B ' Nun wird gedruckt. Willst du abbrechen: tipp A',13,10
 DC.B ' Willst ne Pause: tipp P, wieder weiter mit W',13,10
 DC.B ' (A und P wirken erst, wenn ein angefangenes Etikett fertig ist)',13,10,10,0
DRODERET:
 DC.B 13,10,' DruckerEinstellung und Etikettengrîûe OK? (j/n)',13,10,0
ETGR1:
 DC.B ' zwei Etiketten nebeneinander? (j/n)',13,10,0
ETGR2:
 DC.B ' angenommene EtikettBreite ca ',0
ETGR3:
 DC.B ' mm. Nun: Weniger/Mehr/Gehtso? (w/m/g)',13,10,0
ETGR4:
 DC.B ' angenommene EtikettHîhe ca ',0
ETGR5:
 DC.B ' Wieviel Etiketten pro Blatt untereinander?',13,10
 DC.B ' (0=endlos, 1..9 ist klar, A=10 B=11 usw)',13,10,0
WIII:
 DC.B '  neues Blatt eingelegt? (a=abbruch, jede andre=ja)',13,10,0

MAPLA: DC.B 8,32,8,0
NLTV:  DC.B 13,10,0

.EVEN

LL: DC.W $FFFF


