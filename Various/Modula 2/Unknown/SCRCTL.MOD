IMPLEMENTATION MODULE ScrCtl;
(*      Copyright 1986 by Ron Sprunger
        Permission is granted for all uses except re-distribution
        to third parties.  Please contact me on BIX (BIX name sprung)
        with any bug fixes or suggestions.

        Note that the implementation module initializes the monochrome
        screen to white-on-black with no wrap.  Other users might wish
        to change this.
*)

FROM Terminal   IMPORT  Write, WriteString, Read;
FROM Strings    IMPORT  Delete, Insert, Length, InitStringModule;

PROCEDURE eseq(c : CHAR);       (* write escape sequence to screen *)
BEGIN                           (* this is utility routine within module *)
  Write(CHR(27));
  Write(c);
END eseq;

PROCEDURE gotoxy(x,y : INTEGER);        (* cursor to col x, row y *)
BEGIN                                   (* corner is 1,1 *)
  eseq("Y");
  Write(CHR(y+31));
  Write(CHR(x+31));
END gotoxy;

PROCEDURE clrscr;                       (* home cursor, clear screen *)
BEGIN
  eseq("E");
END clrscr;

PROCEDURE clreol;               (* clear from cursor to end of line *)
BEGIN
  eseq("K");
END clreol;

PROCEDURE clreos;               (* clear from cursor to end of screen *)
BEGIN
  eseq("J");
END clreos;

PROCEDURE con;                  (* turn cursor on *)
BEGIN
  eseq("e");
END con;

PROCEDURE coff;                 (* turn cursor off *)
BEGIN
  eseq("f");
END coff;

PROCEDURE savcurs;              (* save cursor position *)
BEGIN
  eseq("j");
END savcurs;

PROCEDURE rstcurs;              (* place cursor at saved position *)
BEGIN
  eseq("k");
END rstcurs;

PROCEDURE rvon;                 (* start reverse video *)
BEGIN
  eseq("p");
END rvon;

PROCEDURE rvoff;                (* end reverse video *)
BEGIN
  eseq("q");
END rvoff;

PROCEDURE clr24;                (* clear first 24 lines only *)
BEGIN
  gotoxy(80,24);
  eseq("d");
  eseq("H");                    (* home cursor *)
END clr24;

PROCEDURE bell(n : CARDINAL);   (* ring bell n times *)
VAR     i,t     : CARDINAL;
BEGIN
  t := n;
  WHILE (t > 0) DO
    Write(CHR(7));
    DEC(t);
    IF (t>0) THEN
      FOR i := 1 TO 40000 DO; END;
    END;
  END;
END bell;

PROCEDURE msg(VAR s : ARRAY OF CHAR;cd : CARDINAL);
VAR
        ch      : CHAR;
        l       : CARDINAL;
BEGIN
  l := 0;                       (* length of display *)
  savcurs;coff;                 (* save cursor pos and turn curs off *)
  gotoxy(1,25);clreol;rvon;     (* clear out bottom line *)
  IF (cd IN {2..5}) THEN        (* BELL requested? *)
    Write(CHR(7));
  END;
  IF (cd = 5) THEN
    WriteString("Fatal "); l := 6;
  END;
  IF (cd IN {4,5}) THEN
    WriteString("Error: "); INC(l,7);
  END;
  IF (HIGH(s) > 54-l) THEN s[54-l] := 0C; END;  (* assure fit on line *)
  WriteString(s);rvoff;WriteString(" .. ");
  IF (cd IN {3..5}) THEN
    WriteString("Any Key to Continue..");
    con;
    Read(ch);                   (* wait for response *)
    coff;
    gotoxy(1,25);clreol;
  END;
  IF (cd = 5) THEN              (* fatal error? *)
    con;                        (* turn cursor on *)
    HALT;                       (* and quit *)
  END;
  rstcurs;                      (* put cursor back where found *)
END msg;

