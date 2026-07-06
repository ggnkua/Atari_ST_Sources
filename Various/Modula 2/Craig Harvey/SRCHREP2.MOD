MODULE SR; (* search/replace w/wildcards *)

FROM InOut IMPORT WriteLn, Read, Write, ReadString, WriteString,
           Done, ReadCard, WriteCard, EOL;
FROM FileSystem IMPORT File, Lookup, Response, Close, SetRead,
                SetWrite, Length, GetPos, SetPos, ReadChar, WriteChar;
FROM GEMDOS IMPORT Delete;
FROM SYSTEM IMPORT ADDRESS, CODE, SETREG, REGISTER, ADR;

CONST fasize = 32000;
      Maxstring = 79;
      strmax = 19;

TYPE FArray = ARRAY [0..fasize] OF CHAR; 
     String = ARRAY [0..Maxstring] OF CHAR;
     Substring = ARRAY [0..strmax] OF CHAR;
     Charset = SET OF CHAR;
     Cards = [0..255];
     Cardset = SET OF Cards;

VAR i, srchlen, replen, flen, pos, start, stop : CARDINAL;
    ch : CHAR;
    fname : String;
    search, repstrg : Substring;
    fa : FArray;
    F1 : File;
    found : BOOLEAN;
    Lcset, Ucset, Alphaset, 
    Numset, Hexset, Wildresp : Charset;
    Wildset : Cardset;
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


PROCEDURE Position(x,y: CARDINAL);
BEGIN  (* VT 52 position cursor *)
  WriteLn;
  Write(CHR(27));
  Write('Y');
  Write(CHR(y+32));
  Write(CHR(x+32));
END Position;

PROCEDURE Cls; (* clear screen *)
BEGIN
  Write(CHR(27)); Write('E');
END Cls;

PROCEDURE Cursrt; (* cursor right *)
BEGIN
  Write(CHR(27)); Write('C');
END Cursrt;

PROCEDURE Invideo;
BEGIN
  Write(CHR(27)); Write('p'); (* inverse video *) 
END Invideo;

PROCEDURE Normvideo;
BEGIN
  Write(CHR(27)); Write('q');
END Normvideo;

PROCEDURE Clrdown;
BEGIN
  Write(CHR(27)); Write('J');
END Clrdown;

PROCEDURE Curson;
BEGIN
  Write(CHR(27)); Write('e');
END Curson;

PROCEDURE Cursoff;
BEGIN
  Write(CHR(27)); Write('f');
END Cursoff;


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

  
PROCEDURE Getsource(VAR F : File; VAR ok : BOOLEAN); 
VAR i : CARDINAL;
    s : ARRAY [0..12] OF CHAR;
