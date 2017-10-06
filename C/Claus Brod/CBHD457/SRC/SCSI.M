IMPLEMENTATION MODULE Scsi;
(****************************************************************************
 *
 * SCSI-Zugriffe nach SCSI-2
 *
 * $Source: /dev/e/hm2/lib/se\RCS\SCSI.M,v $
 *
 * $Revision: 1.2 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 00:04:08 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: SCSI.M,v $
 * Revision 1.2  1996/02/14  00:04:08  Steffen_Engel
 * Korrektur bei Maskierung in SetCmd6: Maske 1F muû Modulo 20 tragen.
 *
 * Revision 1.1  1996/02/03  19:33:48  S_Engel
 * Initial revision
 *
 *****************************************************************************
 * altes Modul: SCSI2.M
 *
 * Revision 1.5  1995/10/30  17:44:48  S_Engel
 * *** empty log message ***
 *
 * Revision 1.4  1995/04/13  13:46:56  S_Engel
 * Simple Senseauswertung mit GetError
 *
 * Revision 1.3  1995/02/10  12:38:10  S_Engel
 * Anpassungen an aktuellen SCSI-Driver
 *
 * Revision 1.2  1995/02/07  23:59:40  S_Engel
 * Umstellung auf handleorientierte SCSI-Routinen
 *
 * Revision 1.1  1995/01/01  19:14:46  S_Engel
 * Initial revision
 *
 *
 ****************************************************************************)


FROM SYSTEM   (* Type  *) IMPORT BYTE, ADDRESS,
              (* Proc  *) ADR, TSIZE;

IMPORT SYSTEM;

FROM Portab IMPORT UChar, Char;

IMPORT ScsiIO;

  FROM SYSTEM  IMPORT CODE;
  (* String fÅr WHAT - leider ein biûchen HM2-spezifisches *)
  CONST What = '@(#) Scsi2 '
               + CHR(SYSTEM.DATE DIV 1000000H DIV 10 + 48)
               + CHR(SYSTEM.DATE DIV 1000000H MOD 10 + 48) + '.'
               + CHR(SYSTEM.DATE DIV 10000H MOD 100H DIV 10 MOD 10 + 48)
               + CHR(SYSTEM.DATE DIV 10000H MOD 100H MOD 10 + 48) + '.'
               + CHR(SYSTEM.DATE MOD 10000H DIV 10 MOD 10 + 48)
               + CHR(SYSTEM.DATE MOD 10000H MOD 10 + 48)
               + '  (c) S. Engel';


(*------ Deklarationsteil *)

VAR
  Handle          : ScsiIO.tHandle; 
  SCmd            : ScsiIO.tSCSICmd;

(*------ Hilfsunterprogramme *)

PROCEDURE SetCmd6(Cmd :SHORTCARD;BlockAdr:LONGCARD;
                                   TransferLen:SHORTCARD);
         
BEGIN
  WITH Cmd6 DO
    Command := Cmd;
    LunAdr  := BYTE(VAL(CHAR,LogicalUnit+
              VAL(SHORTCARD,BlockAdr DIV 010000H) MOD 020H));
    Adr     := VAL(SHORTCARD, BlockAdr MOD 010000H);
    Len     := TransferLen MOD 0100H;
    Flags   := BYTE(VAL(CHAR,0));
  END;
END SetCmd6;

PROCEDURE SetCmd10(Cmd :SHORTCARD;BlockAdr:LONGCARD;
                                      TransferLen:SHORTCARD);
         
BEGIN
  WITH Cmd10 DO
    Command   := Cmd;
    Lun       := BYTE(VAL(CHAR, LogicalUnit));
    Adr       := BlockAdr;
    Reserved  := 0;
    LenHigh   := TransferLen DIV 100H;
    LenLow    := TransferLen MOD 100H;
    Flags     := BYTE(VAL(CHAR,0));
  END;
END SetCmd10;

PROCEDURE SetCmd12(Cmd : SHORTCARD; BlockAdr    : LONGCARD;
                                    TransferLen : LONGCARD);
         
BEGIN
  WITH Cmd12 DO
    Command := Cmd;
    Lun     := BYTE(VAL(CHAR,LogicalUnit));
    Adr     := BlockAdr;
    Len     := TransferLen;
    Reserved:= BYTE(0);
    Flags   := BYTE(0);
  END;
END SetCmd12;

PROCEDURE SetCmd(VAR Cmd      : ARRAY OF SYSTEM.LOC;
                     Buffer   : SYSTEM.ADDRESS;
                     Len      : LONGCARD;
                     TimeOut  : LONGCARD) : ScsiIO.tpSCSICmd;

  BEGIN
    SCmd.handle := Handle;
    SCmd.Cmd    := SYSTEM.ADR(Cmd);
    SCmd.CmdLen := HIGH(Cmd) + 1;
    SCmd.Buffer := Buffer;
    SCmd.TransferLen := Len;
    SCmd.SenseBuffer := SYSTEM.ADR(ScsiIO.ReqBuff);
    SCmd.Timeout := TimeOut;
    SCmd.Flags := ScsiFlags;
    RETURN SYSTEM.ADR(SCmd);
  END SetCmd;




