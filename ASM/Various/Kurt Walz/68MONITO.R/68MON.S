.TXT

ANF:

* SUBA.W #32000,A7
* MOVE.L 32004(A7),A5
* MOVE.L A7,D0
* SUB.L  A5,D0
* MOVE.L D0,-(A7)
* MOVE.L A5,-(A7)
* MOVE.L #$4A0000,-(A7)  Teil des RAM wieder freigeben: hier nicht n”tig
* TRAP   #1
* ADDA.W #12,A7
* TST.L  D0
* BNE    QUIT

 MOVEQ #$3F,D5
WUCL:
 SUBQ #1,D5
 BSR  CLOSE  solange CLOSE probieren,bis es klappt. So kann ein TOS-
 TST  D7     Programm seine eigne file-handle wieder freigeben.
 BMI  WUCL
 MOVE D5,D7
 BSR  OUT4HEX  melde diese handle-Nummer

 CLR.L -(A7)
 MOVE.W #32,-(A7) supervisor
 TRAP  #1
 ADDQ.L #6,A7

EINST:

FRAG0:
 LEA   TXT1(pc),A4
FRAG:
 BSR   OUTABADR    * gib ASCIItext ab (a4) auf tv
 BSR   INBYTE     * warte auf Tastatur, gib asciiByte in d4
 AND.B #$DF,D4   * GROSSBUCHSTABE
 CMP.B #'G',D4
 BEQ   RUN
 CMP.B #'S',D4
 BEQ   SUBST
 CMP.B #'H',D4
 BEQ   BSUBST
 CMP.B #'L',D4
 BEQ   DUMP
 CMP.B #'I',D4
 BEQ   INFO
 CMP.B #'T',D4
 BEQ   TRANSFER
 CMP.B #'M',D4
 BEQ   MUSTER

 CMP.B #'Q',D4
 BEQ   QUIT
 CMP.B #'R',D4
 BEQ   READ
 CMP.B #'W',D4
 BEQ   WRITE
 BRA   FRAG0

