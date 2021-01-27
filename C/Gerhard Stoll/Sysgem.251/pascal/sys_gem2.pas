(* ------------------------------------------------------------------- *)
(* Module Type          : *)  UNIT
(* Module Name          : *)  sys_gem2;
(* ------------------------------------------------------------------- *
 * Module Version       : 2.51                                         *
 * Module Date          : 10-11-95                                     *
 * Last Change          : 13-09-09 (by Markus Storcz)                  *
 * Author               : Andreas Pietsch                              *
 * Programming Language : Pure-Pascal                                  *
 * Copyright            : (c) 1995, Andrea Pietsch, 56727 Mayen        *
 * ------------------------------------------------------------------- *)

INTERFACE

USES    GEM;

(* -------------------------------------------------------------------
 * Konstanten
 * ------------------------------------------------------------------- *)

(* -------------------------------------------------------------------
 * Nachrichten von SysGem an eine Auswertungs-Funktion
 * ------------------------------------------------------------------- *)

CONST   SG_OPENICONIFIED = 0;
        SG_START         = 1;
        SG_NOWIN         = 2;
        SG_END           = 3;
        SG_END2          = 4;
        SG_REND          = 5;
        SG_REND2         = 6;
        SG_QUIT          = 7;
        SG_TIMER         = 8;
        SG_FTIMER        = 9;
        SG_POSX          = 10;
        SG_POSY          = 11;
        SG_VISIBLE       = 12;
        SG_INVISIBLE     = 13;
        SG_TOP           = 14;
        SG_UNTOP         = 15;
        SG_SIZED         = 16;
        SG_FULLED        = 17;
        SG_MOVED         = 18;
        SG_LCLICK1       = 19;
        SG_LCLICK2       = 20;
        SG_BUTTON        = 21;
        SG_BUTTON2       = 22;
        SG_RBUTTON       = 23;
        SG_RBUTTON2      = 24;
        SG_KEY           = 25;
        SG_EDKEY         = 26;
        SG_EDCHANGED     = 27;
        SG_MENU          = 28;
        SG_DRAGDROP      = 29;
        SG_HELP          = 30;
        SG_UNDO          = 31;
        SG_EXCEPTION     = 32;
        SG_TERMDENIED    = 33;
        SG_DRAWOWN       = 34;
        SG_SLIDER        = 35;
        SG_SLIDER2       = 36;
        SG_RSLIDER       = 37;
        SG_RSLIDER2      = 38;
        SG_3DSTATE       = 39;
        SG_CLIPBOARD     = 40;
        SG_CHILDEXIT     = 41;
        SG_SELECT        = 42;
        SG_DESELECT      = 43;
        SG_RADIO         = 44;
        SG_NEXTSTART     = 45;
        SG_NEWDIAL       = 46;
        SG_NEWFONT       = 47;
        SG_EDREDRAW      = 48;
        SG_LCIRCLE       = 49;
        SG_RCIRCLE       = 50;
        SG_RCLICK1       = 51;
        SG_RCLICK2       = 52;
        SG_TOUCH         = 53;
        SG_EMPTYSLDLINE  = 54;
        SG_LASTEDIT      = 55;
        SG_EDITABLE      = 56;
        SG_BEGINHELP     = 57;
        SG_ENDHELP       = 58;
        SG_POSITION      = 59;
        SG_SLDNEWPOS1    = 60;
        SG_SLDNEWPOS2    = 61;

(* -------------------------------------------------------------------
 * Werte fÅr GetParam
 * ------------------------------------------------------------------- *)

        PAR_HANDLE       = 0;
        PAR_CHARW        = 1;
        PAR_CHARH        = 2;
        PAR_BOXW         = 3;
        PAR_BOXH         = 4;
        PAR_APPLID       = 5;
        PAR_XMAX         = 6;
        PAR_YMAX         = 7;
        PAR_DESKX        = 8;
        PAR_DESKY        = 9;
        PAR_DESKW        = 10;
        PAR_DESKH        = 11;
        PAR_BITPLANES    = 12;
        PAR_MAXCOLOR     = 13;
        PAR_ACTCOLOR     = 14;
        PAR_COLOR        = 15;
        PAR_ACCENTRY     = 16;
        PAR_MULTI        = 17;
        PAR_VAES         = 18;
        PAR_VTOS         = 19;
        PAR_VMAGX        = 20;
        PAR_RMAGX        = 21;
        PAR_MINT         = 22;
        PAR_WINX         = 23;
        PAR_SEARCH       = 24;
        PAR_AGI          = 25;
        PAR_AVSERVER     = 26;               (* [GS] *)
        PAR_ICFS         = 27;               (* [GS] *)
        PAR_BACKCOL      = 28;               (* [GS] *)
        PAR_ACTICOL      = 29;               (* [GS] *)
        PAR_SYSPT        = 30;               (* [GS] *)

(* -------------------------------------------------------------------
 * Werte fÅr agi aus Parameter
 * ------------------------------------------------------------------- *)

        AGI_0           = 0;
        AGI_3           = 1;
        AGI_4           = 2;

(* -------------------------------------------------------------------
 * Werte fÅr die Alertbox
 * ------------------------------------------------------------------- *)

        ALERT_NORM      = 0;
        ALERT_STOP      = 1;

        ButtonCenter    = 0;
        ButtonLeft      = 1;
        ButtonRight     = 2;

(* -------------------------------------------------------------------
 * Flags fuer Baeume im Fenster
 * ------------------------------------------------------------------- *)

        LINK_TOP        = 1;
        LINK_LEFT       = 2;
        LINK_RIGHT      = 3;
        LINK_BOTTOM     = 4;

(* -------------------------------------------------------------------
 * Spezielle Nachrichten an die Module
 * ------------------------------------------------------------------- *)

        SGM_IDENTIFY    = 70;
        SGM_INIT        = 71;
        SGM_START       = 72;
        SGM_QUIT        = 73;
        SGM_USER        = 74;

(* -------------------------------------------------------------------
 * Nachrichten von Auswertungs-Funktion(en) an SysGem
 * ------------------------------------------------------------------- *)

        SG_CLOSE        = 80;
        SG_REDRAW       = 81;
        SG_REDRAWALL    = 82;
        SG_TERM         = 83;
        SG_CONT         = 84;
        SG_ABORT        = 85;
        SG_KEYUSED      = 86;
        SG_KEYCONT      = 87;
        SG_CALL         = 88;
        SG_PIPE         = 89;
        SG_SELECTED     = 90;
        SG_TAKEKEY      = 91;
        SG_TAKEDIAL     = 92;
        SG_CALLUPD      = 93;
        SG_ICONIFY      = 94;

(* -------------------------------------------------------------------
 * Werte fÅr 'SetTab'-Funktionen
 * ------------------------------------------------------------------- *)

        TAB_LEFT        = 0;
        TAB_RIGHT       = 1;
        TAB_CENTER      = 2;
        TAB_DECIMAL     = 3;

(* -------------------------------------------------------------------
 * Werte von TerminateSysGem
 * ------------------------------------------------------------------- *)

        TERM_OK           = 0;
        TERM_DENIED_ACC   = 1;
        TERM_DENIED_SGM   = 2;

(* -------------------------------------------------------------------
 * Werte fÅr RedrawObj
 * ------------------------------------------------------------------- *)

        SET_STATE         = 1;
        DEL_STATE         = 2;
        UPD_STATE         = 4;
        FLIP_STATE        = 8;
        TAKE_STATE        = 16;
        USER_STATE        = 32;

(* -------------------------------------------------------------------
 * Stati fÅr Scroll-Funktionen
 * ------------------------------------------------------------------- *)

        SCROLL_PG_UP      = 0;
        SCROLL_PG_DOWN    = 1;
        SCROLL_UP         = 2;
        SCROLL_DOWN       = 3;
        SCROLL_PG_LEFT    = 4;
        SCROLL_PG_RIGHT   = 5;
        SCROLL_LEFT       = 6;
        SCROLL_RIGHT      = 7;

(* -------------------------------------------------------------------
 * Stati fÅr SetWindowParm
 * ------------------------------------------------------------------- *)

        SET_X             = 1;
        SET_Y             = 2;
        SET_W             = 3;
        SET_H             = 4;

