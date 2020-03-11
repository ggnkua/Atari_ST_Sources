(******************************************************************)
(**)               MODULE Accent; (* 87Nov29 - kbad *)          (**)
(**   based on accent.c developed by John Stern of Ampex Corp.   **)
(******************************************************************)
(* Copyright 1987,1988 Ken Badertscher
 * Permission is granted to use this program and source code,
 * however it may NOT be used or modified for any commercial gain.
 * The author disclaims responsibility for any damages resulting
 * from the use or misuse of this program, and disclaims liability
 * for losses of any kind or nature, financial or otherwise,
 * incurred as a result of the use of this software.
 *)
(******************************************************************)
 *                             IMPORTs                            *)
(*================================================================*)

FROM SYSTEM IMPORT ADDRESS, REG, INLINE;

IMPORT ASCII;

FROM String IMPORT
(*PROC*)    InitStringModule, Concat, Pos, Assign, Insert;

FROM Terminal IMPORT
(*PROC*)    WriteString, Read, Write, WriteLn;

FROM BasePage IMPORT
(*PROC*)    NumberOfArguments, GetArgument;

FROM FileSystem IMPORT
(*TYPE*)    File, Response,
(*PROC*)    Lookup, Close, Delete, Reset, ReadChar, WriteChar,
            Length, SetRead, Doio;

FROM Heap IMPORT
(*PROC*)    CreateHeap, Allocate, DeAllocate;

FROM Random IMPORT
(*PROC*)    RandomInt;

FROM AccentStrings IMPORT
(*CONST*)   PAGEWIDTH,
(*TYPE*)    AccentString,
(*VAR*)     vowel, cocknie, nerdism, curse, censor, article;

IMPORT AccentObjects;

(******************************************************************)
(*                      Global declarations                       *)
(*================================================================*)

CONST
    BUFSIZE     = 512;

