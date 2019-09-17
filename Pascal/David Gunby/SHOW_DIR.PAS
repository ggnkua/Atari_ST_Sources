{compile with all checks off and linker 4 11 11 10}

PROGRAM davids_window_thing;
USES gemaes, gemdecl, gemvdi, printer, bios, dos;
TYPE
  pipearray                   = array [0..7] OF integer;

CONST
  elements                    = 4095;
  strnlen                     = 50;
  max_elements  : byte        = 127;
  real_max                    = 127;
  dir           : dirstr      = 'c:\*.*'#0'                           ';
  wh            : integer     = -1;
  acchandle     : integer     = -1;
  aeshandle     : integer     = -1;
  vdihandle     : integer     = -1;
  charw         : integer     = 0;
  charh         : integer     = 0;
  charbw        : integer     = 0;
  charbh        : integer     = 0;
  minx          : integer     = 0;
  miny          : integer     = 0;
  maxw          : integer     = 0;
  maxh          : integer     = 0;
  atpos         : integer     = 0;
  atelement     : integer     = 0;
  winx          : integer     = 50;
  winy          : integer     = 50;
  winw          : integer     = 150;
  winh          : integer     = 100;
  accname       : string[17]  = '  Show Directory'#00#00;
  winname       : string[15]  = 'Directory'#00#00;
  wininfo       : string[150] = '  By David Gunby | '#00#00;

VAR
  big_array     : packed array [0..real_max] OF string [strnlen];
  pipe          : pipearray;

PROCEDURE alert (s  : string);
BEGIN
  s:='[3]['+s+'][  OK  ]';
  IF FORM_ALERT (1, s[1])=3 THEN ;
END;

FUNCTION strf (l  : longint;n : byte)  : string;
VAR
  s               : string[10];
BEGIN
  IF (l=0) AND (n=6) THEN s:='      ' 
  ELSE
    STR (l:n, s);
  strf:=s;
END;

PROCEDURE tidyup;
BEGIN
  IF wh>=0 THEN
  BEGIN
    WIND_CLOSE (wh);
    WIND_DELETE (wh);
  END;
  wh:=-1;
END;

PROCEDURE termchain;
BEGIN
  tidyup;
  V_CLSVWK (vdihandle);
  APPL_EXIT;
END;

PROCEDURE sort_bigarray;
VAR
  n, m                    : byte;
  s                       : string;
  doneone                 : boolean;
BEGIN
  IF max_elements=0 THEN EXIT;
  FOR m:=1 TO max_elements-1 DO
    FOR n:=1 TO (max_elements-1)-m DO
      IF big_array [n]>big_array [n+1] THEN
      BEGIN
        s:=big_array [n];
        big_array[n]:=big_array[n+1];
        big_array [n+1]:=s;
        doneone:=TRUE;
      END;
END;

FUNCTION prepname (s  : string) : string;
BEGIN
  WHILE (POS ('.', s)<9) AND (POS ('.', s)>0) DO
    INSERT (' ', s, POS ('.', s));
  WHILE (LENGTH (s)<13) DO
    s:=s+' ';
  prepname:=s;
END;

FUNCTION otherstuff (ok : searchrec)  : string;
VAR
  s             : string;
  d             : datetime;
BEGIN
  s:='';
  UNPACKTIME (ok.time, d);
  s:=s+'  '+strf (d.hour, 2)+':'+strf (d.min, 2);
  s:=s+'  '+strf (d.day, 2)+'/'+strf (d.month, 2)+'/'+strf (d.year, 4)+'  ';
  IF (ok.attr AND  1)= 1 THEN s:=s+'R' ELSE s:=s+'-';
  IF (ok.attr AND  2)= 2 THEN s:=s+'S' ELSE s:=s+'-';
  IF (ok.attr AND  4)= 4 THEN s:=s+'H' ELSE s:=s+'-';
  IF (ok.attr AND  8)= 8 THEN s:=s+'V' ELSE s:=s+'-';
  IF (ok.attr AND 16)=16 THEN s:=s+'D' ELSE s:=s+'-';
  IF (ok.attr AND 32)=32 THEN s:=s+'A' ELSE s:=s+'-';
  otherstuff:=s;
END;

PROCEDURE readin;
VAR
  size              : longint;
  n                 : byte;
  ok                : searchrec;
