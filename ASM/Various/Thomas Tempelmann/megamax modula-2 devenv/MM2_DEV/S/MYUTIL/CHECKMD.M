MODULE CheckMD; (*$ E MOS *)

FROM Terminal IMPORT Read, WriteString, WriteLn;

FROM StrConv IMPORT LHexToStr;

FROM MOSCtrl IMPORT ProcessID;

FROM SYSTEM IMPORT ADDRESS, LONGWORD;


TYPE P_MD = POINTER TO MD;
     
     MD = RECORD
            next: P_MD;
            start: ADDRESS;
            length: LONGCARD;
            owner: LONGWORD    (* Bit 31: length ungerade, Rest des  *)
                               (* 1. Byte: ModLevel, Rest: Prozeû-ID *)
          END;

TYPE P_MPB = POINTER TO MPB;

     MPB = RECORD
             free: P_MD;
             used: P_MD;
             boomer: P_MD
           END;

VAR MPBPtr: P_MPB;

PROCEDURE GetMPBPtr;
  (*$L-*)
  BEGIN
    ASSEMBLER
        ; MPB-Root suchen
        CLR.L   MPBPtr

        PEA     set_trc(PC)
        MOVE    #4,-(A7)
        MOVE    #5,-(A7)
        TRAP    #13             ; setexec (4, set_trc)
        ADDQ.L  #8,A7
        ILLEGAL

        MOVE.L  #-1,-(A7)
        MOVE.W  #$48,-(A7)
        TRAP    #1              ; malloc (-1L)
        ADDQ.L  #6,A7

        PEA     rst_trc(PC)
        MOVE    #4,-(A7)
        MOVE    #5,-(A7)
        TRAP    #13             ; setexec (4, rst_trc)
        ADDQ.L  #8,A7
        ILLEGAL

        RTS

      set_trc:
        MOVE.L  D0,$10          ; vektor #4 wiederherstellen
        LEA     sv_trc(PC),A0
        MOVE.L  $24,(A0)        ; vektor #9 (trace) retten
        LEA     trace(PC),A0
        MOVE.L  A0,$24          ; vektor #9 (trace) setzen
        ORI.W   #$8000,(A7)     ; Trace-Bit setzen
        ADDQ.L  #2,2(A7)        ; PC hinter ILLEGAL-Instr
        RTE

      rst_trc:
        MOVE.L  D0,$10          ; vektor #4 wiederherstellen
        MOVE.L  sv_trc(PC),$24  ; vektor #9 (trace) rÅcksetzen
        ANDI.W  #$3FFF,(A7)     ; Trace-Bit(s) lîschen
        ADDQ.L  #2,2(A7)        ; PC hinter ILLEGAL-Instr
        RTE

      sv_trc:
        DC.L    0

      trace:
        MOVE.L  A0,-(A7)
        MOVE.L  4+2(A7),A0
        CMPI.W  #$4E90,(A0)     ; JMP (A0) - Instr ?
        BEQ     trc2
      trc3
        MOVE.L  (A7)+,A0
        ORI.W   #$8000,(A7)     ; Trace-Bit erneut setzen
        RTE
      trc2:
        LEA     trace2(PC),A0
        MOVE.L  A0,$24          ; setexec (9, trace2)
        BRA     trc3

      trace2:
        MOVE.L  A0,-(A7)
        MOVE.L  4+2(A7),A0
        CMPI.W  #$6100,(A0)     ; JSR x.L - Instr ?
        BEQ     trc4
        MOVE.L  (A7)+,A0
        RTE
      trc4:
        CMPI.L  #-1,4+6(A7)     ; steht -1 (malloc-param) auf Stack ?
        BNE     trc_err         ; nicht gefunden
        TST.B   4+6+4(A7)       ; ist Adr. v. MPB < $1000000 ?
        BNE     trc_err         ; nicht gefunden
        MOVE.L  4+6+4(A7),MPBPtr ; auf Supervisor-Stack steht MPB-Pointer
      trc_err
        MOVE.L  (A7)+,A0
        ANDI.W  #$7FFF,(A7)     ; Trace-Bit lîschen
        RTE
    END
  END GetMPBPtr;
  (*$L=*)


