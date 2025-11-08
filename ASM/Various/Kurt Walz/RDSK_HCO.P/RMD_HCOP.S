
ENDOFMEM: EQU $42E  hier merkt sichs TOS, ab wo memory zuende
ENDOFUSE: EQU $436  Hier merkt sichs TOS, wo user nicht hindarf
BEGOFUSE: EQU $432  und hier, ab wo der user hindarf
HDVBPB:  EQU $472  vector um harddiskBIOSparameterBlock zu holen
DRIVES: EQU $4C4  hier 16 bits, gesetzt fÅr jedes angeschlossne Laufwerk
DR: EQU 6         6= "G:"  3= "D:"  als Laufwerksname

HCOPVEC: EQU $502 hier merkt sichs TOS,wo die HardCopyRoutine steht
OBHC:  EQU $4EE  =0,wenn eine Hardcopy gemacht werden soll

ANFANG:
 BRA START

HCRIES:

*kann anstelle des ST_hardcopy_programmteils treten
*um hardcopy auf P6_printer zu geben. erzeugt besonders RIESIGE Kopie.

movem.L d0-d4/a0,-(a7)
* move.w #$1C40,  d0  vertrÑgt "Tally" nicht!
* bsr    anpr2       um printer_Bereitschaft zu testen und pr zu initialisieren
* bne    vaufh
        moveq #13,d0
        bsr anpr1
        bne vaufh


movea.w #$8200,a0   adr, wo tvBase abgelegt
** moveq  #0,    d0  kann entfallen,solange obiges moveq_#13 stehenbleibt
movep.w 1(a0), d0
 lsl.L  #8,    d0
 move.L d0,    a0  ab hier tv_RAM
 moveq  #33,   d2  vertikal(da je 12tvZeilen): 33*12=408 tvZeiln
*                  in tv8x12 bei d2=0 also 8 pixl unterdrÅckn!
poulo:
 move.L #$1B2A27,d0  code fÅr 180_grafikModus, weitere 2Byte mÅssen die Zahl der Infopakete angeben!
 bsr    anpr3
 move.w #$FF04, d0   also 2*280-1=4FF(hex)=2*640-1dz grafikInfos
 bsr    anpr2
 moveq  #79,   d1
provlo:
 bsr    tv8x12   druckt gemÑû8x12(HORxVERT)tvPixel: 16x24 P6(180er)pixel
 bne    vaufh
 addq   #1, a0
 dbra   d1, provlo

 move.w sr,-(a7)
 and.w #$2500,sr     erlaube zumindest den Tastatur-Interrupt
* move.L #$1C3330,d0  papiervorschub auf 48/360 inch setzen (=24 Nadeln)
* bsr    anpr3       besser 24/180 inch, sonst versteht es Tally nicht!
 move.L #$1B3318,d0
 bsr   anpr3

 move.w #$A0D, d0    LineFeed carrRet
 bsr    anpr2
 move.w (a7)+,sr
 tst.w  OBHC
 bne    vaufh
*                     durch 80* addq1,a0:  a0 zeigt nun ungrade tvZeile
 lea   880(a0),a0    nÑchste noch nicht gedruckte tvZeile
 dbra   d2,    poulo

vaufh:
clr.B  $E1B           TOS merkt sich hier,ob shift/contr/altrn gedrÅckt
movem.L (a7)+,d0-d4/a0
 rts

*subr gibt 8*24 tvPixl auf printer(horiz8 vert24)   ne=timeout  !d0d3
tv8x12:
 move.L d1,-(a7)
 moveq  #7,  d1
n8: 
 cmp.b  #7,  d1  tvPixel an byteAnfang?
 bne    nA
 move.L a0, d0   teste, ob AnfangTVzeile, also durch 80 teilbares a0..
 and.L #$FFFFF,d0
 divu   #80,d0  .. divisionsrest in d0.hiWord
 swap       d0
 tst.w      d0   wenn tvZeileAnfang: keine printerZwischenPixel
 beq    n9
nA:
 bsr hol4pix
 lea 320(a0),a0  vier tvZeilen weiter
 bsr hol4pix
 lea 320(a0),a0
 bsr hol4pix
 lea -640(a0),a0  nun d3=vorigeTVpixel d0=nÑchsteTVpixel