BEGIN
  size:=0;
  n:=1;
  FINDFIRST (dir, $3f, ok);
  WHILE (DOSERROR=0) AND (n<real_max) DO
  BEGIN
    size:=size+ok.size;
    big_array [n]:='  '+prepname (ok.name)+'  '+strf (ok.size, 6);
    big_array [n]:=big_array [n]+otherstuff (ok);
    IF (ok.attr AND $10)=$10 THEN big_array[n][1]:=#7;
    INC (n);
    FINDNEXT (ok);
  END;
  DEC (n);
  max_elements:=n;
  n:=LENGTH (wininfo);
  WHILE (wininfo[n]<>'|')  AND (n>0) DO
    DEC (n);
  DELETE (wininfo, n, LENGTH (wininfo));
  wininfo:=wininfo+'| '+dir+#00+#00;
  sort_bigarray;
  big_array [0]:=strf (max_elements-1, 0)+' items in '+strf (size, 0)+' bytes ('+strf (size DIV 1024, 0)+'K)';
END;

PROCEDURE setup;
VAR
  n               : byte;
  workin          : intin_array;
  workout         : workout_array;
BEGIN
  readin;
  aeshandle:=APPL_INIT;
  vdihandle:=graf_handle (charw, charh, charbw, charbh);
  FOR n:=0 TO 9 DO
    workin[n]:=1;
  workin[10]:=2;
  V_OPNVWK (workin, vdihandle, workout);
  WIND_GET (0, WF_FULLXYWH, minx, miny, maxw, maxh);
END;

PROCEDURE setslidersize;
VAR
  hsize, hat, wsize, wat,
  x, y, w, h        : integer;
BEGIN
  WIND_CALC (1, elements, winx, winy, winw, winh, x, y, w, h);
  hsize:=MIN (1000, ROUND (1000*(w / charw) / strnlen));
  IF max_elements=0 THEN wsize:=1000
    ELSE wsize:=MIN (1000, ROUND (1000*(h / charh) / max_elements));
  WIND_SET (wh, WF_HSLSIZE, hsize, 0, 0, 0);
  WIND_SET (wh, WF_VSLSIZE, wsize, 0, 0, 0);
  IF atpos<>0 THEN
    wat:=ROUND (1000*((atpos)/(strnlen-(w DIV charw))))
  ELSE
    wat:=0;
  IF atelement<>0 THEN
    hat:=ROUND (1000*((atelement)/(max_elements-(h DIV charh))))
  ELSE
    hat:=0;
  WIND_SET (wh, WF_HSLIDE, wat, 0, 0, 0);
  WIND_SET (wh, WF_VSLIDE, hat, 0, 0, 0);
END;

FUNCTION getline (atline : integer)  : string;
VAR
  m                   : integer;
  linestr             : string;
BEGIN
  linestr:='   '+big_array[atline];
  linestr:=linestr+#0+#0;
  getline:=linestr;
END;

PROCEDURE doredraw;
VAR
  b1, b2        : grect;
  a             : array_4;
  atline,
  n             : integer;
  linestr       : string;
BEGIN
  WIND_UPDATE (BEG_UPDATE);
  GRAF_MOUSE (M_OFF, NIL);
  b1.x:=pipe[4];
  b1.y:=pipe[5];
  b1.w:=pipe[6];
  b1.h:=pipe[7];
  VSF_COLOR (vdihandle, WHITE);
  VSF_STYLE (vdihandle, SOLID);
  WIND_GET (wh, WF_FIRSTXYWH, b2.x, b2.y, b2.w, b2.h);
  WHILE (b2.w<>0) AND (b2.h<>0) DO
  BEGIN
    IF intersect (b1, b2) THEN
    BEGIN
      a[0]:=b2.x;
      a[1]:=b2.y;
      a[2]:=b2.x+b2.w-1;
      a[3]:=b2.y+b2.h-1;
      VS_CLIP (vdihandle, 1, a);
      V_BAR (vdihandle, a); 
      n:=b2.y+charbh;
      atline:=ROUND (atelement +((b2.y-(winy+(2*charh))) / charh))-1;
      INC (b2.h, charh);
      REPEAT
        IF atline<=max_elements THEN
        BEGIN 
          linestr:=getline (atline);
          V_GTEXT (vdihandle, (b2.x DIV charw)*charw, ((n-1) DIV charh)*charh , 
            COPY (linestr, (atpos+((b1.x-winx) DIV charw))+1, (b2.w DIV charw)+1));
        END;
        INC (atline);
        INC (n, charh);
      UNTIL n>b2.y+b2.h;
    END;
    WIND_GET (wh, WF_NEXTXYWH, b2.x, b2.y, b2.w, b2.h);
  END;  
  GRAF_MOUSE (M_ON, NIL);
  WIND_UPDATE (END_UPDATE);
