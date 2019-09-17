PROGRAM windowdemo6;
USES gemaes, gemdecl, gemvdi, {gem, util, ppal,} dos, printer;
CONST
  fname = 'ADDFILE.DJG';
  maxe  = 80;
  drive = '';

TYPE 
  ob_Type         = g_box..g_title;
  object          = packed record
    ob_next       : integer;
    ob_head       : integer;
    ob_tail       : integer;
    ob_type       : integer;   
    ob_flags      : integer;
    ob_state      : integer;
    ob_spec       : pointer;
    ob_x          : integer;
    ob_y          : integer;
    ob_w          : integer;
    ob_h          : integer;
  END;
  tree            = packed array[0..199] OF object;
  tree_ptr        = ^tree;
  string10              = packed string [10];
  string30              = packed string [30];
  ms                    = packed array [0..10] OF string30;

VAR
  nameline, infoline    : string30;
  x, y, w, h, p, acchan : integer;
  tstring               : packed array [0..10] OF string10;
  mestring, f2          : ms;
  ontop                 : boolean;
  myfile                : packed file OF ms;
  main                  : tree_ptr;
  hello                 : tree_ptr;
  pipe                  : array_8;
  vdihan, wh, aeshan,
  charh, charw, 
  minx, miny, maxw, maxh      : integer;
  s : string30;

PROCEDURE upper (VAR me     : string30);
VAR
  n                         : byte;
BEGIN
  FOR n:=1 TO LENGTH (me) DO
    me[n]:=UPCASE (me[n]);
END;

PROCEDURE openfile;
VAR
  ok                    : searchrec;
BEGIN
  ASSIGN (myfile, drive+fname);
  FINDFIRST (drive+fname, $27, ok);
  IF DOSERROR=0 THEN RESET (myfile)
    ELSE REWRITE (myfile);
END;

PROCEDURE setlen (VAR mstring  : ms);
VAR
  x, y                  : integer;