(* ------------------------------------------------------------------- *)

        RSC_NOCICON       = -1;
        RSC_LOADERR       = -2;
        RSC_NOMEMORY      = -3;

(* ------------------------------------------------------------------- *)

        BUT_OK            = 1;
        BUT_ABORT         = 2;
        BUT_SYSTEM        = 4;
        BUT_HELP          = 8;
        BUT_ALL           = 15;

(* ------------------------------------------------------------------- *)

        WIN_FORCE         = 1;
        WIN_PAINT         = 2;

(* ------------------------------------------------------------------- *)

TYPE    RECT            = RECORD
          x             : INTEGER;
          y             : INTEGER;
          w             : INTEGER;
          h             : INTEGER;
        END;

(* ------------------------------------------------------------------- *)

        COOKIE          = RECORD
          id            : LONGINT;
          value         : LONGINT;
        END;

(* ------------------------------------------------------------------- *)

        AREA            = RECORD
          init          : INTEGER;
          x, y, w, h    : INTEGER;
          size          : LONGINT;
          mf            : MFDB;
        END;

(* ------------------------------------------------------------------- *)

        PARAMETER       = RECORD
          vdi_handle    : INTEGER;
          charw         : INTEGER;
          charh         : INTEGER;
          boxw          : INTEGER;
          boxh          : INTEGER;
          appl_id       : INTEGER;
          xmax          : INTEGER;
          ymax          : INTEGER;
          desktop       : RECT;
          bitplanes     : INTEGER;
          max_colors    : INTEGER;
          act_colors    : INTEGER;
          color_avail   : INTEGER;
          acc_entry     : INTEGER;
          multitask     : INTEGER;
          aes_version   : INTEGER;
          tos_version   : WORD;
          magx          : INTEGER;
          magx_release  : INTEGER;
          mint          : INTEGER;
          winx          : INTEGER;
          search        : INTEGER;
          agi           : INTEGER;
          AVServer      : INTEGER;				(* [GS] *)
          icfs          : INTEGER;
          backcol       : INTEGER;				(* [GS] *)
          acticol       : INTEGER;				(* [GS] *)
          syspt         : INTEGER;				(* [GS] *)
        END;

(* ------------------------------------------------------------------- *)

        DRAG_DROP_PTR   = ^DRAG_DROP;
        DRAG_DROP       = RECORD
          gemini        : integer;
          data_type     : longint;
          data          : pchar;
          data_len      : longint;
          data_id       : packed array [0..127] of char;
          filename      : packed array [0..127] of char;
          x, y          : integer;
          state         : integer;
          obj           : integer;
          id            : longint;
        END;

(* ------------------------------------------------------------------- *)

        DIALOG_INFO_PTR = ^DIALOG_INFO;
        DIALOG_INFO     = RECORD
          id            : LONGINT;
          user          : POINTER;
          dd            : DRAG_DROP_PTR;
          denied        : LONGINT;
          tree          : AesTreePtr;
          kstate        : INTEGER;
          edit_field    : INTEGER;
          box           : INTEGER;
          clip          : RECT;
          user2         : POINTER;
        END;

(* ------------------------------------------------------------------- *)

        WINDOW_INFO_PTR = ^WINDOW_INFO;
        WINDOW_INFO     = RECORD
          id            : LONGINT;
          handle        : INTEGER;
          pos_x         : LONGINT;
          pos_y         : LONGINT;
          doc_x         : LONGINT;
          doc_y         : LONGINT;
          key           : WORD;
          state         : INTEGER;
          mTitle        : INTEGER;
          mItem         : INTEGER;
          mx, my        : INTEGER;
          line          : LONGINT;
          column        : LONGINT;
          line_ptr      : PCHAR;
          line_user     : POINTER;
          work_area     : RECT;
          draw_area     : RECT;
          clip          : RECT;
          user          : POINTER;
          tree          : AesTreePtr;
          obj_id        : LONGINT;
          item          : INTEGER;
          box           : INTEGER;
          dd            : DRAG_DROP_PTR;
          denied        : LONGINT;
          user2         : POINTER;
        END;

(* ------------------------------------------------------------------- *)

        TABULAR         = RECORD
          pos, just     : INTEGER;
        END;

(* ------------------------------------------------------------------- *)

        SLD_ENTRY       = RECORD
          tree          : AesTreePtr;
          buffer        : PCHAR;
          tab           : ^TABULAR;
          area          : RECT;
          clip          : RECT;
          len           : INTEGER;
          box           : INTEGER;
          line          : INTEGER;
          hpos          : INTEGER;
          txt           : PCHAR;
          eelect        : INTEGER;
          changed       : INTEGER;
          drawn         : INTEGER;
        END;

(* ------------------------------------------------------------------- *)

        XTREE_PTR       = ^XTREE;
        XTREE           = RECORD
          id            : LONGINT;
          tree          : AesTreePtr;
          pos           : INTEGER;
          start         : INTEGER;
          depth         : INTEGER;
          edit          : INTEGER;
        END;

(* ------------------------------------------------------------------- *)

        MPROC           = function   ( item : integer ) : integer;
        DPROC           = function   ( msg, button : INTEGER; inf : DIALOG_INFO_PTR ) : integer;
        APROC           = function   ( msg : INTEGER; inf : WINDOW_INFO_PTR ) : integer;
        RPROC           = procedure  ( inf : WINDOW_INFO_PTR );
        TPROC           = procedure;
        EPROC           = procedure  ( ed : integer; str : pchar );
        FPROC           = function   ( tree : AESTreePtr; ed : integer; id : longint ) : integer;
        CPROC           = function   ( str1, str2 : pchar ) : integer;
        WPROC           = procedure  ( win_id : longint; enter : integer );
        UPROC           = procedure  ( msg : pointer );
        IPROC           = procedure  ( id : LONGINT; VAR r : RECT );
        VPROC           = function   ( s1, s2 : PCHAR ) : INTEGER;
        XPROC           = function   ( s1 : PCHAR; u1 : POINTER; s2 : PCHAR; u2 : POINTER ) : integer;
        SPROC           = procedure  ( var entry : SLD_ENTRY );
	USR_PROC	= function   ( key : integer ) : integer;
	
(* ------------------------------------------------------------------- *)

        XWIN_PTR        = ^XWIN;
        XWIN            = RECORD
          id            : LONGINT;
          owner         : LONGINT;
          flags         : INTEGER;
          cfg           : WORD;
          work          : RECT;
          wname         : PCHAR;
          winfo         : PCHAR;
          user          : POINTER;
          align_x       : INTEGER;
          align_y       : INTEGER;
          scr_x, scr_y  : INTEGER;
          font_id       : INTEGER;
          font_pt       : INTEGER;
          min_w, min_h  : INTEGER;
          max_w, max_h  : INTEGER;
          back          : INTEGER;
          anz_trees     : INTEGER;
          trees         : XTREE_PTR;
          menu          : AesTreePtr;
          md            : AesTreePtr;
          doc_w, doc_h  : LONGINT;
          redraw        : RPROC;
          waction       : APROC;
          daction       : DPROC;
        END;

(* -------------------------------------------------------------------
 * Berechnet aus einem String ein Long. Wird fÅr die (Fenster) Id's
 * benîtigt.
 * ------------------------------------------------------------------- *)

FUNCTION  MakeId        ( CONST id : STRING ) : LONGINT;

(* ------------------------------------------------------------------- *)

PROCEDURE ShowArrow;
PROCEDURE ShowBee;
PROCEDURE ShowHour;
PROCEDURE ShowFinger;
PROCEDURE ShowHand;
PROCEDURE ShowThinCross;
PROCEDURE ShowThickCross;
PROCEDURE ShowOutlineCross;
PROCEDURE ShowMouse;
PROCEDURE HideMouse;

(* ------------------------------------------------------------------- *)

PROCEDURE SetState       ( tree : AESTreePtr; obj, state : INTEGER );
PROCEDURE DelState       ( tree : AESTreePtr; obj, state : INTEGER );
FUNCTION  GetState       ( tree : AESTreePtr; obj, state : INTEGER ) : BOOLEAN;
PROCEDURE SetGlobalState ( tree : AESTreePtr; obj, state : INTEGER );

