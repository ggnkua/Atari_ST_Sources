MODULE M2Init;

(*
 * Stand: 11.09.95
 *
 * Initialisierungs-Routine fr MM2-Programme.
 * Sie ist fr normale Programme und Accessories geeignet.
 *
 * Dieses Modul muž in der Regel als erstes Treibermodul beim Linken
 * von MM2-Programmen eingebunden werden. Es wird dann beim Start des
 * Programms angesprungen und erh„lt in folgenden Registern definierte Werte:
 *  A0: Bei ACCs die Adresse der Base Page, sonst Null.
 *  A1: Zeiger auf eine Liste von Adressen aller Modulk”rper.
 *  A2: Zeiger auf den im Prg-code abgelegten PDB (Daten d. residenten Module)
 *
 * Der Stack-Pointer ist bei ACCs noch nicht definiert, zuerst muž ein
 * Speicherbereich alloziert werden, in den dann der Stack gelegt wird.
 *
 * Bei normalen Programmen ist A7 bereits definiert, bei 4(A7) befindet
 * sich der Zeiger auf die Base Page. Das Programm wird immer in den
 * gr”žten freien Speicherbereich geladen, der dann schon alloziert ist.
 * Mit dem 'Mshrink'-Aufruf wird der Bereich soweit verkleinert, daž nur
 * noch der ben”tigte Platz fr den Programmcode, Base Page, glob. Variable
 * und den Stack verbleiben. Der Stack-Pointer, der zuerst auf das Ende des
 * Bereichs zeigt, wird dann ans Ende des neuen, verkleinerten Bereichs
 * gesetzt.
 *
 * Auf die untere Grenze des Stack-Bereichs wird immer das A3-Register
 * gesetzt.
 *
 * Einige Daten im PDB werden fr das Laufzeitsystem (z.B. MOSCtrl, PrgCtrl)
 * und die Modulverwaltung (Loader/ModCtrl/ModBase) initialisiert.
 *
 * Dann werden die Module intialisiert, die von M2Init importiert werden.
 * Dazu werden alle Adressen angesprungen, die in der Liste der Modulk”rper
 * (A1 zeigt darauf) stehen. Das Ende der Liste ist mit einer Null gekenn-
 * zeichnet. Der Aufruf "PushPDB" schliežt die Initialisierung des Laufzeit-
 * systems ab.
 *
 * Nun k”nnen die restlichen Modulk”rper ausgefhrt werden. Deren Adressen
 * folgen in der schon erw„hnten Liste. Dabei werden zuerst die weiteren
 * Treibermodule mitsamt ihrer Importe und ganz zuletzt das Hauptmodul
 * gestartet. Wenn es zurckkehrt, ist die Modulk”rperliste zuende und
 * das Programm terminiert.
 *
 * ----------------------------------------------------------------------------
 * 18.12.90  Fertigstellung fr System 2.2
 * 14.02.91  Der PDB wird nun im BSS- statt im TEXT-Segment angelegt.
 * 17.01.94  Die Pterm-Routine von GEMDOS wird nicht mehr direkt angesprungen.
 * 11.09.95  CZ/UK: Ursache fr memory violation von Accessories unter MTOS
             beseitigt
 *)

(*$ M-  Keine Symbole ablegen *)
(*$ N+  Runtime-Modul nicht automatisch importieren *)
(*$ L-  Fr Assembler: Keine Codeerzeugung vom Compiler am Prozedurbeginn *)

FROM SYSTEM IMPORT ASSEMBLER, BYTE, TSIZE;

FROM MOSCtrl IMPORT PDB, PushPDB, SetProcessState, ProcessID, Pterm;

(* Storage/StorBase darf nicht importiert werden! *)

CONST (* default size of stack for process *)
      stackSize = 8192;

      (* base page constants *)
      codestart = 8;
      codelen   = 12;
      datastart = 16;
      datalen   = 20;
      bssstart  = 24;
      bsslen    = 28;
      parent    = 36;
      
      (* GEMDOS functions *)
      Malloc  = $48;
      Mshrink = $4A;


VAR basePDB: PDB;

BEGIN
  ASSEMBLER
        MOVE.L  A1,A6             ; A6: address of main module entries

        ; first copy preset PDB (A2) to 'basePDB' (A4)
        LEA     basePDB,A4
        MOVEQ   #TSIZE(PDB) DIV 2 - 1,D0
