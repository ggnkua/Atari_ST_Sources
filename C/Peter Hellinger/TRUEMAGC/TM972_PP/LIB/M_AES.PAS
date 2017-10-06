UNIT M_AES;

INTERFACE

USES Basics;

CONST   MouseLeft =     Bit0;   (* Bitwert fÅr Maustasten *)
        MouseRight =    Bit1;

TYPE    tAESGLOBAL =    RECORD
                         apVersion:     INTEGER; (* globl 0 *)
                         apCount:       INTEGER; (* globl 1 *)
                         apId:          INTEGER; (* globl 2 *)
                         apPprivate:    LONGINT; (* globl 3/4 *)
                         apPtree:       POINTER; (* globl 5/6*)
                         apPmem:        POINTER; (* globl 7/8 *)
                         apLmem:        INTEGER; (* globl 9 *)
                         apNplanes:     INTEGER; (* globl 10 *)
                         Reserved1:     INTEGER; (* globl 11 *)
                         Reserved2:     INTEGER; (* globl 12 *)
                         apBvdisk:      WORD;    (* globl 13 *)
                         apBvhard:      WORD;    (* globl 14 *)
                        END;

TYPE    tControl =      RECORD
                         opcode:        INTEGER;
                         sizeIntIn:     INTEGER;
                         sizeIntOut:    INTEGER;
                         sizeAddrIn:    INTEGER;
                         sizeAddrOut:   INTEGER;
                        END;

TYPE    tIntIn =        ARRAY [0..16] OF INTEGER;
        tIntOut =       ARRAY [0.. 7] OF INTEGER;
        tAddrIn =       ARRAY [0.. 2] OF POINTER;
        tAddrOut =      ARRAY [0.. 1] OF POINTER;

VAR     CallResult:  INTEGER;
        (* EnthÑlt nach einem AESCall den eventuellen Fehlercode *)

FUNCTION AESCall (op, c1, c2, c3, c4: INTEGER): INTEGER;
(* FÅhrt eine AES-Operation aus *)

(*-- AES-Objc --------------------------------------------------------*)

CONST   GBOX =          20;
        GTEXT =         21;
        GBOXTEXT =      22;
        GIMAGE =        23;
        GPROGDEF =      24;
        GIBOX =         25;
        GBUTTON =       26;
        GBOXCHAR =      27;
        GSTRING =       28;
        GFTEXT =        29;
        GFBOXTEXT =     30;
        GICON =         31;
        GTITLE =        32;
        GCICON =        33;     (* object type number for AES   *)

CONST   SELECTABLE =    Bit0;
        DEFAULT =       Bit1;
        ExitFlag =      Bit2;   (* EXIT ist reserviertes Wort... *)
        EDITABLE =      Bit3;
        RBUTTON =       Bit4;
        LASTOB =        Bit5;
        TOUCHEXIT =     Bit6;
        HIDETREE =      Bit7;
        INDIRECT =      Bit8;

CONST   SELECTED =      Bit0;
        CROSSED =       Bit1;
        CHECKED =       Bit2;
        DISABLED =      Bit3;
        OUTLINED =      Bit4;
        SHADOWED =      Bit5;
        WHITEBAK =      Bit6;
        DRAW3D =        Bit7;
                        
CONST   WHITE =          0;     (* Farben *)
        BLACK =          1;
        RED =            2;
        GREEN  =         3;
        BLUE  =          4;
        CYAN  =          5;
        YELLOW  =        6;
        MAGENTA  =       7;
        LWHITE =         8;
        LBLACK  =        9;
        LRED =          10;
        LGREEN =        11;
        LBLUE =         12;
        LCYAN =         13;
        LYELLOW =       14;
        LMAGENTA =      15;

TYPE    BoxInfo =       RECORD
                         char:  CHAR;   (* Bit 24..31 *)
                         frame: CHAR;   (* Bit 16..23 *)
                         flags: BITSET; (* Bit0..Bit3:   Innenfarbe (0..15)
                                          * Bit4..Bit6:   Raster
                                          * Bit7:         Text transparent oder deckend
                                          * Bit8..Bit11:  Textfarbe
                                          * Bit12..Bit15: Rahmenfarbe
                                          *)
                        END;           

TYPE    PtrTEDINFO =    ^TEDINFO;
        TEDINFO =       RECORD
                         tePtext:     PChar;
                         tePtmplt:    PChar;
                         tePvalid:    PChar;
                         teFont:      INTEGER;
                         teFontid:    INTEGER;
                         teJust:      INTEGER;
                         teColor:     BITSET;
                         teFontsize:  INTEGER;
                         teThickness: INTEGER;
                         teTxtlen:    INTEGER;
                         teTmplen:    INTEGER;
                        END;

TYPE    PtrBITBLK =     ^BITBLK;
        BITBLK =        RECORD
                         biData:  POINTER;
                         biWb:    INTEGER;
                         biHl:    INTEGER;
                         biX:     INTEGER;
                         biY:     INTEGER;
                         biColor: INTEGER;
                        END;    

TYPE    PtrPARMBLK =    ^PARMBLK;
        PARMBLK =       RECORD
                         pbTree:      POINTER;
                         pbObj:       INTEGER;
                         prPrevstate: BITSET;
                         prCurrstate: BITSET;
                         pbRect:      tRect;
                         pbClip:      tRect;
                         pbParm:      POINTER;
                        END;

TYPE    PtrUSERBLK =    ^USERBLK;
        USERBLK =       RECORD
                         ubCode: POINTER;
                         ubPara: LONGINT;
                        END;

TYPE    PtrICONBLK =    ^ICONBLK;
        ICONBLK =       RECORD
                         ibPmask: POINTER;
                         ibPdata: POINTER;
                         ibPtext: POINTER;
                         ibChar:  BITSET;
                         ibXchar: INTEGER;
                         ibYchar: INTEGER;
                         ibXicon: INTEGER;
                         ibYicon: INTEGER;
                         ibWicon: INTEGER;
                         ibHicon: INTEGER;
                         ibXtext: INTEGER;
                         ibYtext: INTEGER;
                         ibWtext: INTEGER;
                         ibHtext: INTEGER;
                         (* ibResvd: INTEGER;  Steht im Profibuch, gibts aber 
                          *                    in der wirklichen Welt nicht!!!
                          *                    REEEEESCHKEEEEEEEEE!!!!
                          *)
                        END;

TYPE    PtrCICON =      ^CICON;
        CICON =         RECORD
                         numplanes: INTEGER; (* number of planes in the following data *)
                         coldata:   POINTER; (* pointer to color bitmap in standard form *)
                         colmask:   POINTER; (* pointer to single plane mask of col_data *)
                         seldata:   POINTER; (* pointer to color bitmap of selected icon *)
                         selmask:   POINTER; (* pointer to single plane mask of selected icon *)
                         nextres:   PtrCICON; (* pointer to next icon for a different resolution *)
                        END;

TYPE    PtrCICONBLK =   ^CICONBLK;
        CICONBLK =      RECORD
                         mono:  ICONBLK;  (* default monochrome icon *)
                         color: PtrCICON; (* list of color icons for different resolutions *)
                        END;

TYPE    PtrObjcspec =   ^Objcspec;
        Objcspec =      RECORD
                         CASE INTEGER OF
                          0: (address: POINTER);
                          1: (Box: BoxInfo); (* steht direkt im Langwort! *)
                          2: (TedPtr: PtrTEDINFO);
                          3: (StringPtr: PtrCSTRING);
                          4: (ImagePtr: PtrBITBLK);
                          5: (UserDefPtr: PtrUSERBLK);
                          6: (IconPtr: PtrICONBLK);
                          7: (CiconPtr: PtrCICONBLK);
                          8: (obSpecPtr: PtrObjcspec);
                        END;

