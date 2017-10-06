UNIT M_VDI;

INTERFACE

USES Basics;

(*-- VDI-Parameter ---------------------------------------------------*)

TYPE    tWorkIn =        ARRAY [0.. 10] OF INTEGER;
        tWorkOut =       ARRAY [0.. 57] OF INTEGER;
        tPxyArray =      ARRAY [0..  3] OF INTEGER;
        tBigPxyArray =   ARRAY [0..  7] OF INTEGER;
        tMouseArray =    ARRAY [0.. 38] OF INTEGER;
        tSmallArray =    ARRAY [0..  1] OF INTEGER;
        tRGBArray =      ARRAY [0..  2] OF INTEGER;
        tTextAttrArray = ARRAY [0..  9] OF INTEGER;
        tFontName =      ARRAY [0.. 31] OF CHAR;
        tDistanceArray = ARRAY [0..  4] OF INTEGER;
        tFilmName =      ARRAY [0..124] OF CHAR;
        tFilmIndex =     ARRAY [0..7,0..1] OF INTEGER;
        tCtrlArray =     ARRAY [0..512] OF INTEGER;
        tVDICtrlArray =  ARRAY [0.. 11] OF INTEGER;

PROCEDURE VDICall (c0, c1, c3, c5, c6: INTEGER);

CONST   NoGdos =   $0FFFFFFFE;  (* Kein GDOS isntalliert *)
        Gdos =     $00007E88A;  (* GDOS 1.1 von Atari Corp. *)
        AMCGdos =  $00007E864;  (* AMCGDos von Arnd Beissner *)
        AMCLight = $00007E8BA;  (* GEMINI-Spezial-GDos von Arnd Beissner *)
        NVDI =     $000000000;  (* NVDI von Bela GmbH *)

FUNCTION vq_gdos: LONGINT;
(* Achtung, das ABC-GEM (GEM 2.1) schmiert bei dieser Funktion ab!!! *)

(*-- VDI-Attrib ------------------------------------------------------*)
                      

CONST   REPLACE =        1;      (* Schreibmodi *)
        TRANSPARENT =    2;
        XORMODE =        3;
        REVTRANSPARENT = 4;

FUNCTION  vswr_mode (handle, mode: INTEGER): INTEGER;
PROCEDURE vs_color (handle, index: INTEGER; rgb: tRGBArray);
          
CONST   Line =          1;      (* Linienstile *)
        LongDash =      2;
        Dot =           3;
        DashDot =       4;
        Dash =          5;
        DashDotDot =    6;
        User =          7;

FUNCTION  vsl_type (handle, typ: INTEGER): INTEGER;
PROCEDURE vsl_udsty (handle: INTEGER; style: WORD);
FUNCTION  vsl_width (handle, width: INTEGER): INTEGER;
FUNCTION  vsl_color (handle, color: INTEGER): INTEGER;

CONST   Cornerd =       0;      (* Linien-Endtypen *)
        Arrow =         1;
        Rounded =       2;
                      
PROCEDURE vsl_ends (handle, begstyle, endstyle: INTEGER);

CONST   Point =         1;      (* Markertypen *)
        Plus =          2;
        Star =          3;
        Square =        4;
        Cross =         5;
        Diamond =       6;

FUNCTION  vsm_type (handle, typ: INTEGER): INTEGER;
FUNCTION  vsm_height (handle, height: INTEGER): INTEGER; 
FUNCTION  vsm_color (handle, index: INTEGER): INTEGER;
PROCEDURE vst_height (handle, h: INTEGER; VAR cw, ch, bw, bh: INTEGER);
FUNCTION  vst_point (handle, h: INTEGER; VAR cw, ch, bw, bh: INTEGER): INTEGER;
FUNCTION  vst_rotation (handle, angle: INTEGER): INTEGER;
FUNCTION  vst_font (handle, font: INTEGER): INTEGER;
FUNCTION  vst_color (handle, index: INTEGER): INTEGER;

CONST   Fat =           Bit0;      (* Text-Effekte *)
        Light =         Bit1;
        Italic =        Bit2;
        Underline =     Bit3;
        Outline =       Bit4;
        Shadowed =      Bit5;

PROCEDURE vst_effects (handle: INTEGER; effect: BITSET; VAR old: BITSET);

CONST   LeftJust =      0;
        Centerd =       1;
        RightJust =     2;

CONST   BaseJust =      0;
        HalfJust =      1;
        AscentJust =    2;
        BottomJust =    3;
        DescentJust =   4;
        TopJust =       5;

PROCEDURE vst_alignment (handle, hin, vin: INTEGER; VAR hout, vout: INTEGER);

CONST   None =          0;      (* FÅlltypen *)
        Full =          1;
        Pattern =       2;
        Hatch =         3;
        UserFill =      4;

FUNCTION  vsf_interior (handle: INTEGER; index: INTEGER): INTEGER;
FUNCTION  vsf_style (handle, style: INTEGER): INTEGER;
FUNCTION  vsf_color (handle, index: INTEGER): INTEGER; 
FUNCTION  vsf_perimeter (handle: INTEGER; border: BOOLEAN): BOOLEAN;
PROCEDURE vsf_udpat (handle: INTEGER; pat: POINTER; planes: INTEGER);

(*-- VDI-Control -----------------------------------------------------*)


PROCEDURE v_opnwk (VAR win: tWorkIn; VAR handle: INTEGER; VAR wout: tWorkOut);
PROCEDURE v_clswk  (handle: INTEGER);
PROCEDURE v_opnvwk (VAR win: tWorkIn; VAR handle: INTEGER; VAR wout: tWorkOut);
PROCEDURE v_clsvwk (handle: INTEGER);
PROCEDURE v_clrwk (handle: INTEGER);
PROCEDURE v_updwk (handle: INTEGER);
FUNCTION  vst_load_fonts (handle, select: INTEGER): INTEGER;
PROCEDURE vst_unload_fonts (handle, select: INTEGER);
PROCEDURE vs_clip (handle: INTEGER; rect: tRect; doit: BOOLEAN);

(*-- VDI-Escape ------------------------------------------------------*)

PROCEDURE vq_chcells (handle: INTEGER; VAR rows, colums: INTEGER);
PROCEDURE v_exit_cur (handle: INTEGER);
PROCEDURE v_enter_cur (handle: INTEGER);
PROCEDURE v_curup (handle: INTEGER);
PROCEDURE v_curdown (handle: INTEGER);
PROCEDURE v_curright (handle : INTEGER);
PROCEDURE v_curleft (handle: INTEGER);
PROCEDURE v_curhome (handle: INTEGER);
PROCEDURE v_eeos (handle: INTEGER);
PROCEDURE v_eeol (handle: INTEGER);
PROCEDURE v_curaddress (handle, row, column: INTEGER);
PROCEDURE v_curtext (handle: INTEGER; CONST str: ARRAY OF CHAR);
PROCEDURE v_rvon (handle: INTEGER);
PROCEDURE v_rvoff (handle: INTEGER);
PROCEDURE vq_curaddress (handle: INTEGER; VAR row, column: INTEGER);
FUNCTION  vq_tabstatus (handle: INTEGER): INTEGER;
PROCEDURE v_hardcopy (handle: INTEGER);
PROCEDURE v_dspcur (handle, x, y: INTEGER);
PROCEDURE v_rmcur (handle: INTEGER);
PROCEDURE v_form_adv (handle: INTEGER);
PROCEDURE v_output_window (handle: INTEGER; pxy: tRect);
PROCEDURE v_clear_disp_list (handle: INTEGER);
PROCEDURE v_bit_image (handle: INTEGER; CONST fileName: ARRAY OF CHAR; aspect, scaling, numPts: INTEGER; pxy: POINTER);
PROCEDURE vq_scan (handle: INTEGER; VAR gSlice, gPage, size, page, dv: INTEGER);
PROCEDURE v_alpha_text (handle: INTEGER; CONST str: ARRAY OF CHAR);
FUNCTION  vs_palette (handle, palette: INTEGER): INTEGER;
PROCEDURE v_sound (handle, freq, time: INTEGER);
PROCEDURE vs_mute (handle, action: INTEGER);
PROCEDURE vt_resolution (handle, xres, yres: INTEGER; VAR xset, yset: INTEGER);
PROCEDURE vt_axis (handle, xres, yres: INTEGER; VAR xset, yset: INTEGER);
PROCEDURE vt_origin (handle, x, y: INTEGER);
PROCEDURE vq_tdimensions (handle: INTEGER; VAR x, y: INTEGER);
PROCEDURE vt_alignment (handle, x, y: INTEGER);
PROCEDURE vsp_film (handle, index, light: INTEGER);
PROCEDURE vqp_filmname (handle: INTEGER; VAR filmName: ARRAY OF CHAR);
PROCEDURE vsc_expose (handle, state: INTEGER);
PROCEDURE v_meta_extents (handle, minX, minY, maxX, maxY: INTEGER);
PROCEDURE v_write_meta (handle, numIntin: INTEGER; intIn: POINTER; numPtsin: INTEGER; ptsIn: POINTER);
PROCEDURE vm_pagesize (handle, width, height: INTEGER);
PROCEDURE vm_coords (handle, llx, lly, urx, ury: INTEGER);
PROCEDURE vm_filename (handle: INTEGER; CONST fileName: ARRAY OF CHAR);
PROCEDURE v_offset (handle, offset: INTEGER);
PROCEDURE v_fontinit (handle: INTEGER; header: POINTER);

(*-- VDI-Input -------------------------------------------------------*)

CONST   Mouse =         1;      (* Device-Typen *)
        Cursor =        2;
        FKey =          3;
        Keyboard =      4;

CONST   Request =       1;      (* Input-Modus *)
        Sample =        2;

FUNCTION  vsin_mode (handle, device, mode: INTEGER): INTEGER;
PROCEDURE vrq_locator (handle, x, y: INTEGER; VAR xo, yo: INTEGER; VAR term: CHAR);
PROCEDURE vsm_locator (handle, x, y: INTEGER; VAR xo, yo: INTEGER; VAR term: CHAR; VAR result: BITSET);
PROCEDURE vrq_valuator (handle, inv: INTEGER; VAR out: INTEGER; VAR term: CHAR);
PROCEDURE vsm_valuator (handle, inv: INTEGER; VAR out: INTEGER; VAR term: CHAR; VAR result: BITSET);
PROCEDURE vrq_choice (handle, inv: INTEGER; VAR out: INTEGER);
FUNCTION  vsm_choice (handle: INTEGER; VAR choice: INTEGER): INTEGER;
PROCEDURE vrq_string (handle, len: INTEGER; echo: BOOLEAN; x, y: INTEGER; VAR str: ARRAY OF CHAR);
FUNCTION  vsm_string (handle, len: INTEGER; echo: BOOLEAN; x, y: INTEGER; VAR str: ARRAY OF CHAR): INTEGER;
PROCEDURE vsc_form (handle: INTEGER; form: POINTER);
PROCEDURE v_show (handle: INTEGER; reset: BOOLEAN);
PROCEDURE v_hide (handle: INTEGER);
PROCEDURE vq_mouse (handle: INTEGER; VAR stat: BITSET; VAR x, y: INTEGER);
FUNCTION  vex_timv (handle: INTEGER; new: POINTER; VAR intervall: INTEGER): POINTER;
FUNCTION  vex_butv (handle: INTEGER; new: POINTER): POINTER;
FUNCTION  vex_motv (handle: INTEGER; new: POINTER): POINTER;
FUNCTION  vex_curv (handle: INTEGER; new: POINTER): POINTER;