END;

PROCEDURE send_redraw;
BEGIN
  pipe[0]:=WM_REDRAW;
  pipe[3]:=wh;
  pipe[4]:=winx;
  pipe[5]:=winy;
  pipe[6]:=winw;
  pipe[7]:=winh;
  APPL_WRITE (aeshandle, SIZEOF (pipe), pipe);
END;

PROCEDURE openwindow;
BEGIN
  IF wh<0 THEN
  BEGIN
    wh:=WIND_CREATE (elements, minx, miny, maxw, maxh);
    IF wh>=0 THEN
    BEGIN
      WIND_SET (wh, WF_NAME, HIPTR (winname[1]), LOPTR (winname[1]), 0, 0);
      WIND_SET (wh, WF_INFO, HIPTR (wininfo[1]), LOPTR (wininfo[1]), 0, 0);
      setslidersize;
      WIND_OPEN (wh, winx, winy, winw, winh);
      WIND_SET (wh, WF_PREVXYWH, minx, miny, maxw, maxh);
    END ELSE alert ('||Window Creation error');
  END ELSE   
    send_redraw;
END;

PROCEDURE window (x, y, w, h  : integer);
BEGIN
  winx:=((x DIV charw) *charw)+2;
  winy:=((y DIV charh) *charh)+2;
  winw:=w;
  winh:=h;
  WIND_SET (wh, WF_CURRXYWH, winx, winy, w, h);
  setslidersize;
END;

PROCEDURE full_window;
VAR
  x, y, w, h            : integer;
BEGIN
  WIND_GET (wh, WF_PREVXYWH, x, y, w, h);
  window (x, y, w, h);
END;

PROCEDURE hslidtopos;
VAR
  x, y, w, h        : integer;
BEGIN
  WIND_CALC (1, elements, winx, winy, winw, winh, x, y, w, h);
  atpos:=ROUND ((pipe[4] / 1000)*(strnlen-(w DIV charw)));
  WIND_SET (wh, WF_HSLIDE, pipe[4], 0, 0, 0);
  send_redraw;
END;

PROCEDURE vslidtopos;
VAR
  x, y, w, h        : integer;
BEGIN
  WIND_CALC (1, elements, winx, winy, winw, winh, x, y, w, h);
  atelement:=ROUND ((pipe[4] / 1000)*(max_elements-(h DIV charh)+1));
  WIND_SET (wh, WF_VSLIDE, pipe[4], 0, 0, 0);
  send_redraw;
END;

PROCEDURE doarrows;
VAR
  ph, pw          : integer;
BEGIN
  ph:=((winh-(3*charbh)) DIV charh);
  pw:=(winw-(2*charbw)) DIV charw;
  CASE pipe[4] OF
    1 : atelement:=MIN (atelement+ph, max_elements-ph+1);
    0 : atelement:=MAX (0, atelement-ph);
    3 : atelement:=MIN (atelement+1, max_elements-ph+1);
    2 : atelement:=MAX (0, atelement-1);
    5 : atpos:=MIN (atpos+pw, strnlen-pw);
    4 : atpos:=MAX (atpos-pw, 0);
    7 : atpos:=MIN (atpos+1, strnlen-pw);
    6 : atpos:=MAX (atpos-1, 0);
  END;
  setslidersize;
  send_redraw;
END;

PROCEDURE topwindow;
VAR
  n, m              : integer;
BEGIN
  WIND_SET (wh, WF_TOP, winx, winy, winw, winh);
END;

PROCEDURE doclipboard;
VAR
  myfile            : text;
  s                 : string;
  m                 : integer;
  ok                : searchrec;
