MODULE Coroutin;

(*$E MOS *)
IMPORT TOSIO;
FROM InOut IMPORT KeyPressed, WriteString, WriteLn;

FROM SYSTEM IMPORT ASSEMBLER;
FROM SYSTEM IMPORT ADDRESS, LISTEN, TRANSFER, IOTRANSFER, NEWPROCESS, ADR;

FROM Storage IMPORT ALLOCATE, DEALLOCATE;

FROM SysInfo IMPORT UseStackFrame;

FROM RandomGen IMPORT RandomCard;

IMPORT MOSGlobals, PrgCtrl; (* nur f. lokales Modul *)


(*$L-*)

CONST   DftSF = $0010;
        rtsCode = $4E75;

VAR useSF: BOOLEAN;

PROCEDURE BadReturn;  (* RTS aus CoRoutine anmeckern *)
  BEGIN
    ASSEMBLER
        TRAP    #6
        DC.W    -15-$6000       ; kein cont, scan prev
    END
  END BadReturn;

(*
   Transferdaten beim Usermode:
        2  Byte - 0: zeigt Usermode an / 1: Vektor zus. restaurieren
        4  Byte - PC
        2  Byte - SR
        4  Byte - A6
        56 Byte - D0-A5
      { 60 Byte - FP3-FP7 }  (* wenn SwitchFPUContext = TRUE *)

   Transferdaten beim Supervisormode:
        2  Byte - $FFxx, zeigt Supervisormode an
        4  Byte - USP
        60 Byte - D0-A6
        4  Byte - Dummy
        2  Byte - SR
        4  Byte - PC
      { 60 Byte - FP3-FP7 }  (* wenn SwitchFPUContext = TRUE *)
*)

(* Kennung:      Zustand:
    0             Normal u. Exc-RÅckkehr - Usermode
    1             Warten auf Exc - Usermode, Vektor restaurieren
    $FF           Exc-RÅckkehr - Supervisormode
*)

PROCEDURE @NEWP ( p:PROC; a:ADDRESS; n:LONGCARD; VAR prc:ADDRESS );
  BEGIN
    ASSEMBLER
        LINK    A5,#0
        
        MOVE.L  -(A3),A1        ; 'prc'
        MOVE.L  -(A3),A0        ; SIZE (workspace)
        MOVE.L  A0,D1
        BCLR    #0,D1
        MOVE.L  -(A3),D0        ; ADR (workspace)
        ADDQ.L  #1,D0
        BCLR    #0,D0
        ADDA.L  D0,A0           ; ENDADR (workspace)
        MOVE.L  -(A3),D2        ; ADR (procedure)
        CMPI.L  #90,D1          ; ist workspace groû genug ?
        BCC     wspOk
        
        TRAP    #6
        DC.W    -10-$4000       ; 'out of stack'
        UNLK    A5
        RTS
        
      wspOk:
        MOVEM.L A3/A5,-(A7)
        
        MOVE.L  D0,A3
        
        MOVE.L  D2,-(A0)         ;Adresse fÅr scan
        ADDQ.L  #2,(A0)          ;scan-Adr etwas vorsetzen
        CLR.L   -(A0)            ;voriges A5
        MOVE.L  A0,A5            ;fÅr UNLK in backScan()
        MOVE.L  #BadReturn,-(A0) ;Fehlerbehandlung bei RTS aus Coroutine
        
        MOVEM.L D0-A5,-(A0)      ; Bis auf A3,A5 nur Dummy-Werte
        MOVE.L  A6,-(A0)
        MOVE.W  SR,-(A0)
        MOVE.L  D2,-(A0)
        CLR.W   -(A0)
        
        ; nun den SP in 'prc' ablegen
        MOVE.L  A0,(A1)
        
        MOVEM.L (A7)+,A3/A5
        UNLK    A5
    END
  END @NEWP;