PROCEDURE input(x,                              (* screen x-coord *)
                y,                              (* screen y-coord *)
                maxl,                           (* maximum chars  *)
                clrl    : CARDINAL;             (* length to clear *)
                VAR s   : ARRAY OF CHAR;        (* string to fill *)
                typ     : CARDINAL;             (* input type   *)
                spac    : fstrip;               (* strip, fill, leave spaces? *)
                ctlc,                           (* allow ctlc abort? *)
                quick,                          (* require CR?    *)
                ctlchars,                       (* allow ctl chars? *)
                echo    : BOOLEAN;              (* echo input? *)
                VAR tch : CHAR;                 (* input terminator *)
                VAR tabnam
                        : ARRAY OF CHAR;        (* name of table .tab file *)
                tablen  : CARDINAL);            (* tab description length *)
(* MODS:
        08/29/86 - rms : modify parm list for complete spec
        07/16/86 - rms : add typ and tch parms
        07/16/86 - rms : add spac (strip,fill,leave) parameter, and quick
                         also fix init to zero HIGH characters
*)
TYPE
        chset   = SET OF CHAR;

CONST   CR      = 15C;                  (* carriage return to exit *)
        bs      = 10C;                  (* ^H to del back one *)
        bw      = 1C;                   (* ^A back word *)
        fs      = 14C;                  (* ^L forward space *)
        fw      = 27C;                  (* ^W forward word *)
        sl      = 25C;                  (* ^U start of line *)
        el      = 16C;                  (* ^N end of line *)
        ds      = 4C;                   (* ^D delete space *)
        dw      = 26C;                  (* ^V delete word *)
        de      = 31C;                  (* ^Y delete to eol *)
        df      = 32C;                  (* ^Z delete field *)
        is      = 06C;                  (* ^F insert space *)
        ti      = 21C;                  (* ^Q toggle mode *)
        DEL     = 177C;                 (* erase back RUB *)
        editchrs= chset {bs,bw,fs,fw,sl,el,ds,dw,de,df,is,ti,DEL};
        sp      = " ";
        prompt  = "_";
        ctlset  = chset {01C..037C};
        printable
                = chset {' '..'~'};
        nums    = chset {"0".."9"};
        alph    = chset {"A".."Z","a".."z",' '};
        realset = chset {"0".."9","-","+","E","."};
        signs   = chset {"-","+"};
        ynset   = chset {'Y','N','y','n'};
        wordsep = chset {" ","/","-",011C,":"};
VAR
        eofset,                         (* input terminators *)
        okset,                          (* allowed in input *)
        editset : chset;                (* edit commands *)
        pos,                            (* current position on line *)
        i,                              (* loop var *)
        l       : CARDINAL;             (* current length of string *)
        ch      : CHAR;
        newword,
        insert  : BOOLEAN;

  PROCEDURE poscurs(o:CARDINAL);        (* gotoxy(x+o,y)        *)
  BEGIN
    gotoxy(x+o,y);
    pos := o;
  END poscurs;

  PROCEDURE showc(c:CHAR);      (* assumes cursor at correct position *)
  BEGIN                 (* prints character c to screen *)
    IF echo THEN
      IF (c IN ctlset) THEN
        rvon; Write(CHR(ORD(c)+64)); rvoff;
      ELSE Write(c); END;               (* and echo to screen *)
    ELSE Write('*'); END;               (*  unless noecho requested *)
  END showc;

  PROCEDURE dlete(chars,dpos:CARDINAL);
  VAR   i       : CARDINAL;
  BEGIN
    IF (l>0) AND (dpos<l) AND (chars>0) THEN
      coff;
      Delete(s,dpos,chars);             (* remove from string *)
      l := Length(s);                   (* adjust length *)
      FOR i := l TO HIGH(s) DO
        s[i] := 0C; END;                (* null end of string *)
      poscurs(dpos);                    (* this resets pos *)
      IF (l>pos) THEN
        FOR i := pos TO l-1 DO
          showc(s[i]); END;             (* redisplay *)
      END;
      poscurs(l);
      FOR i := 1 TO chars DO
        IF ((l+i)<=maxl) THEN Write(prompt); END;
      END;
      pos := dpos;                      (* restore cursor position *)
      con;
    END;                                (*endif *)
  END dlete;

  PROCEDURE insrt(c:CHAR; p:CARDINAL; ins:BOOLEAN);