BEGIN
  SCRP_READ (s[1]);
  m:=1;
  REPEAT
    s[0]:=CHAR (m);
    INC (m);
  UNTIL s[m]=#0;
  IF s='' THEN s:='A:\SCRAP'+#0;
  IF (DRVMAP AND 4)=4 THEN s[1]:='C';
  SCRP_WRITE (s[1]);
  FINDFIRST (s, $10, ok);
  IF DOSERROR<>0 THEN MKDIR (s);
  IF s[LENGTH (s)]<>'\' THEN s:=s+'\';
  FINDFIRST (s+'SCRAP.*', $27, ok);
  WHILE DOSERROR=0 DO
  BEGIN
    ERASE (s+ok.name);
    FINDNEXT (ok);
  END;
  ASSIGN (myfile, s+'SCRAP.TXT');
  REWRITE (myfile);
  FOR m:=0 TO max_elements DO
  BEGIN
    s:=getline (m);
    WHILE (POS (#0, s)<>0) DO
      DELETE (s, POS (#0, s), 1);
    WRITELN (myfile, s);
  END;
  CLOSE (myfile);
END;

PROCEDURE getnewpath;
VAR
  dir2        : dirstr;
  name        : string[20];
  n           : integer;
BEGIN
  name:=#0;
  dir:=dir+#0;
  dir2:=dir;
  FSEL_INPUT (dir[1], name[1], n);
  IF n=1 THEN
    readin
  ELSE
    dir:=dir2;
  WIND_SET (wh, WF_INFO, HIPTR (wininfo), LOPTR (wininfo), 0, 0);
END;

PROCEDURE acopen;
VAR
  s           : string;
  n, m        : integer;
BEGIN
  openwindow;
  s:='[1][    Pipe Monitor|   By David Gunby|(in HighSpeed Pascal)][  OK  | MORE | DIR ]'#0#0;
  n:=FORM_ALERT (3, s[1]);
  IF n=3 THEN 
  BEGIN
    getnewpath;
    EXIT;
  END;
  IF n=1 THEN EXIT;
  alert ('|David Gunby, 12 Windrush Drive|Oadby, Leicester,LE2 4GH');
  s:='[2][||Output To Which Device][ Printer | ClipBoard | Non ]'+#0+#0;
  n:=FORM_ALERT (1, s[1]);
  IF (n=1) THEN FOR m:=0 TO max_elements DO
                  WRITELN (lst, getline (m));
  IF (n=2) THEN doclipboard;     
END;

PROCEDURE evnt_mesag (VAR pipe : pipearray);
VAR
  k, rt, d            : integer;
BEGIN
  REPEAT
    pipe[0]:=32123;
    pipe[4]:=32123;
    WIND_GET (0, WF_TOP, k, rt, rt, rt);
    IF k=wh THEN d:=17 ELSE d:=16;
    rt:=EVNT_MULTI (d, 0, 0, 0, 0, 0, 0, 0, 0, 
                    0, 0, 0, 0, 0, pipe, 0, 0, 
                    d, d, d, d, k, d);
    IF (rt=1) THEN
    BEGIN
      CASE k OF
        $6200 : pipe[0]:=AC_OPEN;
        24832 : pipe[0]:=AC_CLOSE;
        $4800 : pipe[4]:=2;
        $5000 : pipe[4]:=3;
        $4b00 : pipe[4]:=6;
        $4d00 : pipe[4]:=7;
      END;
      IF pipe[4]<>32123 THEN pipe[0]:=WM_ARROWED;
    END;
  UNTIL pipe[0]<>32123;
END;

PROCEDURE domainloop;
VAR
  n              : byte;
  byebye          : boolean;
BEGIN
  REPEAT
    byebye:=FALSE;
    evnt_mesag (pipe);
    CASE pipe[0] OF
      MN_SELECTED : ;
      WM_FULLED   : full_window;
      WM_REDRAW   : doredraw;
      WM_ARROWED  : IF max_elements>0 THEN doarrows;
      WM_HSLID    : hslidtopos;
      WM_VSLID    : IF max_elements>0 THEN vslidtopos;
      WM_MOVED,
      WM_SIZED    : window (pipe[4], pipe[5], pipe[6], pipe[7]);
      WM_TOPPED   : topwindow;
      AC_OPEN     : acopen;
      30,
      33          : WIND_SET (wh, 25, winx, winy, winw, winh);
      WM_CLOSED,
      AC_CLOSE    : IF APPFLAG THEN byebye:=TRUE ELSE tidyup;
    END;
  UNTIL byebye=TRUE;
END;

BEGIN
  GRAF_MOUSE (2, NIL);
  setup;
  IF APPFLAG THEN 
  BEGIN
    wininfo:=' Press HELP | '+wininfo;
    openwindow
  END ELSE acchandle:=menu_register (aeshandle, accname[1]);
  GRAF_MOUSE (0, NIL);
  domainloop;
  termchain;
END.