(****************************************************************)
(*                                                              *)
(*   LaPeer Systems, Inc. has developed this software for the   *)
(*   benefit of the Public Domain.  For our benefit, please     *)
(*   credit LSI whenever it is used.                            *)
(*                                                              *)
(*   Jerry K. LaPeer                                            *)
(*                                                              *)
(*   Compu-Serve 76657,754                                      *)
(*   GEnie       J.K.LAPEER                                     *)
(*                                                              *)
(****************************************************************)

MODULE Buffers;
(*$A- *) (*$F- *) (*$T- *) (*$S- *)

FROM SYSTEM                     IMPORT ADDRESS, ADR, TSIZE, NULL, CODE;
FROM GEMX                       IMPORT BasePageAddress, BasePageType;
FROM XBIOS                      IMPORT SuperExec;
FROM GEMDOS                     IMPORT Alloc, TermRes;

IMPORT GEMDOS, SYSCIO;

CONST NumbOfFatBuffers          = 16;
      NumbOfDirBuffers          = 16;

TYPE BCBPtr                     = POINTER TO BCBDef;
     BCBDef                     = RECORD
       blink                    : BCBPtr;       (* next BCB             *)
       bbufdrv                  : INTEGER;      (* drive#, or -1        *)
       bbuftyp                  : INTEGER;      (* buffer type          *)
       bbufrec                  : INTEGER;      (* record# cached here  *)
       bdirty                   : INTEGER;      (* dirty flag           *)
       bdm                      : ADDRESS;      (* Ptr to Drive Media   *)
       bbufr                    : ADDRESS;      (* Ptr to buffer itself *)
     END;
     DiskBuffDef                = ARRAY[0..511] OF CHAR;

VAR  BCBfatBuf         : POINTER TO ARRAY[1..NumbOfFatBuffers] OF BCBDef;
     DiskFatBuff       : POINTER TO ARRAY[1..NumbOfFatBuffers] OF DiskBuffDef;
     BCBDirBuf         : POINTER TO ARRAY[1..NumbOfDirBuffers] OF BCBDef;
     DiskDirBuff       : POINTER TO ARRAY[1..NumbOfDirBuffers] OF DiskBuffDef;

VAR SysFatBCB [000004b2H]       : BCBPtr;
    SysDirBCB[000004b6H]        : BCBPtr;
    TempBCB                     : BCBPtr;

(*
   The following compiler directive stops the compiler from generating the
   normal Modula-2 entry/exit code for the next procedure. This is needed as
   this routine is called in supervisor mode
*)

(*$P- Stop entry/exit code for next procedure *)

PROCEDURE InstallFatBuffers;

CONST RTS                       = 04E75H;(* ML return from subroutine opcode *)

BEGIN (* InstallFatBuffers *)

  IF LONGCARD(SysFatBCB) = 0
     THEN HALT;
  END;

  TempBCB := SysFatBCB;

  WHILE LONGCARD(TempBCB^.blink) # 0 DO
        TempBCB := TempBCB^.blink;
  END;

  TempBCB^.blink := ADDRESS(BCBfatBuf);

  CODE(RTS);                   (* code to return to calling BIOS function *)

END InstallFatBuffers;

(*$P+ Resume previous entry/exit code *)

(*$P- Stop entry/exit code for next procedure *)

PROCEDURE InstallDirBuffers;

CONST RTS                 = 04E75H;(* ML return from subroutine opcode *)

BEGIN (* InstallDirBuffers *)

  IF LONGCARD(SysDirBCB) = 0
     THEN HALT;
  END;

  TempBCB := SysDirBCB;

  WHILE LONGCARD(TempBCB^.blink) # 0 DO
        TempBCB := TempBCB^.blink;
  END;

  TempBCB^.blink := ADDRESS(BCBDirBuf);

  CODE(RTS);                   (* code to return to calling BIOS function *)

END InstallDirBuffers;

(*$P+ Resume previous entry/exit code *)

PROCEDURE Initialise () : BOOLEAN;

VAR c                           : CARDINAL;

BEGIN

  Alloc(LONGCARD(TSIZE(BCBDef)      * NumbOfFatBuffers), BCBfatBuf);
  Alloc(LONGCARD(TSIZE(DiskBuffDef) * NumbOfFatBuffers), DiskFatBuff);

  FOR c := 1 TO NumbOfFatBuffers DO
      WITH BCBfatBuf^[c] DO
           blink   := ADR(BCBfatBuf^[c + 1]);
           bbufdrv := -1;
           bbuftyp := 0;
           bbufrec := 0;
           bdirty  := 0;
           bdm     := ADDRESS(0);
           bbufr   := ADR(DiskFatBuff^[c]);
      END;
  END;

  BCBfatBuf^[NumbOfFatBuffers].blink := BCBPtr(0);

  Alloc(LONGCARD(TSIZE(BCBDef)      * NumbOfDirBuffers), BCBDirBuf);
  Alloc(LONGCARD(TSIZE(DiskBuffDef) * NumbOfDirBuffers), DiskDirBuff);

  FOR c := 1 TO NumbOfDirBuffers DO
      WITH BCBDirBuf^[c] DO
           blink   := ADR(BCBDirBuf^[c + 1]);
           bbufdrv := -1;
           bbuftyp := 1;
           bbufrec := -1;
           bdirty  := 0;
           bdm     := ADDRESS(0);
           bbufr   := ADR(DiskDirBuff^[c]);
      END;
  END;

  BCBDirBuf^[NumbOfDirBuffers].blink := BCBPtr(0);

  SuperExec(PROC(InstallFatBuffers)); (* Install the Fat Disk Buffers *)
  SuperExec(PROC(InstallDirBuffers)); (* Install the Dir Disk Buffers *)

  RETURN TRUE;

END Initialise;

BEGIN   (* body of Buffers *)

  IF Initialise()
     THEN WITH BasePageAddress^ DO
               TermRes(CodeLen +             (*Tell GEMDOS to terminate us*)
                       DataLen +             (*but let us remain in memory*)
                       BssLen  +
                       LONGCARD(CodeBase - LowTPA), 0);
          END;
  END;

END Buffers.
