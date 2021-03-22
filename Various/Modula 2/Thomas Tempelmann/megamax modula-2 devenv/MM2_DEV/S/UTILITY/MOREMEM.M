MODULE MoreMem;

(*-----------------------------------------------------------------------------
 * Erstellt im M„rz 1988 von Thomas Tempelmann, Nordendstr.64, D-8000 Mnchen
 *
 * Erstellt unter dem Megamax-Modula-2 System, Version 1.1
 *-----------------------------------------------------------------------------
 * Kurzbeschreibung : Vergr”žert die m”gliche Anzahl von allozierbaren
 *                    Speicherbl”cken.
 *                    Dieses Programm funktioniert nur mit den TOS-Versionen
 *                    1.0 und 1.2. Bei TOS-Versionen ab 1.4 ist stattdessen
 *                    das Programm 'FOLDRxxx.PRG' zuverwenden (das wiederum
 *                    aber nicht bei den TOS-Versionen 1.0 / 1.2 den oben
 *                    beschriebenen Zweck erfllt).
 *                    Fr die Anwendung ist dieses Modul mit vollst. Optimierung
 *                    und ohne irgendwelche Treibermodule (auch nicht M2Init!)
 *                    zu linken und dann in den AUTO-Ordner zu kopieren.
 *-----------------------------------------------------------------------------
 * 15.5.88: Erstellung aus dem Megamax Storage-Modul.
 * 19.6.88: Der Puffer wird mit GEMDOS-Malloc geholt.
 * 12.8.88: Ausgabe einer Installationsmeldung.
 * 21.9.89: Anpassung an MOS-Version 2.0
 *----------------------------------------------------------------------------*)

(*$C- No Case Sensitivity *)
(*$M- No Symbols (Procedure Names) *)
(*$R- Range Check off *)
(*$L- No Parameter Link *)
(*$N+ No Runtime Module needed *)
(*$S- No Stack Check *)

FROM SYSTEM IMPORT
  ASSEMBLER, BYTE, ADDRESS, LONGWORD, ADR, WORD;


CONST
  Elements = 300; (* Bestimmt die Anzahl neuer belegbarer Speicherbl”cke. *)
                  (* Fr jeden dieser Bl”cke werden 18 Bytes belegt.      *)
                  (* Achtung: Bei Žnderung die Ausgabetexte am Ende des   *)
                  (*          Programms bercksichtigen !                 *)

  mdSize0 = 16;
  mdSize2 = mdSize0 + 2;   (* Plus vorstehendes L„ngen-word (=1) *)
  elemSize = Elements * mdSize2;


CONST (* GEMDOS functions *)
      PtermRes  = $31;
      Mshrink   = $4A;
      PrintLine = $09;

TABLE procStart: 0;

PROCEDURE newMDSt;
  
  PROCEDURE initMDSt;
    BEGIN
      ASSEMBLER
        MOVE.L  #elemSize,D5
        
        MOVE.L  8(A7),A5
        ADDQ.L  #2,A5
        MOVEQ   #mdSize2,D2
        
        ; Ende der MD-Freiliste suchen
l0      TST.L   (A6)
        BEQ     st0
        MOVE.L  (A6),A6
        BRA     l0
        
nxt     MOVE    #1,-2(A5)       ; MD.mylen
        MOVE.L  A5,(A6)         ; Adr. des MD dem Vorg„nger in MD.next zuweisen
        MOVE.L  A5,A6
        ADDA.W  D2,A5
st0     SUB.L   D2,D5
        BCC     nxt
        
        ; letztes Element mit NIL markieren
        CLR.L   (A6)            ; MD.next
      END;
    END initMDSt;


  BEGIN
    ASSEMBLER
        ; Size v. elems*16 als amount
        MOVE.L  #elemSize,-(A7)
        MOVE.W  #$48,-(A7)      ; Malloc
        TRAP    #1
        MOVE.L  D0,(A7)
        BEQ     noMem
        PEA     initMDSt(PC)
        MOVE    #38,-(A7)
        TRAP    #14             ; Supexec (initMDSt)
noMem   CLR.W   (A7)
        MOVE.L  #2,-(A7)
        MOVE.W  #PtermRes,-(A7) ; terminate process
        TRAP    #1
    END;
  END newMDSt;

TABLE procEnd: 0;

BEGIN
  ASSEMBLER
        MOVE.L  A0,A4             ; starting address of workspace
        
        PEA     t(PC)
        MOVE    #38,-(A7)
        TRAP    #14             ; Supexec
        BRA     c
     t: MOVE.L  $4F2,A0
        MOVE.L  8(A0),D0
        RTS
     c: MOVE.L  D0,A0
        CMPI.W  #$0100,2(A0)
        BNE     b
        MOVE.L  #$56FE,D0
        BRA     e
     b: CMPI.W  #$0102,2(A0)
        BNE     f
        MOVE.L  $20(A0),D0
        ADDQ.L  #4,D0
     e: MOVE.L  D0,A6

        MOVE.L  #$80,-(A7)        ; base page must not be reallocated
        MOVE.L  A4,-(A7)
        CLR     -(A7)
        MOVE    #Mshrink,-(A7)    ; return memory of environment
        TRAP    #1

        ; print message
        PEA     msg_1(PC)
        MOVE.W  #PrintLine,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7

        ; move 'newMDSt' to top of memory
        
        LEA     procStart,A0
        LEA     procEnd,A1
        LEA     newMDSt,A4
        SUBA.L  A0,A4
        MOVE.L  A0,D0
        SUB.L   A1,D0
        LEA     0(A7,D0.L),A2
        SUBA.W  #128,A2
        ADDA.L  A2,A4
        ; move A0..A1 -> A2
movelp: MOVE    (A0)+,(A2)+
        CMPA.L  A1,A0
        BCS     movelp
        ; call 'newMDSt'
        JMP     (A4)

f:      ; print error msg
        PEA     msg_v(PC)
        MOVE.W  #PrintLine,-(A7)
        TRAP    #1
        ; Terminate program
        CLR     (A7)
        TRAP    #1

msg_1   DC.B    13,10
        ASC     'MOREMEM.PRG erweitert GEMDOS-Puffer um 300 Speicher-Bl”cke.'
        DC.B    13,10
        ASC     'Dazu werden 5400 Bytes belegt.'
        DC.B    13,10,0

msg_v   DC.B    13,10
        ASC     'MOREMEM.PRG mit dieser TOS-Version nicht lauff„hig !'
        DC.B    13,10
        ASC     'Stattdessen FOLDRxxx.PRG verwenden !'
        DC.B    13,10,0
        SYNC
  END
END MoreMem.