* nun erzeug printerZwischenPixel nur dann
*wenn min 2 der 4 nÑchstgelegnn hauptPixl(=ungradeBitNummrn in d0 u d3) gesetzt!
movem.L d1-d2,-(a7)
 moveq  #23,  d2    zÑhl die bitNummern
 and.L #$AAAAAA,d0  so bleiben zunÑchst nur die bits der Haupt(=tv)Pixl
NA: moveq #0, d1    code fÅr die gesetzten (Haupt)NachbarPixel
 btst   d2,   d0   erster Hauptnachbar: rechts oben
 beq    Nz
 addq   #1,   d1  reObn=bit0
Nz: btst d2,  d3   zweiter Hauptnachbar: links oben
 beq    Ny
 addq   #2,   d1  liObn=bit1
Ny:
 bclr   d2,   d0  lîsch das bit, jetzt info fÅr ZwPixl hierrein
 cmp    #3,   d1  wars bisher gesetzt und sein linker Nachbar auch?
 bne    NO
 bset   d2,   d0
NO:
 subq   #2,   d2  zeig bitNummer fÅr nÑchstunteren HauptPixl
 bmi    NN
 btst   d2,   d0   dritter Hauptnachbar: rechts unten
 beq    Nx
 addq   #4,   d1  reUnt=bit2
Nx: btst d2,  d3   vierter und letzter Hauptnachbar: links unten
 beq    Nw
 addq   #8,   d1  liUnt=bit3
Nw: 
 cmp    #6,   d1   wenn zuwenig gesetzteNachbarn= keinZwischenPixel auf printer
 bcs    NA
 cmp    #8,   d1   s.o.
 beq    NA
 cmp    #10,  d1  zwar zwei Nachbarn, aber nichtdiagonale
 beq    NA
 cmp    #12,  d1  s.o.
 beq    NA
NM: addq #1,  d2  zeig die zugehîrge bitNummr zum aktuelln ZwischnPixl
 bset   d2,   d0
 subq   #1,   d2
 bra    NA
Ns: btst #0, 959(a0)
 bra    Np
NN:
 move.w d1,   d3    merk gesetzteNachbarn_Zahl nun in d3
movem.L (a7)+,d1-d2  in d1 nun wieder bitNummer des aktuellen tvBytes
 btst   d1,  960(a0)  hauptNachbar rechts unter unterstem pot ZwischPixl
 beq    Nt
 addq   #4,   d3
Nt: addq #1,  d1      zeig auf entsprechenden LINKSunten Nachbar
 cmp.b  #7,   d1
 bhi    Ns
 btst   d1,  960(a0)
Np: beq Nr
 addq   #8,   d3
Nr: subq #1,  d1      wieder originalWert
 cmp    #6,   d3   0,1,2,3,4,5: kein ZwischenPixl auf bit0
 bcs    Nq
 cmp    #8,   d3
 beq    Nq
 cmp    #10,  d3
 beq    Nq
 cmp    #12,  d3
 beq    Nq
 addq   #1,   d0   wenn gestzNachbarn_Anzahl groû: auch bit0_d0 setzen
Nq:
 bsr anpr3
n9:
 bsr hol4pix
 lea 320(a0),a0  vier tvZeilen weiter
 bsr hol4pix
 lea 320(a0),a0
 bsr hol4pix
 lea -640(a0),a0
 move.L d0,  d3  merk dir das zuletzt ausgegebene PixelPaket
 tst.w d2
 sne   d4
 ext.w d4
 ext.L d4        also 0(wenn unterste tvZeilen) oder FFFFFFFF sonst.
 or.L #$FE0000,d4 mindestens 7 druckerPixl (=4 tvPixl) ausgeben.
 and.L d4,d0
 bsr  anpr3      gibt ne=timeout
 dbne  d1,  n8   bei ne vorzeitig abbrechen: timeout
 movem.L (a7)+,d1
rts

*subr holt ab (a0) vier UNTEReinanderliegende tvPixel nach d0.B inUNGRADE
* d0BitNummern      (bitNr der tvBytes muû in d1 sein)
hol4pix:
 lsl.L  #8,d0
 btst   d1,(a0)
 beq    h7
 bset   #7,d0
h7: btst d1,80(a0)
 beq    h6
 bset   #5,d0
 btst   #7,d0     wenn drÅber auch pixel: zwischenpixel auf Printer
 beq    h6
 bset   #6,d0