PROCEDURE SetFlags       ( tree : AESTreePtr; obj, flag : INTEGER );
PROCEDURE DelFlags       ( tree : AESTreePtr; obj, flag : INTEGER );
FUNCTION  GetFlags       ( tree : AESTreePtr; obj, flag : INTEGER ) : BOOLEAN;
PROCEDURE SetGlobalFlags ( tree : AESTreePtr; obj, flag : INTEGER );

(* -------------------------------------------------------------------
 * Prototypen
 * ------------------------------------------------------------------- *)

PROCEDURE       ShowRotor;              EXTERNAL;
PROCEDURE       UpdateRotor;            EXTERNAL;
PROCEDURE       EndRotor;               EXTERNAL;

PROCEDURE       ShowClock;              EXTERNAL;
PROCEDURE       UpdateClock;            EXTERNAL;
PROCEDURE       EndClock;               EXTERNAL;

PROCEDURE       ShowCoffee;             EXTERNAL;
PROCEDURE       UpdateCoffee;           EXTERNAL;
PROCEDURE       EndCoffee;              EXTERNAL;

PROCEDURE       ShowDisc;               EXTERNAL;
PROCEDURE       UpdateDisc;             EXTERNAL;
PROCEDURE       EndDisc;                EXTERNAL;

PROCEDURE       ShowAbacus;             EXTERNAL;
PROCEDURE       UpdateAbacus;           EXTERNAL;
PROCEDURE       EndAbacus;              EXTERNAL;

PROCEDURE       ShowDice;               EXTERNAL;
PROCEDURE       UpdateDice;             EXTERNAL;
PROCEDURE       EndDice;                EXTERNAL;

PROCEDURE       ShowPaper;              EXTERNAL;
PROCEDURE       UpdatePaper;            EXTERNAL;
PROCEDURE       EndPaper;               EXTERNAL;

function  initgem ( acc : string; prg_id : longint; prg_name : string ) : integer;
procedure exitgem;
external;
function  sysgemversion : word;
external;
function  sysgemverstr ( i: integer) : pchar;    (* [GS] *)
external;
procedure SetUserKeyProc ( u : USR_PROC );
external;

(* ------------------------------------------------------------------- *)

procedure getparstruct ( var par : parameter );
external;
function  getparam ( par : integer ) : integer;
external;

(* ------------------------------------------------------------------- *)

procedure setkey ( l1, l2 : longint );
external;

(* ------------------------------------------------------------------- *)

procedure setaccproc ( acc_open, acc_close : tproc );
external;
function  newdialog ( tree : aestreeptr ) : integer;
external;
function  deldialog ( tree : aestreeptr ) : integer;
external;

(* ------------------------------------------------------------------- *)

procedure clipboardchanged;
external;
function fileselect ( name, path, suffix, title : string; var file_name : string ) : integer;
function pathselect ( name: string; var path: string; suffix, title, file_name : string ) : integer;

(* -------------------------------------------------------------------
 * einstellungen
 * ------------------------------------------------------------------- *)

procedure setalerttitle ( name : string );
procedure setprogramname ( name : string );
procedure seticonifyname ( name : string );
procedure enable3d;
external;
procedure disable3d;
external;
procedure tellkeystrokes ( tell : integer );
external;
procedure dialposxy ( center : integer );
external;
procedure setfulledx ( value : integer );
external;
procedure setfulledy ( value : integer );
external;
procedure setfulledw ( value : integer );
external;
procedure setfulledh ( value : integer );
external;
procedure waitafterclose ( wait : integer );
external;
procedure frametextcolor ( color : integer );
external;
procedure shortcutcolor ( color : integer );
external;
procedure linkimage ( win_id : longint; image : bitblkptr; text : string );
procedure linkmainimage ( image : bitblkptr; text : string );
function  sysgem3d : integer;
external;
procedure useroundbuttons ( use : integer );
external;
function  setselcolor ( color : integer ) : integer;
external;
function  setseltextcolor ( color : integer ) : integer;
external;
procedure setwinbackground( win_id : longint; color : integer );
external;
procedure useowneditfields( use : integer );
external;
procedure setmonoeditframe( paint: integer );
external;
procedure setreturn ( use : integer );
external;
procedure setunknownevent ( proc : uproc );
external;
procedure setlanguage ( english : integer );
external;
procedure setlinkiconcolor ( win_id : longint; color : integer );
external;
procedure setlinktextcolor ( win_id : longint; color : integer );
external;
procedure sendsliderpos ( send : integer );
external;

(* -------------------------------------------------------------------
 * timer-routinen
 * ------------------------------------------------------------------- *)

procedure setproctimer ( p : tproc );
external;
procedure settimer ( ms_low, ms_high : integer );
external;
procedure setdispatchtime ( ms_low, ms_high : integer );
external;
procedure setwindowtimer ( win_id : longint; ms_low, ms_high : integer );
external;
procedure usefasttimer ( win_id : longint; enable : integer );
external;
procedure enabletimer;
external;
procedure disabletimer;
external;
procedure setxtimer ( id : longint; proc : tproc; ms_low, ms_high : integer; user1, user2 : pointer );
external;
procedure delxtimer ( id : longint );
external;
function  getxtimerid : longint;
external;
function  getxtimeruser1 : pointer;
external;
function  getxtimeruser2 : pointer;
external;

(* -------------------------------------------------------------------
 * usernachrichten
 * ------------------------------------------------------------------- *)

procedure showmessage ( text : string );
procedure endmessage;
external;
procedure showstatus ( text1, text2 : string; p, p1 : longint );
procedure endstatus;
external;

(* -------------------------------------------------------------------
 * textfenster
 * ------------------------------------------------------------------- *)

procedure beginlistupdate ( win_id : longint );
external;
procedure endlistupdate ( win_id : longint );
external;
function  linklist ( win_id : longint; text : string ) : pchar;
function  addtolist ( win_id : longint; text : string ) : pchar;
function  insinlist ( win_id : longint; line : word; text : string ) : pchar;
function  chginlist ( win_id : longint; line : word; text : string ) : pchar;

function  xlinklist ( win_id : longint; text : string; effect: integer; user : pointer ) : pchar;      (* [GS] *)
function  xaddtolist ( win_id : longint; text : string; effect: integer; user : pointer ) : pchar;      (* [GS] *)
function  xinsinlist ( win_id : longint; line : word; text : string; effect: integer; user : pointer ) : pchar;      (* [GS] *)
function  xchginlist ( win_id : longint; line : word; text : string; user : pointer ) : pchar;

function  setlisttab ( win_id : longint; pos, just : integer ) : integer;
external;
function  updlisttab ( win_id : longint; tab, pos, just : integer ) : integer;
external;

function  delinlist ( win_id : longint; line : word ) : integer;
external;
function  setlineicon ( win_id : longint; line : word; tree : aestreeptr; obj : integer ) : integer;
external;
function  xsetlineicon ( win_id : longint; line : word; tree : aestreeptr; obj : integer ) : integer;
external;

function  setlistuserptr( win_id : longint; line : word; user : pointer ) : integer;
external;
function  getlistuserptr( win_id : longint; line : word ) : pointer;
external;
procedure delcompletelist ( win_id : longint );
external;
function  countlines ( win_id : longint ) : word;
external;
function  display ( f_name, wname, winfo : string; len : integer; win_id : longint; x, y, w, h : integer; action : aproc ) : word;
function  cmp_strings_up( str1, str2 : pchar ) : integer;
external;
function  cmp_strings_dn( str1, str2 : pchar ) : integer;
external;
procedure do_qsort ( win_id : longint; compare : cproc );
external;
function  getlineptr ( win_id : longint; line : word ) : pchar;
external;
function  setlinecolor ( win_id : longint; line : word; color : integer ) : byte;
external;
function  setlineeffect ( win_id : longint; line : word; effect : integer ) : byte;
external;
function  setlineflags ( win_id : longint; line : word; flags : integer ) : byte;
external;
function  setlineuser ( win_id : longint; line : word; user : integer ) : byte;
external;
procedure redrawline ( win_id : longint; line : word );
external;
function  getlineheight ( win_id : longint ) : integer;
external;
function  gettabposition( win_id : longint; tab_nr, pixel : integer ) : integer;
external;
function  setwindowfont ( win_id : longint; font_id, font_pt : integer ) : integer;
external;
procedure getwindowfont ( win_id : longint; var id, pt : integer );
external;