PROCEDURE GetMPB (VAR mpb: MPB);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A2
        PEA     l(PC)
        MOVE    #38,-(A7)
        TRAP    #14             ; Supexec ()
        ADDQ.L  #6,A7
        RTS
        
      l MOVE.L  MPBPtr,A0
        MOVE.L  MPB.free(A0),MPB.free(A2)
        MOVE.L  MPB.used(A0),MPB.used(A2)
        MOVE.L  MPB.boomer(A0),MPB.boomer(A2)
    END
  END GetMPB;
  (*$L=*)

PROCEDURE WriteLHex (l:LONGWORD);
  BEGIN
    WriteString (LHexToStr(l,9))
  END WriteLHex;

VAR mpb : MPB;
    used: P_MD;
    free: P_MD;
    ch  : CHAR;

PROCEDURE prt (used: P_MD);
  BEGIN
    WriteString (' start: '); WriteLHex (used^.start);
    WriteString (' length: '); WriteLHex (used^.length);
    WriteString (' end: '); WriteLHex (LONGCARD(used^.start)+used^.length);
    WriteString (' owner: '); WriteLHex (used^.owner);
    WriteLn;
    Read (ch);
  END prt;

BEGIN
  GetMPBPtr;
  IF MPBPtr = NIL THEN HALT END;
  WriteString ('F(ree list or U(sed list or B(oth ? ');
  REPEAT
    Read (ch); ch:= CAP (ch)
  UNTIL (ch='B') OR (ch='U') OR (ch='F') OR (ch=33C);
  IF ch=33C THEN RETURN END;
  WriteLn;
  WriteString ('ActProcess: '); WriteLHex (ProcessID^);
  WriteLn;
  GetMPB (mpb);
  IF ch='B' THEN
    used:= mpb.free;
    WriteString ('FREE:');
    WriteLn;
    WHILE (used # NIL) & (ADDRESS (used) >= $800L) DO
      prt (used);
      IF ch=33C THEN RETURN END;
      used:= used^.next;
    END;
    used:= mpb.used;
    WriteString ('USED:');
    WriteLn;
    WHILE (used # NIL) & (ADDRESS (used) >= $800L) DO
      prt (used);
      IF ch=33C THEN RETURN END;
      used:= used^.next;
    END;
    (* beides gleichzeitig geht nicht, weil free falsch herum geordnet ist
    used:= mpb.used;
    free:= mpb.free;
    LOOP
      IF ADDRESS (used) < $800L THEN EXIT END;
      IF (used = NIL) AND (free = NIL) THEN EXIT END;
      IF (free=NIL) OR ( (used#NIL) & (used^.start > free^.start) ) THEN
        WriteString ('  used! ');
        prt (used);
        used:= used^.next;
      ELSE
        WriteString ('  free! ');
        prt (free);
        free:= free^.next;
      END;
      IF ch=33C THEN RETURN END;
    END;
    *)
  ELSE
    IF ch='U' THEN
      used:= mpb.used
    ELSE
      used:= mpb.free
    END;
    WHILE (used # NIL) & (ADDRESS (used) >= $800L) DO
      WriteString ('MD: '); WriteLHex (used);
      WriteLn;
      prt (used);
      IF ch=33C THEN RETURN END;
      used:= used^.next;
    END;
  END;
  WriteString ('Ende.');
  Read (ch);
END CheckMD.

(* $FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$00000292$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99$FFF68A99Ä$00000EE9T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000011C5$00001103$00000EB1$00000EC0$00000E64$00000EEA$00000EDD$00000EE9$FFEE98EF$FFEE98EF$00001103$000010D9$000011D3$0000113C$0000120C$000011D3†ÄÄ*)