copyPDB MOVE.W  (A2)+,(A4)+
        DBRA    D0,copyPDB
        LEA     basePDB,A4        ; A4 now points to PDB

        MOVE.L  A0,D0             ; base page for accessory in A0?
        BNE     initAcc           ; yes

        ; initialization for normal programs
        MOVE.L  4(A7),A5
        MOVE.L  codelen(A5),D0
        ADD.L   datalen(A5),D0
        ADD.L   bsslen(A5),D0
        ADDI.L  #256,D0           ; D0: total length of static program space
        MOVE.L  D0,D2
        ADD.L   A5,D2             ; D2: end of program space
        ADDQ.L  #1,D2
        BCLR    #0,D2             ; sync D2
        MOVE.L  D2,A3             ; end of prg.space is bottom of stack
        MOVE.L  PDB.topOfStack(A4),D3
        BEQ     useDefault
        ADD.L   D3,D0
        BRA     gotStack
useDefault:
        ADDI.L  #stackSize,D0
gotStack:
        MOVE.L  D0,D1             ; D0: size of prg.space + stack
        ADD.L   A5,D1             ; D1: top of stack
        ADDQ.L  #1,D1
        BCLR    #0,D1             ; sync D1
        CMP.L   A7,D1             ; enough stack ?
        BHI     oldStack
        MOVE.L  D1,A7             ; set new top of stack
oldStack:
        MOVE.L  D0,-(A7)          ; new workspace of process
        MOVE.L  A5,-(A7)          ; starting address of workspace
        CLR.W   -(A7)
        MOVE    #Mshrink,-(A7)    ; return unused memory
        TRAP    #1
        ADDA.W  #12,A7
        BRA     contNorm

initAcc ; initialization for accessories
        MOVE.L  A0,A5             ; address of base page
        LEA     256(A5),A7        ; use top of basepage's cmdline as stack
        MOVE.L  PDB.topOfStack(A4),D0
        BNE     takeIt
        MOVE.L  #stackSize,D0
takeIt: MOVE.L  D0,-(A7)
        MOVE    #Malloc,-(A7)
        TRAP    #1
        ADDQ.L  #2,A7
        MOVE.L  (A7)+,D1          ; size of stack
        TST.L   D0                ; bottom address of stack
        BLE.W   error             ; not enough memory
        MOVE.L  D0,A3             ; bottom of stack -> A3
        ADD.L   D1,D0
        MOVE.L  D0,A7             ; top of stack -> A7

contNorm:
        MOVE.L  A5,PDB.basePageAddr(A4)   ; store ^base page
        SUBA.W  #32,A7                    ; cz/uk: safety distance for MiNT
        MOVE.L  A7,A1                     ; get stack pointer
        SUBA.W  #12,A1                    ; point to process return address,
        MOVE.L  A1,PDB.topOfStack(A4)     ; process needs it to return on error
        MOVE.L  A3,PDB.bottomOfStack(A4)  ; lowest address of stack
        
        ; init modules imported by this module
loop1   MOVE.L  (A6)+,A0
        MOVE.L  A0,D0                     ; end of list ?
        BEQ     end1
        MOVEM.L A4/A6,-(A7)
        JSR     (A0)                      ; call bodies
        MOVEM.L (A7)+,A4/A6
        BRA     loop1

end1:   MOVE.L  A4,(A3)+
        MOVE.L  ProcessID,A0
        MOVE.L  (A0),(A3)+
        JSR     PushPDB                   ; determine local process-id
        
        MOVE    #1,(A3)+
        JSR     SetProcessState           ; init-phase
loop2:  MOVE.L  (A6)+,A0
        MOVE.L  A0,D0                     ; end of list ?
        BEQ     end2
        TST.L   (A6)                      ; last module ?
        BNE     notLast
        MOVE.L  A0,-(A7)
        MOVE    #2,(A3)+
        JSR     SetProcessState           ; run-phase
        MOVE.L  (A7)+,A0
notLast MOVEM.L A4/A6,-(A7)
        JSR     (A0)                      ; call main modules
        MOVEM.L (A7)+,A4/A6
        BRA     loop2

error:  MOVE    #-39,(A3)+
        BRA     exit
end2:   CLR     (A3)+
exit:   JMP     Pterm                     ; terminate process
  END
END M2Init.