(*----------------------------------------------------------------*)
(* local Malloc definitions used to get available memory          *)
    D0          = 0;
    pop         = 4FEFH; (* lea x(sp),sp *)
    TrapGEMDOS  = 4E41H; (* trap #1      *)
    available   = -1D;
    malloc      = 48H;

PROCEDURE Malloc(amt: LONGINT; fnID: INTEGER); CODE TrapGEMDOS;

(*----------------------------------------------------------------*)

TYPE
    Buf         = ARRAY [0..BUFSIZE] OF CHAR;
    CapsOpts    = (STARTWORD, NOCAPS, ONECAP, ALLCAPS);

VAR
    (* PROC vars used in 'accent' array for multiple accents *)
    Japanese, Chinese, German, Cockney, Italian, Stutter,
    PigLatin, Lisp, Nerd, Obscene, Uncensored, Nroff : PROC;

    (* accent flags, procedures, and flag descriptions *)
    accent  : ARRAY [0..13] OF
                RECORD
                  option  : CHAR;
                  func    : PROC;
                  descrip : AccentString;
                END;

    (* current set of accent options *)
    opts        : AccentString;

    (* temporaries used to hold individual words *)
    buf,
    tmpbuf      : Buf;

    (* capitalization flags *)
    caps        : CapsOpts;

    (* word terminator and last character read *)
    punc,ch     : CHAR;

    (* current argument, total arguments *)
    arg,nargs   : CARDINAL;

    (* various globals, ptr holds current index into buf, and     *)
    (* cursepos holds position of beginning of curse for DoCensor *)
    s,c,n,ptr,
    cursepos    : INTEGER;

    (* various flags -- if TRUE: *)
    whocares,
    prevLF,     (* last char read was an EOL            *)
    showForms,  (* program was called from the desktop  *)
    cancel,     (* user canceled from file-selector     *)
    redir,      (* redirect output to printer or disk   *)
    nrofflag,   (* nroff mode in effect                 *)
    pass,       (* skip current line in nroff mode      *)
    escchar     (* word started with a '\' (nroff esc)  *)
            : BOOLEAN;

    (* command line arguments *)
    args        : ARRAY [1..10] OF AccentString;

    (* input and output file variables *)
    infile,
    outfile     : File;
    maxFileSize,
    infileLen,
    amtToAlloc  : LONGINT;
    Pinfile,
    PinfileCH   : ADDRESS;

(******************************************************************)
(*                      Some useful procedures                    *)
(*================================================================*)

PROCEDURE GetCH;
  BEGIN
    ch := VAL(CHAR,PinfileCH^);
    INC(PinfileCH);
    DEC(infileLen);
  END GetCH;

(*----------------------------------------------------------------*)

PROCEDURE StrLength(s: ARRAY OF CHAR): INTEGER;
  VAR l: INTEGER;
  BEGIN l := 0;
    WHILE ( l <= HIGH(s) ) AND ( s[l] # 0C ) DO INC(l) END;
    RETURN l
  END StrLength;

(*----------------------------------------------------------------*)

PROCEDURE IsVowel(ch: CHAR): BOOLEAN;
  VAR i: INTEGER;
  BEGIN
    FOR i := 0 TO HIGH(vowel) DO
      IF (ch = vowel[i,0]) THEN RETURN TRUE END;
    END;
    RETURN FALSE
  END IsVowel;

(*----------------------------------------------------------------*)

PROCEDURE IsArticle(str: ARRAY OF CHAR): BOOLEAN;
  VAR i,len: INTEGER;
  BEGIN
    FOR i := 0 TO HIGH(article) DO
      len := StrLength(article[i]);
      IF ( StrLength(str) = len ) THEN
        WHILE (len > -1) AND ( article[i,len] = str[len] ) DO
          DEC(len)
        END;
        IF len = -1 THEN RETURN TRUE END;
      END;
    END;
    RETURN FALSE
  END IsArticle;

(*----------------------------------------------------------------*)

PROCEDURE Strip(VAR from: ARRAY OF CHAR;
		startingAt, howMany : INTEGER);
  BEGIN 
    WHILE from[startingAt+howMany] # 0C DO
      from[startingAt] := from[startingAt+howMany];
      INC(startingAt);
    END;
    from[startingAt] := 0C;
  END Strip;

(*----------------------------------------------------------------*)

PROCEDURE WaitForKey(prompt: ARRAY OF CHAR);
  VAR ch: CHAR;
  BEGIN
    WriteLn;
    Write(33C);Write('p');
    WriteString(prompt);
    Write(33C);Write('q');
    Read(ch);
  END WaitForKey;

(******************************************************************)
(**)                    MODULE WrapWriting;                     (**)
(**            perorms word-wrapping of Accent output            **)
(*================================================================*)

IMPORT
(*PROC*)    StrLength, Concat, Write, WriteLn, WriteChar, 
(*TYPE*)    Buf,
(*VAR*)     redir, outfile,
(*CONST*)   PAGEWIDTH;

EXPORT WrapWrite;

CONST
    SPACE = ' ';
    CR = 15C;
    LF = 12C;
VAR
    lineBuf : Buf;      (* holds current line       *)
    curPos  : INTEGER;  (* current position in line *)

PROCEDURE WrapWrite(word: ARRAY OF CHAR;
                    flush: BOOLEAN ): BOOLEAN;
(*  Output 'word' with word-wrapping to console, and (IF redir)
 * to 'outfile'.  IF flush, then put out the current line.
 * Should return FALSE on a write error to outfile, but in the
 * interest of speed, it doesn't.
 *)
  VAR newPos,wordLen: INTEGER;
  BEGIN
    wordLen := StrLength(word);
    newPos := curPos + wordLen;
    IF ( flush ) OR
       ( newPos > PAGEWIDTH ) OR
       ( newPos > HIGH(lineBuf) ) THEN
      newPos := 0;
      WHILE lineBuf[newPos] # 0C DO
        Write(lineBuf[newPos]);
        IF redir THEN WriteChar(outfile,lineBuf[newPos]) END;
        INC(newPos);
      END;
      WriteLn;
      IF redir THEN WriteChar(outfile,CR); WriteChar(outfile,LF) END;
      curPos := 0;
      lineBuf := "";
    END;
    Concat(lineBuf,word,lineBuf);
    curPos := curPos + wordLen;
    RETURN TRUE
  END WrapWrite;

BEGIN
  curPos := 0;
END WrapWriting;

(******************************************************************)
(*                  "Accent-ization" procedures                   *)
(*================================================================*)

PROCEDURE DoJapanese;
  VAR s: INTEGER;
  BEGIN s := 0;
    WHILE (buf[s] # 0C) DO
      IF (buf[s] = 'l') THEN buf[s] := 'r' END;
      INC(s);
    END;
  END DoJapanese;

(*----------------------------------------------------------------*)

PROCEDURE DoChinese;
  VAR s: INTEGER;
  BEGIN s := 0;
    WHILE (buf[s] # 0C) DO
      IF(buf[s] = 'r') THEN buf[s] := 'l' END;
      INC(s);
    END;
  END DoChinese;

(*----------------------------------------------------------------*)

PROCEDURE DoGerman;
  VAR s: INTEGER;
  BEGIN s := 0;
    WHILE (buf[s] # 0C) DO
      CASE buf[s] OF
        'c' : IF (IsVowel(buf[s+1])) AND
                ( (s = 0) OR (IsVowel(buf[s-1])) ) THEN buf[s] := 'k' END
      | 'd' : IF (buf[s+1] = 0C) THEN buf[s] := 't' END
      | 'g' : IF (buf[s+1] = 0C) THEN buf[s] := 'k' END
      | 'p' : IF (buf[s+1] = 'h') THEN
                buf[s] := 'f'; Strip(buf,s+1,1) END
      | 's' : IF (IsVowel(buf[s+1])) AND
                ( (s = 0) OR (IsVowel(buf[s-1])) ) THEN buf[s] := 'z' END
      | 't' : IF (s = 0) AND (buf[s+1] = 'h') THEN
                buf[s] := 'z'; Strip(buf,s+1,1) END
      | 'v' : buf[s] := 'f'
      | 'w' : buf[s] := 'v'
      ELSE
      END;(*CASE*)
      INC(s);
    END;(*WHILE*)
  END DoGerman;

(*----------------------------------------------------------------*)

PROCEDURE DoItalian;
  VAR s: INTEGER;
  BEGIN s := 0;
    WHILE (buf[s] # 0C) DO
      CASE buf[s] OF
        'h' : IF (s = 0) THEN buf[s] := "'" END
      | 't' : IF (buf[s+1] = 'h') THEN Strip(buf,s+1,1) END
      ELSE END;
      INC(s);
    END;
    IF ( (RandomInt(0,2) = 2) AND (StrLength(buf) > 2) ) THEN
      IF NOT( IsVowel(buf[s-1]) ) THEN
        buf[s] := vowel[RandomInt(0,HIGH(vowel)),0]; INC(s);
        buf[s] := 0C;
      ELSIF (buf[s-1] = 'e') AND NOT( IsVowel(buf[s-2]) ) THEN
        buf[s-1] := vowel[RandomInt(0,HIGH(vowel)),0];
      END;
    END;
  END DoItalian;

(*----------------------------------------------------------------*)

PROCEDURE DoCockney;
  BEGIN
    IF ( IsArticle(buf) ) AND ( ODD(RandomInt(0,1)) ) THEN
      Concat(buf," ",buf);
      Concat(buf,cocknie[RandomInt(0,HIGH(cocknie))],buf);
    END;
    IF (buf[0] = 'h') AND ( IsVowel(buf[1]) ) THEN buf[0] := "'" END;
  END DoCockney;

(*----------------------------------------------------------------*)

PROCEDURE DoStutter;
  VAR tmpptr,ptr,stuts : INTEGER;
  BEGIN tmpptr := 0; ptr := 0;

    IF ( ASCII.CharIsAlpha(buf[0]) ) AND
       (StrLength(buf) > 2) AND (RandomInt(1,4) = 1)  THEN

      (* search for end of consonants *)
      WHILE NOT( IsVowel(buf[ptr]) ) AND (buf[ptr] # 0C) DO
        tmpbuf[tmpptr] := buf[ptr]; INC(tmpptr); INC(ptr);
      END;

      tmpbuf[tmpptr] := 0C;
      IF (buf[ptr] # 0C) THEN (* not all consonants *)
        tmpptr := RandomInt(2,5);
        FOR stuts := tmpptr TO 1 BY -1 DO
          Insert(tmpbuf,buf,ptr);
        END;(*FOR*)
      END;(*IF not all consonants*)

    END;(*IF IsAlpha*)
  END DoStutter;

(*----------------------------------------------------------------*)

PROCEDURE DoLisp;
  VAR s: INTEGER;
  BEGIN s := 0;
    WHILE (buf[s] # 0C) DO
      IF (buf[s] = 's') THEN buf[s] := 't'; Insert('h',buf,s+1) END;
      INC(s)
    END
  END DoLisp;

(*----------------------------------------------------------------*)

PROCEDURE DoNerd;
  BEGIN
    IF ( (IsArticle(buf)) OR (punc = ',') ) AND
       ( ODD(RandomInt(0,1)) ) THEN
      Concat(buf,", ",buf);
      Concat(buf,nerdism[RandomInt(0,HIGH(nerdism))],buf);
      (* add trailing comma if followed by space *)
      IF (punc = ' ') THEN Concat(buf,",",buf) END;
    END
  END DoNerd;

(*----------------------------------------------------------------*)

PROCEDURE DoPigLatin;
  VAR s, ptr, tmpptr : INTEGER;
  BEGIN ptr := 0; tmpptr := 0;
    IF NOT( ASCII.CharIsAlpha(buf[0]) ) THEN RETURN END;
    IF IsVowel(buf[0]) THEN Concat (buf,"way", buf); RETURN END;
    WHILE NOT( IsVowel(buf[ptr]) ) AND (buf[ptr] # 0C) DO
      (* search for consonants *)
      tmpbuf[tmpptr] := buf[ptr]; INC(tmpptr); INC(ptr);
    END;
    tmpbuf[tmpptr] := 0C;
    Strip(buf,0,ptr);
    Concat(buf,tmpbuf,buf);
    Concat(buf,"ay",buf);
  END DoPigLatin;

(*----------------------------------------------------------------*)

PROCEDURE DoUncensored;
  BEGIN 

    cursepos := 0;
    tmpbuf := " ";
    IF ( IsArticle(buf) ) THEN
      Concat(tmpbuf,curse[RandomInt(0,HIGH(curse))],tmpbuf);
    ELSIF ( (StrLength(buf) = 2) AND
            (buf[0] = 'a') AND (buf[1] = 'n') ) AND
          ( ODD(RandomInt(0,1)) ) THEN
      Concat(tmpbuf,"asshole",tmpbuf);
    ELSE RETURN
    END;
    
    cursepos := VAL(INTEGER,StrLength(buf));
    Concat(buf,tmpbuf,buf);

  END DoUncensored;

(*----------------------------------------------------------------*)

PROCEDURE DoObscene;
  VAR n: INTEGER;
  BEGIN

    DoUncensored;
    IF (cursepos # 0) THEN
      tmpbuf := buf;
      INC(cursepos);
      WHILE (buf[cursepos] # 0C) DO
        IF ( ASCII.CharIsAlpha(tmpbuf[cursepos-2]) ) AND
           ( ASCII.CharIsAlpha(tmpbuf[cursepos-1]) ) AND
           ( ASCII.CharIsAlpha(tmpbuf[cursepos]  ) ) AND
           ( ASCII.CharIsAlpha(tmpbuf[cursepos+1]) ) AND
           ( ASCII.CharIsAlpha(tmpbuf[cursepos+2]) ) THEN
          buf[cursepos] := censor[ RandomInt(0,HIGH(censor)) , 0 ];
        END;
        INC(cursepos);
      END; (*WHILE*)
    END; (*IF (cursepos # 0)*)

  END DoObscene;

(*----------------------------------------------------------------*)

PROCEDURE DoNroff;
  BEGIN
    nrofflag := TRUE;
  END DoNroff;

(******************************************************************)
(*                  Initialize accent array                       *)
(*----------------------------------------------------------------*)

PROCEDURE InitAccent;
  BEGIN

    Japanese    := DoJapanese;
    Chinese     := DoChinese;
    German      := DoGerman;
    Italian     := DoItalian;
    PigLatin    := DoPigLatin;
    Cockney     := DoCockney;
    Stutter     := DoStutter;
    Lisp        := DoLisp;
    Nerd        := DoNerd;
    Obscene     := DoObscene;
    Uncensored  := DoUncensored;
    Nroff       := DoNroff;

    WITH accent[0] DO
      option := 'J'; func := Japanese; descrip := '(apanese)';
    END;
    WITH accent[1] DO
      option := 'C'; func := Chinese; descrip := '(hinese)';
    END;
    WITH accent[2] DO
      option := 'G'; func := German; descrip := '(erman)';
    END;
    WITH accent[3] DO
      option := 'I'; func := Italian; descrip := '(talian)';
    END;
    WITH accent[4] DO
      option := 'P'; func := PigLatin; descrip := '(ig Latin)';
    END;
    WITH accent[5] DO
      option := 'K'; func := Cockney; descrip := '(cocKney)';
    END;
    WITH accent[6] DO
      option := 'S'; func := Stutter; descrip := '(tutter)';
    END;
    WITH accent[7] DO
      option := 'L'; func := Lisp; descrip := '(isp)';
    END;
    WITH accent[8] DO
      option := 'D'; func := Nerd; descrip := '(nerD)';
    END;
    WITH accent[9] DO
      option := 'O'; func := Obscene; descrip := '(bscene/censored)';
    END;
    WITH accent[10] DO
      option := 'U'; func := Uncensored; descrip := '(ncensored)';
    END;
    WITH accent[11] DO
      option := 'R'; func := Nroff; descrip := '(andom accent)';
    END;
    WITH accent[12] DO
      option := 'N'; func := Nroff; descrip := '(pass Nroff commands)';
    END;
    WITH accent[13] DO
      option := 10C; func := Nroff; descrip := ' file1 [ file2 ... ]';
    END;

  END InitAccent;    
    
(******************************************************************)
(*              Use dialogs to get args and files                 *)
(*----------------------------------------------------------------*)

PROCEDURE DoForms;
  BEGIN
    (* get input file, terminate program if user selects 'cancel' *)
    cancel := TRUE;
    AccentObjects.GetFile(' Select file to "accent"... ', cancel, args[2]);
    IF cancel THEN AccentObjects.GEMTerm END;

    (* get accent options *)
    AccentObjects.GetArgs(args[1]);

    (* get output file (if cancel, then just output to screen)    *)
    AccentObjects.GetFile(' Select output file... ', cancel, args[3]);
    redir := ~cancel;
    showForms := TRUE;
    IF redir THEN
      Lookup(outfile, args[3], TRUE);
      IF outfile.res # done THEN
        WriteString('Error opening '); WriteString(args[3]); 
        WaitForKey(' Press a key... ');
        AccentObjects.GEMTerm
      ELSIF ~outfile.new THEN
        Delete(outfile);
        Lookup(outfile, args[3], TRUE);
      END;
    END;
    
    nargs := 2;
  END DoForms;

(******************************************************************)
(*                  Check argument validity                       *)
(*----------------------------------------------------------------*)
(* this procedure will only allow the 'uncensored' option if      *)
(* specifically requested on the command line. (i.e. NOT from the *)
(* GEM shell... sorry, kids!                                      *)

PROCEDURE CheckArgs(): BOOLEAN;
  VAR optnum: INTEGER;
  BEGIN optnum := 0;
    arg := 1;
    WHILE (arg <= nargs) AND
          (args[arg,0] = '-') DO (* stop at first non-flag argument*)

      c := 1;
      WHILE (args[arg,c] # 0C) DO
        args[arg,c] := CAP(args[arg,c]);
        n := 0;
        WHILE (n <= HIGH(accent)) AND (args[arg,c] # accent[n].option) DO
          INC(n);
        END;
        IF n > HIGH(accent) THEN
          WriteString('Illegal option '); Write(args[arg,c]); WriteLn;
          RETURN FALSE;
        ELSE
          IF args[arg,c] = 'R' THEN (* select random argument   *)
            REPEAT
              args[arg,c] := accent[RandomInt(0,HIGH(accent)-3)].option
            UNTIL args[arg,c] # 'U' (* but not 'uncensored'     *)
          END;
          opts[optnum] := args[arg,c]; INC(optnum);
        END;
        INC(c);
      END;

      INC(arg);
    END;
    opts[optnum] := 0C;
    RETURN TRUE

  END CheckArgs;

(******************************************************************)
(*                         MAIN routine                           *)
(*================================================================*)

BEGIN (*Accent*)

  (* find out how much memory we have to play with *)
  Malloc(available,malloc);
  INLINE(pop,6);
  maxFileSize := REG(D0);
  (* leave room for the resource *)
  maxFileSize := maxFileSize - 32767D;
  (* make the heap or die *)
  IF NOT( CreateHeap(maxFileSize,TRUE) ) THEN
    n := AccentObjects.DoAlert(1,"[3][Memory allocation error][oh, my]");
    AccentObjects.GEMTerm;
  END;

  (* init some variables *)
  nrofflag := FALSE;
  redir := FALSE;
  showForms := FALSE;

  InitStringModule;
  InitAccent;

  punc := ' ';
  buf := "";

  nargs := NumberOfArguments();
  arg := 1;
  WHILE (arg <= nargs) DO
    GetArgument(arg, args[arg]);
    INC(arg);
  END;

  IF arg = 1 THEN (* no arguments passed, do the GEM stuff *)
    AccentObjects.ShowTitle;
    DoForms
  END;

  IF NOT( CheckArgs() ) OR (nargs < 1) THEN (* show usage *)
    WriteLn;
    whocares := WrapWrite(' Usage: accent',FALSE);
    FOR n := 0 TO HIGH(accent) DO
      buf := ' -';
      buf[2] := accent[n].option;
      buf[3] := 0C;
      Concat(buf,accent[n].descrip,buf);
      whocares := WrapWrite(buf,FALSE);
    END;
    whocares := WrapWrite("",TRUE);
    WriteLn; WriteLn;
    AccentObjects.GEMTerm;
  END;

  WHILE ( arg <= nargs ) DO

    (* set up initial conditions for each file *)
    caps    := STARTWORD;
    punc    := ASCII.LF;
    pass    := FALSE;
    escchar := FALSE;
    ptr     := 0;

    (* go get the file *)
    Assign(infile.name,args[arg]);
    Lookup(infile, infile.name, FALSE);

    IF infile.res # done THEN
      WriteString("Can't open file ");
      WriteString(infile.name);  WaitForKey("  Press a key...  ");
    ELSIF infile.new THEN
      WriteString("File "); WriteString(infile.name);
      WriteString(" not found");  WaitForKey("  Press a key...  ");
      Delete(infile);
    ELSE

      (* snarf the file into memory *)
      Length(infile,infileLen);
      IF infileLen >= maxFileSize THEN
        n := AccentObjects.DoAlert(1,"[1][File too long][sorry]");
        infileLen := 0D;
      ELSE
        amtToAlloc := infileLen;
        Allocate(Pinfile,amtToAlloc);
        IF Pinfile = NIL THEN
          n := AccentObjects.DoAlert(1,"[3][Memory allocation error][arrgh]");
          AccentObjects.GEMTerm;
        ELSE
          PinfileCH := Pinfile;
          infile.buf := PinfileCH;    (* set file buffer *)
          infile.buflen := infileLen; (* set file buffer length *)
          SetRead(infile);            (* set read status *)
          Doio(infile);               (* do the transfer *)
          IF infile.res # done THEN
            n := AccentObjects.DoAlert(1,"[1][Input file read error][arrgh]");
            infileLen := 0D;
          ELSE
            GetCH;
          END;
          Close(infile);
        END;
      END;

      WHILE ( infileLen > 0D ) DO

        (* map caps to lowercase *)
        IF ASCII.CharIsUpper(ch) THEN
          buf[ptr] := ASCII.ToLower(ch);
          INC(ptr);
          IF (caps = STARTWORD) THEN caps := ALLCAPS END;
          prevLF := FALSE;
          GetCH;

        ELSIF ASCII.CharIsLower(ch) THEN  (* bona fide letter *)
          buf[ptr] := ch; INC(ptr);
          IF (caps = STARTWORD) THEN caps := NOCAPS
          ELSIF (caps = ALLCAPS) THEN caps := ONECAP
          END;
          prevLF := FALSE;
          GetCH;

        ELSE    (* check all other chars *)
          IF (ch = ASCII.CR) THEN (* skip CR's *)
            GetCH;
          ELSIF ((ch = '.') OR (ch = "'")) AND
             (nrofflag) AND
             (punc = ASCII.LF) AND
             (ptr = 0) THEN
            pass := TRUE; (* ignore lines starting with . or ' in nroff mode *)
          END;
          IF ( ch = ASCII.LF ) OR
             ( ch = ASCII.HT ) OR
             ( ch = '.' ) OR
             ( ch = ',' ) OR
             ( ch = ' ' ) OR
             ( ch = '!' ) OR
             ( ch = '?' ) OR
             ( ch = ';' ) OR
             ( ch = ':' ) THEN

            punc := ch; buf[ptr] := 0C;

            (* accent individual words except, possibly, in nroff mode *)
            IF (buf[0] # 0C) AND (~pass) AND (~escchar) THEN
              s := 0;
              WHILE (opts[s] # 0C) DO
                FOR n := 0 TO HIGH(accent) DO
                  IF ( accent[n].option = opts[s] ) THEN
                    accent[n].func
                  END;
                END;
                INC(s);
              END;
            END;

            s := 0;
            WHILE (buf[s] # 0C) DO (* capitalize as necessary *)
              IF ASCII.CharIsAlpha(buf[s]) THEN
                IF ((caps = ONECAP) AND (s = 0)) OR (caps = ALLCAPS)
                  THEN buf[s] := CAP(buf[s]) END;
              END;
              INC(s);
            END;

            IF punc = ASCII.LF THEN (* check for paragraphs *)
              IF ~prevLF THEN buf[s] := ' '; buf[s+1] := 0C END;
              whocares := WrapWrite(buf,prevLF);
              prevLF := TRUE;
              GetCH;
              IF ch = ASCII.CR THEN GetCH END;
              IF ( ch = ASCII.LF ) OR
                 ( ch = ASCII.HT ) OR
                 ( ch = ' ' ) THEN (* yup, it's a paragraph *)
                whocares := WrapWrite("",TRUE);
              END;
            ELSE
              buf[s] := punc;
              buf[s+1] := 0C;
              whocares := WrapWrite(buf,FALSE);
              prevLF := FALSE;
              GetCH;
            END;
            ptr := 0;
            caps := STARTWORD;
            escchar := FALSE;
            (* reset pass conditions for nroff mode *)
            IF (punc = ASCII.LF) THEN pass := FALSE END;

          ELSE (* not a delimiter *)
            (* ignore words with escape character \ in nroff mode *)
            IF (nrofflag) AND (ch = '\') THEN escchar := TRUE END;
            prevLF := FALSE;
            buf[ptr] := ch; INC(ptr); GetCH;
          END; (* IF delimiter *)

        END; (*IF .. check char*)

      END; (* WHILE infileLen > 0D *)

      whocares := WrapWrite("",TRUE);

      DeAllocate(Pinfile,amtToAlloc);
      IF redir THEN Close(outfile) END;

      INC(arg);
      IF showForms THEN 
        n := 0;
        WHILE (n < HIGH(accent)) AND
              (opts[0] # accent[n].option) DO
          INC(n)
        END;
        opts := " *** End ";
        buf := "of";
        accent[n].func;
        Concat(opts,buf,opts); Concat(opts,' ',opts);
        buf := "file";
        accent[n].func;
        Concat(opts,buf,opts);
        Concat(opts," ***   ",opts);
        buf := "Press";
        accent[n].func;
        Concat(opts,buf,opts); Concat(opts,' ',opts);
        buf := "a";
        accent[n].func;
        Concat(opts,buf,opts); Concat(opts,' ',opts);
        buf := "key";
        accent[n].func;
        Concat(opts,buf,opts);
        Concat(opts,"... ",opts);
        WaitForKey(opts);
        opts := "";
      END;
    END; (*IF infile.res*)

    IF showForms THEN
      n := AccentObjects.DoAlert(1,
        "[2][Would you care to have|another go at it?][Sure!|No thanks]");
      IF n = 1 THEN
        DoForms;
        IF NOT( CheckArgs() ) THEN AccentObjects.GEMTerm END;
      END;
    END;

  END; (* WHILE arg <= nargs *)

  AccentObjects.GEMTerm;

END Accent.