h6: btst d1,160(a0)
 beq    h5
 bset   #3,d0
 btst   #5,d0
 beq    h5
 bset   #4,d0
h5: btst d1,240(a0)
 beq    h4
 bset   #1,d0
 btst   #3,d0
 beq    h3
 bset   #2,d0
h3: btst d1,320(a0) wenn drunter auch pixel: zwischenpixel auf printer
 beq    h4
 bset   #0,d0
h4:    rts

*subr gibt aus d0 drei bytes an printerport (nicht das MSByte)
anpr3:
 swap     d0
 bsr  anpr1
anpp:
 rol.L #8,d0
 bsr  anpr1
 rol.L #8,d0
 bsr  anpr1
rts

*subr gibt d0.w an printerport (erst hiByte dann lowByte)
anpr2:
 swap     d0
 bra  anpp

*subr gibt d0.b an printerport  ne=timeout
anpr1:
 move.w sr,   -(a7)
 move.w #$2700,sr
 move.L d0,   -(a7)    ** ! setzt voraus, daû alle Int disabled !!
 bsr    waibusy
 bne    ranp1
 move.b #7,   $FF8800  reg7 des soundchip anwÑhlen ..
 move.b $FF8800, d0    .. auslesen und ..
 or.b   #$80,    d0    .. bit7 setzen, dadurch portB als Ausgang geschaltet
 move.b d0,   $FF8802

 move.b #15,  $FF8800  portB(=printPort) anwÑhlen
 move.b 3(a7),$FF8802  dortrein (in printPort) schreiben
 move.b #14,  $FF8800  portA anwÑhlen
 move.b $FF8800, d0    portA auslesen
 and.b  #$DF,    d0    strobeBit(=bit5) clear vorbereiten
 move.b d0,   $FF8802  und so strobLOW verwirklichen
 bsr    zei0
 or.b   #$20,    d0    strobe high
 move.b d0,   $FF8802
 bsr    waibusy        warte, bis(eq) printer nicht mehr busy oder bis timeout(ne)
ranp1:
 move.w sr,   d0
 move.b d0, 5(a7)
 move.L (a7)+,d0
 move.w (a7)+,sr
rts

zei0:
 move.L d0, -(a7)
 move.w #99, d0
zzi0:
 dbra   d0,   zzi0
 move.L (a7)+,d0
rts

waibusy:
 move.L #$5FFFF,d0
wbu: btst #0, $FFFA01  ne=centronics(=printer) busy
 beq    rwb
 subq.L #1,     d0
 bpl    wbu
rwb:   rts


START:
 CLR.L -(A7)
 MOVE.W #32,-(A7)  supervisor
 TRAP  #1
 ADDQ.L #6, A7
* LEA ANFANG(PC),A0
* MOVE.L D0,(A0)

 MOVEA.W #ENDOFUSE,A4
 MOVEA.W #ENDOFMEM,A5
 MOVE.L (A5), A1
 CMP.W  #$200,(A1)  ist RAMDISK schon initialisiert(eq)?
 BEQ   ISTSCHON
 MOVE.W #11,-(A7)   gibt d0=0,wenn nix getippt
 TRAP  #1
 ADDQ.L #2,A7
 ADD.W #21,D0   macht Carry,wenn d0=-1 war, wenn also was getippt war
 BCC   SOWRDGR  nixGetippt: defaultWert=21
 MOVE.W #7,-(A7)
 TRAP  #1
 ADDQ.L #2,A7
 CMP.B #'A',D0
 BLO   SOWALPHA
 SUBQ.B #7,D0
SOWALPHA:
 SUB.B #'0',D0  war mindestens eine "1" getippt(hs)?
 BLE   HOERAUF
 AND.W #$1F,D0
SOWRDGR:
 MOVE.W D0,D1  um Zahl der "FreienCluster" zu errechnen
 LSL.W #6,D1     alswÑre swap_LSR#10, also/1024, =absolute Zahl der Cluster
 SUB.W #20,D1      Verwaltung fordert ihren Tribut
 LEA FREECL(PC),A0
 MOVE.W D1, (A0)
 SWAP D0
 CLR.W D0
 MOVE.L D0,D1
 ADD.L BEGOFUSE,D1
 ADD.L #$20000,D1  sovielPlatz soll der user haltdoch haben
 CMP.L (A4),  D1  bleibt noch was fÅr RAMDISK(lo)?
