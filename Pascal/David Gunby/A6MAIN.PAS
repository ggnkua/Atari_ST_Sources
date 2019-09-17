{
  hello, this is the start to a direct to disk address book in pascal
  it sorts the addresses as they are added
  
  but only works if you quit after adding each address
  
  the problem seems to be that when a record is added to the main 
  holder file it can not be reaccessed until the program is restarted

}
PROGRAM a6main;
USES gemaes, gemdecl, gemvdi, ppal, util, gem, dos, bios;
CONST
  rscname               = 'A6.RSC';
  filename              = 'NAMEFILE.DJG';

{ IMPORTANT pascal strings are diffent to C strings
    a element 0 of a pascal string in the length not the 
    first char }

TYPE    { data strutures }
  string30              = packed string [30];
  array9                = packed array [0..9] OF string30;
  frecord               = packed record { structure of the file }
    prev, next          : longint;  { 32bit signed }
    info                : array9;
  END;
  dfile                 = packed file OF frecord;

VAR
  s                     : string25;
  xp, yp, wp, hp, acchan: integer;  { 16 bit signed }
  mainfile              : dfile;
  holder                : frecord;
  start, fin, p         : longint;
  drive                 : dirstr;
  main                  : tree_ptr;

FUNCTION filesize       : longint;  { this is where I thought the problem
                                      was to start }
VAR
  ok                    : searchrec;
BEGIN
  FINDFIRST (drive+filename, $27, ok);
  filesize:=ok.size DIV SIZEOF (frecord);
  GOTOXY (50, 1);
  write (ok.size DIV SIZEOF (frecord));
END;

PROCEDURE movestpos;  { sets un ICHARBOX es }
VAR
  n                   : integer;
  f                   : ^longint;
BEGIN
  FOR n:=6 TO 15 DO
  BEGIN
    f:=main^[n].ob_spec;
    f^:=ORD (ADDR (holder.info[n-6][1]));
  END;
END;

PROCEDURE setlen;  { converts gem C strings to pascal strings}
VAR
  n, m                  : byte;
BEGIN
  FOR n:=0 TO 9 DO
    WITH holder DO
    BEGIN
      m:=1;
      REPEAT
        INC (m);
      UNTIL info[n][m]=#0;
      info[n][0]:=CHAR (m);
    END;  
END;

PROCEDURE clearhold;
VAR
  n                     : byte;
BEGIN
  FOR n:=0 TO 9 DO
    holder.info[n]:=#0;
END;

PROCEDURE setupfileinfo;
BEGIN
  SEEK (mainfile, 0);
  READ (mainfile, holder);
  start:=holder.next;
  fin:=holder.prev;
END;

PROCEDURE openfile; { opens and sets up the file }
VAR
  ok                    : searchrec;
BEGIN
  ASSIGN (mainfile, drive+filename);
  FINDFIRST (drive+filename, $27, ok);
  IF DOSERROR=0 THEN RESET (mainfile) 
  ELSE BEGIN
    REWRITE (mainfile);
    holder.prev:=0;
    holder.next:=0;
    WRITE (mainfile, holder);
  END;
  setupfileinfo;
END;

PROCEDURE setupvars;
BEGIN
  openfile;
  CLOSE (mainfile);
  wh:=-1;
  s:='Address Book'+#0+#0;
  p:=start;
END;

PROCEDURE readinfo (p   : longint);
BEGIN
  IF FILESIZE<p THEN EXIT;
  SEEK (mainfile, p);
  READ (mainfile, holder);
END;

PROCEDURE writeinfo (p  : longint);
BEGIN
  IF FILESIZE<p THEN EXIT;
  SEEK (mainfile, p);
  WRITE (mainfile, holder);
END;

PROCEDURE set0 (prev, next    : longint);
VAR
  spare         : frecord;
  n             : longint;
BEGIN
  n:=FILEPOS (mainfile);
  SEEK (mainfile, 0);
  READ (mainfile, spare);
  IF prev<>-1 THEN spare.prev:=prev;
  IF next<>-1 THEN spare.next:=next;
  SEEK (mainfile, 0);
  WRITE (mainfile, spare);
  SEEK (mainfile, n);
END;

PROCEDURE addnode;  { this adds an address and works if you quit between
                      adding addresses }
VAR
  byebye                : boolean;
  spare                 : frecord;
  op, i                 : longint;