PROCEDURE @TRAN ( VAR source,dest:ADDRESS );  (* Transfer *)
  BEGIN
    ASSEMBLER
        ; Aufruf erfolgt immer im Usermode, der zu startende Prozeû
        ; kann in beiden Modi ablaufen
        
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  A7,A0
        MOVE.L  D0,A7
        
        MOVE.L  -(A3),A2        ; dest
        MOVE.L  -(A3),A1        ; source
        MOVE    SR,D2
        ANDI    #$CFFF,D2
        
        MOVE    #$2700,SR       ; keine Interrupts !
        
        ; aktiven Prozeû beenden
        MOVE.L  (A0)+,D0        ; RÅcksprungadr. hinter TRANSFER
        MOVEM.L D0-A5,-(A0)
        MOVE.L  A6,-(A0)
        MOVE.W  D2,-(A0)
        MOVE.L  D0,-(A0)
        CLR.W   -(A0)
        
        MOVE.L  (A2),D0         ; zuerst retten, falls A1=A2
        MOVE.L  A0,(A1)
        MOVE.L  D0,A6
        
        ; neuen Prozeû starten
        TST.W   (A6)+
        BEQ     stUsr
        BMI     stSup
        
        ; starte Usermode, vorher Vektor restaurieren
        MOVE.L  (A6)+,D0        ; alter Vektor
        MOVE.L  4+2+4+4(A6),A0  ; D1: Vektoradr.
        MOVE.L  D0,(A0)
        TST     useSF
        BEQ     no20
        MOVE    #DftSF,-(A7)
no20:
        MOVE.L  (A6)+,-(A7)     ; PC
        MOVE.W  (A6)+,-(A7)     ; SR
        MOVE.L  (A6)+,-(A7)     ; A6
        MOVEM.L (A6)+,D0-A5
        MOVE.L  A6,USP
        MOVE.L  (A7)+,A6
        RTE
        
stUsr:  ; starte Usermode
        TST     useSF
        BEQ     no20b
        MOVE    #DftSF,-(A7)
no20b:
        MOVE.L  (A6)+,-(A7)     ; PC
        MOVE.W  (A6)+,-(A7)     ; SR
        MOVE.L  (A6)+,-(A7)     ; A6
        MOVEM.L (A6)+,D0-A5
        MOVE.L  A6,USP
        MOVE.L  (A7)+,A6
        RTE
        
stSup:  ; starte Supervisormode
        MOVE.L  A6,A7
        MOVE.L  (A7)+,A0
        MOVE.L  A0,USP
        MOVEM.L (A7)+,D0-A6
        ADDQ.L  #4,A7
        TST     useSF
        BEQ     no20c
        MOVE.W  (A7),-(A7)
        MOVE.L  4(A7),2(A7)
        MOVE    #DftSF,6(A7)
no20c:
        RTE
    END
  END @TRAN;

PROCEDURE @LSTN;
  BEGIN
    ASSEMBLER
        PEA     P(PC)
        MOVE    #38,-(A7)
        TRAP    #14
        ADDQ.L  #6,A7
        RTS
     P: MOVE    SR,D1
        MOVE    D1,D0
        ANDI    #$0700,D0
        BEQ     ok
        MOVE    D1,D0
        SUBI    #$0100,D0
        MOVE    D0,SR
        NOP
        NOP
      ok:
        MOVE    D1,SR
    END
  END @LSTN;

PROCEDURE hdlExc;
  (* FÅr IOTRANSFER-Auslîsungen per Exception *)
  BEGIN
    ASSEMBLER
        ; Der Aufruf kann aus beiden Modi kommen, der zu startende
        ; Prozeû ist immer im Usermode
        
        MOVE    #$2700,SR       ; keine Interrupts !
        
        BTST.B  #5,4(A7)        ; aus welchem mode ?
        BNE     frSup
        
        ; Entry aus User mode
        
        ; Daten auf den USP retten
        MOVE.L  A6,-(A7)
        MOVE.L  USP,A6
        MOVEM.L D0-A5,-(A6)
        MOVE.L  (A7)+,-(A6)
        MOVE.L  (A7)+,A0        ; ^Transfer-Daten
        MOVE    (A7)+,-(A6)     ; SR
        MOVE.L  (A7)+,-(A6)     ; PC
        CLR.W   -(A6)
        
        ; A0 zeigt auf:
        ; 2  Byte - 1, zeigt IOTR an
        ; 4  Byte - alter Exc-Vektor
        ; 4  Byte - PC
        ; 2  Byte - SR
        ; 4  Byte - A6
        ; 56 Byte - D0-A5
        
        MOVE.L  2+4+4+2+4+32+8(A0),A2  ; A2: alter dest^
        MOVE.L  A6,(A2)
        
        MOVE.L  2+4+4+2+4+4(A0),A3  ; D1: Vektoradr.
        LEA     2(A0),A6
        MOVE.L  (A6)+,(A3)      ; alten Vektor restaurieren
        TST     useSF
        BEQ     no20d
        MOVE    #DftSF,-(A7)