BEGIN
  FOR x:=0 TO 10 DO
  BEGIN
    y:=1;
    WHILE (mstring[x][y]<>#0) AND (y<=30) DO
    BEGIN
      mstring[x][0]:=CHAR(y);
      INC (y);
    END;
    FILLCHAR (mstring[x][y], 30-y, #0);
  END;
END;

PROCEDURE readinfo;
BEGIN
  IF FILESIZE (myfile)>0 THEN 
  BEGIN
    SEEK (myfile, p);
    READ (myfile, mestring);
    setlen (mestring);
  END;
END;

PROCEDURE setts;
VAR
  n                     : integer;
BEGIN
  tstring[0]:='Name      :';
  tstring[1]:='Company   :';
  tstring[2]:='Street    :';
  tstring[3]:='Town      :';
  tstring[4]:='City      :';
  tstring[5]:='Other     :';
  tstring[6]:='Post Code :';
  tstring[7]:='Tel       :';
  tstring[8]:='Fax       :';
  tstring[9]:='Comment   :';
  FOR n:=0 TO 10 DO
    mestring[n][1]:=#00;
END;

PROCEDURE rscload(rscname : string);
BEGIN
  rscname:=rscname+#00;
  rsrc_load (rscname[1]);
  IF GemError = 0 THEN
  BEGIN
    Writeln(rscname,' could not be found');
    appl_exit;
    EXIT;
  END;
END;

PROCEDURE openrsc;
BEGIN
  rscload (drive+'ADDBOOK.RSC');
  RSRC_GADDR (R_TREE, 0, hello);
  RSRC_GADDR (R_TREE, 1, main);
END;

PROCEDURE movestpos;
VAR
  n                   : integer;
  f                   : ^longint;
BEGIN
  FOR n:=6 TO 15 DO
  BEGIN
    f:=main^[n].ob_spec;
    f^:=ORD (ADDR (mestring[n-6][1]));
  END;
END;

PROCEDURE puttextline;
VAR
  i, d                  : integer;
BEGIN
  setlen (mestring);
  WIND_GET (pipe[3], WF_WORKXYWH, x, y, w, h);
  i:=charh;
  d:=0;
  WHILE (i<=y+h-1+charh) AND (d<10) DO
  BEGIN
    V_GTEXT (vdihan, x+5, y+i, tstring[d]+' '+mestring[d]);
    INC (i, charh);
    INC (d);
  END;
END;

PROCEDURE redrawwindow;
VAR
  r1, r2              : grect;
  a                   : array_4;
BEGIN
  IF wh<0 THEN EXIT;
  WIND_GET (wh, WF_CURRXYWH, r1.x, r1.y, r1.w, r1.h);
  WIND_UPDATE (BEG_UPDATE);
  GRAF_MOUSE (M_OFF, NIL);
  VSF_COLOR (vdihan, WHITE);
  VSF_STYLE (vdihan, SOLID);
  WIND_GET (pipe[3], WF_FIRSTXYWH, r2.x, r2.y, r2.w, r2.h);
  WHILE ((r2.w<>0) AND (r2.h<>0)) DO
  BEGIN
    IF INTERSECT (r1, r2) THEN
    BEGIN
      a[0]:=r2.x;                 a[1]:=r2.y;
      a[2]:=r2.x+r2.w-1;          a[3]:=r2.y+r2.h-1;
      VS_CLIP (vdihan, 1, a);
      V_BAR (vdihan, a);
      puttextline;
    END;  
    WIND_GET (pipe[3], WF_NEXTXYWH, r2.x, r2.y, r2.w, r2.h);
  END;
  VS_CLIP (vdihan, 0, a);
  GRAF_MOUSE (M_ON, NIL);
  WIND_UPDATE (END_UPDATE);
END;

PROCEDURE findad;
VAR
  n                     : integer;
  byebye, go            : boolean;
BEGIN
  openfile;
  setlen (f2);
  FOR n:=0 TO 9 DO
    upper (f2[n]);
  n:=0;
  go:=FALSE;
  WHILE (NOT (EOF (myfile))) AND (NOT (go)) DO
  BEGIN
    n:=0;
    byebye:=TRUE;
    readinfo;
    setlen (mestring);
    IF POS ('DELETED', mestring[0])=1 THEN byebye:=FALSE;
    REPEAT
      upper (mestring[n]);
      IF f2[n][1]<>#0 THEN 
        IF (POS (f2[n], mestring[n])=0) THEN byebye:=FALSE;
      INC (n);
    UNTIL (byebye=FALSE) OR (n=9);
    IF (n=9) AND (byebye=TRUE) THEN go:=TRUE;
    INC (p);
  END;
  IF (go) AND (FILESIZE (myfile)>0) THEN 
  BEGIN
    p:=FILEPOS (myfile)-1;
    SEEK (myfile, p);
    READ (myfile, mestring);
    setlen (mestring);
    CLOSE (myfile);
  END;
  redrawwindow;
END;

PROCEDURE find;
BEGIN
  p:=0;
  f2:=mestring;
  findad;
END;

PROCEDURE setupwindow;
VAR
  oldwh                 : integer;
BEGIN
  oldwh:=wh;
  IF wh<0 THEN
  BEGIN
    nameline:='Another Address Book'+#0+#0;
    wh:=WIND_CREATE (223-info, minx, miny, 365, 15+(10*charh));
  END;
  WIND_SET (wh, WF_NAME, HIPTR (nameline[1]), LOPTR (nameline[1]), 0, 0);
  WIND_SET (wh, WF_INFO, HIPTR (infoline[1]), LOPTR (infoline[1]), 0, 0);
  IF (oldwh<0) AND (wh>=0) THEN
  BEGIN
    WIND_GET (wh, WF_FULLXYWH, x, y, w, h);
    WIND_OPEN (wh, x, y, w, h);
  END ELSE IF wh>=0 THEN WIND_SET (wh, WF_TOP, 0, 0, 0, 0);
  pipe[3]:=wh;  pipe[4]:=x;   pipe[5]:=y;
  pipe[6]:=w;   pipe[7]:=h;
  redrawwindow;
  ontop:=TRUE;
END;

PROCEDURE addaddress;
BEGIN
  openfile;
  SEEK (myfile, FILESIZE (myfile));
  WRITE (myfile, mestring);
  CLOSE (myfile);
END;

PROCEDURE moveadd;
VAR
  spare                       : integer;
BEGIN
  spare:=0;
  openfile;
  IF (pipe[4]=3) AND (p<FILESIZE (myfile)-1) THEN INC (p)
    ELSE IF (p>0) AND (pipe[4]=2) THEN DEC (p);
  readinfo;
  setlen (mestring);
  WHILE (mestring[0]='DELETED') AND (spare<10) DO
  BEGIN
    INC (spare);
    readinfo;
    INC (p);
    p:=p MOD FILESIZE (myfile);
  END;
  IF spare=10 THEN p:=0;
  CLOSE (myfile);
  redrawwindow;
END;

PROCEDURE print;
VAR
  n                     : integer;
BEGIN
  openfile;
  readinfo;
  setlen (mestring);
  FOR n:=0 TO 8 DO
    WRITELN (lst, '         ', mestring[n]);
  CLOSE (myfile);
END;

PROCEDURE clipboard;
VAR
  tfile                 : text;
  ok                    : searchrec;
  path                  : string30;
  olddrive, n           : byte;
  olddir                : dirstr;
BEGIN
  openfile;
  readinfo;
  CLOSE (myfile);
  SCRP_READ (olddir[1]);
  IF olddir='' THEN
  BEGIN
    FINDFIRST ('C:\', anyfile, ok);
    IF DOSERROR <>0 THEN path:='C:\' ELSE path:='A:\';
    FINDFIRST (path+'CLIPBRD\', directory, ok);
    IF DOSERROR<>0 THEN MKDIR (path+'CLIPBRD\');
    olddir:=path+'CLIPBRD\';
  END;
  FINDFIRST (olddir+'scrap.*',$27, ok);
  WHILE DOSERROR=0 DO
  BEGIN
    ERASE (olddir+ok.name);
    FINDNEXT (ok);
  END;
  setlen (mestring);
  ASSIGN (tfile, olddir+'SCRAP.TXT');
  REWRITE (tfile);
  FOR n:=0 TO 9 DO
    Writeln (tfile, mestring[n]);
  CLOSE (tfile);
  olddir:=olddir+#0;
  scrp_write (olddir[1]);
END;

PROCEDURE edit;
BEGIN
  openfile;
  SEEK (myfile, p);
  setlen (mestring);
  WRITE (myfile, mestring);
  CLOSE (myfile);
  redrawwindow;
END;

PROCEDURE delete;
BEGIN
  openfile;
  IF FILESIZE (myfile)>0 THEN
  BEGIN
    readinfo;
    mestring[0]:='DELETED'+#0;
    setlen (mestring);
    SEEK (myfile, p);
    WRITE (myfile, mestring);
    IF (p>0) THEN DEC (p) ELSE 
      IF p<FILESIZE (myfile) THEN INC (p)
        ELSE p:=0;
  END;
  CLOSE (myfile);
  moveadd;
END;

PROCEDURE setobjectstatus (t  : tree_ptr; index, stat  : integer);
BEGIN
  t^[index].ob_state:=stat;
END;

FUNCTION drawform (thistree : tree_ptr;n  : integer) : integer;
VAR
  d                          : integer;
BEGIN
  WITH thistree^[0] DO
  BEGIN
    d:=ob_x;
    form_center (thistree, minx, miny, maxw, maxh);
    form_dial (fmd_start, 0, 0, 0, 0, minx, miny, maxw, maxh);
    form_dial (fmd_grow , d, d, d, d, d, d, d, d);
    objc_draw (thistree,  0, $7fff, minx, miny, maxw, maxh);
    IF n>=0 THEN n:=form_do (thistree, n);
    form_dial (fmd_shrink, d, d, d, d, d, d, d, d);
    form_dial (fmd_finish, 0, 0, 0, 0, minx, miny, maxw, maxh);
    setobjectstatus (thistree, n, thistree^[n].ob_state-1);
  END;
  drawform:=n;
END;

PROCEDURE sayhello;
VAR
  n                     : integer;
BEGIN
  n:=drawform (hello, 0);
  setobjectstatus (hello, 9, 48);
END;

PROCEDURE fullwindow;
VAR
  sx, sy, sw, sh        : integer;
BEGIN
  setts;
  sx:=drawform (main, 6);
  setobjectstatus (main, sx, 48);
  CASE sx OF
    3   : addaddress; {accept}
    4   : setts; {cancel}
    16  : find; {find}
    17  : sayhello; {hello}
    18  : print; {print}
    19  : clipboard; {to clip board}
    20  : delete; {delete}
    25  : edit; {edit}
  END;
END;

PROCEDURE sendmessage;
VAR
  n                     : integer;
BEGIN
  n:=pipe[1];
  pipe[0]:=69;
  pipe[1]:=aeshan;
  pipe[2]:=1;
  openfile;
  SEEK (myfile, p);
  READ (myfile, mestring);
  setlen (mestring);
  CLOSE (myfile);
  pipe[3]:=HIPTR (mestring);
  pipe[4]:=LOPTR (mestring);
  pipe[5]:=p;
  APPL_WRITE (n, SIZEOF(pipe), pipe[0]);
END;

PROCEDURE closedownwindow;
BEGIN
  IF wh>=0 THEN 
  BEGIN
    WIND_CLOSE (wh);
    WIND_DELETE (wh);
    wh:=-1;
  END;
  ontop:=FALSE;
END;

PROCEDURE shutdown;
BEGIN
  graf_shrinkbox (0, 0, 0, 0, minx, miny, maxw, maxh);
  rsrc_free;
  v_clsvwk (vdihan);
  appl_exit;
END;

PROCEDURE windowbits;
BEGIN
  CASE pipe[0] OF
    41  : wh:=-1; 
    22  : IF APPFLAG THEN BEGIN
            wh:=-1;                        { Accessory closed }
            closedownwindow;
            shutdown;
            HALT;
          END ELSE closedownwindow;
    20  : redrawwindow;                           { Window redraw requested }
    21  : setupwindow;                            { Window topped }
    23  : fullwindow;                             { Window full "button" was hit }
    24  : moveadd;                                { One of the slider bar arrows was hit }
    28  : WIND_SET (pipe[3], WF_CURRXYWH,
            pipe[4], pipe[5], MAX (70,pipe[6]), MAX (50,pipe[7]));
                                                  { Window moved }
    29  : ontop:=FALSE;
    40  : setupwindow;                            { Accessory opened }
    69  : sendmessage;
  END;
END;

PROCEDURE handlesearch (mx, my, mb  : integer);
BEGIN
  IF FILEPOS (myfile)=0 THEN EXIT;
  WIND_GET (wh, WF_TOP, x, y, w, h);
  IF (x=wh) AND (mb=1) THEN
  BEGIN
    WIND_GET (wh, WF_WORKXYWH, x, y, w, h);
    IF (mx>x) AND (mx<(x+w)) AND (my>y) AND (my<(y+h)) THEN
    BEGIN
      openfile;
      IF FILESIZE (myfile)>p+1 THEN INC (p)
        ELSE p:=0;
      CLOSE (myfile);
      findad;
    END;
  END;
END;

PROCEDURE mainloop;
VAR
  mx, my, mb, u,  
  rt, k, dummy, t1, t2  : integer;
  byebye                : boolean;
BEGIN
  byebye:=FALSE;
  WHILE (NOT (byebye)) OR (NOT (APPFLAG)) DO
  BEGIN
    IF ontop THEN u:=19 ELSE u:=17;
    rt:=evnt_multi (u, 1, 2, 1, 0, 0, 0, 
                    0, 0, 0, 0, 0, 0, 0, pipe[0], 0, 0,
                    mx, my, mb, dummy, k, dummy);
    IF (rt AND 1) = 1 THEN IF (k=$11b) AND (APPFLAG) THEN byebye:=TRUE;
    IF ((rt AND 2) = 2) AND (ontop) THEN handlesearch (mx, my, mb);
    IF (rt AND 16)=16 THEN windowbits;
  END;
END;

FUNCTION setupgem : boolean;
VAR
  n               : integer;
  income          : intin_array;
  outward         : workout_array;
BEGIN
  n:=0;
  aeshan:=appl_init;
  vdihan:=graf_handle (charw, charh, n, n);
  IF (vdihan<0) OR (aeshan<0) THEN setupgem:=FALSE
    ELSE setupgem:=TRUE;
  FOR n:=0 TO 9 DO
    income[n]:=1;
  income[10]:=2;
  v_opnvwk (income, vdihan, outward);
  wind_get (0, 7, minx, miny, maxw, maxh );
END;

BEGIN
  ontop:=FALSE;
  s:='  Address Book'+#0;
  openrsc;
  p:=0;
  wh:=-1;
  setts;
  movestpos;
  moveadd;
  IF setupgem THEN GRAF_MOUSE (arrow, NIL);
  IF APPFLAG THEN setupwindow
    ELSE acchan:=menu_register (aeshan, s[1]);
  mainloop;
  closedownwindow;
  shutdown ;
END.