CONST   KRSHIFT =       Bit0;   (* Tastatur-Status *)
        KLSHIFT =       Bit1;
        KCTRL =         Bit2;
        KALT =          Bit3;
        KCAPS =         Bit4;   (* FÅr VDI undokumentiert *)

PROCEDURE vq_key_s (handle: INTEGER; VAR status: BITSET);


(*-- VDI-Inquire -----------------------------------------------------*)

CONST   Workstation =   0;
        Extended =      1;

PROCEDURE vq_extnd (handle, wich: INTEGER; VAR out: tWorkOut);
PROCEDURE vq_color (handle, color: INTEGER; setit: BOOLEAN; VAR rgb: tRGBArray);
PROCEDURE vql_attributes (handle: INTEGER; VAR attrib: tPxyArray);
PROCEDURE vqm_attributes (handle: INTEGER; VAR attrib: tPxyArray);
PROCEDURE vqf_attributes (handle: INTEGER; VAR attrib: tDistanceArray);
PROCEDURE vqt_attributes (handle: INTEGER; VAR attrib: tTextAttrArray);
PROCEDURE vqt_extent (handle: INTEGER; CONST str: ARRAY OF CHAR; VAR extent: tBigPxyArray);
FUNCTION  vqt_width (handle: INTEGER; ch: CHAR; VAR width, left, right: INTEGER): INTEGER;
FUNCTION  vqt_name (handle, element: INTEGER; VAR name: ARRAY OF CHAR): INTEGER;
PROCEDURE vq_cellarray (handle: INTEGER; pxy: tRect; len, rows: INTEGER; VAR elUsed, rowsUsed, status: INTEGER; colArray: POINTER);
FUNCTION  vqin_mode (handle, device: INTEGER): INTEGER;
PROCEDURE vqt_fontinfo (handle : INTEGER; VAR minADE, maxADE, maxWidth: INTEGER; VAR dist: tDistanceArray; VAR effects: tRGBArray);

(*-- VDI-Output ------------------------------------------------------*)

PROCEDURE v_pline (handle, count: INTEGER; pxy: POINTER);
PROCEDURE v_pmarker (handle, count: INTEGER; pxy: POINTER);
PROCEDURE v_gtext (handle, x, y: INTEGER; CONST str: ARRAY OF CHAR);
PROCEDURE v_fillarea (handle, count: INTEGER; pxy: POINTER);
PROCEDURE v_cellarray (handle, len, used, rows, mode: INTEGER; pxy: tPxyArray; color: POINTER);
PROCEDURE v_contourfill (handle, x, y, index: INTEGER);
PROCEDURE vr_recfl (handle: INTEGER; pxy: tRect);
PROCEDURE v_bar (handle: INTEGER; pxy: tRect);
PROCEDURE v_arc (handle, x, y, rad, bega, enda: INTEGER);
PROCEDURE v_pieslice (handle, x, y, rad, begp, endp: INTEGER);
PROCEDURE v_circle (handle, x, y, rad: INTEGER);
PROCEDURE v_ellipse (handle, x, y, xrad, yrad: INTEGER);
PROCEDURE v_ellarc (handle, x, y, xrad, yrad, bega, enda: INTEGER);
PROCEDURE v_ellpie (handle, x, y, xrad, yrad, begp, endp: INTEGER);
PROCEDURE v_rbox (handle: INTEGER; pxy: tRect);
PROCEDURE v_rfbox (handle: INTEGER; pxy: tRect);
PROCEDURE v_justified (handle, x, y, len, wspace, cspace: INTEGER; CONST str: ARRAY OF CHAR);


(*-- VDI-Raster ------------------------------------------------------*)

TYPE MFDB =     RECORD
                 fdAddr:    POINTER;
                 fdW:       INTEGER;
                 fdH:       INTEGER;
                 fdWdwidth: INTEGER;
                 fdStand:   INTEGER;
                 fdNplanes: INTEGER;
                 fdR1:      INTEGER;
                 fdR2:      INTEGER;
                 fdR3:      INTEGER;
                END;

PROCEDURE vro_cpyfm (handle, mode: INTEGER; pxy: ARRAY OF INTEGER; srcMFDB, destMFDB: MFDB);
PROCEDURE vrt_cpyfm (handle, mode, cSet, cNotset: INTEGER; pxy: ARRAY OF INTEGER; srcMFDB, destMFDB: MFDB);
PROCEDURE vr_trnfm (handle: INTEGER; VAR srcMFDB, destMFDB: MFDB);
FUNCTION  v_get_pixel (handle, x, y: INTEGER; VAR index: INTEGER): BOOLEAN;


(*----------------------------------------------------------------------*
 * Die von Atari zusÑtzlich eingefÅhrten erweiterten Funktionen um das  *
 * neue FSMGDOS bzw. Speedo anzusteuern. FÅr nÑhere Informationen bitte *
 * unbedingt den FSM-Programmers Guide von Atari GmbH anfordern!        *
 *----------------------------------------------------------------------*)

CONST   FSMGdos =    $05F46534D;  (* = '_FSM' FSMGdos von Atari Corp. *)
        FontGdos =   $05F464E54;  (* = '_FNT' FontGdos von Atari Corp. *)
        SpeedoGdos = $0464E5443;  (* = 'FSMC' Speedo von Atari Corp. *)

TYPE tSpeedoHeader = RECORD
                      FHFMVER: ARRAY [0..7] OF BYTE;
                      FHFNTSZ: LONGINT;
                      FHFBFSZ: LONGINT;
                      FHCBFSZ: WORD;
                      FHHEDSZ: WORD;
                      FHFNTID: WORD;
                      FHSFVNR: WORD;
                      FHFNTNM: ARRAY [0..69] OF CHAR;
                      FHMDATE: ARRAY [0.. 9] OF CHAR;
                      FHLAYNM: ARRAY [0..69] OF CHAR;
                      FHCPYRT: ARRAY [0..77] OF CHAR;
                      FHNCHRL: WORD;
                      FHNCHRF: WORD;
                      FHFCHRF: WORD;
                      FHNKTKS: WORD;
                      FHNKPRS: WORD;
                      FHFLAGS: Byteset;
                      FHCLFGS: Byteset;
                      FHFAMCL: BYTE;
                      FHFRMCL: BYTE;
                      FHSFNTN: ARRAY [0..31] OF CHAR;
                      FHSFACN: ARRAY [0..15] OF CHAR;
                      FHFNTFM: ARRAY [0..14] OF CHAR;
                      FHITANG: WORD;
                      FHORUPM: WORD;
                      FHWDWTH: WORD;
                      FHEMWTH: WORD;
                      FHENWTH: WORD;
                      FHTNWTH: WORD;
                      FHFGWTH: WORD;
                      FHFXMIN: WORD;
                      FHFYMIN: WORD;
                      FHFXMAX: WORD;
                      FHFYMAX: WORD;
                      FHULPOS: WORD;
                      FHULTHK: WORD;
                      FHSMCTR: ARRAY [0..5] OF BYTE;
                      FHDPSTR: ARRAY [0..5] OF BYTE;
                      FHFNSTR: ARRAY [0..5] OF BYTE;
                      FHALSTR: ARRAY [0..5] OF BYTE;
                      FHCMITR: ARRAY [0..5] OF BYTE;
                      FHSNMTR: ARRAY [0..5] OF BYTE;
                      FHSDNTR: ARRAY [0..5] OF BYTE;
                      FHMNMTR: ARRAY [0..5] OF BYTE;
                      FHMDNTR: ARRAY [0..5] OF BYTE;
                      FHLNMTR: ARRAY [0..5] OF BYTE;
                      FHLDNTR: ARRAY [0..2] OF WORD;
                      SIZEFW:  LONGINT;
                      EXTFHMETRES: LONGINT;
                     END;

PROCEDURE vqt_fontheader (handle: INTEGER; VAR header: tSpeedoHeader;
                          VAR path: ARRAY OF CHAR);

CONST   ScratchFSM =    0;
        ScratchBitmap = 1;
        NoScratch =     2;

PROCEDURE vst_scratch (handle, mode: INTEGER);

CONST   NoError =        0;  (* Fehlermeldungen *)
        CharNotFound =   1;
        ReadError =      8;
        OpenError =      9;
        BadFileformat = 10;
        OutOfMemory =   11;
        MiscError =     -1;