(*      write c into s at position p - insert if ins, else overwrite    *)
  VAR   i       : CARDINAL;
  BEGIN         (* start of procedure insrt *)
    coff;

    IF ins THEN                         (* insert mode? *)
      IF (p<l) THEN                     (* position within string? *)
        FOR i := l TO p+1 BY -1 DO
          IF (i<maxl) THEN
            s[i] := s[i-1];             (* shift tail right *)
          END;                          (* endif i<maxl *)
        END;                            (* endfor *)
        poscurs(p+1);
        FOR i := p+1 TO l DO
          IF (i<maxl) THEN showc(s[i]); END;    (* redisplay tail *)
        END;
        poscurs(p);
      END;                              (* endif pos<l*)
    END;                                (* endif ins *)

    s[p] := c;                          (* put it into the string *)
    showc(c);                           (* and show on field *)
    IF (l<maxl) THEN
      IF (pos>l) THEN msg('Pos past Length',4); END;    (* for debug *)
      IF (pos=l) OR ins THEN INC(l); END;       (* bump length *)
    END;
    IF (pos<l) AND (pos<(maxl-1)) THEN
      INC(pos);                         (* bump position on field *)
    ELSE
      bell(1);
    END;
    con;
  END insrt;

  PROCEDURE initfld;
  VAR   i       : CARDINAL;
  BEGIN
    gotoxy(x,y);                        (* position for input *)
    WriteString(s);                     (* put up existing string *)
    FOR i := l TO (maxl-1) DO           (* put up prompt chars *)
      Write(prompt);
    END;
    FOR i := maxl TO (clrl-1) DO
      Write(' ');                       (* clear to clear length *)
    END;
    poscurs(0);
  END initfld;

BEGIN   (* start of main input routine *)
  insert := FALSE;                      (* always start in overwrite *)
  l := Length(s);                       (* pickup length of default *)
  CASE typ OF   (* start by setting up allowable entry for type *)
    0,1,2       : okset := printable;
|   3,4,5       : okset := alph + nums;
|   6,7,8       : okset := alph;
|   9,12,13     : okset := nums;
|   10          : okset := nums + signs;
|   11          : okset := realset;
|   14          : okset := ynset;
                  IF (l=0) OR NOT (s[0] IN ynset) THEN
                    s[0] := 'Y'; s[1] := 0C; END;
|   15          : okset := ynset;
                  IF (l=0) OR NOT (s[0] IN ynset) THEN
                    s[0] := 'N'; s[1] := 0C; END;
  ELSE
    msg("Invalid Type for input",5);
  END;                                  (*endcase *)
  IF ctlchars THEN                      (* if allowing ctrl chars, *)
    eofset := chset {CR};               (* then only CR for eof *)
    okset := okset + ctlset;            (*  others are valid input *)
    EXCL(okset,CR);
    editset := chset {DEL};
  ELSE                                  (* otherwise, *)
    editset := editchrs;                (* include edit commands ok *)
    eofset := ctlset - editset;         (* any control character ends *)
  END;

  initfld;
  con;                                  (* need cursor *)

  LOOP          (* take chars until eof is entered *)
    poscurs(pos);
    REPEAT
      Read(ch);
      IF (ch = 03C) AND ctlc THEN       (* ^C brute force abort *)
        msg("Ctrl-C Abort",5); END;
      IF (ch IN eofset) THEN EXIT; END; (* input done? *)
      IF NOT ((ch IN okset) OR (ch IN editset)) THEN bell(1); END;(* invalid *)
    UNTIL ((ch IN okset) OR (ch IN editset));
    IF (ch IN editset) THEN             (* if edit command *)
      CASE ch OF
        bs      :       (* move back one char           *)
          IF (pos>0) THEN
            DEC(pos);
          END;
