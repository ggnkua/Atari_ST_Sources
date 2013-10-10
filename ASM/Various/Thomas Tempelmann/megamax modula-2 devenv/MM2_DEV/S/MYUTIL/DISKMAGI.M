MODULE DiskMagic;

(*
 * Tr„gt eine Zufallszahl im 'Magic' des Bootsektors ein.
 *)

FROM SYSTEM IMPORT VAL, BYTE, ADR;

FROM BIOS IMPORT DriveMap, DriveSet, RWAbs, BPB, BPBPtr, RW, GetBPB;

FROM SysUtil1 IMPORT Poke;

FROM RandomGen IMPORT RandomCard;

FROM InOut IMPORT WriteString, WriteCard, WriteLn, GotoXY, WritePg;
IMPORT InOut;


PROCEDURE drvno (c:CHAR): CARDINAL;
  BEGIN
    RETURN ORD (CAP (c)) - ORD ('A')
  END drvno;

TYPE CharSet = SET OF CHAR;

VAR sd: CHAR;
    sn: CARDINAL;
    drives: DriveSet;
    p: BPBPtr;
    inf: BPB;
    ch: CHAR;
    l: LONGINT;


PROCEDURE info (n: CARDINAL);
  BEGIN
    WriteString ('  Drive ');
    WriteString (CHR (n + ORD ('A')));
    WriteString (':');
    WriteLn;
    WriteString ('  Size: ');
    WriteCard (inf.numcl,0);
    WriteString (' KB');
    WriteLn;
  END info;

TYPE Byte3 = ARRAY [1..3] OF BYTE;
VAR buf: ARRAY [0..511] OF BYTE;
    b3: Byte3;

BEGIN
  drives:= DriveMap ();
  WriteLn;
  WriteString ('Randomize "Magic"');
  WriteLn;
  WriteLn;
  
  WriteString ('Drive (A-P) ? ');
  InOut.Read (sd); sd:= CAP (sd);
  IF NOT ( sd IN CharSet {'A'..'P'} ) THEN RETURN END;
  IF NOT ( drvno (sd) IN drives ) THEN
    WriteString ('Not online'); InOut.Read (ch); RETURN
  END;
  WriteLn;
  
  sn:= drvno (sd);
  
  p:= GetBPB (sn);
  IF p = NIL THEN WriteString ('Not online'); InOut.Read (ch); RETURN END;
  inf:= p^;
  
  WriteLn;
  info (sn);

  WriteLn;
  WriteString ('Randomize (Y/N) ? ');
  InOut.Read (ch);
  IF CAP (ch) <> 'Y' THEN RETURN END;

  l:= RWAbs (ReadNoMediaChange, ADR (buf), 1, 0, sn);
  IF l # 0L THEN
    WriteLn; WriteString ('Read error '); InOut.WriteInt (l,0); InOut.Read (ch);
    RETURN
  END;
  l:= LONG (RandomCard (1,MaxCard)) + LONG (MaxCard) * LONG (RandomCard (1,255));
  ASSEMBLER
        MOVE.L  l,D0
        LEA     b3,A0
        MOVE.W  D0,(A0)
        SWAP    D0
        MOVE.B  D0,2(A0)
  END;
  (* mag Compiler nicht:  b3:= VAL (Byte3, l); *)
  Poke (ADR (buf[8]), b3);
  l:= RWAbs (WriteNoMediaChange, ADR (buf), 1, 0, sn);
  IF l # 0L THEN
    WriteLn; WriteString ('Write error '); InOut.WriteInt (l,0); InOut.Read (ch);
    RETURN
  END;

END DiskMagic.

(* $000007F4$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$000007F6$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530$FFF39530€$0000051BT.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000006AD$000006C6$000008A2$00000889$00000566$FFF3CB02$0000051B$000004DC$0000065C$00000837$00000010$000008D3$FFF408D0$FFF408D0$FFF408D0$000001FC°€€*)
