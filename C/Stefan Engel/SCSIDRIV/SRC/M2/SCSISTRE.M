IMPLEMENTATION MODULE ScsiStreamer;

(****************************************************************************
 *
 *
 * $Source: E:\HM2\LIB\se\rcs\scsistre.m,v $
 *
 * $Revision: 1.1 $
 *
 * $Author: S_Engel $
 *
 * $Date: 1996/02/03 19:34:50 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: scsistre.m,v $
 * Revision 1.1  1996/02/03  19:34:50  S_Engel
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
FROM SYSTEM   (* Type  *) IMPORT BYTE, ADDRESS,
              (* Proc  *) ADR, TSIZE;

FROM Portab IMPORT UChar, Char;

(* Standard HM2-Libs *)

(* Eigene Libs *)

(* Projektlibs *)
IMPORT Scsi, ScsiIO;
FROM Scsi IMPORT Cmd6, Cmd10, Cmd12, SetCmd6, SetCmd10, SetCmd12, SetCmd,
          BlockLen, MaxDmaLen, LogicalUnit;






(***************************************************************************)
(*-                                                                       -*)
(*- Sequential Access Devices                                             -*)
(*-                                                                       -*)
(***************************************************************************)

PROCEDURE Read(TransferLen:SHORTCARD;Adr:ADDRESS; Timeout : LONGCARD) : BOOLEAN;
VAR
  Ok      : BOOLEAN;
  MaxLen  : LONGCARD;
  SCmd    : ScsiIO.tSCSICmd;

BEGIN
  Ok:=TRUE;

  MaxLen := MaxDmaLen DIV BlockLen;

  WHILE Ok AND (TransferLen > MaxLen) DO
    VOID(SetCmd6(Cmd6, 008H, 010000H + MaxLen DIV 256, MaxLen MOD 256));
    Ok := ScsiIO.In(SetCmd(SCmd, Cmd6, Adr, VAL(LONGCARD, MaxLen) * BlockLen, Timeout * 200)) = 0;
    DEC(TransferLen, MaxLen);
    Adr := Adr + VAL(LONGCARD, MaxLen) * BlockLen;
  END;
  VOID(SetCmd6(Cmd6, 008H, 010000H + TransferLen DIV 256, TransferLen MOD 256));
  RETURN Ok AND(ScsiIO.In(SetCmd(SCmd, Cmd6, Adr, BlockLen * VAL(LONGCARD, TransferLen), Timeout * 200)) = 0);
END Read;

PROCEDURE ReadNum(VAR TransferLen:SHORTCARD; Adr:ADDRESS; Timeout : LONGCARD) : BOOLEAN;
VAR Ok : BOOLEAN;
    Read : SHORTCARD;
    MaxLen : LONGCARD;
  SCmd  : ScsiIO.tSCSICmd;
  
BEGIN
  Ok:=TRUE;
  Read := 0;

  MaxLen := MaxDmaLen DIV BlockLen;
  IF MaxLen > 255 (* mehr als 255 passen nicht in CDB! *)
  THEN
    MaxLen := 255;
  END;

  WHILE Ok AND (TransferLen > MaxLen) DO
    VOID(SetCmd6(Cmd6, 008H, 010000H+MaxLen DIV 256, MaxLen MOD 256));
    Ok := ScsiIO.In(SetCmd(SCmd, Cmd6, Adr, VAL(LONGCARD, MaxLen) * BlockLen, Timeout * 200)) = 0;
    DEC(TransferLen, MaxLen);
    INC(Read, MaxLen);
    Adr := Adr + VAL(LONGCARD, MaxLen) * BlockLen;
  END;

  VOID(SetCmd6(Cmd6, 008H, 010000H + TransferLen DIV 256, TransferLen MOD 256));
  IF Ok
  THEN
    Ok := ScsiIO.In(SetCmd(SCmd, Cmd6, Adr, BlockLen * VAL(LONGCARD, TransferLen), Timeout * 200)) = 0;
    INC(Read, TransferLen);
  END;
  TransferLen := Read;
  RETURN Ok;
END ReadNum;

PROCEDURE Write(TransferLen:SHORTCARD;Adr:ADDRESS;Timeout : LONGCARD) : BOOLEAN;
VAR Ok      : BOOLEAN;
    MaxLen  : LONGCARD;
    SCmd    : ScsiIO.tSCSICmd;
  
BEGIN
  RETURN WriteNum(TransferLen, Adr, Timeout);

(*
  Ok:=TRUE;
  MaxLen := MaxDmaLen DIV BlockLen;
  WHILE Ok AND (TransferLen > MaxLen) DO
    VOID(SetCmd6(Cmd6, 00AH, 010000H + MaxLen DIV 256, MaxLen MOD 256));
    Ok := ScsiIO.Out(SetCmd(SCmd, Cmd6, Adr, VAL(LONGCARD, MaxLen) * BlockLen, Timeout * 200)) = 0;
    DEC(TransferLen, MaxLen);
    Adr := Adr + VAL(LONGCARD, MaxLen) * BlockLen;
  END;
  VOID(SetCmd6(Cmd6, 00AH, 010000H+TransferLen DIV 256, TransferLen MOD 256));
  RETURN Ok AND (ScsiIO.Out(SetCmd(SCmd, Cmd6, Adr, BlockLen * VAL(LONGCARD, TransferLen), Timeout * 200)) = 0);
*)
END Write;

PROCEDURE WriteNum(VAR TransferLen:SHORTCARD;Adr:ADDRESS;Timeout : LONGCARD) : BOOLEAN;
VAR
  Ok      : BOOLEAN;
  Written : SHORTCARD;
  MaxLen : SHORTCARD;
  SCmd  : ScsiIO.tSCSICmd;

BEGIN
  Ok:=TRUE;
  Written := 0;
  MaxLen := MaxDmaLen DIV BlockLen;
  IF MaxLen > 255 (* mehr als 255 passen nicht in CDB! *)
  THEN
    MaxLen := 255;
  END;
  WHILE Ok AND (TransferLen > MaxLen) DO
    VOID(SetCmd6(Cmd6, 00AH, 010000H + MaxLen DIV 256, MaxLen MOD 256));
    Ok := ScsiIO.Out(SetCmd(SCmd, Cmd6, Adr, VAL(LONGCARD, MaxLen) * BlockLen, Timeout * 200)) = 0;
    DEC(TransferLen, MaxLen);
    INC(Written, MaxLen);
    Adr := Adr + VAL(LONGCARD, MaxLen) * BlockLen;
  END;
  VOID(SetCmd6(Cmd6, 00AH, 010000H + TransferLen DIV 256, TransferLen MOD 256));
  IF Ok
    THEN
      INC(Written, TransferLen);
      Ok := ScsiIO.Out(SetCmd(SCmd, Cmd6, Adr, BlockLen * VAL(LONGCARD, TransferLen), Timeout * 200)) = 0;
    END;
  TransferLen := Written;
  RETURN Ok;
END WriteNum;

PROCEDURE Erase(TimeoutSeconds : LONGCARD) : BOOLEAN;
VAR
  SCmd  : ScsiIO.tSCSICmd;
    
BEGIN
  VOID(SetCmd6(Cmd6, 019H,010000H,0));
  RETURN ScsiIO.In(SetCmd(SCmd, Cmd6, NIL, 0, TimeoutSeconds * 200)) = 0;
END Erase;

PROCEDURE Load(Imed, Ret, Eot, Load:BOOLEAN;
               TimeoutSeconds:LONGCARD) : BOOLEAN;
VAR
  SCmd  : ScsiIO.tSCSICmd;

BEGIN
  VOID(SetCmd6(Cmd6, 01BH,0,0));
  WITH Cmd6 DO
    IF Imed THEN
      LunAdr := VAL(BYTE, UChar(LunAdr)+1);
    ELSE
    END;
    IF Load THEN
      Len := 1;
    END;
    IF Ret THEN
      Len := UChar(VAL(CHAR,VAL(SHORTCARD, CHAR(Len))+2));
    END;
    IF Eot THEN
      Flags:=BYTE(080H);
    END;
  END;
  RETURN ScsiIO.In(SetCmd(SCmd, Cmd6, NIL, 0, TimeoutSeconds * 200)) = 0;

END Load;

PROCEDURE WriteFilemark(Imed : BOOLEAN; Number : SHORTCARD; Timeout : LONGCARD) : BOOLEAN;
VAR
  SCmd  : ScsiIO.tSCSICmd;

BEGIN
  VOID(SetCmd6(Cmd6, 010H,0,Number));
  IF Imed THEN
    Cmd6.Flags:=BYTE(040H);
  END;
  RETURN ScsiIO.In(SetCmd(SCmd, Cmd6, NIL, 0, Timeout * 200)) = 0;
END WriteFilemark;

PROCEDURE Space(Code : SHORTCARD; Count : LONGINT;
                TimeoutSeconds : LONGCARD) : BOOLEAN;

VAR
  Ok          : BOOLEAN;
  SCmd  : ScsiIO.tSCSICmd;
    
BEGIN
  WITH Cmd6 DO
    Command := (011H);
    LunAdr:=BYTE(VAL(CHAR,LogicalUnit + Code MOD 8));
    Adr:=VAL(SHORTCARD, LONGCARD(Count) DIV 0100H);
    Len := VAL(UChar, LONGCARD(Count) MOD 0100H);
    Flags:=BYTE(0);
  END;
  RETURN ScsiIO.In(SetCmd(SCmd, Cmd6, NIL, 0, TimeoutSeconds * 200)) = 0;
END Space;

PROCEDURE Rewind(Imed : BOOLEAN; TimeoutSeconds : LONGCARD) : BOOLEAN;
VAR
  SCmd  : ScsiIO.tSCSICmd;

BEGIN
  VOID(SetCmd6(Cmd6, 001H,0,0));
  IF Imed THEN
    Cmd6.LunAdr := VAL(BYTE, UChar(Cmd6.LunAdr)+1);
  END;
  RETURN ScsiIO.In(SetCmd(SCmd, Cmd6, NIL, 0, TimeoutSeconds * 200)) = 0;
END Rewind;

(*-------------------------------------------------------------------------*)
(*-                                                                       -*)
(*- Quick File Access                                                     -*)
(*-                                                                       -*)
(*-------------------------------------------------------------------------*)
PROCEDURE SeekBlock(Imed : BOOLEAN;
                    BlockAdr,TimeoutSeconds : LONGCARD) : BOOLEAN;
VAR
  Ok          : BOOLEAN;
  SCmd  : ScsiIO.tSCSICmd;
    
BEGIN
  VOID(SetCmd6(Cmd6, 00CH,VAL(SHORTCARD, BlockAdr DIV 0100H),
                   VAL(SHORTCARD, BlockAdr MOD 0100H)));
  IF Imed THEN
    Cmd6.LunAdr := VAL(BYTE, UChar(Cmd6.LunAdr)+1);
  END;
  RETURN ScsiIO.In(SetCmd(SCmd, Cmd6, NIL, 0, TimeoutSeconds * 200)) = 0;
END SeekBlock;

PROCEDURE RequestBlockAdr(VAR BlockAdr : LONGCARD) : BOOLEAN;

VAR
  Ok : BOOLEAN;
  SCmd  : ScsiIO.tSCSICmd;

BEGIN
  VOID(SetCmd6(Cmd6, 002H, 0, 3));
  (* Daten in die oberen 3 Bytes von BlockAdr einlesen *)
  Ok := ScsiIO.In(SetCmd(SCmd, Cmd6, ADR(BlockAdr), 3, ScsiIO.DefTimeout)) = 0;
  (* Daten an richtige Position shiften *)
  BlockAdr:=BlockAdr DIV 0100H;
  RETURN Ok;
END RequestBlockAdr;

PROCEDURE Locate(BlockAdresstype : BOOLEAN;
                    ChangePartition : BOOLEAN;
                    Imed            : BOOLEAN;
                    BlockAdress     : LONGCARD;
                    Partition       : SHORTCARD;
                    TimeoutSeconds  : LONGCARD) : BOOLEAN;

TYPE tLoc = RECORD
                 Command : BYTE;
                 Lun     : BYTE;
                 Res1    : BYTE;
                 Adr3    : BYTE;
                 Adr2    : BYTE;
                 Adr1    : BYTE;
                 Adr0    : BYTE;
                 Res2    : BYTE;
                 part    : BYTE;
                 Flags   : BYTE; 
               END;

VAR
  Cmd         : tLoc;
  OldTimeout  : LONGCARD;
  Ok          : BOOLEAN;
  SCmd  : ScsiIO.tSCSICmd;

  BEGIN
(*    OldTimeout := ScsiIO.GetTimeout();*)
(*    ScsiIO.SetTimeout(TimeoutSeconds * 100);*)
    (* Kommandoblock zusammensetzen *)
    WITH Cmd DO
      Command:=BYTE(02BH);
      Lun:=BYTE(VAL(CHAR,LogicalUnit));

      IF BlockAdresstype
        THEN
          (* Bit setzen *)
          Lun := BYTE(VAL(CHAR,VAL(SHORTCARD, CHAR(Lun)) + 4));
        END;
      IF ChangePartition
        THEN
          (* Bit setzen *)
          Lun := BYTE(VAL(CHAR,VAL(SHORTCARD, CHAR(Lun)) + 2));
        END;
      IF Imed
        THEN
          (* Bit setzen *)
          Lun := BYTE(VAL(CHAR,VAL(SHORTCARD, CHAR(Lun)) + 1));
        END;

      Res1 := BYTE( 0);
      Adr3 := BYTE(VAL(CHAR, BlockAdress DIV 01000000H));
      Adr2 := BYTE(VAL(CHAR, BlockAdress DIV 010000H MOD 0100H));
      Adr1 := BYTE(VAL(CHAR, BlockAdress DIV 0100H MOD 0100H));
      Adr0 := BYTE(VAL(CHAR, BlockAdress MOD 0100H));
      Res2 := BYTE( 0);
      part := BYTE(VAL(CHAR, Partition));
      Flags:=BYTE(0);
    END;
    RETURN ScsiIO.In(SetCmd(SCmd, Cmd, NIL, 0, TimeoutSeconds * 200)) = 0;
(*    Ok := ScsiIO.SendCmdDataIn(Cmd, 10, NIL, 0);*)
(*    ScsiIO.SetTimeout(OldTimeout);*)
(*    RETURN Ok;*)
  END Locate;


PROCEDURE ReadPosition(    BlockAdresstype : BOOLEAN;
                          VAR Partition       : SHORTCARD;
                          VAR BlockAdress     : LONGCARD) : BOOLEAN;

TYPE tPositionData = RECORD
                       Flags     : BYTE;  (* BOP, EOP, Res, Res, Res, BDU, Res, Res *)
                       part      : BYTE;
                       Res1      : BYTE;
                       Res2      : BYTE;
                       FirstLoc  : LONGCARD;
                       LastLoc   : LONGCARD;
                       Res3      : BYTE;
                       NBlBuff2  : BYTE;
                       NBlBuff1  : BYTE;
                       NBlBuff0  : BYTE;
                       BuffBytes : LONGCARD;
                     END;
(*$? TSIZE(tPositionData) # 20 : Fragezeichen? *)


VAR
  PositionData : tPositionData;
  Ok           : BOOLEAN;
  SCmd  : ScsiIO.tSCSICmd;

  BEGIN
    VOID(SetCmd10(Cmd10, 034H, 0, 0));
    IF BlockAdresstype
      THEN
        (* Bit setzen *)
        Cmd10.Lun := VAL(BYTE, UChar(Cmd10.Lun) + 1);
      END;
    Ok := ScsiIO.In(SetCmd(SCmd, Cmd10, ADR(PositionData), SIZE(PositionData), ScsiIO.DefTimeout)) = 0;
(*    Ok := ScsiIO.SendCmdDataIn(Cmd10, 10, ADR(PositionData), SIZE(PositionData));*)

    WITH PositionData DO
      Partition := VAL(SHORTCARD, CHAR(part));
      BlockAdress := FirstLoc;
    END;

    RETURN Ok;
  END ReadPosition;




BEGIN

END ScsiStreamer.