TYPE    tOBJECT = RECORD  (* OBJECT ist reserviert *)
                  obNext:   INTEGER;
                  obHead:   INTEGER;
                  obTail:   INTEGER;
                  obType:   INTEGER;
                  obFlags:  BITSET;
                  obState:  BITSET;
                  obSpec:   Objcspec;
                  obX:      INTEGER;
                  obY:      INTEGER;
                  obWidth:  INTEGER;
                  obHeight: INTEGER;
                 END;

TYPE    tObjctree = ^tObjects;
        tObjects  = ARRAY [0..$FFFF] OF tOBJECT;

PROCEDURE objc_add    (tree: POINTER; parent, child: INTEGER);

PROCEDURE objc_delete (tree: POINTER; obj: INTEGER);

PROCEDURE objc_draw   (tree: POINTER; start, depth: INTEGER; pxy: tRect);

FUNCTION  objc_find   (tree: POINTER; start, depth, x, y: INTEGER): INTEGER;

PROCEDURE objc_offset (tree: POINTER; obj: INTEGER; VAR x, y: INTEGER);

PROCEDURE objc_order  (tree: POINTER; obj, newpos: INTEGER);

CONST   EDSTART =       0;
        EDINIT =        1;
        EDCHAR =        2;
        EDEND =         3;

PROCEDURE objc_edit (tree: POINTER; obj: INTEGER; VAR pos: INTEGER;
                     char, kind: INTEGER);

PROCEDURE objc_change (tree: POINTER; obj: INTEGER; pxy: tRect;
                      state: BITSET; mode: INTEGER);

CONST   GetAttributs =  0;
        SetAttributs =  1;

CONST   LK3DIND =       0;
        LK3DACT =       1;
        INDBUTCOL =     2;
        ACTBUTCOL =     3;
        BACKGRCOL =     4;
        AD3DVALUE =     5;

PROCEDURE objc_sysvar (mode, which, i1, i2: INTEGER; VAR o1, o2: INTEGER);

(*-- AES-Appl --------------------------------------------------------*)

CONST   Timer   =       Bit0;
        Button =        Bit1;
        Mouse =         Bit2;
        Keyboard =      Bit3;


TYPE    RecordEntry =   RECORD
                         kind:  LONGBITSET;     (* Siehe Timer .. Keyboard *)
                         event: LONGINT;
                        END;
                          

FUNCTION  appl_init: INTEGER;

PROCEDURE appl_read (id, len: INTEGER; pipe: POINTER);

PROCEDURE appl_write (id, len: INTEGER; pipe: POINTER);

TYPE    FindMode =      (Normal, AesId, MintId, CurrProcess);
                        (* AesID..CurrProcess wird erst ab AES 4.0 
                         * (MultiTOS) unterstÅtzt.
                         *)

FUNCTION appl_find (mode: FindMode; id: INTEGER; name: ARRAY OF CHAR): INTEGER;

PROCEDURE appl_tplay (num, speed: INTEGER; buffer: POINTER);

FUNCTION  appl_trecord (count: INTEGER; buffer: POINTER): INTEGER;

PROCEDURE appl_bvset (disk, hard: BITSET);

PROCEDURE appl_yield;

PROCEDURE appl_exit;


(* Ab AES 4.0 *)

CONST   ApsFirst = 0; (* Suchmodus *)
        ApsNext =  1;
        ApsShell = 2;

CONST   SystemProcess = 1; (* Applikationstyp *)
        Application =   2;
        Accessory =     4;

FUNCTION appl_search (mode: INTEGER; name: ARRAY OF CHAR; VAR typ, id: INTEGER): INTEGER;

CONST AESFont =         0;
      AESSmallfont =    1;
      AESResolution =   2;
      AESLanguage =     3;

PROCEDURE appl_getinfo (typ: INTEGER; VAR out1, out2, out3, out4: INTEGER);

(*-- AES-Evnt --------------------------------------------------------*)


CONST   KRSHIFT =       Bit0;   (* Tastatur-Status *)
        KLSHIFT =       Bit1;
        KCTRL =         Bit2;
        KALT =          Bit3;
        KCAPS =         Bit4;   (* FÅr AES undokumentiert! *)


PROCEDURE evnt_keybd (VAR taste, scan: INTEGER; VAR ascii: CHAR);

FUNCTION  evnt_button (maxclicks: INTEGER;
                      mask, state: BITSET;
                      VAR x, y: INTEGER;
                      VAR button, kbshift: BITSET): INTEGER;


CONST   EnterRect =     0;
        LeaveRect =     1;

PROCEDURE evnt_mouse  (mode: INTEGER; m1rect: tRect;
                      VAR x, y: INTEGER;  VAR button, kbshift: BITSET);


CONST   MNSELECTED =     10;    (* Eventmessages *)
        WMREDRAW =       20;
        WMTOPPED =       21;
        WMCLOSED =       22;
        WMFULLED =       23;
        WMARROWED =      24;
        WAUPPAGE =        0;
        WADNPAGE =        1;
        WAUPLINE =        2;
        WADNLINE =        3;
        WALFPAGE =        4;
        WARTPAGE =        5;
        WALFLINE =        6;
        WARTLINE =        7;
        WMHSLID =        25;
        WMVSLID =        26;
        WMSIZED =        27;
        WMMOVED =        28;
        WMNEWTOP =       29;
        WMUNTOPPED =     30;     (* Neu in AES 4.0 *)
        WMONTOP =        31;     (* Neu in AES 4.0 *)
        WMICONIFY =      34;     (* Neu in AES 4.1 *)
        WMUNICONIFY =    35;     (* Neu in AES 4.1 *)
        WMALLICONIFY =   36;     (* Neu in AES 4.1 *)
        ACOPEN =         40;
        ACCLOSE =        41;
        APTERM =         50;     (* Neu in AES 4.0 *)
        APTFAIL =        51;     (* Neu in AES 4.0 *)
        APRESCHG =       57;     (* Neu in AES 4.0 *)
        SHUTCOMPLETED =  60;     (* Neu in AES 4.0 *)
        RESCHCOMPLETED = 61;     (* Neu in AES 4.0 *)
        APDRAGDROP =     63;     (* Neu in AES 4.0 *)
        SHWDRAW =        72;     (* Neu in AES 4.0 *)
        CHEXIT =         90;     (* Neu in AES 4.0 *)

PROCEDURE evnt_mesag (buffer: POINTER);

PROCEDURE evnt_timer (count: LONGINT);


CONST   MUKEYBD =       Bit0;      (* Event-Typen *)
        MUBUTTON =      Bit1;
        MUM1 =          Bit2;
        MUM2 =          Bit3;
        MUMESAG =       Bit4;
        MUTIMER =       Bit5;

PROCEDURE evnt_multi (wich: BITSET;
                     maxclicks: INTEGER;
                     mask, state: BITSET;
                     m1mode: INTEGER;
                     m1rect: tRect;
                     m2mode: INTEGER;
                     m2rect: tRect;
                     msgBuff: POINTER;
                     loTimer, hiTimer: INTEGER;
                     VAR x, y: INTEGER;
                     VAR button: BITSET;
                     VAR taste: INTEGER;
                     VAR kbshift: BITSET;
                     VAR scan: INTEGER;
                     VAR ascii: CHAR;
                     VAR clicks: INTEGER;
                     VAR events: BITSET);

PROCEDURE evnt_pmulti (VAR events: BITSET);
(* GemÑû der Anregung im Profibuch wird dieses zusÑtzliche Binding angeboten.
 * Dabei muû man selbst die benîtigten Parameter in die IntIn- und AddrIn-
 * Array schreiben und nach Aufruf der Funktion auch den IntOut-Array
 * auswerten.  Dieses Vorgehen spart in der Regel Zeit, da die ganzen Para-
 * meter von evnt_multi gar nicht erst auf den Stack gepackt werden mÅssen.
 *
 * Ein undokumentiertes Feature ist, daû man nicht alle Parameter setzen muû,
 * wenn man nur auf zwei oder drei Events wartet.
 *)

