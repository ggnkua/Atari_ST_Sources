DEFINITION MODULE MOSCtrl;

(*
 * Internes Modul!
 *)

FROM SYSTEM IMPORT ADDRESS, BYTE, WORD, LONGWORD;

FROM MOSGlobals IMPORT MemArea;


VAR ProcessID: POINTER TO ADDRESS;
     (*
      * Zeigt auf die TOS-Variable, die den aktuellen Prozeû bezeichnet.
      *)

    ModLevel: CARDINAL;
     (*
      * Globales Modullevel.
      * Ist Eins fÅr unterstes Level;
      * Null, wenn eigener Prozeû nicht mehr aktiv (z.B. bei residenten Prg.).
      *)

    BaseResident: BOOLEAN;
     (*
      * TRUE, wenn Basismodule resident sind.
      * Bleibt auch erhalten, wenn Basisprozeû beendet wird und Prg
      * resident bleibt.
      *)

    BaseIsAccessory: BOOLEAN;
     (*
      * Zeigt an, ob BaseProcess ein ACC ist
      *)

    ExitCode: INTEGER;
     (*
      * Erst gÅltig, wenn processState = 3 (term)
      *)

    RealMode: CARDINAL;
     (*
      * Vom Linker Åbergeben: 0 = keine Reals, 1 = Soft, 2 = ST-FPU, 3 = TT-FPU
      *)

    UsedFPU: CARDINAL;
     (*
      * 0: none, 1: external, 2: internal
      *)

    PrgFlags: LONGWORD;
     (*
      * Z.Zt. unbenutzt.
      *)

TYPE TermList  = POINTER TO TermEntry;
     TermEntry = RECORD
                   call: PROC;
                   wsp : MemArea;
                   next: TermList
                 END;

     EnvList  = POINTER TO EnvEntry;
     EnvEntry = RECORD
                  call: PROC; (* PROCEDURE(start,child):BOOLEAN) *)
                  wsp: MemArea;
                  level: INTEGER;
                  prev, next: EnvList
                END;

     RemovalList  = POINTER TO RemovalEntry;
     RemovalEntry = RECORD
                      next: RemovalList;
                      prev: RemovalList;
                      call: PROC;
                      wsp: MemArea;
                      reserved: ARRAY [10..15] OF WORD
                    END;

VAR EnvRoot: EnvEntry;
    RemovalRoot: RemovalEntry;


TYPE PtrPDB = POINTER TO PDB;

     PDB = RECORD
             layout       : CARDINAL;
             basePageAddr : ADDRESS;
             modLst       : POINTER TO ARRAY [1..65535] OF RECORD
                              head0: ADDRESS;
                              var0: ADDRESS;
                              varlen0: LONGCARD;
                              flags: BITSET;
                            END;
             modNo        : CARDINAL;
             processState : CARDINAL; (* 0:created, 1:init, 2:run, 3:term *)
                                      (* 4:finished, 5:remove from memory *)
             bottomOfStack: LONGWORD;
             topOfStack   : LONGWORD;
             termState    : CARDINAL;
             resident     : BOOLEAN;
             flags        : WORD; (* vom Linker: 0,1: RealFormat; 2: 68020-Code *)
             termProcs    : TermList;
             prev         : PtrPDB;
             initialSSP   : LONGWORD;
             prevTermHdlr : LONGWORD;
             reserved     : ARRAY [2..3] OF LONGWORD;
           END;

PROCEDURE GetPDB ( VAR pdb: PtrPDB; VAR process: ADDRESS );
  (*
   * Liefert NIL in pdb, wenn gerade kein MOS-Prozeû aktiv und ModLevel > 0.
   * Wenn ein Prg also resident ist, bekommt es, wenn ModLevel = 0, zumindest
   * seinen PDB, dessen Daten teilweise noch gÅltig sind (Stack-Ptr, resident,
   * modLst, usw). Wenn Prg ein ACC ist und ModLevel=1, wird PDB geliefert.
   * 'process' enthÑlt immer akt. laufenden TOS-Prozeû (akt.Basepage)
   *)

PROCEDURE PushPDB ( pdb: PtrPDB; process: ADDRESS );
  (*
   * Es muû die Adresse eines bereits angelegten
   * und initialisierten PDB Åbergeben werden.
   *)

PROCEDURE PopPDB;

PROCEDURE SetProcessState ( state: CARDINAL );
  (*
   * Muû unbedingt immer aufgerufen werden, weil hierin nicht nur
   * der Prozeû-Status gesetzt, sondern auch abhÑngig davon andere
   * Operationen durchgefÅhrt werden! Also keinesfalls PDB.processState
   * direkt setzen!
   *)

PROCEDURE CallSub ( subRoutine: PROC; VAR wsp: MemArea );

PROCEDURE CallRemoveProcs;
  (*
   * Entfernt u.A. den Termination-Handler
   *)

PROCEDURE Pterm (exitCode: INTEGER);
  (*
   * Ersatz fÅr GEMDOS-Pterm(). FÅhrt Abmeldefunktionen vorher aus.
   *)

(*
 * Folg. zwei Vars bezeichnen letzten aktiven MOS-Prozeû
 *)

VAR ActPDB : PtrPDB;            (* Bleibt nach unterstem Prozeûende erhalten *)
    ActMOSProcess: ADDRESS;     (* Ist NIL unter unterstem Prozeûlevel *)

    BaseProcess: ADDRESS;       (* Bei ACCs hier Base Page des ACC *)

END MOSCtrl.