READ:
 LEA  TREAD(PC),A4
 BSR  OUTABADR
 LEA  -88(A7),A7
 LEA  (A7),  A4
 BSR  HOLNAME
 BEQ  BACKREAD
 CMP.B #'.',(A4)  war nur PunktTaste getippt? dann FloppyInhalt anzeigen
 BNE  NORMR
 LEA  TR2(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL  *so attribut in d7.w
 BMI  BACKREAD
 MOVE D7,D6
 LEA  TR3(PC),A4
 BSR  OUTABADR
 LEA  (A7),  A4
 BSR  HOLNAME
 MOVE  D6,-(A7)  attribut
 MOVE.L A4,-(A7) *fileName, wildcards erlaubt
 MOVE #$4E,-(A7) *searchFirst
 TRAP #1
 ADDQ #8,A7
 TST  D0
 BNE  BACKREAD
DIRAUT:
 BSR  NEWLINE
 MOVE #$2F,-(A7) *get DTA adress
 TRAP #1
 ADDQ #2,A7
 MOVE.L D0,A3
 MOVE.B 21(A3),D7 im 21.Byte der DTA steht das ATTRIBUT des file
 BSR  OUT2HEX
 MOVEQ #31,D7    um die SekundenBits auszufiltern
 AND.W 22(A3),D7 uhrzeit
 ADD.B D7, D7    weil kleinsteEinheit=2sec
 BSR  OUT2DEZ
 MOVE 22(A3),D7 uhrzeit
 LSR  #5,  D7   MinutenBits nun _0 bis _5
 AND  #$3F,D7
 BSR  OUT2DEZ
 MOVE 22(A3),D7 uhrzeit
 LSR  #3,  D7
 LSR  #8,  D7   stundenBits nun _0 bis _4
 BSR  OUT2DEZ
BSR BLANK
 MOVEQ #31,D7
 AND  24(A3),D7 datum,TageBits
 BSR  OUT2DEZ
 MOVE 24(A3),D7
 LSR  #5,  D7   MonatBits nun _0 bis _3
 AND  #15, D7
 BSR  OUT2DEZ
 MOVE 24(A3),D7
 LSR  #1, D7
 LSR  #8, D7   Jahr-1980 nun _0 bis _6
 ADD  #80,D7
 BSR  OUT2DEZ
BSR BLANK
 MOVE.L 26(A3),A4 L„nge
 BSR  OUT8HEX
 BSR  BLANK
 LEA  30(A3),A4   ab dem 30.Byte der DiskTransferArea steht der filename
 BSR  OUTABADR
 MOVE #$4F,-(A7)  searchNext
 TRAP #1
 ADDQ #2,(A7)
 TST  D0
 BNE  BACKREAD
 BRA  DIRAUT

NORMR:
 MOVE  #2, -(A7) *verwende les/schreibdateien
 MOVE.L A4,-(A7) *name
 MOVE  #$3D,-(A7) *open
 TRAP  #1
 ADDQ  #8, A7
 MOVE  D0, D5 *code, evtl Fehlercode, sonst handleNr
 BSR   NEWLINE
 MOVE  D5, D7
 BPL   OPNOK
 BSR   OUT4HEX
 BRA   BACKREAD
OPNOK:
 BSR   OUT4HEX
 LEA   TXT2(PC),A4
 BSR   OUTABADR
 BSR   HOLZAHL  *so startadr in d7.L
 BMI   VBACKR
 MOVE.L D7,-(A7)
 LEA   TLENGTH(PC),A4
 BSR   OUTABADR
 BSR   HOLZAHL  *so L„nge in d7.L
 BMI   VBACKR
 MOVE.L D7,-(A7)
 MOVE  D5, -(A7) *handle
 MOVE  #$3F,-(A7) *read
 TRAP  #1
 ADDA.W #12, A7
 MOVE.L D0,  D7 *TATSŽCHLICHE LŽNGE
 BSR   STRICH
 BSR   OUT6HEX
VBACKR:
 BSR   CLOSE

BACKREAD:
 LEA  88(A7),A7
 BRA  FRAG0

WRITE:
 LEA  TWRITE(PC),A4
 BSR  OUTABADR
 LEA  -88(A7),A7
 LEA  (A7),  A4
 BSR  HOLNAME
 BEQ  BACKWRIT

 MOVE  #0, -(A7) *verwende les/schreibdateien
 MOVE.L A4,-(A7) *name
 MOVE  #$3C,-(A7) *create
 TRAP  #1
 ADDQ  #8, A7
 MOVE  D0, D5 *code, evtl Fehlercode, sonst handleNr
 BSR   NEWLINE
 MOVE  D5, D7
 BPL   CREOK
 BSR   OUT4HEX
 BRA   BACKWRIT
CREOK:
 BSR   OUT4HEX
 LEA   TXT2(PC),A4
 BSR   OUTABADR
 BSR   HOLZAHL  *so startadr in d7.L
 BMI   VBACKW
 MOVE.L D7,-(A7)
 LEA   TLENGTH(PC),A4
 BSR   OUTABADR
 BSR   HOLZAHL  *so L„nge in d7.L
 BMI   VBACKW
 MOVE.L D7,-(A7)
 MOVE  D5, -(A7) *handle
 MOVE  #$40,-(A7) *WRITE
 TRAP  #1
 ADDA.W #12, A7
 MOVE.L D0,  D7 *TATSŽCHLICHE LŽNGE
 BSR   STRICH
 BSR   OUT6HEX
VBACKW:
 BSR   CLOSE

BACKWRIT:
 LEA  88(A7),A7
 BRA  FRAG0

CLOSE:
 MOVE.W D5,-(A7)  *handle
 MOVE.W #$3E,-(A7) *close
 TRAP   #1
 ADDQ.L #4, A7
 MOVE.L D0, D7 *code, evtl Fehlercode
* BSR   STRICH  Meldung unn”tig, weil praktisch nie Fehler auftritt
* BSR   OUT6HEX
RTS

INFO:
 LEA  ITXT(PC),A4
 BSR  OUTABADR
 LEA  ANF(PC),A4
 BSR  OUT8HEX
 BSR  BLANK
 LEA  ENDE(PC),A4
 BSR  OUT8HEX
 BSR  BLANK
 LEA  (A7),A4
 BSR  OUT8HEX
 BSR  BLANK
 LEA  EINST(PC),A4
 BSR  OUT8HEX
 LEA  TXT3(PC),A4
 BSR  OUTABADR
 MOVE.W SR,D7
 BSR  OUT4HEX
 LEA  TXT4(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL
 BMI  FRAG0   *wenn nix hex, dann statusRegister nicht aendern
 MOVE.W D7,SR
 BRA  FRAG0

RUN:
 LEA   TXT2(PC),A4
 BSR   OUTABADR
 BSR   HOLZAHL  *so startadr in d7.L
 BMI   FRAG0
 AND.W #-2,D7  *grade Adresse erzwingen
 MOVE.L D7,A4
 JMP   (A4)   *so wird ein anderes Programm gestartet

SUBST:
 LEA   STXT(PC),A4
 BSR   OUTABADR
 LEA   TXT2(PC),A4
 BSR   OUTABADR
 BSR   HOLZAHL  *so startadr in d7.L
 BMI   FRAG0
 AND.W #-2,D7  *grade Adresse erzwingen
 MOVE.L D7,A5
 BSR   NEWLINE
SULOO:
 MOVE.W A5,D7
 AND.W  #7,D7  *achterZahl? dann neue Zeile und Adresse vornweg
 BNE    SUZEI
SUGA:
 BSR    NEWLINE
 MOVE.L A5,D7
 BSR    OUT6HEX
 BSR    BLANK
SUZEI:
 MOVE.W (A5)+,D7
 BSR    OUT4HEX
 BSR    STRICH
 BSR    HOLZAHL
 BCS    WEISU   *eingabe mit Blank: weitermachen
 CMP.B  #$D,D4  *eingabe mit 'T'? dann bleib auf dieser Adresse
 BNE    SOBR
 SUBQ.L #2,A5
 BRA    SUGA
SOBR:
 CMP.B  #$B,D4  *eingabe mit 'R'? dann zurueck auf letzte Adress-Ausgabe
 BNE    FRAG0  *eingabe nicht mit Blank T oder R: abbreche Substitution
 MOVE.L A5,D7
 SUBQ.L #3,D7
 AND.W  #-8,D7
 MOVE.L D7,A5
 BRA    SUGA
WEISU:
 BMI    SULOO    *keinerlei hexZiffer vorm Blank getippt: next word zeige
 MOVE.W D7,-2(A5)
 BRA    SULOO

BSUBST:
 LEA   BTXT(PC),A4
 BSR   OUTABADR
 LEA   STXT(PC),A4
 BSR   OUTABADR
 LEA   TXT2(PC),A4
 BSR   OUTABADR
 BSR   HOLZAHL  *so startadr in d7.L
 BMI   FRAG0
 MOVE.L D7,A5
 BSR   NEWLINE
BULOO:
 MOVE.W A5,D7
 AND.W  #7,D7  *achterZahl? dann neue Zeile und Adresse vornweg
 BNE    BUZEI
BUGA:
 BSR    NEWLINE
 MOVE.L A5,D7
 BSR    OUT6HEX
 BSR    BLANK
BUZEI:
 MOVE.B (A5)+,D7
 BSR    OUT2HEX
 BSR    HOLZAHL
 BCS    WEIBU   *eingabe mit Blank: weitermachen
 CMP.B  #$D,D4  *eingabe mit 'T'? dann bleib auf dieser Adresse
 BNE    BOBR
 SUBQ.L #1,A5
 BRA    BUGA
BOBR:
 CMP.B  #$B,D4  *eingabe mit 'R'? dann zurck auf letzte Adress-Ausgabe
 BNE    FRAG0  *eingabe nicht mit Blank T oder R: abbreche Substitution
 MOVE.L A5,D7
 SUBQ.L #3,D7
 AND.W  #-8,D7
 MOVE.L D7,A5
 BRA    BUGA
WEIBU:
 BMI    BULOO    *keinerlei hexZiffer vorm Blank getippt: next BYTE zeige
 MOVE.B D7,-1(A5)
 BRA    BULOO

OUT2DEZ:
 DIVU #10,D7  ergebnis=MSD=d7.w divisionsRest=LSD=hiWord
 LSL.W #4,D7
 ROR.L #4,D7
 ROL.W #4,D7
OUT2HEX:
 ROR #4, D7
 BSR OUT1HEX
 ROL #4, D7
 BSR OUT1HEX
 BSR STRICH
 RTS

MUSTER:
 LEA  TM(PC),A4
 BSR  OUTABADR
 BSR  INBYTE  * sollte= 1,2,3 oder 4 sein
 MOVEQ #7,D6
 AND  D4, D6  *L„nge des Musters
 BEQ  FRAG0
 CMP  #4, D6
 BHI  FRAG0
 LEA  TM2(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL  *gibt in d7.L HexMuster
 BMI  FRAG0
 MOVE.L D7,D5  *merk Hex-Muster und rotiere es..
 MOVE  D6,D7   *..gem„ž seiner L„nge(=D6) so, daž..
U: SUBQ #1,D7  *..das vordere Byte in D6.B steht, das zweite im HiByte
 BEQ   MROK
 ROR.L #8,D5
 BRA   U
MROK:
 LEA  TM3(PC),A4
 BSR  OUTABADR
 BSR  INBYTE
* durch obiges  MOVEQ#7,D6  sind die oberen D6-bits Null!
 MOVE.W D4,-(A7)
 AND.B #$DF,D4
 CMP.B #'U',D4  *nur ab ungeraden Adressen suchen?
 BNE  OBG
 BSET #15, D6  *bit15_13_D6, wenn nur ab ungeradn
 BSET #13, D6
OBG:
 CMP.B #'G',D4
 BNE  NIXG
 BSET #15,D6  *bit15_14_D6, wenn nur ab geraden
 BSET #14,D6
NIXG:
 MOVE.W (A7)+,D4
 BTST  #5, D4
 BEQ  NREL
 BSET #12,D6  signalisier,daž pcRelative Werte mitgeprft
NREL:
 LEA  TXT2(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL
 BMI  FRAG0
 MOVE.L D7, A5   *merk startAdr
 LEA  TT4(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL
 BMI  FRAG0
 MOVE.L D7,A6   *merk EndAdr
 LEA  TM4(PC),A4
 BSR  OUTABADR

N1U:
 CMP.L A6,A5
 BHI   FRAG0
 TST.W D6     *alle Adr untersuch (pl)?
 BPL   NIXUG
 MOVE  A5,D7
 AND   #1,D7
 BNE   UNG
 BTST #14,D6 *grade Adr untersuch (ne)?
 BNE   NIXUG
 ADDQ  #1,A5
 BRA   NIXUG
UNG:
 BTST #13,D6 *ungrade Adr untersuch (ne)?
 BNE   NIXUG
 ADDQ  #1,A5
NIXUG:
 BTST #12,D6
 BEQ  NIXREL

 MOVE.L A5,-(A7)
 BTST   #0, 3(A7)
 MOVE.L (A7)+,A4
 BNE   N1XREL
 MOVEQ  #0, D4
 MOVE.B (A4),D4
 ADDA.W D4, A4  so,wie es pc-relativ gemacht wird bei xx(pc,a1)
 MOVE.L D5,D7
 ROR.L #8,D7  ganzesMusterWord=d7.L
 CMP.L A4,D7
 BNE   N1XREL
 LEA  P1TXT(PC),A4
 BRA  VNRL
N1XREL:
 MOVE.L A5,-(A7)
 BTST   #0, 3(A7)
 MOVE.L (A7)+,A4
 BNE    NIXREL
 ADDA.W (A4),A4  so,wie es pc-relativ gemacht wird
 MOVE.L D5,D7
 ROR.L #8,D7
 CMP.L A4,D7
 BNE  NIXREL
 LEA  P2TXT(PC),A4
VNRL:
 BSR  OUTABADR
 MOVE.L A5,D7  die Adr, auf ders Muster tats„chlich beginnt
 ADDQ.L #1,A5
 BSR  OUT6HEX
 BRA  MMELD
NIXREL:

 CMP.B (A5)+,D5
 BNE   N1U
 CMP.B #1,D6 *MusterL„nge=1byte?
 BEQ   MMELD
 MOVE.L D5,D7
 ROL.L  #8,D7 *2.byte des Musters in d7.B
 CMP.B (A5),D7
 BNE   N1U
 CMP.B #2,D6 *MusterL„nge=2byte?
 BEQ   MMELD
 ROL.L #8,  D7
 CMP.B 1(A5),D7
 BNE   N1U
 CMP.B #3,D6 *MusterL„nge=3byte?
 BEQ   MMELD
 ROL.L #8,  D7
 CMP.B 2(A5),D7
 BNE   N1U

MMELD:
 BSR   NEWLINE
 MOVE.L A5,D7
 SUBQ.L #1,D7  *die Adr, auf ders Muster tats„chlich beginnt
**++ BSR   OUT6HEX
**++ BSR   BLANK
 AND.L #$FFFFFE,D7 *die letzte grade Adr
 SUBQ.L #8,D7
 BSR   OUT6HEX
 MOVE.L A5,-(A7)
 MOVE.L D7, A5
 BSR    BLANK
 BSR    O4UNDBL
 BSR    O4UNDBL
 BSR    O4UNDBL
 BSR    O4UNDBL
 BSR    O4UNDBL
 BSR    O4UNDBL
 BSR    O4UNDBL
 BSR    O4UNDBL
 SUBA.W #16,A5
 MOVEQ #15,D7  *um auf 16 zu zaehlen
MUALOO:
 MOVE.B (A5)+,D4
 CMP.B  #' ',D4
 BCS    MUNOTOK
 CMP.B  #$7F,D4
**++ BCC MUNOTOK
 BRA MUOK
MUNOTOK:
 MOVEQ #$2E,D4 * '.' als hinweis, dass nichtascii oder steurzeichen
MUOK:
 BSR    OUTBYTE
 DBRA   D7,  MUALOO
 MOVE.L (A7)+,A5

 BSR   INBYTE
 CMP.B #' ',D4
 BEQ   N1U
BRA FRAG0

O4UNDBL:
 MOVE.W (A5)+,D7
 BSR    OUT4HEX
 BSR    BLANK
RTS

DUMP:
 LEA  DTXT(PC),A4
 BSR  OUTABADR
 LEA  TXT2(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL  *gibt Zahl in d7.L
 BMI  FRAG0
 BSR  NEWLINE
 AND.B #$F0,D7  *sechzehnerzahl
 MOVE.L D7,A5  *startadress des dump
 MOVEQ #15,D6  *16 zeilen
DULOO:
 MOVE.W A5,D7
 AND.W #15,D7  *sechzehnerzahl? dann newline und adresse vornweg
 BNE   DUZEI
 BSR   NEWLINE
 MOVE.L A5,D7
 BSR   OUT6HEX
DUZEI:
 BSR    BLANK
 MOVE.W (A5)+,D7
 BSR    OUT4HEX
 MOVE.W A5,D7
 AND.W #15,D7  *sechzehnerzahl? dann ASCII-darstellung des bishergn hintendran
 BNE   DUZEI
 BSR   BLANK
 SUBA.W #16,A5
 MOVEQ #15,D7  *um auf 16 zu zaehlen
DUALOO:
 MOVE.B (A5)+,D4
 CMP.B  #' ',D4
 BCS    DUNOTOK
 CMP.B  #$7F,D4
 BCS    DUOK
DUNOTOK:
 MOVEQ #$2E,D4 * '.' als hinweis, dass nichtascii oder steurzeichen
DUOK:
 BSR    OUTBYTE
 DBRA   D7,  DUALOO
DUZAH:
 DBRA   D6,  DULOO
 BSR    INBYTE
 CMP.B  #' ',D4
 BNE    FRAG0
 MOVEQ  #0, D6  *zaehle nur eine Zeile
 BRA    DULOO

TRANSFER:
 LEA  TT(PC),A4
 BSR  OUTABADR
 LEA  TXT2(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL  *gibt Zahl in d7.L  start,ab wo transfer
 BMI  FRAG0
 MOVE.L D7,A5  *BlockAnfang merke
 BSR  NEWLINE
 LEA  TT3(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL  *gibt Zahl in d7.L  soviele bytes (nur blank: end_adr frag)
 BCC  FRAG0
 BPL  TRELDIST

 BSR  NEWLINE
 LEA  TT4(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL  *gibt Zahl in d7.L  bishier geht block
 BMI  FRAG0
 ADDQ.L #1, D7 *erste Adresse HINTER dem Block
 SUB.L  A5, D7
TRELDIST:
 MOVE.L D7,D6  *byteAnzahl merke
 BEQ  FRAG0
 BMI  FRAG0

 BSR  NEWLINE
 LEA  TT5(PC),A4
 BSR  OUTABADR
 BSR  HOLZAHL  *gibt Zahl in d7.L  ab dorthin transfer
 BMI  FRAG0
 MOVE.L D7,A4  *merk zieladresse

 CMP.L  A5,A4  *zieladresse die kleinere (ls)? dann aufw„rtsLoop
 BLS    TL1
 ADD.L  D6,A4
 ADD.L  D6,A5
TL2:
 MOVE.B -(A5),-(A4)
 SUBQ.L #1,D6
 BHI    TL2
 BRA    FRAG0
TL1:
 MOVE.B (A5)+,(A4)+
 SUBQ.L #1,  D6
 BHI    TL1
 BRA    FRAG0



HOLZAHL:
*subroutine holt von Tastatur hexZiffern (bis nichtHex getippt), gibt
* entsprechnde Zahl in d7.L   ruft HOLDIG,gibt aber etwas andere flags weiter:
* CS: abschluss mit Blank oder Return
* CC: anderer Abschluss
* MI: gar kein hex getippt vorm Abschluss       futsch d7,d4,evtl mehr
* gibt letztes d4 aus HOLDIG weiter
 CLR.L D7
 BSR   HOLDIG
 BMI   RTHOL  *Lass flag MI zum Zeichen, dass keinerlei Hexziffer getippt
NOCHHOL:
 OR.B  D4,D7
 BSR   HOLDIG
 BMI   ENDHOL
 LSL.L #4,D7
 BRA   NOCHHOL
ENDHOL:
 AND.W #1,CCR *so flag PL, nur CS bleibt eventuell gesetzt
RTHOL:
 RTS

HOLDIG:
*subroutine holt eine hexziffer von Tastatur,ruft INBYTE
* gibt entsprechnde Zahl in d4.B, wenns hex war. dann flag PL
* gibt flag MI, wenns nichtHex war, zudem CS wenns BLANK oder RETURN war.
* gibt z.B. bei 'R' den code $B, also ascii minus $47
 BSR   INBYTE
 CMP.B #' ',D4
 BEQ   RCHOLDIG
 CMP.B #13,D4
 BEQ   RCHOLDIG
 CMP.B #'0',D4
 BCS   RMHOLDIG
 CMP.B #'9',D4
 BLS   RRHOLDIG
 AND.B #$DF,D4 *mach Grossbuchstabe
 SUB.B #$47,D4 *dadurch 'F'=$46 zu $FF gemacht
 BCC   RMHOLDIG *denn es war vorher > 'F'
 CMP.B #$FA,D4
 BCC   RRHOLDIG *dann wars vorher > 'A', also hexZiffer
RMHOLDIG:
 MOVE.W #8,CCR  *flag MI und CC
 BRA    RTHOLDIG
RCHOLDIG:
 MOVE.W #9,CCR *CondCodeRegister_Bits: bit3=MInus bit2=EQ bit1=oVerfSet bit0=CS
 BRA    RTHOLDIG
RRHOLDIG:
 AND.B #$0F,D4
RTHOLDIG:
 RTS

HOLNAME:
*subrou liest via INBYTE von Tastatur, bei Steuerzeichen: wiederhole
* bei Escape oder ControlC: abbrechendes Ende, REToderBLANK=normalesEnde
* will a4=BufferBereich, denn ab dort wird Name hingeschrieben
*  gibt flag eq, wenn Esc oder ContrC oder stringL„nge=0
 MOVE.L D4,-(A7)
 MOVE.L A4,-(A7)
STEUR:
 LEA  TNAME(PC),A4
 BSR   OUTABADR
 MOVE.L (A7), A4 *ab a4 tastatur einlesen
HNLOOP:
 BSR    INBYTE
 CMP.B  #$D,D4 *carrRet
 BEQ    ENDEING
 CMP.B  #$20,D4 *Blank
 BEQ    ENDEING
 CMP.B  #$1B,D4 *Esc
 BEQ    ERREING
 CMP.B  #$3,D4 *ContrC
 BEQ    ERREING
 CMP.B  #$7F,D4
 BEQ    STEUR
 CMP.B  #$1F,D4
 BLS    STEUR

 MOVE.B D4,(A4)+
 BRA    HNLOOP

ENDEING:
 CLR.B     (A4)
 CMP.L  (A7),A4 *ist stringl„nge =0? dann auch eq-flag
ERREING:
 MOVE.L (A7)+,A4
 MOVEM.L (A7)+,D4 *so flags nicht beeinflužt
RTS

OUTABADR:
*subroutine will a4=begin eines ascii-string,
* gibt dessen text aus, bis eine 0 kommt. ruft OUTBYTE.  futsch: d4,a4,evtlmehr
 MOVE.B (A4)+,D4
 BEQ    RTOUTAB
 BSR    OUTBYTE
 BRA    OUTABADR
RTOUTAB:
 RTS

HEX1:
*subroutine will in bits_3_2_1_0 von D7 eine Ziffer,
* macht daraus einen asciiCharacter (0..9 oder A..F) in D4.B
 MOVE.B #$0F,D4
 AND.B    D7,D4 * Ziffer herausmaskiert
 ADD.B  #$30,D4 * erzeug ascii gr/gl '0'
 CMP.B  #$3A,D4 * > '9' ? dann cc (CarryClear) ..
 BCS    OK09
 ADDQ.B #$07,D4 * ..und deshalb mindestens 'A' (=$41) erzeugen
OK09:
 RTS

OUT6HEX:
*subrou will d7=Longw,gibt 6hexZiff aus, BRA OUT06HEX  futsch: d4,evtlmehr
 ROL.L #8,D7
 BRA   OUT06HEX

OUT4HEX:
*subrou will d7=Longw,gibt 4hexZiff aus, BRA OUT04HEX  futsch: d4,evtlmehr
 SWAP   D7
 BRA  OUT04HEX

O1HX:
 ROL.L #4,D7
OUT1HEX:
*subroutine will in bits_3_2_1_0 von D7 eine Ziffer,ruft HEX1,
* somit asciiCharacter in D4.B, gibts auf tv via OUTBYTE.    futsch:d4,evtlmehr
 BSR HEX1
 BSR OUTBYTE
 RTS

OUT8HEX:
*subroutine will a4=Longword, gibt
* entsprechend acht hexziffern aufs tv   futsch: d7,d4, evtl mehr
 MOVE.L A4,D7
 ROL.L  #4,D7
 BSR   OUT1HEX
 BSR   O1HX
OUT06HEX:
 BSR   O1HX
 BSR   O1HX
OUT04HEX:
 BSR   O1HX
 BSR   O1HX
 BSR   O1HX
 BRA   O1HX

BLANK:
*subroutine gibt ein Leerzeichen aufs tv  futsch: a4,d4  evtl mehr
 LEA TBLANK(PC),A4
 BSR OUTABADR
 RTS

STRICH:
*subroutine gibt '_' aufs tv  futsch: a4,d4  evtl mehr
 LEA TSTRICH(PC),A4
 BSR OUTABADR
 RTS

NEWLINE:
*subroutine gibt carrRet-LineFeed auf tv  futsch: a4,d4  evtl mehr
 LEA TXT1310(PC),A4
 BSR OUTABADR
 RTS

TM:
 DC.B 13,10,'MUSTER SUCHEN, 1,2,3 ODER 4 BYTES? ',0
TM2:
 DC.B 13,10,'HEX EINTIPP: ',0
TM3:
 DC.B 13,10,'A-LLE/ G-ERADE/ U-NGERADE ADR ABSUCHEN? (SHIFT=NIX-PC-REL)',0
TM4:
 DC.B 13,10,'NUN ADR GEMELDET, WENN GEF. DANN BLANK=WEITERSUCH',0
TT:
 DC.B 13,10,'TRANSFER RAM-BLOCK AB',0
TT3:
 DC.B 13,10,'WIEVIEL BYTE (NUR BLANK: ERFRAG END-ADR) ',0
TT4:
 DC.B 13,10,'LETZTE ADR DES RAM-BLOCKS: ',0
TT5:
 DC.B 13,10,'TRANSFER DORTHIN: ',0
TXT1:
 DC.B 13,13,10,'INF GO SUBS HALFW LIST TRANS MUSTR R/WRIT QUIT >> ',0
TXT2:
 DC.B 13,10,'STARTADR: ',0
TXT3:
 DC.B 13,10,'STATUSREG BISHER: ',0
TXT4:
 DC.B '  TIP NEUES: ',0
ITXT:
 DC.B 13,10,' MON VON BIS      MONSTACK EINSTIEG',13,10,0
DTXT:
 DC.B 13,10,'NACH DUMP (16 ZEILEN) TIPPE M-ENUE ODER BLANK(=NOCHNEZEILE)',0
BTXT:
 DC.B 13,10,'BYTEWEISE AENDERN:',0
STXT:
 DC.B 13,10,'AENDRE MIT HEX UND BLANK. NUR BLANK=NEXT R=ZURUECK T=BLEIB',0
TXT1310:
 DC.B 13,10,0
TBLANK:
 DC.B ' ',0
TSTRICH:
 DC.B '_',0
TREAD:
 DC.B 13,10,'(". " {Punkt und Blank}=Directory!  VON FLOPPY LESEN, FILE-',0
TWRITE:
 DC.B 13,10,'UM AUF FLOPPY ZU SPEICHERN, FILE-',0
TNAME:
 DC.B 13,10,'NAME EINTIPPEN: ',0
TLENGTH:
 DC.B 13,10,'WIEVIELE BYTES: ',0
P1TXT:
 DC.B 13,10,'?VIA xx(PC,Rg):',0
P2TXT:
 DC.B 13,10,'?VIA iiii(PC):',0
TR2:
 DC.B ' ATTRIBUT(0=normal 10=sudir): ',0
TR3:
 DC.B '   NUN zB.  A:\*.*  ALS',0

.EVEN

OUTBYTE:
*subroutine will d4.B=ascii, gibts auf tv.
 MOVE D4,-(A7)
 MOVE #2,-(A7)
 TRAP #1
 ADDQ #4, A7
 RTS

INBYTE:
*subroutine wartet auf Tastatur und gibt in d4.B das, was von Tastatur gekommn
*
* macht IMMER GLEICH ECHO auf tv !!
*
 MOVE #7,-(A7)
 TRAP #1
 ADDQ #2, A7
 MOVE.B D0,D4
 BSR  OUTBYTE * hier also ECHO
 RTS

QUIT:
 CLR -(A7)
 TRAP #1

ENDE:
 DC.W 0
.END