FUNCTION evnt_dclicks (new: INTEGER; setclick: BOOLEAN): INTEGER;


(*-- AES-Form -----------------------------------------------------------*)


FUNCTION form_do (tree: POINTER; start: INTEGER): INTEGER;


CONST   FMDSTART =      0;
        FMDGROW =       1;
        FMDSHRINK =     2;
        FMDFINISH =     3;

PROCEDURE form_dial   (flag: INTEGER; small, big: tRect);

FUNCTION  form_alert  (button: INTEGER; str: ARRAY OF CHAR): INTEGER;

PROCEDURE form_error  (errNum: INTEGER);

PROCEDURE form_center (tree: POINTER; VAR rect: tRect);

FUNCTION  form_keybd  (tree: POINTER; obj, chin: INTEGER;
                      VAR nextObj, chout: INTEGER): INTEGER;

FUNCTION  form_button (tree: POINTER; obj, clicks: INTEGER; 
                      VAR next: INTEGER): INTEGER;


(*-- AES-FSel -----------------------------------------------------------*)

FUNCTION fsel_input (VAR pfad, name: ARRAY OF CHAR): BOOLEAN;

FUNCTION fsel_exinput (VAR info, pfad, name: ARRAY OF CHAR): BOOLEAN;


(*-- AES-Graf -----------------------------------------------------------*)

PROCEDURE graf_rubberbox (x, y, mw, mh: INTEGER; VAR lw, lh: INTEGER);

PROCEDURE graf_dragbox   (moving, boundary: tRect; VAR x, y: INTEGER);

PROCEDURE graf_movebox   (rect: tRect; dx, dy: INTEGER);

PROCEDURE graf_growbox   (source, dest: tRect);

PROCEDURE graf_shrinkbox (source, dest: tRect);

FUNCTION  graf_watchbox  (tree: POINTER; item: INTEGER;
                         instate, outstate: BITSET): INTEGER;

CONST   Horizontal =    0;
        Vertical =      1;

FUNCTION  graf_slidebox (tree: POINTER; parent, obj: INTEGER; 
                        dir: INTEGER): INTEGER;

PROCEDURE graf_handle (VAR handle, wCh, hCh, wbox, hbox: INTEGER);

CONST   ARROW =          0;
        TEXTCRSR =       1;
        BUSYBEE =        2;
        POINTHAND =      3;
        FLATHAND =       4;
        THINCROSS =      5;
        THICKCROSS =     6;
        OUTLCROSS =      7;
        USERDEF =      255;
        MOFF =         256;
        MON =          257;
        SAVEMOUSE =    258; (* Ab AES 4.0!!! *)
        LASTSAVED =    259; (* Ab AES 4.0!!! *)
        PREVIOSMOUSE = 260; (* Ab AES 4.0!!! *)

PROCEDURE graf_mouse   (form: INTEGER; user: POINTER);

PROCEDURE graf_mkstate (VAR x, y: INTEGER; VAR button, kbshift: BITSET);


(*-- AES-Menu -----------------------------------------------------------*)

CONST   Reset = 0;
        Setflag = 1;

FUNCTION menu_bar (tree: POINTER; action: INTEGER): INTEGER;
(* Ab AES 4.0: Wird als 'action' -1 Åbergeben, bekommt am als Returnwert
 * die Application-Id des Prrozesses, dem die aktuelle MenÅzeile gehîrt.
 *)

PROCEDURE menu_icheck (tree: POINTER; item, action: INTEGER);

PROCEDURE menu_ienable (tree: POINTER; item, action: INTEGER);

PROCEDURE menu_tnormal (tree: POINTER; item, action: INTEGER);
(* Aus welchen GrÅnden auch immer: Bei action sind reset und set vertauscht *)

PROCEDURE menu_text (tree: POINTER; item: INTEGER; str: ARRAY OF CHAR);

FUNCTION menu_register (apid: INTEGER; VAR str: ARRAY OF CHAR): INTEGER;
(* AES 4.0: Wenn apid = -1 wird str zum NAMEN der Application (siehe 
 * ApplFind!)  Dieses Verhalten scheint auch in AES-Versionen vor 4.0 
 * zu funktionieren, ist dort aber NICHT DOKUMENTIERT!!!
 *)

PROCEDURE menu_unregister (apid: INTEGER);

(* Ab AES 4.0 *)

TYPE    MENU =  RECORD
                 mnTree:   POINTER; (* the object tree of the menu *)
                 mnMenu:   INTEGER; (* the parent object of the menu items *)
                 mnItem:   INTEGER; (* the starting menu item *)
                 mnScroll: INTEGER; (* the scroll field status of the menu *)
                 mnKstate: BITSET;  (* The CTRL, ALT, SHIFT Key state *)
                END;

TYPE    MNSET = RECORD
                 display: LONGINT; (* the submenu display delay *)
                 drag:    LONGINT; (* the submenu drag delay *)
                 delay:   LONGINT; (* the single-click scroll delay *)
                 speed:   LONGINT; (* the continuous scroll delay *)
                 height:  INTEGER; (* the menu scroll height *)
                END;

FUNCTION menu_popup (men: MENU; xpos, ypos: INTEGER; VAR mdata: MENU): INTEGER;

CONST   InquireMenu = 0;
        AttachMenu =  1;
        RemoveMenu =  2;

FUNCTION menu_attach (flag: INTEGER; tree: POINTER; item: INTEGER; VAR mdata: MENU): INTEGER;

CONST   InquireStart = 0;
        SetStart =     1;

PROCEDURE menu_istart (flag: INTEGER; tree: POINTER; men, item: INTEGER);

PROCEDURE menu_settings (flag: INTEGER; VAR value: MNSET);

(*-- AES-Rsrc -----------------------------------------------------------*)

FUNCTION  rsrc_load (name: ARRAY OF CHAR): BOOLEAN;

PROCEDURE rsrc_free;

CONST   RTREE =         0;
        ROBJECT =       1;
        RTEDINFO =      2;
        RICONBLK =      3;
        RBITBLK =       4;
        RSTRING =       5;
        RIMAGEDATA =    6;
        ROBSPEC =       7;
        RTEPTEXT =      8;
        RTEPTMPLT =     9;
        RTEPVALID =     10;
        RIBPMASK =      11;
        RIBPDATA =      12;
        RIBPTEXT =      13;
        RBIDATA =       14;
        RFRSTR =        15;
        RFRIMG =        16;

FUNCTION rsrc_gaddr (typ, item: INTEGER): POINTER;

PROCEDURE rsrc_saddr (typ, item: INTEGER; tree: POINTER);

PROCEDURE rsrc_obfix (tree: POINTER; obj: INTEGER);

PROCEDURE rsrc_rcfix (header: POINTER);


(*-- AES-Scrp -----------------------------------------------------------*)

CONST   scCSV =         Bit0;
        scTXT =         Bit1;
        scGEM =         Bit2;
        scIMG =         Bit3;
        scDCA =         Bit4;
        scUSR =         Bit5;

PROCEDURE scrp_read  (VAR pfad: ARRAY OF CHAR; VAR return: BITSET);
(* Funktioniert nicht auf die beschriebene Art mit dem ST/E/TT GEM *)

PROCEDURE scrp_write (pfad: ARRAY OF CHAR);

PROCEDURE scrp_clear; 


(*-- AES-Shel -----------------------------------------------------------*)

PROCEDURE shel_read (VAR command, path: ARRAY OF CHAR);

CONST   LaunchProg =       0; (* exec *)
        LaunchAppl =       1;
        LaunchAcc =        3;
        ShutDown =         4;
        ChangeRez =        5;
        BroadCast =        7;
        Environment =      8;
        MsgRecognize =     9;
        SendMessage =     10;

