UNIT things;
INTERFACE

{$IFDEF CPU86}
USES crt, DOS, search;
{$ELSE}
USES crt2, DOS, search;
{$ENDIF}
TYPE
  datearray         = packed array [0..7] OF word;  {holds most dates}
  menutype          = (nul, ADDRESS, ORDER, QUOTE, DIARY, MERGE);
      {used by mainloop do decide which module to divert commands to}

CONST
                  { normal consts }
  config            = 'ppal.ini';     {loaded at startup}
                  {typed consts}
  lockchar: char    = 'á';
  menusel : menutype= ADDRESS;        {start up menu}
  dir     : dirstr  = '';             {start directory}
  sopen   : boolean = FALSE;    {is there a message file?}
  stemp   : string  = '';
  stdcode : dirstr  = '';
  password: string  = '';
  clipfile: dirstr  = '';
  ansi    : boolean = TRUE;           {if ANSI.SYS is installed}
                                      {the program is designed to run
                                        on an st or a pc if this is set false 
                                        then vt52 will be used else ansi
                                        escapes will be used}

VAR
  date              : datearray;    {date held here}
  sfilename         : dirstr;       {message file name}
  sfile             : text;         {message file}
  funcmem           : packed array [1..10] OF string;

FUNCTION exist (n : string) : boolean;  {returns true if n exists}
PROCEDURE dodate (f : boolean);{writes the system time and date }
PROCEDURE curon (v  : boolean);
{uses VT52 or ANSI.SYS to turn cursor on}
FUNCTION getchar : char;
{gets a char from CON:}
FUNCTION getstring (x, y, maxl : byte;r, d : string;echo : boolean; VAR back : boolean) : string;
{gets a string - from x, y on the CON: with a maximum length maxl
r is he refix and d the default which is returned by ESCAPE
IF echo then the chars are displayed
IF back the terminated by TAB}
PROCEDURE centre (s : string;cr : boolean);
{centres astring on the screen
if cr THEN WRITE (#10, #13);}
PROCEDURE drawlinex (x, y, l : byte;c : char);
{draws a horizontal line at x, y of length l and
char c}
PROCEDURE drawliney (x, y, l : byte;c : char);
{draws a verticle line}
PROCEDURE writexy (x, y : byte;s : string);
{writes string s at x, y retoring the ursors postion
after use}
FUNCTION strf (n : longint) : string;
{STR rediefined as a function}
FUNCTION togglebool (b  : boolean)  : boolean;
{IF b THEN return FALSE else RETURn TRUE}
FUNCTION confirm (s : string) : boolean;
{if user presses Y then RETURNS TRUE}
FUNCTION valf (s  : string) : longint;
{VAL redefined as a function}
PROCEDURE invert (v : boolean);
{uses VT52 or ANSI.SYS to set inverse video to v}
PROCEDURE cleardisparea;
{clears bog right box}


IMPLEMENTATION

FUNCTION paste : string;
VAR
  myfile        : text;
  t             : string;
BEGIN
  paste:='';
  ASSIGN (myfile, clipfile);
  IF exist (clipfile) THEN
  BEGIN
    RESET (myfile);
    READLN (myfile, t);
    paste:=t;
    CLOSE (myfile);
  END;
END;

PROCEDURE clip (s : string);
VAR
  myfile          : text;
BEGIN
  ASSIGN (myfile, clipfile);
  REWRITE (myfile);
  WRITELN (myfile, s);
  CLOSE (myfile);
END;

FUNCTION exist (n : string) : boolean;
VAR     {returns true if a file n exists}
  ok              : searchrec;
  mestr           : string;
BEGIN
  FINDFIRST (n, $27, ok);
  IF DOSERROR=0 THEN exist:=TRUE
    ELSE exist:=FALSE;
END;

PROCEDURE dosadfile;
VAR{ called bye do date to print a message on the sreen}
  n, x, y     : byte;
  holder      : char;
BEGIN
  x:=WHEREX;
  y:=WHEREY;
  IF EOF (sfile) THEN RESET (sfile);
  READLN (sfile, stemp);
  GOTOXY (3, 25);
  FOR n:=3 TO 79 DO
    WRITE (' ');
  writexy (3, 25, stemp);
  GOTOXY (x, y);
END;

FUNCTION strform (n : longint) : string;
VAR
  t : string;
BEGIN
  STR (n, t);
  IF n<10 THEN t:='0'+t;
  strform:=t;
END;

PROCEDURE dodate (f : boolean);{writes the system time and date }
VAR
  support       : datearray;
  c, m          : string;
BEGIN     { writes the time and date on the top line of the screen }
  GETDATE (support[0], support[1], support[2], support [3]);
  GETTIME (support[4], support[5], support[6], support [7]);
  IF ((support[6] DIV 2 <>date[6] DIV 2) OR (f)) AND (sopen) THEN dosadfile;
  IF ((support[5]<>date[5]) OR (support[6]<>date[6])) OR (f) THEN
  BEGIN
    writexy (71, 1, strform (support[4])+':'+strform (support[5])+':'+strform (support[6])+' ');
    IF (support[2]<>date[2]) OR (f) THEN
    BEGIN
      CASE support[3] OF
        0 : c:='Sunday';
        1 : c:='Monday';
        2 : c:='Tuesday';
        3 : c:='Wednesday';
        4 : c:='Thursday';
        5 : c:='Friday';
        6 : c:='Saturday';
      END;
      CASE support[1] OF
        1 : m:='January';
        2 : m:='February';
        3 : m:='March';
        4 : m:='April';
        5 : m:='May';
        6 : m:='June';
        7 : m:='July';
        8 : m:='August';
        9 : m:='September';
        10: m:='October';
        11: m:='November';
        12: m:='December';
      END;
      CASE support[2] MOD 10 OF
        1 : m:='st '+m;
        2 : m:='nd '+m;
        3 : m:='rd '+m;
      ELSE
        m:='th '+m;
      END;
      IF support[2] in [11, 12, 13] THEN 
      BEGIN
        DELETE (m, 1, 2);
        m:='th'+m;
      END;
      writexy (3, 1, c+', '+ strf (support[2])+ m+' '+strf (support[0])+' ');
    END;
  END;
  date:=support;
END;

PROCEDURE curon (v  : boolean);
BEGIN     {turns the cursor on with either vt52 or ansi escapes}
  CASE ansi OF
    FALSE : IF v THEN WRITE (#27, 'e') ELSE WRITE (#27, 'f');
    TRUE  :{ IF v THEN WRITE (#27, 'm', #27, '5') ELSE WRITE (#27, 'm', #27, '8');}
  END;
END;

PROCEDURE lockout;
VAR
  byebye, b       : boolean;
  s               : string;
  x, y            : byte;
BEGIN
  x:=WHEREX;
  y:=WHEREY;
  REPEAT
    s:=getstring (30, 23, 25, 'Enter Password : ', '', FALSE, b);
    IF s=password THEN byebye:=TRUE ELSE byebye:=FALSE;
    writexy (30, 23, '                                           ');
  UNTIL byebye;
  GOTOXY (x, y);
END;

FUNCTION getchar : char;
VAR
  you       : char;
BEGIN       {returns a char from the keyboard}
  REPEAT
    dodate (FALSE);
  UNTIL KEYPRESSED;
  you:=READKEY;
  IF (you=lockchar) AND (password<>'') THEN
  BEGIN
    lockout;
    you:='|';
  END;
  getchar:=you;
END;

FUNCTION getstring (x, y, maxl : byte;r, d : string;echo : boolean; VAR back : boolean) : string;
VAR         {gets a string; x, y are the start positions, maxl is the max length}
  n               : byte;
  byebye          : boolean; {r is the prefix; d is the default}
  you             : char;    { echo = false for passwords}
  at              : byte;
BEGIN                         { back for moveing back a field}
  GOTOXY (x, y);
  WRITE (r+d);      { print prefix}
  x:=(x+LENGTH (r));
  at:=LENGTH (d);
  r:=d;
  back:=FALSE;
  REPEAT
    byebye:=FALSE;
    curon (TRUE);
    you:=getchar;
    curon (FALSE);
    GOTOXY (x, y);
    CASE you OF
      #0  : BEGIN
              you:=READKEY;
              CASE you OF
                #59..
                #68 : BEGIN
                        FOR n:=1 TO LENGTH (r) DO
                          WRITE (' ');
                          r:=funcmem [ORD (you)-58];
                          IF LENGTH (r)<at THEN at:=LENGTH (r);
                      END;
                #119: BEGIN
                        FOR n:=1 TO LENGTH (r) DO
                          WRITE (' ');
                        r:='';
                        at:=0;
                      END;
                #84..
                #93 : funcmem[ORD (you)-83]:=r;
                #72 : BEGIN
                        back:=TRUE;
                        byebye:=TRUE; {up}
                      END;
                #77 : IF at<LENGTH (r) THEN INC (at);  {left}
                #75,
                #74 : IF at>0 THEN DEC (at);  {right}
                #80 : byebye:=TRUE;  {down}
                #71 : IF at>0 THEN at:=0;  {home}
                #79 : at:=LENGTH (r);  {end}
                #45 : BEGIN
                        clip (r);
                        FOR n:=1 TO LENGTH (r)+1 DO
                          WRITE (' ');
                        r:='';    {Alt-x cut}
                        at:=0;
                      END;
                #83 : DELETE (r, at+1, 1);{delete}
                #46 : clip (r);   {alt-c copy}
                #47 : BEGIN
                        FOR n:=1 TO LENGTH (r)+1 DO
                          WRITE (' ');
                        r:=paste;
                        at:=LENGTH (r); {alt-v paste}
                      END;
              END;
          END;
      #9,
      #10,
      #13 : byebye:=TRUE;
      #127: DELETE (r, at+1, 1);{delete}
      #27 : BEGIN
              r:=d;
              byebye:=TRUE;{ if esc then pass default back}
            END;
      #8  : IF at>0 THEN
            BEGIN
              DEC (at);
              DELETE (r, at+1, 1);
            END;{ back space}
    ELSE      { else update string}
      IF LENGTH (r)<maxl THEN
      BEGIN
        INC (at);
        INSERT (you, r, at);
      END;
    END;
    GOTOXY (x, y);
    WHILE (LENGTH (r)>maxl) DO
      r[0]:=PRED (r[0]);
    IF echo THEN
      WRITE (r+'  ')
    ELSE BEGIN
      FOR n:=1 TO LENGTH (r) DO
        WRITE ('*');
      WRITE (' ');
    END;
    GOTOXY ((x+at), y);
  UNTIL byebye;
  WRITELN ('');
  getstring:=r;
  curon (FALSE);    {turn cusror off}
END;

PROCEDURE centre (s : string;cr : boolean);
  { centres string, s on the current line of the screen}
BEGIN
  GOTOXY ((80-LENGTH (s)) DIV 2, WHEREY);
  WRITE (s);
  IF cr THEN WRITELN;
END;

PROCEDURE drawlinex (x, y, l : byte;c : char);
  { draws a line of char, c at x,y of lenght l in the x direction }
VAR
  spare             : byte;
BEGIN
  GOTOXY (x, y);
  FOR spare:=x TO x+l DO
    WRITE (c);
END;

PROCEDURE drawliney (x, y, l : byte;c : char);
  { draws a line - up and down  }
VAR
  spare             : byte;
BEGIN
  FOR spare:=y TO y+l DO
  BEGIN
    GOTOXY (x, spare);
    WRITE (c);
  END;
END;

PROCEDURE writexy (x, y : byte;s : string);
  { wrtes a string at x, y }
VAR
  ox, oy     : byte;
BEGIN
  ox:=WHEREX;
  oy:=WHEREY;
  GOTOXY (x, y);
  WRITE (s);
  GOTOXY (ox, oy);
END;

FUNCTION strf (n : longint) : string;
  { STR redefinded as function for ease }
VAR
  c : string;
BEGIN
  STR (n, c);
  strf:=c;
END;

FUNCTION togglebool (b  : boolean)  : boolean;
BEGIN
  IF b THEN togglebool:=FALSE
    ELSE togglebool:=TRUE;
END;

FUNCTION confirm (s : string) : boolean;
  { returns true if user confirmes an action }
BEGIN
  writexy (35, 20, #7+'Confirm '+s+' Y/N ?');
  s[1]:=UPCASE (getchar);
  IF s[1]='Y' THEN confirm:=TRUE ELSE confirm:=FALSE;
END;

FUNCTION valf (s  : string) : longint;
VAR
  r         : longint;
  e, n      : integer;
BEGIN
  n:=1;
  WHILE (s[n]=' ') AND (n<LENGTH (s)) DO
    INC (n);
  VAL (COPY (s, n, LENGTH (s)), r, e);
  valf:=r;
END;

PROCEDURE invert (v : boolean);
  { turns inverse video on or off }
BEGIN
  IF v THEN 
  BEGIN   {this will only work on the st if you
            have written the two procedures bellow}
    TEXTCOLOR (WHITE);
    TEXTBACKGROUND (BLACK);
  END ELSE BEGIN
    TEXTCOLOR (BLACK);
    TEXTBACKGROUND (WHITE);
  END;
END;

PROCEDURE clearmenuarea;
VAR     { clears the bottom left menu area;}
  y           : byte;
BEGIN
  FOR y:=10 TO 23 DO
  BEGIN
    GOTOXY (2, y);
    WRITE ('                       ');
  END;
END;

PROCEDURE cleardisparea;
VAR     { clears the large display area; }
  y           : byte;
BEGIN
  FOR y:=3 TO 23 DO
  BEGIN
    GOTOXY (26, y);
    WRITE ('                                                      ');
  END;
END;

BEGIN
END.