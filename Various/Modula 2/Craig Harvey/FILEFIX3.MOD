MODULE Filefix; (* View/edit disk file contents *)

FROM InOut IMPORT WriteLn, Read, Write, ReadString, WriteString, 
     Done, WriteCard;
FROM FileSystem IMPORT File, Lookup, Response, Close, SetRead,
     SetWrite, Length, GetPos, SetPos,
     ReadChar, WriteChar;
FROM LongInOut IMPORT ReadLongCard, WriteLongCard;
FROM SYSTEM IMPORT ADDRESS, CODE, REGISTER, SETREG, ADR;
 
VAR
  ch1, ch2 : CHAR;
  F1, F2 : File;
  fname, s : ARRAY [0..30] OF CHAR;
  i, j, k : CARDINAL;
  len, pos : LONGCARD;
  ok, dest : BOOLEAN;
  addr, temp : ADDRESS;

PROCEDURE Bconout5(ch : CHAR);
(* 
    Supplements TDI BConOut procedure which is missing final device.
                        For all characters to show, you need sixth 
    device (#5) (see ST Internals p. 246) which is not implemented
    yet in TDI M2, so use BIOS call to bconout (ST Internals p. 144). 
    I never found it specifically stated how to do a move.w #character,
    but from examples in the Abacus Machine Language book, I
    discovered you just repeat the ASCII code for the character 
    twice (once in each byte of the word) to make the immediate 
    mode source data.    
*)
VAR x : CARDINAL; (* word-length version of ch *)
                        
BEGIN
  x:= 256*ORD(ch) + ORD(ch); (* this duplicates the ASCII code twice *)
  addr:= ADR(x);
  temp:= REGISTER(12); (* save contents of A4 *)
  SETREG(12,addr); (* put address of x into A4 *)

                  (* Machine Code    Hex   Assembly Code *)
(* example for 
   single character:
  CODE(16188); (* (0011111100111100) 3F3C move.w #'A',-(sp) *)
  CODE(16705); (* (0100000101000001) 4141 [ch= 'A'  ORD('A')= 65] *)
*)
(* code for getting
  char code from 
  address of x:
*)
  CODE(16151); (* (0011111100010111) 3F17 move.w (A4),-(sp)     *)

  CODE(16188); (* (0011111100111100) 3F3C move.w #5,-(sp) *)
  CODE(5);     (* (0000000000000101)    5 [device #5, full font dev.] *)
  CODE(16188); (* (0011111100111100) 3F3C move.w #3, -(sp) *)
  CODE(3);     (* (0000000000000011)    3 [BIOS function #3, bconout] *)
  CODE(20045); (* (0100111001001101) 4E4D trap #13 [call to BIOS] *)
  CODE(23695); (* (0101110010001111) 5C8F addq.l #6, sp [stack corr.] *)
  
  SETREG(12, temp); (* restore prior contents of A4 *)
END Bconout5;


PROCEDURE Fres(F : File);
VAR s : ARRAY [0..12] OF CHAR;
BEGIN
  CASE F.res OF
    done: s:= "done" |
    notdone: s:= "notdone" |
    notsupported: s:= "notsupported" |
    callerror: s:= "callerror" |
    unknownfile: s:= "unknownfile" |
    paramerror: s:= "paramerror" |
    toomanyfiles: s:= "toomanyfiles" |
    eom: s:= "eom" |
    softerror: s:= "softerror" |
    timeout: s:= "timeout" |
  ELSE s:= "elserror"
  END; (* case *)
  WriteString(s); WriteLn;
END Fres;

  
PROCEDURE GetSource(VAR F : File; VAR ok : BOOLEAN); 
VAR i : CARDINAL;
BEGIN
  WriteLn; WriteLn;
  i:= 0;
  LOOP
    IF i = 3 THEN ok:= FALSE; EXIT END;
    i:= i+1;
    WriteString('Source Filename: ');
    ReadString(fname); WriteLn;
    Lookup(F, fname, FALSE); (* don't create F *)
    Fres(F);
    WriteLn;
    WriteString(s); WriteLn;
    IF F.res <> done THEN WriteString('File not found: ');
      WriteCard(3-i, 1);
      WriteString(' more tries.');
      WriteLn;
      F.res:= done; Close(F); (* resets things, which shouldn't be
                           needed, but is needed *)     
    ELSE EXIT (* file found *)
    END; (* if *)
  END; (* loop *)
END GetSource;


PROCEDURE Showhex(ch: CHAR);
VAR
  dhigh, dlow : CARDINAL;
  
  PROCEDURE Hexchar(x: CARDINAL): CHAR;
  VAR ch : CHAR;
  BEGIN
   CASE x OF
    0 : ch:= '0'|
    1 : ch:= '1'|
    2 : ch:= '2'|
    3 : ch:= '3'|
    4 : ch:= '4'|
    5 : ch:= '5'|
    6 : ch:= '6'|
    7 : ch:= '7'|
    8 : ch:= '8'|
    9 : ch:= '9'|
    10 : ch:= 'A'|
    11 : ch:= 'B'|
    12 : ch:= 'C'|
    13 : ch:= 'D'|
    14 : ch:= 'E'|
    15 : ch:= 'F'|
   END; (* case *)
  RETURN ch;
  END Hexchar;
BEGIN
  dhigh:= ORD(ch) DIV 16;
  dlow:= ORD(ch) MOD 16;
  Write(Hexchar(dhigh));
  Write(Hexchar(dlow));
END Showhex;


PROCEDURE Modify(F: File);
VAR ch1, ch2 : CHAR;
    pos1 : LONGCARD;
BEGIN
  WriteString('Position to modify: ');
  ReadLongCard(pos1);
  SetPos(F, pos1);
  ReadChar(F, ch1);
  WriteString('  That was: ');
  Write(ch1); WriteLn;
  WriteString('Change to (CHAR): ');
  Read(ch2); Write(ch2); WriteLn;
  Close(F);
  SetWrite(F); 
  SetPos(F, pos1);
  WriteChar(F, ch2); Fres(F);
  Close(F); 
  SetRead(F);
END Modify;


BEGIN
  Write(CHR(27)); Write('E'); (* VT52 Clear Home *)
  Write(CHR(27)); Write('e'); (* cursor on *) 
  WriteLn;
  WriteString('Public Domain Disk File Editor created with TDI Modula-2.');
  WriteLn;
  WriteString('  by Craig Harvey, the Clear Thinking BBS: 313-761-2444');
  WriteLn;
  WriteString('This version only allows replacement of single CHARACTERS.');
  WriteLn;
  WriteString('You can use it to fix text typos in object files.');
  WriteLn;
  ok:= TRUE;
  GetSource(F1, ok);
  IF ok THEN
    Length(F1, len);
    WriString('File lllength in bytes: ');
    WriteLongCard(len, 1);
    WriteLn;
    WriteString('Begin at byte # [0]: ');
    ReadLongCard(pos);
    WriteLn;
    IF Done = FALSE THEN pos:= 0 END;
    SetRead(F1);
    SetPos(F1, pos);
    
(*  WriteLn; WriteLn;
    dest:= FALSE; (* don't write to file, just to screen *)
    WriteString(' Write to file as well as screen (Y/N)? ');
    Read(ch1);
    IF CAP(ch1) = 'Y' THEN 
      dest:= TRUE;
      WriteString('Destination Filename: ');
      ReadString(fname); WriteLn;
      Lookup(F2, fname, TRUE); (* create if not there *)
    END; (* if Y *)
    IF dest = TRUE THEN SetWrite(F2);
*)
    WriteString('[ESC] to quit, [M] to modify, any other key to continue...');
    WriteLn; WriteLn;
    WriteString('  POSITION CHAR ASCII HEX'); WriteLn; WriteLn;
    REPEAT
      i:= 0;
      REPEAT (* displays 20 lines at a time *)
        i:= i+1;
        GetPos(F1, pos);
        WriteLongCard(pos, 10);
        WriteString('   ');
        ReadChar(F1, ch1);
        Bconout5(ch1);
        IF ch1 = ' ' THEN Write(CHR(8));
          Write(CHR(8)); WriteString('(s)') END;
        WriteCard(ORD(ch1), 6);
        WriteString('   ');
        Showhex(ch1);
        WriteLn;
      UNTIL (i = 20) OR (pos = len-1);   
      IF pos = len-1 THEN WriteString('[End of File]'); WriteLn END;(*if*)
      Read(ch1);
        IF CAP(ch1) = 'M' THEN
          Modify(F1);
          IF pos < 20 THEN pos:= 20 END;
          pos:= pos-20;
          SetPos(F1, pos);
        END; (* if *)
    UNTIL (pos = len-1) OR (ch1 = CHR(27)); (* ESCape *)
    Close(F1);
  END; (* IF ok *)
  Write(CHR(27)); Write('f'); (* cursor off *) 
END Filefix.