(* -------------------------------------------------------------------
 * sliderboxen
 * ------------------------------------------------------------------- *)

function  linkslider ( tree : aestreeptr; up, dn, show, hide, max, box : integer; buf : pchar; len, icons : integer ) : integer;
external;
function  xlinkslider ( tree : aestreeptr; up, dn, show, hide, max, box : integer; buf : pchar; len, icons : integer; redraw : sproc ) : integer;
external;
function  linkhorslider ( tree : aestreeptr; box, left, right, show, hide : integer ) : integer;
external;

function  setslidertab ( tree : aestreeptr; box, pos, just : integer ) : integer;
external;
function  updslidertab ( tree : aestreeptr; box, tab, pos, just : integer ) : integer;
external;
procedure setsliderfont ( tree : aestreeptr; box, font_id, font_pt, draw : integer );
external;

procedure redrawsliderbox(tree : aestreeptr; box : integer );
external;
procedure fastdrawsldbox ( tree: aestreeptr; box : integer );
external;
procedure redrawtheslider ( tree : aestreeptr; box, draw : integer );
external;

procedure scrollslider ( tree : aestreeptr; box, whot : integer );
external;
function  addslideritem ( tree : aestreeptr; box, anz_items : integer ) : integer;
external;
function  setsliderpos ( tree : aestreeptr; box, just, draw : integer ) : integer;
external;
function  getslideritems( tree : aestreeptr; box : integer ) : integer;
external;

function  selectslditem ( tree : aestreeptr; box, line, draw : integer ) : integer;
external;
function  deselslditem ( tree : aestreeptr; box, draw : integer ) : integer;
external;
function  drawslider ( tree : aestreeptr; hide : integer; p1, p100 : longint; draw : integer ) : integer;
external;
function  unlinkslider ( tree : aestreeptr; box : integer ) : integer;
external;

(* -------------------------------------------------------------------
 * texte in editfeldern
 * ------------------------------------------------------------------- *)

procedure settext ( tree : aestreeptr; index : integer; text : string );
function  gettext ( tree : aestreeptr; index : integer; var text : string ) : pchar;
procedure cleareditfields(tree : aestreeptr );
external;
function  seteditfield ( tree : aestreeptr; field : integer ) : integer;
external;

(* -------------------------------------------------------------------
 * fenster
 * ------------------------------------------------------------------- *)

function  xwindow ( xw : xwin_ptr ) : pointer;
external;
procedure initxwindow ( var xw : xwin );
external;
procedure setwindowname ( handle : integer; text : string );
procedure setwindowinfo ( handle : integer; text : string );
procedure closeallwindows;
external;
function  windowvisible ( handle : integer ) : integer;
external;
function  gettopwindow : integer;
external;
function  gettopwindowid : longint;
external;
function  topwindow ( handle : integer ) : integer;
external;
function  closewindow ( handle : integer ) : integer;
external;
function  closewindowbyid ( win_id : longint ) : integer;
external;
function  gethandle ( win_id : longint ) : integer;
external;
function  getwindowid ( handle : integer ) : longint;
external;
procedure setwinminsize ( id : longint; w, h : integer );
external;
procedure setwinmaxsize ( id : longint; w, h : integer );
external;
procedure scrollwindow ( handle, what : integer );
external;
function  setwindowparm ( handle, what : integer; value : longint ) : longint;
external;
function  openwindow ( id : longint; wname, winfo : string; flags : integer; menu : aestreeptr; align, part, sx, sy : integer; docx, docy : longint; x, y, w, h : integer; user : pointer; redraw : rproc; action : aproc ) : integer;
function  linktree ( win_id : longint; tree : aestreeptr; id : longint; pos : integer ) : integer;
external;
function  unlinktree ( win_id : longint; tree : aestreeptr ) : integer;
external;
procedure calcwintrees ( win_id : longint );
external;
procedure cyclewindow ( show : integer );
external;
procedure seticonredraw ( win_id : longint; proc : iproc );
external;
procedure setwinuser ( win_id : longint; user : pointer );
external;
function  getwinuser ( win_id : longint ) : pointer;
external;
procedure resizewindow ( win_id : longint; var size : rect );
external;
function  countwindows : integer;
external;

(* -------------------------------------------------------------------
 * internes hilfe-system
 * ------------------------------------------------------------------- *)

procedure beginhelp ( tree : aestreeptr; obj : integer; text : string );
procedure endhelp;
external;
procedure enablehelp;
external;
procedure disablehelp;
external;
procedure sethelptime ( count : integer );
external;
procedure sethelpcolor ( color : integer );
external;

(* -------------------------------------------------------------------
 * schreiben ins fenster
 * ------------------------------------------------------------------- *)

function  openlogwindow ( win_id : longint; title, winfo : string; columns, rows, x, y : integer; action : aproc ) : integer;
procedure wwrite ( win_id : longint; text : string );
procedure wcls ( win_id : longint );
external;
procedure wposxy ( win_id : longint; x, y : integer );
external;
procedure wgetxy ( win_id : longint; var x, y : integer );
external;
function  wgetchar ( win_id : longint; x, y : integer; var effect : integer ) : char;
external;
procedure hidecursor ( win_id : longint );
external;
procedure showcursor ( win_id : longint );
external;

(* -------------------------------------------------------------------
 * popup's
 * ------------------------------------------------------------------- *)

function  popup ( tree : aestreeptr; x, y, start, first : integer ) : integer;
external;
function  xpopup ( tree : aestreeptr; obj : integer; tree2 : aestreeptr; start : integer; var first : integer ) : integer;
external;
function  cycle ( tree : aestreeptr; obj : integer; pop_tree : aestreeptr; first, last : integer; var ret : integer ) : integer;
external;
function  cycleback ( tree : aestreeptr; obj : integer; pop_tree : aestreeptr; first, last : integer; var ret : integer ) : integer;
external;
function  listbox ( str : pchar; count : integer; len : integer; tree : aestreeptr; box : integer ) : integer;
external;
function  xlistbox ( str : pchar; count : integer; len : integer; tree : aestreeptr; box : integer; proc : sproc ) : integer;
external;

(* -------------------------------------------------------------------
 * kommunikation
 * ------------------------------------------------------------------- *)

function  searchprogram ( pname : string ) : integer;

(* -------------------------------------------------------------------
 * verwaltung
 * ------------------------------------------------------------------- *)

procedure handlesysgem;
external;
procedure takeevent ( event, x, y, state, kstate, key, clicks : integer; msg : pointer );
external;
procedure terminatesysgem;
external;
procedure dispatchevents;
external;
function  selectprinter : integer;
external;

(* -------------------------------------------------------------------
 * config-datei
 * ------------------------------------------------------------------- *)

function  countkeywords : word;
external;
function  setconfig ( key : string; value : pointer; len : longint ) : integer;
function  getconfigptr ( key : string; value : pointer; var len : longint ) : integer;
function  getconfig ( key : string; value : pointer ) : integer;
function  delconfig ( key : string ) : integer;
function  saveconfig ( fname : string ) : longint;
function  loadconfig ( fname : string ) : longint;

(* -------------------------------------------------------------------
 * alerts
 * ------------------------------------------------------------------- *)

function  alert ( pri, def : integer; text : string ) : integer;
procedure setbutton ( just : integer );
external;
procedure set3dalertcolor(icn1, icn2, icn3 : integer );
external;
procedure setalertcolor ( icn1, icn2, icn3 : integer );
external;

(* -------------------------------------------------------------------
 * redraw
 * ------------------------------------------------------------------- *)

function  linkownredraw ( tree : aestreeptr; obj : integer ) : integer;
external;
function  removeownredraw(tree : aestreeptr; obj : integer ) : integer;
external;

procedure redrawarea ( handle : integer; var area : rect );
external;
procedure setclipping ( var clip : rect );
external;
procedure redrawwindow ( handle : integer );
external;
procedure redrawobj ( tree : aestreeptr; obj, depth, state, flag : integer );
external;
procedure disableobj ( tree : aestreeptr; obj, draw : integer );
external;
procedure enableobj ( tree : aestreeptr; obj, draw : integer );
external;
procedure hideobj ( tree : aestreeptr; obj, draw : integer );
external;
procedure showobj ( tree : aestreeptr; obj, draw : integer );
external;
procedure settextcolor ( tree : aestreeptr; obj, color: integer );
external;