PROCEDURE TestUnitReady() : BOOLEAN;

BEGIN
  SetCmd6(000H,0,0);
  RETURN ScsiIO.In(SetCmd(Cmd6, NIL, 0, ScsiIO.DefTimeout)) = 0;
END TestUnitReady;


PROCEDURE Inquiry(Buffer : ADDRESS; Vital : BOOLEAN; Page : SHORTCARD; TransLen : SHORTCARD) : BOOLEAN;

  BEGIN
    WITH Cmd6 DO
      Command := 12H;
      LunAdr  := BYTE(VAL(CHAR, LogicalUnit));
      Adr := 0;
      IF Vital
        THEN
          LunAdr  := BYTE(VAL(CHAR, LogicalUnit + 1));
          Adr := Page * 100H;
        END;
      Len := TransLen;
      Flags := BYTE(0);
    END;
    RETURN ScsiIO.In(SetCmd(Cmd6, Buffer, TransLen, ScsiIO.DefTimeout)) = 0;
  END Inquiry;


PROCEDURE ModeSelect(SelectFlags  : tsSelectFlag;
                        Buffer       : ADDRESS;
                        ParmLen      : SHORTCARD) : BOOLEAN;

BEGIN
  ParmLen := ParmLen
             + TSIZE(tParmHead)       (* ParameterHeader                *)
             + TSIZE(tBlockDesc);     (* Block-Deskriptor               *)

  WITH Cmd6 DO
    Command := 015H;
    LunAdr  := BYTE(VAL(CHAR,LogicalUnit+(VAL(SHORTCARD,CHAR(SelectFlags)) MOD 020H)));
    Adr     := 0;
    Len     := ParmLen;
    Flags   := BYTE(0);
  END;
  RETURN ScsiIO.Out(SetCmd(Cmd6, Buffer, ParmLen, ScsiIO.DefTimeout)) = 0;
(*  RETURN ScsiIO.SendCmdDataOut(Cmd6, 6, Buffer, ParmLen);*)
END ModeSelect;


PROCEDURE ModeSense(PageCode       : SHORTCARD;
                       PageControl    : tPC;
                       Buffer         : ADDRESS;
                       ParmLen        : SHORTCARD) : BOOLEAN;
BEGIN
  ParmLen := ParmLen
             + TSIZE(tParmHead)       (* ParameterHeader                *)
             + TSIZE(tBlockDesc);     (* Block-Deskriptor               *)

  WITH Cmd6 DO
    Command := 01AH;
    LunAdr  := BYTE(VAL(CHAR,LogicalUnit));
    Adr     := ((ORD(PageControl) * 64 + PageCode) MOD 0100H)*0100H;
    Len     := ParmLen;
    Flags   := BYTE(0);
  END;
  RETURN ScsiIO.In(SetCmd(Cmd6, Buffer, ParmLen, ScsiIO.DefTimeout)) = 0;
(*  RETURN ScsiIO.SendCmdDataIn(Cmd6, 6, Buffer, ParmLen);*)
END ModeSense;


PROCEDURE PreventMediaRemoval(Prevent:BOOLEAN) : BOOLEAN;

BEGIN
  IF Prevent THEN
    SetCmd6(01EH,0,1);
  ELSE
    SetCmd6(01EH,0,0);
  END;
  RETURN ScsiIO.In(SetCmd(Cmd6, NIL, 0, ScsiIO.DefTimeout)) = 0;
END PreventMediaRemoval;


PROCEDURE GetError(reqbuff : ADDRESS) : ErrorType;
TYPE tReq = POINTER TO ARRAY[0..17] OF UChar;

  BEGIN
    CASE tReq(reqbuff)^[12] OF
      |004H,
       03AH: RETURN nomedia;
      |028H: RETURN mediachange;
      |029H: RETURN reset;

      ELSE
          RETURN unknown;
    END;
  END GetError;


(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Allgemeine Tools                                                      -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)

PROCEDURE Wait(Ticks : LONGCARD);
VAR Clock[04BAH], Time : LONGCARD;

  BEGIN
    Time := Clock + Ticks;
    WHILE Clock < Time DO
    END;
  END Wait;

PROCEDURE SetBlockSize(NewLen : LONGCARD);

BEGIN
  BlockLen := NewLen;
(*  MaxTransferLen:=VAL(SHORTCARD, ScsiIO.MaxDmaLen DIV VAL(LONGCARD, BlockLen));*)
END SetBlockSize;

PROCEDURE GetBlockSize() : LONGCARD;

BEGIN
  RETURN BlockLen;
END GetBlockSize;


(*$E+*)
PROCEDURE MySetScsiUnit(handle : ScsiIO.tHandle; Lun: SHORTINT; MaxLen : LONGCARD);

BEGIN
(*  ScsiIO.SetDmaScsiAdr(handle);*)
  Handle := handle;
  LogicalUnit:=VAL(SHORTCARD, Lun);
  MaxDmaLen := MaxLen;
END MySetScsiUnit;
(*$E=*)




BEGIN
  LogicalUnit:=0;
  SetBlockSize(ScsiIO.DmaBlockLen);
  SetScsiUnit := MySetScsiUnit;
  ScsiFlags := {};
END Scsi.