CONST   NoGraphic =        0; (* appl *)
        Graphic =          1;
        AbortShutdown =    0; (* bei exec = shutdown! *)
        PartialShutdown =  1;
        CompleteShutdown = 2;

CONST   Now =           0;
        AtEnd =         1;


PROCEDURE shel_write (exec, appl, start: INTEGER; command, path: ARRAY OF CHAR);

FUNCTION  shel_get (len: INTEGER; buffer: POINTER): INTEGER;
(* AES 4.0: Liefert die LÑnge des Puffers, wenn len = -1 *)

PROCEDURE shel_put (len: INTEGER; buffer: POINTER);

PROCEDURE shel_find (VAR name: ARRAY OF CHAR);

PROCEDURE shel_envrn (VAR param: ARRAY OF CHAR; name: ARRAY OF CHAR);

PROCEDURE shel_rdef (command, path: ARRAY OF CHAR);

PROCEDURE shel_wdef (command, path: ARRAY OF CHAR);


(*-- AES-Wind -----------------------------------------------------------*)

CONST   NAME =          Bit0;
        CLOSER =        Bit1;
        FULL =          Bit2;
        MOVE =          Bit3;
        INFO =          Bit4;
        Size =          Bit5;   (* SIZE ist reserviertes Wort *)
        UPARROW =       Bit6;
        DNARROW =       Bit7;
        VSLIDE =        Bit8;
        LFARROW =       Bit9;
        RTARROW =       Bit10;
        HSLIDE =        Bit11;
        HOTCLOSEBOX =   Bit12;  (* Was immer das auch ist... *)
        Unused1 =       Bit13;
        SMALLER =       Bit14;  (* ... in MTOS 1.07 ist das Iconifier *)
        Unused2 =       Bit15;

FUNCTION wind_create (comp: BITSET; size: tRect): INTEGER;

PROCEDURE wind_open   (handle: INTEGER; size: tRect);

PROCEDURE wind_close  (handle: INTEGER);

PROCEDURE wind_delete (handle: INTEGER);

CONST   WFRESVD1 =      1;
        WFNAME =        2;
        WFINFO =        3;
        WFWORKXYWH =    4;
        WFCURRXYWH =    5;
        WFPREVXYWH =    6;
        WFFULLXYWH =    7;
        WFHSLIDE =      8;
        WFVSLIDE =      9;
        WFTOP =         10;
        WFFIRSTXYWH =   11;
        WFNEXTXYWH =    12;
        WFRESVD13 =     13;
        WFNEWDESK =     14;
        WFHSLSIZE =     15;
        WFVSLSIZE =     16;
        WFSCREEN =      17;
        WFCOLOR =       18;     (* Neu in AES 4.0 *)
        WFDCOLOR =      19;     (* Neu in AES 4.0 *)
        WFOWNER =       20;     (* Neu in AES 4.0 *)
        WFBEVENT =      24;     (* Neu in AES 4.0 *)
        WFBOTTOM =      25;     (* Neu in AES 4.0 *)

                                (* Neu in AES 4.1 *)
	    WFTOOLBAR =     30;     (* Toolbar parameter for wind_get/set *)
	    WF_FTOOLBAR =   31;     (* Get the First Toolbar rectangle *)
	    WF_NTOOLBAR	=   32;	    (* Get the Next Toolbar rectangle *)
	    WM_TOOLBAR =    37;	    (* Toolbar Button Event Message *)

PROCEDURE wind_get  (handle, typ: INTEGER; VAR para: tRect);

PROCEDURE wind_set  (handle, typ: INTEGER; para: tRect);

FUNCTION wind_find (x, y: INTEGER): INTEGER;

CONST   ENDUPDATE =     0;
        BEGUPDATE =     1;
        ENDMCTRL =      2;
        BEGMCTRL =      3;
        REQUPDATE =   257;
        REQMCTRL =    259;

FUNCTION wind_update (mode: INTEGER): INTEGER;
(* AES 4.0: Bei REQUPDATE bzw. REQMCTRL checkt das AES, ob ein Prozess 
 * schon ein BEGUPDATE bzw. BEGMCTRL abgesetzt hat, und returniert
 * 0 als Fehlercode, falls dies der Fall ist.  Ansonsten wird ein normaler
 * BEGUPDATE bzw. BEGMCTRL ausgefÅhrt.
 *)

CONST   WCBORDER =      0;
        WCWORK =        1;

PROCEDURE wind_calc (mode: INTEGER; comp: BITSET; VAR inr, outr: tRect);

PROCEDURE wind_new;


(*--- AES-Xgraf_ ---------------------------------------------------------*)

PROCEDURE xgrf_stepcalc (ow, oh, x, y, w, h: INTEGER;
                        VAR cx, cy, count, xstep, ystep: INTEGER);

PROCEDURE xgrf_2box (xc, yc, wc, hc, corners, count, xstep, ystep, doubled: INTEGER);


IMPLEMENTATION

(*----------------------------------------------------------------------*
 * Int. Vers | Datum    | Name | énderung                               *
 *-----------+----------+------+----------------------------------------*
 *  1.00     | 14.04.92 |  Hp  | Modula-2 to Pascal                     *
 *-----------+----------+------+----------------------------------------*)

{$I COMPOPT.INC}
{$L GEMCALL.O}

USES M_Sys;

TYPE IntArray = ARRAY [0..$7FFF] OF INTEGER;

VAR  iarray:    ^IntArray;

FUNCTION CallGEM (func: INTEGER; parablock: POINTER): LONGINT;
EXTERNAL;

FUNCTION AESCall (op, c1, c2, c3, c4: INTEGER): INTEGER;
BEGIN
 WITH App^.AESPB^.cbControl^ DO BEGIN
  opcode:= op;
  sizeIntIn:= c1;
  sizeIntOut:= c2;
  sizeAddrIn:= c3;
  sizeAddrOut:= c4;
 END;
 CallGEM (200, App^.AESPB);
 CallResult:= App^.AESPB^.cbPIntOut^[0];
 AESCall:= CallResult;
END (*AESCall*);

FUNCTION appl_init(): INTEGER;
BEGIN
 appl_init:= AESCALL (10, 0, 1, 0, 0);
END (*appl_init*);

