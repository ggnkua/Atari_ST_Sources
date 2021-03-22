IMPLEMENTATION MODULE UserTrace; (* V#015 *)
(*$M-,S-,R-*)

(* Erstellt August '88 von Thomas Tempelmann, unter Megamax Modula-2 *)
(* Anpassung an MOS V2 am 9.12.90 *)

FROM SYSTEM IMPORT ADR, ADDRESS, WORD, LONGWORD, BYTE, ASSEMBLER;

FROM PrgCtrl IMPORT TermProcess, CatchProcessTerm, TermCarrier;

FROM FastStrings IMPORT Assign, Length;

FROM MOSGlobals IMPORT UserBreak, MemArea;

FROM SysTypes IMPORT ScanDesc, ExcSet, TRAP5;

FROM AESForms IMPORT FormAlert;

FROM GEMScan IMPORT InputScan, InitChain, CallingChain;

FROM ShellMsg IMPORT ScanMode, ScanAddr, ErrorMsg, ScanIndex;

FROM Calls IMPORT CallSupervisor;


VAR scan: ScanDesc;     (* Wird in 'trap5entry' initialisiert *)

VAR active: BYTE;       (* Semaphore zum Schutz vor Wiedereintritt *)


PROCEDURE doStop;

  VAR ps: POINTER TO ARRAY [0..255] OF CHAR;
      index, button: CARDINAL;
      str: ARRAY [0..19] OF CHAR;

  BEGIN
    InitChain (scan);
    index:= 0;
    str:= 'UserTrace-Stop   ';
    InputScan (str, index);
    FormAlert (2, '[0][  UserTrace-Stop  ][Quit|Cont|Edit]', button);
    IF button = 3 THEN (* Edit *)
      ScanMode := TRUE;
      ScanIndex:= index;
      Assign (str, ErrorMsg);
      TermProcess (0)
    ELSIF button = 1 THEN (* Quit *)
      TermProcess (0)
    END
  END doStop;


PROCEDURE callSub;
  (*$L-*)
  BEGIN
    ASSEMBLER
        ; Routine im User-Mode ausfÅhren.
        ; Dazu eigenen Stack verwenden.
        ; Alter USP muû gerettet werden
        
        MOVE.L  USP,A1
        MOVE.L  A1,-(A7)        ; alten Daten-Stack retten
        
        LEA     stackLo(PC),A3  ; Parameter-Stack setzen
        LEA     stackHi(PC),A1
        MOVE.L  A1,USP          ; Daten-Stack setzen
        
        ANDI    #$CFFF,SR       ; User Mode aktivieren
        JSR     (A0)            ; Funktion aufrufen
        
        ; zurÅck in den Supervisor-Mode
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  D0,A7           ; SSP wiederherstellen
        MOVE.L  (A7)+,A1
        MOVE.L  A1,USP          ; USP wiederherstellen
        RTS
        
      stackLo:
        DS      2000            ; 2000 Byte fÅr Stack reservieren
      stackHi:
    END
  END callSub;
  (*$L=*)


PROCEDURE trap5entry;
  (*$L-*)
  BEGIN
    ASSEMBLER
        ; Wort nach TRAP 5 - Instr. prÅfen
        MOVE.L  A0,-(A7)
        MOVE.W  D0,-(A7)
        MOVE.L  8(SP),A0        ; PC laden
        MOVE.W  (A0)+,D0
        BEQ     check           ; es folgt Zeile -> Stop-Test
        CMPI.W  #63,D0
        BHI     check           ; Asm-Zeile oder Prozedurein-/ausstieg
        MOVE.L  A0,8(SP)        ; PC hinter Debug-Datum setzen
        LEA     sizeTable(PC),A0
        MOVE.B  0(A0,D0.W),D0
        EXT.W   D0
        SUBA.W  D0,A3           ; Wert von A3-Stack ertfernen
        MOVE.W  (A7)+,D0
        MOVE.L  (A7)+,A0
        RTE

      check:
        MOVE.W  (A7)+,D0
        TAS     active    ; ist Anfangs Null
        BNE     ret       ; Stop-Routine braucht selber nicht getested werden

        MOVEM.L D0-D7/A1-A6,-(SP)

        MOVE.L  Stop,A0
        JSR     callSub   ; Stop-Routine aufrufen
        TST.W   -(A3)     ; Ergebnis von Funktion (BOOLEAN) abholen
        BEQ     ende      ; Programm fortfÅhren

        ; Programm stoppen
        LEA     scan,A0
        MOVE.L  62(SP),scan.pc(A0)      ; PC
        MOVE.L  48(SP),scan.link(A0)    ; A5
        MOVE.L  USP,A1
        MOVE.L  A1,scan.stack(A0)       ; SP
        LEA     doStop,A0
        JSR     callSub
     ende:
        SF      active
        MOVE.L  62(SP),A0
        ADDQ.L  #2,A0
        MOVEM.L (A7)+,D0-D7/A1-A6

     ret:
        ; PC hinter Debug-Text setzen
     l: TST.B   (A0)+
        BNE     l
        ADDQ.L  #1,A0
        MOVE.L  A0,6(SP)
        BCLR    #0,9(SP)  ; PC begradigen

        MOVE.L  (A7)+,A0
        RTE
        
     sizeTable:
        ; Tabelle mit Grîûen der Werte auf dem A3-Stack
        DC.B    0,4,8,2,4,0,0,0,4,2,0,0,0,0,0,0,0,0,0,0,4,2,4,4,2,4,4,6,0,0
        DC.B    4,0,0,2,2,2,0,0,2,2,4,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DC.B    0,0,0,0
    END;
  END trap5entry;
  (*$L=*)


PROCEDURE dummy (): BOOLEAN;
  (*$L-*)
  BEGIN
    ASSEMBLER
        CLR     (A3)+
    END
  END dummy;
  (*$L=*)


VAR     trap5exc [$94]: PROC;
        oldtrap5: PROC;
        hdl: TermCarrier;
        wsp: MemArea;

PROCEDURE init (p: ADDRESS);
  BEGIN
    oldtrap5:= trap5exc;
    trap5exc:= trap5entry;
  END init;

PROCEDURE exit (p: ADDRESS);
  BEGIN
    trap5exc:= oldtrap5
  END exit;

PROCEDURE terminate;
  BEGIN
    CallSupervisor (exit, NIL, wsp);
  END terminate;
  
BEGIN
  Stop:= dummy;
  CallSupervisor (init, NIL, wsp);
  CatchProcessTerm (hdl,terminate,wsp); (* wsp.bottom ist NIL *)
END UserTrace.
