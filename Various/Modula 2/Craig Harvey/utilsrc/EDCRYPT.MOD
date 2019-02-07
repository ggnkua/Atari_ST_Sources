MODULE EDCRYPT; (* To Encrypt a file *)
FROM Mylib IMPORT MoveMem;
FROM GEMDOS IMPORT ConIn, NecIn, ConOut, ConWS, Read, Write, Create, SetPath,
            GetDrv, GetPath, Open, Close, Seek, SeekMode, DFree, 
            OldTerm, DiskInfoBuffer, SFirst;
FROM GEMX IMPORT BasePageAddress; (* was pointer to BasePageType *)
FROM SYSTEM IMPORT CODE, ADR, ADDRESS, REGISTER, SETREG, PUSH;
FROM Strings IMPORT Length, Concat, Assign, Insert;
FROM AESForms IMPORT FormAlert, FileSelectorInput;
FROM AESApplications IMPORT ApplExit, ApplWrite, ApplFind, ApplRead, ApplInitialise;

CONST debug = TRUE;
      ext = '*.*';
 (* Registers *)
  D0 = 0;
  D1 = 1;
  D2 = 2;
  D3 = 3;
  D4 = 4;
  A0 = 8;
  A1 = 9;
  A2 = 10;
  A3 = 11;
  A4 = 12;
  A5 = 13;
  A6 = 14;
  A7 = 15; (* user stack pointer *)

TYPE
     Fseltype = ARRAY[0..100] OF CHAR; (* increased from 60 to 100 1/15/92 *)
     Pathtype = ARRAY[0..88] OF CHAR;
     Fsel0type = ARRAY[0..12] OF CHAR;
     Charset  = SET OF CHAR;

VAR
    ptr1, ptr2:                    POINTER TO CHAR;
    startadr, startadr2, lnptradr, writeadr,
    saveA1, saveA2, saveD1, saveD2, saveD3, saveD4:     ADDRESS;
    adrptr:  POINTER TO ADDRESS;
    longptr: POINTER TO LONGCARD;
    infobuffer:                                              DiskInfoBuffer;
    blocksize, i, j, k, card, startlnrange, endlnrange,
    outdrive, eollen, lastline, maxlines, maxkey:  CARDINAL;
    fieldlen, startcol: ARRAY[0..2] OF CARDINAL;
    ascend:       ARRAY[0..2] OF BOOLEAN;
    ch:                                                         CHAR;
    count, pos, last, heapsize, index:   LONGCARD;
    handle, handle1, handle2, exbutton, int, result, dummy, apid: INTEGER;
    badselect, edbuf, shownames, ok, askfile:                BOOLEAN;
    cardstrg:                                         ARRAY[0..5] OF CHAR;
    eolstrg:          ARRAY[0..2] OF CHAR;
    insel, outsel, fsel:                  Fseltype;
    path, oldpath, temppath:              Pathtype;
    insel0, outsel0, fsel0:               Fsel0type;
    colon, pathmark, bslash:              ARRAY[0..3] OF CHAR;
    Numset : Charset;

        
PROCEDURE CR; (* gemdos carriage return = writeln *)
BEGIN
  ConOut(CHR(13)); ConOut(CHR(10));
END CR;

PROCEDURE Clrdown;
BEGIN
  ConOut(CHR(27)); ConOut('J');
END Clrdown;