* a4 zeigt auf Stelle,wo EndOfUserMemory vermerkt ist
 BHS   HOERAUF
 SUB.L D0,(A4)  merk verkleinertes EndOfUserMemory
 SUB.L D0,(A5)     und verkleinertes EndOfRAM
 MOVE.W #HDVBPB,A0
 LEA   BPHDD+2(PC),A1
 MOVE.L (A0)+,(A1)
 LEA   IOHDD+2(PC),A1
 MOVE.L (A0)+,(A1)
 ADDQ.L #4,  A0
 LEA   MEDCH+2(PC),A1
 MOVE.L (A0)+,(A1)   vec fÅr BiosParBlock,io,MediaChange von TOS Åbernehmen.

 LEA  VANF(PC),A0
 MOVE.L (A5), A1
 LEA  VEND(PC),A5
N1CC: 
 MOVE.L (A0)+,(A1)+
 CMP.L  A5,A0
 BLS   N1CC
 MOVE.L 4, A0  resetVector
 JMP   (A0)

ISTSCHON:
*  a1 zeigt bereits aufs EndOfMemory  !!
 MOVEA #HDVBPB,A0
 ADDA.W #BPBHARDD-VANF,A1
 MOVE.L A1,(A0)+            so ist dieser TOSvector verbogen nach RAMDISK
 ADDA.W #IOHARDD-BPBHARDD,A1
 MOVE.L A1,(A0)+            auch dieser
 ADDQ.L #4, A0
 ADDA.W #MEDIACHG-IOHARDD,A1
 MOVE.L A1,(A0)             und dieser. Aber wenn nicht RAMDSK gemeint, so
*   wird weitergesprungen auf die ursprÅnglichen TOSvectoren (s.o.)

 BSET   #DR,DRIVES+1     Laufwerk z.B. "G:" anmelden

HOERAUF:
 CLR.W -(A7)
 CMP.W #9,HCOPVEC  ist bereits eine HardcopyRoutine im RAM (lo)?
 BHS   RESRVIER
 TRAP  #1
RESRVIER:
 LEA  HCRIES(PC),A0
 MOVE.L A0, HCOPVEC
 LEA  START+260(PC),A1
 LEA  ANFANG(PC),A0
 SUB.L A0, A1
 MOVE.L A1,-(A7)
 MOVE.W #$31,-(A7) keep process
 TRAP  #1


VANF:
 DC.W $0200,$0002,$0400,$0007,$0005,$0006,$0012

FREECL:
 DC.W $01EC,$0000

MEDIACHG:
 CMP.W #DR,4(A7)  ists RAMDISK-Laufwerk gemeint(eq)?
 BEQ  MDC0
MEDCH:
 JMP 0    hier wird (s.o.) der alte TOS-vector eingebaut
MDC0:
 MOVEQ #0,D0
 RTS

BPBHARDD:
 CMP.W #DR,4(A7)
 BEQ   BPH0
BPHDD:
 JMP 0
BPH0:
 MOVE.L ENDOFMEM,D0
 RTS

IOHARDD:
 CMP.W #DR,14(A7)
 BEQ   IOH0
IOHDD:
 JMP 0
IOH0:
 MOVE.L ENDOFMEM,A0
 ADDA.W #512, A0    ersten sector nie benutzen
 MOVE.L 6(A7),A1   RAM-adr,wo die öbertragung starten soll
 MOVE.W 12(A7),D1  SektorNr,bei dem die öbertragung starten soll
 EXT.L  D1
 LSL.L #8,D1
 LSL.L #1,D1       ByteNr innerhalb RAMDSK,bei dem die öbertragung startet
 ADD.L D1,A0
 MOVEQ #0,D0     !! wichtig fÅrs aufrufende TOS !!
 MOVE.L A1, D2    !!
 MOVE.W 10(A7),D0  soviele Sektoren Åbertragen
 BEQ   R1UE
 BTST #0,5(A7)     öbertragung vom RAM oder ins RAM?
 BNE  UERIC
 EXG  A0,A1
UERIC:
 MOVEQ #127,D1
N1UU:
 MOVE.B (A1)+,(A0)+
 MOVE.B (A1)+,(A0)+
 MOVE.B (A1)+,(A0)+
 MOVE.B (A1)+,(A0)+
 DBRA  D1,N1UU
 SUBQ.W #1,D0
 BNE   UERIC
R1UE:
 RTS

VEND: DC.W 0

