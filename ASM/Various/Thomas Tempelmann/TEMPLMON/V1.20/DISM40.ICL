;
; Dies ist ein Include-File fuer TEMPLEMON
;
;  V#0028
;
; 19.6.86: PC-Rel. Adr. wird mit abs. Adr. ausgegeben
; 28.7.86: PC-Rel: bei Byteoffset ANDI #$FF,2nd_word
;          MOVE to CCR : 'R' wird nun auch ausgegeben (CCROUT:BRA->BSR)
; 13.1.87: BTST #  jetzt richtiger
; 11.8.91: Implementierung der 68040 Befehle, MOVE from CCR implementiert

          BRA.L   DISASM2

!DISMCONVREAL
          MOVEM.L A0-A6,-(SP)
          BSR     CONVREAL
          MOVEM.L (SP)+,A0-A6
          RTS

DSOUT     LEA     DBuffer(A4),A1
          MOVE.L  A1,A0
          BSR     PutLine
          MOVE.L  pMonScreen(PC),A2
          
          ADDA.L  tmon_offset(A4),A2
          MOVE.W  CursorY(A4),D0
          MOVE.W  video_line_bytes(A4),D4
          MULU.W  D4,D0
          ASL.L   #3,D0                   ; Multiplikation mit 8
          CMPI.W  #8,CharHeight(A4)
          BEQ     DSOUT1
          ASL.L   #1,D0
DSOUT1    ADDA.L  D0,A2
          MOVE.W  Rows(A4),D0
          MOVEQ   #0,D1
          CMPI.W  #1,video_plane(A4)
          BEQ.L   FastString16_8
          BRA.L   FastString8_8

          
!ANZTAB   DC.B    0
          DC.B    18 ; FORMAT0=BTST..CMPI
          DC.B    0  ; 3 MOEGL. MOVE BEFEHLE
          DC.B    0
          DC.B    1
          DC.B    40 ; FORMAT4
          DC.B    5  ; FORMAT5=DB..,S..,ADDQ,SUBQ,TRAPcc
          DC.B    1  ; FORMAT6= BRANCH
          DC.B    1  ; FORMAT7=MOVEQ
          DC.B    6  ; FORMAT8=DIVS,DIVU,SBCD,OR,PACK,UNPK
          DC.B    2  ; FORMAT9=SUBX,SUB
          DC.B    0  ; FORMAT10=FEHLER
          DC.B    3  ; FORMAT11=CMP,CMPM,EOR
          DC.B    6  ; FORMAT12=AND,MULS,MULU,ABCD,EXG (2*mal)
          DC.B    2  ; FORMAT13=ADDX,ADD
          DC.B    12 ; FORMAT14
          DC.B    75 ; FORMAT15
          SYNC
;
!FORMTAB  BRA.L   FORMAT0
          BRA.L   FORMATMO
          BRA.L   FORMATMO
          BRA.L   FORMATMO
          BRA.L   FORMAT4
          BRA.L   FORMAT5
          BRA.L   FORMAT6
          BRA.L   FORMAT7
          BRA.L   FORMAT8
          BRA.L   FORMAT9
          BRA.L   FORMERR
          BRA.L   FORMAT11
          BRA.L   FORMAT8 ;BIS AUF AND-BEFEHL IDENTISCH
          BRA.L   FORMAT9 ;IDENTISCH MIT FORMAT13
          BRA.L   FORMAT14
          BRA.L   FORMAT15
;
!DISASM2  BSR     DISASM21
          BRA     PRT40

!DISASM21 BCLR    #30,D7
          CLR.W   DisPrt(A4)
          MOVEA.L A1,A0
          MOVEA.L A1,A2
          MOVEA.L A1,A3
          MOVEQ   #-1,D0
          MOVE.W  D0,DCode(A4)
          MOVE.L  A1,D0
          BSR.L   DPRTADR
          BSR.L   DPRTSPC
          MOVE    (A1)+,D2 ;CODE HOLEN
          MOVE.L  A1,DTemp(A4)
          MOVE    D2,D3
          MOVE    D2,D6
          MOVEQ   #0,D4
          LSR     #8,D3 ;4 HOECHSTE BITS ISOLIEREN
          LSR     #4,D3
          MOVE    D3,D1
          LEA     ANZTAB(PC),A0
!MNFORM   ADD.B   $0(A0,D3.W),D4
          SUBQ    #1,D3
          BPL     MNFORM
          ASL     #2,D1
          LEA     FORMTAB(PC),A0
          ADDA.W  D1,A0
          MOVE.L  A7,DReturn(A4)
          JMP     (A0)
          
!PRT40    BSR.L   DPRTSPC
          CMPI.W  #50,DCursorX(A4)       ; von 40 auf 50 geÑndert
          BMI     PRT40
!DISHEX   MOVE.B  (A2)+,D0
          BSR.L   DPRTBYTE
          MOVE.B  (A2)+,D0
          BSR.L   DPRTBYTE
          BSR.L   DPRTSPC
          MOVE.W  DCursorX(A4),D0
          CMP.W   #80,D0
          BCC     DISASCE
          CMPA.L  A1,A2
          BNE     DISHEX
!PRT60    BSR.L   DPRTSPC
          CMPI.W  #71,DCursorX(A4)
          BMI     PRT60
!DISASC   MOVE.B  (A3)+,D0
          ANDI.B  #$7F,D0
          CMPI.B  #$20,D0
          BCC.S   DISASCP
          MOVEQ   #'.',D0
!DISASCP  BSR.L   DPRT
          MOVE.W  DCursorX(A4),D0
          CMPI.W  #80,D0
          BCC     DISASCE
          CMPA.L  A1,A3
          BNE     DISASC
          MOVE.W  DCursorX(A4),D0
          CMPI.W  #79,D0
          BLS     DISASCE
          MOVEQ   #79,D0
DISASCE   MOVE.W  D0,CursorX(A4)
          BSR     DPUT
          BRA.L   DISASEND

!DPUT     MOVEQ   #SPC,D0
          MOVE.W  DCursorX(A4),D1
          MOVE.W  D1,-(SP)          ; Cursor Position merken
!DPUT1    CMPI.W  #80,DCursorX(A4)
          BCC     DPUT2
          BSR     DPRT
          BRA     DPUT1
!DPUT2    MOVE.W  (SP)+,D1          ; Cursor Position holen
          TST     DisPrt(A4)
          BNE     noDisPrt
          MOVEM.L D1/D4/A1/A2,-(SP)
          BSR     DSOUT
          MOVEM.L (SP)+,D1/D4/A1/A2
          TST.W   PrHandle(A4)
          BEQ     DPUTE
          MOVEQ   #0,D2
          LEA     DBuffer(A4),A0
          SUBQ    #1,D1
          BMI     DPUTE
DPUT3     MOVE.B  (A0)+,D0
          BSR     FPrt
          DBRA    D1,DPUT3
DPUTE     RTS
!DPRTSPC  MOVEQ   #SPC,D0
!DPRT     CMPI.B  #CR,D0
          BEQ     noDisPrt
          CMPI.B  #LF,D0
          BEQ     noDisPrt
          MOVE.L  A0,-(SP)
          LEA     DBuffer(A4),A0
          ADDA.W  DCursorX(A4),A0
          MOVE.B  D0,(A0)
          ADDQ.W  #1,DCursorX(A4)
          MOVE.L  (SP)+,A0
noDisPrt  RTS
!DPRTADR  TST.W   isD20(A4)
          BNE.S   DPrtLong
          SWAP    D0
          BSR.S   DPRTBYTE
          BRA.S   DPRTLONG1
!DPRTLONG SWAP    D0
          BSR.S   DPRTWORD
!DPRTLONG1 SWAP    D0
!DPRTWORD MOVE.W  D0,-(A7)
          LSR.W   #8,D0
          BSR.S   DPRTBYTE
          MOVE.W  (A7)+,D0
!DPRTBYTE MOVE.W  D0,-(A7)
          LSR.B   #4,D0
          BSR.S   DPRTNIBL
          MOVE.W  (A7)+,D0
!DPRTNIBL ANDI.B  #$F,D0
          ORI.B   #$30,D0
          CMPI.B  #'9',D0
          BLS.S   DPRTNIBL1
          ADDQ.B  #7,D0
!DPRTNIBL1 BRA     DPrt
;
;
!CCTAB    ASC     'T F HILSCCCSNEEQ'
          ASC     'VCVSPLMIGELTGTLE'
          ASC     'RASR'
!FCCTAB   ASC     'F   EQ  OGT OGE OLT OLE OGL OR  UN  UEQ UGT UGE ULT ULE NE  T   '
          ASC     'SF  SEQ GT  GE  LT  LE  GL  GLE NGLENGL NLE NLT NGE NGT SNE ST  '