|       bw      :       (* move back one word           *)
          IF (pos>0) THEN
            i := pos; newword := FALSE;
            WHILE (i>0) AND NOT newword DO
              DEC(i);
              IF (i=0) THEN
                IF NOT (s[i] IN wordsep) THEN
                  newword := TRUE; END;
              ELSIF (s[i-1] IN wordsep) AND NOT (s[i] IN wordsep) THEN
                newword := TRUE; END;
              IF newword THEN pos := i; END;    (* endif *)
            END;                                (*endwhile *)
          END;                                  (*end of bw routine *)
|       fs      :       (* move forward one char        *)
          IF (pos<l) AND (pos<maxl-1) THEN
            INC(pos);
          END;
|       fw      :       (* move forward one word        *)
          IF (pos<(l-1)) THEN
            i := pos; newword := FALSE;
            WHILE (i<(l-1)) AND NOT newword DO
              IF (s[i] IN wordsep) AND NOT (s[i+1] IN wordsep) THEN
                pos := i+1; newword := TRUE;
              ELSE INC(i); END;         (* endif *)
            END;                        (* endwhile *)
          END;                          (* end of fw routine *)
|       sl      :       (* cursor to start of line      *)
          pos := 0;
|       el      :       (* cursor to end of line        *)
          IF (l>0) THEN
            IF (l<maxl) THEN pos := l ELSE pos := maxl-1; END;
          ELSE pos := 0; END;
|       ds      :       (* delete char at cursor        *)
          dlete(1,pos);
|       dw      :       (* delete word right            *)
          IF (pos<l) THEN
            i := pos; newword := FALSE;
            WHILE (i<(l-1)) AND NOT newword DO
              IF (s[i] IN wordsep) AND NOT (s[i+1] IN wordsep) THEN
                newword := TRUE
              ELSE INC(i); END;
            END;                                (* endwhile *)
            dlete(i-pos+1,pos);
          END;                                  (* end of dw routine *)
|       de      :       (* delete to end of field       *)
          dlete(l-pos,pos);
|       df      :       (* clear the field              *)
          dlete(l,0);
|       is      :       (* insert space at cursor       *)
          insrt(sp,pos,TRUE);
          IF NOT ((pos=maxl-1) AND (l=maxl)) THEN
            DEC(pos); END;              (* insrt bumps pos *)
|       ti      :       (* toggle input mode (insert/overwrite *)
          insert := (insert = FALSE);
|       DEL     :       (* delete character left        *)
          IF (pos>0) THEN               (* only works to the left *)
            dlete(1,pos-1);
          END;
      END;                              (* endcase *)
    ELSE                                (*else in okset *)
      CASE typ OF
        0,3,6,9 : ;                     (* nothing to do *)
|       1,4,7   : ch := CAP(ch);        (* ucs 0,3,6    *)
|       2,5,8   : IF (pos = 0)          (* autocap 0,3,6*)
                        OR (s[pos-1] IN wordsep) THEN
                    ch := CAP(ch);
                  END;
|       10      : ;                     (* signed num   *)
|       11      : ;                     (* real         *)
|       12      : ;                     (* time         *)
|       13      : ;                     (* date         *)
|       14,15   : ch := CAP(ch);        (* y/n          *)
      END;                              (* endcase *)

      insrt(ch,pos,insert);

      IF quick AND (l >= maxl) THEN     (* quick field *)
        ch := 0C;                       (* for use in tch *)
        EXIT;
      END;
    END;                                (* endelse in okset *)
  END;                                  (*endloop *)

(*** eof character gets us here - set it into tch before leaving routine ***)

  coff;
  tch := ch;
  CASE spac OF          (* treat trailing spaces per parameter spac *)
    strip       : WHILE (l > 0) AND (s[l-1] = sp)  DO
                    s[l-1] := 0C; DEC(l); END;
|   fill        : WHILE (l < maxl) DO
                    s[l] := sp; INC(l); END;
|   leave       : ;
  END;
END input;

BEGIN
  InitStringModule;
  eseq("w");                    (* disable line wrap *)
(*
  eseq("b");                    (* set foreground *)
  Write(CHR(0));                (* white *)
  eseq("c");                    (* set background *)
  Write(CHR(7));                (* black *)
  rvoff;                        (* set normal display *)
                       Commented out to prevent Screen Color Changes *)
END ScrCtl.