no20d:
        MOVE.L  (A6)+,-(A7)     ; PC
        MOVE.W  (A6)+,-(A7)     ; SR
        MOVE.L  (A6)+,-(A7)     ; A6
        MOVEM.L (A6)+,D0-A5
        MOVE.L  A6,USP
        MOVE.L  (A7)+,A6
        RTE
        
frSup:  ; Entry aus Supervisor mode
        
        ; Daten auf den USP retten
        MOVEM.L D0-A6,-(A7)
        MOVE.L  USP,A6
        MOVE.L  A6,-(A7)
        ST.B    -(A7)
        
        MOVE.L  2+4+60(A7),A0         ; ^Transfer-Daten
        
        ; A0: (s.o.)
        
        MOVE.L  2+4+4+2+4+32+8(A0),A2   ; A2: alter dest^
        MOVE.L  A7,(A2)
        
        MOVE.L  2+4+4+2+4+4(A0),A3  ; D1: Vektoradr.
        LEA     2(A0),A6
        MOVE.L  (A6)+,(A3)      ; alten Vektor restaurieren
        TST     useSF
        BEQ     no20e
        MOVE    #DftSF,-(A7)
no20e:
        MOVE.L  (A6)+,-(A7)     ; PC
        MOVE.W  (A6)+,-(A7)     ; SR
        MOVE.L  (A6)+,-(A7)     ; A6
        MOVEM.L (A6)+,D0-A5
        MOVE.L  A6,USP
        MOVE.L  (A7)+,A6
        RTE
    END
  END hdlExc;