BEGIN
  setlen;
  spare:=holder;
  openfile;
  byebye:=FALSE;
  op:=start;
  REPEAT
    readinfo (op);
    IF (holder.info[0]>spare.info[0]) OR (op=0) THEN byebye:=TRUE
      ELSE op:=holder.next;
  UNTIL (byebye) OR (op=0);
  IF (start=op) THEN
  BEGIN
    holder.prev:=FILESIZE;
    writeinfo (start);
    holder:=spare;
    holder.prev:=0;
    holder.next:=start;
    start:=FILESIZE;
    set0 (-1, FILESIZE);
    writeinfo (FILESIZE);
  END ELSE IF op=0 THEN BEGIN
    op:=fin;
    set0 (FILESIZE, -1);
    fin:=FILESIZE;
    readinfo (op);
    holder.next:=FILESIZE;
    writeinfo (op);
    holder:=spare;
    holder.next:=0;
    holder.prev:=op;
    writeinfo (FILESIZE);
  END ELSE BEGIN
    i:=holder.prev;
    holder.prev:=FILESIZE;
    writeinfo (op);
    readinfo (i);
    holder.next:=FILESIZE;
    writeinfo (i);
    holder:=spare;
    holder.next:=op;
    holder.prev:=i;
    writeinfo (FILESIZE);
  END;
  CLOSE (mainfile);
  p:=op;
END;

PROCEDURE openrsc;
BEGIN
  rscload (drive+rscname);
  RSRC_GADDR (R_TREE, 0, hello);
  RSRC_GADDR (R_TREE, 1, main);
END;

PROCEDURE windupoff;
BEGIN
  GRAF_MOUSE (M_ON, NIL);
  WIND_UPDATE (END_UPDATE);
END;

PROCEDURE windupon;
BEGIN
  WIND_UPDATE (BEG_UPDATE);
  GRAF_MOUSE (M_OFF, NIL);
  VSF_COLOR (vdihan, WHITE);
  VSF_STYLE (vdihan, SOLID);
END;

PROCEDURE closewindow;
BEGIN
  IF wh>0 THEN
  BEGIN
    WIND_CLOSE (wh);
    WIND_DELETE (wh);
    wh:=-1
  END;
END;

PROCEDURE clipon (x, y, w, h  : integer);
VAR
  a                   : array_4;
BEGIN
  a[0]:=x;
  a[1]:=y;
  a[2]:=x+w;
  a[3]:=y+h;
  VS_CLIP (vdihan, 1, a);
END;

PROCEDURE clipoff;
VAR
  a                   : array_4;
BEGIN
  VS_CLIP (vdihan, 0, a);
END;