;
;CODETABELLE
;
; Aufbau der Codetabelle:
; erstes Langwort : Mnemnonik (5 Bits pro Char) = 6 Zeichen plus 2 Bits 7. Zeichen
; zweites Langwort: 3 Bits 7. Zeichen + 8. Zeichen (Bits 31-24), zugelassene
;                   EA's (Bits 23-12), Test auf EA (Bit 11) bei Mnemnonikausgabe,
;                   Prozessortyp (Bit 10 68040-68020, Bit 9 68010, Bit 8 68000;
;                   bei Line F Codes Bit 10 68040, Bit 9 68030, Bit 8 FPU),
;                   Formatnummer (Bit 7 - 0)
;                   EA Kodierung: Bit 23 : Mode 7 Register 3   d8(PC,Xn)
;                                     22 :      7          2   d16(PC)
;                                     21 :      7          4   #<data>
;                                     20 :      7          1   (xxx).L
;                                     19 :      7          0   (xxx).W
;                                     18 :      6              d8(An,Xn)
;                                     17 :      5              d16(An)
;                                     16 :      4              -(An)
;                                     15 :      3              (An)+
;                                     14 :      2              (An)
;                                     13 :      1              An
;                                     12 :      0              Dn
;                   Zeichenkodierung: Ein Zeichen besteht aus 5 Bits
;                                     = 0 Mnemnonikende
;                                     = 1  = 'A'
;                                     = 27 = 'Z'
;                                     = 28 = '2'
;                                     = 29 = '.'  bzw. '1' bei F Code
;                                     = 30 = '16' bzw. '0' bei F Code
;
; Die Tabelle ist sortiert nach dem obersten Nibble des Befehls. Format0
; entspricht den Befehlen, die binÑr kodiert mit 0 anfangen.
;
; Achtung, die Adressierungsart Mode 7, Register 4 (# unmittelbar) entspricht
; bei den logischen VerknÅpfungen immediate dem 'to SR' bzw. 'to CCR'.
;
; Die Umwandlung der Mnemnonik in jeweils 5 Bit groûe Zahlen kann mit Hilfe
; eines Turbo Pascal Pogrammes geschehen:
;
;program str;
;
;uses utis;  (* nur fÅr die Funktion dez2hex, die eine Zahl als Hexstring
;               umwandelt *)
;
;var inp : string;
;    o1,o2,h : longint;
;    c,b : byte;
;
;procedure get(c : byte);
;
;begin
;  if ((inp[c] >= 'A') and (inp[c] <= 'Z')) then
;    h := longint(ord(inp[c])-ord('A')+1)
;  else begin
;    case inp[c] of '2' : h := 28;
;                   '1' : h := 29;
;                   '0' : h := 30;
;    end
;  end
;end;
;
;function dez2hex(z : longint; s : byte) : string;
;
;var st : string;
;    i : byte;
;    v : byte;
;
;  function hexziff(a : byte) : char;
;
;  var c : char;
;
;  begin
;    if a > 9 then c := chr(a + 55)
;    else c := chr(a + 48);
;    hexziff := c;
;  end;
;
;begin
;  st := '';
;  for i := 1 to s do begin
;    v := byte(z mod 16);
;    st := hexziff(v) + st;
;    z := z div 16
;  end;
;  dez2hex := st;
;end;
;
;
;begin
;  repeat
;    write('Befehlsmemnonik eingeben : ');
;    readln(inp);
;    o1 := 0;
;    o2 := 0;
;    for c := 1 to length(inp) do inp[c] := upcase(inp[c]);
;    b := length(inp);
;    if b > 6 then b := 6;
;    for c := 1 to b do begin
;      get(c);
;      h := h shl (32-(c*5));
;      o1 := o1 or h;
;    end;
;    if length(inp) > b then begin
;      get(7);
;      h := h shr 3;
;      o1 := o1 or h;
;      get(7);
;      h := h shl 29;
;      o2 := o2 or h;
;      if length(inp) > 7 then begin
;        get(8);
;        h := h shl 24;
;        o2 := o2 or h;
;      end;
;    end;
;    writeln('DC.L $',dez2hex(o1,8));
;    writeln('DC.L $',dez2hex(o2,8));
;  until inp = '';
;end.
;
;
;
;FORMAT0
;
!CODETAB  DC.L    $6BEC5800 ; MOVEP Format 17, Proz. 00/10/20-40
          DC.L    $00000711
          DC.L    $7C920000 ; ORI   Format 14             "
          DC.L    $001FD70E
          DC.L    $0B889000 ; ANDI  Format 14             "
          DC.L    $001FD70E
          DC.L    $9D449000 ; SUBI  Format 14             "
          DC.L    $001FDF0E
          DC.L    $09089000 ; ADDI  Format 14             "
          DC.L    $001FDF0E
          DC.L    $6BEC5980 ; MOVES Format 29, Proz. 10/20-40
          DC.L    $001FCE1D
          DC.L    $2BE49000 ; EORI  Format 14, Proz. 00/10/20-40
          DC.L    $001FD70E
          DC.L    $1B609000 ; CMPI  Format 14             "
          DC.L    $001FDF0E
          DC.L    $15274000 ; BTST  Format 13             "
          DC.L    $00FFDF0D
          DC.L    $10D07000 ; BCHG  Format 13             "
          DC.L    $001FDF0D
          DC.L    $10D92000 ; BCLR  Format 13             "
          DC.L    $001FDF0D
          DC.L    $14CB4000 ; BSET  Format 13             "
          DC.L    $001FDF0D
          DC.L    $1A17C000 ; CHK2  Format 32, Proz. 20-40
          DC.L    $00DE4C20
          DC.L    $1B61C000 ; CMP2  Format 32, Proz. 20-40
          DC.L    $00DE4C20
          DC.L    $18660000 ; CAS   Format 30, Proz. 20-40
          DC.L    $001FCC1E
          DC.L    $1867C000 ; CAS2  Format 31, Proz. 20-40
          DC.L    $0000041F
          DC.L    $951A0000 ; RTM   Format 15, Proz. 20
          DC.L    $0000040F
          DC.L    $1858C680 ; CALLM Format 29, Proz. 20
          DC.L    $00DE4C1D
;
;FORMAT1,2,3
;
          DC.L    $6BEC5000 ; MOVE  Format 2 , Proz. 00/10/20-40
          DC.L    $00FFF702
;
;FORMAT4
;
;
;
          DC.L    $91665A00 ; RESET  FORMAT 0 , PROZ. 00/10/20-40
          DC.L    $00000700
          DC.L    $73E00000 ; NOP    FORMAT 0              "
          DC.L    $00000700
          DC.L    $9D1F0000 ; STOP   FORMAT 27             "
          DC.L    $0000071B
          DC.L    $950A0000 ; RTE    FORMAT 0              "
          DC.L    $00000700
          DC.L    $95080000 ; RTD    FORMAT 0 , PROZ. 10/20-40
          DC.L    $00000600
          DC.L    $95260000 ; RTS    FORMAT 0 , PROZ. 00/10/20-40
          DC.L    $00000700
          DC.L    $A4830B00 ; TRAPV  FORMAT 0              "
          DC.L    $00000700
          DC.L    $95240000 ; RTR    FORMAT 0              "
          DC.L    $00000700
          DC.L    $4B185385 ; ILLEGAL FORMAT 0             "
          DC.L    $80000700
          DC.L    $6BEC5180 ; MOVEC  FORMAT 36, PROZ. 10/20-40
          DC.L    $00000624
          DC.L    $12E14000 ; BKPT   FORMAT 41, PROZ. 10/20-40
          DC.L    $00000629
          DC.L    $9DC30000 ; SWAP   FORMAT 1 , PROZ. 00/10/20-40
          DC.L    $00000701
          DC.L    $2E29DB80 ; EXT.W  FORMAT 18             "
          DC.L    $00000712
          DC.L    $2E29D600 ; EXT.L  FORMAT 18             "
          DC.L    $00000712
          DC.L    $2E282EB0 ; EXTB.L FORMAT 18, PROZ. 20-40
          DC.L    $00000412
          DC.L    $AB98B000 ; UNLK   FORMAT 15, PROZ. 00/10/20-40
          DC.L    $0000070F
          DC.L    $625CB000 ; LINK   FORMAT 20             " (WORD FORMAT)
          DC.L    $00000714
          DC.L    $625CB000 ; LINK   FORMAT 39, PROZ. 20-40  (LONG FORMAT)
          DC.L    $00000427
          DC.L    $6BEC5000 ; MOVE USP FORMAT 22, PROZ. 00/10/20-40
          DC.L    $00000716
          DC.L    $A4830000 ; TRAP   FORMAT 21             "
          DC.L    $00000715
          DC.L    $6D580000 ; MULUL & MULUSL FORMAT 33, PROZ. 20-40
          DC.L    $00FFDC21
          DC.L    $226C0000 ; DIVUL & DIVUSL FORMAT 33, PROZ. 20-40
          DC.L    $00FFDC21
          DC.L    $54E40000 ; JSR    Format 1 , Proz. 00/10/20-40
          DC.L    $00DE4F01
          DC.L    $53600000 ; JMP    Format 1              "
          DC.L    $00DE4F01
          DC.L    $6BEC5000 ; MOVE VON SR Format 23        "
          DC.L    $001FDF17
          DC.L    $6BEC5000 ; MOVE TO CCR Format 25        "
          DC.L    $00FFDF19
          DC.L    $6BEC5000 ; MOVE FROM CCR Format 40      "
          DC.L    $001FDF28
          DC.L    $6BEC5000 ; MOVE TO SR Format 24         "
          DC.L    $00FFDF18
          DC.L    $70864000 ; NBCD Format 1                "
          DC.L    $001FDF01
          DC.L    $81420000 ; PEA Format 1                 "
          DC.L    $00DE4F01
          DC.L    $A0660000 ; TAS Format 1                 "
          DC.L    $001FDF01
          DC.L    $6BEC5680 ; MOVEM REG TO <EA> Format 19  "
          DC.L    $001F4F13
          DC.L    $6BEC5680 ; MOVEM <EA> TO REG Format 19  "
          DC.L    $00DECF13
          DC.L    $714F8000 ; NEGX Format 8                "
          DC.L    $001FDF08
          DC.L    $1B240000 ; CLR Format 8                 "
          DC.L    $001FDF08
          DC.L    $714E0000 ; NEG Format 8                 "
          DC.L    $001FDF08
          DC.L    $73E80000 ; NOT Format 8                 "
          DC.L    $001FDF08
          DC.L    $A4E80000 ; TST Format 8                 "
          DC.L    $00FFF708
          DC.L    $1A160000 ; CHK Format 9                 "
          DC.L    $00FFDF09
          DC.L    $61420000 ; LEA Format 26                "
          DC.L    $00DE4F1A
;
;
;
;FORMAT5
;
          DC.L    $20800000 ; DB..   Format 3 , Proz. 00/10/20-40
          DC.L    $00000703
          DC.L    $A4830000 ; TRAPcc FORMAT 37, Proz. 20-40
          DC.L    $00000425
          DC.L    $98000000 ; S..    Format 4 , Proz. 00/10/20-40
          DC.L    $001FDF04
          DC.L    $09091000 ; ADDQ   Format 5              "
          DC.L    $001FFF05
          DC.L    $9D451000 ; SUBQ   Format 5              "
          DC.L    $001FFF05
;
;FORMAT6
;
          DC.L    $10000000 ; B..    Format 6              "
          DC.L    $00000706
;
;FORMAT7
;
          DC.L    $6BEC5880 ; MOVEQ  Format 7              "
          DC.L    $00000707
;
;FORMAT8
;
          DC.L    $98864000 ; SBCD   Format 11             "
          DC.L    $0000070B
          DC.L    $8046B000 ; PACK   Format 34, Proz. 20-40
          DC.L    $00000422
          DC.L    $ABA0B000 ; UNPK   Format 34,         "
          DC.L    $00000422
          DC.L    $226D5000 ; DIVU   Format 9 , Proz. 00/10/20-40
          DC.L    $00FFDF09
          DC.L    $226D3000 ; DIVS   Format 9              "
          DC.L    $00FFDF09
          DC.L    $7C800000 ; OR     Format 10             "
          DC.L    $00FFDF0A
;
;FORMAT9
;
          DC.L    $9D458000 ; SUBX   Format 11             "
          DC.L    $0000070B
          DC.L    $9D440000 ; SUB    Format 10             "
          DC.L    $00FFF70A
;
;FORMAT11
;
          DC.L    $1B600000 ; CMP    Format 10             "
          DC.L    $00FFF70A
          DC.L    $1B60D000 ; CMPM   Format 28             "
          DC.L    $0000071C
          DC.L    $2BE40000 ; EOR    Format 10             "
          DC.L    $00FFF70A
;
;FORMAT12
;
          DC.L    $08864000 ; ABCD   Format 11, Proz. 00/10/20-40
          DC.L    $0000070B
          DC.L    $2E0E0000 ; EXG    Format 12             "
          DC.L    $0000070C
          DC.L    $2E0E0000 ; EXG    Format 12             "
          DC.L    $0000070C
          DC.L    $6D595000 ; MULU   Format 9              "
          DC.L    $00FFDF09
          DC.L    $6D593000 ; MULS   Format 9              "
          DC.L    $00FFDF09
          DC.L    $0B880000 ; AND    Format 10             "
          DC.L    $00FFDF0A
;
;FORMAT13
;
          DC.L    $09098000 ; ADDX   Format 11             "
          DC.L    $0000070B
          DC.L    $09080000 ; ADD    Format 10             "
          DC.L    $00FFF70A
;
;FORMAT14
;
          DC.L    $11868380 ; BFCHG  Format 35, Proz. 20-40
          DC.L    $001E4423
          DC.L    $1186C900 ; BFCLR  Format 35          "
          DC.L    $001E4423
          DC.L    $1192E980 ; BFINS  Format 35          "
          DC.L    $001E4423
          DC.L    $118C6780 ; BFFFO  Format 35          "
          DC.L    $001E4423
          DC.L    $11A65A00 ; BFSET  Format 35          "
          DC.L    $001E4423
          DC.L    $11A93A00 ; BFTST  Format 35          "
          DC.L    $001E4423
          DC.L    $118B8A4C ; BFEXTS Format 35          "
          DC.L    $001E4423
          DC.L    $118B8A54 ; BFEXTU Format 35          "
          DC.L    $001E4423
          DC.L    $0CC00000 ; AS.    Format 16, Proz. 00/10/20-40
          DC.L    $001FC710
          DC.L    $64C00000 ; LS.    Format 16             "
          DC.L    $001FC710
          DC.L    $93F00000 ; ROX.   Format 16             "
          DC.L    $001FC710
          DC.L    $93C00000 ; RO.    Format 16             "
          DC.L    $001FC710
;
;FORMAT15
;
          DC.L    $835F6280 ; PMOVE  Format 45, Proz. 030, TT Register
          DC.L    $001E4A2D
          DC.L    $831E1200 ; PLOAD  Format 44, Proz. 030
          DC.L    $001E4A2C
          DC.L    $819959A0 ; PFLUSH Format 43, Proz. 030
          DC.L    $001E4A2B
          DC.L    $835F6280 ; PMOVE  Format 45, Proz. 030, SRP,CRP,TC,PSR
          DC.L    $001E4A2D
          DC.L    $850B3A00 ; PTEST  Format 42, Proz. 030
          DC.L    $001E4A2A
;
          DC.L    $1C2B3400 ; CPUSH  Format 46, Proz. 040
          DC.L    $0000042E
          DC.L    $1A5D6000 ; CINV   Format 46, Proz. 040
          DC.L    $0000042E
;
          DC.L    $850B3A00 ; PTEST  Format 48, Proz. 040
          DC.L    $00000430
          DC.L    $819959A0 ; PFLUSH Format 47, Proz. 040
          DC.L    $0000042F
;
          DC.L    $6BEC5F00 ; MOVE16 Format 49, Proz. 040
          DC.L    $00000431
;
          DC.L    $335F6280 ; FMOVE   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $325D4000 ; FINT    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $34D2E400 ; FSINH   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $325D4968 ; FINTRZ  Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $34E32A00 ; FSQRT   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $331E7743 ; FLOGNP1 Format 50, Proz. FPU/040
          DC.L    $A0FFDD32
          DC.L    $3168FC37 ; FETOXM1 Format 50, Proz. FPU/040
          DC.L    $A0FFDD32
          DC.L    $3502E400 ; FTANH   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $30681700 ; FATAN   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $30669700 ; FASIN   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $30681720 ; FATANH  Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $34D2E000 ; FSIN    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $3502E000 ; FTAN    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $3168FC00 ; FETOX   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $352EFA3F ; FTWOTOX Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $350AEA3F ; FTENTOX Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $331E7700 ; FLOGN   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $331E7EF8 ; FLOG10  Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $331E7E00 ; FLOG2   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $30453000 ; FABS    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $30DF3400 ; FCOSH   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $338A7000 ; FNEG    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $3046F980 ; FACOS   Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $30DF3000 ; FCOS    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $31CB42E2 ; FGETEXP Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $31CB4685 ; FGETMAN Format 50, Proz. FPU/040
          DC.L    $C0FFDD32
          DC.L    $31136000 ; FDIV    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $335E4000 ; FMOD    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $30484000 ; FADD    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $336AC000 ; FMUL    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $34CEC226 ; FSGLDIV Format 50, Proz. FPU/040
          DC.L    $C0FFDD32
          DC.L    $348AD000 ; FREM    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $34C61614 ; FSCALE  Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $34CEC6D5 ; FSGLMUL Format 50, Proz. FPU/040
          DC.L    $80FFDD32
          DC.L    $34EA2000 ; FSUB    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $34D2E1BE ; FSINCOS Format 61, Proz. FPU/040
          DC.L    $60FFDD3D
          DC.L    $30DB0000 ; FCMP    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $35274000 ; FTST    Format 50, Proz. FPU/040
          DC.L    $00FFDD32
          DC.L    $34DAFB14 ; FSMOVE  Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $34E71950 ; FSSQRT  Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $311AFB14 ; FDMOVE  Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $31271950 ; FDSQRT  Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $34C22980 ; FSABS   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $34DC5380 ; FSNEG   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $31022980 ; FDABS   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $311C5380 ; FDNEG   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $34C89B00 ; FSDIV   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $34C24200 ; FSADD   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $34DB5600 ; FSMUL   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $31089B00 ; FDDIV   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $31024200 ; FDADD   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $311B5600 ; FDMUL   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $34E75100 ; FSSUB   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $31275100 ; FDSUB   Format 50, Proz. 040
          DC.L    $00FFDC32
          DC.L    $335F628E ; FMOVECR Format 53, Proz. FPU/040
          DC.L    $40000535
          DC.L    $335F6280 ; FMOVE   Format 55, Proz. FPU/040 ; from FPn to EA
          DC.L    $001FDD37
          DC.L    $335F6280 ; FMOVE   Format 51, Proz. FPU/040 ; from/to FPcr
          DC.L    $00FFFD33
          DC.L    $335F62B4 ; FMOVEM  Format 52, Proz. FPU/040 ; from/to FPcr
          DC.L    $00FFFD34
          DC.L    $335F62B4 ; FMOVEM  Format 54, Proz. FPU/040 ; from/to FPn
          DC.L    $00DFCD36
          DC.L    $34C00000 ; FS..    Format 58, Proz. FPU/040
          DC.L    $001FDD3A
          DC.L    $31040000 ; FDB..   Format 59, Proz. FPU/040
          DC.L    $0000053B
          DC.L    $35241800 ; FTRAPcc Format 56, Proz. FPU/040
          DC.L    $00000538
          DC.L    $339F0000 ; FNOP    Format 0 , Proz. FPU/040
          DC.L    $00000500
          DC.L    $30800000 ; FB..    Format 57, Proz. FPU/040
          DC.L    $00000539
          DC.L    $34C36280 ; FSAVE   Format 1 , Proz. FPU/040
          DC.L    $001F4D01
          DC.L    $348B3A3E ; FRESTORE Format 1, Proz. FPU/040
          DC.L    $451ECD01
;
!SPRTAB   BRA.L   TYP0
          BRA.L   TYP1
          BRA.L   TYP2
          BRA.L   TYP3
          BRA.L   TYP4
          BRA.L   TYP5
          BRA.L   TYP6
          BRA.L   TYP7
          BRA.L   TYP8
          BRA.L   TYP9
          BRA.L   TYP10
          BRA.L   TYP11
          BRA.L   TYP12
          BRA.L   TYP13
          BRA.L   TYP14
          BRA.L   TYP15
          BRA.L   TYP16
          BRA.L   TYP17
          BRA.L   TYP18
          BRA.L   TYP19
          BRA.L   TYP20
          BRA.L   TYP21
          BRA.L   TYP22
          BRA.L   TYP23
          BRA.L   TYP24
          BRA.L   TYP25
          BRA.L   TYP26
          BRA.L   TYP27
          BRA.L   TYP28
          BRA.L   TYP29
          BRA.L   TYP30
          BRA.L   TYP31
          BRA.L   TYP32
          BRA.L   TYP33
          BRA.L   TYP34
          BRA.L   TYP35
          BRA.L   TYP36
          BRA.L   TYP37
          BRA.L   TYP38
          BRA.L   TYP39
          BRA.L   TYP40
          BRA.L   TYP41
          BRA.L   TYP42
          BRA.L   TYP43
          BRA.L   TYP44
          BRA.L   TYP45
          BRA.L   TYP46
          BRA.L   TYP47
          BRA.L   TYP48
          BRA.L   TYP49
          BRA.L   TYP50
          BRA.L   TYP51
          BRA.L   TYP52
          BRA.L   TYP53
          BRA.L   TYP54
          BRA.L   TYP55
          BRA.L   TYP56
          BRA.L   TYP57
          BRA.L   TYP58
          BRA.L   TYP59
          BRA.L   TYP60
          BRA.L   TYP61
;
;
!PRPPTAB  BSR     PUNKT
          MOVEQ   #'P',D0
          BRA     PRP_TAB
!PRPXTAB  BSR     PUNKT
          MOVEQ   #'X',D0
          BRA     PRP_TAB
!PRPDTAB  BSR     PUNKT
          MOVEQ   #'D',D0
          BRA     PRP_TAB
!PRPSTAB  BSR     PUNKT
          MOVEQ   #'S',D0
          BRA     PRP_TAB
!PRPLTAB  BSR     PUNKT
          MOVEQ   #'L',D0
          BRA     PRP_TAB
!PRPBTAB  BSR     PUNKT
          MOVEQ   #'B',D0
          BRA     PRP_TAB
!PRPWTAB  BSR     PUNKT
          MOVEQ   #'W',D0
!PRP_TAB  BSR.L   DPRT
!DPRTTAB  BSR.L   DPRTSPC
          CMPI.W  #20,DCursorX(A4)
          BMI     DPRTTAB
          RTS
!PUNKT    MOVEQ   #'.',D0
          BRA     RAUS1
!EKLAMZU  MOVEQ   #']',D0
          BRA.S   RAUS1
!EKLAMAUF MOVEQ   #'[',D0
          BRA.S   RAUS1
!KLAMZU   MOVEQ   #')',D0
          BRA.S   RAUS1
!KLAMAUF  MOVEQ   #'(',D0
!RAUS1    BRA.L   DPRT
!IMM      MOVEQ   #'#',D0
          BRA     RAUS1
!DOLLAR   MOVEQ   #'$',D0
          BRA     RAUS1
!KOMMA    MOVEQ   #',',D0
          BRA     RAUS1
!MAL      MOVEQ   #'*',D0
          BRA     RAUS1
!DOPPELPKT MOVEQ  #':',D0
          BRA     RAUS1
;
;
;AUSGABE  DER     MNEMONIC
;
!MNREGTAB DC.B    0,1,3,4,2
          SYNC
;
!MNRAUS   MOVE    D2,D6
          MOVE    D3,D5          ; erstes Wort nach Befehl bei FPU $F1xx
          MOVE.W  D4,DCode(A4)
          ASL     #3,D4 ;MAL 8
          LEA     CODETAB(PC),A0
          MOVE.L  $0(A0,D4.W),D3 ;CODE LESEN --> D3
          MOVE.L  $4(A0,D4.W),D2
          MOVE.W  D6,D0
          ROL.W   #8,D0
          ANDI.W  #$F0,D0        ; F Code ?
          CMPI.W  #$F0,D0
          BNE     MNRAUSN
          TST     isDFPU(A4)
          BEQ     MNRAUSOF
          BTST    #8,D2
          BNE     MNCPUTEST1 ; FPU Befehl bei vorhandener FPU
MNRAUSOF  MOVEQ   #8,D0
          ADDQ    #1,D0
          TST     isD30(A4)  ; nicht mal 30er CPU? dann Fehler.
          BEQ.L   FORMERR
          TST     isD40(A4)
          BEQ     MNCPUTEST
          ADDQ    #1,D0
          BRA     MNCPUTEST
MNRAUSN   MOVEQ   #8,D0
          TST     isD10(A4)
          BEQ     MNCPUTEST
          ADDQ    #1,D0
          TST     isD20(A4)
          BEQ     MNCPUTEST
          ADDQ    #1,D0
MNCPUTEST BTST    D0,D2
          BEQ.L   FORMERR ; Befehl nicht fÅr diese CPU!
MNCPUTEST1
          CMPI.B  #43,D2         ; FORMAT 43?
          BNE     MNCPUTEST2
          MOVE.W  D5,D0          ; Mode Feld holen
          ROL.W   #6,D0
          ANDI.W  #7,D0
          CMPI.W  #1,D0
          BEQ     DOMNOUT        ; PFLUSHA, kein EA Test!
          CMPI.W  #4,D0
          BEQ     DOMNOUT        ; PFLUSH by Functioncode only!
MNCPUTEST2
          CMPI.B  #61,D2
          BEQ     MNFORMATF
          CMPI.B  #50,D2         ; FORMAT 50?
          BNE     MNRAUSCT
MNFORMATF BTST    #14,D5         ; R/M FIELD
          BEQ     DOMNOUT        ; Register to Register; kein Test auf EA!
MNRAUSCT  BTST    #11,D2  ; auf EA testen?
          BEQ     DOMNOUT
          MOVE.L  D2,D0   ; zugelassene EA's holen und in HIGHWORD schieben
          ASL.L   #4,D0
          MOVE.W  D6,D0   ; Befehl fÅr EA.Mode holen
          MOVE.W  D6,D1
          LSR.W   #3,D0
          ANDI.W  #7,D0  ; Mode 7? dann EA.Reg dazu addieren
          CMPI.W  #7,D0
          BNE     MNCMP
          ANDI.W  #7,D1
          LEA     MNREGTAB(PC),A0
          MOVE.B  0(A0,D1.W),D1
          ADD.W   D1,D0
MNCMP     MOVE.W  D0,D1
          SWAP    D0
          BTST    D1,D0
          BEQ.L   FORMERR ; EA nicht zugelassen!
DOMNOUT   MOVEQ   #8,D4
          MOVE.W  D6,D5
          ROL.W   #8,D5
          ANDI.W  #$FE,D5
!MNOUT    ROL.L   #5,D3 ; 1. BUCHSTABEN HOLEN
          CMPI.W  #2,D4
          BNE     MNOUTO
          ANDI.L  #$18,D3
          MOVE.L  D3,D0
          MOVE.L  D2,D3
          ROL.L   #3,D3
          ANDI.L  #$FFFFFFE7,D3
          OR.L    D0,D3
MNOUTO    MOVE    D3,D0
          BSR     MNOUTCHR
!MNOUT1   SUBQ    #1,D4
          BNE     MNOUT
          MOVEQ   #0,D3
          MOVE.B  D2,D3  ; Format Nr. aus Tabelle holen
          ASL.W   #2,D3
          LEA     SPRTAB(PC),A0
          ADDA.W  D3,A0
          MOVE.L  D6,D2  ; Befehlscode zurÅck
          MOVE.L  D6,D4
          JMP     (A0)

MNOUTCHR  ANDI.W  #$1F,D0
          BEQ     MNOUTE
          CMPI.W  #28,D0
          BNE     MNOUTT1
          MOVEQ   #'2',D0
          BRA     MNOUTD
MNOUTT1   CMPI.W  #29,D0
          BNE     MNOUTT2
          MOVEQ   #'.',D0
          CMPI.W  #$F2,D5
          BNE     MNOUTD
          MOVEQ   #'1',D0
          BRA     MNOUTD
MNOUTT2   CMPI.W  #30,D0
          BNE     MNOUTT4
          CMPI.W  #$F2,D5
          BEQ     MNOUTT3
          MOVEQ   #'1',D0
          BSR.L   DPRT
          MOVEQ   #'6',D0
          BRA     MNOUTD
MNOUTT3   MOVEQ   #'0',D0
          BRA     MNOUTD
MNOUTT4   ADDI.W  #$40,D0
MNOUTD    BRA.L   DPRT
MNOUTE    RTS

;
!FORMERRP MOVE.L  (A7)+,D0 ;PULL ADRESSE
!FORMERR  BSET    #7,DCode(A4)
          MOVE.L  A0,-(SP)
          LEA     DBuffer(A4),A0
          MOVE.L  A0,-(SP)
FORMERRS  CMPI.B  #SPC,(A0)+
          BNE     FORMERRS
          SUBA.L  (SP)+,A0
          MOVE.W  A0,DCursorX(A4)
          MOVE.L  (SP)+,A0
          MOVEQ   #4,D3
!FORMERR1 MOVEQ   #'*',D0
          BSR.L   DPRT
          DBF     D3,FORMERR1
          BSR.L   DPRTTAB
          MOVE.L  DTemp(A4),A1
          SUBQ.L  #2,A1
          BSR.L   ADRPR1
          MOVE.L  DReturn(A4),A7
          RTS
;
;
;         EFFEKTIVE ADRESSE AUSGEBEN
;
!EFFADR   MOVE    D4,D3
          LSR     #3,D3                  ; Mode holen
          AND.L   #7,D3
          CMPI.W  #7,D3                  ; Mode 7?
          BEQ.L   MODE7
          CMPI.W  #5,D3
          BNE.S   EA8
          TST     isD20(A4)
          BEQ     EA5_00
          BSR     KLAMAUF
!EA5_00   BSR.S   ADRPR
          TST     isD20(A4)
          BEQ     EA8
          BSR     KOMMA
          BRA     EA2
!EA8      CMPI.W  #6,D3
          BNE.S   EA7
          TST     isD20(A4)
          BNE.L   MODE6
!EA6_00   BSR.S   INDEX1
!EA7      CMPI.W  #4,D3
          BNE.S   EA1
          MOVEQ   #'-',D0
          BSR.L   DPRT
!EA1      CMPI    #2,D3                  ; DIREKT
          BMI.S   EA2
          BSR.L   KLAMAUF
!EA2      MOVEQ   #'D',D0
          CMPI    #0,D3
          BEQ.S   EA3
          MOVEQ   #'A',D0
!EA3      BSR.L   DPRT
          MOVE    D4,D0
          ANDI.W  #7,D0
          OR      #$30,D0
          BSR.L   DPRT
          CMPI    #2,D3
          BMI.S   RETEA
          CMPI.W  #6,D3
          BEQ     INDEX2
          BSR     KLAMZU
          CMPI    #3,D3
          BNE     RETEA
          MOVEQ   #'+',D0
          BSR.L   DPRT
!RETEA    RTS
!ADRPR    BSR     DOLLAR
!ADRPR1   MOVE.B  (A1)+,D0
          BSR.L   DPRTBYTE
!ADRPR2   MOVE.B  (A1)+,D0
          BRA.L   DPRTBYTE
!INDEX1   BSR     DOLLAR
          MOVE.W  (A1),D0
          BRA.L   DPRTBYTE
!INDEX2   BSR.L   KOMMA
          MOVEQ   #'D',D0
          MOVE.W  (A1)+,D1
          BPL     IND1
          MOVEQ   #'A',D0
!IND1     BSR.L   DPRT
          MOVE.W  D1,D0
          LSR     #8,D0
          LSR     #4,D0
          ANDI.W  #7,D0
          OR      #$30,D0
          BSR.L   DPRT
          MOVEQ   #'.',D0
          BSR.L   DPRT
          MOVEQ   #'W',D0
          BTST    #11,D1
          BEQ     IND2
          MOVEQ   #'L',D0
          TST     isD20(A4)
          BEQ     IND2
          BSR.L   DPRT
          LSR.W   #8,D1       ; Scale Faktor herausholen
          LSR.W   #1,D1
          ANDI.B  #3,D1
          BEQ     IND21
          MOVEQ   #'*',D0
          BSR     DPRT
          MOVEQ   #1,D0
          ASL.W   D1,D0
          ADDI    #$30,D0
!IND2     BSR.L   DPRT
IND21     BRA     KLAMZU

!MODE6    MOVE.W  (A1)+,D1
          BTST    #8,D1
          BNE     FullFormat
BriefFormat
          BSR     KLAMAUF
          BSR     DOLLAR
          MOVE.B  D1,D0
          BSR     DPRTBYTE
          BSR     KOMMA
          CMPI.B  #7,D3
          BEQ     BriefPC
          MOVEQ   #'A',D0
          BSR     DPRT
          MOVE.W  D4,D0
          ANDI.W  #$7,D0
          ORI.W   #$30,D0
          BSR     DPRT
          BRA     BriefCont
BriefPC   MOVEQ   #'P',D0
          BSR     DPRT
          MOVEQ   #'C',D0
          BSR     DPRT
BriefCont BSR     KOMMA
          MOVEQ   #'D',D0
          BTST    #15,D1
          BEQ     MODE6_1
          MOVEQ   #'A',D0
MODE6_1   BRA     IND1

FullFormat
          MOVE.W  D1,D0     ; verbotene Formate heraussuchen
          ANDI    #7,D0
          CMPI    #4,D0     ; Index/Indirect Selection = 100?
          BEQ     FORMERRP
          MOVE.W  D1,D0
          ASR.W   #4,D0
          ANDI.W  #3,D0     ; BD Size = 0 (reserved?)
          BEQ     FORMERRP
          BTST    #6,D1     ; Index Suppress = 0?
          BEQ     FullFormat1
          BTST    #2,D1     ; Index/Indirect Selection grîûer 3?
          BNE     FORMERRP
FullFormat1
          BCLR    #31,D7    ; wird bei der ersten Ausgabe fÅr nachfolgende
                            ; Kommas gesetzt
          BSR     KLAMAUF
          MOVE.B  D1,D0
          ANDI.B  #7,D0     ; No Memory Indirect?
          BEQ     FullFormatNoMemoryIndirect
          BTST    #2,D1     ; Postindexed?
          BNE     FullFormatPostindexed
FullFormatPreindexed
          BSR     EKLAMAUF
          BSR     FullFormatBD
          BSR     FullFormatBR
          BSR.L   FullFormatIR
          BSR     EKLAMZU
          BSR.L   FullFormatOD
          BRA     KLAMZU
FullFormatPostindexed
          BSR     EKLAMAUF
          BSR     FullFormatBD
          BSR     FullFormatBR
          BSR     EKLAMZU
          BSR.L   FullFormatIR
          BSR.L   FullFormatOD
          BRA     KLAMZU
FullFormatNoMemoryIndirect
          BSR     FullFormatBD
          BSR     FullFormatBR
          BSR.L   FullFormatIR
          BRA     KLAMZU
;
FullFormatBD
          BTST    #5,D1     ; BD Size = Null Displacement?
          BEQ     FullFormatBD0
          BSET    #31,D7
          BEQ     FullFormatBDK
          BSR     KOMMA
FullFormatBDK
          BSR     DOLLAR
          MOVE.W  (A1)+,D0
          BSR     DPRTWORD
          BTST    #4,D1     ; Long Base Displacement?
          BEQ     FullFormatBD0
          MOVE.W  (A1)+,D0
          BSR     DPRTWORD
FullFormatBD0
          RTS
;
FullFormatBR
          BSET    #31,D7
          BEQ     FullFormatBR0
          BSR     KOMMA
FullFormatBR0
          MOVE.W  D4,D3
          LSR     #3,D3
          ANDI    #7,D3
          CMPI    #7,D3     ; PC oder An?
          BEQ     FullFormatBRPC
          BTST    #7,D1     ; Base Register Suppress?
          BNE     FullFormatZBR
          MOVEQ   #'A',D0
          BSR     DPRT
          MOVE.W  D4,D0
          ANDI    #7,D0
          ADDI    #$30,D0
          BRA     DPRT
FullFormatBRPC
          BTST    #7,D1     ; Base Register Suppress?
          BEQ     FullFormatBRPCO
FullFormatBRZPC
          MOVEQ   #'Z',D0
          BSR     DPRT
FullFormatBRPCO
          MOVEQ   #'P',D0
          BSR     DPRT
          MOVEQ   #'C',D0
          BRA     DPRT
FullFormatZBR
          MOVEQ   #'Z',D0
          BSR     DPRT
          MOVEQ   #'B',D0
          BSR     DPRT
          MOVEQ   #'R',D0
          BRA     DPRT
;
FullFormatIR
          BTST    #6,D1     ; Index Register Suppress?
          BNE     FullFormatIR0
          BSET    #31,D7
          BEQ     FullFormatIRK
          BSR     KOMMA
FullFormatIRK
          MOVEQ   #'D',D0
          BTST    #15,D1
          BEQ     FullFormatIR1
          MOVEQ   #'A',D0
FullFormatIR1
          BSR     DPRT
          MOVE    D1,D0
          ROL.W   #4,D0
          ANDI    #7,D0
          ORI     #$30,D0
          BSR     DPRT
          MOVEQ   #'.',D0
          BSR     DPRT
          MOVEQ   #'W',D0
          BTST    #11,D1
          BEQ     FullFormatIR2
          MOVEQ   #'L',D0
FullFormatIR2
          BSR     DPRT
          MOVE.W  D1,D3
          ASR.W   #8,D3
          ASR.W   #1,D3
          ANDI.W  #3,D3     ; Scaling = 1?
          BEQ     FullFormatIR0
          MOVEQ   #'*',D0
          BSR     DPRT
          MOVEQ   #1,D0
          ASL.W   D3,D0
          ORI.W   #$30,D0
          BSR     DPRT
FullFormatIR0
          RTS
;
FullFormatOD
          BTST    #1,D1    ; Null Outer Displacement?
          BEQ     FullFormatOD0
          BSET    #31,D7
          BEQ     FullFormatODK
          BSR     KOMMA
FullFormatODK
          BSR     DOLLAR
          MOVE.W  (A1)+,D0
          BSR     DPRTWORD
          BTST    #0,D1    ; Word oder Long Outer Displacement
          BEQ     FullFormatOD0
          MOVE.W  (A1)+,D0
          BSR     DPRTWORD
FullFormatOD0
          RTS
;
!FORMAT0  MOVE    D2,D3
          ANDI.W  #$138,D3
          CMPI.W  #$108,D3
          BEQ.L   MNRAUS ;MOVEP
          ADDQ    #1,D4
          BTST    #8,D2
          BNE     BITFORM
          MOVE    D2,D3
          ANDI    #$01C0,D3  ; Bit 7 und 6 auf 1, Bit 8 auf 0 testen
          CMPI.W  #$00C0,D3
          BNE     Format0alt
          MOVE.W  D2,D3
          ROL.W   #7,D3
          ANDI.W  #7,D3
          CMPI.W  #4,D3
          BEQ     BITFORM
          BRA     Format0neu
Format0alt
          MOVE    D2,D3
          LSR     #8,D3
          LSR     #1,D3
          ANDI.W  #$7,D3
          CMPI.W  #$7,D3
          BNE     FORMAT0C
          ADDQ    #4,D4
          BRA     MNRAUS ;MOVES
!FORMAT0C CMPI.W  #$4,D3
          BEQ     BITFORM  ; Bit Number static
          ADD     D3,D4
          ANDI    #$2,D3
          BNE.L   TESTDV11 ;ADDI,SUBI,CMPI
          BEQ.L   TESTDVSR ;EORI, ANDI, ORI
          BRA     MNRAUS
!BITFORM  ADDQ    #7,D4
          MOVE    D2,D3
          LSR     #6,D3
          ANDI.W  #$3,D3
          ADD     D3,D4
;          BRA.L   TESTDI
          BRA     MNRAUS
!Format0neu
          ADD.W   #11,D4
          BTST    #11,D2
          BNE     Format0neu1
          MOVE    D2,D3
          ROR.W   #8,D3
          CMPI.B  #6,D3
          BEQ     FORMAT0Module
          MOVE    (A1),D3
          BTST    #11,D3
          BNE     MNRAUS ;CHK2
          ADDQ    #1,D4
          BRA     MNRAUS ;CMP2
!Format0neu1
          ADDQ    #2,D4
          MOVE    D2,D3
          CMPI.B  #$FC,D3
          BNE     MNRAUS ;CAS
          ADDQ    #1,D4
          BRA     MNRAUS
!Format0Module
          TST     isD30(A4)
          BNE     FORMERR ; nur 68020 CPU
          ADDQ    #4,D4
          ROL.W   #4,D3
          ANDI.W  #3,D3
          BEQ     MNRAUS ; RTM
          ADDQ    #1,D4
          BRA     MNRAUS ; CALLM
;
!FORMATMO BRA.L   TESTMOVE
;
;
!FORMAT4TAB
          DC.W    $4E70,$4E71,$4E72,$4E73,$4E74,$4E75,$4E76,$4E77,$4AFC,$4E7A
          DC.W    $4848,$4840,$4880,$48C0,$49C0,$4E58,$4E50,$4808,$4E60,$4E40
          DC.W    $4C00,$4C40,$4E80,$4EC0,$40C0,$44C0,$42C0,$46C0,$4800,$4840
          DC.W    $4AC0,$4880,$4C80,$4000,$4200,$4400,$4600,$4A00
          DC.W    0
!FORMAT4MASK
          DC.W    9,$FFFE,10,$FFF8,18,$FFF0,20,$FFC0,31,$FF80,33,$FF00,38,0
!FORMAT4  MOVE.W  D2,D3
          LEA     FORMAT4TAB(PC),A0
          MOVE.L  A1,-(SP)
          LEA     FORMAT4MASK(PC),A1
          MOVEQ   #0,D0
!FORMAT4L MOVE.W  (A0)+,D1 ; Vergleichswert holen
          BEQ     FORMAT4N ; Tabellenende?
          CMP.W   (A1),D0  ; ZÑhlerstand vergleichen
          BCS     FORMAT4M
          AND.L   (A1)+,D3  ; NUR UNTERSTEN 16 BIT NOTWENDIG, Code ausmaskieren
!FORMAT4M CMP.W   D1,D3
          BEQ     FORMAT4T
          ADDQ.W  #1,D0
          BRA     FORMAT4L
!FORMAT4N BTST    #6,D2
          BEQ     FORMAT4E  ; CHK Befehl gefunden
          ADDQ.W  #1,D0
          BTST    #7,D2
          BEQ     FORMERR
          BTST    #8,D2
          BEQ     FORMERR
          BRA     FORMAT4E
!FORMAT4T CMPI    #37,D0     ; TST Befehl?
          BNE     FORMAT4E
          TST     isD20(A4)  ; TST Befehl bei 68020-68040 prÅfen
          BNE     FORMAT44
          MOVE.W  D2,D3
          ANDI.W  #$003F,D3
          CMPI.W  #$003C,D3  ; unmittelbar nicht erlaubt
          BEQ     FORMERR
          LSR     #3,D3
          CMPI.W  #1,D3      ; Adressregister direkt nicht erlaubt
          BEQ     FORMERR
          BRA     FORMAT4E
!FORMAT44 MOVE.B  D2,D3
          LSR.B   #3,D3
          CMPI.B  #1,D3      ; Adressregister direkt mit Size Byte nicht erlaubt
          BEQ     FORMERR
!FORMAT4E MOVE.L  (SP)+,A1
          ADD.W   D0,D4
          BRA     MNRAUS
;
;
;
;
!FORMAT5  MOVE.W  D2,D3
          ANDI.W  #$F8,D3
          CMPI.W  #$C8,D3
          BEQ.L   MNRAUS ; DB..
          ADDQ    #1,D4
          CMPI.W  #$F8,D3
          BNE     FORMAT5W
          MOVE.W  D2,D0
          ANDI.W  #7,D0
          CMPI.W  #2,D0
          BCS     FORMAT5W
          CMPI.W  #5,D0
          BCS     MNRAUS ; TRAPcc
FORMAT5W  ADDQ    #1,D4
          ANDI.W  #$C0,D3
          CMPI.W  #$C0,D3
          BEQ     MNRAUS ; Scc
          ADDQ    #1,D4
          BTST    #8,D2
          BEQ.L   MNRAUS ;ADDQ
!FORMAT5S ADDQ    #1,D4
          BRA.L   MNRAUS ;SUBQ
;
!FORMAT6  BRA.L   MNRAUS ;BRANCH
;
!FORMAT7  BTST    #8,D2  ;MOVEQ
          BEQ.L   MNRAUS
          BRA.L   FORMERR
;
!FORMAT8  MOVE    D2,D3 ;DIVS,DIVU,SBCD,OR,PACK,UNPK SOWIE FORMAT12
          ANDI.W  #$1F0,D3
          CMPI.W  #$100,D3
          BEQ     MNRAUS   ; SBCD(8) bzw. ABCD(12)
          ADDQ    #1,D4
          CMPI.W  #$140,D3
          BEQ     MNRAUS   ; PACK(8) bzw. EXG(12)
          ADDQ    #1,D4
          CMPI.W  #$180,D3
          BNE     FORMAT81
          BTST    #14,D2
          BEQ     MNRAUS   ; UNPACK(8)
          BTST    #3,D2
          BNE     MNRAUS   ; EXG(12)
          BRA     FORMERR
!FORMAT81 ADDQ    #1,D4
          ANDI.W  #$1C0,D3
          CMPI.W  #$0C0,D3
          BEQ     MNRAUS   ; DIVU(8) bzw. MULU(12)
          ADDQ.L  #1,D4
          CMPI.W  #$1C0,D3
          BEQ     MNRAUS   ; DIVS(8) bzw. MULS(12)
          ADDQ    #1,D4
          BRA     MNRAUS   ; OR(8) bzw. AND(12)
;
!FORMAT9  MOVE    D2,D3 ;SUB,SUBX
          CMP.B   #$C0,D2
          BCS     KEINADDA ;ADDA,SUBA
          ADDQ    #1,D4
          BRA.L   MNRAUS
!KEINADDA ANDI.W  #$130,D3
          CMPI.W  #$100,D3
          BEQ.L   TESTN11 ;SUBX
          ADDQ.W  #$1,D4
          BRA.L   TESTASV ;SUB
;
!FORMAT11 MOVE    D2,D3
          ANDI.W  #$1C0,D3
          CMPI.W  #$80,D3
          BLE.L   TESTAB ;CMP
          ANDI.W  #$C0,D3
          CMPI.W  #$C0,D3
          BEQ.L   MNRAUS ;CMP MIT ADRESSE
          ADDQ    #1,D4
          MOVE    D2,D3
          ANDI.W  #$138,D3
          CMPI.W  #$108,D3
          BEQ.L   TESTN11 ;CMPM
          ADDQ    #1,D4
          BRA.L   TESTDV11 ;EOR
;
!FORMAT14TAB
          DC.W    $EAC0,$ECC0,$EFC0,$EDC0,$EEC0,$E8C0,$EBC0,$E9C0,0
!FORMAT14 MOVE.W  D2,D3
          ANDI.W  #$FFC0,D3
          LEA     FORMAT14TAB(PC),A0
          MOVEQ   #0,D0
!FORMAT14L
          MOVE.W  (A0)+,D1
          BEQ     FORMAT14O
          CMP.W   D1,D3
          BEQ     FORMAT14T
          ADDQ    #1,D0
          BRA     FORMAT14L
!FORMAT14T
          MOVE    D2,D3
          ROR.W   #3,D3
          ANDI.B  #7,D3
          CMPI.B  #7,D3     ; EA MODE 7 ?
          BNE     FORMAT14B
          MOVEQ   #0,D1
          MOVE.B  D3,D1
          ANDI.B  #7,D1     ; Reg.Field holen
          LEA     MNREGTAB(PC),A0
          MOVE.B  0(A0,D1.W),D1
          ROL.W   #3,D3
          ANDI    #7,D3
          ADD     D3,D1     ; MODE Field draufaddiren
          MOVE.W  #$1FC,D3
          BTST    D1,D3     ; EA prÅfen
          BEQ     FORMAT14O
          ADD     D0,D4
          BRA     MNRAUS
!FORMAT14B
          MOVE    D2,D3
          ANDI.B  #7,D3
          CMPI.B  #2,D3
          BCC     FORMAT14O
          ADD     D0,D4
          BRA     MNRAUS
!FORMAT14O
          ADDQ    #8,D4
          MOVE    D2,D3
          CMP.B   #$C0,D2
          BCS     FORM14A
          LSR     #6,D3
!FORM14A  LSR     #3,D3
          ANDI.W  #$3,D3
          ADD     D3,D4
          CMP.B   #$C0,D2
          BCC.L   TESTSV
;SONST    GROESSE 11 VERBOTEN
;
;TEST     FUER    VERBOTENE FORMATE
;
!TESTN11  BSR.L   TEST11 ;WENN NUR DIE GROESSE WICHTIG IST
          BRA     MNRAUS1
!TEST11   CMPI.B  #$C0,D6 ;GROESSE 11 VERBOTEN
          BCC.L   FORMERRP
          RTS
!TESTDV11 BSR.L   TEST11
!TESTDV   ANDI.W  #$3F,D6
          CMPI.W  #$3A,D6
          BPL     FORMERR2
          ANDI.W  #$38,D6
          CMPI.W  #$8,D6
          BNE     MNRAUS1
!FORMERR2 BRA.L   FORMERR
!TESTDVSR BSR.L   TEST11 ;DATENVERAENDERLICH ODER SR BETREFFEND
          ANDI.W  #$3F,D6
          CMPI.W  #$3C,D6
          BEQ     MNRAUS1
          BRA     TESTDV
!TESTDI   ANDI.W  #$3F,D6 ;DATEN, NICHT IMM.
          CMPI.W  #$3C,D6
          BPL     FORMERR2
!TESTD    ANDI.W  #$38,D6 ;DATEN
          CMPI.W  #$8,D6
          BEQ     FORMERR2
!MNRAUS1  BRA.L   MNRAUS
!TESTSTPD ANDI.W  #$38,D6 ;STEUERUNG ODER PREDECR
          CMPI.W  #$20,D6
          BEQ     MNRAUS1
          BRA     TESTSTE
!TESTSTPI ANDI.W  #$38,D6 ;STEUERUNG ODER POSTINCR
          CMPI.W  #$18,D6
          BEQ     MNRAUS1
!TESTSTE  MOVE    D2,D6 ;STEUERUNG
          ANDI.W  #$3F,D6
          CMPI.W  #$3C,D6
          BPL.L   FORMERR
          CMPI.W  #$10,D6
          BCS.L   FORMERR
          ANDI.W  #$38,D6
          CMPI.W  #$10,D6
          BEQ     MNRAUS1
          CMPI.W  #$28,D6
          BCS.L   FORMERR
          BRA     MNRAUS1
!TESTSV   ANDI.W  #$3F,D6 ;SPEICHERVERAENDERLICH
          CMPI.W  #$10,D6
          BCS.L   FORMERR
          CMPI.W  #$3A,D6
          BPL.L   FORMERR
          BRA     MNRAUS1
!TESTASV  BSR.L   TEST11 ;SPEICHERV., BEI ADRESSE GR BYTE VERBOTEN
          MOVE    D2,D3
          ANDI.W  #$100,D3
          BNE     TESTSV
!TESTAB   BSR.L   TEST11 ;BEI ADRESSE GR. BYTE VERBOTEN
          ANDI.W  #$38,D6
          CMPI.W  #$8,D6
          BNE     TESTDV
          BRA     MNRAUS1
!TESTABV  ANDI.W  #$3F,D6 ;VERAENDERBAR, ADR->KEIN BYTE
          CMPI.W  #$3A,D6
          BPL     FORMERR
          BRA     TESTAB
!TESTCMP  ANDI.W  #$1C0,D6
          CMPI.W  #$80,D6
          BLE.L   TESTAB
          CMP.B   #$C0,D6
          BNE.L   FORMERR
          BRA.L   MNRAUS
!TESTMOVE ANDI.W  #$3000,D6
          CMPI.W  #$1000,D6
          BNE     TESTM2
          MOVE    D2,D6
          ANDI.W  #$1C0,D6
          CMPI.W  #$40,D6
          BEQ     FORMERRM
          MOVE    D2,D6
          ANDI.W  #$38,D6
          CMPI.W  #$8,D6
!FORMERRM BEQ.L   FORMERR
!TESTM2   MOVE    D2,D6
          ANDI.W  #$1C0,D6
          CMPI.W  #$1C0,D6
          BNE     MNRAUS55
          MOVE    D2,D6
          ANDI.W  #$E00,D6
          CMPI.W  #$400,D6
          BPL.L   FORMERR
!MNRAUS55 BRA.L   MNRAUS
;
!FORMAT15 MOVE.W  D2,D3
          LSR.W   #8,D3
          ANDI.W  #$E,D3
          BEQ     FORMAT15_PMMU30
          CMPI.W  #$2,D3
          BEQ.L   FORMAT15_FPU
          MOVE.W  D2,D3
          LSR.W   #8,D3
          ANDI.W  #$F,D3
          CMPI.W  #$4,D3
          BEQ.L   FORMAT15_CPUSH_CINV
          CMPI.W  #$5,D3
          BEQ.L   FORMAT15_PMMU40
          CMPI.W  #$6,D3
          BEQ.L   FORMAT15_MOVE16
          BRA     FORMERR
;
!FORMAT15_PMMU30
          MOVE.W  D2,D3
          ANDI.W  #$C0,D3 ; Bit 7 & 6 testen
          BNE     FORMERR
          MOVE.W  (A1),D3
          MOVE.W  D3,D0
          MOVE.W  D3,D1
          ROL.W   #3,D1
          ANDI.W  #7,D1   ; obersten 3 Bits des nÑchsten Wortes
          BNE     FORMAT15_PMMU30_1
          ANDI.W  #$FF,D0
          BNE     FORMERR
          BRA     MNRAUS  ; PMOVE TT Register
FORMAT15_PMMU30_1
          ADDQ    #1,D4
          CMPI.W  #1,D1
          BNE     FORMAT15_PMMU30_2
          ROL.W   #6,D0
          ANDI.W  #7,D0
          BEQ     MNRAUS  ; PLOAD
          ADDQ    #1,D4
          CMPI.W  #1,D0
          BEQ     MNRAUS  ; PFLUSH
          CMPI.W  #4,D0
          BEQ     MNRAUS  ; PFLUSH
          CMPI.W  #6,D0
          BEQ     MNRAUS  ; PFLUSH
          BRA     FORMERR
FORMAT15_PMMU30_2
          ADDQ    #2,D4
          CMPI.W  #2,D1
          BEQ     FORMAT15_PMMU30_3
          CMPI.W  #3,D1
          BNE     FORMAT15_PMMU30_4
FORMAT15_PMMU30_3
          ANDI.W  #$FF,D0
          BEQ     MNRAUS  ; PMOVE
          BRA     FORMERR
FORMAT15_PMMU30_4
          ADDQ    #1,D4
          CMPI.W  #4,D1
          BEQ     MNRAUS  ; PTEST
          BRA     FORMERR
FORMAT15_CPUSH_CINV
          ADDQ    #5,D4
          BTST    #5,D2
          BEQ     MNRAUS  ; CPUSH
          ADDQ    #1,D4
          BRA     MNRAUS  ; CINV
FORMAT15_PMMU40
          ADDQ    #7,D4
          MOVE.W  D2,D0
          ANDI.W  #$E0,D0
          BEQ     PFLUSH_MNRAUS  ; PFLUSH
          ANDI.W  #$C0,D0
          CMPI.W  #$40,D0
          BNE     FORMERR
          MOVE.W  D2,D0
          ANDI.W  #$D8,D0
          CMPI.W  #$48,D0
          BEQ     MNRAUS  ; PTEST
          BRA     FORMERR
PFLUSH_MNRAUS
          ADDQ    #1,D4
          BRA     MNRAUS  ; PFLUSH
FORMAT15_MOVE16
          ADD.W   #9,D4
          MOVE.W  D2,D0
          ANDI.W  #$FC,D0
          CMPI.W  #$20,D0
          BEQ     MNRAUS  ; MOVE16
          ANDI.W  #$E0,D0
          BEQ     MNRAUS  ; MOVE16
          BRA     FORMERR
;
; Bei den FPU Codes wird nicht direkt MNRAUS bzw. FORMERR angesprungen,
; damit im Line F Handler diese Routine angesprungen werden kann, um bei
; 68040 auf Software Emulationbefehle zu testen. Daher wird bei allen FPU
; Befehlen ein vollstÑndiger Test auf alle mîglichen Opmode, Conditional
; Predicate und EA Besonderheiten gemacht, die nicht im EA Feld der Tabelle
; fÅr die Befehlsmnemnonik enthalten sind!
;
FORMAT15_FPU_TAB
          DC.B    1,2,3,4,6,8,9,10,12,13,14,15,16,17,18,20,21,22,24,25,26
          DC.B    28,29,30,31,32,33,34,35,36,37,38,39,40,48,49,50,51,52,53
          DC.B    54,55,56,58,64,65,68,69,88,90,92,94,96,98,99,100,102,103
          DC.B    104,108,0
          SYNC
FORMAT15_FPU
          BSR.L   TEST_FPU_FORMAT
          BEQ     MNRAUS
          BRA     FORMERR
;
TEST_FPU_CODE                       ; Entry fÅr Line F Handler bei 68040
          MOVE.W  is10(A4),isD10(A4)
          MOVE.W  is20(A4),isD20(A4)
          MOVE.W  is30(A4),isD30(A4)
          MOVE.W  is40(A4),isD40(A4)
          MOVE.W  isFPU(A4),isDFPU(A4)
          MOVEQ   #0,D4
          LEA     ANZTAB(PC),A0
          MOVEQ   #15,D1
T_F_C_L   ADD.B   0(A0,D1.W),D4
          DBRA    D1,T_F_C_L
          MOVE.W  D2,D5             ; Code sichern
          ST      DisPrt(A4)
          BSR     TEST_FPU_FORMAT
          CLR.W   DisPrt(A4)
          ASL     #3,D4 ;MAL 8
          LEA     CODETAB(PC),A0
          MOVE.L  $0(A0,D4.W),D3 ;CODE LESEN --> D3
          MOVE.L  $4(A0,D4.W),D2
          CMPI.B  #50,D2         ; FORMAT 50?
          BNE     FMNRAUSCT
          BTST    #14,D5         ; R/M FIELD
          BEQ     FMNOUT         ; Register to Register; kein Test auf EA!
FMNRAUSCT BTST    #11,D2  ; auf EA testen?
          BEQ     FMNOUT
          MOVE.L  D2,D0   ; zugelassene EA's holen und in HIGHWORD schieben
          ASL.L   #4,D0
          MOVE.W  D6,D0   ; Befehl fÅr EA.Mode holen
          MOVE.W  D6,D1
          LSR.W   #3,D0
          ANDI.W  #7,D0  ; Mode 7? dann EA.Reg dazu addieren
          CMPI.W  #7,D0
          BNE     FMNCMP
          ANDI.W  #7,D1
          LEA     MNREGTAB(PC),A0
          MOVE.B  0(A0,D1.W),D1
          ADD.W   D1,D0
FMNCMP    MOVE.W  D0,D1
          SWAP    D0
          BTST    D1,D0
          BEQ.L   FORMAT15_FORMERR ; EA nicht zugelassen!
          BRA.L   FORMAT15_MNRAUS
FMNOUT    TST.L   D0
          RTS
;
TEST_FPU_FORMAT
          ADD.W   #10,D4
          MOVE.W  D2,D0
          ASR.W   #6,D0
          ANDI.W  #7,D0              ; Bits 6-8 = 0?
          BNE     FORMAT15_FPU_ALLG  ; nein!
          MOVE.W  (A1)+,D3
          BTST    #15,D3             ; Bits 13 & 15 des zweiten Wortes = 0?
          BNE.L   FORMAT15_FPU_ALLG1
          BTST    #13,D3
          BNE.L   FORMAT15_FPU_ALLG1
          MOVE.W  D2,D0
          ANDI.W  #63,D0
          BNE     FORMAT15_NO_FMOVECR
          MOVE.W  D3,D0
          ROL.W   #6,D0
          ANDI.W  #63,D0
          CMPI.W  #$17,D0
          BNE     FORMAT15_NO_FMOVECR
          ADD.W   #54,D4
          BRA     FORMAT15_MNRAUS    ; FMOVECR
FORMAT15_NO_FMOVECR
          MOVE.W  D3,D0
          ANDI.W  #127,D0
          BEQ.L   FORMAT15_TEST_TO_EA ; FMOVE
          ADDQ    #1,D4
          LEA     FORMAT15_FPU_TAB(PC),A0
FORMAT15_FPU_LOOP
          MOVE.B  (A0)+,D1
          BEQ     FORMAT15_FORMERR
          CMP.B   D1,D0
          BEQ     FORMAT15_TEST_B_W_L_S
          CMPI.B  #48,D1
          BCS     FORMAT15_FPU_COUNT
          CMPI.B  #55,D1
          BCS     FORMAT15_FPU_LOOP
FORMAT15_FPU_COUNT
          ADDQ    #1,D4
          BRA     FORMAT15_FPU_LOOP
FORMAT15_FPU_ALLG
          BTST    #8,D2
          BEQ.L   FORMAT15_ALLG0
          BTST    #7,D2
          BNE     FORMAT15_FORMERR
          ADD.W   #64,D4
          BTST    #6,D2
          BEQ     FORMAT15_MNRAUS ; FSAVE
          ADDQ    #1,D4
          BRA     FORMAT15_MNRAUS ; FRESTORE
FORMAT15_FORMERR
          MOVEQ   #-1,D0
          RTS
FORMAT15_MNRAUS
          MOVEQ   #0,D0
          RTS
FORMAT15_TEST_B_W_L_S
          BTST    #14,D3
          BEQ     FORMAT15_MNRAUS
          MOVE.W  D3,D0
          ROL.W   #6,D0
          ANDI.W  #7,D0
          BEQ     FORMAT15_MNRAUS
          CMPI.W  #1,D0
          BEQ     FORMAT15_MNRAUS
          CMPI.W  #4,D0
          BEQ     FORMAT15_MNRAUS
          CMPI.W  #6,D0
          BEQ     FORMAT15_MNRAUS
          MOVE.W  D4,D0
          ANDI.W  #$38,D0
          BEQ     FORMAT15_FORMERR
          BRA     FORMAT15_MNRAUS
FORMAT15_TEST_SINGLE_FPCR  ; mit EA = Dn
          MOVE.W  D3,D0
          ROL.W   #6,D0
          ANDI.W  #7,D0
          CMPI.W  #1,D0
          BEQ     FORMAT15_TEST_TO_EA
          CMPI.W  #2,D0
          BEQ     FORMAT15_TEST_TO_EA
          CMPI.W  #4,D0
          BEQ     FORMAT15_TEST_TO_EA
          MOVE.W  D2,D0
          ASR.W   #3,D0
          ANDI.W  #7,D0
          BEQ     FORMAT15_FORMERR
FORMAT15_TEST_FPIAR         ; mit EA = An
          MOVE.W  D3,D0
          ROL.W   #6,D0
          ANDI.W  #7,D0
          CMPI.W  #1,D0     ; FPIAR?
          BEQ     FORMAT15_MNRAUS
          MOVE.W  D2,D0
          ASR.W   #3,D0
          ANDI.W  #7,D0
          CMPI.W  #1,D0
          BEQ     FORMAT15_FORMERR
FORMAT15_TEST_TO_EA
          BTST    #13,D3         ; DR Bit testen
          BEQ     FORMAT15_MNRAUS ; Memory to Register uninteressant
          MOVE.W  D2,D0
          ANDI.W  #$38,D0        ; Mode Field ausselektieren
          CMPI.W  #$38,D0        ; Mode 7?
          BNE     FORMAT15_MNRAUS ; nein, dann nix mehr untersuchen
          MOVE.W  D2,D0
          ANDI.W  #7,D0
          CMPI.W  #2,D0          ; bei Register to Memory eingeschrÑnkte EA!
          BCC     FORMAT15_FORMERR
          BRA     FORMAT15_MNRAUS
FORMAT15_FMOVEM_FPN
          MOVE.W  D2,D0
          ASR.W   #3,D0
          ANDI.W  #7,D0
          BTST    #13,D3
          BEQ     FORMAT15_FMOVEM_FPN_0 ; dr Bit
          CMPI.W  #3,D0
          BEQ     FORMAT15_FORMERR
          BRA     FORMAT15_TEST_TO_EA
FORMAT15_FMOVEM_FPN_0
          CMPI.W  #4,D0
          BEQ     FORMAT15_FORMERR
          BRA     FORMAT15_MNRAUS
FORMAT15_FPU_ALLG0
          MOVE.W  (A1)+,D3
FORMAT15_FPU_ALLG1
          ADD.W   #55,D4
FORMAT15_ALLG2
          BTST    #15,D3
          BEQ     FORMAT15_TEST_TO_EA ; FMOVE FPn to EA
          ADDQ    #3,D4
          BTST    #14,D3
          BNE     FORMAT15_FMOVEM_FPN ; FMOVEM FPn
          SUBQ    #2,D4
          MOVE.W  D3,D0
          ROL.W   #6,D0
          ANDI.W  #7,D0
          BEQ     FORMAT15_FORMERR
          CMPI.W  #1,D0
          BEQ     FORMAT15_TEST_FPIAR ; FMOVE FPcr
          CMPI.W  #2,D0
          BEQ     FORMAT15_TEST_FPIAR ; FMOVE FPcr
          CMPI.W  #4,D0
          BEQ     FORMAT15_TEST_FPIAR ; FMOVE FPcr
          ADDQ    #1,D4
          BRA     FORMAT15_TEST_SINGLE_FPCR ; FMOVEM FPcr
FORMAT15_ALLG0
          MOVE.W  (A1)+,D3
FORMAT15_ALLG
          ADD.W   #59,D4
          BTST    #8,D2
          BNE     FORMAT15_FORMERR
          BTST    #7,D2
          BNE     FORMAT15_ALLGL
          MOVE.W  D2,D0
          ASR.W   #3,D0
          ANDI.W  #7,D0
          CMPI.W  #1,D0
          BEQ     FORMAT15_ALLGM
          CMPI.W  #7,D0
          BNE     FORMAT15_MNRAUS ; FScc
          MOVE.W  D2,D0
          ANDI.W  #7,D0
          CMPI.W  #2,D0
          BCS     FORMAT15_MNRAUS ; FScc
          CMPI.W  #5,D0
          BCC     FORMAT15_FORMERR
          ADDQ    #1,D4           ; fÅr FTRAPcc
FORMAT15_ALLGM
          ADDQ    #1,D4           ; fÅr FDBcc
          BRA     FORMAT15_MNRAUS
FORMAT15_ALLGL
          ADDQ    #3,D4
          MOVE.W  D2,D0
          ANDI.W  #127,D0
          BNE     FORMAT15_ALLGB
          TST.W   D3
          BEQ     FORMAT15_MNRAUS  ; FNOP
FORMAT15_ALLGB
          ADDQ    #1,D4
          BTST    #5,D2
          BNE     FORMAT15_FORMERR
          TST.W   D3
          BNE     FORMAT15_MNRAUS  ; FBcc mit nicht 0 displacement 16 Bit
          BTST    #6,D2
          BEQ     FORMAT15_FORMERR ; FBcc mit 0 displacement 16 Bit
          TST     (A1)
          BEQ     FORMAT15_FORMERR ; FBcc mit 0 displacement 32 Bit
          BRA     FORMAT15_MNRAUS  ; FBcc mit nicht 0 displacement 32 Bit
;
!TYP0     CMPI.W  #$4E74,D2        ; RTD?
          BNE     TYP0E            ; nein
          BSR     DPRTTAB
          BSR     IMM
          BSR     DOLLAR
          MOVE.W  (A1)+,D0
          BSR     DPRTWORD
!TYP0E    RTS
;
!TYP1     BSR.L   DPRTTAB ;JMP
          MOVE    D2,D4
          BSR     EFFADR
          RTS
;
;
;
;         MOVE    ADRESSEN AUSGEBEN
;
!TYP2     MOVEQ   #0,D4
;
;GROESSE  BERECHNEN
;
          BTST    #13,D2
          BEQ.S   LASSEN ; Byte
          BTST    #12,D2
          BNE.S   WORTW  ; Wort
          OR      #$80,D4
          BRA.S   LASSEN
!WORTW    OR      #$40,D4
!LASSEN   MOVE    D2,D3
          ANDI.W  #$3F,D3
          OR      D3,D4
          BSR.L   GREFFADK
          BSR.L   REGSCH
          ANDI.W  #$C7,D4
          MOVE    D2,D3
          LSR     #3,D3 ;MOD
          ANDI.W  #$38,D3
          OR      D3,D4
          BSR     EFFADR
          RTS
;
!TYP3     BSR.L   CCRAUS ;DB..
          BSR.L   DPRTTAB
          MOVE    D2,D4
          ANDI.W  #$7,D4
          BSR.L   EFFADK
          BRA.L   DLANG
;
;
!TYP4     BSR.L   CCRAUS
          BSR.L   DPRTTAB
          MOVE    D2,D4
          ANDI.W  #$3F,D4
          BSR     EFFADR
          RTS
;
!TYP5     MOVE    D2,D4 ;ADDQ
          MOVE    D2,D0
          ANDI.W  #$F8,D0
          CMPI.W  #$0008,D0 ; EA Adressregister direkt mit Size Byte?
          BEQ     FORMERR
          BSR.L   GROESSE
          BSR.L   IMM
          MOVE    D2,D0
          LSR     #8,D0
          LSR     #1,D0
          ANDI.W  #$7,D0
          BNE     KEINE8
          MOVEQ   #8,D0
!KEINE8   OR      #$30,D0
          BSR.L   DPRT
          BSR.L   KOMMA
          BSR     EFFADR
          RTS
;
!TYP6     BSR.L   CCRAUS ;BRANCH
;          BSR.L   DPRTTAB
          MOVE    D2,D3
          AND.L   #$FF,D3
          BEQ     LANG
          CMPI.W  #$FF,D3
          BNE     TYP6_1
          TST     isD20(A4)
          BEQ     TYP6_1
!SLANG    BSR.L   PRPLTAB
          MOVE.L  A1,D3
          MOVE.L  (A1)+,D4
          ADD.L   D4,D3
          BRA     RELADR
TYP6_1    TST     isD20(A4)
          BEQ     TYP6_11
          BSR.L   PRPBTAB
          BRA     TYP6_12
TYP6_11   BSR.L   PRPSTAB
TYP6_12   CMPI.W  #$80,D3
          BPL     ZURUECK
          ADD.L   A1,D3
          BRA     RELADR
!ZURUECK  ADD.L   A1,D3
          SUB.L   #$100,D3
          BRA     RELADR
!DLANG    TST     isD20(A4)
          BEQ     DLANG1
          BSR     LANG_2
          BRA.L   PRPWTAB
!DLANG1   BSR     LANG_2
          BRA.L   PRPLTAB
!LANG     TST     isD20(A4)
          BEQ     LANG1
          BSR.L   PRPWTAB
          BRA     LANG_2
!LANG1    BSR.L   PRPLTAB
!LANG_2   MOVE.L  A1,D3
          MOVE    (A1)+,D4
          EXT.L   D4
          ADD.L   D4,D3
!RELADR   BSR.L   DOLLAR
          ROL.L   #8,D3
          TST     isD20(A4)
          BEQ.S   RELADR1
          MOVE.B  D3,D0
          BSR.L   DPRTBYTE
!RELADR1  ROL.L   #8,D3
          MOVE.B  D3,D0
          BSR.L   DPRTBYTE
          ROL.L   #8,D3
          MOVE.B  D3,D0
          BSR.L   DPRTBYTE
          ROL.L   #8,D3
          MOVE.B  D3,D0
          BRA.L   DPRTBYTE
;
;
!TYP7     BSR.L   DPRTTAB ;MOVEQ
          BSR.L   IMM
          BSR.L   DOLLAR
          MOVE    D2,D0
          BSR.L   DPRTBYTE
          BSR.L   KOMMA
          CLR     D4
          BSR.L   REGSCH
          BSR     EFFADR
          RTS
;
!TYP8     MOVE    D2,D4 ;CLR
          BRA.L   GREFFAD
;
!TYP9     MOVE.W  D2,D4
          MOVE.W  D2,D0
          ANDI.W  #$FE7F,D2 ;DIVS USW.
          ANDI.W  #$F1C0,D0
          CMPI.W  #$4100,D0 ;CHK.L?
          BNE     TYP10
          TST     isD20(A4)
          BEQ     FORMERR
          BSR     PRPLTAB
          CMPI.B  #$3C,D4   ;CHK.L #data,Dn
          BNE     TYP91
          BSR     IMM
          MOVE.L  (A1)+,D0
          BSR     DPRTLONG
          BRA     TYP92
TYP91     BSR     EFFADR
TYP92     BSR     KOMMA
          MOVE.W  D4,D0
          ROL.W   #7,D0
          BRA.L   PRTDREG
;
;WEITER   MIT     TYP10
;
!TYP10    MOVE    D2,D4 ;ADD
          BTST    #6,D2
          BNE     TYP10ok    ; ADDA, keine EinschrÑnkung
          BTST    #8,D2
          BEQ     TYP10dest  ; <ea> + Dn -> Dn
          MOVE.W  D2,D3
          ANDI.W  #$38,D3
          BEQ     FORMERR  ; kein Dn!
          CMPI.W  #$08,D3
          BEQ     FORMERR  ; kein An!
          CMPI.W  #$38,D3  ; EA Mode 7
          BNE     TYP10ok  ; keine Untersuchung auf EinschrÑnkung
          MOVE.W  D2,D3
          ANDI.W  #7,D3
          CMPI.W  #2,D3
          BCC     FORMERR
          BRA     TYP10ok
TYP10dest MOVE.W  D2,D3
          ANDI.W  #$38,D3
          CMPI.W  #$08,D3  ; Adressierung An?
          BNE     TYP10ok
          MOVE.W  D2,D3
          ANDI.W  #$C0,D3  ; Opmode Byte Grîûe?
          BEQ     FORMERR
TYP10ok   MOVE    D2,D3
          ANDI.W  #$1C0,D3
          CMP.B   #$C0,D3
          BNE     TYP10C
          MOVEQ   #'A',D0
          BSR.L   DPRT
          BTST    #8,D3
          BEQ     TYP10B
          BCLR    #6,D4
          BRA     TYP10A
!TYP10B   BCLR    #7,D4
!TYP10A   BSR.L   GREFFADK
          MOVE    D2,D4
          LSR     #5,D4
          LSR.B   #4,D4
          BSR     EFFADR
          RTS
!TYP10C   BTST    #8,D4
          BEQ     ZIELDR
          BSR.L   REGSCH
          ANDI.W  #$C7,D4
          BSR.L   GREFFADK
          MOVE    D2,D4
          BSR     EFFADR
          RTS
!ZIELDR   BSR.L   GREFFADK
          BSR.L   REGSCH
          ANDI.W  #$C7,D4
          BSR     EFFADR
          RTS
;
!TYP11    MOVE    D2,D4 ;ADDX
          BTST    #3,D2
          BEQ     TYP11D
          EORI.W  #$28,D4
!TYP11D   BSR.L   GREFFADK
          BSR.L   REGSCH
          BSR     EFFADR
          RTS
;
!TYP12    BSR.L   DPRTTAB ;EXG
          MOVE    D2,D4
          LSR     #8,D4
          LSR     #1,D4
          ANDI.W  #$7,D4
          MOVE    D2,D3
          ANDI.W  #$F8,D3
          CMPI.W  #$48,D3
          BNE     TYP12A
          OR      #$8,D4
!TYP12A   BSR.L   EFFADK
          MOVE    D2,D4
          ANDI.W  #$F,D4
          BSR     EFFADR
          RTS
;
!TYP13    BSR.L   DPRTTAB ;BTST
          BTST    #8,D2
          BEQ     STATISCH
          MOVE    D2,D4
          LSR     #8,D4
          LSR     #1,D4
          ANDI.W  #$7,D4
          BSR.L   EFFADK
          MOVE    D2,D4
          BSR     EFFADR
          RTS
!STATISCH CMPI.W  #$083C,D2  ; BTST STATIC mit #(unmittelbar) EA?
          BEQ     FORMERR
          BSR     IMM
          BSR     Dollar
          MOVE    (A1)+,D0
          BSR     DPRTBYTE
          BSR     KOMMA
          MOVE    D2,D4
          BSR     EFFADR
          RTS
;
!TYP14    MOVE    D2,D4 ;ANDI
          ANDI.W  #$C0,D4
          OR      #$3C,D4
          BSR.L   GREFFADK
          MOVE    D2,D4
          BTST    #10,D2
          BNE     TYP14A
          ANDI.W  #$3F,D4 ;ANDI, EORI, ORI
          CMPI.W  #$3C,D4 ;SPEZIAL?
          BNE     TYP14A
          BTST    #6,D2
          BEQ.L   CCROUT
          BNE.L   PRSR
!TYP14A   BSR     EFFADR
          RTS
;
!TYP15    BSR.L   DPRTTAB ;UNLK
          MOVE    D2,D4
          ANDI.W  #$F,D4
          BSR     EFFADR
          RTS
;
;
;
!TYP16    MOVEQ   #'R',D0 ;ASL
          BTST    #8,D2
          BEQ     TYP16A
          MOVEQ   #'L',D0
!TYP16A   BSR.L   DPRT
          MOVE    D2,D4
          CMP.B   #$C0,D2
          BCS     DRSCH
          BTST    #11,D2
          BNE     FORMERR
          BSR.L   DPRTTAB
          BSR     EFFADR
          RTS
!DRSCH    MOVE    D2,D4
          BSR.L   GROESSE
          LSR     #8,D4
          LSR     #1,D4
          ANDI.W  #$7,D4
          BTST    #5,D2
          BEQ     SDIREKT
          BSR.L   EFFADR
          BRA     DRSCHA
!SDIREKT  BSR.L   IMM
          ANDI.W  #$7,D4
          BNE     DRSCHB
          MOVEQ   #8,D4
!DRSCHB   ADDI.W  #$30,D4
          MOVE    D4,D0
          BSR.L   DPRT
!DRSCHA   BSR.L   KOMMA
          MOVE    D2,D4
          ANDI.W  #$7,D4
          BSR     EFFADR
          RTS
;
;
!MOVEM1   LSR     #1,D4   ; fuer alle modi ausser predec.
          RTS
!MOVEM2   LSL     #1,D4   ; fuer predecrement
          RTS
;
!TYP17    MOVEQ   #$40,D4 ;MOVEP
          BTST    #6,D2
          BEQ     TYP17A
          MOVEQ   #$80,D4
!TYP17A   BSR.L   GROESSE
          MOVE    D2,D4
          BTST    #7,D2
          BNE     TYP17B
          OR      #$20,D4
          BSR.L   EFFADK
          BSR.L   REGSCH
          ANDI.W  #7,D4
          BSR     EFFADR
          RTS
!TYP17B   BSR.L   REGSCH
          ANDI.W  #$7,D4
          BSR.L   EFFADK
          MOVE    D2,D4
          OR      #$20,D4
          BSR     EFFADR
          RTS
!TYP18    MOVE    D2,D4 ;EXT
          ANDI.W  #$47,D4
          ADDI.W  #$40,D4
          BSR     DPRTTAB
          BSR     EFFADR
          RTS
!TYP19    MOVE    D2,D4 ;MOVEM
          SUB     #$40,D4
          BSR.L   GROESSE
          MOVE    (A1)+,A5 ;LISTE
          BTST    #10,D2
          BEQ     TOSTORE
          BSR.L   EFFADK
          MOVE    A5,D4
          LEA     MOVEM1(PC),A5
!REGLISTE CLR     D7
          MOVEQ   #'D',D1
          BSR.L   REGL1
          MOVEQ   #'A',D1
!REGL1    MOVEQ   #'0',D3
!REGL11   JSR     (A5) ;VERSCHIEDENE REIHENFOLGE
          BCC     REGL12
          BTST    #0,D7
          BEQ     REGL16
          MOVE    D4,D0
          ANDI.W  #$8001,D0
          BNE     REGL12
!REGL16   MOVE    D1,D0
          BSR.L   DPRT
          MOVE    D3,D0
          BSR.L   DPRT
          MOVE    D4,D0
          ANDI.W  #$8001,D0
          BNE     REGL13
          BCLR    #0,D7
          CMPI.W  #$0,D4
          BEQ     REGL14
          MOVEQ   #'/',D0
          BSR.L   DPRT
          BRA     REGL12
!REGL13   MOVEQ   #'-',D0
          BSR.L   DPRT
          BSET    #0,D7
!REGL12   ADDQ    #1,D3
          CMPI.W  #'8',D3
          BNE     REGL11
!REGL14   RTS

!TOSTORE  MOVE    A5,D4       ; Reg.Liste
          MOVE    D2,D3         ; Op-code
          ANDI    #$0038,D3     ; adr.-mode
          CMPI    #$0020,D3     ; adr.-mode = PREDEC ?
          BEQ     TOSTOR1
          LEA     MOVEM1(PC),A5
          BRA     TOSTORC
TOSTOR1   LEA     MOVEM2(PC),A5
TOSTORC   BSR     REGLISTE
          BSR.L   KOMMA
          MOVE    D2,D4
          BSR     EFFADR
          RTS
;
!TYP20    BSR.L   DPRTTAB ;LINK
          MOVE    D2,D4
          EORI.W  #$18,D4
          BSR.L   EFFADK
          BSR.L   IMM
          BRA.L   ADRPR
!TYP21    BSR.L   DPRTTAB ;TRAP
          MOVE    D2,D4
          ANDI.W  #$F,D4
!DEZIMAL  BSR.L   IMM
          CMPI.W  #$A,D4
          BMI     EINERZ
          MOVEQ   #$30,D0
!DEZIMAL1 ADDQ    #1,D0
          SUB     #$A,D4
          CMPI.W  #$A,D4
          BPL     DEZIMAL1
          BSR.L   ASCI22
!EINERZ   MOVE    D4,D0
          OR      #$30,D0
          BRA     ASCI22
!TYP22    MOVEQ   #'.',D0 ;MOVE USP
          BSR.L   ASCI22
          MOVEQ   #'L',D0
          BSR.L   ASCI22
          MOVE    D2,D4
          BSR.L   DPRTTAB
          BTST    #3,D2
          BNE     FROMUSP
          EORI.W  #$28,D4
          BSR.L   EFFADK
!PRUSP    MOVEQ   #'U',D0
          BSR.L   ASCI22
          MOVEQ   #'S',D0
          BSR.L   ASCI22
          MOVEQ   #'P',D0
!ASCI22   BRA.L   DPRT
!FROMUSP  BSR.L   PRUSP
          BSR.L   KOMMA
          EORI.W  #$20,D4
          BSR     EFFADR
          RTS
!TYP23    BSR.L   PRPWTAB ;MOVE SR,..
          BSR.L   PRSR
          BSR.L   KOMMA
!TYP23A   MOVE    D2,D4
          ANDI    #$7F,D4
          BSR     EFFADR
          RTS
!TYP24    BSR.L   PRPWTAB ;MOVE..,SR
          BSR.L   TYP23A
          BSR.L   KOMMA
!PRSR     MOVEQ   #'S',D0
          BSR.L   ASCI22
!PRR      MOVEQ   #'R',D0
          BRA     ASCI22
!TYP25    BSR.L   PRPWTAB ;MOVE TO CCR
          BSR.L   TYP23A
          BSR.L   KOMMA
!CCROUT   MOVEQ   #'C',D0
          BSR     ASCI22
          BSR     ASCI22
          BRA     PRR
;
!TYP26    BSR.L   DPRTTAB ;LEA
          MOVE    D2,D4
          BSR.L   EFFADK
          MOVEQ   #'A',D0
          BSR.L   DPRT
          MOVE    D2,D0
          LSR     #4,D0
          LSR.B   #5,D0
          ORI     #$30,D0
          BRA.L   DPRT
;
!TYP27    BSR.L   DPRTTAB ;STOP
          BSR.L   IMM
          BRA.L   ADRPR1
;
!TYP28    MOVE    D2,D4 ;CMPM
          EORI.W  #$10,D4
          BSR.L   GREFFADK
          LSR     #6,D4
          LSR     #3,D4
          BSR     EFFADR
          RTS
;
!TYP29    BTST    #11,D2
          BNE     TYP29_2
!TYP29_1  BSR.L   DPRTTAB ;CALLM
          BSR.L   IMM
          BSR     DOLLAR
          MOVE.W  (A1)+,D0
          BSR     DPRTBYTE
          BSR     KOMMA
          MOVE.W  D2,D4
          BSR     EFFADR
          RTS
!TYP29_2  BSR     TYP29_2S ;MOVES
          MOVE.W  (A1)+,D5
          BTST    #11,D5
          BEQ     TYP29_3
          MOVE.W  D5,D0
          ROL.W   #4,D0
          BSR.L   PRTDREG
          BSR     KOMMA
          MOVE.W  D2,D4
          BRA     EFFADR
!TYP29_3  MOVE.W  D2,D4
          BSR     EFFADR
          BSR     KOMMA
          MOVE.W  D5,D0
          ROL.W   #4,D0
          BRA.L   PRTDREG
!TYP29_2S MOVE.W  D2,D0
          LSR.W   #6,D0
          ANDI.W  #3,D0
          BEQ     PRPBTAB
          SUBQ.W  #1,D0
          BEQ     PRPWTAB
          SUBQ.W  #1,D0
          BEQ     PRPLTAB
          BRA     FORMERR
;
TYP30     MOVEQ   #0,D0 ;CAS
          BSR     TYP30SIZE
          MOVE.W  (A1)+,D4
          MOVE.W  D4,D0
          BSR     PRTDREG
          BSR     KOMMA
          MOVE.W  D4,D0
          ASR.W   #6,D0
          BSR     PRTDREG
          BSR     KOMMA
          MOVE.W  D2,D4
          BSR     EFFADR
          RTS
;
TYP30SIZE MOVE.W  D2,D4
          ASR.W   #8,D4
          ASR.W   #1,D4
          ANDI.W  #3,D4
          BEQ     FORMERR
          CMP.B   D0,D4
          BEQ     FORMERR
          LEA     PRPBTAB(PC),A0
          SUBQ.W  #1,D4
          BEQ     TYP30A
          LEA     PRPWTAB(PC),A0
          SUBQ.W  #1,D4
          BEQ     TYP30A
          LEA     PRPLTAB(PC),A0
TYP30A    JMP     (A0)
;
PRTDREG   MOVE.W  D0,-(SP)
          BTST    #3,D0
          BEQ     PRTDREG1
          MOVEQ   #'A',D0
          BRA     PRTDREG2
PRTDREG1  MOVEQ   #'D',D0
PRTDREG2  BSR     DPRT
          MOVE.W  (SP)+,D0
          ANDI.B  #7,D0
          ORI.B   #$30,D0
          BRA     DPRT
;
TYP31     MOVEQ   #1,D0 ;CAS2
          BSR     TYP30SIZE
          MOVE.W  (A1)+,D4
          MOVE.W  (A1)+,D3
          MOVE.W  D4,D0
          BSR     PRTDREG
          BSR     DOPPELPKT
          MOVE.W  D3,D0
          BSR     PRTDREG
          BSR     KOMMA
          MOVE.W  D4,D0
          ASR.W   #6,D0
          BSR     PRTDREG
          BSR     DOPPELPKT
          MOVE.W  D3,D0
          ASR.W   #6,D0
          BSR     PRTDREG
          BSR     KOMMA
          BSR     KLAMAUF
          MOVE.W  D4,D0
          ROL.W   #4,D0
          BSR     PRTDREG
          BSR     KLAMZU
          BSR     DOPPELPKT
          BSR     KLAMAUF
          MOVE.W  D3,D0
          ROL.W   #4,D0
          BSR     PRTDREG
          BRA     KLAMZU
;
TYP32     BSR     TYP32SIZE ;CHK2,CMP2
          MOVE.W  (A1)+,-(SP)
          MOVE.W  D2,D4
          BSR     EFFADR
          BSR     KOMMA
          MOVE.W  (SP)+,D0
          ROL.W   #4,D0
          BRA     PRTDREG
TYP32SIZE MOVE.W  D2,D4
          ASR.W   #8,D4
          ASR.W   #1,D4
          ANDI.W  #3,D4
          CMPI.B  #3,D4
          BEQ     FORMERR
          LEA     PRPBTAB(PC),A0
          SUBQ.W  #1,D4
          BMI     TYP30A
          LEA     PRPWTAB(PC),A0
          SUBQ.W  #1,D4
          BMI     TYP30A
          LEA     PRPLTAB(PC),A0
TYP32A    JMP     (A0)
;
TYP33_EQU MOVE.W  D5,D0    ; Dh und Dl bzw. Dr und Dq gleich ?
          ANDI.W  #7,D0
          MOVE.W  D5,D1
          ROL.W   #4,D1
          ANDI.W  #7,D1
          CMP.W   D1,D0
          RTS
;
TYP33_Q   BSR     DPRTSPC
          MOVEQ   #'?',D0
          BSR     DPRT
          MOVEQ   #'!',D0
          BRA     DPRT
;
TYP33_L   MOVE.W  D5,D0
          ANDI.B  #7,D0
          BSR     PRTDREG
          BSR     DOPPELPKT
TYP33_S   MOVE.W  D5,D0
          ROL.W   #4,D0
          ANDI.B  #7,D0
          BRA     PRTDREG
;
TYP33     MOVE.W  (A1)+,D5 ;DIVS.L,DIVSL.L,MULS.L
          MOVE.L  D2,D4    ;DIVU.L,DIVUL.L,MULU.L
          MOVEQ   #'U',D0
          BTST    #11,D5   ; signed or unsigned?
          BEQ     TYP33_1
          MOVEQ   #'S',D0
TYP33_1   BSR     DPRT
          BTST    #6,D2    ; Division oder Multiplikation
          BEQ     TYP33_2  ; Multiplikation
          BTST    #10,D5   ; Size ?
          BNE     TYP33_2  ; 64/32, dann nix
          BSR     TYP33_EQU
          BEQ     TYP33_2
          MOVEQ   #'L',D0
          BSR     DPRT
TYP33_2   BSR     PRPLTAB
          MOVE.W  D2,D0
          ANDI.W  #$3F,D0
          CMPI.W  #$3C,D0  ; unmittelbare Adressierung?
          BNE     TYP33_21
          BSR     IMM
          BSR     DOLLAR
          MOVE.L  (A1)+,D0
          BSR     DPRTLONG
          BRA     TYP33_22
TYP33_21  MOVE.W  D5,-(SP)
          BSR     EFFADR
          MOVE.W  (SP)+,D5
TYP33_22  BSR     KOMMA
          BTST    #6,D2    ; Division oder Multiplikation
          BNE     TYP33_3  ; zur Division
          BTST    #10,D5   ; Size?
          BEQ     TYP33_S
TYP33_LONG
          BSR     TYP33_EQU
          BNE     TYP33_L
          BSR     TYP33_L
          BRA     TYP33_Q
TYP33_3   BTST    #10,D5   ; Size?
          BNE     TYP33_LONG
          BSR     TYP33_EQU
          BEQ     TYP33_S
          BRA     TYP33_L
;
TYP34     BSR     DPRTTAB ;PACK,UNPK
          BTST    #3,D2
          BEQ     TYP34_register
          MOVEQ   #'-',D0
          BSR     DPRT
          BSR     KLAMAUF
          MOVE.W  D2,D0
          BSR     PRTDREG
          BSR     KLAMZU
          BSR     KOMMA
          MOVEQ   #'-',D0
          BSR     DPRT
          BSR     KLAMAUF
          MOVE.W  D2,D0
          ROL.W   #7,D0
          ORI.B   #8,D0
          BSR     PRTDREG
          BSR     KLAMZU
          BRA     TYP34_ADJ
TYP34_register
          MOVE.W  D2,D0
          BSR     PRTDREG
          BSR     KOMMA
          MOVE.W  D2,D0
          ROL.W   #7,D0
          ANDI.B  #7,D0
          BSR     PRTDREG
TYP34_ADJ BSR     KOMMA
          BSR.L   IMM
          BSR     DOLLAR
          BRA.L   ADRPR1
;
TYP35     BSR     DPRTTAB ; alle BitField's
          MOVE.W  (A1)+,D4
          BTST    #8,D2
          BEQ     TYP35_1
          MOVE.W  D2,D0
          ROL.W   #7,D0
          ANDI.B  #3,D0
          CMPI.B  #3,D0   ; BFINS ?
          BNE     TYP35_2
          MOVE.W  D4,D0
          ROL.W   #4,D0
          BSR     PRTDREG
          BSR     KOMMA
          BRA     TYP35_1
TYP35_2   BSR     TYP35_1
          BSR     KOMMA
          MOVE.W  D4,D0
          ROL.W   #4,D0
          BRA     PRTDREG
TYP35_1   MOVE.W  D4,-(SP)
          MOVE.W  D2,D4
          BSR     EFFADR
          MOVEQ   #'{',D0
          BSR     DPRT
          MOVE.W  (SP)+,D4
          MOVE.W  D4,D0
          ASR.W   #6,D0
          BSR     TYP35_3
          BSR     DOPPELPKT
          MOVE.W  D4,D0
          BSR     TYP35_3
          MOVEQ   #'}',D0
          BRA     DPRT
TYP35_3   BTST    #5,D0
          BEQ     TYP35_4
          ANDI.B  #7,D0
          BRA     PRTDREG
TYP35_4   ANDI.B  #31,D0
          MOVE.W  D0,-(SP)
          BSR     DOLLAR
          MOVE.W  (SP)+,D0
          BRA     DPRTBYTE
;
TYP36     BSR     DPRTTAB
          MOVE.W  (A1)+,D4
          BTST    #0,D2
          BEQ     TYP36_1
          BSR     TYP36_gen
          BSR     KOMMA
          BRA     TYP36_con
TYP36_1   BSR     TYP36_con
          BSR     KOMMA
TYP36_gen MOVE.W  D4,D0
          ROL.W   #4,D0
          BRA     PRTDREG
TYP36_con LEA     CREG10(PC),A0
          TST     isD20(A4)
          BEQ     TYP36_concomp
          LEA     CREG20(PC),A0
          TST     isD40(A4)
          BEQ     TYP36_concomp
          LEA     CREG40(PC),A0
TYP36_concomp
          MOVE.L  A3,-(SP)
          LEA     CREG(PC),A3
          MOVE.W  D4,D0
          ANDI.W  #$FFF,D0
          MOVEQ   #-1,D1
TYP36_loop
          ADDQ    #1,D1
          CMPA.L  A3,A0
          BEQ     TYP36_err
          CMP.W   (A3)+,D0
          BNE     TYP36_loop
          TST     isD40(A4)
          BEQ     TYP36_vgl
          CMPI.W  #$802,D0 ;CAAR ist bei 68040 nicht vorhanden!
          BEQ     TYP36_err
TYP36_vgl ASL.W   #2,D1
          LEA     CREGMN(PC),A3
TYP36_out ADDA.W  D1,A3
          MOVE.B  (A3)+,D0
          BSR     DPRT
          MOVE.B  (A3)+,D0
          BSR     DPRT
          MOVE.B  (A3)+,D0
          CMPI.B  #SPC,D0
          BEQ     TYP36_end
          BSR     DPRT
          MOVE.B  (A3)+,D0
          CMPI.B  #SPC,D0
          BEQ     TYP36_end
          BSR     DPRT
TYP36_end MOVE.L  (SP)+,A3
          RTS
TYP36_err MOVE.L  (SP)+,A3
          BRA     FORMERRP
;
!CREGMN   ASC     'SFC DFC USP VBR '
          ASC     'CACRCAARMSP ISP '
          ASC     'TC  ITT0ITT1DTT0DTT1PSR URP SRP '
!CREG     DC.W    0,1,$800,$801
!CREG10   DC.W    2,$802,$803,$804
!CREG20   DC.W    3,4,5,6,7,$805,$806,$807
!CREG40
;
TYP37     MOVE.W  D2,D4 ;TRAPcc
          ANDI.B  #$7,D4
          BEQ     FORMERR
          CMPI.B  #1,D4
          BEQ     FORMERR
          CMPI.B  #5,D4
          BCC     FORMERR
          MOVE    D2,D3
          LSR     #7,D3
          ANDI.W  #$1E,D3
          BSR.L   CC1
          MOVE.W  D2,D4
          ANDI.B  #$7,D4
          CMPI.B  #4,D4
          BEQ     TYP37end
          CMPI.B  #3,D4
          BEQ     TYP37L
          BSR     PRPWTAB
          BSR     IMM
          BSR     DOLLAR
          MOVE.W  (A1)+,D0
          BRA     DPRTWORD
TYP37L    BSR     PRPLTAB
          BSR     IMM
          BSR     DOLLAR
          MOVE.L  (A1)+,D0
          BRA     DPRTLONG
TYP37end  RTS
;
TYP38     RTS
;
TYP39     BSR     DPRTTAB ;Link long format
          MOVE.W  D2,D0
          BSR     PRTDREG
          BSR     KOMMA
          BSR     IMM
          BSR     DOLLAR
          MOVE.L  (A1)+,D0
          BRA     DPRTLONG
;
TYP40     BSR     PRPWTAB
          BSR     CCROUT
          BSR     KOMMA
          BRA     TYP23A
;
!TYP41    BSR     DPRTTAB
          MOVE.W  D2,D4
          ANDI.W  #$7,D4
          BRA     DEZIMAL
;
!PMMURW   MOVEQ   #'W',D0
          BTST    #9,D5
          BEQ     PMMURW1
          MOVEQ   #'R',D0
!PMMURW1  BSR     DPRT
          BRA     DPRTTAB
;
!PMMUFD   BTST    #8,D5
          BEQ     PMMUFD1
          MOVEQ   #'F',D0
          BSR     DPRT
          MOVEQ   #'D',D0
          BSR     DPRT
!PMMUFD1  BRA     DPRTTAB
;
!PMMUFC   BTST    #4,D5
          BEQ     TYP42_4
          BTST    #3,D5
          BNE     FORMERRP
          BSR     IMM
          BRA     TYP42_3
!TYP42_2  MOVEQ   #'D',D0
          BSR     DPRT
!TYP42_3  MOVE.W  D5,D0
          ANDI.W  #7,D0
          BSR     DPRTNIBL
          BRA     TYP42_5
!TYP42_4  BTST    #3,D5
          BNE     TYP42_2
          MOVE.W  D5,D1
          ANDI.W  #7,D1
          CMPI.W  #1,D1
          BHI     FORMERRP
          BSR     TYP36_vgl
!TYP42_5  RTS
;
!TYP42    MOVE.W  D2,D4 ; PTEST 68030
          MOVE.W  (A1)+,D5
          MOVE.W  D5,D0
          ROL.W   #3,D0
          ANDI.W  #7,D0
          BNE     TYP42_1
          BTST    #8,D5
          BNE     FORMERR
          MOVE.W  D5,D0
          ASR.W   #5,D0
          ANDI.W  #7,D0
          BNE     FORMERR
!TYP42_1  BSR     PMMURW
          BSR     PMMUFC
          BSR     KOMMA
          BSR     EFFADR
          BSR     KOMMA
          BSR     IMM
          MOVE.W  D5,D0
          ROL.W   #6,D0
          ANDI    #7,D0
          BSR     DPRTNIBL
          BTST    #8,D5
          BEQ     TYP42_6
          BSR     KOMMA
          MOVEQ   #'A',D0
          BSR     DPRT
          MOVE.W  D5,D0
          ASR.W   #5,D0
          ANDI.W  #7,D0
          BSR     DPRTNIBL
!TYP42_6  RTS
;
!TYP43    MOVE.W  (A1)+,D5 ; PFLUSH 68030
          MOVE.W  D5,D0
          ROL.W   #6,D0
          ANDI.W  #7,D0    ; Mode holen
          CMPI.W  #1,D0
          BNE     TYP43_1
          TST.B   D5
          BNE     FORMERR
          MOVEQ   #'A',D0
          BRA     DPRT
!TYP43_1  CMPI.W  #3,D0
          BLS     FORMERR
          CMPI.W  #5,D0
          BEQ     FORMERR
          CMPI.W  #7,D0
          BEQ     FORMERR
          BSR     DPRTTAB
          BSR     PMMUFC
          BSR     KOMMA
          BSR     IMM
          MOVE.W  D5,D0
          ASR.W   #5,D0
          BSR     DPRTNIBL
          BTST    #11,D5
          BEQ     TYP43_2
          BSR     KOMMA
          MOVE.L  D2,D4
          BSR     EFFADR
TYP43_2   RTS
;
!TYP44    MOVE.W  (A1)+,D5 ; PLOAD 68030
          BSR     PMMURW
          BSR     PMMUFC
          BSR     KOMMA
          MOVE.L  D2,D4
          BRA     EFFADR
;
PMMU30REG DC.W    2,3,$18,$10,$12,$13,0
;
PMMU30REGASC
          ASC     'TT0 TT1 PSR TC  SRP CRP '
          SYNC
;
!PMMUREG  MOVE.W  D5,D0
          ROL.W   #6,D0
          ANDI.W  #$3F,D0
          MOVEQ   #-1,D1
          LEA     PMMU30REG(PC),A0
PMMUREG_2 ADDQ    #1,D1
          MOVE.W  (A0)+,D3
          BEQ     FORMERR
          CMP.W   D3,D0
          BNE     PMMUREG_2
          MOVE.L  A3,-(SP)
          LEA     PMMU30REGASC(PC),A3
          ASL.W   #2,D1
          BRA     TYP36_out
;
!TYP45    MOVE.W  (A1)+,D5 ; PMOVE 68030
          BTST    #9,D5    ; R/W Feld
          BNE     TYP45_1  ; preg to ea
          BTST    #13,D5   ; PMOVE fÅr SRP,CRP,TC oder TT?
          BEQ     TYP45_1
          BTST    #8,D5    ; PMOVE fÅr PSR und FD Field = 1
          BNE     FORMERR  ; dann Fehler!
          BSR     DPRTTAB
          BRA     TYP45_2
TYP45_1   BSR     PMMUFD
TYP45_2   MOVE.L  D2,D4
          BTST    #9,D5
          BEQ     TYP45_3
          BSR     PMMUREG
          BSR     KOMMA
          BRA     EFFADR
TYP45_3   BSR     EFFADR
          BSR     KOMMA
          BRA     PMMUREG
;
!Scope    ASC     'LPA'
          SYNC
!CacheField
          ASC     'NCDCICBC'
;
!MMU40A0  BSR     KLAMAUF
          MOVEQ   #'A',D0
          BSR     DPRT
          MOVE.W  D2,D0
          ANDI    #7,D0
          BSR     DPRTNIBL
          BRA     KLAMZU
;
!TYP46    MOVE.W  D2,D1 ; CPUSH & CINV
          ASR.W   #3,D1
          ANDI.W  #3,D1
          BEQ     FORMERR
          SUBQ    #1,D1
          LEA     Scope(PC),A0
          ADDA.W  D1,A0
          MOVE.B  (A0),D0
          BSR     DPRT
          BSR     DPRTTAB
          MOVE.W  D2,D0
          ASR.W   #6,D0
          ANDI.W  #3,D0
          ASL.W   #1,D0
          LEA     CacheField(PC),A0
          ADDA.W  D0,A0
          MOVE.W  (A0),D1
          MOVE.W  D1,D0
          ASR.W   #8,D0
          BSR     DPRT
          MOVE.W  D1,D0
          BSR     DPRT
          BSR     KOMMA
          BRA     MMU40A0
;
!TYP47    BTST    #4,D2 ; PFLUSH 68040
          BEQ     TYP47_1
          MOVEQ   #'A',D0
          BSR     DPRT
TYP47_1   BTST    #3,D2
          BNE     TYP47_2
          MOVEQ   #'N',D0
          BSR     DPRT
TYP47_2   BSR     DPRTTAB
          BTST    #4,D2
          BEQ     MMU40A0
          RTS
;
!TYP48    MOVE.W  D2,D5 ; PTEST 68040
          ASL.W   #4,D5
          BSR     PMMURW
          BRA     MMU40A0
;
!PLUS     MOVEQ   #'+',D0
          BRA     DPRT
;
!TYP49    BSR     DPRTTAB ; MOVE16
          BTST    #5,D2
          BEQ     TYP49_1
          BSR     MMU40A0
          BSR     PLUS
          BSR     KOMMA
          MOVE.W  (A1)+,D2
          ROL.W   #4,D2
          BSR     MMU40A0
          BSR     PLUS
          MOVE.W  D6,D2
          RTS
TYP49_1   BTST    #3,D2
          BEQ     TYP49_5
          BSR     DOLLAR
          MOVE.L  (A1)+,D0
          BSR     DPRTADR
          BSR     KOMMA
          BSR     MMU40A0
TYP49_2   BTST    #4,D2
          BEQ     PLUS
TYP49_4   RTS
TYP49_5   BSR     MMU40A0
          BSR     TYP49_2
          BSR     KOMMA
          BSR     DOLLAR
          MOVE.L  (A1)+,D0
          BRA     DPRTADR
;
!FGR      BRA.L   PRPLTAB
          BRA.L   PRPSTAB
          BRA.L   PRPXTAB
          BRA.L   PRPPTAB
          BRA.L   PRPWTAB
          BRA.L   PRPDTAB
          BRA.L   PRPBTAB
          BRA.L   PRPPTAB
;
!FGROESSE BTST    #14,D3
          BEQ     DPRTTAB
          MOVE.W  D3,D0
          ROL.W   #6,D0
          ANDI.W  #7,D0
          CMPI.W  #7,D0
          BEQ     FORMERRP
          LEA     FGR(PC),A0
          ASL.W   #2,D0
          ADDA.W  D0,A0
          JMP     (A0)
;
!FGROESE  BTST    #14,D3     ; nur fÅr FMOVE mit dynamischem K Faktor
          BEQ     DPRTTAB
          MOVE.W  D3,D0
          ROL.W   #6,D0
          ANDI.W  #7,D0
          LEA     FGR(PC),A0
          ASL.W   #2,D0
          ADDA.W  D0,A0
          JMP     (A0)
;
!FREG     MOVEQ   #'F',D0
          BSR     DPRT
          MOVEQ   #'P',D0
          BRA     DPRT
;
!FREGD    ANDI.W  #7,D0
          MOVE.W  D0,-(SP)
          BSR     FREG
          MOVE.W  (SP)+,D0
          ORI.W   #$30,D0
          BRA     DPRT
;
FREGT     BSET    #31,D7
          BEQ     FREGTE
          MOVE.L  D0,-(SP)
          MOVEQ   #'/',D0
          BSR     DPRT
          MOVE.L  (SP)+,D0
FREGTE    RTS
;
FREGC     BCLR    #31,D7
          BTST    #12,D3
          BEQ     FREGC1
          BSR     FREGT
          BSR     FREG
          MOVEQ   #'C',D0
          BSR     DPRT
          MOVEQ   #'R',D0
          BSR     DPRT
FREGC1    BTST    #11,D3
          BEQ     FREGC2
          BSR     FREGT
          BSR     FREG
          MOVEQ   #'S',D0
          BSR     DPRT
          MOVEQ   #'R',D0
          BSR     DPRT
FREGC2    BTST    #10,D3
          BEQ     FREGC3
          BSR     FREGT
          BSR     FREG
          MOVEQ   #'I',D0
          BSR     DPRT
          MOVEQ   #'A',D0
          BSR     DPRT
          MOVEQ   #'R',D0
          BSR     DPRT
FREGC3    RTS
;
!TYP50    MOVE.W  -2(A1),D3
          BTST    #14,D3
          BEQ     TYP50_1
          BSR     FGROESSE
          MOVE.W  D2,D4
          MOVE.W  D3,-(SP)
          MOVE.W  D3,D0
          ANDI.W  #$1C00,D0
          SWAP    D0
          CLR.W   D0
          OR.L    D0,D7
          BSET    #30,D7
          BSR     EFFADR
          MOVE.W  (SP)+,D3
          BRA     TYP50_2
TYP50_1   BSR     PRPXTAB
          MOVE.W  D3,D0
          ROL.W   #6,D0
          BSR     FREGD
          MOVE.W  D3,D1
          ASR.W   #7,D1
          ANDI.W  #7,D1
          MOVE.W  D3,D0
          ROL.W   #6,D0
          ANDI.W  #7,D0
          CMP.W   D1,D0
          BNE     TYP50_2
          MOVE.W  DCode(A4),D0
          CMPI.W  #146,D0
          BEQ     TYP50_E
          CMPI.W  #153,D0
          BCC     TYP50_2
          CMPI.W  #148,D0
          BCC     TYP50_E
          CMPI.W  #108,D0
          BCS     TYP50_2
          CMPI.W  #133,D0
          BCS     TYP50_E
TYP50_2   MOVE.W  DCode(A4),D0
          CMPI.W  #144,D0
          BEQ     TYP50_E
          BSR     KOMMA
          MOVE    D3,D0
          ASR.W   #7,D0
          BRA     FREGD
TYP50_E   RTS
;
!TYP51    MOVE.W  -2(A1),D3
          ROL.W   #6,D3
          ANDI.W  #7,D3
          CMPI.W  #1,D3     ; FPIAR?
          BEQ     TYP52
          MOVE.W  D2,D0
          ASR.W   #3,D0
          ANDI.W  #7,D0
          CMPI.W  #1,D0
          BEQ     FORMERR
!TYP52    MOVE.W  -2(A1),D3
          MOVE.L  D2,D4
          BSR     PRPLTAB
          BTST    #13,D3
          BEQ     TYP52_1
          BSR     FREGC
          BSR     KOMMA
          BRA     FMEFFADR
TYP52_1   MOVE.W  D3,-(SP)
          BSR     FMEFFADR
          BSR     KOMMA
          MOVE.W  (SP)+,D3
          BRA     FREGC
FMEFFADR  MOVE.W  D4,D0
          ANDI.W  #$3F,D0
          CMPI.W  #$3C,D0
          BNE     EFFADR
          BSR     IMM
          BSR     DOLLAR
          BTST    #10,D3
          BEQ     FMEFFADR1
          MOVE.L  (A1)+,D0
          BSR     DPRTLONG
FMEFFADR1 BTST    #11,D3
          BEQ     FMEFFADR2
          MOVE.L  (A1)+,D0
          BSR     DPRTLONG
FMEFFADR2 BTST    #12,D3
          BEQ     FMEFFADR3
          MOVE.L  (A1)+,D0
          BSR     DPRTLONG
FMEFFADR3 RTS
;
!TYP53    MOVE.W  -2(A1),D3
          BSR     PRPXTAB
          BSR     IMM
          BSR     DOLLAR
          MOVE.W  D3,D0
          ANDI.W  #127,D0
          BSR     DPRTBYTE
          BSR     KOMMA
          MOVE.W  D3,D0
          ASR.W   #7,D0
          BRA     FREGD
;
!TYP54    MOVE.W  -2(A1),D3
          MOVE.L  D2,D4
          BSR     PRPXTAB
          MOVE.W  D3,D0
          ROL.W   #5,D0
          ANDI.W  #3,D0
          ASL.W   #1,D0
          LEA     TYP54L(PC),A0
          ADDA.W  D0,A0
          JMP     (A0)
!TYP54L   BRA.S   TYP54_0
          BRA.S   TYP54_1
          BRA.S   TYP54_2
          BRA.S   TYP54_3
!TYP54_0  BSR     FREGDL
          BSR     KOMMA
          BRA     EFFADR
!TYP54_1  BSR     FREGDD
          BSR     KOMMA
          BRA     EFFADR
!TYP54_2  MOVE.W  D3,-(SP)
          BSR     EFFADR
          BSR     KOMMA
          MOVE.W  (SP)+,D3
          BRA     FREGDL
!TYP54_3  MOVE.W  D3,-(SP)
          BSR     EFFADR
          BSR     KOMMA
          MOVE.W  (SP)+,D3
;         BRA     FREGDD
!FREGDD   MOVEQ   #'D',D0
          BSR     DPRT
          MOVE.W  D3,D0
          ASR.W   #4,D0
          ANDI.W  #7,D0
          BRA     DPRTNIBL
!FREGDL   BCLR    #31,D7
          BTST    #12,D3
          BNE     FREGDPOST
          MOVEQ   #0,D1
FREGD1L   MOVE.W  D1,D0
          BTST    D1,D3
          BEQ     FREGDL1
          BSR     FREGT
          BSR     FREGD
          ADDQ    #1,D1
          CMPI.B  #8,D1
          BCC     FREGD1E
          BTST    D1,D3
          BEQ     FREGD1L
FREGD1IO  ADDQ    #1,D1
          CMPI.B  #8,D1
          BCC     FREGD1O
          BTST    D1,D3
          BNE     FREGD1IO
FREGD1O   SUBQ    #1,D1
          MOVEQ   #'-',D0
          BSR     DPRT
          MOVE.W  D1,D0
          BSR     FREGD
FREGDL1   ADDQ    #1,D1
          CMPI.B  #8,D1
          BCS     FREGD1L
FREGD1E   RTS
FREGDPOSTTAB DC.B 7,6,5,4,3,2,1,0
FREGDP    LEA     FREGDPOSTTAB(PC),A0
          ANDI.W  #7,D0
          MOVE.B  0(A0,D0.W),D0
          BRA     FREGD
FREGDPOST MOVEQ   #7,D1
FREGD2L   MOVE.W  D1,D0
          BTST    D1,D3
          BEQ     FREGD2
          BSR     FREGT
          BSR     FREGDP
          SUBQ    #1,D1
          BMI     FREGDE
          BTST    D1,D3
          BEQ     FREGD2
FREGD2IL  SUBQ    #1,D1
          BMI     FREGD2O
          BTST    D1,D3
          BNE     FREGD2IL
FREGD2O   ADDQ    #1,D1
          MOVEQ   #'-',D0
          BSR     DPRT
          MOVE.W  D1,D0
          BSR     FREGDP
FREGD2    SUBQ    #1,D1
          BPL     FREGD2L
FREGDE    RTS
;
!TYP55    MOVE.W  -2(A1),D3
          BSR     FGROESE
          MOVE    D3,D0
          ASR.W   #7,D0
          BSR     FREGD
          BSR     KOMMA
          MOVE.L  D2,D4
          MOVE.W  D3,-(SP)
          BSR     EFFADR
          MOVE.W  (SP)+,D3
          MOVE.W  D3,D0
          ANDI.W  #$C00,D0
          CMPI.W  #$C00,D0
          BNE     TYP55_E
          MOVEQ   #'{',D0
          BSR     DPRT
          BTST    #12,D3
          BEQ     TYP55_S
          MOVE.W  D3,D0
          ASR.W   #4,D0
          ANDI.W  #7,D0
          BSR     PRTDREG
          BRA     TYP55_K
!TYP55_S  BSR     IMM
          BTST    #6,D3
          BEQ     TYP55_P
          MOVEQ   #'-',D0
          BSR     DPRT
          BSR     DOLLAR
          MOVE.W  D3,D0
          ORI.W   #$FF80,D0
          NEG.W   D0
          BRA     TYP55_O
!TYP55_P  BSR     DOLLAR
          MOVE.W  D3,D0
          ANDI.W  #63,D0
          CMPI.W  #18,D0
          BCS     TYP55_O
          BSR     TYP55_O
          BRA     TYP33_Q
!TYP55_O  BSR     DPRTBYTE
!TYP55_K  MOVEQ   #'}',D0
          BRA     DPRT
!TYP55_E  RTS
;
!PRTFCC   ANDI.W  #31,D0
          ASL.W   #2,D0
          LEA     FCCTAB(PC),A0
          ADDA.W  D0,A0
          MOVE.B  (A0)+,D0
          BSR     DPRT
          MOVE.B  (A0)+,D0
          CMPI.B  #SPC,D0
          BEQ     PRTFCCE
          BSR     DPRT
          MOVE.B  (A0)+,D0
          CMPI.B  #SPC,D0
          BEQ     PRTFCCE
          BSR     DPRT
          MOVE.B  (A0)+,D0
          CMPI.B  #SPC,D0
          BEQ     PRTFCCE
          BSR     DPRT
PRTFCCE   RTS
;
!TYP56    MOVE.W  -2(A1),D0
          BSR     PRTFCC
          MOVE.W  D2,D0
          ANDI.W  #7,D0
          CMPI.W  #2,D0
          BEQ     TYP56W
          CMPI.W  #4,D0
          BEQ     TYP56E
          CMPI.W  #3,D0
          BNE     FORMERR
          BSR     PRPLTAB
          BSR     IMM
          BSR     DOLLAR
          MOVE.L  (A1)+,D0
          BRA     DPRTLONG
!TYP56W   BSR     PRPWTAB
          BSR     IMM
          BSR     DOLLAR
          MOVE.W  (A1)+,D0
          BRA     DPRTWORD
!TYP56E   RTS
;
!TYP57    MOVE.W  D2,D0
          BSR     PRTFCC
          BSR     DPRTTAB
          MOVE.L  A1,D0
          SUBQ.L  #2,D0
          BTST    #6,D2
          BEQ     TYP57W
          MOVE.W  -2(A1),D3
          SWAP    D3
          MOVE.W  (A1)+,D3
          ADD.L   D0,D3
          BRA     RELADR
!TYP57W   MOVE.W  -2(A1),D3
          EXT.L   D3
          ADD.L   D0,D3
          BRA     RELADR
;
!TYP58    MOVE.W  -2(A1),D0
          BSR     PRTFCC
          BSR     DPRTTAB
          MOVE.L  D2,D4
          BRA     EFFADR
;
!TYP59    MOVE.W  -2(A1),D0
          BSR     PRTFCC
          BSR     DPRTTAB
          MOVE.W  D2,D0
          ANDI.W  #7,D0
          BSR     PRTDREG
          BSR     KOMMA
          MOVE.L  A1,D0
          MOVE.W  (A1)+,D3
          EXT.L   D3
          ADD.L   D0,D3
          BRA     RELADR
;
!TYP60    MOVE.W  -2(A1),D3
          BTST    #14,D3
          BNE     TYP60M
          BSR     PRPXTAB
          MOVE.W  D3,D0
          ROL.W   #6,D0
          BSR     FREGD
          BRA     TYP601
!TYP60M   MOVE.W  D3,D0
          ROL.W   #6,D0
          BSR     FGROESSE
!TYP601   BSR     KOMMA
          MOVE.W  D3,D0
          BSR     FREGD
          BSR     DOPPELPKT
          MOVE.W  D3,D0
          ASR.W   #7,D3
          BRA     FREGD
;
!TYP61    MOVE.W  -2(A1),D3
          BSR     FGROESSE
          BTST    #14,D3
          BEQ     TYP61_1
          MOVE.W  D2,D4
          MOVE.W  D3,-(SP)
          BSR     EFFADR
          MOVE.W  (SP)+,D3
          BRA     TYP61_2
TYP61_1   MOVE.W  D3,D0
          ROL.W   #6,D0
          BSR     FREGD
TYP61_2   BSR     KOMMA
          MOVE    D3,D0
          BSR     FREGD
          BSR     DOPPELPKT
          MOVE    D3,D0
          ASR.W   #7,D0
          BRA     FREGD
;
!REGSCH   ANDI.W  #$F8,D4
          MOVE    D2,D3
          LSR     #6,D3
          LSR     #3,D3
          ANDI.W  #7,D3
          OR      D3,D4
          RTS
;
!EFFADK   BSR.L   EFFADR
          BRA.L   KOMMA
;
!GREFFADK BSR.S   GREFFAD
          BRA.L   KOMMA
;
!GREFFAD  BSR.L   GROESSE
          BRA     EFFADR
;
!GROESSE  MOVEQ   #'.',D0
          BSR.L   DPRT
          MOVEQ   #'L',D0
          BTST    #7,D4
          BNE     GROESSE1
          MOVEQ   #'B',D0
          BTST    #6,D4
          BEQ     GROESSE1
          MOVEQ   #'W',D0
!GROESSE1 BSR.L   DPRT
          BRA.L   DPRTTAB
;
;
!MODE7    MOVE.B  D4,D3
          AND.L   #7,D3
          BEQ     ADRWORD
          CMP.B   #1,D3
          BEQ.L   ADRLONG
          CMP.B   #4,D3
          BPL.L   IMMED
          
          ; PC relative Adr.
          CMPI.W  #2,D3         ; hhhh(PC) ?
          BEQ     Lang2
          CMP.B   #3,D3         ; hh(PC,Rn) ?
          BNE     MOD2    ;!!! eigentlich Fehler !!!

          TST     isD20(A4)
          BNE     MODE6

          ; Byte-Offset
          MOVE    (A1),D3
          ANDI    #$FF,D3
          CMPI.W  #$80,D3
          BPL     ZURUECK2
          ADD.L   A1,D3
          BRA     Mod20
!ZURUECK2 ADD.L   A1,D3
          SUB.L   #$100,D3
          BRA     Mod20
          
          ; Word-Offset
!LANG2    MOVE.L  A1,D3
          MOVE    (A1)+,D0
          EXT.L   D0
          ADD.L   D0,D3
          
Mod20     BSR     RELADR
          
!MOD2     BSR     KLAMAUF
          MOVEQ   #'P',D0
          BSR.L   DPRT
          MOVEQ   #'C',D0
          BSR.L   DPRT
          BTST    #0,D4
          BEQ     KLAMZU
          BRA     INDEX2

!ADRWORD  BSR     DOLLAR
          MOVE.W  (A1)+,D1
          EXT.L   D1
          MOVE.L  D1,D0
          SWAP    D0
          TST     isD20(A4)
          BEQ     ADRWORD1
          BSR     DPRTWORD
          BRA     ADRWORD2
ADRWORD1  BSR     DPRTBYTE
ADRWORD2  MOVE.W  D1,D0
          BSR     DPRTWORD
          MOVEQ   #'.',D0
          BSR     DPRT
          MOVEQ   #'W',D0
          BRA     DPRT
          
!ADRLONG  BSR     DOLLAR
          MOVE.W  (A1)+,D0
          TST     isD20(A4)
          BEQ.S   ADRLONG1
          BSR.L   DPRTWORD
          BSR     ADRPR1
          BRA     ADRLONG2
!ADRLONG1 BSR.L   DPRTBYTE
          BSR     ADRPR1
!ADRLONG2 MOVEQ   #'.',D0
          BSR     DPRT
          MOVEQ   #'L',D0
          BRA     DPRT
!IMMED    BSR.L   IMM
          BTST    #30,D7
          BNE     IMMEDnew
          BSR     DOLLAR
          MOVE.B  D4,D3
          LSR     #6,D3
          BEQ     BITE
          CMP.B   #1,D3
          BEQ     ADRPR1
          BSR.L   ADRPR1
          BRA     ADRPR1
!BITE     MOVE.W  (A1)+,D0
          BRA.L   DPRTBYTE
!IMMEDnew
          MOVE.L  D7,D0
          SWAP    D0
          ROL.W   #8,D0     ; Bits 28-26 aus D7 nach Bits 4-2 in D0
          ANDI.W  #$1C,D0
          TST     DisPrt(A4)
          BNE     IMMEDnewTEST
          TST     isFPU(A4)
          BEQ     IMMEDnoFPU
          LEA     IMMEDTB(PC),A0
          ADDA.W  D0,A0
          JMP     (A0)
!IMMEDnoFPU
          LEA     IMMEDTB1(PC),A0
          ADDA.W  D0,A0
          JMP     (A0)
!IMMEDnewTEST               ; damit bei Test auf 68040 FPU Code kein HÑnger passiert
          CMPI.W  #$1C,D0
          BEQ     FORMERR
          RTS
!IMMEDTB  BRA.L   IMMED1LONG
          BRA.L   IMMEDSINGLE
          BRA.L   IMMEDEXTENDED
          BRA.L   IMMEDPACKED
          BRA.L   IMMEDWORD
          BRA.L   IMMEDDOUBLE
          BRA.L   IMMEDBYTE
          BRA.L   FORMERR
!IMMEDTB1 BRA.L   IMMED1LONG
          BRA.L   IMMED1LONG
          BRA.L   IMMED3LONG
          BRA.L   IMMED3LONG
          BRA.L   IMMEDWORD
          BRA.L   IMMED2LONG
          BRA.L   IMMEDBYTE
          BRA.L   FORMERR
!IMMEDBYTE
          BSR     DOLLAR
          MOVE.W  (A1)+,D0
          BRA     DPRTBYTE
!IMMEDWORD
          BSR     DOLLAR
          MOVE.W  (A1)+,D0
          BRA     DPRTWORD
!IMMED3LONG
          BSR     DOLLAR
          BRA     IMMED3LON
!IMMED2LONG
          BSR     DOLLAR
          BRA     IMMED2LON
!IMMED1LONG
          BSR     DOLLAR
          BRA     IMMED1LON
!IMMED3LON
          MOVE.L  (A1)+,D0
          BSR     DPRTLONG
!IMMED2LON
          MOVE.L  (A1)+,D0
          BSR     DPRTLONG
!IMMED1LON
          MOVE.L  (A1)+,D0
          BRA     DPRTLONG
!IMMEDSINGLE
          FMOVE.S (A1)+,FP0
          FMOVE.X FP0,REALREAL(A4)
          BSR     DISMCONVREAL
          BRA     COPYREALREAL
!IMMEDDOUBLE
          FMOVE.D (A1)+,FP0
          FMOVE.X FP0,REALREAL(A4)
          BSR     DISMCONVREAL
          BRA     COPYREALREAL
!IMMEDEXTENDED
          FMOVE.X (A1)+,FP0
          FMOVE.X FP0,REALREAL(A4)
          BSR     DISMCONVREAL
          BRA     COPYREALREAL
!IMMEDPACKED
          FMOVE.P (A1)+,FP0
          FMOVE.X FP0,REALREAL(A4)
          BSR     DISMCONVREAL
!COPYREALREAL
          LEA     REALSTR(A4),A0
!COPYREALREALLOOP
          MOVE.B  (A0)+,D0
          BEQ     COPYREALREALEND
          CMPI.B  #SPC,D0
          BEQ     COPYREALREALLOOP
          BSR     DPRT
          BRA     COPYREALREALLOOP
!COPYREALREALEND
          RTS
;
;ENDE     DER     ZEILE
;
;
!CCRAUS   MOVE    D2,D3
          LSR     #7,D3
          ANDI.W  #$1E,D3
          CMPI.W  #$6000,D2
          BMI     CC1
          CMPI.W  #$6200,D2
          BPL     CC1
          ADDI.W  #$20,D3 ;BRA,BSR
!CC1      LEA     CCTAB(PC),A0
          MOVE.B  $0(A0,D3.W),D0
          BSR.L   DPRT
          MOVE.B  $1(A0,D3.W),D0
          BRA.L   DPRT
;
!DISASEND
;
; ENDE DES DISASSEMBLERS