PROCEDURE Bconout(ch : CHAR; device: CARDINAL);
(* device 5 = full 255 char set, 0 = PRT, 1 = AUX(RS232), 2 = CON *)
(* 3 = midi, 4 = IKDB *)
VAR x : CARDINAL; (* word-length version of ch *)
BEGIN
  (* movem.l A1-A2/D1-D2,-(SP) *)
  CODE(048E7H, 06060H); (* 0100 1000 1110 0111, 0110 0000 0110 0000 *)
  x:= ORD(ch);
  PUSH(x);
  PUSH(device); (* see if this works ?? It does! *)
  PUSH(3);
  CODE(04E4DH); (* (0100 1110 0100 1101) trap #13 [call to BIOS] *)
  CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
  (* restore all registers used *)
  (* movem.l A1-A2/D1-D2,(SP)+ *)
  CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
END Bconout;

(***)
PROCEDURE Pwr(x, exp: CARDINAL): CARDINAL;
VAR i, y: CARDINAL;
BEGIN
  y:= x;
(*  ConCard(x); ConOut('^'); ConCard(exp); ConOut('='); *)
  IF exp = 0 THEN y:= 1;
  ELSIF exp > 1 THEN
    FOR i:= 2 TO exp DO
      y:= y*x;
    END; (* for *)
  END; (* if *) (* note: if exp=1 then y just stays as x *)
(*  ConCard(y);
  ConIn(a); *) 
  RETURN y;
END Pwr;
(***)

(***)
PROCEDURE Cardtostrg(x: CARDINAL; VAR cardstrg: ARRAY OF CHAR);
VAR i, place: CARDINAL;
    big: BOOLEAN;
BEGIN
  i:= 0;
  big:= FALSE;
  FOR place:= 5 TO 1 BY -1 DO
    IF (x >= Pwr(10, place)) OR big THEN
      cardstrg[i]:= CHR(x DIV Pwr(10, place) + 48);
      x:= x MOD Pwr(10, place);
      big:= TRUE;
      i:= i + 1;
    END; (* if *)
  END; (* for place=5 to 1 *)
  cardstrg[i]:= CHR(x + 48);
  cardstrg[i + 1]:= CHR(0);
END Cardtostrg;
(***)

PROCEDURE LCardtostrg(x: LONGCARD; VAR cardstrg: ARRAY OF CHAR;
                     ishex: BOOLEAN; digits: CARDINAL);
(* modified to do 5 or 6 digits WITH leading zeros as needed *)
(* now should do ANY number of digits, if receiving strg is long enough *)
VAR i, card, ref, place, max, base: CARDINAL;
    y: LONGCARD;
(* big: BOOLEAN; *)
BEGIN
  i:= 0;
  max:= digits - 1;
  base:= 10;
  IF ishex THEN
    base:= 16;
  END;
  FOR place:= max TO 0 BY -1 DO (* 4 for full 5 digits *)
(*
    ConWS(' place: '); ConCard(place); CR;
*)
    y:= LONG(base);
    IF place = 0 THEN y:= 1;
    ELSIF place > 1 THEN
      FOR card:= 2 TO place DO
        y:= y * LONG(base);
      END; (* for *)
    END; (* if *) (* note: if place=1 then y just stays as x *)
    card:= SHORT(x DIV y);
    ref:= 48; (* ORD('0') *)
    IF card > 9 THEN (* A-F *)
      ref:= 55; (* ORD ('A') - ORD('9') + 1 *)
    END;
    cardstrg[i]:= CHR(card + ref);
    x:= x MOD y;
    (* big:= TRUE; *)
    INC(i);
  END; (* for place = 4 to 1 *)
  (* cardstrg[i]:= CHR(SHORT(x) + 48); *)
  cardstrg[i]:= 0C; (* was i+1 *)
END LCardtostrg;


PROCEDURE ConCard(x: CARDINAL);
VAR cardstrg: ARRAY[0..7] OF CHAR;
BEGIN
  Cardtostrg(x, cardstrg);
  ConWS(cardstrg);
END ConCard;


PROCEDURE ConLCard(x: LONGCARD);
VAR cardstrg: ARRAY[0..7] OF CHAR;
BEGIN
  LCardtostrg(x, cardstrg, FALSE, 7);
  ConWS(cardstrg);
END ConLCard;


PROCEDURE Strgtolongc(cardstrg: ARRAY OF CHAR; ishex: BOOLEAN): LONGCARD;
VAR i, ref: CARDINAL;
    x, y, base: LONGCARD;
BEGIN
  x:= 0;
  y:= 0;
  i:= 0;
  base:= 10; (* defaults to decimal *)
(*
  IF cardstrg[0] = '$' THEN (* hex number *)
*)
(**)
  IF ishex THEN
    base:= 16;
  END; (* if hex *)
(**)
  WHILE NOT (cardstrg[i] IN Numset) DO (* skip over leading spaces etc. *)
    INC(i);
  END;
  WHILE cardstrg[i] <> 0C DO
    ref:= 48; (* ORD('0'); *) (* default to decimal *)
    IF cardstrg[i] >= 'A' THEN (* change to hex A-F base *)
      ref:= 55; (* ORD('A') - 10; *)
    END; (* if hex *)
    y:= LONG(ORD(cardstrg[i]) - ref);
    x:= x * base + y;
    INC(i);
  END; (* while *)
  RETURN x;
END Strgtolongc;


PROCEDURE Conrs(VAR strg: ARRAY OF CHAR); (* my own ConRS *)
VAR i: CARDINAL;
    ch: CHAR;
BEGIN
  i:= 0;
  LOOP (* until CR *)
    NecIn(ch);
    CASE ORD(ch) OF
      13: strg[i]:= 0C; (* CR *)
          EXIT; |
      27: strg[0]:= ch; (* Esc *)
          strg[1]:= 0C;
          EXIT; |
       8: IF i > 0 THEN (* Backspace *)
            DEC(i);
            strg[i]:= 0C; 
            ConOut(CHR(8));
            ConOut(' ');
            ConOut(CHR(8));
(*
          ELSE (* i <= 0 *)
            ConOut('>');
*)
          END; (* if *) |
    ELSE
      ConOut(ch);
      strg[i]:= CAP(ch);
      INC(i);
      IF i >= HIGH(strg) THEN
        strg[i]:= 0C;
        EXIT;
      END;
    END; (* case *)
  END; (* loop *)
END Conrs;


PROCEDURE Compare(strg1, strg2: ARRAY OF CHAR): BOOLEAN;
VAR i: CARDINAL; (* for exact match only *)
    first: BOOLEAN;
BEGIN
  first:= TRUE;
  i:= 0;
  REPEAT
    IF NOT first THEN
      INC(i);
    END;
    IF CAP(strg1[i]) <> CAP(strg2[i]) THEN
      RETURN FALSE;
    END; (* if *)
    first:= FALSE;
  UNTIL strg1[i] = 0C;
  RETURN TRUE;
END Compare;
  
(*
PROCEDURE CompareSubj(strg1, strg2: ARRAY OF CHAR): BOOLEAN;
VAR i, j: CARDINAL; (* strg1 is the desired search strg *)
BEGIN
  i:= 0;
  j:= 0;
  WHILE strg2[j+i] <> 0C DO
    WHILE (strg1[i] <> 0C) AND (CAP(strg1[i]) = CAP(strg2[j+i])) DO
      INC(i);
    END; (* while matching *)
    IF strg1[i] = 0C THEN RETURN TRUE;
    ELSIF strg2[j+i] = 0C THEN RETURN FALSE;
    END; (* if matched thru all of strg1 *)
    INC(j);
    i:= 0;
  END; (* while not at end of strg2 *)
  RETURN FALSE;
END CompareSubj;
*)

PROCEDURE Cls;
BEGIN
  ConOut(CHR(27)); ConOut('E'); (* Cls *)
END Cls;
   
PROCEDURE Init;
BEGIN
  CODE(0A00AH); (* lineA Hide mouse *)
  Cls;
  ConOut(CHR(27)); ConOut('v'); (* line wrap *)
  eolstrg[0]:= 15C; (* CR *)
  eolstrg[1]:= 12C; (* LF *)
  eolstrg[2]:= 0C;
  eollen:= 2;
  Numset:= Charset{'0'..'9'};
(* Get full current path for *.* *)
  fsel0:= ''; (* was empty *)
  colon:= ' : ';
  pathmark:= ':\';
  bslash:= '\';
  GetDrv(j); (* 0=A, 1=B,... *)
  ch:= CHR(65 + j); (* 65 = 'A' *)
  temppath[0]:= ch; temppath[1]:= 0C; (* A *)
  Concat(temppath, pathmark, oldpath); (* gives A:\ *)
  GetPath(path, 0); (* 0=current drive, but doesn't give drive or last \ *)
  IF path[0] <> 0C THEN (* there's something there *)
    oldpath[2]:= 0C; (* get rid of '\' before adding another one *)
    Concat(oldpath, path, temppath); (* gives A:\path *)
    Concat(temppath, bslash, path); (* gives A:\path\ *)
  ELSE
    path:= oldpath; (* Strings.Assign(path, oldpath); *)
  END; (* if subdirectory/folder *)
(**
  temppath:= '*.*';
  Strings.Concat(path, temppath, oldpath); (* gives e.g., A:\path\*.DRY *)
**)
END Init;


PROCEDURE Selectfiles(): BOOLEAN;
BEGIN
  IF askfile THEN (* not passed filename in command tail *)
    Cls;
    ConWS(" Find BACKUP? of source file:");
    CR;
    i:= 0;
    result:= 0;
    LOOP
      IF i = 3 THEN 
        RETURN FALSE;
        EXIT 
      END; (* if not ok *)
      i:= i+1;
      ConWS('Source Filename: ');
      IF NOT Fselect(path, insel, insel0) THEN
        RETURN FALSE;
      END;
      SFirst(insel, 0, result);
      IF result < 0 THEN 
        ConWS('Error finding file: ');
        ConWS(insel);
        ConWS(' ; ');
        ConCard(3-i);
        ConWS(' more tries.');
        CR;
      ELSE ConWS('found'); CR;
        EXIT (* file found *)
      END; (* if *)
    END; (* getsource loop *)
  END; (* if askfile *)

(* select output file *)
  LOOP
    Cls;
    ConWS(' Now Select OUTPUT File'); CR;
    IF NOT Fselect(path, outsel, outsel0) THEN
      RETURN FALSE;
    END;
    SFirst(outsel, 0, result);
    IF result = 0 THEN (* that file exists *)
      ConWS(' File already exists, Overwrite? (y/N) ');
      ConIn(ch); CR;
      IF CAP(ch) = 'Y' THEN
        EXIT;
      END;
    ELSE
      EXIT; (* no conflict *)
    END; (* if outsel exists *)
  END; (* outsel loop *)
  RETURN TRUE;
END Selectfiles;


PROCEDURE Fselect(VAR wantpath: Pathtype; VAR fseltmp: Fseltype;
          VAR fsel0ret: Fsel0type): BOOLEAN;
(* always returns new path in tmp global variable 'path' with final \ *)
(* carename = TRUE => return false if filename is null *)
VAR (* fsel0tmp: Fsel0type; *)(* so if cancel, filename won't change *)
    j: CARDINAL; (* to hold length of path, 2.30 1/12/92 *)
    result: INTEGER; (* 2.30 1/12/92 *)
BEGIN
  Concat(wantpath, ext, path);
(*
  fsel0ret:= cfg.fsel0;
*)
  fsel0ret:= ''; (* force new file choice *)
(**
  mresetptr^:= 0; (* reset flag *) (* test 1/20/92?? *)
**)
  CODE(0A009H); (* lineA Show mouse *)
  FileSelectorInput(ADR(path), ADR(fsel0ret), result);
  CODE(0A00AH); (* lineA Hide mouse *)

  (* strip wildcards & filename so setpath works *)
  j:= Length(path); (* was -1, but stripped for safety *)
  WHILE (path[j] <> '\') AND (j > 0) DO
    path[j]:= 0C;
    DEC(j);
  END; (* while *)
  IF result = 0 THEN (* CANCEL *)
    RETURN FALSE;
  ELSIF (fsel0ret[0] = 0C) THEN (* need some filename *)
    CODE(0A009H); (* lineA Show mouse *)
    dummy:= FormAlert(1,'[1][No Filename selected][ OK ]');
    CODE(0A00AH); (* lineA Hide mouse *)
    RETURN FALSE;
  END; (* if cancel or no filename *)
(*
  IF newfile THEN
    cfg.fsel0:= fsel0ret;
  END; (* if newfile *)
*)
  wantpath:= path;
  Concat(path, fsel0ret, fseltmp);
  RETURN TRUE;
END Fselect;


PROCEDURE Makespace(): BOOLEAN;
VAR i: CARDINAL;
    tmplong: LONGCARD;
BEGIN
  Open(insel, 0, handle1);
  IF (handle1 < 0) THEN
    ok:= Close(handle1);
    ConWS('Source file did not open properly. Please check disk');
    ConIn(ch);
    RETURN FALSE;
  END;
  Seek(0, handle1, end, pos);
  last:= pos; (* length of file *)
  ok:= Close(handle1);
  ConWS(' File Size: '); 
  ConLCard(last); CR;
  tmplong:= last DIV 8;
  IF tmplong > 0FFFFH THEN
    tmplong:= 0FFFFH;
  END;
  maxlines:= SHORT(tmplong);
  heapsize:= last + (LONG(maxlines) * 4) + 2; (* 4 bytes per pointer *)
(****
  IF NOT Compare(outsel, insel) THEN
    ConWS('Checking output disk free space...'); CR; CR;
    IF outsel[1] = ':' THEN
      outdrive:= ORD(outsel[0]) - 64; (* drive A = 1, B = 2, etc. *)
    ELSE
      outdrive:= 0;
    END; (* if *)
  END; (* if outsel <> insel *)
  DFree(infobuffer, outdrive);
  IF infobuffer.freeSpace < last THEN
    ConWS('Not enough room on output disk... press a key to abort');
    ConIn(ch);
    OldTerm(); (* terminate program *)
  END; (* if free space too small *)
****) 
  ConWS('Creating record space ');
(***
  heapsize:= last + PTRSPACE; (* record space + other *)
  maxlines:= PTRSPACE DIV 4; (* 5000 *)
  IF NOT CreateHeap(heapsize, TRUE) THEN
    ConWS(' Not enough RAM'); CR;
  END; (* if *)
  NEW(ptr1);
  startadr:= ADDRESS(ptr1);
***)
    (* find largest free ram block *)
    (* save registers *)
    CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
    PUSH(LONGINT(-0001H)); (* to get largest free ram block *)
    PUSH(048H); (* malloc code *)
    CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
    CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
    (* restore all necessary registers *)
    (* movem.l A1-A2/D1-D2,(SP)+ *)
    CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
    tmplong:= LONGCARD(REGISTER(D0));
(**)
    IF tmplong > heapsize THEN
      (* grab desired ram *)
      (* save registers *)
      CODE(048E7H, 06060H); (* movem.l A1-A2/D1-D2,-(SP) *)
      PUSH(heapsize); (* to grab ram block for file bytes only *)
      PUSH(048H); (* malloc code *)
      CODE(04E41H); (* (0100 1110 0100 0001) trap #1 [call GEMDOS] *)
      CODE(05C8FH); (* (0101 1100 1000 1111) addq.l #6, sp [stack corr.] *)
      (* restore all necessary registers *)
      (* movem.l A1-A2/D1-D2,(SP)+ *)
      CODE(04CDFH, 00606H); (* 0100 1100 1101 1111, 0000 0110 0000 0110 *)
      (* set startadr to beginning of block *)
      startadr:= REGISTER(D0);
(**
      lnptradr:= startadr + ADDRESS(buffsize); (* start of lnptrarray *)
      longptr:= lnptradr;
      longptr^:= 0; (* needed for initial setfoundpos! *)
**)
(**)
    ELSE (* no room *)
      CODE(0A009H); (* lineA Show mouse *)
      dummy:= FormAlert(1,'[3][Not enough free RAM][ OK ]');
      CODE(0A00AH); (* lineA Hide mouse *)
      RETURN FALSE;
    END; (* if enough ram *)
(**)
  CR;
  RETURN TRUE;
END Makespace;


PROCEDURE Readfile;
VAR lines, j: CARDINAL;
BEGIN
  CR; CR;
(**
  j:= 0; (* i counts original file entries, j counts packed entries *)
**)
  ConWS('Reading source file...'); CR;
  ConWS(insel);

  Open(insel, 0, handle1);
  Seek(0, handle1, beginning, pos);
  Read(handle1, last, startadr); (* read whole file into buffer *)
  lnptradr:= startadr + ADDRESS(last + 2); (* immediately follows file text *)
  lnptradr:= ADDRESS((LONGCARD(lnptradr) DIV 2) * 2); (* get even address *)

  IF Close(handle1) THEN (* Close Source file *)
    ConWS(' closed.');
  END; (* if *)
  CR;
END Readfile;


(*ds*)
PROCEDURE Encrypt(): BOOLEAN;
VAR j, k, pwlen: CARDINAL;
    tmplong: LONGCARD;
    pw: ARRAY[0..20] OF CHAR; (* Substrg; *) (* password *)
    result: INTEGER;
    chptr: POINTER TO CHAR;
    getnew: BOOLEAN;
BEGIN (* main encrypt *)
(****
  CODE(0A009H); (* lineA Show mouse *)
  dummy:= FormAlert(1,'[3][Do Not Encrypt if|File bigger than buffer|or will Append][OK|Cancel]');
  CODE(0A00AH); (* lineA Hide mouse *)
  IF dummy = 2 THEN
    RETURN FALSE;
  END;
****)
  pw[0]:= 0C; (* init *)
(****
  InitObjStrg(TEXTTREE, TEXTSTRG, pw);
  InitObjStrg(TEXTTREE, TEXT1, 'ENCRYPT/DECRYPT BUFFER');
  InitObjStrg(TEXTTREE, TEXT2, 'Enter your password:');
  getnew:= TRUE;
  pwlen:= GetStrg(pw, getnew, FALSE); (* disable hex/dec buttons *)
  IF (pwlen = 0) OR (pwlen = 0FFH) THEN (* cancelled or zero length strg *)
    RETURN FALSE;
  END;
  (* encrypt password so run of spaces doesn't reveal it *)
*****)
  CR;
  ConWS(' Enter Password (max 20 chars, Esc Quits)'); CR;
  ConOut('>');
  Conrs(pw); CR;
  IF pw[0] = 33C THEN (* escape *)
    RETURN FALSE;
  END;
  pwlen:= Length(pw);
  ConWS( 'Encrypting...'); CR;
  j:= 0;
  WHILE j < pwlen DO
    pw[j]:= CHR(CARDINAL( BITSET(ORD(pw[j])) / BITSET(60) ));
    (* 60 just for the heck of it *)
    INC(j);
  END; (* while *)
  (* now encrypt buffer using encrypted password *)
  tmplong:= 0;
  chptr:= startadr;
  LOOP (* WHILE j <= last DO *)
    k:= 0;
    WHILE k < pwlen DO
      chptr^:= CHR(CARDINAL( BITSET(ORD(chptr^)) / BITSET(pw[k]) ));
      (* char XOR pw; = union - intersection = symmetric difference *)
      IF tmplong >= last THEN
        EXIT;
      END;
      INC(tmplong);
      INC(k);
      INC(chptr);
    END; (* while *)
  END; (* loop *)
(**
  Lineptrs(0);
  MiniInit; (* sets i = 0, etc. *)
  saved:= FALSE;
  Display(0, cfg.maxdispline);
  SetSlideSize;
  SetSlidePos;
**)
  RETURN TRUE;
END Encrypt;
(*ds*)


PROCEDURE Writesorted;
VAR i, key: CARDINAL;
    j: INTEGER;
    tmplong: LONGCARD;
    longptr: POINTER TO LONGCARD;
    tmpstrg: ARRAY[0..25] OF CHAR;
BEGIN
  ConWS('Writing encrypted file ');
  ConWS(outsel); ConWS(' ...'); CR;
  Create(outsel, 0, handle2); (* also opens it *)
(****
  longptr:= lnptradr;
  FOR i:= 0 TO lastline - 1 DO
    tmplong:= longptr^;
    writeadr:= startadr + ADDRESS(tmplong);
    INC(longptr, 4);
    count:= Getlen(i); (* length of line *)
    IF shownames & (i >= startlnrange) & (i <= endlnrange) THEN
      ConCard(i+1);
      FOR key:= 0 TO maxkey DO
        ConWS('  ');
        ptr1:= writeadr + ADDRESS(startcol[key]);
        FOR j:= 0 TO fieldlen[key]-1 DO
          tmpstrg[j]:= ptr1^;
          INC(ptr1);
        END; (* for *)
        INC(j);
        tmpstrg[j]:= 0C;
        ConWS(tmpstrg);
      END; (* for keys *)  
      CR;
    END; (* if show *)
(**
    ConCard(i);
    ConWS('  ');
    ConCard(SHORT(tmplong)); CR; (* offset of line start *)
    ConWS('  ');
    ConCard(SHORT(count)); CR; (* length of line *)
**)
    Write(handle2, count, writeadr);
  END; (* for 0 to maxfiles-1 *)
****)
  Create(outsel, 0, handle2); (* also opens it *)
  Write(handle2, last, startadr);
  ConWS('Done writing encrypted file.'); CR;
END Writesorted;


PROCEDURE GetParams(): BOOLEAN;
(* true if got cmdtail from parent program or shell *)
VAR tmpadr: ADDRESS;
    longptr: POINTER TO LONGCARD;
    cardptr: POINTER TO CARDINAL;
    cmdfilelen: CARDINAL;
    cardstrg, lcardstrg: ARRAY[0..8] OF CHAR;
(*
    ptr1: POINTER TO CHAR;
*)
BEGIN
  ptr1:= ADDRESS(BasePageAddress) + ADDRESS(128);
  ok:= TRUE;
  edbuf:= FALSE;
  IF ptr1^ <> 0C THEN
(**
    ConWS(' CmdTail: ');
**)
    j:= ORD(ptr1^);
    cmdfilelen:= j;
    i:= 0;
    LOOP
      INC(ptr1);
      fsel[i]:= ptr1^;
(*
      lcardstrg[i]:= ptr1^;
*)
(**
      Bconout(ptr1^, 5);
**)
      DEC(j);
      INC(i);
      IF i = 2 THEN
        IF (fsel[0] = 'C') & (fsel[1] = 'T') THEN (* is CTutil *)
          i:= 0;
          edbuf:= TRUE;
        END; (* if CT *)
      END; (* if i=2 *)
      IF j <= 0 THEN
        EXIT;
      END;
    END; (* loop *)
    fsel[i]:= 0C;
(**
    ConWS('< press a key');
    CR;
    ConIn(ch);
**)
    CR;

   IF edbuf THEN (* convert passed string to address *)
    MoveMem(ADR(fsel), ADR(lcardstrg), 8);
    ptr1:= ADDRESS(Strgtolongc(lcardstrg, FALSE));
(****
    LCardtostrg(LONGCARD(ptr1), lcardstrg, FALSE, 7);
    ConWS(' Returned from lcardtostrg'); CR;
    j:= 7;
    i:= 0;
    LOOP
      Bconout(lcardstrg[i], 5);
      INC(i);
      IF i >= j THEN
        EXIT;
      END;
    END;
    CR;
****)
    longptr:= ADDRESS(ptr1) + ADDRESS(6); (* skip lenchar & filename *)
    IF longptr^ <> 0 THEN
      ConWS(' ** Received Edit Plus buffer info **'); CR;
      startadr:= ADDRESS(longptr^); (* startadr other than this prg's *)
(****
    LCardtostrg(LONGCARD(startadr), lcardstrg, FALSE, 7);
    ConWS(' startadr ');
    j:= 7;
    i:= 0;
    LOOP
      Bconout(lcardstrg[i], 5);
      INC(i);
      IF i >= j THEN
        EXIT;
      END;
    END;
    CR;
****)

      INC(longptr, 4);
      lnptradr:= ADDRESS(longptr^); (* lnptradr of parent prg *)
(****
    LCardtostrg(LONGCARD(lnptradr), lcardstrg, FALSE, 7);
    ConWS(' lnptradr ');
    j:= 7;
    i:= 0;
    LOOP
      Bconout(lcardstrg[i], 5);
      INC(i);
      IF i >= j THEN
        EXIT;
      END;
    END;
    CR;
****)
      INC(longptr, 4);
      last:= longptr^;
(****
    LCardtostrg(last, lcardstrg, FALSE, 7);
    ConWS(' last ');
    j:= 7;
    i:= 0;
    LOOP
      Bconout(lcardstrg[i], 5);
      INC(i);
      IF i >= j THEN
        EXIT;
      END;
    END;
    CR;
****)
      INC(longptr, 4);
      cardptr:= ADDRESS(longptr);
      lastline:= cardptr^;
(****
    Cardtostrg(lastline, lcardstrg);
    ConWS(' lastline ');  ConCard(lastline);
(**
    j:= 7;
    i:= 0;
    LOOP
      Bconout(lcardstrg[i], 5);
      INC(i);
      IF i >= j THEN
        EXIT;
      END;
    END;
**)
    ConWS('< press a key');
    CR;
    ConIn(ch);
****)

(**
      INC(longptr, 2);
      buffsize:= longptr^; (* total buffer size from EdHak *)
**)
      edbuf:= TRUE;
    ELSE
      ConWS('No parameters found'); CR;
    END; (* if params exist *)
   ELSE (* something other than CT util parameters passed, i.e., filespec *)
     ptr1:= ADR(fsel);
     ok:= PassedFile(cmdfilelen, TRUE); (* FALSE = don't load it *)
   END; (* if CT util params *)
  ELSE
    RETURN FALSE; (* no fname or params passed *)
  END; (* if any command tail *) 
  RETURN TRUE;
END GetParams;


PROCEDURE PassedFile(max: CARDINAL; doload: BOOLEAN): BOOLEAN;
(* passed prg filespec as address in msgpipe or in basepage *)
(* max is max length of filespec string = maxindex + 1 *)
(* ptr1 points to filespec *)
BEGIN
  j:= 0;
  k:= 0;
  WHILE (ptr1^ > 40C) & (j < max) DO (* xfer to fsel *)
(**
    ConOut(ptr1^);
**)
    insel[j]:= ptr1^;
    INC(j);
    IF ptr1^ = '\' THEN (* to set cfg.oldpath length *)
      k:= j;
    END;
    INC(ptr1);
  END; (* while *)
  insel[j]:= 0C;
  (* INC(k); *) (* k becomes length of path part of string *)
  (* set cfg.oldpath *)
  IF k > 0 THEN (* includes more than filename, e.g. F:\ *)
    MoveMem(ADR(insel), ADR(path), LONG(k));
    path[k]:= 0C;
  END; (* if also passed drive\path, else leave as was *)
  (* set fsel0 *)
  DEC(j, k);
  MoveMem(ADR(insel) + ADDRESS(k), ADR(insel0), LONG(j));
  insel0[j]:= 0C;
  (** Use this if want to actually load the file into buffer **)
  ok:= TRUE;
(*** DEBUG ***
    cfg.macro[1]:= '[1][>';
    Concat(cfg.macro[1],insel,cfg.macro[2]);
    cfg.macro[1]:= '<][ OK ]';
    Concat(cfg.macro[2], cfg.macro[1], cfg.macro[3]);
    CODE(0A009H); (* lineA Show mouse *)
    dummy:= FormAlert(1, cfg.macro[3]);
    CODE(0A00AH); (* lineA Hide mouse *)
*** end debug ***)
(***
  IF doload THEN
    CODE(0A00AH); (* lineA Hide mouse *) (* in case of failed load *)
    ok:= LoadFile(fsel, FALSE); (* don't allow display yet *)
    CODE(0A009H); (* lineA Show mouse *)
  END; (* if doload *)
  RETURN ok; (* false if canceled from loadfile *)
***)
  askfile:= FALSE;
  RETURN TRUE;
END PassedFile;


PROCEDURE Main(): BOOLEAN;           
BEGIN (* main *)
  IF NOT edbuf THEN
    IF NOT Selectfiles() THEN
      RETURN FALSE;
    END; (* if *)
    CR;
    IF NOT Makespace() THEN (* creates proper space for records *)
      RETURN FALSE;
    END;
    Readfile;
(****
    Lineptrs(0);
****)
  END; (* if not edbuf *)
(****
  IF NOT GetKeyField() THEN
    RETURN FALSE;
  END;
****)
  IF NOT Encrypt() THEN
    RETURN FALSE;
  END;
(****
  j:= 0; (* recursion counter *)
  Sortsection(startlnrange, endlnrange); (* call recursive Quicksort routine *)
  CR;
  IF (NOT Movesorted() ) & (NOT edbuf) THEN (* sorts to tmp ram buffer *)
****)
  IF NOT edbuf THEN
    Writesorted; (* sorts directly to disk file *)
  END;      
  CR;
  ConWS('All Done!  ');
(****
  ConCard(endlnrange-startlnrange+1); ConWS(' lines sorted.'); CR;
****)
  IF NOT edbuf THEN
    ConWS('Done writing encrypted file.'); CR;
    IF Close(handle2) THEN (* close new file *)
      ConWS(outsel); 
      ConWS(' closed.'); CR;
    END; (* if to file *)
  END; (* not edbuf *)
(*
  ConOut(CHR(27)); ConOut('E'); (* Clear Home *)
*)
  CR;
  ConWS('Press any key ');
  NecIn(ch);
  RETURN TRUE;
END Main;

BEGIN
(*
  apid:= ApplInitialise();
*)
(*** check if passed info in command tail ***)
  askfile:= TRUE;
  Init;
  IF GetParams() THEN
  END;
  CR;
  ConWS(' EDCRYPT v 0.9  Encrypts a file'); CR;
  ConWS(' & can work directly with Edit Plus'); CR;
  CR;
(****
  ConWS(' Max 65535 lines, 65535 columns '); CR;
  ConWS('    Up to 3 key sort fields'); CR;
  ConWS(' (each Ascending or Descending)'); CR;
  CR;
  ConWS('In this unregistered version, all lines'); CR;
  ConWS('must end in CR/LF but lengths may vary.'); CR;
  CR;
****)
  ConWS(' SHAREWARE: $5 Please.'); CR;
  CR;
  ConWS(' Copyright (c) 1994 by Craig A. Harvey'); CR;
  ConWS(' Clear Thinking'); CR;
  ConWS(' 2753 Plymouth Rd., Suite 137'); CR;
  ConWS(' Ann Arbor, MI  48105  USA'); CR;
  ConWS(' 313-971-8671    BBS: 313-971-6035'); CR;
  CR;
  ConWS(' (created with TDI Modula-2)'); CR;
  CR;
  ch:= 'Y';
  IF NOT askfile THEN
    ConWS(' Source file: ');
    ConWS(insel); CR;
    CR;
  END;
  IF NOT edbuf THEN
    ConWS(' Press Any Key to begin     Q to Quit');
    ConIn(ch); CR;
  END;
  IF CAP(ch) <> 'Q' THEN
    IF Main() THEN 
    END; (* if *)
  END;
  CODE(0A009H); (* lineA Show mouse *)
(*
  ConWS(' Exiting...'); CR;
*)
(*
  ApplExit;
*)
END EDCRYPT.