BEGIN
  WriteLn;
  i:= 0;
  ok:= TRUE;
  LOOP
    IF i = 3 THEN ok:= FALSE; EXIT END;
    i:= i+1;
    WriteString('Source Filename: ');
    ReadString(fname); WriteLn;
    Lookup(F, fname, FALSE); (* don't create F *)
    Fres(F);
    IF F.res <> done THEN WriteString('File not found: ');
      WriteCard(3-i, 1);
      WriteString(' more tries.');
      WriteLn;
      F.res:= done; Close(F); (* resets things, which shouldn't be
                           needed, but is needed *)     
    ELSE EXIT (* file found *)
    END; (* if *)
  END; (* loop *)
END Getsource;


PROCEDURE Readfile(F1: File; fasize: CARDINAL; VAR flen: CARDINAL;
          VAR fname: String);

VAR i: CARDINAL;
    ch: CHAR;
    
 PROCEDURE Sizecheck;
 BEGIN
  IF i>= fasize THEN
   WriteLn;
   WriteString(' File too big for array.');
   WriteLn
  END (* if i>fasize *)
 END Sizecheck;

BEGIN
 Cls;
 Curson;
 Getsource(F1, found);
 IF (found = FALSE) THEN HALT; END;
 WriteString(' initializing array.');
 FOR i:= 0 TO fasize DO fa[i]:= ' ' END (* for *);
 WriteString(' opening ');
 WriteString(fname);
 WriteLn;
 SetRead(F1);
 WriteString(' reading file into array...');
 i:= 0;
 WHILE NOT F1.eof DO
   ReadChar(F1,ch);
     IF NOT F1.eof THEN fa[i]:= ch; INC(i); END; (* if *)
   IF fasize <> 0 THEN Sizecheck END;
 END; (* While not eof *)
 Close(F1);
 WriteString(' done.');
 flen:= i;
 WriteLn;
 WriteString(' File is ');
 WriteCard(flen,0);
 WriteString(' bytes long.');
 WriteLn;
END Readfile;


PROCEDURE Writefile(flen: CARDINAL; fname : String);
VAR i: INTEGER;
    newfile: String;
    ok : BOOLEAN;
BEGIN
 newfile:= '  ';
 WriteLn;
 WriteString(' Write to filename [Return=same]: ');
 WriteLn; WriteLn;
 WriteString(' ->');
 ReadString(newfile);
 IF newfile[1] = ' ' THEN
   newfile:= fname;
   ok:= Delete(fname);
   IF ok THEN WriteString('deleted')
     ELSE WriteString('oops...'); END; (* if ok *)
 END; (* if *)
 WriteLn;
 WriteString(' Writing to file ');
 WriteString(newfile);
 WriteString('...');
 Lookup(F1, newfile, TRUE); (* create newly *)
 SetWrite(F1);
 FOR i:= 0 TO flen-1 DO
   WriteChar(F1,fa[i]);
 END; (* for *);
 Close(F1);
 WriteLn; WriteLn;
 WriteString(' Done.')
END Writefile;


PROCEDURE Find(strlen,flen: CARDINAL; search: Substring; VAR pos: CARDINAL; VAR found: BOOLEAN);

VAR i: CARDINAL;
    ch: CHAR;

BEGIN
 Cls;
 REPEAT
  i:= 0;
  REPEAT
   ch:= fa[pos+i];
   IF ch = EOL THEN Write('.') END;(* if *)
(* Write(ch); *)
   found:= FALSE;
   IF ch = search[i] THEN found:=TRUE END; (* if *)
   IF ORD(search[i]) IN Wildset THEN (* wildcard check *)
    CASE ORD(search[i]) OF
     191: found:= TRUE| 
     193: IF ch IN Alphaset THEN
           found:= TRUE
          END|
     200: IF ch IN Hexset THEN 
           found:= TRUE
          END|
     206: IF ch IN Numset THEN
           found:= TRUE
          END|
    END (* case *)
   END; (* if *)
   i:= i+1
  UNTIL (found=FALSE) OR (i >= strlen);
  pos:= pos+1
 UNTIL (found = TRUE) OR (pos = flen);
 pos:= pos-1;
END Find;


PROCEDURE Replace(srchlen,replen,pos: CARDINAL; repstrg: Substring; VAR flen: CARDINAL);

VAR i, shift: CARDINAL;
    ch: CHAR;

BEGIN (* note: flen = actual # of bytes in file w/o eof character *)

 IF replen >= srchlen THEN
  shift:= replen - srchlen;
  FOR i:= 0 TO srchlen-1 DO (* replace *) 
   fa[pos+i]:= repstrg[i] END; (* for *)
 ELSE  (* replen < srchlen *)
  shift:= srchlen - replen;
(*  WriteString('shift = ');
  WriteCard(shift,0); *)
  flen:= flen - shift;
  IF replen > 0 THEN
   FOR i:= 0 TO replen-1 DO fa[pos+i]:= repstrg[i] END; (* for *)
  END; (* if *)
(*  WriteString('equal length done, shift = ');
  WriteCard(shift,0); WriteLn; *)
  FOR i:= pos+replen TO flen-1 DO
   fa[i]:= fa[i+shift] END; (* shift left *)
(*  WriteString('shift left done'); WriteLn; *)
(*  FOR i:= 0 TO (shift-1) DO fa[flen+i]:=' ' END; *) (* fill with blanks *)
  fa[flen]:= CHR(0);
  WriteString('blanked out end done'); WriteLn;
 END; (* else replen<srchlen *)
 
 IF replen > srchlen THEN
  WriteLn; WriteLn; WriteLn;
  WriteString('flen = ');
  WriteCard(flen,0); WriteLn;
  flen:= flen + shift;   (* insert *) 
  WriteCard(flen,8);
  IF flen > fasize THEN
    WriteString(' New file is TOO BIG! ') END;
(*  WriteCard(HIGH(fa),8); WriteLn; WriteLn; *)
  FOR i:= flen-1 TO pos+replen BY -1 DO
    fa[i]:= fa[i-shift] END;
(*  WriteString('done shift right = '); WriteCard(shift,0); WriteLn; *)
  FOR i:= 0 TO (shift-1) DO
    fa[pos + srchlen + i]:= repstrg[srchlen + i] END;
(*  WriteString('done insert of extra repstrg'); WriteLn; *)
 END; (* if insert *)
(* WriteString('press any key');
 Read(ch); *)
END Replace;


PROCEDURE Intro;
BEGIN
 Write(CHR(27));Write('E'); (* clr home *)
 WriteLn;
 WriteString(' SEARCH/REPLACE UTILITY');
 WriteLn; WriteLn;
 WriteString(' With WILDCARDS:');
 WriteLn;
 WriteString('   - totally wild');
 WriteLn;
 WriteString('   - alpha-only');
 WriteLn;
 WriteString('   - numeric-only');
 WriteLn;
 WriteString('   - hex-only');
 WriteLn; WriteLn;
 WriteString(' String Length Max = 20 characters.');
 WriteLn; WriteLn;
 WriteString(' File Size Max = 32K');
 WriteLn; WriteLn;
 WriteString('   Written by Craig Harvey');
 WriteLn;
 WriteString(' with Kyan Pascal & TDI Modula-2.');
 WriteLn; WriteLn;
 WriteString(' Hit RETURN'); Read(ch);
END Intro;


PROCEDURE Wildcard(i: INTEGER; VAR ch: CHAR);
VAR a: CHAR;
    j: INTEGER;
    sub: Substring;
BEGIN
 Position(0,13);
 WriteString('<?> General Wildcard (Ascii 0-255)');
 WriteLn;
 WriteString('<A> Alpha Wildcard (A-Z,a-z)');
 WriteLn;
 WriteString('<N> Numeric Wildcard (0-9)');
 WriteLn;
 WriteString('<H> Hex (0-9,A-F)');
 WriteLn;
 Position(16+i,8);
 Write(CHR(8)); (* backspace *)
 REPEAT
   Read(a);
   a:= CAP(a)
 UNTIL a IN Wildresp;
 ch:= CHR(ORD(a)+128);
 Invideo; 
 Position(15+i,8);
 Write(a);
 Normvideo;
 Position(0,13);  (* delete lines *)
 Clrdown;
 Position(15+i,8);
 Cursrt;
END Wildcard; 


PROCEDURE Ascii(i: INTEGER; VAR ch: CHAR);
 (* specify single ascii code to search for *)
VAR x : CARDINAL;
BEGIN
  Position(0,13);
  WriteLn;
  WriteString('ASCII # = ');
  ReadCard(x);
  ch:= CHR(x);
  Position(15+i,8);
  Bconout5(ch);
  Position(0,13);  (* delete lines *)
  Clrdown;
  Position(15+i,8);
  Cursrt;
END Ascii;

PROCEDURE Asciirep(i: INTEGER; VAR ch: CHAR);
 (* specify single ascii code to replace with *)
VAR x : CARDINAL;
BEGIN
  Position(0,17);
  WriteLn;
  WriteString('ASCII # = ');
  ReadCard(x);
  ch:= CHR(x);
  Position(15+i,14);
  Bconout5(ch);
  Position(0,18);  (* delete lines *)
  Clrdown;
  Position(15+i,14);
  Cursrt;
END Asciirep;


PROCEDURE Getsearch(VAR s:Substring; VAR i: CARDINAL);
VAR ch: CHAR;
    j: INTEGER;
BEGIN
 FOR j:= 0 TO 19 DO search[j]:= ' '; END; (* if *)
 Position(2,8);
 WriteString(' SEARCH FOR: --------------------');
 WriteLn; WriteLn;
 WriteString(' <Esc> to choose a wildcard.');
 WriteLn;
 WriteString(' <CTL-A> to specify an ASCII code.');
 WriteLn;
 WriteString(' <Return> when done.');
 Position(14,8);
 Write(' ');
 i:= 0;
 REPEAT
  Read(ch);
  IF ch <> CHR(13) THEN 
          (* simulate loop/exit *) 
   Position(15+i,8);
   IF ch = CHR(27) THEN Wildcard(i,ch); s[i]:= ch (* if *)
   ELSIF ch = CHR(8) THEN s[i]:= CHR(0); i:= i-2; Write(CHR(8)); Write('-');
     Write(CHR(8))  (* if *)
   ELSIF ch = CHR(1) THEN Ascii(i,ch); s[i]:= ch; ch:= '*'
   ELSE Write(ch); s[i]:= ch
   END; (* if *) 
   i:= i+1;
  END (* if not eoln *)
 UNTIL (ch = CHR(13)) OR (i>=20)
END Getsearch;


PROCEDURE Getrepstrg(VAR repstrg:Substring; VAR i: CARDINAL);
VAR ch: CHAR;
    j: INTEGER;
BEGIN
 FOR j:= 0 TO 19 DO repstrg[j]:= ' '; END; (* for *)
 Position(2,13); WriteLn;
 WriteString(' REPLACE WITH: --------------------');
 WriteLn; WriteLn;
 WriteString(' <CTL-A> to specify a single ASCII code.');
 WriteLn;
 WriteString(' <Return> when done.');
 Position(14,14);
 Write(' ');
 i:= 0;
 REPEAT 
  Read(ch);
  IF ch <> CHR(13) THEN
          (* simulate loop/exit *) 
   Position(15+i,14);
   IF ch = CHR(8) THEN repstrg[i]:= CHR(0);
     i:= i-2; Write(CHR(8)); Write('-');
     Write(CHR(8))
   ELSIF ch = CHR(1) THEN Asciirep(i,ch); repstrg[i]:= ch; ch:= '*'
   ELSE Write(ch); repstrg[i]:= ch
   END; (* if *) 
   i:= i+1;
  END; (* if not chr13 *)
 UNTIL (i=20) OR (ch = CHR(13));
END Getrepstrg;


BEGIN
 Hexset:= Charset{'0'..'9','A'..'F','a'..'f'};
 Lcset:= Charset{'a'..'z'};
 Ucset:= Charset{'A'..'Z'};
 Alphaset:= Lcset + Ucset;
 Numset:= Charset{'0'..'9'};
 Wildresp:= Charset{'?','A','N','H'};
 Wildset:= Cardset{191,193,200,206}; (* chr(?,A,H,N, +128) *)
 Normvideo;
 Intro;
 Readfile(F1,fasize,flen,fname);
 Getsearch(search,srchlen);
 Getrepstrg(repstrg,replen);
 Cls;
 WriteLn;
 WriteString(' Search String = ');
 FOR i:= 0 TO 19 DO
   IF ORD(search[i]) IN Wildset THEN
     Invideo;
     Write(CHR(ORD(search[i])-128));
     Normvideo;
   ELSE Bconout5(search[i]);
   END; (* if *) 
 END; (* for *)
 WriteLn;
 WriteString(' Replace String = ');
 FOR i:=0 TO 19 DO
  Bconout5(repstrg[i])
 END; (* for *)
 WriteLn;
 WriteString(' hit RETURN'); Read(ch);
 pos:= 0;
 REPEAT
  Find(srchlen,flen,search,pos,found);
  IF found THEN 
   WriteLn; WriteLn;
   WriteString('FOUND at Position ');
   WriteCard(pos,0);
   Write(':');
   WriteLn; WriteLn;
   IF pos < 150 THEN start:= 0 
    ELSE start:= pos-150 END; (* if *) 
   stop:= pos+srchlen+150;
   IF stop > flen THEN stop:= flen END;
   IF pos > 0 THEN
    FOR i:= start TO pos-1 DO
      IF fa[i] <> CHR(10) THEN Bconout5(fa[i]) END (* if *)
    END; (* for *)
   END; (* if *)
   Invideo;
   FOR i:= pos TO pos+srchlen-1 DO 
     IF fa[i] <> CHR(10) THEN Bconout5(fa[i]) END (* if *)
   END; (* for *)
   Normvideo;
   FOR i:= pos+srchlen TO stop DO
     IF fa[i] <> CHR(10) THEN Bconout5(fa[i]) END (* if *)
   END; (* for *)
   WriteLn; WriteLn;
   WriteString(' Replace it (Y/N)? ');
   Read(ch);
   IF CAP(ch)='Y' THEN
     Replace(srchlen,replen,pos,repstrg,flen) END; (* if *)
   pos:= pos+srchlen;
  ELSE  (* if not found *)
   WriteLn; WriteLn;
   WriteString('No (more) matches found.');
   WriteLn;
  END (* if found *)
 UNTIL pos >= flen-1;
 Writefile(flen,fname);
 Cursoff;
END SR.
