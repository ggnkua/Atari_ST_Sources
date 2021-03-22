MODULE CopySecs;

(*
 * Kopiert einige Sektoren von einem auf ein anderes Laufwerk.
 *)

(*$E MOS*)
IMPORT GEMDOSIO;

FROM Storage IMPORT ALLOCATE;

FROM SYSTEM IMPORT ADR, ADDRESS;

FROM SysUtil0 IMPORT VarEqual;

FROM BIOS IMPORT DriveMap, DriveSet, RWAbs, BPB, BPBPtr, RW, GetBPB;

FROM InOut IMPORT WriteString, WriteCard, WriteHex, WriteLn,
        GotoXY, WritePg;
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
    k, j, i, bufbls, dblno, sblno, restbls, bls: CARDINAL;
    sec, pc: POINTER TO CARDINAL;


PROCEDURE info (n: CARDINAL);
  BEGIN
    WriteString ('  Drive ');
    WriteString (CHR (n + ORD ('A')));
    WriteString (':');
    WriteLn;
    WriteString ('  Sector Size: ');
    WriteCard (inf[n].clsizb,0);
    WriteString (' Byte');
    WriteLn;
    WriteString ('  No. of Sectors: ');
    WriteCard (inf [n].numcl,0);
    WriteLn;
  END info;


BEGIN
  drives:= DriveMap ();
  WriteLn;
  WriteString ('Copy sectors');
  WriteLn;
  WriteString ('------------');
  WriteLn;
  
  WriteString ('Source drive      (C-P)? ');
  InOut.Read (sd); sd:= CAP (sd);
  IF NOT ( sd IN CharSet {'C'..'P'} ) THEN RETURN END;
  IF NOT ( drvno (sd) IN drives ) THEN RETURN END;
  WriteLn;
  
  WriteString ('Destination drive (C-P)? ');
  InOut.Read (dd); dd:= CAP (dd);
  IF NOT ( dd IN CharSet {'C'..'P'} ) THEN RETURN END;
  IF NOT ( drvno (dd) IN drives ) THEN RETURN END;
  WriteLn;
  
  (*IF sd = dd THEN RETURN END;*)
  sn:= drvno (sd);
  dn:= drvno (dd);
  
  p:= GetBPB (sn);
  IF p = NIL THEN WriteString ('Not online'); InOut.Read (ch); RETURN END;
  inf[sn]:= p^;
  
  p:= GetBPB (dn);
  IF p = NIL THEN WriteString ('Not online'); InOut.Read (ch); RETURN END;
  inf[dn]:= p^;

  WriteLn;
  WriteString ('Source drive: ');
  WriteLn;
  info (sn);

  WriteLn;
  WriteString ('Dest drive: ');
  WriteLn;
  info (dn);
  
  IF inf[sn].clsizb # inf[dn].clsizb THEN
    WriteString ('Both drives must have identical cluster size!');
    InOut.Read (ch);
    RETURN
  END;

  ALLOCATE (sec, inf[sn].clsizb+2);
  
  WriteLn;
  WriteString ('Source start (logical sector)? ');
  InOut.ReadCard (sblno);

  WriteString ('Destination start (logical sector)? ');
  InOut.ReadCard (dblno);
  
  WriteString ('No of sectors? ');
  InOut.ReadCard (bls);
  
  pc:= ADDRESS (sec) + LONG (inf[sn].clsizb);
  pc^:= $1234;
  
  FOR i:= 1 TO bls DO
    GotoXY (0, 20);
    WriteString ('Block: ');
    WriteCard (sblno,5);
    WriteString ('  -> ');
    WriteCard (dblno,5);
    WriteLn;
    l:= RWAbs (Read, sec, 1, sblno, sn);
    IF l # 0L THEN
      WriteLn; WriteString ('Read error!');
      InOut.Read (ch);
      RETURN
    END;
    pc:= sec;
    FOR j:= 1 TO 30 DO
      IF (j MOD 10) # 1 THEN
        WriteString (' ');
      ELSE
        WriteString (' ');
      END;
      WriteHex (pc^, 5);
      IF (j MOD 10) = 0 THEN
        (*
          pb:= ADDRESS(pc) - 20;
          WriteString (' ');
          FOR k:= 1 TO 10 DO
            
          END;
        *)
        WriteLn;
      END;
      INC (pc, 2);
    END;
    InOut.Read (ch);
    IF ch = CHR(27) THEN RETURN END;
    l:= RWAbs (Write, sec, 1, dblno, dn);
    IF l # 0L THEN
      WriteLn; WriteString ('Write error!');
      InOut.Read (ch);
      RETURN
    END;
    INC (sblno);
    INC (dblno)
  END;
  WriteLn;
  WriteString ("OK.");
  InOut.Read (ch);
END CopySecs.