PROCEDURE setslider;  { this dosn't work well }
VAR
  slid                : word;
BEGIN
  openfile;
  slid:=MAX (0, (ROUND (1000*((p-1) /(FILESIZE-2)))));
  WIND_SET (wh, WF_VSLIDE, slid, slid, slid, slid);
  CLOSE (mainfile);
END;

PROCEDURE puttext;
VAR
  n, m, x, y, w, h    : integer;
BEGIN
  WIND_GET (wh, WF_WORKXYWH, x, y, w, h);
  setslider;
  openfile;
  readinfo (p);
  CLOSE (mainfile);
  n:=y+charboxh-2;
  m:=0;
  WHILE n<y+h DO
  BEGIN
    V_GTEXT (vdihan, x+3, n, holder.info[m]);
    INC (m);
    INC (n, charh);
  END;
END;

PROCEDURE do_redraw;
VAR
  r1, r2              : grect;
  a                   : array_4;
BEGIN
  IF wh<0 THEN EXIT;
  WIND_GET (wh, WF_WORKXYWH, r1.x, r1.y, r1.w, r1.h);
  pipe[4]:=r1.x;  pipe[5]:=r1.y;  pipe [6]:=r1.w; pipe [7]:=r1.h;
  windupon;
  WIND_GET (pipe[3], WF_FIRSTXYWH, r2.x, r2.y, r2.w, r2.h);
  WHILE ((r2.w<>0) AND (r2.h<>0)) DO
  BEGIN
    IF (INTERSECT (r1, r2)) THEN
    BEGIN
      MAKEXYXY (r2, a);
      VS_CLIP (vdihan, 1, a);
      V_BAR (vdihan, a);
      puttext;
    END;  
    WIND_GET (pipe[3], WF_NEXTXYWH, r2.x, r2.y, r2.w, r2.h);
  END;
  VS_CLIP (vdihan, 0, a);
  windupoff;
END;

FUNCTION scan2ascii (n  : integer)  : char;
VAR
  hb, lb              : ^byte;
  spare               : longint;
  inhere              : char;
BEGIN
  hb:=@n;
  spare:=SUCC (ORD (hb));
  lb:=PTR (spare);
  inhere:=CHAR (lb^);
  IF (ORD (inhere)>30) AND (ORD (inhere)<255) THEN
    scan2ascii:=inhere
  ELSE
    CASE n OF
      $4800 : scan2ascii:=#1;
      $5000 : scan2ascii:=#2;
      $4b00 : scan2ascii:=#3;
      $4d00 : scan2ascii:=#4;
      $0e08 : scan2ascii:=#8;
      $0f09 : scan2ascii:=#9;
      $4700 : scan2ascii:=#12;
      $720d,
      $1c0d : scan2ascii:=#13;
      $11b  : scan2ascii:=#27;
    END;
END;

PROCEDURE openwindow;
VAR
  x                       : integer;
BEGIN
  IF wh<0 THEN 
  BEGIN
    wh:=WIND_CREATE (463, minx, miny, 30*charw, 11*charh);
    WIND_SET (wh, WF_NAME, HIPTR (s[1]), LOPTR (s[1]), x, x);
    IF wh>0 THEN WIND_OPEN (wh, 50, miny, 30*charw, 11*charh);
  END ELSE
    WIND_SET (wh, WF_TOP, xp, yp, wp, hp);
  pipe[3]:=wh;
  do_redraw;
END;

PROCEDURE slider;
BEGIN
  openfile;
  WIND_SET (wh, WF_VSLIDE, pipe[4], pipe[5], pipe[6], pipe[7]);
  p:=MAX (1, ROUND ((FILESIZE-1) *(pipe[4]/1000))); { do maths bit to sp }
  CLOSE (mainfile);
  do_redraw;
END;

PROCEDURE arrows;
BEGIN
  openfile;
  readinfo (p);
  CASE pipe[4] OF
    3, 1  : IF holder.next<>0 THEN p:=holder.next;
    2, 0  : IF holder.prev<>0 THEN p:=holder.prev;
  END;
  do_redraw;
  CLOSE (mainfile);
END;

FUNCTION drawmainform (n : integer) : integer;
BEGIN
  WITH main^[n] DO
  BEGIN
    FORM_CENTER (main, minx, miny, maxw, maxh);
    FORM_DIAL (FMD_START, minx, miny, maxw, maxh, minx, miny, maxw, maxh);
    OBJC_DRAW (main, n, 10, ob_x, ob_y, ob_w, ob_h);
    n:=FORM_DO (main, 6);
    DEC (main^[n].ob_state, 1);
    FORM_DIAL (FMD_FINISH, minx, miny, maxw, maxh, minx, miny, maxw, maxh);
  END;
  drawmainform:=n;
END;

PROCEDURE fuller;
VAR
  done            : boolean;
  n               : integer;
BEGIN
  done:=FALSE;
  n:=0;
  openfile;
  REPEAT
    n:=drawmainform (n);
    CASE n OF
      3   : addnode;{add}
      4   : done:=TRUE;{cancel}
      16  : ;{find}
      17  : sayhello;
      18  : ;{print}
      19  : ;{clipboard}
      20  : ;{delete}
      25  : ;{edit}
      26  : clearhold;
      27  : readinfo (p);{fetch}
    END;
    n:=0;
  UNTIL done;
  CLOSE (mainfile);
END;

PROCEDURE dopipe;
BEGIN
  CASE pipe[0] OF
    MN_SELECTED : ; {not used by this program}
    WM_REDRAW   : do_redraw;
    WM_TOPPED   : IF wh>0 THEN WIND_SET (wh, WF_TOP, 0, 0, 0, 0);
    WM_CLOSED   : closewindow;
    WM_FULLED   : fuller;
    WM_ARROWED  : arrows;
    WM_HSLID    : ;
    WM_VSLID    : slider ; 
    WM_SIZED    : ; { "" }
    WM_MOVED    : IF wh>0 THEN WIND_SET (wh, WF_CURRXYWH, pipe[4], pipe[5], pipe[6], pipe[7]);
    WM_NEWTOP   : ;
    AC_OPEN     : openwindow;
    AC_CLOSE    : wh:=-1;
  END;
END;

PROCEDURE domainloop;
VAR
  mx, my, mb, u,  
  rt, k, dummy, t1, t2  : integer;
  byebye                : boolean;
BEGIN
  byebye:=FALSE;
  WHILE (NOT (byebye)) OR (NOT (APPFLAG)) DO
  BEGIN
    byebye:=FALSE;
    rt:=evnt_multi (19, 1, 1, 1, 0, 0, 0, 
                    0, 0, 0, 0, 0, 0, 0, pipe[0], 0, 0,
                    mx, my, mb, dummy, k, dummy);
    IF ((rt AND 1) = 1) AND (scan2ascii (k)=#27) THEN 
                                BEGIN
                                  byebye:=TRUE;
                                  closewindow;
                                END ELSE ;
    IF ((rt AND 2) = 2) AND (ontop) THEN ;
    IF (rt AND 16)=16 THEN dopipe;
    IF (APPFLAG) AND (wh=-1) THEN byebye:=TRUE;
  END;
END;

BEGIN
  IF RUNFROMMEMORY THEN drive:='F:\SOURCE\PASCAL\' ELSE drive:='';
  IF setupgem THEN;
  setupvars;
  openrsc;
  movestpos;
  IF APPFLAG THEN openwindow
    ELSE acchan:=MENU_REGISTER (aeshan, s[1]);
  domainloop;  
  shutdown (NIL);
END.