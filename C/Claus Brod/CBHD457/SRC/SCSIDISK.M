IMPLEMENTATION MODULE ScsiDisk;
(****************************************************************************
 *
 *
 * $Source: /dev/e/hm2/lib/se\RCS\SCSIDISK.M,v $
 *
 * $Revision: 1.3 $
 *
 * $Author: Steffen_Engel $
 *
 * $Date: 1996/02/14 00:00:26 $
 *
 * $State: Exp $
 *
 *****************************************************************************
 * History:
 *
 * $Log: SCSIDISK.M,v $
 * Revision 1.3  1996/02/14  00:00:26  Steffen_Engel
 * Korrektur: cMaxBlockAdr muž 1FFFFF sein!
 *
 * Revision 1.2  1996/02/03  19:34:02  S_Engel
 * Kleine Anpassungen
 *
 * Revision 1.1  1995/11/13  23:36:28  S_Engel
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
FROM Scsi IMPORT Cmd6, Cmd10, Cmd12, SetCmd6, SetCmd10, SetCmd12, SetCmd, BlockLen, MaxDmaLen;




PROCEDURE Read6(BlockAdr : LONGCARD;
               TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;
VAR
    Ok : BOOLEAN;
    MaxLen : SHORTCARD;

BEGIN
  Ok:=TRUE;
  MaxLen := MaxDmaLen DIV BlockLen;
  IF MaxLen > 255
    THEN
      MaxLen := 255;
    END;
  WHILE Ok AND (TransferLen > MaxLen) DO
    SetCmd6(008H, BlockAdr, MaxLen);
    Ok:=ScsiIO.In(SetCmd(Cmd6,Adr, VAL(LONGCARD, MaxLen) * BlockLen, ScsiIO.DefTimeout)) = 0;
    INC(BlockAdr, MaxLen);
    DEC(TransferLen, MaxLen);
    Adr := Adr + VAL(LONGCARD, MaxLen) * BlockLen;
  END;
  SetCmd6(008H,BlockAdr,TransferLen);
  RETURN Ok AND (ScsiIO.In(SetCmd(Cmd6, Adr, VAL(LONGCARD, BlockLen) * VAL(LONGCARD, TransferLen), ScsiIO.DefTimeout)) = 0);

END Read6;
PROCEDURE Read10(BlockAdr : LONGCARD;
               TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;
VAR
      Ok : BOOLEAN;

BEGIN
  Ok:=TRUE;
  WHILE Ok AND (TransferLen > MaxDmaLen DIV BlockLen) DO
    SetCmd10(028H, BlockAdr, MaxDmaLen DIV BlockLen);
    Ok := ScsiIO.In(SetCmd(Cmd10, Adr, MaxDmaLen DIV BlockLen * BlockLen, 10 * 200)) = 0;
    INC(BlockAdr, MaxDmaLen DIV BlockLen);
    DEC(TransferLen, MaxDmaLen DIV BlockLen);
    Adr := Adr + MaxDmaLen DIV BlockLen * BlockLen;
  END;
  SetCmd10(028H, BlockAdr, TransferLen);
  RETURN Ok AND(ScsiIO.In(SetCmd(Cmd10, Adr, VAL(LONGCARD, BlockLen) * VAL(LONGCARD, TransferLen), ScsiIO.DefTimeout)) = 0);
END Read10;

PROCEDURE Write6(BlockAdr : LONGCARD;
                TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;
VAR
    Ok     : BOOLEAN;
    MaxLen : SHORTCARD;

BEGIN
  Ok:=TRUE;
  MaxLen := MaxDmaLen DIV BlockLen;
  IF MaxLen > 255
    THEN
      MaxLen := 255;
    END;
  WHILE Ok AND (TransferLen > MaxLen) DO
    SetCmd6(00AH, BlockAdr, MaxLen);
    Ok := ScsiIO.Out(SetCmd(Cmd6, Adr, VAL(LONGCARD, MaxLen) * BlockLen, ScsiIO.DefTimeout)) = 0;
    INC(BlockAdr, MaxLen);
    DEC(TransferLen, MaxLen);
    Adr := Adr + VAL(LONGCARD, MaxLen) * BlockLen;
  END;
  SetCmd6(00AH,BlockAdr,TransferLen);
  RETURN Ok AND (ScsiIO.Out(SetCmd(Cmd6, Adr, BlockLen * VAL(LONGCARD, TransferLen), ScsiIO.DefTimeout)) = 0);
END Write6;
PROCEDURE Write10(BlockAdr : LONGCARD;
                TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;
VAR
    Ok : BOOLEAN;

BEGIN
  Ok:=TRUE;
  WHILE Ok AND (TransferLen>MaxDmaLen DIV BlockLen) DO
    SetCmd10(02AH,BlockAdr,MaxDmaLen DIV BlockLen);
    Ok := ScsiIO.Out(SetCmd(Cmd10, Adr, MaxDmaLen DIV BlockLen * BlockLen, 20*200)) = 0;
    INC(BlockAdr,MaxDmaLen DIV BlockLen);
    DEC(TransferLen, MaxDmaLen DIV BlockLen);
    Adr := Adr + MaxDmaLen DIV BlockLen * BlockLen;
  END;
  SetCmd10(02AH,BlockAdr,TransferLen);
  RETURN Ok AND (ScsiIO.Out(SetCmd(Cmd10, Adr, VAL(LONGCARD, BlockLen) * VAL(LONGCARD, TransferLen), 20*200)) = 0);
END Write10;


CONST
    cMaxBlockAdr     =  001FFFFFH; (* Max. Blocknummer bei Read(6)/Write(6)  *)

PROCEDURE Read(BlockAdr : LONGCARD;
               TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;

BEGIN
  IF (BlockAdr > cMaxBlockAdr)
    THEN
      RETURN Read10(BlockAdr, TransferLen, Adr);
    ELSE
      RETURN Read6(BlockAdr, TransferLen, Adr);
    END;
END Read;

PROCEDURE Write(BlockAdr : LONGCARD;
                TransferLen : SHORTCARD; Adr : ADDRESS) : BOOLEAN;

BEGIN
  IF (BlockAdr > cMaxBlockAdr)
    THEN
      RETURN Write10(BlockAdr, TransferLen, Adr);
    ELSE
      RETURN Write6(BlockAdr, TransferLen, Adr);
    END;
END Write;

PROCEDURE StartStop(LoadEject, StartFlag : BOOLEAN) : BOOLEAN;

BEGIN
  IF StartFlag THEN
    SetCmd6(01BH,0,1);
  ELSE
    SetCmd6(01BH,0,0);
  END; 
  IF LoadEject
    THEN
      INCL(BYTESET(Cmd6.Len), 1);
    END;
  RETURN ScsiIO.In(SetCmd(Cmd6, NIL, 0, 60*200)) = 0;
END StartStop;

PROCEDURE Seek6(BlockAdr : LONGCARD) : BOOLEAN;

  BEGIN
    SetCmd6(00BH, BlockAdr, 0);
    RETURN ScsiIO.In(SetCmd(Cmd6, NIL, 0, ScsiIO.DefTimeout)) = 0;
  END Seek6;

PROCEDURE Seek10(BlockAdr : LONGCARD) : BOOLEAN;

  BEGIN
    SetCmd10(02BH, BlockAdr, 0);
    RETURN ScsiIO.In(SetCmd(Cmd10, NIL, 0, ScsiIO.DefTimeout)) = 0;
  END Seek10;

PROCEDURE Seek(BlockAdr : LONGCARD) : BOOLEAN;

BEGIN
  IF BlockAdr > cMaxBlockAdr
    THEN
      RETURN Seek10(BlockAdr);
    ELSE
      RETURN Seek6(BlockAdr);
    END;
END Seek;

PROCEDURE Format() : BOOLEAN;

  BEGIN
    SetCmd6(004H,0,0);
    RETURN ScsiIO.In(SetCmd(Cmd6, NIL, 0, 24*60*60*200)) = 0;
  END Format;




PROCEDURE ReadCapacity(PMI : BOOLEAN; VAR BlockAdr, BlockLen : LONGCARD) : BOOLEAN;
VAR Data : ARRAY[0..1] OF LONGCARD;
    Ok : BOOLEAN;

  BEGIN
    SetCmd10(025H, BlockAdr, 0);

    IF PMI
      THEN
        Cmd10.LenLow := 1;
      END;

    (* und rufen *)
    Ok := ScsiIO.In(SetCmd(Cmd10, ADR(Data), SIZE(Data), ScsiIO.DefTimeout)) = 0;
(*    Ok := ScsiIO.SendCmdDataIn(Cmd10, 10, ADR(Data), SIZE(Data));*)

    (* und Antwort, bitte *)
    IF Ok
      THEN
        BlockAdr := Data[0];
        BlockLen := Data[1];
      END;

    RETURN Ok;

  END ReadCapacity;

END ScsiDisk.
