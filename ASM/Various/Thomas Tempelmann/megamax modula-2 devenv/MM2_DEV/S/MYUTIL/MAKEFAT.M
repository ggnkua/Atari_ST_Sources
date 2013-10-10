MODULE MakeFAT;

(*
 * Erzeugt einen Dummy-FAT Sektor (512 Byte), der aufsteigend alle Werte von
 *  $xx00 bis $xxFF enth„lt.
 *)

FROM SYSTEM IMPORT VAL, BYTE, ADR;

FROM SysUtil0 IMPORT VarEqual;

FROM BIOS IMPORT DriveMap, DriveSet, RWAbs, BPB, BPBPtr, RW, GetBPB;

FROM InOut IMPORT WriteString, WriteCard, WriteLn, GotoXY, WritePg;
IMPORT InOut;


PROCEDURE drvno (c:CHAR): CARDINAL;
  BEGIN
    RETURN ORD (CAP (c)) - ORD ('A')
  END drvno;

TYPE CharSet = SET OF CHAR;

VAR sd, dd: CHAR;
    i, hibyte, sn, dn: CARDINAL;
    drives: DriveSet;
    p: BPBPtr;
    inf: ARRAY [0..31] OF BPB;
    ch: CHAR;
    l: LONGINT;
    bufbls, blno, restbls, bls: CARDINAL;

    sec: ARRAY [0..511] OF BYTE;


PROCEDURE info (n: CARDINAL);
  BEGIN
    WriteString ('  Drive ');
    WriteString (CHR (n + ORD ('A')));
    WriteString (':');
    WriteLn;
    WriteString ('  Size: ');
    IF inf[n].clsizb <> 1024 THEN HALT END;
    WriteCard (inf [n].numcl,0);
    WriteString (' KB');
    WriteLn;
  END info;

PROCEDURE swap (VAR a: ARRAY OF BYTE);
  VAR h: BYTE;
  BEGIN
    h:= a[0];
    a[0]:= a[1];
    a[1]:= h
  END swap;
  

BEGIN
  drives:= DriveMap ();
  WriteLn;
  WriteString ('Make FAT Sector');
  WriteLn;
  WriteLn;
  
  WriteString ('Drive (C-P) ? ');
  InOut.Read (sd); sd:= CAP (sd);
  IF NOT ( sd IN CharSet {'C'..'P'} ) THEN RETURN END;
  IF NOT ( drvno (sd) IN drives ) THEN RETURN END;
  WriteLn;
  
  sn:= drvno (sd);
  
  p:= GetBPB (sn);
  IF p = NIL THEN WriteString ('Not online'); InOut.Read (ch); RETURN END;
  inf[sn]:= p^;
  
  WriteLn;
  WriteString ('Info: ');
  WriteLn;
  info (sn);

  WriteLn;
  WriteString ('Hi-Byte ? ');
  InOut.ReadCard (hibyte);

  WriteLn;
  WriteString ('Sector no. ? ');
  InOut.ReadCard (blno);

  FOR i:= 0 TO 255 DO
    sec [i*2]:= VAL (BYTE, i+1);
    sec [i*2+1]:= VAL (BYTE, hibyte)
  END;
  INC (sec [511]);
  
  l:= RWAbs (Write, ADR (sec), 1, blno, sn);
  IF l # 0L THEN
    WriteLn; WriteString ('Write error!'); InOut.Read (ch);
    RETURN
  END;

  WriteLn;
  WriteString ('Sector successfully written');
  InOut.Read (ch);

END MakeFAT.

(* $0000072B$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$0000072D$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F$FFF3912F€$000007A0T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000000A8$0000078F$0000076F$00000779$0000078E$00000217$0000078F$000007AF$000007A0$00000722$00000882$000006E4$000007AF$000002D4$FFF458C4$000002DD¨€€*)
