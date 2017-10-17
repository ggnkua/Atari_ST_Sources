DEFINITION MODULE ScsiProc;

(****************************************************************************
 *
 *
 * $Source: E:\HM2\LIB\se\rcs\scsiproc.d,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:32:08 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsiproc.d,v $
 * Revision 1.1  1996/02/03  19:32:08  S_Engel
 * Initial revision
 *
 *
 *
 ****************************************************************************)

FROM SYSTEM  IMPORT BYTE,ADDRESS,TSIZE;


(***************************************************************************)
(*-                                                                       -*)
(*- Processor Devices                                                     -*)
(*-                                                                       -*)
(***************************************************************************)
PROCEDURE Send(AEN : BOOLEAN; Data : ADDRESS; Length : LONGCARD) : BOOLEAN;

PROCEDURE Receive(Data : ADDRESS; Length : LONGCARD) : BOOLEAN;



END ScsiProc.
