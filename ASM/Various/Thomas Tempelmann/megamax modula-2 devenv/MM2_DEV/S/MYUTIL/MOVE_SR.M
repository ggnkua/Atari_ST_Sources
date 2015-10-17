MODULE MOVE_SR;
(*$L-,N+,M-*)

FROM SYSTEM IMPORT LONGWORD;

(*
 * Emulator fÅr MOVE from SR
 *
 * Funktionsprinzip: Die Instr. wird im Supervisor-Mode ausgefÅhrt.
 *
 * >> Kann gar nicht funktionieren, weil dann auch gleich das gesetzte
 *    S-Bit mit Åbernommen wird, was ja gar nicht beabsichtigt ist.
 *    Auûerdem ist noch ein Fehler drin: Auf dem USP verbleiben 4 Byte!
 *
 * Ohne M2Init linken!
 *)

CONST (* XBIOS functions *)
      Supexec   = 38;
      (* GEMDOS functions *)
      PtermRes  = $31;
      PrintLine = $09;

      (* base page constants *)
      codestart = 8;
      codelen   = 12;
      datastart = 16;
      datalen   = 20;
      bssstart  = 24;
      bsslen    = 28;
      parent    = 36;

VAR old20, oldA0, oldSSP, old24: LONGWORD;

PROCEDURE trcExc;
  BEGIN
    ASSEMBLER
        MOVE.L  A0,oldA0
        MOVE.L  oldSSP,A0
        ADDQ.L  #2,A7           ; SR wieder vom USP runterholen
        MOVE.L  (A7)+,2(A0)     ; neuen PC setzen, altes SR erhalten
        ADDQ.L  #2,A7           ; SF vom USP runterholen
        MOVE.L  A7,USP
        MOVE.L  A0,A7
        MOVE.L  oldA0,A0
        MOVE.L  old24,$24
        RTE
    END
  END trcExc;

PROCEDURE privExc;
  (***** Einsprung bei Privilegsverletzung *****)
  BEGIN
    ASSEMBLER
        ; PrÅfen, ob MOVE from SR die Exc. ausgelîst hat
        ; *** fehlt noch!
        
        ; Trace-Vektor umsetzen
        MOVE.L  $24,old24
        MOVE.L  #trcExc,$24
        ; USP nach SP
        MOVE.L  A0,oldA0
        MOVE.L  USP,A0
        MOVE.W  #$0010,-(A0)
        MOVE.L  2(A7),-(A0)     ; PC auf -(USP)
        MOVE.W  (A7),-(A0)      ; SR auf -(USP)
        MOVE.L  A7,oldSSP       ; SSP retten
        MOVE.L  A0,A7           ; USP nach SSP
        MOVE.L  oldA0,A0
        ; Supervisor- und Trace-Bit setzen
        ORI.W   #$A000,(A7)
        RTE

rtn:    MOVE.L  old20,-(A7)     ; normalen Exc-Handler anspringen
    END
  END privExc;


PROCEDURE UseStackFrame (): BOOLEAN;
  BEGIN
    ASSEMBLER
        PEA     a(PC)
        MOVE    #Supexec,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        RTS

      a MOVE.L  A7,D2
        MOVE.L  $10,D1          ; Illegal Instruction Exc-Vektor
        LEA     b(PC),A0
        MOVE.L  A0,$10
        ILLEGAL                 ; DC.W    $4AFC
      b MOVE.L  A7,D0
        MOVE.L  D2,A7
        SUB.L   D0,D2
        SUBQ.L  #6,D2
        SNE     D0
        ANDI    #1,D0
        MOVE.L  D1,$10
    END
  END UseStackFrame;

BEGIN
  ASSEMBLER
        MOVE.L  4(A7),A5        ; Ptr to base page
        
        JSR     UseStackFrame
        TST     D0
        BEQ     no_inst         ; no emulation on 68000
        
        ; set vectors
        PEA     t(PC)
        MOVE    #Supexec,-(A7)
        TRAP    #14
        BRA     c
     t: MOVE.L  $20,old20
        MOVE.L  #privExc,$20
        RTS
     c:
        ; print msg
        PEA     msg_1(PC)
        MOVE.W  #PrintLine,-(A7)
        TRAP    #1
        
        ; install prg
        CLR.W   (A7)            ; exitcode: 0
        MOVE.L  codelen(A5),A0
        ADDA.L  datalen(A5),A0
        ADDA.L  bsslen(A5),A0
        ADDA.W  #256,A0
        MOVE.L  A0,-(A7)        ; total length of static program space
        MOVE.W  #PtermRes,-(A7) ; terminate process and stay resident
        TRAP    #1

no_inst:
        CLR.W   -(A7)
        TRAP    #1              ; Pterm0

msg_1   DC.B    13,10
        ASC     'MOVE from SR emulator for the Atari TT. Freeware by Thomas Tempelmann'
        DC.B    13,10,0
  END
END MOVE_SR.