(* -------------------------------------------------------------------
 * dialoge
 * ------------------------------------------------------------------- *)

function  windowdialog ( id : longint; xpos, ypos : integer; wname, winfo : string; shut, force : integer; tree, menu : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;
function  xwindowdialog ( id : longint; xpos, ypos : integer; wname, winfo : string; shut, force : integer; tree, menu : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;
function  multipledialog( id : longint; xpos, ypos : integer; wname, winfo : string; top : aestreeptr; active : integer; tree : aestreeptr; menu : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;
function  xmultipledialog( id : longint; xpos, ypos : integer; wname, winfo : string; top : aestreeptr; active : integer; tree : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;
function  begindialog ( win_id : longint; tree : aestreeptr; ed : integer; title : string ) : integer;
procedure finishdialog ( win_id : longint );
external;
function  dodialog ( tree : aestreeptr; ed : integer; text : string ) : integer;
function  handledialog ( win_id : longint; ed : integer ) : integer;
external;
procedure changebutton ( tree : aestreeptr; obj : integer; text : string; draw : integer );

(* -------------------------------------------------------------------
 * modulschnittstelle
 * ------------------------------------------------------------------- *)

function  askmodule ( name : string; cmd : integer; p : pointer ) : longint;
function  modulavail ( name : string ) : integer;
procedure setmodulepath ( path : string );
procedure startsysgemmodul ( name : string; p : pointer );
function  loadsysgemmodul ( name : string ) : integer;
procedure termsysgemmodul ( name : string );
function  getmoduleinfo ( nr : integer; name, mod_name, mod_autor : pointer ) : integer;

(* -------------------------------------------------------------------
 * fontselektor
 * ------------------------------------------------------------------- *)

function  fontselect ( buttons : integer; var id, pt : integer; title, example : string; internal : integer; help : tproc ) : integer;

(* -------------------------------------------------------------------
 * bildschirmroutinen
 * ------------------------------------------------------------------- *)

function  newarea ( var a : area ) : integer;
external;
procedure freearea ( var a : area );
external;
procedure cleararea ( var a : area );
external;
function  savearea ( handle : integer; var a : area; var r : rect ) : integer;
external;
procedure restorearea ( handle : integer; var a : area );
external;
procedure copyarea ( handle : integer; var a : area; xx, yy : integer );
external;
procedure movescreen ( handle : integer; var r : rect; x, y : integer );
external;

(* -------------------------------------------------------------------
 * resourcen
 * ------------------------------------------------------------------- *)

function  loadresource ( rsc_name : string; long : integer ) : word;
function  rscadr ( tree_type, index : integer ) : aestreeptr;
external;
procedure rscfree;
external;

(* -------------------------------------------------------------------
 * menÅzeilen
 * ------------------------------------------------------------------- *)

function  setdesktopmenu( menu : aestreeptr; action : mproc ) : integer;
external;
procedure remdesktopmenu;
external;

(* -------------------------------------------------------------------
 * sonstiges
 * ------------------------------------------------------------------- *)

procedure calcarea ( tree : aestreeptr; obj : integer; var r : rect );
external;
procedure rectintersect ( var r1, r2 );
external;

(* -------------------------------------------------------------------
 * online-help
 * ------------------------------------------------------------------- *)

procedure setonlinehelp ( prg1, prg2, fname : string );
function  callonlinehelp ( help : string ) : integer;

(* -------------------------------------------------------------------
 * crc-routinen
 * ------------------------------------------------------------------- *)

function  crc_16 ( p : pointer; len : longint ) : word;
external;
function  crc_32 ( p : pointer; len : longint ) : longint;
external;

(* -------------------------------------------------------------------
 * system-routinen
 * ------------------------------------------------------------------- *)

function  getcookie ( id : longint; var l : longint ) : integer;
external;

(* -------------------------------------------------------------------
 * font-routinen
 * ------------------------------------------------------------------- *)

function  fontexists ( font_id : integer ) : integer;
external;
function  getfontid ( font_name : string ) : integer;
function  getfontname ( font_id : integer ) : pchar;
external;
function  vectorfont ( font_id : integer ) : integer;
external;

(* ------------------------------------------------------------------- *)

procedure normalfont;
external;
procedure smallfont;
external;
procedure setfont ( font_id , font_pt : integer );
external;

(* ------------------------------------------------------------------- *)

function  stringwidth ( text : string ) : integer;
function  stringheight : integer;
external;
function  centerx ( x1, x2 : integer; text : string ) : integer;
function  centery ( y1, y2 : integer ) : integer;
external;

(* ------------------------------------------------------------------- *)

procedure v_xtext ( color, x, y : integer; text : string );
procedure v_stext ( color, x, y : integer; text : string );

(* ------------------------------------------------------------------- *)

procedure setsysfont ( id : integer );
external;
procedure sendfontchanged ( id, pt : integer );
external;
procedure resetsysfont;
external;

(* procedure ClearCache;
external; *)

(* ------------------------------------------------------------------- *)

function GetVerString: string;

function fitwildcard( wildcard, test: string): integer;

IMPLEMENTATION

{$B-}
{$D-}
{$L-}
{$I-}
{$Q-}
{$S-}
{$R-}
{$T-}
{$X+}
{$Z-}

FUNCTION INQMAGX: INTEGER; EXTERNAL;
{$L MAGIC }

FUNCTION WILDCARDFIT( WILDCARD, TEST: PCHAR): INTEGER; EXTERNAL;
{$L WILD }

(* -------------------------------------------------------------------
 * Ab hier befinden sich die spezifischen Anpassungen fÅr die C-Lib.
 *
 * AUF GAR KEINEN FALL IRGENDWAS AENDERN!!!!
 *
 * Bei einer neuen Pascal-Version kînnen Sie einfach durch neukompilieren
 * dieser Unit eine neue Lib erstellen. Bei neuen Versionen einfach die
 * SYS_PAS.LIB austauschen und neu Åbersetzen. Und schon haben Sie eine
 * neue Lib. NIE wieder AbhÑngigkeiten von der Pascal-Version/Release!
 * ------------------------------------------------------------------- *)

var     errno      : integer;   (* interne Error-Variable              *)
        _app       : integer;   (* App oder ACC?                       *)
        _atexitv   : longint;   (* Adresse                             *)
        _filsysv   : longint;   (* Adresse                             *)


function fitwildcard( wildcard, test: string): integer;
var
 s1: string;
 s2: string;
begin
 s1:=wildcard+#0;
 s2:=test+#0;
 fitwildcard:=wildcardfit( @s1 [1], @s2 [1]);
end;

function GetVerString: string;
var
 version: integer;

function DecodeVersion( version: integer ): string;
var
 buffer, temp: string;

begin
 str( (version DIV 256), temp );
 buffer:=temp;
 str( ((version MOD 256) DIV 16), temp );
 buffer:=buffer+'.'+temp;
 str( ((version MOD 16) DIV 1), temp );
 buffer:=buffer+temp;
 DecodeVersion:=buffer;
end;

begin
 version:=InqMagX;
 GetVerString:=DecodeVersion( version );
end;

(* -------------------------------------------------------------------
 * Berechnet aus einem String ein Long. Wird fÅr die (Fenster) Id's
 * benîtigt.
 * ------------------------------------------------------------------- *)

FUNCTION MakeId ( CONST id : STRING ) : LONGINT;

VAR     conv    : RECORD
          CASE INTEGER OF
            0   : ( x1 : PACKED ARRAY [0..3] OF CHAR );
            1   : ( x2 : lONGINT );
        END;

BEGIN
  conv.x1 [0] := id [1];
  conv.x1 [1] := id [2];
  conv.x1 [2] := id [3];
  conv.x1 [3] := id [4];
  MakeId := conv.x2;
END;

(* -------------------------------------------------------------------
 * Die Maus-Funktionen. MÅssen hier als Proceduren sein, da sie in C
 * als #define deklariert sind.
 * ------------------------------------------------------------------- *)

FUNCTION graf_mouse ( nr : INTEGER; form : POINTER ) : INTEGER;
EXTERNAL;

(* ------------------------------------------------------------------- *)

PROCEDURE ShowArrow;        BEGIN Graf_Mouse ( 0,   NIL ); END;
PROCEDURE ShowBee;          BEGIN Graf_Mouse ( 2,   NIL ); END;
PROCEDURE ShowHour;         BEGIN Graf_Mouse ( 2,   NIL ); END;
PROCEDURE ShowFinger;       BEGIN Graf_Mouse ( 3,   NIL ); END;
PROCEDURE ShowHand;         BEGIN Graf_Mouse ( 4,   NIL ); END;
PROCEDURE ShowThinCross;    BEGIN Graf_Mouse ( 5,   NIL ); END;
PROCEDURE ShowThickCross;   BEGIN Graf_Mouse ( 6,   NIL ); END;
PROCEDURE ShowOutlineCross; BEGIN Graf_Mouse ( 7,   NIL ); END;
PROCEDURE ShowMouse;        BEGIN Graf_Mouse ( 257, NIL ); END;
PROCEDURE HideMouse;        BEGIN Graf_Mouse ( 256, NIL ); END;

(* -------------------------------------------------------------------
 * Die Flag-Funktionen. MÅssen hier als Proceduren sein, da sie in C
 * als #define deklariert sind.
 * ------------------------------------------------------------------- *)

PROCEDURE SetState ( tree : AESTreePtr; obj, state : INTEGER );

begin
  tree^[obj].ob_state := ( tree^[obj].ob_state OR state );
end;

(* ------------------------------------------------------------------- *)

PROCEDURE SetGlobalState ( tree : AESTreePtr; obj, state : INTEGER );

begin
  tree^[obj].ob_state := state;
end;

(* ------------------------------------------------------------------- *)

PROCEDURE DelState ( tree : AESTreePtr; obj, state : INTEGER );

begin
  tree^[obj].ob_state := ( tree^[obj].ob_state AND ( NOT state ));
end;

(* ------------------------------------------------------------------- *)

PROCEDURE SetFlags ( tree : AESTreePtr; obj, flag : INTEGER );

begin
  tree^[obj].ob_flags := ( tree^[obj].ob_flags OR flag );
end;

(* ------------------------------------------------------------------- *)

PROCEDURE SetGlobalFlags ( tree : AESTreePtr; obj, flag : INTEGER );

begin
  tree^[obj].ob_flags := flag;
end;

(* ------------------------------------------------------------------- *)

PROCEDURE DelFlags ( tree : AESTreePtr; obj, flag : INTEGER );

begin
  tree^[obj].ob_flags := ( tree^[obj].ob_flags AND ( NOT flag ));
end;

(* ------------------------------------------------------------------- *)

FUNCTION GetState ( tree : AESTreePtr; obj, state : INTEGER ) : boolean;

begin
  GetState := (( tree^[obj].ob_state AND state ) <> 0 );
end;

(* ------------------------------------------------------------------- *)

FUNCTION GetFlags ( tree : AESTreePtr; obj, flag : INTEGER ) : boolean;

begin
  GetFlags := (( tree^[obj].ob_flags AND flag ) <> 0 );
end;

(* ------------------------------------------------------------------- *)

function  sginitgem ( acc : pchar; prg_id : longint; prg_name : pchar ) : integer;
external;
function  sgfileselect ( name, path, suffix, title : pchar; file_name : pchar ) : integer;
external;
procedure sgsetalerttitle ( name : pchar );
external;
procedure sgsetprogramname( name : pchar );
external;
procedure sgseticonifyname( name : pchar );
external;
procedure sglinkimage ( win_id : longint; image : pointer; text : pchar );
external;
procedure sglinkmainimage ( image : pointer; text : pchar );
external;
procedure sgshowmessage ( text : pchar );
external;
procedure sgshowstatus ( text1, text2 : pchar; p, p1 : longint );
external;
function  sglinklist ( win_id : longint; text : pchar ) : pchar;
external;
function  sgaddtolist ( win_id : longint; text : pchar ) : pchar;
external;
function  sginsinlist ( win_id : longint; line : word; text : pchar ) : pchar;
external;
function  sgchginlist ( win_id : longint; line : word; text : pchar ) : pchar;
external;
function  sgxlinklist ( win_id : longint; text : pchar; user : pointer ) : pchar;
external;
function  sgxaddtolist ( win_id : longint; text : pchar; user : pointer ) : pchar;
external;
function  sgxinsinlist ( win_id : longint; line : word; text : pchar; user : pointer ) : pchar;
external;
function  sgxchginlist ( win_id : longint; line : word; text : pchar; user : pointer ) : pchar;
external;
procedure sgsettext ( tree : aestreeptr; index : integer; text : pchar );
external;
function  sggettext ( tree : aestreeptr; index : integer; text : pchar ) : pchar;
external;
procedure sgsetwindowname ( handle : integer; text : pchar );
external;
procedure sgsetwindowinfo ( handle : integer; text : pchar );
external;
function  sgopenwindow ( id : longint; wname, winfo : pchar; flags : integer; menu : aestreeptr; align, part, sx, sy : integer; docx, docy : longint; x, y, w, h : integer; user : pointer; redraw : rproc; action : aproc ) : integer;
external;
procedure sgbeginhelp ( tree : aestreeptr; obj : integer; text : pchar );
external;
function  sgopenlogwindow ( win_id : longint; title, info : pchar; columns, rows, x, y : integer; action : aproc ) : integer;
external;
procedure sgwwrite ( win_id : longint; text : pchar );
external;
function  sgsearchprogram ( pname : pchar ) : integer;
external;
function  sgsetconfig ( key : pchar; value : pointer; len : longint ) : integer;
external;
function  sggetconfigptr ( key : pchar; value : pointer; var len : longint ) : integer;
external;
function  sggetconfig ( key : pchar; value : pointer ) : integer;
external;
function  sgdelconfig ( key : pchar ) : integer;
external;
function  sgsaveconfig ( fname : pchar ) : longint;
external;
function  sgloadconfig ( fname : pchar ) : longint;
external;
function  sgalert ( pri, def : integer; text : pchar ) : integer;
external;
function  sgwindowdialog ( id : longint; xpos, ypos : integer; wname, winfo : pchar; shut, force : integer; tree, menu : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;
external;
function  sgxwindowdialog ( id : longint; xpos, ypos : integer; wname, winfo : pchar; shut, force : integer; tree, menu : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;
external;
function  sgmultipledialog( id : longint; xpos, ypos : integer; wname, winfo : pchar; top : aestreeptr; active : integer; tree : aestreeptr; menu : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;
external;
function  sgxmultipledialog( id : longint; xpos, ypos : integer; wname, winfo : pchar; top : aestreeptr; active : integer; tree : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;
external;
function  sgbegindialog ( win_id : longint; tree : aestreeptr; ed : integer; title : pchar ) : integer;
external;
function  sgdodialog ( tree : aestreeptr; ed : integer; text : pchar ) : integer;
external;
procedure sgchangebutton ( tree : aestreeptr; obj : integer; text : pchar; draw : integer );
external;
function  sgaskmodule ( name : pchar; cmd : integer; p : pointer ) : longint;
external;
function  sgmodulavail ( name : pchar ) : integer;
external;
procedure sgsetmodulepath ( path : pchar );
external;
procedure sgstartsysgemmodul ( name : pchar; p : pointer );
external;
function  sgloadsysgemmodul ( name : pchar ) : integer;
external;
procedure sgtermsysgemmodul ( name : pchar );
external;
function  sggetmoduleinfo ( nr : integer; name, mod_name, mod_autor : pointer ) : integer;
external;
function  sgfontselect ( buttons : integer; var id, pt : integer; title, example : pchar; internal : integer; help : tproc ) : integer;
external;
function  sgloadresource ( rsc_name : pchar; long : integer ) : word;
external;
procedure sgsetonlinehelp ( prg1, prg2, fname : pchar );
external;
function  sgcallonlinehelp ( help : pchar ) : integer;
external;
function  sggetfontid ( font_name : pchar ) : integer;
external;
function  sgstringwidth ( text : pchar ) : integer;
external;
function  sgcenterx ( x1, x2 : integer; text : pchar ) : integer;
external;
procedure sgv_xtext ( color, x, y : integer; text : pchar );
external;
procedure sgv_stext ( color, x, y : integer; text : pchar );
external;

(* ------------------------------------------------------------------- *)

function initgem ( acc : string; prg_id : longint; prg_name : string ) : integer;

var s1, s2 : string;

begin
  s1 := acc + #0;
  s2 := prg_name + #0;
  initgem := sginitgem ( @s1 [1], prg_id, @s2 [1] );
end;

(* ------------------------------------------------------------------- *)

function fileselect ( name, path, suffix, title : string; var file_name : string ) : integer;

var s1, s2, s3, s4, s5 : string;

begin
  s1 := name + #0;
  s2 := path + #0;
  s3 := suffix + #0;
  s4 := title + #0;
  s5 := '' + #0;
  fileselect := sgfileselect ( @s1 [1], @s2 [1], @s3 [1], @s4 [1], @s5 [0] );
  ctopascalstring ( file_name, @s5 );
end;

(* ------------------------------------------------------------------- *)

function pathselect ( name: string; var path: string; suffix, title, file_name : string ) : integer;

var s1, s2, s3, s4, s5 : string;

begin
  s1 := name + #0;
  s2 := path + #0;
  s3 := suffix + #0;
  s4 := title + #0;
  s5 := '' + #0;
  pathselect := sgfileselect ( @s1 [1], @s2 [0], @s3 [1], @s4 [1], @s5 [1] );
  ctopascalstring ( path, @s2 );
end;

(* ------------------------------------------------------------------- *)

procedure setalerttitle ( name : string );

var s1 : string;

begin
  s1 := name + #0;
  sgsetalerttitle ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure setprogramname( name : string );

var s1 : string;

begin
  s1 := name + #0;
  sgsetprogramname ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure seticonifyname( name : string );

var s1 : string;

begin
  s1 := name + #0;
  sgseticonifyname ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure linkimage ( win_id : longint; image : bitblkptr; text : string );

var s1 : string;

begin
  s1 := text + #0;
  sglinkimage ( win_id, image, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure linkmainimage ( image : bitblkptr; text : string );

var s1 : string;

begin
  s1 := text + #0;
  sglinkmainimage ( image, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure showmessage ( text : string );

var s1 : string;

begin
  s1 := text + #0;
  sgshowmessage ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure showstatus ( text1, text2 : string; p, p1 : longint );

var s1, s2 : string;

begin
  s1 := text1 + #0;
  s2 := text2 + #0;
  if ((text1='') and (text2='')) then
   sgshowstatus ( nil, nil, p, p1 )
  else if ((text1='') and (text2<>'')) then
   sgshowstatus ( nil, @s2 [1], p, p1 )
  else if ((text1<>'') and (text2='')) then
   sgshowstatus ( @s1 [1], nil, p, p1 )
  else if ((text1<>'') and (text2<>'')) then
   sgshowstatus ( @s1 [1], @s2 [1], p, p1 );
end;


(* ------------------------------------------------------------------- *)

function linklist ( win_id : longint; text : string ) : pchar;

var s1 : string;

begin
  s1 := text + #0;
  linklist := sglinklist ( win_id, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function addtolist ( win_id : longint; text : string ) : pchar;

var s1 : string;

begin
  s1 := text + #0;
  addtolist := sgaddtolist ( win_id, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function insinlist ( win_id : longint; line : word; text : string ) : pchar;

var s1 : string;

begin
  s1 := text + #0;
  insinlist := sginsinlist ( win_id, line, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function chginlist ( win_id : longint; line : word; text : string ) : pchar;

var s1 : string;

begin
  s1 := text + #0;
  chginlist := sgchginlist ( win_id, line, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function xlinklist ( win_id : longint; text : string; user : pointer ) : pchar;

var s1 : string;

begin
  s1 := text + #0;
  xlinklist := sgxlinklist ( win_id, @s1 [1], user );
end;

(* ------------------------------------------------------------------- *)

function xaddtolist ( win_id : longint; text : string; user : pointer ) : pchar;

var s1 : string;

begin
  s1 := text + #0;
  xaddtolist := sgxaddtolist ( win_id, @s1 [1], user );
end;

(* ------------------------------------------------------------------- *)

function xinsinlist ( win_id : longint; line : word; text : string; user : pointer ) : pchar;

var s1 : string;

begin
  s1 := text + #0;
  xinsinlist := sgxinsinlist ( win_id, line, @s1 [1], user );
end;

(* ------------------------------------------------------------------- *)

function xchginlist ( win_id : longint; line : word; text : string; user : pointer ) : pchar;

var s1 : string;

begin
  s1 := text + #0;
  xchginlist := sgxchginlist ( win_id, line, @s1 [1], user );
end;

(* -------------------------------------------------------------------
 * Da PP die File-Funktionen aus C nicht frisst, hier das équivalent.
 * Ist (leider) etwas langsamer als in C... :-(((
 * ------------------------------------------------------------------- *)

function Display ( f_name, wname, winfo : string; len : integer; win_id : longint; x, y, w, h : integer; action : APROC ) : WORD;

var     s1, s2, s3, s4  : string;
        f               : TEXT;
        i               : WORD;
        z               : INTEGER;

begin
  s1 := f_name + #0;
  s2 := wname + #0;
  s3 := winfo + #0;

  assign ( f, f_name );
  Reset ( f );
  if ( IOResult <> 0 ) then
    begin
      Display := 0;
      exit;
    end;

  z := sgOpenWindow ( win_id, @s2 [1], @s3 [1], $fef, NIL, 1, 1, 8, 16, 1, 1, x, y, w, h, NIL, rproc(NIL), action );
  if ( z <= 0 ) then
    begin
      close ( f );
      Display := 0;
      exit;
    end;
  i := 0;
  BeginListUpdate ( win_id );
  while ( not ( eof ( f ))) do
    begin
      fillchar ( s4, sizeof ( s4 ), 0 );
      readln ( f, s4 );
      if ( i = 0 ) then
        begin
          LinkList ( win_id, s4 );
        end
      else
        begin
          AddToList ( win_id, s4 );
        end;
      inc ( i );
    end;
  EndListUpdate ( win_id );
  close ( f );
  display := i;
end;

(* ------------------------------------------------------------------- *)

procedure settext ( tree : aestreeptr; index : integer; text : string );

var s1 : string;

begin
  s1 := text + #0;
  sgsettext ( tree, index, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function gettext ( tree : aestreeptr; index : integer; var text : string ) : pchar;

var s1 : pchar;

begin
  s1 := sggettext ( tree, index, nil );
  ctopascalstring ( text, s1 );
  gettext := s1;
end;

(* ------------------------------------------------------------------- *)

procedure setwindowname ( handle : integer; text : string );

var s1 : string;

begin
  s1 := text + #0;
  sgsetwindowname ( handle, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure setwindowinfo ( handle : integer; text : string );

var s1 : string;

begin
  s1 := text + #0;
  sgsetwindowinfo ( handle, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function openwindow ( id : longint; wname, winfo : string; flags : integer; menu : aestreeptr; align, part, sx, sy : integer; docx, docy : longint; x, y, w, h : integer; user : pointer; redraw : rproc; action : aproc ) : integer;

var s1, s2 : string;

begin
  s1 := wname + #0;
  s2 := winfo + #0;
  openwindow := sgopenwindow ( id, @s1 [1], @s2 [1], flags, menu, align, part, sx, sy, docx, docy, x, y, w, h, user, redraw, action );
end;

(* ------------------------------------------------------------------- *)

procedure beginhelp ( tree : aestreeptr; obj : integer; text : string );

var s1 : string;

begin
  s1 := text + #0;
  sgbeginhelp ( tree, obj, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function openlogwindow ( win_id : longint; title, winfo : string; columns, rows, x, y : integer; action : aproc ) : integer;

var s1, s2 : string;

begin
  s1 := title + #0;
  s2 := winfo + #0;
  openlogwindow := sgopenlogwindow ( win_id, @s1 [1], @s2 [1], columns, rows, x, y, action );
end;

(* ------------------------------------------------------------------- *)

procedure wwrite ( win_id : longint; text : string );

var s1 : string;

begin
  s1 := text + #0;
  sgwwrite ( win_id, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function searchprogram ( pname : string ) : integer;

var s1 : string;

begin
  s1 := pname + #0;
  searchprogram := sgsearchprogram ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function setconfig ( key : string; value : pointer; len : longint ) : integer;

var s1 : string;

begin
  s1 := key + #0;
  setconfig := sgsetconfig ( @s1 [1], value, len );
end;

(* ------------------------------------------------------------------- *)

function getconfigptr ( key : string; value : pointer; var len : longint ) : integer;

var s1 : string;

begin
  s1 := key + #0;
  getconfigptr := sggetconfigptr ( @s1 [1], value, len );
end;

(* ------------------------------------------------------------------- *)

function getconfig ( key : string; value : pointer ) : integer;

var s1 : string;

begin
  s1 := key + #0;
  getconfig := sggetconfig ( @s1 [1], value );
end;

(* ------------------------------------------------------------------- *)

function delconfig ( key : string ) : integer;

var s1 : string;

begin
  s1 := key + #0;
  delconfig := sgdelconfig ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function saveconfig ( fname : string ) : longint;

var s1 : string;

begin
  s1 := fname + #0;
  saveconfig := sgsaveconfig ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function loadconfig ( fname : string ) : longint;

var s1 : string;

begin
  s1 := fname + #0;
  loadconfig := sgloadconfig ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function alert ( pri, def : integer; text : string ) : integer;

var s1 : string;

begin
  s1 := text + #0;
  alert := sgalert ( pri, def, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function windowdialog ( id : longint; xpos, ypos : integer; wname, winfo : string; shut, force : integer; tree, menu : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;

var s1, s2 : string;

begin
  s1 := wname + #0;
  s2 := winfo + #0;
  windowdialog := sgwindowdialog ( id, xpos, ypos, @s1 [1], @s2 [1], shut, force, tree, menu, edit, user, proc );
end;

(* ------------------------------------------------------------------- *)

function xwindowdialog ( id : longint; xpos, ypos : integer; wname, winfo : string; shut, force : integer; tree, menu : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;

var s1, s2 : string;

begin
  s1 := wname + #0;
  s2 := winfo + #0;
  xwindowdialog := sgxwindowdialog ( id, xpos, ypos, @s1 [1], @s2 [1], shut, force, tree, menu, edit, user, proc );
end;

(* ------------------------------------------------------------------- *)

function multipledialog( id : longint; xpos, ypos : integer; wname, winfo : string; top : aestreeptr; active : integer; tree : aestreeptr; menu : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;

var s1, s2 : string;

begin
  s1 := wname + #0;
  s2 := winfo + #0;
  multipledialog := sgmultipledialog ( id, xpos, ypos, @s1 [1], @s2 [1], top, active, tree, menu, edit, user, proc );
end;

(* ------------------------------------------------------------------- *)

function xmultipledialog( id : longint; xpos, ypos : integer; wname, winfo : string; top : aestreeptr; active : integer; tree : aestreeptr; edit : integer; user : pointer; proc : dproc ) : integer;

var s1, s2 : string;

begin
  s1 := wname + #0;
  s2 := winfo + #0;
  xmultipledialog := sgxmultipledialog ( id, xpos, ypos, @s1 [1], @s2 [1], top, active, tree, edit, user, proc );
end;

(* ------------------------------------------------------------------- *)

function begindialog ( win_id : longint; tree : aestreeptr; ed : integer; title : string ) : integer;

var s1 : string;

begin
  s1 := title + #0;
  begindialog := sgbegindialog ( win_id, tree, ed, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function dodialog ( tree : aestreeptr; ed : integer; text : string ) : integer;

var s1 : string;

begin
  s1 := text + #0;
  dodialog := sgdodialog ( tree, ed, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure changebutton ( tree : aestreeptr; obj : integer; text : string; draw : integer );

var s1 : string;

begin
  s1 := text + #0;
  sgchangebutton ( tree, obj, @s1 [1], draw );
end;

(* ------------------------------------------------------------------- *)

function askmodule ( name : string; cmd : integer; p : pointer ) : longint;

var s1 : string;

begin
  s1 := name + #0;
  askmodule := sgaskmodule ( @s1 [1], cmd, p );
end;

(* ------------------------------------------------------------------- *)

function modulavail ( name : string ) : integer;

var s1 : string;

begin
  s1 := name + #0;
  modulavail := sgmodulavail ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure setmodulepath ( path : string );

var s1 : string;

begin
  s1 := path + #0;
  sgsetmodulepath ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure startsysgemmodul ( name : string; p : pointer );

var s1 : string;

begin
  s1 := name + #0;
  sgstartsysgemmodul ( @s1 [1], p );
end;

(* ------------------------------------------------------------------- *)

function loadsysgemmodul ( name : string ) : integer;

var s1 : string;

begin
  s1 := name + #0;
  loadsysgemmodul := sgloadsysgemmodul ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure termsysgemmodul ( name : string );

var s1 : string;

begin
  s1 := name + #0;
  sgtermsysgemmodul ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function getmoduleinfo ( nr : integer; name, mod_name, mod_autor : pointer ) : integer;

begin
  getmoduleinfo := sggetmoduleinfo ( nr, name, mod_name, mod_autor );
end;

(* ------------------------------------------------------------------- *)

function fontselect ( buttons : integer; var id, pt : integer; title, example : string; internal : integer; help : tproc ) : integer;

var s1, s2 : string;

begin
  s1 := title + #0;
  s2 := example + #0;
  fontselect := sgfontselect ( buttons, id, pt, @s1[1], @s2 [1], internal, help );
end;

(* ------------------------------------------------------------------- *)

function loadresource ( rsc_name : string; long : integer ) : word;

var s1 : string;

begin
  s1 := rsc_name + #0;
  loadresource := sgloadresource ( @s1 [1], long );
end;

(* ------------------------------------------------------------------- *)

procedure setonlinehelp ( prg1, prg2, fname : string );

var s1, s2, s3 : string;

begin
  s1 := prg1 + #0;
  s2 := prg2 + #0;
  s3 := fname + #0;
  sgsetonlinehelp ( @s1 [1], @s2 [1], @s3 [1] );
end;

(* ------------------------------------------------------------------- *)

function callonlinehelp ( help : string ) : integer;

var s1 : string;

begin
  s1 := help + #0;
  callonlinehelp := sgcallonlinehelp ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function getfontid ( font_name : string ) : integer;

var s1 : string;

begin
  s1 := font_name + #0;
  getfontid := sggetfontid ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function stringwidth ( text : string ) : integer;

var s1 : string;

begin
  s1 := text + #0;
  stringwidth := sgstringwidth ( @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

function centerx ( x1, x2 : integer; text : string ) : integer;

var s1 : string;

begin
  s1 := text + #0;
  centerx := sgcenterx ( x1, x2, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure v_xtext ( color, x, y : integer; text : string );

var s1 : string;

begin
  s1 := text + #0;
  sgv_xtext ( color, x, y, @s1 [1] );
end;

(* ------------------------------------------------------------------- *)

procedure v_stext ( color, x, y : integer; text : string );

var s1 : string;

begin
  s1 := text + #0;
  sgv_stext ( color, x, y, @s1 [1] );
end;

(* -------------------------------------------------------------------
 * Die eigentliche Lib. Pfad einfach anpassen...
 * ------------------------------------------------------------------- *)

(*$L D:\SGEM250P\sys_pas2.lib *)

(* -------------------------------------------------------------------
 * Startup-Code, damit die Lib richtig hochkommt...
 * Das 'AND' muû sein, da sonst der Linker die Variablen
 * wegoptimiert, und das wÑre schlecht...
 * ------------------------------------------------------------------- *)

begin
  _filsysv   := longint ( 0 );
  _atexitv   := longint ( 0 );
  errno      := 0;
  _app       := 0;
  if (( AppFlag = TRUE ) and ( _app = 0 ) and ( _filsysv = 0 ) and ( _atexitv = 0 )) then
    begin
      _app := 1;
    end
  else
    begin
      _app := 0;
    end;
  if ( _app = 0 ) then
    begin
      ;
    end;
end.

(* ------------------------------------------------------------------- *)