PROCEDURE hdlCall;
  (* FÅr IOTRANSFER-Auslîsungen per JSR *)
  BEGIN
    ASSEMBLER
        ; Der Aufruf kann aus beiden Modi kommen, der zu startende
        ; Prozeû ist immer im Usermode
        
        MOVE.L  D1,-(A7)
        
        MOVEM.L D0/D2/A0-A2,-(A7)
        MOVEQ   #1,D0
        MOVE.L  D0,-(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        TST.W   D0
        BNE     frSup
        
        ; Entry aus User mode
        
        MOVE.W  D0,4(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  A7,USP
        MOVE.L  D0,A7
        MOVEM.L (A7)+,D0/D2/A0-A2
        
        MOVE    SR,D1
        ANDI    #$CFFF,D1
        
        ;BREAK
        MOVE    #$2700,SR       ; keine Interrupts !
        
        ; Aktiven Prozeû beenden, Daten auf den USP retten
        ; auf USP stehen noch: D1.L, ^Dest-Transfer-Daten, PC.L
        MOVE.L  A0,-(A7)
        MOVE.L  USP,A0
        MOVE.L  (A0)+,-(A7)     ; D1 retten
        MOVE.L  (A0)+,-(A7)     ; ^Transfer-Daten
        MOVE.L  (A0)+,-(A7)     ; PC retten
        MOVEM.L D0-A5,-(A0)
        MOVE.L  A6,-(A0)
        MOVE.W  D1,-(A0)        ; SR
        MOVE.L  (A7)+,-(A0)     ; PC
        MOVE.L  (A7)+,14(A0)    ; D1 in Transfer-Daten ablegen
        MOVE.L  (A7)+,A1        ; ^Transfer-Daten
        MOVE.L  (A7)+,42(A0)    ; A0 in Transfer-Daten ablegen
        CLR.W   -(A0)
        
        ; A1 zeigt auf:
        ; 2  Byte - 1, zeigt IOTR an
        ; 4  Byte - alter Exc-Vektor
        ; 4  Byte - PC
        ; 2  Byte - SR
        ; 4  Byte - A6
        ; 56 Byte - D0-A5
        
        MOVE.L  2+4+4+2+4+32+8(A1),A2  ; A2: alter dest^
        MOVE.L  A6,(A2)
        
        MOVE.L  2+4+4+2+4+4(A1),A3  ; D1: Vektoradr.
        LEA     2(A1),A6
        MOVE.L  (A6)+,(A3)      ; alten Vektor restaurieren
        TST     useSF
        BEQ     no20f
        MOVE    #DftSF,-(A7)
no20f:
        MOVE.L  (A6)+,-(A7)     ; PC
        MOVE.W  (A6)+,-(A7)     ; SR
        MOVE.L  (A6)+,-(A7)     ; A6
        MOVEM.L (A6)+,D0-A5
        MOVE.L  A6,USP
        MOVE.L  (A7)+,A6
        RTE
        
frSup:  ; Entry aus Supervisor mode
        
        ADDQ.L  #6,A7
        MOVEM.L (A7)+,D0/D2/A0-A2
        
        MOVE.L  (A7),D1
        ADDQ.L  #2,A7
        MOVE.L  2(A7),(A7)      ; ^Transfer-Daten 2 Byte tiefer
        MOVE    SR,4(A7)        ; SR darÅber
        
        ;BREAK
        MOVE    #$2700,SR       ; keine Interrupts !
        
        ; aktiven Prozeû beenden, Daten auf den USP retten
        MOVEM.L D0-A6,-(A7)
        MOVE.L  USP,A0
        MOVE.L  A0,-(A7)
        ST.B    -(A7)
        
        MOVE.L  2+4+60(A7),A0         ; ^Transfer-Daten
        
        ; A0: (s.o.)
        
        MOVE.L  2+4+4+2+4+32+8(A0),A2   ; A2: alter dest^
        MOVE.L  A7,(A2)
        
        MOVE.L  2+4+4+2+4+4(A0),A3  ; D1: Vektoradr.
        LEA     2(A0),A6
        MOVE.L  (A6)+,(A3)      ; alten Vektor restaurieren
        TST     useSF
        BEQ     no20g
        MOVE    #DftSF,-(A7)
no20g:
        MOVE.L  (A6)+,-(A7)     ; PC
        MOVE.W  (A6)+,-(A7)     ; SR
        MOVE.L  (A6)+,-(A7)     ; A6
        MOVEM.L (A6)+,D0-A5
        MOVE.L  A6,USP
        MOVE.L  (A7)+,A6
        RTE
    END
  END hdlCall;


PROCEDURE @IOTR ( VAR source,dest:ADDRESS; vecAddr:ADDRESS );
  CONST JSRInstr = $4EB9;
  BEGIN
    ASSEMBLER
        ; Aufruf erfolgt immer im Usermode, der zu startende Prozeû
        ; kann in beiden Modi ablaufen
        
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  A7,A0
        MOVE.L  D0,A7
        
        MOVE.L  -(A3),D1        ; vector
        MOVE.L  -(A3),A2        ; dest
        MOVE.L  -(A3),A1        ; source
        MOVE    SR,D2
        ANDI    #$CFFF,D2
        
        MOVE    #$2700,SR       ; keine Interrupts !
        
        ; Daten fÅr 'hdlExc' und 'hdlCall':
        ; 2  Byte - 1, zeigt IOTR an
        ; 4  Byte - alter Exc-Vektor
        ; 4  Byte - PC
        ; 2  Byte - SR
        ; 4  Byte - A6
        ; 56 Byte - D0-A5
        
        ; aktiven Prozeû beenden
        MOVE.L  (A0)+,D0        ; RÅcksprungadr. hinter IOTRANSFER
        MOVEM.L D0-A5,-(A0)
        MOVE.L  A6,-(A0)
        MOVE.W  D2,-(A0)
        MOVE.L  D0,-(A0)
        
        MOVE.L  D1,A3
        MOVE.L  (A3),-(A0)      ; alten vektor retten
        
        MOVE    #1,-(A0)
        
        MOVE.L  (A2),D0         ; zuerst retten, falls A1=A2
        MOVE.L  A0,(A1)
        MOVE.L  D0,A6
        
        CMPA.W  #$400,A3
        BCS     isExc
        MOVE.L  #hdlCall,-(A0)
        BRA     cont0
isExc   MOVE.L  #hdlExc,-(A0)
cont0   MOVE    #JSRInstr,-(A0)
        
        MOVE.L  A0,(A3)         ; neuen vektor auf 'JSR hdlExc/hdlCall'
        
        ; neuen Prozeû starten
        TST.W   (A6)+
        BEQ     stUsr
        BMI     stSup
        
        ; starte Usermode, vorher Vektor restaurieren
        MOVE.L  (A6)+,D0        ; alter Vektor
        MOVE.L  4+2+4+4(A6),A0  ; D1: Vektoradr.
        MOVE.L  D0,(A0)
        TST     useSF
        BEQ     no20h
        MOVE    #DftSF,-(A7)
no20h:
        MOVE.L  (A6)+,-(A7)     ; PC
        MOVE.W  (A6)+,-(A7)     ; SR
        MOVE.L  (A6)+,-(A7)     ; A6
        MOVEM.L (A6)+,D0-A5
        MOVE.L  A6,USP
        MOVE.L  (A7)+,A6
        RTE
        
stUsr:  ; starte Usermode
        TST     useSF
        BEQ     no20i
        MOVE    #DftSF,-(A7)
no20i:
        MOVE.L  (A6)+,-(A7)     ; PC
        MOVE.W  (A6)+,-(A7)     ; SR
        MOVE.L  (A6)+,-(A7)     ; A6
        MOVEM.L (A6)+,D0-A5
        MOVE.L  A6,USP
        MOVE.L  (A7)+,A6
        RTE
        
stSup:  ; starte Supervisormode
        MOVE.L  A6,A7
        MOVE.L  (A7)+,A0
        MOVE.L  A0,USP
        MOVEM.L (A7)+,D0-A6
        ADDQ.L  #4,A7
        TST     useSF
        BEQ     no20j
        MOVE.W  (A7),-(A7)
        MOVE.L  4(A7),2(A7)
        MOVE    #DftSF,6(A7)
no20j:
        RTE
    END
  END @IOTR;


PROCEDURE @IOCA ( vecAddr:ADDRESS );
  BEGIN
    ASSEMBLER
        CMPI.L  #$400,-(A3)
        BCS     isExc
        MOVEM.L D3-D7/A3-A6,-(A7)
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  A7,USP
        MOVE.L  D0,A7
        MOVE.L  (A3),A1
        MOVE.L  (A1),A1
        JSR     (A1)
        ANDI    #$CFFF,SR
        MOVEM.L (A7)+,D3-D7/A3-A6
        RTS
      isExc:
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.L  (A7)+,A2
        MOVE    SR,D1
        ANDI    #$CFFF,D1
        MOVE.L  A7,USP
        MOVE.L  D0,A7
        MOVE.L  (A3),A1
        MOVE.L  (A1),A1
        TST     useSF
        BEQ     no20k
        MOVE    #DftSF,-(A7)
no20k:
        MOVE.L  A2,-(A7)
        MOVE    D1,-(A7)
        JMP     (A1)            ; rettet sicher alle Register
    END
  END @IOCA;


PROCEDURE @PRIO;  (* Set Interrupt Priority *)
  BEGIN
    (* IR-level in D1, auf Bitpos. wie SR; D0, D2 nicht verÑndern ! *);
    ASSEMBLER
        MOVE.L  D2,-(A7)
        MOVE.L  D0,-(A7)
        MOVE.W  D1,-(A7)
        CLR.L   -(A7)
        MOVE    #$20,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
        MOVE.W  (A7)+,D1
        MOVE.L  A7,USP
        MOVE.L  D0,A7
        MOVE    SR,D0
        ANDI    #$F0FF,D0
        ANDI    #$0F00,D1
        OR      D1,D0
        MOVE    D0,SR
        MOVE.L  (A7)+,D0
        MOVE.L  (A7)+,D2
    END
  END @PRIO;

(*$L+*)


MODULE IR [5];

  (*
   * Lokales Modul, das sich in VBL-Vektor installiert.
   * Dadurch wird die Routine 'serveProc' regelmÑûig vom GEMDOS
   * aufgerufen und setzt nach jeweils einer bestimmten Anzahl
   * von Aufrufen eine Variable ('Key') auf TRUE.
   *)

  IMPORT TRANSFER, IOTRANSFER, NEWPROCESS, ADDRESS, ADR, LISTEN;

  FROM PrgCtrl IMPORT CatchProcessTerm, TermCarrier;

  FROM MOSGlobals IMPORT MemArea;

  EXPORT Key;

  VAR main, server: ADDRESS;
      stack: ARRAY [1..800] OF CARDINAL;
      terminate, Key: BOOLEAN;

  PROCEDURE serveProc;
    VAR i: CARDINAL;
    BEGIN
      i:= 0;
      LOOP
        IOTRANSFER (server, main, $4DEL);  (* VBL-Queue *)
        IF terminate THEN
          TRANSFER (server, main);
        END;
        INC (i);
        IF i > 50 THEN
          Key:= TRUE;
          i:= 0
        END
      END
    END serveProc;
  
  PROCEDURE terminateIR;
    BEGIN
      terminate:= TRUE;
      TRANSFER (main, server)
    END terminateIR;

  VAR carrier: TermCarrier;
      wsp: MemArea;

  BEGIN
    Key:= FALSE;
    terminate:= FALSE;

    (*
     * Prozeû einrichten und starten
     *)
    NEWPROCESS (serveProc, ADR (stack), SIZE (stack), server);
    TRANSFER (main, server);

    (*
     * Die Prozedur 'terminateIR' soll dafÅr sorgen, daû bei
     * Programmende der IOTRANSFER-Zyklus beendet wird.
     *)
    wsp.bottom:= NIL;
    CatchProcessTerm (carrier, terminateIR, wsp);
  END IR;


CONST StackSize = 2000L;

VAR a1, a2: ADDRESS;
    Main, Ha, Tschi: ADDRESS;
    Count: CARDINAL;
    
PROCEDURE schreibeHa;
  VAR l:LONGCARD;
  BEGIN
    LOOP
      IF RandomCard (1,5) # 5 THEN
        WriteString (" Ha ");
        FOR l:= 1L TO 3000L DO END
      ELSE
        IF Key THEN
          Key:= FALSE;
          WriteString (" <Key> ")
        END;
        TRANSFER (Ha, Tschi); (* direkter Transfer auf 'Tschi' *)
        ASSEMBLER
          TRAP #0             (* indirekter Transfer Åber TRAP #0 -> 'Tschi' *)
        END;
        WriteLn;
      END;
      IF Count >= 50 THEN
        TRANSFER (Ha, Main);  (* Ende *)
      END
    END
  END schreibeHa;

PROCEDURE schreibeTschi;
  (*
   * Durch das folgende Verlassen dieser Coroutine Åber 'IOTRANSFER'
   * statt 'TRANSFER' kann sie sowohl durch einen TRANSFER auf sie
   * zurÅck als auch Åber IO-Kanal (in diesem Fall 'TRAP #0') wieder
   * aktiviert werden.
   *)
  BEGIN
    LOOP
      WriteString (" Tschi ");
      INC (Count);
      IOTRANSFER (Tschi, Ha, $80L);  (* Installation auf TRAP #0 *)
    END;
  END schreibeTschi;

BEGIN
  useSF:= UseStackFrame ();
  ALLOCATE (a1, StackSize);
  ALLOCATE (a2, StackSize);
  NEWPROCESS (schreibeHa, a1, StackSize, Ha);
  NEWPROCESS (schreibeTschi, a2, StackSize, Tschi);
  Count:= 0;
  (*
   * Nun niesen wir ein paarmal...
   *)
  TRANSFER (Main, Ha);
  (*
   * Danach warten wir auf einen Tastendruck, wÑhrenddessen weiterhin
   * im VBL-Interrupt 'Key' zyklisch gesetzt wird.
   *)
  WHILE NOT KeyPressed () DO
    IF Key THEN
      Key:= FALSE;
      WriteString (" <Key> ")
    END
  END;
  DEALLOCATE (a1, StackSize);
  DEALLOCATE (a2, StackSize);
END Coroutin.