CONST   ToApplication = 0;
        ToScreen =      1;   (* 8^( *)

PROCEDURE vst_error (handle, mode: INTEGER; VAR errorcode: INTEGER);
FUNCTION  vqt_f_name (handle, num: INTEGER; VAR name: ARRAY OF CHAR; VAR fsm: BOOLEAN): INTEGER;
PROCEDURE vqt_f_extent (handle: INTEGER; CONST str: ARRAY OF CHAR; extent: POINTER);
PROCEDURE v_ftext (handle, x, y: INTEGER; CONST str: ARRAY OF CHAR);
PROCEDURE v_killoutline (handle: INTEGER; component: POINTER);
PROCEDURE v_getoutline (handle, ch: INTEGER; xyarray, bezarray: POINTER; maxverts: INTEGER; VAR numvert: INTEGER);
PROCEDURE vqt_pairkern (handle, ch1, ch2: INTEGER; VAR x, y: LONGINT);
PROCEDURE vqt_trackkern (handle: INTEGER; VAR x, y: LONGINT);
PROCEDURE vst_kern (handle, tmode, pmode: INTEGER; VAR tracks, pairs: INTEGER);
FUNCTION  vst_arbpt (handle, point: INTEGER; VAR cw, ch, bw, bh: INTEGER): INTEGER;
FUNCTION  vst_arbpt32 (handle: INTEGER; point: LONGINT; VAR cw, ch, bw, bh: INTEGER): LONGINT;
PROCEDURE vqt_advance   (handle, ch: INTEGER; VAR advx, advy, xremain, yremain: INTEGER);
PROCEDURE vqt_advance32 (handle, ch: INTEGER; VAR advx, advy: LONGINT);
FUNCTION  vqt_devinfo (handle, device: INTEGER; VAR devstr: ARRAY OF CHAR): BOOLEAN;
PROCEDURE vst_width (handle, h: INTEGER; VAR cw, ch, bw, bh: INTEGER);

FUNCTION  v_savecache (handle: INTEGER; CONST filename: ARRAY OF CHAR): INTEGER;
FUNCTION  v_loadcache (handle: INTEGER; CONST filename: ARRAY OF CHAR; mode: INTEGER): INTEGER;
PROCEDURE v_flushcache (handle: INTEGER);
FUNCTION  v_cachesize (handle, cache: INTEGER): LONGINT;

FUNCTION  vst_setsize (handle, point: INTEGER; VAR cw, ch, bw, bh: INTEGER): INTEGER;
FUNCTION  vst_setsize32 (handle: INTEGER; point: LONGINT; VAR cw, ch, bw, bh: INTEGER): LONGINT;
FUNCTION  vst_skew (handle, skew: INTEGER): INTEGER;
PROCEDURE v_get_table (handle: INTEGER; VAR ascii, style: POINTER);

CONST AtariChars =     0;
      BitstreamChars = 1;
      
PROCEDURE vst_charmap (handle, mode: INTEGER);

PROCEDURE v_getbitmap_info (handle, ch: INTEGER; VAR advx, advy, xoff, yoff, width, height: LONGINT);

FUNCTION  v_bez_on (handle: INTEGER): INTEGER;
PROCEDURE v_bez_off (handle: INTEGER);
PROCEDURE v_set_App_buff (handle: INTEGER; buff: POINTER; words: INTEGER);
PROCEDURE v_bez (handle, count: INTEGER;  xyarr, bezarr, extent: POINTER; VAR totpts, totmoves: INTEGER);
PROCEDURE v_bez_fill (handle, count: INTEGER; xyarr, bezarr, extent: POINTER; VAR totpts, totmoves: INTEGER);
FUNCTION  v_bez_qual (handle, percent: INTEGER): INTEGER;

(*----------------------------------------------------------------------*
 * énderungen, die COMPO an Speedo 5.0 durchgefÅhrt hat                 *
 *----------------------------------------------------------------------*)

CONST UNKNOWN_FONT =     $00;  (* unbekannter Font     *)
      BITMAP_FONT =      $01;  (* Bitmap               *)
      SPEEDO_FONT =      $02;  (* Speedo Vektorfont    *)
      TT_FONT =          $04;  (* Truetype             *)
      PFB_FONT =         $08;  (* Type 1 Font          *)
      CFN_FONT =         $10;  (* Calamus Font         *)
      ANY_FONT =         $FF;  (* Maske fÅr alle Fonts *)

CONST FONT_CHECK =       $0000; (* nichts, nur intout[0-2]          *)
      FONT_NAME =        $0001; (* Name des Fonts (Bitmap+Vektor)   *)
      FONT_FAMILY =      $0002; (* Familienbeschreibung             *)
      FONT_STYLE =       $0004; (* Stilbeschreibung                 *)
      FONT_FILE =        $0008; (* Dateinamen des Fonts             *)
      FONT_FILE_A =      $0010; (* zusÑtzliche Datei (z.B. AFM/PFM) *)
      FONT_FILE_B =      $0020; (* zusÑtzliche Datei                *)
      FONT_PNTS_SINGLE = $0040;
      FONT_PNTS_DOUBLE = $0080;
      FONT_PNTS =        $0100; (* gewÅnschte Punktgrîûen           *)
      FONT_STRUCT =      $0200; (* Daten in Struktur eintragen      *)
      FONT_ALL_DATA =    $FFFF;

TYPE  Font_Info =        RECORD
                          size:   LONGINT;                  (* Grîûe der Struktur  *)
                          typ:    BITSET;                   (* Fonttyp             *)
                          id:     INTEGER;                  (* ID                  *)
                          elem:   INTEGER;                  (* Element Nummer      *)
                          name:   ARRAY [0.. 49] OF CHAR;   (* Fontname            *)
                          family: ARRAY [0.. 49] OF CHAR;   (* Familie             *)
                          style:  ARRAY [0.. 49] OF CHAR;   (* Stil                *)
                          ffile:  ARRAY [0..199] OF CHAR;   (* Dateiname des Fonts *)
                          file_a: ARRAY [0..199] OF CHAR;   (* erster Zusatzfile   *)
                          file_b: ARRAY [0..199] OF CHAR;   (* zweiter Zusatzfile  *)
                          num_points: INTEGER;              (* Anzahl Punktgrîûen  *)
                          points: ARRAY [0..63] OF INTEGER; (* Maximal Punktgrîûen *)
                         END;

FUNCTION  vqt_s_info (handle, flag, id, elem: INTEGER; VAR info: Font_Info): INTEGER;
(* Spezielle Informationen Åber den Font erfragen *)

FUNCTION  vqt_s_name (handle, num: INTEGER; VAR name: ARRAY OF CHAR; 
                     VAR fsm: BOOLEAN; VAR typ, flag: INTEGER): INTEGER;

FUNCTION  vst_font_by_name (handle, typ: INTEGER;  VAR name: ARRAY OF CHAR): INTEGER; 
FUNCTION  vqt_name_id  (handle, typ: INTEGER; VAR name: ARRAY OF CHAR): INTEGER; 
FUNCTION  vs_outmode   (handle, mode: INTEGER; flags: BITSET): INTEGER;
FUNCTION  vs_use_fonts (handle, types: INTEGER; flags: BITSET): INTEGER;
PROCEDURE vs_backmap   (handle: INTEGER; flags: BITSET; VAR mapon: BOOLEAN; VAR point: INTEGER);
PROCEDURE v_mono_ftext (handle, x, y: INTEGER; CONST str: ARRAY OF CHAR);

(*----------------------------------------------------------------------*)

IMPLEMENTATION

(*----------------------------------------------------------------------*
 * Int. Vers | Datum    | Name | énderung                               *
 *-----------+----------+------+----------------------------------------*
 *  1.00     | 14.04.92 |  Hp  | Modula-2 to Pascal                     *
 *-----------+----------+------+----------------------------------------*)

USES M_Sys;

{$I COMPOPT.INC}
{$L GEMCALL.O}

TYPE tIntArray = ARRAY [0..$7FFF] OF INTEGER;

VAR iarray:   ^tIntArray;

FUNCTION CallGEM (func: INTEGER; parablock: POINTER): LONGINT;
EXTERNAL;

FUNCTION GetD0: LONGINT;
EXTERNAL;


PROCEDURE VDICall (c0, c1, c3, c5, c6: INTEGER);
BEGIN
 App^.VDIPB^.Control^[0]:= c0;
 App^.VDIPB^.Control^[1]:= c1;
 App^.VDIPB^.Control^[3]:= c3;
 App^.VDIPB^.Control^[5]:= c5;
 App^.VDIPB^.Control^[6]:= c6;
 CallGEM (115, App^.VDIPB);
END (*VDICall*);

FUNCTION Copy2IntIn (CONST s: ARRAY OF CHAR; start: INTEGER): INTEGER;
VAR i: INTEGER;
BEGIN
 i:= 0;
 WHILE s[i] <> #0 DO BEGIN
  App^.VDIPB^.IntIn^[start+i]:= ORD(s[i]);  INC (i);
 END;
 Copy2IntIn:= i;
END (*Copy2IntIn*);

FUNCTION vqt_x_name (handle, element: INTEGER; 
                     VAR name: ARRAY OF CHAR; VAR flags: ARRAY OF INTEGER): INTEGER;
VAR i: INTEGER;
BEGIN
 FillChar (name, SIZEOF (name), #0);
 FillChar (flags, SIZEOF (flags), #0);
 App^.VDIPB^.IntIn^[0]:= element;
 App^.VDIPB^.IntOut^[33]:= 0;
 App^.VDIPB^.IntOut^[34]:= 0;
 VDICall (130, 0, 2, 1, handle);
 FOR i:= 1 TO 32 DO  name[i-1]:= CHR(App^.VDIPB^.IntOut^[i]); name[32]:= #0;
 flags[0]:= App^.VDIPB^.IntOut^[33];
 flags[1]:= App^.VDIPB^.IntOut^[34];
 vqt_x_name:= App^.VDIPB^.IntOut^[0];
END (*vqt_x_name*);

FUNCTION  vswr_mode (handle, mode: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= mode;
 VDICall (32, 0, 1, 0, handle);
 vswr_mode:= App^.VDIPB^.IntOut^[0];
END (*vswr_mode*);

PROCEDURE vs_color (handle, index: INTEGER; rgb: tRGBArray);
BEGIN
 App^.VDIPB^.IntIn^[0]:= index;
 App^.VDIPB^.IntIn^[1]:= rgb[0];
 App^.VDIPB^.IntIn^[2]:= rgb[1];
 App^.VDIPB^.IntIn^[3]:= rgb[2];
 VDICall(14, 0, 4, 0, handle);
END (*vs_color*);

FUNCTION  vsl_type (handle, typ: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= typ;
 VDICall (15, 0, 1, 0, handle);
 vsl_type:= App^.VDIPB^.IntOut^[0];
END (*vsl_type*);

PROCEDURE vsl_udsty (handle: INTEGER; style: WORD);
BEGIN
 App^.VDIPB^.IntIn^[0]:= style;
 VDICall (113, 0, 1, 0, handle);
END (*vsl_udsty*);

FUNCTION  vsl_width (handle, width: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.Ptsin^[0]:= width;
 App^.VDIPB^.Ptsin^[1]:= 0;
 VDICall (16, 1, 0, 0, handle);
 vsl_width:= App^.VDIPB^.PtsOut^[0];
END (*vsl_width*);

FUNCTION  vsl_color (handle, color: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= color;
 VDICall (17, 0, 1, 0, handle);
 vsl_color:= App^.VDIPB^.IntOut^[0];
END (*vsl_color*);

PROCEDURE vsl_ends (handle, begstyle, endstyle: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= begstyle;
 App^.VDIPB^.IntIn^[1]:= endstyle;
 VDICall (108, 0, 2, 0, handle);
END (*vsl_ends*);

FUNCTION  vsm_type (handle, typ: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= typ;
 VDICall (18, 0, 1, 0, handle);
 vsm_type:= App^.VDIPB^.IntOut^[0];
END (*vsm_type*);

FUNCTION  vsm_height (handle, height: INTEGER): INTEGER; 
BEGIN
 App^.VDIPB^.Ptsin^[0]:= height;
 App^.VDIPB^.Ptsin^[1]:= 0;
 VDICall (19, 1, 0, 0, handle);
 vsm_height:= App^.VDIPB^.PtsOut^[0];
END (*vsm_height*);

FUNCTION  vsm_color (handle, index: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= index;
 VDICall (20, 0, 1, 0, handle);
 vsm_color:= App^.VDIPB^.IntOut^[0];
END (*vsm_color*);

PROCEDURE vst_height (handle, h: INTEGER;
                         VAR cw, ch, bw, bh: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= 0;
 App^.VDIPB^.Ptsin^[1]:= h;
 VDICall (12, 1, 0, 0, handle);
 cw:= App^.VDIPB^.PtsOut^[0];
 ch:= App^.VDIPB^.PtsOut^[1];
 bw:= App^.VDIPB^.PtsOut^[2];
 bh:= App^.VDIPB^.PtsOut^[3];
END (*vst_height*);

FUNCTION  vst_point (handle, h: INTEGER;
                         VAR cw, ch, bw, bh: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= h;
 VDICall (107, 0, 1, 0, handle);
 cw:= App^.VDIPB^.PtsOut^[0];
 ch:= App^.VDIPB^.PtsOut^[1];
 bw:= App^.VDIPB^.PtsOut^[2];
 bh:= App^.VDIPB^.PtsOut^[3];
 vst_point:= App^.VDIPB^.IntOut^[0];
END (*vst_point*);

FUNCTION  vst_rotation (handle, angle: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= angle;
 VDICall (13, 0, 1, 0, handle);
 vst_rotation:= App^.VDIPB^.IntOut^[0];
END (*vst_rotation*);

FUNCTION  vst_font (handle, font: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= font;
 VDICall (21, 0, 1, 0, handle);
 vst_font:= App^.VDIPB^.IntOut^[0];
END (*vst_font*);

FUNCTION  vst_color (handle, index: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= index;
 VDICall (22, 0, 1, 0, handle);
 vst_color:= App^.VDIPB^.IntOut^[0];
END (*vst_color*);

PROCEDURE vst_effects (handle: INTEGER; effect: BITSET; VAR old: BITSET);
BEGIN
 App^.VDIPB^.IntIn^[0]:= BitsetToWord (effect);
 VDICall (106, 0, 1, 0, handle);
 WordToBitset (App^.VDIPB^.IntOut^[0], old);
END (*vst_effects*);

PROCEDURE vst_alignment (handle, hin, vin: INTEGER; 
                            VAR hout, vout: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= hin;
 App^.VDIPB^.IntIn^[1]:= vin;
 VDICall (39, 0, 2, 0, handle);
 hout:= App^.VDIPB^.IntOut^[0];
 vout:= App^.VDIPB^.IntOut^[1];
END (*vst_alignment*);

FUNCTION  vsf_interior (handle, index: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= index;
 VDICall (23, 0, 1, 0, handle);
 vsf_interior:= App^.VDIPB^.IntOut^[0];
END (*vsf_interior*);

FUNCTION  vsf_style (handle, style: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= style;
 VDICall (24, 0, 1, 0, handle);
 vsf_style:= App^.VDIPB^.IntOut^[0];
END (*vsf_style*);

FUNCTION  vsf_color (handle, index: INTEGER): INTEGER; 
BEGIN
 App^.VDIPB^.IntIn^[0]:= index;
 VDICall (25, 0, 1, 0, handle);
 vsf_color:= App^.VDIPB^.IntOut^[0];
END (*vsf_color*);

FUNCTION  vsf_perimeter (handle: INTEGER; border: BOOLEAN): BOOLEAN;
BEGIN
 IF border THEN BEGIN  App^.VDIPB^.IntIn^[0]:= 1;  END
           ELSE BEGIN  App^.VDIPB^.IntIn^[0]:= 0;  END;
 VDICall (104, 0, 1, 0, handle);
 vsf_perimeter:= App^.VDIPB^.IntOut^[0] = 1;
END (*vsf_perimeter*);

PROCEDURE vsf_udpat (handle: INTEGER; pat: POINTER;
                              planes: INTEGER);
VAR old: POINTER;
BEGIN
 old:= App^.VDIPB^.intin;
 App^.VDIPB^.intin:= pat;
 VDICall (112, 0, planes * 16, 0, handle);
 App^.VDIPB^.intin:= old;
END (*vsf_udpat*);

PROCEDURE v_opnwk (VAR win: tWorkin; VAR handle: INTEGER;
                           VAR wout: tWorkOut);
VAR c: INTEGER;
BEGIN
 FOR c:= 0 TO 10 DO BEGIN  App^.VDIPB^.IntIn^[c]:= win[c];  END;
 VDICall(1, 0, 11, 0, handle);
 handle:= App^.VDIPB^.Control^[6];
 FOR c:= 0 TO 44 DO BEGIN wout[c]:= App^.VDIPB^.IntOut^[c]; END;
 FOR c:= 0 TO 11 DO BEGIN wout[c+45]:= App^.VDIPB^.PtsOut^[c]; END;
END (*v_opnwk*);

PROCEDURE v_clswk (handle: INTEGER);
BEGIN
 VDICall(2, 0, 0, 0, handle);
END (*v_clswk*);

PROCEDURE v_opnvwk (VAR win: tWorkIn; VAR handle: INTEGER;
                       VAR wout: tWorkOut);
VAR c: INTEGER;
BEGIN
 FOR c:= 0 TO 10 DO BEGIN App^.VDIPB^.IntIn^[c]:= win[c]; END;
 VDICall(100, 0, 11, 0, handle);
 handle:= App^.VDIPB^.Control^[6];
 FOR c:= 0 TO 44 DO BEGIN wout[c]:= App^.VDIPB^.IntOut^[c]; END;
 FOR c:= 0 TO 11 DO BEGIN wout[c+45]:= App^.VDIPB^.PtsOut^[c]; END;
END (*v_opnvwk*);

PROCEDURE v_clsvwk (handle: INTEGER);
BEGIN
 VDICall(101, 0, 0, 0, handle);
END (*v_clsvwk*);

PROCEDURE v_clrwk (handle: INTEGER);
BEGIN
 VDICall(3, 0, 0, 0, handle);
END (*v_clrwk*);

PROCEDURE v_updwk (handle: INTEGER);
BEGIN
 VDICall(4, 0, 0, 0, handle);
END (*v_updwk*);

FUNCTION  vst_load_fonts (handle, select: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= select;
 VDICall(119, 0, 1, 0, handle);
 vst_load_fonts:= App^.VDIPB^.IntOut^[0];
END (*vst_load_fonts*);

PROCEDURE vst_unload_fonts (handle, select: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= select;
 VDICall(120, 0, 1, 0, handle);
END (*vst_unload_fonts*);

PROCEDURE vs_clip (handle: INTEGER; rect: tRect; doit: BOOLEAN);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= rect.x;
 App^.VDIPB^.Ptsin^[1]:= rect.y;
 App^.VDIPB^.Ptsin^[2]:= rect.w;
 App^.VDIPB^.Ptsin^[3]:= rect.h;
 IF doit THEN BEGIN  App^.VDIPB^.IntIn^[0]:= 1; END
         ELSE BEGIN  App^.VDIPB^.IntIn^[0]:= 0; END;
 VDICall(129, 2, 1, 0, handle);
END (*vs_clip*);

PROCEDURE vq_chcells (handle: INTEGER; VAR rows, colums: INTEGER);
BEGIN
 VDICall  (5, 0, 0, 1, handle);
 rows:= App^.VDIPB^.IntOut^[0];
 colums:= App^.VDIPB^.IntOut^[1];
END (*vq_chcells*);

PROCEDURE v_exit_cur (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 2, handle);
END (*v_exit_cur*);

PROCEDURE v_enter_cur (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 3, handle);
END (*v_enter_cur*);

PROCEDURE v_curup (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 4, handle);
END (*v_curup*);

PROCEDURE v_curdown (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 5, handle);
END (*v_curdown*);

PROCEDURE v_curright (handle : INTEGER);
BEGIN
 VDICall (5, 0, 0, 6, handle);
END (*v_curright*);

PROCEDURE v_curleft (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 7, handle);
END (*v_curleft*);

PROCEDURE v_curhome (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 8, handle);
END (*v_curhome*);

PROCEDURE v_eeos (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 9, handle);
END (*v_eeos*);

PROCEDURE v_eeol (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 10, handle);
END (*v_eeol*);

PROCEDURE v_curaddress (handle, row, column: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= row;
 App^.VDIPB^.IntIn^[1]:= column;
 VDICall (5, 0, 2, 11, handle);
END (*v_curaddress*);

PROCEDURE v_curtext (handle: INTEGER; CONST str: ARRAY OF CHAR);
BEGIN
 VDICall (5, 0, Copy2IntIn (str, 0) - 1, 12, handle);
END (*v_curtext*);

PROCEDURE v_rvon (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 13, handle);
END (*v_rvon*);

PROCEDURE v_rvoff (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 14, handle);
END (*v_rvoff*);

PROCEDURE vq_curaddress (handle: INTEGER; VAR row, column: INTEGER);
BEGIN
 VDICall (5, 0, 0, 15, handle);
 row:= App^.VDIPB^.IntOut^[0];
 column:= App^.VDIPB^.IntOut^[1];
END (*vq_curaddress*);

FUNCTION  vq_tabstatus (handle: INTEGER): INTEGER;
BEGIN
 VDICall (5, 0, 0, 16, handle);
 vq_tabstatus:= App^.VDIPB^.IntOut^[0];
END (*vq_tabstatus*);

PROCEDURE v_hardcopy (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 17, handle);
END (*v_hardcopy*);

PROCEDURE v_dspcur (handle, x, y: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 VDICall (5, 1, 0, 18, handle);
END (*v_dspcur*);

PROCEDURE v_rmcur (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 19, handle);
END (*v_rmcur*);

PROCEDURE v_form_adv (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 20, handle);
END (*v_form_adv*);

PROCEDURE v_output_window (handle: INTEGER; pxy: tRect);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= pxy.x;
 App^.VDIPB^.Ptsin^[1]:= pxy.y;
 App^.VDIPB^.Ptsin^[2]:= pxy.w;
 App^.VDIPB^.Ptsin^[3]:= pxy.h;
 VDICall (5, 2, 0, 21, handle);
END (*v_output_window*);

PROCEDURE v_clear_disp_list (handle: INTEGER);
BEGIN
 VDICall (5, 0, 0, 22, handle);
END (*v_clear_disp_list*);

PROCEDURE v_bit_image (handle: INTEGER; CONST fileName: ARRAY OF CHAR;
                        aspect, scaling, numPts: INTEGER;
                        pxy: POINTER);
VAR i: INTEGER;
    o: POINTER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= aspect;
 App^.VDIPB^.IntIn^[1]:= scaling;
 o:= App^.VDIPB^.ptsin;  App^.VDIPB^.ptsin:= pxy;
 VDICall (5, numPts, Copy2IntIn (filename, 2) - 1, 23, handle);
 App^.VDIPB^.ptsin:= o;
END (*v_bit_image*);

PROCEDURE vq_scan(handle: INTEGER; VAR gSlice, gPage, size, page, dv: INTEGER);
BEGIN
 VDICall (5, 0, 0, 24, handle);
 gSlice:= App^.VDIPB^.IntOut^[0];
 gPage:= App^.VDIPB^.IntOut^[1];
 size:= App^.VDIPB^.IntOut^[2];
 page:= App^.VDIPB^.IntOut^[3];
 dv:= App^.VDIPB^.IntOut^[4];
END (*vq_scan*);

PROCEDURE v_alpha_text (handle: INTEGER; CONST str: ARRAY OF CHAR);
BEGIN
 VDICall (5, 0, Copy2IntIn(str, 0) - 1, 25, handle);
END (*v_alpha_text*);

FUNCTION  vs_palette (handle, palette: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= palette;
 VDICall (5, 0, 1, 60, handle);
 vs_palette:= App^.VDIPB^.IntOut^[0];
END (*vs_palette*);

PROCEDURE v_sound(handle, freq, time: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= freq;
 App^.VDIPB^.IntIn^[1]:= time;
 VDICall (5, 0, 2, 61, handle);
END (*v_sound*);

PROCEDURE vs_mute (handle, action: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= action;
 VDICall (5, 0, 1, 62, handle);
END (*vs_mute*);

PROCEDURE vt_resolution (handle, xres, yres: INTEGER;
                             VAR xset, yset: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= xres;
 App^.VDIPB^.IntIn^[1]:= yres;
 VDICall (5, 0, 2, 81, handle);
 xset:= App^.VDIPB^.IntIn^[0];
 yset:= App^.VDIPB^.IntIn^[1];
END (*vt_resolution*);

PROCEDURE vt_axis (handle, xres, yres: INTEGER;
                             VAR xset, yset: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= xres;
 App^.VDIPB^.IntIn^[1]:= yres;
 VDICall (5, 0, 2, 82, handle);
 xset:= App^.VDIPB^.IntIn^[0];
 yset:= App^.VDIPB^.IntIn^[1];
END (*vt_axis*);

PROCEDURE vt_origin (handle, x, y: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= x;
 App^.VDIPB^.IntIn^[1]:= y;
 VDICall (5, 0, 2, 83, handle);
END (*vt_origin*);

PROCEDURE vq_tdimensions (handle: INTEGER; VAR x, y: INTEGER);
BEGIN
 VDICall  (5, 0, 0, 84, handle);
 x:= App^.VDIPB^.IntIn^[0];
 y:= App^.VDIPB^.IntIn^[1];
END (*vq_tdimensions*);

PROCEDURE vt_alignment (handle, x, y: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= x;
 App^.VDIPB^.IntIn^[1]:= y;
 VDICall (5, 0, 2, 85, handle);
END (*vt_alignment*);

PROCEDURE vsp_film (handle, index, light: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= index;
 App^.VDIPB^.IntIn^[1]:= light;
 VDICall (5, 0, 2, 91, handle);
END (*vsp_film*);

PROCEDURE vqp_filmname (handle: INTEGER; VAR filmName: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
 VDICall (5, 0, 1, 92, handle);
 FOR i:= 0 TO 24 DO BEGIN filmName[i]:= CHR(App^.VDIPB^.IntOut^[i]) END;
 filmName[25]:= CHR (0);
END (*vqp_filmname*);

PROCEDURE vsc_expose (handle, state: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= state;
 VDICall (5, 0, 1, 93, handle);
END (*vsc_expose*);

PROCEDURE v_meta_extents (handle, minX, minY, maxX, maxY: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= minX;
 App^.VDIPB^.Ptsin^[1]:= minY;
 App^.VDIPB^.Ptsin^[2]:= maxX;
 App^.VDIPB^.Ptsin^[3]:= maxY;
 VDICall (5, 2, 0, 98, handle);
END (*v_meta_extents*);

PROCEDURE v_write_meta (handle, numIntin: INTEGER; intIn: POINTER;
                         numPtsin: INTEGER;  ptsIn: POINTER);
VAR oldInt, oldPts: POINTER;
BEGIN
 oldInt:= App^.VDIPB^.intin;
 oldPts:= App^.VDIPB^.ptsin;
 App^.VDIPB^.intin:= intIn;
 App^.VDIPB^.ptsin:= ptsIn;
 VDICall (5, numPtsin, numIntin, 99, handle);
 App^.VDIPB^.intin:= oldInt;
 App^.VDIPB^.ptsin:= oldPts;
END (*v_write_meta*);

PROCEDURE vm_pagesize (handle, width, height: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= 0;
 App^.VDIPB^.IntIn^[1]:= width;
 App^.VDIPB^.IntIn^[2]:= height;
 VDICall (5, 0, 3, 99, handle);
END (*vm_pagesize*);

PROCEDURE vm_coords (handle, llx, lly, urx, ury: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= 1;
 App^.VDIPB^.IntIn^[1]:= llx;
 App^.VDIPB^.IntIn^[2]:= lly;
 App^.VDIPB^.IntIn^[3]:= urx;
 App^.VDIPB^.IntIn^[4]:= ury;
 VDICall (5, 0, 5, 99, handle);
END (*vm_coords*);

PROCEDURE vm_filename (handle: INTEGER; CONST fileName: ARRAY OF CHAR);
BEGIN
 VDICall (5, 0, Copy2IntIn(fileName, 0) - 1, 100, handle);
END (*vm_filename*);

PROCEDURE v_offset (handle, offset: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= offset;
 VDICall (5, 0, 1, 101, handle);
END (*v_offset*);

PROCEDURE v_fontinit (handle: INTEGER; header: POINTER);
BEGIN
 iarray:= header;
 App^.VDIPB^.IntIn^[0]:= iarray^[0];
 App^.VDIPB^.IntIn^[1]:= iarray^[1];
 VDICall (5, 0, 2, 102, handle);
END (*v_fontinit*);

VAR old:   POINTER;
    trick: ^POINTER;

FUNCTION  vsin_mode (handle, device, mode: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= device;
 App^.VDIPB^.IntIn^[1]:= mode;
 VDICall(33, 0, 2, 0, handle);
 vsin_mode:= App^.VDIPB^.IntOut^[0];
END (*vsin_mode*);

PROCEDURE vrq_locator (handle, x, y: INTEGER;
                          VAR xo, yo: INTEGER; VAR term: CHAR);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 VDICall(28, 1, 0, 0, handle);
 xo:= App^.VDIPB^.PtsOut^[0];
 yo:= App^.VDIPB^.PtsOut^[1];
 term:= CHR(App^.VDIPB^.IntOut^[0]);
END (*vrq_locator*);

PROCEDURE vsm_locator (handle, x, y: INTEGER; VAR xo, yo: INTEGER;
                     VAR term: CHAR; VAR result: BITSET);
VAR l:  LONGINT;
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 App^.VDIPB^.Control^[0]:= 28;
 App^.VDIPB^.Control^[1]:= 1;
 App^.VDIPB^.Control^[3]:= 0;
 App^.VDIPB^.Control^[5]:= 0;
 App^.VDIPB^.Control^[6]:= handle;
 CallGEM (115, ADDR (App^.VDIPB));
 l:= GetD0;
 xo:= App^.VDIPB^.PtsOut^[0];
 yo:= App^.VDIPB^.PtsOut^[1];
 term:= CHR(App^.VDIPB^.IntOut^[0]);
 LongToBitset (l, result);
END (*vsm_locator*);

PROCEDURE vrq_valuator (handle, inv: INTEGER; VAR out: INTEGER;
                        VAR term: CHAR);
BEGIN
 App^.VDIPB^.IntIn^[0]:= inv;
 VDICall (29, 0, 1, 0, handle);
 out:= App^.VDIPB^.IntOut^[0];
 term:= CHR(App^.VDIPB^.IntOut^[1]);
END (*vrq_valuator*);

PROCEDURE vsm_valuator (handle, inv: INTEGER; VAR out: INTEGER;
                      VAR term: CHAR; VAR result: BITSET);
BEGIN
 App^.VDIPB^.IntIn^[0]:= inv;
 VDICall (29, 0, 1, 0, handle);
 out:= App^.VDIPB^.IntOut^[0];
 term:= CHR(App^.VDIPB^.IntOut^[1]);
 WordToBitset (App^.VDIPB^.Control^[4], result);
END (*vsm_valuator*);

PROCEDURE vrq_choice (handle, inv: INTEGER; VAR out: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= inv;
 VDICall (30, 0, 1, 0, handle);
 out:= App^.VDIPB^.IntOut^[0];
END (*vrq_choice*);

FUNCTION  vsm_choice (handle: INTEGER; VAR choice: INTEGER ): INTEGER;
BEGIN
 VDICall  (30, 0, 0, 0, handle);
 choice:= App^.VDIPB^.IntOut^[0];
 vsm_choice:= App^.VDIPB^.Control^[4];
END (*vsm_choice*);

PROCEDURE vrq_string (handle, len: INTEGER; echo: BOOLEAN;
                         x, y: INTEGER;
                         VAR str: ARRAY OF CHAR);
VAR h: INTEGER;
    i: INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= len;
 IF echo THEN BEGIN  App^.VDIPB^.IntIn^[1]:= 1;  END
         ELSE BEGIN  App^.VDIPB^.IntIn^[1]:= 0;  END;
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 VDICall (31, 1, 2, 0, handle);
 h:= App^.VDIPB^.Control^[4] - 1;
 FOR i:= 0 TO h DO  str[i]:= CHR(App^.VDIPB^.IntOut^[i]);  str[h+1]:= #0;
END (*vrq_string*);

FUNCTION  vsm_string (handle, len: INTEGER; echo: BOOLEAN;
                        x, y: INTEGER; VAR str: ARRAY OF CHAR): INTEGER;
VAR h: INTEGER;
    i: INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= len;
 IF echo THEN BEGIN App^.VDIPB^.IntIn^[1]:= 1; END
         ELSE BEGIN App^.VDIPB^.IntIn^[1]:= 0; END;
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 VDICall (31, 1, 2, 0, handle);
 h:= App^.VDIPB^.Control^[4] - 1;
 FOR i:= 0 TO h DO  str[i]:= CHR(App^.VDIPB^.IntOut^[i]); str[h+1]:= #0;
 vsm_string:= App^.VDIPB^.Control^[4];
END (*vsm_string*);

PROCEDURE vsc_form (handle: INTEGER; form: POINTER);
BEGIN
 old:= App^.VDIPB^.intin;
 App^.VDIPB^.intin:= form;
 VDICall (111, 0, 37, 0, handle);
 App^.VDIPB^.intin:= old;
END (*vsc_form*);

PROCEDURE v_show (handle: INTEGER; reset: BOOLEAN);
BEGIN
 IF reset THEN BEGIN App^.VDIPB^.IntIn^[0]:= 0; END
          ELSE BEGIN App^.VDIPB^.IntIn^[0]:= 1; END;
 VDICall (122, 0, 1, 0, handle);
END (*v_show*);

PROCEDURE v_hide (handle: INTEGER);
BEGIN
 VDICall (123, 0, 0, 0, handle);
END (*v_hide*);

PROCEDURE vq_mouse (handle: INTEGER; VAR stat: BITSET; VAR x, y: INTEGER);
BEGIN
 VDICall (124, 0, 0, 0, handle);
 WordToBitset (App^.VDIPB^.IntOut^[0], stat);
 x:= App^.VDIPB^.PtsOut^[0];
 y:= App^.VDIPB^.PtsOut^[1];
END (*vq_mouse*);

FUNCTION  vex_timv (handle: INTEGER; new: POINTER;
                        VAR intervall: INTEGER): POINTER;
BEGIN
 trick:= ADDR (App^.VDIPB^.Control^[7]);  trick^:= new;
 VDICall (118, 0, 0, 0, handle);
 intervall:= App^.VDIPB^.IntOut^[0];
 trick:= ADDR (App^.VDIPB^.Control^[9]);
 vex_timv:= trick^;
END (*vex_timv*);

FUNCTION  vex_butv (handle: INTEGER; new: POINTER): POINTER;
BEGIN
 trick:= ADDR (App^.VDIPB^.Control^[7]); trick^:= new;
 VDICall (125, 0, 0, 0, handle);
 trick:= ADDR (App^.VDIPB^.Control^[9]);
 vex_butv:= trick^;
END (*vex_butv*);

FUNCTION  vex_motv (handle: INTEGER; new: POINTER): POINTER;
BEGIN
 trick:= ADDR (App^.VDIPB^.Control^[7]); trick^:= new;
 VDICall (126, 0, 0, 0, handle);
 trick:= ADDR (App^.VDIPB^.Control^[9]);
 vex_motv:= trick^;
END (*vex_motv*);

FUNCTION  vex_curv (handle: INTEGER; new: POINTER): POINTER;
BEGIN
 trick:= ADDR (App^.VDIPB^.Control^[7]); trick^:= new;
 VDICall (127, 0, 0, 0, handle);
 trick:= ADDR (App^.VDIPB^.Control^[9]);
 vex_curv:= trick^;
END (*vex_curv*);

PROCEDURE vq_key_s (handle: INTEGER; VAR status: BITSET);
BEGIN
 VDICall (128, 0, 0, 0, handle);
 WordToBitset (App^.VDIPB^.IntOut^[0], status);
END (*vq_key_s*);

PROCEDURE vq_extnd (handle, wich: INTEGER; VAR out: tWorkout);
VAR i: INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= wich;
 VDICall (102, 0, 1, 0, handle);
 FOR i:=  0 TO 44 DO BEGIN out[i]:= App^.VDIPB^.IntOut^[i]; END;
 FOR i:= 45 TO 56 DO BEGIN out[i]:= App^.VDIPB^.PtsOut^[i-45]; END;
END (*vq_extnd*);

PROCEDURE vq_color (handle, color: INTEGER; setit: BOOLEAN; VAR rgb: tRgbarray);
BEGIN
 App^.VDIPB^.IntIn^[0]:= color;
 IF setit THEN BEGIN App^.VDIPB^.IntIn^[0]:= 0; END
          ELSE BEGIN App^.VDIPB^.IntIn^[0]:= 1;  END;
 VDICall (26, 0, 2, 0, handle);
 rgb[0]:= App^.VDIPB^.IntOut^[1];
 rgb[1]:= App^.VDIPB^.IntOut^[2];
 rgb[2]:= App^.VDIPB^.IntOut^[3];
END (*vq_color*);

PROCEDURE vql_attributes (handle: INTEGER; VAR attrib: tPxyArray);
BEGIN
 VDICall (35, 0, 0, 0, handle);
 attrib[0]:= App^.VDIPB^.IntOut^[0];
 attrib[1]:= App^.VDIPB^.IntOut^[1];
 attrib[2]:= App^.VDIPB^.IntOut^[2];
 attrib[3]:= App^.VDIPB^.PtsOut^[0];
END (*vql_attributes*);

PROCEDURE vqm_attributes (handle: INTEGER; VAR attrib: tPxyArray);
BEGIN
 VDICall (36, 0, 0, 0, handle);
 attrib[0]:= App^.VDIPB^.IntOut^[0];
 attrib[1]:= App^.VDIPB^.IntOut^[1];
 attrib[2]:= App^.VDIPB^.IntOut^[2];
 attrib[3]:= App^.VDIPB^.PtsOut^[1];
END (*vqm_attributes*);

PROCEDURE vqf_attributes (handle: INTEGER; VAR attrib: tDistanceArray);
VAR i: INTEGER;
BEGIN
 VDICall (37, 0, 0, 0, handle);
 FOR i:= 0 TO 4 DO BEGIN attrib[i]:= App^.VDIPB^.IntOut^[i]; END;
END (*vqf_attributes*);

PROCEDURE vqt_attributes (handle: INTEGER; VAR attrib: tTextAttrArray);
VAR i: INTEGER;
BEGIN
 VDICall (38, 0, 0, 0, handle);
 FOR i:= 0 TO 5 DO BEGIN attrib[i]:= App^.VDIPB^.IntOut^[i]; END;
 FOR i:= 6 TO 9 DO BEGIN attrib[i]:= App^.VDIPB^.PtsOut^[i-6]; END;
END (*vqt_attributes*);

PROCEDURE vqt_extent (handle: INTEGER; CONST str: ARRAY OF CHAR;
                         VAR extent: tBigPxyArray);
VAR i: INTEGER;
BEGIN
 VDICall (116, 0, Copy2IntIn(str, 0) - 1, 0, handle);
 FOR i:= 0 TO 7 DO  extent[i]:= App^.VDIPB^.PtsOut^[i];
END (*vqt_extent*);

FUNCTION  vqt_width (handle: INTEGER; ch: CHAR; 
                       VAR width, left, right: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= ORD(ch);
 VDICall (117, 0, 1, 0, handle);
 width:= App^.VDIPB^.PtsOut^[0];
 left:= App^.VDIPB^.PtsOut^[2];
 right:= App^.VDIPB^.PtsOut^[4];
 vqt_width:= App^.VDIPB^.IntOut^[0];
END (*vqt_width*);

FUNCTION vqt_name (handle, element: INTEGER; VAR name: ARRAY OF CHAR): INTEGER;
VAR flags: ARRAY [0..1] OF INTEGER;
BEGIN
 vqt_name:= vqt_x_name (handle, element, name, flags);
END (*vqt_name*);

PROCEDURE vq_cellarray (handle: INTEGER; pxy: tRect;
                     len, rows: INTEGER; 
                     VAR elUsed, rowsUsed, status: INTEGER;
                     colArray: POINTER);
VAR i: INTEGER;
BEGIN
 App^.VDIPB^.Ptsin^[0]:= pxy.x;
 App^.VDIPB^.Ptsin^[1]:= pxy.y;
 App^.VDIPB^.Ptsin^[2]:= pxy.w;
 App^.VDIPB^.Ptsin^[3]:= pxy.h;
 App^.VDIPB^.Control^[7]:= len;
 App^.VDIPB^.Control^[8]:= rows;
 old:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= ADDR (colArray);
 VDICall  (27, 2, 0, 0, handle);
 App^.VDIPB^.ptsin:= old;
 elUsed:= App^.VDIPB^.Control^[9];
 rowsUsed:= App^.VDIPB^.Control^[10];
 status:= App^.VDIPB^.Control^[11];
END (*vq_cellarray*);

FUNCTION  vqin_mode (handle: INTEGER; device: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= device;
 VDICall (115, 0, 1, 0, handle);
 vqin_mode:= App^.VDIPB^.IntOut^[0];
END (*vqin_mode*);

PROCEDURE vqt_fontinfo (handle : INTEGER;
                       VAR minADE, maxADE, maxWidth: INTEGER;
                       VAR dist: tDistanceArray;
                       VAR effects: tRGBArray);
VAR i: INTEGER;
BEGIN
 VDICall (131, 0, 0, 0, handle);
 minADE:= App^.VDIPB^.IntOut^[0];
 maxADE:= App^.VDIPB^.IntOut^[1];
 FOR i:= 0 TO 4 DO BEGIN dist[i]:= App^.VDIPB^.PtsOut^[2 * i + 1]; END;
 maxWidth:= App^.VDIPB^.PtsOut^[0];
 effects[0]:= App^.VDIPB^.PtsOut^[2];
 effects[1]:= App^.VDIPB^.PtsOut^[4];
 effects[2]:= App^.VDIPB^.PtsOut^[6];
END (*vqt_fontinfo*);

VAR oldPts: POINTER;
    oldInt: POINTER;

PROCEDURE v_pline (handle, count: INTEGER; pxy: POINTER);
BEGIN
 oldPts:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= pxy;
 VDICall(6, count, 0, 0, handle);
 App^.VDIPB^.ptsin:= oldPts;
END (*v_pline*);

PROCEDURE v_pmarker (handle, count: INTEGER; pxy: POINTER);
BEGIN
 oldPts:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= pxy;
 VDICall(7, count, 0, 0, handle);
 App^.VDIPB^.ptsin:= oldPts;
END (*v_pmarker*);

PROCEDURE v_gtext (handle, x, y: INTEGER; CONST str: ARRAY OF CHAR);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 VDICall(8, 1, Copy2IntIn(str, 0), 0, handle);
END (*v_gtext*);

PROCEDURE v_fillarea (handle, count: INTEGER; pxy: POINTER);
BEGIN
 oldPts:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= pxy;
 VDICall(9, count, 0, 0, handle);
 App^.VDIPB^.ptsin:= oldPts;
END (*v_fillarea*);

PROCEDURE v_cellarray (handle, len, used, rows, mode: INTEGER;
                     pxy: tPxyArray; color: POINTER);
BEGIN
 App^.VDIPB^.Control^[7]:= len;
 App^.VDIPB^.Control^[8]:= used;
 App^.VDIPB^.Control^[9]:= rows;
 App^.VDIPB^.Control^[10]:= mode;
 oldPts:= App^.VDIPB^.intin;
 oldInt:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= ADDR (pxy);
 App^.VDIPB^.intin:= color;
 VDICall (10, 2, len * rows, 0, handle);
 App^.VDIPB^.ptsin:= oldPts;
 App^.VDIPB^.intin:= oldInt;
END (*v_cellarray*);

PROCEDURE v_contourfill (handle, x, y, index: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= index;
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 VDICall(103, 1, 1, 0, handle);
END (*v_contourfill*);

PROCEDURE vr_recfl (handle: INTEGER; pxy: tRect);
BEGIN
 oldPts:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= ADDR (pxy);
 VDICall(114, 2, 0, 0, handle);
 App^.VDIPB^.ptsin:= oldPts;
END (*vr_recfl*);

PROCEDURE v_bar (handle: INTEGER; pxy: tRect);
BEGIN
 oldPts:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= ADDR (pxy);
 VDICall(11, 2, 0, 1, handle);
 App^.VDIPB^.ptsin:= oldPts;
END (*v_bar*);

PROCEDURE v_arc (handle, x, y, rad, bega, enda: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 App^.VDIPB^.Ptsin^[2]:= 0;
 App^.VDIPB^.Ptsin^[3]:= 0;
 App^.VDIPB^.Ptsin^[4]:= 0;
 App^.VDIPB^.Ptsin^[5]:= 0;
 App^.VDIPB^.Ptsin^[6]:= rad;
 App^.VDIPB^.Ptsin^[7]:= 0;
 App^.VDIPB^.IntIn^[0]:= bega;
 App^.VDIPB^.IntIn^[1]:= enda;
 VDICall(11, 4, 2, 2, handle);
END (*v_arc*);

PROCEDURE v_pieslice (handle, x, y, rad, begp, endp: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 App^.VDIPB^.Ptsin^[2]:= 0;
 App^.VDIPB^.Ptsin^[3]:= 0;
 App^.VDIPB^.Ptsin^[4]:= 0;
 App^.VDIPB^.Ptsin^[5]:= 0;
 App^.VDIPB^.Ptsin^[6]:= rad;
 App^.VDIPB^.Ptsin^[7]:= 0;
 App^.VDIPB^.IntIn^[0]:= begp;
 App^.VDIPB^.IntIn^[1]:= endp;
 VDICall(11, 4, 2, 3, handle);
END (*v_pieslice*);

PROCEDURE v_circle (handle, x, y, rad: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 App^.VDIPB^.Ptsin^[2]:= 0;
 App^.VDIPB^.Ptsin^[3]:= 0;
 App^.VDIPB^.Ptsin^[4]:= rad;
 App^.VDIPB^.Ptsin^[5]:= 0;
 VDICall(11, 3, 0, 4, handle);
END (*v_circle*);

PROCEDURE v_ellipse (handle, x, y, xrad, yrad: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 App^.VDIPB^.Ptsin^[2]:= xrad;
 App^.VDIPB^.Ptsin^[3]:= yrad;
 VDICall(11, 2, 0, 5, handle);
END (*v_ellipse*);

PROCEDURE v_ellarc (handle, x, y, xrad, yrad, bega, enda: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 App^.VDIPB^.Ptsin^[2]:= xrad;
 App^.VDIPB^.Ptsin^[3]:= yrad;
 App^.VDIPB^.IntIn^[0]:= bega;
 App^.VDIPB^.IntIn^[1]:= enda;
 VDICall(11, 2, 2, 6, handle);
END (*v_ellarc*);

PROCEDURE v_ellpie (handle, x, y, xrad, yrad, begp, endp: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 App^.VDIPB^.Ptsin^[2]:= xrad;
 App^.VDIPB^.Ptsin^[3]:= yrad;
 App^.VDIPB^.IntIn^[0]:= begp;
 App^.VDIPB^.IntIn^[1]:= endp;
 VDICall(11, 2, 2, 7, handle);
END (*v_ellpie*);

PROCEDURE v_rbox (handle: INTEGER; pxy: tRect);
BEGIN
 oldPts:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= ADDR (pxy);
 VDICall (11, 2, 0, 8, handle);
 App^.VDIPB^.ptsin:= oldPts;
END (*v_rbox*);

PROCEDURE v_rfbox (handle: INTEGER; pxy: tRect);
BEGIN
 oldPts:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= ADDR (pxy);
 VDICall(11, 2, 0, 9, handle);
 App^.VDIPB^.ptsin:= oldPts;
END (*v_rfbox*);

PROCEDURE v_justified (handle, x, y, len, wspace, cspace: INTEGER; CONST str: ARRAY OF CHAR);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 App^.VDIPB^.Ptsin^[2]:= len;
 App^.VDIPB^.Ptsin^[3]:= 0;
 App^.VDIPB^.IntIn^[0]:= wspace;
 App^.VDIPB^.IntIn^[1]:= cspace;
 VDICall (11, 2, Copy2IntIn (str, 2), 10, handle);
END (*v_justified*);

VAR ptsIn,
    intIn:      POINTER;
    control7:   ^POINTER;
    control9:   ^POINTER;

PROCEDURE vro_cpyfm (handle, mode: INTEGER; pxy: ARRAY OF INTEGER; srcMFDB, destMFDB: MFDB);
BEGIN
 App^.VDIPB^.IntIn^[0]:= mode;
 ptsIn:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= ADDR (pxy);
 control7:= ADDR (App^.VDIPB^.Control^[7]);  control7^:= ADDR (srcMFDB);
 control9:= ADDR (App^.VDIPB^.Control^[9]);  control9^:= ADDR (destMFDB);
 VDICall (109, 4, 1, 0, handle);
 App^.VDIPB^.ptsin:= ptsIn;
END (*vro_cpyfm*);

PROCEDURE vrt_cpyfm (handle, mode, cSet, cNotset: INTEGER; pxy: ARRAY OF INTEGER; srcMFDB, destMFDB: MFDB);
BEGIN
 App^.VDIPB^.IntIn^[0]:= mode;
 App^.VDIPB^.IntIn^[1]:= cSet;
 App^.VDIPB^.IntIn^[2]:= cNotset;
 ptsIn:= App^.VDIPB^.ptsin;
 App^.VDIPB^.ptsin:= ADDR (pxy);
 control7:= ADDR (App^.VDIPB^.Control^[7]);  control7^:= ADDR (srcMFDB);
 control9:= ADDR (App^.VDIPB^.Control^[9]);  control9^:= ADDR (destMFDB);
 VDICall (121, 4, 1, 0, handle);
 App^.VDIPB^.ptsin:= ptsIn;
END (*vrt_cpyfm*);

PROCEDURE vr_trnfm (handle: INTEGER; VAR srcMFDB, destMFDB: MFDB);
BEGIN
 control7:= ADDR (App^.VDIPB^.Control^[7]);  control7^:= ADDR (srcMFDB);
 control9:= ADDR (App^.VDIPB^.Control^[9]);  control9^:= ADDR (destMFDB);
 VDICall (110, 0, 0, 0, handle);
END (*vr_trnfm*);

FUNCTION  v_get_pixel (handle, x, y: INTEGER; VAR index: INTEGER): BOOLEAN;
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 VDICall (105, 1, 0, 0, handle);
 index:= App^.VDIPB^.IntOut^[1];
 v_get_pixel:= App^.VDIPB^.IntOut^[0] = 0;
END (*v_get_pixel*);

PROCEDURE vqt_fontheader (handle: INTEGER; VAR header: tSpeedoHeader;
                          VAR path: ARRAY OF CHAR);
VAR p: ^POINTER;
    i, l: INTEGER;
BEGIN
 p:= ADDR (App^.VDIPB^.IntIn^[0]);
 p^:= ADDR (header);
 VDICall  (232, 0, 2, 0, handle);
 FillChar (path, HIGH (path), #0);  l:= 1;
 FOR i:= 0 TO Min (App^.VDIPB^.Control^[4], SIZEOF (path)-1) DO BEGIN
  path[i]:= CHR (App^.VDIPB^.IntOut^[i]);  INC (l);
 END;
 path[l]:= #0;
END (*vqt_fontheader*);

PROCEDURE vst_scratch (handle, mode: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= mode;
 VDICall  (244, 0, 0, 0, handle);
END (*vst_scratch*);

PROCEDURE vst_error (handle, mode: INTEGER; VAR errorcode: INTEGER);
VAR p: ^POINTER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= mode;
 p:= ADDR (App^.VDIPB^.IntIn^[1]);
 p^:= ADDR (errorcode);
 VDICall (245, 0, 3, 0, handle);
END (*vst_error*);

FUNCTION  vqt_f_name (handle, num: INTEGER; VAR name: ARRAY OF CHAR; VAR fsm: BOOLEAN): INTEGER;
VAR flags: ARRAY [0..1] OF INTEGER;
BEGIN
 flags[0]:= 0;
 vqt_f_name:= vqt_x_name (handle, num, name, flags);
 fsm:= flags[0] <> 0;
END (*vqt_f_name*);

PROCEDURE vqt_f_extent (handle: INTEGER; CONST str: ARRAY OF CHAR; extent: POINTER);
VAR i: INTEGER;
    p: ^tRGBArray;
BEGIN
 VDICall  (240, 0, Copy2IntIn (str, 0), 0, handle);
 p:= extent;
 FOR i:= 0 TO 7 DO BEGIN p^[i]:= App^.VDIPB^.PtsOut^[i]; END;
END (*vqt_f_extent*);

PROCEDURE v_ftext (handle, x, y: INTEGER; CONST str: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 VDICall (241, 1, Copy2IntIn (str, 0), 0, handle);
END (*v_ftext*);

PROCEDURE v_killoutline (handle: INTEGER; component: POINTER);
VAR p: ^POINTER;
BEGIN
 p:= ADDR (App^.VDIPB^.IntIn^[0]); p^:= component;
 VDICall (242, 0, 2, 0, handle);
END (*v_killoutline*);

PROCEDURE v_getoutline (handle, ch: INTEGER; xyarray, bezarray: POINTER;
                        maxverts: INTEGER; VAR numvert: INTEGER);
VAR p: ^POINTER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= ch;
 App^.VDIPB^.IntIn^[1]:= maxverts;
 p:= ADDR (App^.VDIPB^.IntIn^[2]); p^:= xyarray;
 p:= ADDR (App^.VDIPB^.IntIn^[4]); p^:= bezarray;
 VDICall (243, 0, 6, 0, handle);
 numvert:= App^.VDIPB^.IntOut^[0];
END (*v_getoutline*);

PROCEDURE vqt_pairkern (handle, ch1, ch2: INTEGER; VAR x, y: LONGINT);
VAR p: ^LONGINT;
BEGIN
 App^.VDIPB^.IntIn^[0]:= ch1;
 App^.VDIPB^.IntIn^[1]:= ch2;
 VDICall (235, 0, 2, 0, handle);
 p:= ADDR (App^.VDIPB^.PtsOut^[0]); x:= p^;
 p:= ADDR (App^.VDIPB^.PtsOut^[2]); y:= p^;
END (*vqt_pairkern*);

PROCEDURE vqt_trackkern (handle: INTEGER; VAR x, y: LONGINT);
VAR p: ^LONGINT;
BEGIN
 VDICall (234, 0, 2, 0, handle);
 p:= ADDR (App^.VDIPB^.PtsOut^[0]); x:= p^;
 p:= ADDR (App^.VDIPB^.PtsOut^[2]); y:= p^;
END (*vqt_trackkern*);

PROCEDURE vst_kern (handle, tmode, pmode: INTEGER; VAR tracks, pairs: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= tmode;
 App^.VDIPB^.IntIn^[1]:= pmode;
 VDICall (237, 0, 2, 0, handle);
 tracks:= App^.VDIPB^.PtsOut^[0];
 pairs:= App^.VDIPB^.PtsOut^[1];
END (*vst_kern*);

FUNCTION  vst_arbpt (handle, point: INTEGER; VAR cw, ch, bw, bh: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= point;
 VDICall (246, 0, 1, 0, handle);
 cw:= App^.VDIPB^.PtsOut^[0];
 ch:= App^.VDIPB^.PtsOut^[1];
 bw:= App^.VDIPB^.PtsOut^[2];
 bh:= App^.VDIPB^.PtsOut^[3];
 vst_arbpt:= App^.VDIPB^.IntOut^[0];
END (* vst_arbpt*);

FUNCTION  vst_arbpt32 (handle: INTEGER; point: LONGINT; VAR cw, ch, bw, bh: INTEGER): LONGINT;
VAR p: ^LONGINT;
BEGIN
 p:= ADDR (App^.VDIPB^.IntIn^[0]);  p^:= point;
 VDICall (246, 0, 2, 0, handle);
 cw:= App^.VDIPB^.PtsOut^[0];
 ch:= App^.VDIPB^.PtsOut^[1];
 bw:= App^.VDIPB^.PtsOut^[2];
 bh:= App^.VDIPB^.PtsOut^[3];
 p:= ADDR(App^.VDIPB^.IntOut^[0]);
 vst_arbpt32:= p^;
END (* vst_arbpt32*);

PROCEDURE vqt_advance (handle, ch: INTEGER; VAR advx, advy, xremain, yremain: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= ch;
 VDICall (247, 0, 1, 0, handle);
 advx:= App^.VDIPB^.PtsOut^[0];
 advy:= App^.VDIPB^.PtsOut^[1];
 xremain:= App^.VDIPB^.PtsOut^[2];
 yremain:= App^.VDIPB^.PtsOut^[3];
END (*vqt_advance*);

PROCEDURE vqt_advance32 (handle, ch: INTEGER; VAR advx, advy: LONGINT);
VAR p: ^LONGINT;
BEGIN
 App^.VDIPB^.IntIn^[0]:= ch;
 VDICall (247, 0, 1, 0, handle);
 p:= ADDR (App^.VDIPB^.PtsOut^[4]);  advx:= p^;
 p:= ADDR (App^.VDIPB^.PtsOut^[6]);  advy:= p^;
END (*vqt_advance32*);

FUNCTION  vqt_devinfo (handle, device: INTEGER; VAR devstr: ARRAY OF CHAR): BOOLEAN;
VAR i: INTEGER;
    b: BOOLEAN;
BEGIN
 b:= FALSE;
 FillChar (devstr, SIZEOF (devstr), #0);
 App^.VDIPB^.IntIn^[0]:= device;
 VDICall (248, 0, 1, 0, handle);
 IF App^.VDIPB^.PtsOut^[0] = 1 THEN BEGIN
  i:= 0;
  WHILE App^.VDIPB^.IntOut^[i] <> 0 DO BEGIN
   devstr[i]:= CHR (App^.VDIPB^.IntOut^[i]);  INC (i);
  END;
  devstr[i]:= #0;
  b:= TRUE;
 END;
 vqt_devinfo:= b;
END (*vqt_devinfo*);

FUNCTION  v_savecache (handle: INTEGER; CONST filename: ARRAY OF CHAR): INTEGER;
VAR i, l: INTEGER;
BEGIN
 VDICall (249, 0, Copy2IntIn(filename, 0), 0, handle);
 v_savecache:= App^.VDIPB^.IntOut^[0];
END (*v_savecache*);

FUNCTION  v_loadcache (handle: INTEGER; CONST filename: ARRAY OF CHAR; mode: INTEGER): INTEGER;
VAR i, l: INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= mode;
 VDICall (250, 0, Copy2IntIn(filename, 1), 0, handle);
 v_loadcache:= App^.VDIPB^.IntOut^[0];
END (* v_loadcache*);

PROCEDURE v_flushcache (handle: INTEGER);
BEGIN
 VDICall (251, 0, 0, 0, handle);
END (*v_flushcache*);

FUNCTION  v_cachesize (handle, cache: INTEGER): LONGINT;
VAR p: ^LONGINT;
BEGIN
 App^.VDIPB^.IntIn^[0]:= cache;
 VDICall (255, 0, 1, 0, handle);
 p:= ADDR (App^.VDIPB^.IntOut^[0]);
 v_cachesize:= p^;
END (*v_cachesize*);

FUNCTION  vst_setsize (handle, point: INTEGER; VAR cw, ch, bw, bh: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= point;
 VDICall (252, 0, 1, 0, handle);
 cw:= App^.VDIPB^.PtsOut^[0];
 ch:= App^.VDIPB^.PtsOut^[1];
 bw:= App^.VDIPB^.PtsOut^[2];
 bh:= App^.VDIPB^.PtsOut^[3];
 vst_setsize:= App^.VDIPB^.IntOut^[0];
END (*vst_setsize*);

PROCEDURE vst_width (handle, h: INTEGER;
                         VAR cw, ch, bw, bh: INTEGER);
BEGIN
 App^.VDIPB^.Ptsin^[0]:= 0;
 App^.VDIPB^.Ptsin^[1]:= h;
 VDICall (231, 1, 0, 0, handle);
 cw:= App^.VDIPB^.PtsOut^[0];
 ch:= App^.VDIPB^.PtsOut^[1];
 bw:= App^.VDIPB^.PtsOut^[2];
 bh:= App^.VDIPB^.PtsOut^[3];
END (*vst_width*);

FUNCTION  vst_setsize32 (handle: INTEGER; point: LONGINT; VAR cw, ch, bw, bh: INTEGER): LONGINT;
VAR p: ^LONGINT;
BEGIN
 p:= ADDR(App^.VDIPB^.IntIn^[0]); p^:= point;
 VDICall (252, 0, 2, 0, handle);
 cw:= App^.VDIPB^.PtsOut^[0];
 ch:= App^.VDIPB^.PtsOut^[1];
 bw:= App^.VDIPB^.PtsOut^[2];
 bh:= App^.VDIPB^.PtsOut^[3];
 p:= ADDR(App^.VDIPB^.IntOut^[0]);
 vst_setsize32:= p^;
END (*vst_setsize32*);

FUNCTION  vst_skew (handle, skew: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= skew;
 VDICall (253, 0, 1, 0, handle);
 vst_skew:= App^.VDIPB^.IntOut^[0];
END (*vst_skew*);

PROCEDURE v_get_table (handle: INTEGER; VAR ascii, style: POINTER);
VAR p: ^POINTER;
BEGIN
 App^.VDIPB^.IntOut^[0]:= 0;
 App^.VDIPB^.IntOut^[1]:= 0;
 App^.VDIPB^.IntOut^[2]:= 0;
 App^.VDIPB^.IntOut^[3]:= 0;
 VDICall (254, 0, 0, 0, handle);
 p:= ADDR (App^.VDIPB^.IntOut^[0]); ascii:= p^;
 p:= ADDR (App^.VDIPB^.IntOut^[2]); style:= p^;
END (*v_get_table*);

PROCEDURE vst_charmap (handle, mode: INTEGER);
BEGIN
 App^.VDIPB^.IntIn^[0]:= mode;
 VDICall (236, 0, 1, 0, handle);
END (*vst_charmap*);

PROCEDURE v_getbitmap_info (handle, ch: INTEGER;
                            VAR advx, advy, xoff, yoff, width, height: LONGINT);
VAR p: ^LONGINT;
BEGIN
 App^.VDIPB^.IntIn^[0]:= ch;
 VDICall (239, 0, 1, 0, handle);
 width:= App^.VDIPB^.IntOut^[0];
 height:= App^.VDIPB^.IntOut^[1];
 p:= ADDR (App^.VDIPB^.IntOut^[2]); advx:= p^;
 p:= ADDR (App^.VDIPB^.IntOut^[4]); advy:= p^;
 p:= ADDR (App^.VDIPB^.IntOut^[6]); xoff:= p^;
 p:= ADDR (App^.VDIPB^.IntOut^[8]); yoff:= p^;
END (*v_getbitmap_info*);

FUNCTION  v_bez_on (handle: INTEGER): INTEGER;
BEGIN
 VDICall (11, 1, 0, 13, handle);
 v_bez_on:= App^.VDIPB^.IntOut^[0];
END (*v_bez_on*);

PROCEDURE v_bez_off (handle: INTEGER);
BEGIN
 VDICall (11, 0, 0, 13, handle);
END (*v_bez_off*);

PROCEDURE v_set_App_buff (handle: INTEGER; buff: POINTER; words: INTEGER);
VAR p: ^POINTER;
BEGIN
 p:= ADDR (App^.VDIPB^.IntIn^[0]);  p^:= buff;
 App^.VDIPB^.IntIn^[2]:= words;
 VDICall (-1, 0, 0, 6, handle);
END (*v_set_App_buff*);

PROCEDURE v_bez (handle, count: INTEGER;  xyarr, bezarr, extent: POINTER;
                 VAR totpts, totmoves: INTEGER);
VAR oIntin, oPtsin, oIntout, oPtsout: POINTER;
    x: INTEGER;
BEGIN
 WITH App^.VDIPB^ DO BEGIN
  oIntin:=  intin;  intin:=  bezarr;
  oPtsin:=  ptsin;  ptsin:=  xyarr;
  oPtsout:= ptsout; ptsout:= extent;
  x:= (count + 1) DIV 2;
  VDICall (6, count, x, 13, handle);
  totpts:= IntOut^[0];
  totmoves:= IntOut^[1];
  intin:= oIntin;
  ptsin:= oPtsin;
  ptsout:= oPtsout;
 END;
END (*v_bez*);

PROCEDURE v_bez_fill (handle, count: INTEGER; xyarr, bezarr, extent: POINTER;
                      VAR totpts, totmoves: INTEGER);
VAR oIntin, oPtsin, oIntout, oPtsout: POINTER;
BEGIN
 oIntin:=  App^.VDIPB^.intin;  App^.VDIPB^.intin:=  bezarr;
 oPtsin:=  App^.VDIPB^.ptsin;  App^.VDIPB^.ptsin:=  xyarr;
 oPtsout:= App^.VDIPB^.ptsout; App^.VDIPB^.ptsout:= extent;
 VDICall (9, count, (count + 1) DIV 2, 13, handle);
 totpts:= App^.VDIPB^.IntOut^[0];
 totmoves:= App^.VDIPB^.IntOut^[1];
 App^.VDIPB^.intin:= oIntin;
 App^.VDIPB^.ptsin:= oPtsin;
 App^.VDIPB^.ptsout:= oPtsout;
END (*v_bez_fill*);

FUNCTION v_bez_qual (handle, percent: INTEGER): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= 32;
 App^.VDIPB^.IntIn^[1]:= 1;
 App^.VDIPB^.IntIn^[2]:= percent;
 VDICall (5, 0, 3, 99, handle);
 v_bez_qual:= App^.VDIPB^.IntOut^[0];
END (*v_bez_qual*);

FUNCTION vqt_s_info (handle, flag, id, elem: INTEGER; VAR info: Font_Info): INTEGER;
VAR p: ^POINTER;
BEGIN
 info.size:= SIZEOF (info);
 App^.VDIPB^.IntIn^[0]:= flag;
 App^.VDIPB^.IntIn^[1]:= id;
 App^.VDIPB^.IntIn^[2]:= elem;
 p:= ADDR (App^.VDIPB^.IntIn^[3]);
 p^:= ADDR (info);
 VDICALL (229, 0, 5, 0, handle);
 vqt_s_info:= App^.VDIPB^.IntOut^[0];
END; (*vqt_s_info*)

FUNCTION  vqt_s_name;
VAR fl: ARRAY [0..1] OF INTEGER;
BEGIN
 vqt_s_name:= vqt_x_name (handle, num, name, fl);
 fsm:= fl[0] = 1;
 typ:= fl[1] AND $00FF;
 flag:= fl[1] AND $FF00;
END (*vqt_s_name*);

FUNCTION vst_font_by_name (handle, typ: INTEGER; VAR name: ARRAY OF CHAR): INTEGER; 
VAR i: INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= typ;
 VDICALL (230, 0, Copy2IntIn (name, 1), 0, handle);
 vst_font_by_name:= App^.VDIPB^.IntOut^[0];
 i:= 0;
 WHILE i < App^.VDIPB^.Control^[4] DO BEGIN
  name[i]:= CHR (App^.VDIPB^.IntOut^[i+1]);  INC (i);
 END;
 name[i]:= #0
END; (*vst_font_by_name*)

FUNCTION vqt_name_id (handle, typ: INTEGER; VAR name: ARRAY OF CHAR): INTEGER; 
VAR i: INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= typ;
 VDICALL (230, 0, Copy2IntIn (name, 1), 100, handle);
 vqt_name_id:= App^.VDIPB^.IntOut^[0];
 i:= 0;
 WHILE i < App^.VDIPB^.Control^[4] DO BEGIN
  name[i]:= CHR (App^.VDIPB^.IntOut^[i+1]);  INC (i);
 END;
 name[i]:= #0
END; (*vqt_name_id*)

FUNCTION vs_outmode (handle, mode: INTEGER; flags: BITSET): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= mode;
 App^.VDIPB^.IntIn^[1]:= BitsetToWord (flags);
 VDICALL (224, 0, 2, 101, handle);
 vs_outmode:= App^.VDIPB^.IntOut^[0];
END (*vs_outmode*);

FUNCTION vs_use_fonts (handle, types: INTEGER; flags: BITSET): INTEGER;
BEGIN
 App^.VDIPB^.IntIn^[0]:= types;
 App^.VDIPB^.IntIn^[1]:= BitsetToWord (flags);
 VDICALL (224, 0, 2, 105, handle);
 vs_use_fonts:= App^.VDIPB^.IntOut^[0];
END (*vs_use_fonts*);

PROCEDURE vs_backmap (handle: INTEGER; flags: BITSET; 
                      VAR mapon: BOOLEAN; VAR point: INTEGER);
BEGIN
 IF mapon THEN App^.VDIPB^.IntIn^[0]:= 0 ELSE App^.VDIPB^.IntIn^[0]:= 0;
 App^.VDIPB^.IntIn^[1]:= point;
 App^.VDIPB^.IntIn^[2]:= BitsetToWord (flags);
 VDICALL (224, 1, 2, 100, handle);
 mapon:= App^.VDIPB^.IntOut^[0] = 0;
 point:= App^.VDIPB^.IntOut^[1];
END (*vs_backmap*);

PROCEDURE v_mono_ftext (handle, x, y: INTEGER; CONST str: ARRAY OF CHAR);
VAR i: INTEGER;
BEGIN
 App^.VDIPB^.Ptsin^[0]:= x;
 App^.VDIPB^.Ptsin^[1]:= y;
 VDICALL ( 233, 1, Copy2IntIn (str, 0), 0, handle);
END (*v_mono_ftext*);

FUNCTION vq_gdos: LONGINT;
BEGIN
 vq_gdos:= CallGEM (LONGINT (-2), NIL);
END;

END (*M_VDI*).
