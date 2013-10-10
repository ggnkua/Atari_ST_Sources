MODULE CmpPart;
(*$E MOS *)

(*
 * Vergleicht zwei Partitions
 *)

FROM SYSTEM IMPORT ADR;

FROM SysUtil0 IMPORT VarEqual;

FROM BIOS IMPORT DriveMap, DriveSet, RWAbs, BPB, BPBPtr, RW, GetBPB;

IMPORT TOSIO;
FROM InOut IMPORT WriteString, WriteCard, WriteLn, GotoXY, WritePg;
IMPORT InOut;


PROCEDURE drvno (c:CHAR): CARDINAL;
  BEGIN
    RETURN ORD (CAP (c)) - ORD ('A')
  END drvno;

TYPE CharSet = SET OF CHAR;

VAR sd, dd: CHAR;
    sn, dn: CARDINAL;
    drives: DriveSet;
    p: BPBPtr;
    inf: ARRAY [0..31] OF BPB;
    ch: CHAR;
    l: LONGINT;
    bufbls, blno, restbls, bls: CARDINAL;

    buf2, buf: ARRAY [1..32768] OF CARDINAL; (* 2 * 64KB *)


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


BEGIN
  drives:= DriveMap ();
  WriteLn;
  WriteString ('Compare partitions');
  WriteLn;
  WriteLn;
  
  WriteString ('First drive  (C-P) ? ');
  InOut.Read (sd); sd:= CAP (sd);
  IF NOT ( sd IN CharSet {'C'..'P'} ) THEN RETURN END;
  IF NOT ( drvno (sd) IN drives ) THEN RETURN END;
  WriteLn;
  
  WriteString ('Second drive (C-P) ? ');
  InOut.Read (dd); dd:= CAP (dd);
  IF NOT ( dd IN CharSet {'C'..'P'} ) THEN RETURN END;
  IF NOT ( drvno (dd) IN drives ) THEN RETURN END;
  WriteLn;
  
  IF sd = dd THEN RETURN END;
  sn:= drvno (sd);
  dn:= drvno (dd);
  
  p:= GetBPB (sn);
  IF p = NIL THEN WriteString ('Not online'); InOut.Read (ch); RETURN END;
  inf[sn]:= p^;
  
  p:= GetBPB (dn);
  IF p = NIL THEN WriteString ('Not online'); InOut.Read (ch); RETURN END;
  inf[dn]:= p^;

  WriteLn;
  WriteString ('First drive: ');
  WriteLn;
  info (sn);

  WriteLn;
  WriteString ('Second drive: ');
  WriteLn;
  info (dn);

  WriteLn;
  WriteString ('Compare (Y/N) ? ');
  InOut.Read (ch);
  IF CAP (ch) <> 'Y' THEN RETURN END;

  blno:= 0;
  restbls:= inf[sn].numcl * inf[sn].clsiz;
  bufbls:= SHORT (SIZE (buf) DIV 1024L) * inf[sn].clsiz; (* =128 *)
  REPEAT
    GotoXY (0, 17);
    WriteString ('Block no. ');
    WriteCard (blno,0);
    WriteLn;
    WriteString ('Compared: ');
    WriteCard (blno DIV inf[sn].clsiz,4);
    WriteString (' KB');
    WriteLn;
    WriteString ('Left    : ');
    WriteCard (restbls DIV inf[sn].clsiz,4);
    WriteString (' KB');
    bls:= bufbls;
    IF bls > restbls THEN bls:= restbls END;
    l:= RWAbs (Read, ADR (buf), bls, blno, sn);
    IF l # 0L THEN
      WriteLn; WriteString ('Read error on source!'); InOut.Read (ch);
      RETURN
    END;
    l:= RWAbs (Read, ADR (buf2), bls, blno, dn);
    IF l # 0L THEN
      WriteLn; WriteString ('Read error on destination!'); InOut.Read (ch);
      RETURN
    END;
    IF NOT VarEqual (buf, buf2) THEN
      WriteLn; WriteString ('Not equal!'); InOut.Read (ch);
      RETURN
    END;
    INC (blno, bls);
    DEC (restbls, bls)
  UNTIL restbls = 0;

END CmpPart.

(* $FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654$FFF38654€$000000DET.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000927$0000099B$00000AD7$00000BCA$0000001E$FFF29BCA$00000475$FFF38654$FFF38654$FFF38654$FFF38654$00000542$0000047F$00000749$00000791$000007DD˜€€*)
