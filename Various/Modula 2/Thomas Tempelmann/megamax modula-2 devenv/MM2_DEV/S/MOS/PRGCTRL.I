IMPLEMENTATION MODULE PrgCtrl; (* V#053 *)
(*$Y+,C-,L-,R-,N+*)

(*
  23.10.88: GetBasePageAddr holt sich BP-Ptr aus ProcessID des TOS und
              nicht mehr Åber GetPDB.
  15.01.89: Accessory nach 23.10.88 wieder korrekt.
  23.01.89: Accessory kommt auch mit residenten Prgs klar.
  17.01.94: TermProcess ruft nun Pterm aus MOSCtrl auf.
*)

FROM SYSTEM IMPORT ASSEMBLER, ADR, WORD, ADDRESS, TSIZE, LONGWORD;

FROM MOSGlobals IMPORT MemArea;

IMPORT MOSCtrl;
FROM MOSCtrl IMPORT ProcessID, GetPDB, TermEntry, EnvEntry, ModLevel, PDB,
        ExitCode, ActMOSProcess, EnvRoot, Pterm;

(* ! Storage darf nicht importiert werden ! *)

VAR dummy: ADDRESS;

PROCEDURE TermProcess ( ec: Integer );
  BEGIN
    ASSEMBLER
        JMP     Pterm
    END
  END TermProcess;


PROCEDURE CatchProcessTerm ( VAR hdl: TermCarrier; call: Proc; wsp: MemArea );
  BEGIN
    ASSEMBLER
        CLR.L   -(A7)
        MOVE.L  A7,(A3)+
        MOVE.L  #dummy,(A3)+
        JSR     GetPDB
        MOVE.L  (A7)+,A0
        MOVE.L  A0,D0
        BEQ     noMod
        MOVE.L  -(A3),D2
        MOVE.L  -(A3),A2
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),A1
        MOVE.L  PDB.TermProcs(A0),D1    ; oldHdl:= pdb.TermProcs
        MOVE.L  A1,PDB.TermProcs(A0)    ; pdb.TermProcs:= ADR (hdl)
        MOVE.L  D1,TermEntry.next(A1)   ; hdl.next:= oldHdl
        MOVE.L  D0,TermEntry.call(A1)   ; hdl.call:= call
        MOVE.L  D2,TermEntry.wsp.length(A1)
        MOVE.L  A2,TermEntry.wsp.bottom(A1)
        RTS
      noMod:
        TRAP    #6
        DC.W    -14     ; Ill. call
        SUBA.W  #$10,A3
    END
  END CatchProcessTerm;


PROCEDURE SetEnvelope ( VAR hdl: EnvlpCarrier; call: EnvlpProc; wsp: MemArea );
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D2
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),A1        ; hdl
        
        ; hdl.next:=ADR(EnvRoot)
        ; hdl.prev:=EnvRoot.prev
        ; EnvRoot.prev^.next:= ADR (hdl)
        ; EnvRoot.prev:= ADR (hdl)
        LEA     EnvRoot,A2
        MOVE.L  A2,EnvEntry.next(A1)
        MOVE.L  EnvEntry.prev(A2),A0
        MOVE.L  A0,EnvEntry.prev(A1)
        MOVE.L  A1,EnvEntry.next(A0)
        MOVE.L  A1,EnvEntry.prev(A2)
        
        CLR.W   EnvEntry.level(A1)
        MOVE.L  D1,EnvEntry.call(A1)
        MOVE.L  D0,EnvEntry.wsp.bottom(A1)
        MOVE.L  D2,EnvEntry.wsp.length(A1)
    END
  END SetEnvelope;

PROCEDURE SysSetEnvelope (VAR hdl: EnvlpCarrier; call: EnvlpProc; wsp: MemArea);
  BEGIN
    ASSEMBLER
        MOVE.L  -16(A3),-(A7)
        JSR     SetEnvelope
        MOVE.L  (A7)+,A0
        SUBQ.W  #1,EnvEntry.level(A0)   ; level:= -1
    END;
  END SysSetEnvelope;

PROCEDURE RemoveEnvelope ( VAR hdl: EnvlpCarrier );
  BEGIN
    ASSEMBLER
        ; next^.prev:= prev;
        ; prev^.next:= next
        MOVE.L  -(A3),A0
        MOVE.L  EnvEntry.next(A0),A1
        MOVE.L  EnvEntry.prev(A0),A2
        MOVE.L  A2,EnvEntry.prev(A1)
        MOVE.L  A1,EnvEntry.next(A2)
    END
  END RemoveEnvelope;

PROCEDURE GetBasePageAddr ( VAR bpp: ADDRESS );
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A1
        MOVE.L  ActMOSProcess,(A1)
    END
  END GetBasePageAddr;

PROCEDURE ActiveProcess (): ADDRESS;
  BEGIN
    ASSEMBLER
        MOVE.L  ProcessID,A0
        MOVE.L  (A0),(A3)+
    END
  END ActiveProcess;

PROCEDURE BaseProcess (): ADDRESS;
  BEGIN
    ASSEMBLER
        MOVE.L  MOSCtrl.BaseProcess,(A3)+
    END
  END BaseProcess;

PROCEDURE ProcessLinked (): BOOLEAN;
  BEGIN
    ASSEMBLER
        CMPI    #1,ModLevel
        SLS     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END ProcessLinked;
  

PROCEDURE Accessory (): BOOLEAN;
  BEGIN
    ASSEMBLER
        ; nicht BaseProcess prÅfen, damit ein unter dem Acc gestartetes
        ; Modul auch FALSE erhÑlt
        MOVE.L  ActMOSProcess,A0
        MOVE.L  A0,D0
        BEQ     nope
        TST.L   $24(A0)         ; parent's basepage
      nope
        SEQ     D0
        ANDI    #1,D0
        MOVE    D0,(A3)+
    END
  END Accessory;

PROCEDURE ProcessState (): PState;
  BEGIN
    ASSEMBLER
        SUBQ.L  #4,A7
        MOVE.L  A7,(A3)+
        MOVE.L  #dummy,(A3)+
        JSR     GetPDB
        MOVE.L  (A7)+,A0
        MOVE.W  PDB.processState(A0),(A3)+
    END
  END ProcessState;

PROCEDURE CurrentExitCode (): INTEGER;
  BEGIN
    ASSEMBLER
        MOVE    ExitCode,(A3)+
    END
  END CurrentExitCode;
  
PROCEDURE SetNewExitCode ( i: INTEGER );
  BEGIN
    ASSEMBLER
        MOVE    -(A3),ExitCode
    END
  END SetNewExitCode;

END PrgCtrl.
