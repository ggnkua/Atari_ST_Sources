IMPLEMENTATION MODULE ScsiProc;
(****************************************************************************
 *
 *
 * $Source: E:\HM2\LIB\se\rcs\scsiproc.m,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:34:22 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsiproc.m,v $
 * Revision 1.1  1996/02/03  19:34:22  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)


(* Systemabh„ngiges *)
(* IMPLEMENTATION FšR  >>> H„nisch-Modula-2 <<< *)
(*                                              *)
(* Durchgefhrt von Steffen Engel               *)
(*                                              *)
(*$S-   Stack-Checks                            *)
(*$I-   keine Variablen-Initialisierung         *)
(*$V-   keine arithmetischen Kontrollen         *)
(*$T-   kein Bereichstest                       *)
(*$Y-   keine Laufzeittests auf RETURN und CASE *)
(*                                              *)
(*----------------------------------------------*)



IMPORT SYSTEM, System;

(* Standard HM2-Libs *)

(* Eigene Libs *)

(* Projektlibs *)
IMPORT ScsiDefs, ScsiIO, Scsi;


(***************************************************************************)
(*-                                                                       -*)
(*- Processor Devices                                                     -*)
(*-                                                                       -*)
(***************************************************************************)

PROCEDURE Send(AEN : BOOLEAN; Data : SYSTEM.ADDRESS; Length : LONGCARD) : BOOLEAN;
VAR
  SCmd  : ScsiIO.tSCSICmd;

BEGIN

  WITH Scsi.Cmd6 DO
    Command := 00AH;
    LunAdr  := SYSTEM.BYTE(VAL(CHAR, Scsi.LogicalUnit+ORD(AEN)));
    Adr     := Length DIV 0100H;
    Len     := Length MOD 0100H;
    Flags   := SYSTEM.BYTE(0);
  END;
  RETURN ScsiIO.Out(Scsi.SetCmd(SCmd, Scsi.Cmd6, Data, Length, ScsiIO.DefTimeout)) = 0;
END Send;


PROCEDURE Receive(Data : SYSTEM.ADDRESS; Length : LONGCARD) : BOOLEAN;
VAR
  SCmd  : ScsiIO.tSCSICmd;

BEGIN

  WITH Scsi.Cmd6 DO
    Command := 08H;
    LunAdr  := SYSTEM.BYTE(VAL(CHAR, Scsi.LogicalUnit));
    Adr     := Length DIV 0100H;
    Len     := Length MOD 0100H;
    Flags   := SYSTEM.BYTE(0);
  END;
  RETURN ScsiIO.In(Scsi.SetCmd(SCmd, Scsi.Cmd6, Data, Length, ScsiIO.DefTimeout)) = 0;

END Receive;



BEGIN

END ScsiProc.