PROCEDURE appl_read (id, len: INTEGER; pipe: POINTER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:=  id;
 App^.AESPB^.cbPIntIn^[1]:=  len;
 App^.AESPB^.cbPadrin^[0]:= pipe;
 CallResult:= AESCALL (11, 2, 1, 1, 0);
END (*appl_read*);

PROCEDURE appl_write (id, len: INTEGER; pipe: POINTER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:=  id;
 App^.AESPB^.cbPIntIn^[1]:=  len;
 App^.AESPB^.cbPadrin^[0]:= pipe;
 CallResult:= AESCALL (12, 2, 1, 1, 0);
END (*appl_write*);

FUNCTION appl_find (mode: FindMode; id: INTEGER; name: ARRAY OF CHAR): INTEGER;
VAR x: RECORD
        CASE BOOLEAN OF
         TRUE:  (h, l: WORD);
         FALSE: (p: POINTER);
       END;
BEGIN
 CASE mode OF
  Normal:      x.p:= ADDR (name);
  AesId:       BEGIN  x.h:= $FFFE;  x.l:= id;  END;
  MintId:      BEGIN  x.h:= $FFFF;  x.l:= id;  END;
  CurrProcess: x.p:= POINTER (0);
 END;
 App^.AESPB^.cbPadrin^[0]:= x.p;
 CallResult:= AESCALL (13, 0, 1, 1, 0);
 appl_find:= CallResult;
END (*appl_find*);

PROCEDURE appl_tplay (num, speed: INTEGER; buffer: POINTER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:=  num;
 App^.AESPB^.cbPIntIn^[1]:=  speed;
 App^.AESPB^.cbPadrin^[0]:= buffer;
 CallResult:= AESCALL (14, 2, 1, 1, 0);
END (*appl_tplay*);

FUNCTION appl_trecord (count: INTEGER; buffer: POINTER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:=  count;
 App^.AESPB^.cbPadrin^[0]:= buffer;
 appl_tRecord:= AESCALL (15, 1, 1, 1, 0);
END (*appl_trecord*);

PROCEDURE appl_bvset (disk, hard: BITSET);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= BitsetToWord (disk);
 App^.AESPB^.cbPIntIn^[1]:= BitsetToWord (hard);
 CallResult:= AESCALL (16, 2, 1, 1, 0);
END (*appl_bvset*);

PROCEDURE appl_yield;
BEGIN
 CallResult:= AESCALL (17, 0, 1, 0, 0);
END (*appl_yield*);

FUNCTION appl_search (mode: INTEGER; name: ARRAY OF CHAR; VAR typ, id: INTEGER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= mode;
 App^.AESPB^.cbPadrin^[0]:= ADDR (name);
 CallResult:= AESCALL (18, 1, 3, 1, 0);
 typ:= App^.AESPB^.cbPIntOut^[1];
 id:= App^.AESPB^.cbPIntOut^[2];
 appl_search:= CallResult;
END (*appl_search*);

PROCEDURE appl_exit;
BEGIN
 CallResult:= AESCALL (19, 0, 1, 0, 0);
END (*appl_exit*);

PROCEDURE appl_getinfo (typ: INTEGER; VAR out1, out2, out3, out4: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= typ;
 CallResult:= AESCALL (130, 1, 5, 0, 0);
 out1:= App^.AESPB^.cbPIntOut^[1];
 out2:= App^.AESPB^.cbPIntOut^[2];
 out3:= App^.AESPB^.cbPIntOut^[3];
 out4:= App^.AESPB^.cbPIntOut^[4];
END (*appl_getinfo*);

PROCEDURE evnt_keybd (VAR taste, scan: INTEGER; VAR ascii: CHAR);
BEGIN
 taste:= AESCALL (20, 0, 1, 0, 0); (* Auf Keyboard-Event warten *)
 scan:= HI (taste);
 ascii:= CHR (LO (taste));
END (*evnt_keybd*);

PROCEDURE evnt_multi (wich: BITSET;  maxclicks: INTEGER;
                     mask, state: BITSET;
                     m1mode: INTEGER;  m1rect: tRect;
                     m2mode: INTEGER;  m2rect: tRect;
                     msgBuff: POINTER;
                     loTimer, hiTimer: INTEGER;
                     VAR x, y: INTEGER;
                     VAR button: BITSET;
                     VAR taste: INTEGER;
                     VAR kbshift: BITSET;
                     VAR scan: INTEGER;
                     VAR ascii: CHAR;
                     VAR clicks: INTEGER;
                     VAR events: BITSET);
BEGIN (* multi *)
 (* Array's laden *)
 App^.AESPB^.cbPIntIn^[0]:= BitsetToWord (wich);
 App^.AESPB^.cbPIntIn^[1]:= maxclicks;
 App^.AESPB^.cbPIntIn^[2]:= BitsetToWord (mask);
 App^.AESPB^.cbPIntIn^[3]:= BitsetToWord (state);
 App^.AESPB^.cbPIntIn^[4]:= m1mode;
 App^.AESPB^.cbPIntIn^[5]:= m1rect.x;
 App^.AESPB^.cbPIntIn^[6]:= m1rect.y;
 App^.AESPB^.cbPIntIn^[7]:= m1rect.w;
 App^.AESPB^.cbPIntIn^[8]:= m1rect.h;
 App^.AESPB^.cbPIntIn^[9]:= m2mode;
 App^.AESPB^.cbPIntIn^[10]:= m2rect.x;
 App^.AESPB^.cbPIntIn^[11]:= m2rect.y;
 App^.AESPB^.cbPIntIn^[12]:= m2rect.w;
 App^.AESPB^.cbPIntIn^[13]:= m2rect.h;
 App^.AESPB^.cbPIntIn^[14]:= loTimer;
 App^.AESPB^.cbPIntIn^[15]:= hiTimer;
 App^.AESPB^.cbPadrin^[0]:= msgBuff;
 CallResult:= AESCALL (25, 16, 7, 1, 0);
 WordToBitset (CallResult, events);
 x:= App^.AESPB^.cbPIntOut^[1];
 y:= App^.AESPB^.cbPIntOut^[2];
 WordToBitset (App^.AESPB^.cbPIntOut^[3], button);
 WordToBitset (App^.AESPB^.cbPIntOut^[4], kbshift);
 taste:= App^.AESPB^.cbPIntOut^[5];
 scan:= HI (taste);
 ascii:= CHR (LO (taste));
 clicks:= App^.AESPB^.cbPIntOut^[6];
END (*evnt_multi*);

PROCEDURE evnt_pmulti (VAR events: BITSET);
BEGIN
 CallResult:= AESCALL (25, 16, 7, 1, 0);
 WordToBitset (CallResult, events);
END (*evnt_pmulti*);

FUNCTION evnt_button (maxclicks: INTEGER; mask, state: BITSET;
     VAR x, y: INTEGER;  VAR button, kbshift: BITSET): INTEGER;
VAR clicks: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= maxclicks;
 App^.AESPB^.cbPIntIn^[1]:= BitsetToWord (mask);
 App^.AESPB^.cbPIntIn^[2]:= BitsetToWord (state);
 clicks:= AESCALL (21, 3, 5, 0, 0);
 x:= App^.AESPB^.cbPIntOut^[1];
 y:= App^.AESPB^.cbPIntOut^[2];
 WordToBitset (App^.AESPB^.cbPIntOut^[3], button);
 WordToBitset (App^.AESPB^.cbPIntOut^[4], kbshift);
 evnt_button:= clicks;
END (*evnt_button*);

PROCEDURE evnt_mouse  (mode: INTEGER; m1rect: tRect;
          VAR x, y: INTEGER;  VAR button, kbshift: BITSET);
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= mode;
 iarray:= ADDR  (m1rect);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[1 + i]:= iarray^[i];  END;
 CallResult:= AESCALL (22, 5, 5, 0, 0);
 x:= App^.AESPB^.cbPIntOut^[1];
 y:= App^.AESPB^.cbPIntOut^[2];
 WordToBitset (App^.AESPB^.cbPIntOut^[3], button);
 WordToBitset (App^.AESPB^.cbPIntOut^[4], kbshift);
END (*evnt_mouse*);

PROCEDURE evnt_mesag (buffer: POINTER);
BEGIN
 App^.AESPB^.cbPadrin^[0]:= buffer;
 CallResult:= AESCALL (23, 0, 1, 1, 0);
END (*evnt_mesag*);

PROCEDURE evnt_timer (count: LONGINT);
VAR trick: RECORD
            CASE tag: BOOLEAN OF
             TRUE:  (long: LONGINT);
             FALSE: (hi, lo: INTEGER);
           END;
BEGIN
 trick.long:= count;
 App^.AESPB^.cbPIntIn^[0]:= trick.lo;
 App^.AESPB^.cbPIntIn^[1]:= trick.hi;
 CallResult:= AESCALL (24, 2, 1, 0, 0);
END (*evnt_timer*);

FUNCTION evnt_dclicks (new: INTEGER; setclick: BOOLEAN): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= new;
 IF setclick THEN App^.AESPB^.cbPIntIn^[1]:= 1  ELSE  App^.AESPB^.cbPIntIn^[1]:= 0;
 evnt_dclicks:= AESCALL (26, 2, 1, 0, 0);
END (*evnt_dclicks*);

FUNCTION form_do (tree: POINTER; start: INTEGER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= start;
 App^.AESPB^.cbPadrin^[0]:= tree;
 form_do:= AESCALL (50, 1, 1, 1, 0);
END (*form_do*);

PROCEDURE form_dial (flag: INTEGER; small, big: tRect);
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= flag;
 iarray:= ADDR (small);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[1 + i]:= iarray^[i];  END;
 iarray:= ADDR (big);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[5 + i]:= iarray^[i];  END;
 CallResult:= AESCALL (51, 9, 1, 1, 0);
END (*form_dial*);

FUNCTION form_alert  (button: INTEGER; str: ARRAY OF CHAR): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= button;
 App^.AESPB^.cbPadrin^[0]:= ADDR (str);
 form_alert:= AESCALL (52, 1, 1, 1, 0);
END (*form_alert*);

PROCEDURE form_error  (errNum: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= errNum;
 CallResult:= AESCALL (53, 1, 1, 0, 0);
END (*form_error*);

PROCEDURE form_center (tree: POINTER; VAR rect: tRect);
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (54, 0, 5, 1, 0);
 rect.x:= App^.AESPB^.cbPIntOut^[1];
 rect.y:= App^.AESPB^.cbPIntOut^[2];
 rect.w:= App^.AESPB^.cbPIntOut^[3];
 rect.h:= App^.AESPB^.cbPIntOut^[4];
END (*form_center*);

FUNCTION form_keybd (tree: POINTER;  obj, chIn: INTEGER;
                     VAR nextObj, chOut: INTEGER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= obj;
 App^.AESPB^.cbPIntIn^[1]:= chIn;
 App^.AESPB^.cbPIntIn^[2]:= 0;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (55, 3, 3, 1, 0);
 nextObj:= App^.AESPB^.cbPIntOut^[1];
 chOut:= App^.AESPB^.cbPIntOut^[2];
 form_keybd:= CallResult;
END (*form_keybd*);

FUNCTION form_button (tree: POINTER; obj, clicks: INTEGER;
             VAR next: INTEGER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= obj;
 App^.AESPB^.cbPIntIn^[1]:= clicks;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (56, 2, 2, 1, 0);
 next:= App^.AESPB^.cbPIntOut^[1];
 form_button:= CallResult;
END (*form_button*);

FUNCTION fsel_input (VAR pfad, name: ARRAY OF CHAR): BOOLEAN;
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (pfad);
 App^.AESPB^.cbPadrin^[1]:= ADDR (name);
 CallResult:= AESCALL (90, 0, 2, 2, 0);
 fsel_input:= App^.AESPB^.cbPIntOut^[1] = 1;
END (*fsel_input*);

FUNCTION fsel_exinput (VAR info, pfad, name: ARRAY OF CHAR): BOOLEAN;
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (pfad);
 App^.AESPB^.cbPadrin^[1]:= ADDR (name);
 App^.AESPB^.cbPadrin^[2]:= ADDR (info);
 CallResult:= AESCALL (91, 0, 2, 3, 0);
 fsel_exinput:= App^.AESPB^.cbPIntOut^[1] = 1;
END (*fsel_exinput*);

PROCEDURE graf_rubberbox (x, y, mw, mh: INTEGER; VAR lw, lh: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= x;
 App^.AESPB^.cbPIntIn^[1]:= y;
 App^.AESPB^.cbPIntIn^[2]:= mw;
 App^.AESPB^.cbPIntIn^[3]:= mh;
 CallResult:= AESCALL (70, 4, 3, 0, 0);
 lw:= App^.AESPB^.cbPIntOut^[1];
 lh:= App^.AESPB^.cbPIntOut^[2];
END (*graf_rubberbox*);

PROCEDURE graf_dragbox (moving, boundary: tRect; VAR x, y: INTEGER);
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= moving.w;
 App^.AESPB^.cbPIntIn^[1]:= moving.h;
 App^.AESPB^.cbPIntIn^[2]:= moving.x;
 App^.AESPB^.cbPIntIn^[3]:= moving.y;
 iarray:= ADDR (boundary);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i+4]:= iarray^[i];  END;
 CallResult:= AESCALL (71, 8, 3, 0, 0);
 x:= App^.AESPB^.cbPIntOut^[1];
 y:= App^.AESPB^.cbPIntOut^[2];
END (*graf_dragbox*);

PROCEDURE graf_movebox (rect: tRect; dx, dy: INTEGER);
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= rect.x;
 App^.AESPB^.cbPIntIn^[1]:= rect.y;
 App^.AESPB^.cbPIntIn^[2]:= rect.w;
 App^.AESPB^.cbPIntIn^[3]:= rect.h;
 App^.AESPB^.cbPIntIn^[4]:= dx;
 App^.AESPB^.cbPIntIn^[5]:= dy;
 CallResult:= AESCALL (72, 6, 1, 0, 0);
END (*graf_movebox*);

PROCEDURE graf_growbox (source, dest: tRect);
VAR i: INTEGER;
BEGIN
 iarray:= ADDR (source);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i]:= iarray^[i];  END;
 iarray:= ADDR (dest);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i+4]:= iarray^[i];  END;
 CallResult:= AESCALL (73, 8, 1, 0, 0);
END (*graf_growbox*);

PROCEDURE graf_shrinkbox (source, dest: tRect);
VAR i: INTEGER;
BEGIN
 iarray:= ADDR (source);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i]:= iarray^[i];  END;
 iarray:= ADDR (dest);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i+4]:= iarray^[i];  END;
 CallResult:= AESCALL (74, 8, 1, 0, 0);
END (*graf_shrinkbox*);

FUNCTION graf_watchbox (tree: POINTER; item: INTEGER;
   instate, outstate: BITSET): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[1]:= item;
 App^.AESPB^.cbPIntIn^[2]:= BitsetToWord (instate);
 App^.AESPB^.cbPIntIn^[3]:= BitsetToWord (outstate);
 App^.AESPB^.cbPadrin^[0]:= tree;
 graf_watchbox:= AESCALL (75, 4, 1, 1, 0);
END (*graf_watchbox*);

FUNCTION graf_slidebox (tree: POINTER; parent, obj, dir: INTEGER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= parent;
 App^.AESPB^.cbPIntIn^[1]:= obj;
 App^.AESPB^.cbPIntIn^[2]:= dir;
 App^.AESPB^.cbPadrin^[0]:= tree;
 graf_slidebox:= AESCALL (76, 3, 1, 1, 0);
END (*graf_slidebox*);

PROCEDURE graf_handle (VAR handle, wCh, hCh, wbox, hbox: INTEGER);
BEGIN
 CallResult:= AESCALL (77, 0, 5, 0, 0);
 handle:= App^.AESPB^.cbPIntOut^[0];
 wCh:= App^.AESPB^.cbPIntOut^[1];
 hCh:= App^.AESPB^.cbPIntOut^[2];
 wbox:= App^.AESPB^.cbPIntOut^[3];
 hbox:= App^.AESPB^.cbPIntOut^[4];
END (*graf_handle*);

PROCEDURE graf_mouse (form: INTEGER; user: POINTER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= form;
 App^.AESPB^.cbPadrin^[0]:= user;
 CallResult:= AESCALL (78, 1, 1, 1, 0);
END (*graf_mouse*);

PROCEDURE graf_mkstate (VAR x, y: INTEGER; VAR button, kbshift: BITSET);
BEGIN
 CallResult:= AESCALL (79, 0, 5, 0, 0);
 x:= App^.AESPB^.cbPIntOut^[1];
 y:= App^.AESPB^.cbPIntOut^[2];
 WordToBitset (App^.AESPB^.cbPIntOut^[3], button);
 WordToBitset (App^.AESPB^.cbPIntOut^[4], kbshift);
END (*graf_mkstate*);

FUNCTION menu_bar (tree: POINTER; action: INTEGER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= action;
 App^.AESPB^.cbPadrin^[0]:= tree;
 menu_bar:= AESCALL (30, 1, 1, 1, 0);
END (*menu_bar*);

PROCEDURE menu_icheck (tree: POINTER; item: INTEGER; action: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= item;
 App^.AESPB^.cbPIntIn^[1]:= action;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (31, 2, 1, 1, 0);
END (*menu_icheck*);

PROCEDURE menu_ienable (tree: POINTER; item: INTEGER; action: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= item;
 App^.AESPB^.cbPIntIn^[1]:= action;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (32, 2, 1, 1, 0);
END (*menu_ienable*);

PROCEDURE menu_tnormal (tree: POINTER; item: INTEGER; action: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= item;
 App^.AESPB^.cbPIntIn^[1]:= action;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (33, 2, 1, 1, 0);
END (*menu_tnormal*);

PROCEDURE menu_text (tree: POINTER; item: INTEGER; str: ARRAY OF CHAR);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= item;
 App^.AESPB^.cbPadrin^[0]:= tree;
 App^.AESPB^.cbPadrin^[1]:= ADDR (str);
 CallResult:= AESCALL (34, 1, 1, 2, 0);
END (*menu_text*);

FUNCTION menu_register (apid: INTEGER; VAR str: ARRAY OF CHAR): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= apid;
 App^.AESPB^.cbPadrin^[0]:= ADDR (str);
 menu_register:= AESCALL (35, 1, 1, 1, 0);
END (*menu_register*);

PROCEDURE menu_unregister (apid: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= apid;
 CallResult:= AESCALL (36, 1, 1, 1, 0);
END (*menu_unregister*);

FUNCTION menu_popup (men: MENU; xpos, ypos: INTEGER; VAR mdata: MENU): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= xpos;
 App^.AESPB^.cbPIntIn^[1]:= ypos;
 App^.AESPB^.cbPadrin^[0]:= ADDR (men);
 App^.AESPB^.cbPadrin^[1]:= ADDR (mdata);
 CallResult:= AESCALL (36, 2, 1, 2, 0);
 menu_popup:= CallResult;
END (*menu_popup*);

FUNCTION menu_attach (flag: INTEGER; tree: POINTER; item: INTEGER; VAR mdata: MENU): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= flag;
 App^.AESPB^.cbPIntIn^[1]:= item;
 App^.AESPB^.cbPadrin^[0]:= tree;
 App^.AESPB^.cbPadrin^[1]:= ADDR (mdata);
 CallResult:= AESCALL (37, 2, 1, 2, 0);
 menu_attach:= CallResult;
END (*menu_attach*);

PROCEDURE menu_istart (flag: INTEGER; tree: POINTER; men, item: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= flag;
 App^.AESPB^.cbPIntIn^[1]:= men;
 App^.AESPB^.cbPIntIn^[2]:= item;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (38, 3, 1, 1, 0);
END (*menu_istart*);

PROCEDURE menu_settings (flag: INTEGER; VAR value: MNSET);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= flag;
 App^.AESPB^.cbPadrin^[0]:= ADDR (value);
 CallResult:= AESCALL (39, 1, 1, 1, 0);
END (*menu_settings*);

FUNCTION rsrc_load (name: ARRAY OF CHAR): BOOLEAN;
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (name);
 CallResult:= AESCALL (110, 0, 1, 1, 0);
 rsrc_load:= CallResult <> 0;
END (*rsrc_load*);

PROCEDURE rsrc_free;
BEGIN
 CallResult:= AESCALL (111, 0, 1, 0, 0);
END (*rsrc_free*);

FUNCTION rsrc_gaddr (typ, item: INTEGER): POINTER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= typ;
 App^.AESPB^.cbPIntIn^[1]:= item;
 CallResult:= AESCALL (112, 2, 1, 0, 1);
 rsrc_gaddr:= App^.AESPB^.cbPadrOut^[0];
END (*rsrc_gaddr*);

PROCEDURE rsrc_saddr (typ, item: INTEGER; tree: POINTER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= typ;
 App^.AESPB^.cbPIntIn^[1]:= item;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (113, 2, 1, 1, 0);
END (*rsrc_saddr*);

PROCEDURE rsrc_obfix (tree: POINTER; obj: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= obj;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (114, 1, 1, 1, 0);
END (*rsrc_obfix*);

PROCEDURE rsrc_rcfix (header: POINTER);
BEGIN
 App^.AESPB^.cbPadrin^[0]:= header;
 CallResult:= AESCALL (115, 0, 1, 1, 0);
END (*rsrc_rcfix*);

PROCEDURE scrp_read (VAR pfad: ARRAY OF CHAR; VAR return: BITSET);
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (pfad);
 CallResult:= AESCALL (80, 0, 1, 1, 0);
 WordToBitset (CallResult, return);
END (*scrp_read*);

PROCEDURE scrp_write (pfad: ARRAY OF CHAR);
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (pfad);
 CallResult:= AESCALL (81, 0, 1, 1, 0);
END (*scrp_write*);

PROCEDURE scrp_clear; 
BEGIN
 CallResult:= AESCALL (82, 0, 1, 0, 0);
END (*scrp_clear*);

PROCEDURE shel_read (VAR command, path: ARRAY OF CHAR);
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (command);
 App^.AESPB^.cbPadrin^[1]:= ADDR (path);
 CallResult:= AESCALL (120, 0, 1, 2, 0);
END (*shel_read*);

PROCEDURE shel_write (exec, appl, start: INTEGER;
                     command, path: ARRAY OF CHAR);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:=  exec;
 App^.AESPB^.cbPIntIn^[1]:=  appl;
 App^.AESPB^.cbPIntIn^[2]:=  start;
 App^.AESPB^.cbPadrin^[0]:= ADDR (command);
 App^.AESPB^.cbPadrin^[1]:= ADDR (path);
 CallResult:= AESCALL (121, 3, 1, 2, 0);
END (*shel_write*);

FUNCTION shel_get (len: INTEGER; buffer: POINTER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:=  len;
 App^.AESPB^.cbPadrin^[0]:= buffer;
 shel_get:= AESCALL (122, 1, 1, 1, 0);
END (*shel_get*);

PROCEDURE shel_put (len: INTEGER; buffer: POINTER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:=  len;
 App^.AESPB^.cbPadrin^[0]:= buffer;
 CallResult:= AESCALL (123, 1, 1, 1, 0);
END (*shel_put*);

PROCEDURE shel_find (VAR name: ARRAY OF CHAR);
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (name);
 CallResult:= AESCALL (124, 0, 1, 1, 0);
END (*shel_find*);

PROCEDURE shel_envrn (VAR param: ARRAY OF CHAR; name: ARRAY OF CHAR);
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (param);
 App^.AESPB^.cbPadrin^[1]:= ADDR (name);
 CallResult:= AESCALL (125, 0, 1, 2, 0);
END (*shel_envrn*);

PROCEDURE shel_rdef (command, path: ARRAY OF CHAR);
(* Erst ab GEM 2.0 *)
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (command);
 App^.AESPB^.cbPadrin^[1]:= ADDR (path);
 CallResult:= AESCALL (126, 0, 1, 2, 0);
END (*shel_rdef*);

PROCEDURE shel_wdef (command, path: ARRAY OF CHAR);
(* Erst ab GEM 2.0 *)
BEGIN
 App^.AESPB^.cbPadrin^[0]:= ADDR (command);
 App^.AESPB^.cbPadrin^[1]:= ADDR (path);
 CallResult:= AESCALL (127, 0, 1, 2, 0);
END (*shel_wdef*);

FUNCTION wind_create (comp: BITSET; size: tRect): INTEGER;
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= BitsetToWord (comp);
 iarray:= ADDR (size);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i+1]:= iarray^[i];  END;
 wind_create:= AESCALL (100, 5, 1, 0, 0);
END (*wind_create*);

PROCEDURE wind_open (handle: INTEGER; size: tRect);
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= handle;
 iarray:= ADDR (size);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i+1]:= iarray^[i];  END;
 CallResult:= AESCALL (101, 5, 1, 0, 0);
END (*wind_open*);

PROCEDURE wind_close  (handle: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= handle;
 CallResult:= AESCALL (102, 1, 1, 0, 0);
END (*wind_close*);

PROCEDURE wind_delete (handle: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= handle;
 CallResult:= AESCALL (103, 1, 1, 0, 0);
END (*wind_delete*);

PROCEDURE wind_get (handle, typ: INTEGER; VAR para: tRect);
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= handle;
 App^.AESPB^.cbPIntIn^[1]:= typ;
 CallResult:= AESCALL (104, 2, 5, 0, 0);
 iarray:= ADDR (para);
 FOR i:= 0 TO 3 DO BEGIN  iarray^[i]:= App^.AESPB^.cbPIntOut^[i+1];  END;
END (*wind_get*);

PROCEDURE wind_set (handle, typ: INTEGER; para: tRect);
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= handle;
 App^.AESPB^.cbPIntIn^[1]:= typ;
 iarray:= ADDR (para);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i+2]:= iarray^[i];  END;
 CallResult:= AESCALL (105, 6, 1, 0, 0);
END (*wind_set*);

FUNCTION wind_find (x, y: INTEGER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= x;
 App^.AESPB^.cbPIntIn^[1]:= y;
 wind_find:= AESCALL (106, 2, 1, 0, 0);
END (*wind_find*);

FUNCTION wind_update (mode: INTEGER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= mode;
 wind_update:= AESCALL (107, 1, 1, 0, 0);
END (*wind_update*);

PROCEDURE wind_calc (mode: INTEGER; comp: BITSET; 
                    VAR inr, outr: tRect); 
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= mode;
 App^.AESPB^.cbPIntIn^[1]:= BitsetToWord (comp);
 iarray:= ADDR (inr);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i+2]:= iarray^[i];  END;
 CallResult:= AESCALL (108, 6, 5, 0, 0);
 iarray:= ADDR (outr);
 FOR i:= 0 TO 3 DO BEGIN  iarray^[i]:= App^.AESPB^.cbPIntOut^[i+1];  END;
END (*wind_calc*);

PROCEDURE wind_new;
BEGIN
 CallResult:= AESCALL (109, 0, 0, 0, 0);
END (*wind_new*);

PROCEDURE objc_add (tree: POINTER; parent, child: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= parent;
 App^.AESPB^.cbPIntIn^[1]:= child;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (40, 2, 1, 1, 0);
END (*objc_add*);

PROCEDURE objc_delete (tree: POINTER; obj: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= obj;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (41, 1, 1, 1, 0);
END (*objc_delete*);

PROCEDURE objc_draw (tree: POINTER; start, depth: INTEGER; pxy: tRect);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= start;
 App^.AESPB^.cbPIntIn^[1]:= depth;
 App^.AESPB^.cbPIntIn^[2]:= pxy.x;
 App^.AESPB^.cbPIntIn^[3]:= pxy.y;
 App^.AESPB^.cbPIntIn^[4]:= pxy.w;
 App^.AESPB^.cbPIntIn^[5]:= pxy.h;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (42, 6, 1, 1, 0);
END (*objc_draw*);

FUNCTION objc_find (tree: POINTER;
                   start, depth, x, y: INTEGER): INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= start;
 App^.AESPB^.cbPIntIn^[1]:= depth;
 App^.AESPB^.cbPIntIn^[2]:= x;
 App^.AESPB^.cbPIntIn^[3]:= y;
 App^.AESPB^.cbPadrin^[0]:= tree;
 objc_find:= AESCALL (43, 4, 1, 1, 0);
END (*objc_find*);

PROCEDURE objc_offset (tree: POINTER; obj: INTEGER; VAR x, y: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= obj;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (44, 1, 3, 1, 0);
 x:= App^.AESPB^.cbPIntOut^[1];
 y:= App^.AESPB^.cbPIntOut^[2];
END (*objc_offset*);

PROCEDURE objc_order (tree: POINTER; obj, newpos: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= obj;
 App^.AESPB^.cbPIntIn^[1]:= newpos;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (45, 2, 1, 1, 0);
END (*objc_order*);

PROCEDURE objc_edit (tree: POINTER; obj: INTEGER; VAR pos: INTEGER;
                  char, kind: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= obj;
 App^.AESPB^.cbPIntIn^[1]:= char;
 App^.AESPB^.cbPIntIn^[2]:= pos;
 App^.AESPB^.cbPIntIn^[3]:= kind;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (46, 4, 2, 1, 0);
 pos:= App^.AESPB^.cbPIntOut^[1];
END (*objc_edit*);

PROCEDURE objc_change (tree: POINTER; obj: INTEGER; pxy: tRect;
                      state: BITSET; mode: INTEGER);
VAR i: INTEGER;
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= obj;
 App^.AESPB^.cbPIntIn^[1]:= 0;
 iarray:= ADDR (pxy);
 FOR i:= 0 TO 3 DO BEGIN  App^.AESPB^.cbPIntIn^[i+2]:= iarray^[i];  END;
 App^.AESPB^.cbPIntIn^[6]:= BitsetToWord (state);
 App^.AESPB^.cbPIntIn^[7]:= mode;
 App^.AESPB^.cbPadrin^[0]:= tree;
 CallResult:= AESCALL (47, 8, 1, 1, 0);
END (*objc_change*);

PROCEDURE objc_sysvar (mode, which, i1, i2: INTEGER; VAR o1, o2: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= mode;
 App^.AESPB^.cbPIntIn^[1]:= which;
 App^.AESPB^.cbPIntIn^[2]:= i1;
 App^.AESPB^.cbPIntIn^[3]:= i2;
 CallResult:= AESCALL (48, 4, 3, 0, 0);
 o1:= App^.AESPB^.cbPIntOut^[1];
 o2:= App^.AESPB^.cbPIntOut^[2];
END (*objc_sysvar*);

PROCEDURE xgrf_stepcalc (ow, oh, x, y, w, h: INTEGER;
                        VAR cx, cy, count, xstep, ystep: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= ow;
 App^.AESPB^.cbPIntIn^[1]:= oh;
 App^.AESPB^.cbPIntIn^[2]:= x;
 App^.AESPB^.cbPIntIn^[3]:= y;
 App^.AESPB^.cbPIntIn^[4]:= w;
 App^.AESPB^.cbPIntIn^[5]:= h;
 CallResult:= AESCALL (130, 6, 6, 0, 0);
 cx:=    App^.AESPB^.cbPIntOut^[1];
 cy:=    App^.AESPB^.cbPIntOut^[2];
 count:= App^.AESPB^.cbPIntOut^[3];
 xstep:= App^.AESPB^.cbPIntOut^[4];
 ystep:= App^.AESPB^.cbPIntOut^[5]; 
END (*xgrf_stepcalc*);

PROCEDURE xgrf_2box (xc, yc, wc, hc, corners, count, xstep, ystep, doubled: INTEGER);
BEGIN
 App^.AESPB^.cbPIntIn^[0]:= count; 
 App^.AESPB^.cbPIntIn^[1]:= xstep; 
 App^.AESPB^.cbPIntIn^[2]:= ystep; 
 App^.AESPB^.cbPIntIn^[3]:= doubled; 
 App^.AESPB^.cbPIntIn^[4]:= corners; 
 App^.AESPB^.cbPIntIn^[5]:= xc; 
 App^.AESPB^.cbPIntIn^[6]:= yc; 
 App^.AESPB^.cbPIntIn^[7]:= wc; 
 App^.AESPB^.cbPIntIn^[8]:= hc; 
 CallResult:= AESCALL (131, 9, 1, 0, 0);
END (*xgrf_2box*);

END (*M_AES*).
