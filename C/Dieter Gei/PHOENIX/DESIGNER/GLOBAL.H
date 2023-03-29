/*****************************************************************************
 *
 * Module : GLOBAL.H
 * Author : Dieter Geiû
 *
 * Creation date    : 05.03.90
 * Last modification:
 *
 *
 * Description: This module defines global definitions.
 *
 * History:
 * 05.08.05: Variable nvdi_version and function vqt_ext_name added
 * 25.12.02: Variables bShowDebugInfo added
 * 23.06.02: Variables global_mem1 and global_mem2 added
 * 01.03.97: Variables bUseDesktopWindow, bTopDesktopWindow, and bUseDesktopWindowSliders added
 * 26.02.97: Olga functions added
 * 24.02.97: Functions NameFromDevice and DeviceFromName added
 * 23.02.97: Variable st_guide_apid added
 * 13.02.97: Variable olga_apid added
 * 27.12.96: Function open_work_ex added
 * 23.05.96: Variable use_lfn added
 * 19.10.95: Functions RemLeadSP and RemTrailSP added
 * 21.09.95: Function vst_arbpoint added
 * 16.09.95: Function text_extent added
 * 27.07.95: Function rc_inflate added
 * 14.07.95: Variable screen_info added
 * 18.07.94: Definition of GDOS_TRUETYPEFONT added
 * 24.05.94: Variables btn_round_borders and btn_shadow_width added
 * 26.04.94: Clipboard definitions added
 * 25.04.94: Definitions for SYSTEM_INF and SYSTEM_DIR and variable use_adapt added
 * 04.04.94: Inf file functions added
 * 29.03.94: Parameter char_width in v_text no longer needed
 * 15.03.94: Definition of VA_START added
 * 12.02.94: Variable use_std_fs added
 * 17.12.93: Function scan_to_ascii added
 * 04.12.93: SpeedoGDOS font numbers added
 * 04.11.93: Structs FONTDESC and FONTINFO added
 * 25.10.93: Struct XIMG added
 * 23.10.93: CEDIT_FLAG added
 * 15.10.93: Variable planes added
 * 05.10.93: Variables dlg_checkbox, dlg_radiobutton, and dlg_arrow added
 * 03.10.93: COLOR defines variables added
 * 02.10.93: Type ICON added
 * 30.09.93: Variabled color_desktop and pattern_desktop added
 * 16.09.93: Struct IMG_HEADER added
 * 10.09.93: Function scroll_area moved from WINDOWS.H
 * 05.09.93: Variables color_highlight and color_highlighttext added
 * 04.09.93: Function get_parent added
 * 23.08.93: Function set_ob_spec added
 * 22.03.93: Dialog color variables added
 * 21.03.93: Values of UNDO_FLAG, HELP_FLAG and NOECHO_FLAG changed
 * 18.03.93: Component "spec" added in USRBLK
 * 05.03.90: Creation of body
 *****************************************************************************/

#ifndef __GLOBAL__
#define __GLOBAL__

/****** DEFINES **************************************************************/

#define MAX_FUNC      10                  /* Anzahl Funktionstasten */

#define NO_HANDLE    (-1)                 /* Wert fÅr ungÅltiges Handle */

#define DESK           0                  /* Window-Handle/Klasse des Desktop als Objekt */
#define DESKWINDOW     1                  /* Klasse des Desktops im einem Fenster */
#define MIN_WDESK    640                  /* Minimale Breite des Desktop */

#define VA_START  0x4711                  /* Start einer 2. Instanz verhindern (öbergabe des Dateinamens) */

#define SCREEN         1                  /* GEM-GerÑte */
#define PLOTTER       11
#define PRINTER       21
#define METAFILE      31
#define CAMERA        41
#define TABLET        51
#define MEMORY_SYS    61
#define FAX_SYS       81
#define IMG_SYS       91

#define NDC            0                  /* Normalisierte Koordinaten */
#define RC             2                  /* Raster Koordinaten */

#define FONT_SYSTEM    1                  /* GEM System Font */
#define FONT_SWISS     2                  /* Swiss Font */
#define FONT_DUTCH    14                  /* Dutch Font */
#define FONT_CHICAGO 250                  /* Chicago Font */

#define GDOS_SWISS                 3      /* SpeedoGDOS Fonts */
#define GDOS_SWISS_ITALIC          4
#define GDOS_SWISS_BOLD            5
#define GDOS_SWISS_BOLD_ITALIC     6
#define GDOS_DUTCH_ROMAN          11
#define GDOS_DUTCH_ITALIC         12
#define GDOS_DUTCH_BOLD           13
#define GDOS_DUTCH_BOLD_ITALIC    14
#define GDOS_PARK_AVENUE         362
#define GDOS_BITSTREAM_COOPER    630
#define GDOS_VGA_ROUNDED         756
#define GDOS_MONOSPACE           956
#define GDOS_WINGBATS           3219
#define GDOS_SYMBOL_MONOSPACED  9831

#define GDOS_BITMAPFONT            0      /* Bitmap Font */
#define GDOS_VECTORFONT            1      /* Vektor Font z. B. Speedo */
#define GDOS_TRUETYPEFONT          2      /* True Type Font */

#define MAX_FONTNAME              32      /* Maximale Fontname-LÑnge */

#define COLOR_HIGHLIGHT            0      /* Farbe fÅr selektierten Hintergrund */
#define COLOR_HIGHLIGHTTEXT        1      /* Farbe fÅr selektierten Text */
#define COLOR_DISABLED             2      /* Farbe eines disabled button */
#define COLOR_BTNFACE              3      /* Farbe der OberflÑche der SchaltflÑche */
#define COLOR_BTNHIGHLIGHT         4      /* Farbe des oberen und linken Randes */
#define COLOR_BTNSHADOW            5      /* Farbe des unteren und rechten Randes */
#define COLOR_BTNTEXT              6      /* Farbe des Textes */
#define COLOR_SCROLLBAR            7      /* Farbe des Scrollbar-Hintergrundes */
#define COLOR_DIALOG               8      /* Farbe des Hintergrundes einer Dialogbox */
#define MAX_SYSCOLORS              9      /* Anzahl Systemfarben */

#define STRSIZE      82                   /* Stringgrîûe */
#define STRLEN       80                   /* StringlÑnge */
#define LONGSTRSIZE 256                   /* Lange Stringgrîûe */
#define LONGSTRLEN  255                   /* Lange StringlÑnge */

#define SETSIZE     32                    /* Grîûe eines Sets in Longs */
#define SETMAX      (SETSIZE * 32 - 1)    /* Maximale Elemente eines Sets */

#define CF_CSV      0                     /* Clipboard Formate */
#define CF_TXT      1
#define CF_GEM      2
#define CF_IMG      3
#define CF_DCA      4
#define CF_USR      5
#define CF_FORMATS  6

#define CM_RAM      0x0001                /* Clipboard modes */
#define CM_DISK     0x0002

#define SYSTEM_INF  "C:\\GEMSYS\\SYSTEM\\SYSTEM.INF"
#define SYSTEM_DIR  "C:\\GEMSYS\\SYSTEM\\"

#if GEMDOS | MSDOS | FLEXOS
#define PROGSEP     '/'                   /* Programm-Trennzeichen */
#define SCRAPDIR    "C:\\CLIPBRD\\"       /* Standard Clipboard-Pfad */
#endif

#if UNIX
#define PROGSEP     ';'                   /* Programm-Trennzeichen */
#define SCRAPDIR    "/tmp/"               /* Standard Clipboard-Pfad */
#endif

#define HORIZONTAL  0x01                  /* Horizontales Scrolling */
#define VERTICAL    0x02                  /* Vertikales Scrolling */

#define THEBAR      1                     /* Objekt-Nummer der MenÅzeile */
#define THEACTIVE   2                     /* Objekt-Nummer der aktiven MenÅs */
#define THEFIRST    3                     /* Objekt-Nummer des ersten MenÅs */

#define NUL         0x00                  /* ASCII Codes */
#define SOH         0x01
#define STX         0x02
#define ETX         0x03
#define EOT         0x04
#define ENQ         0x05
#define ACK         0x06
#define BEL         0x07
#define BS          0x08
#define HT          0x09
#define LF          0x0A
#define VT          0x0B
#define FF          0x0C
#define CR          0x0D
#define SO          0x0E
#define SI          0x0F
#define DLE         0x10
#define DC1         0x11
#define DC2         0x12
#define DC3         0x13
#define DC4         0x14
#define NAK         0x15
#define SYN         0x16
#define ETB         0x17
#define CAN         0x18
#define EM          0x19
#define SUB         0x1A
#define ESC         0x1B
#define FS          0x1C
#define GS          0x1D
#define RS          0x1E
#define US          0x1F
#define SP          0x20
#define DEL         0x7F

#define ESCAPE      0x01                  /* Scan Codes spezieller Tasten */
#define BACKSPACE   0x0E
#define TAB         0x0F
#define RETURN      0x1C
#define CLR_HOME    0x47
#define POS1        0x47
#define UP          0x48
#define PGUP        0x49
#define LEFT        0x4B
#define RIGHT       0x4D
#define ENDKEY      0x4F
#define DOWN        0x50
#define PGDOWN      0x51
#define INSERT      0x52
#define DELETE      0x53
#define UNDO        0x61
#define HELP        0x62
#define ENTER       0x72
#define CNTRL_LEFT  0x73
#define CNTRL_RIGHT 0x74
#define CNTRL_CLR   0x77
#define ALT_1       0x78
#define ALT_2       0x79
#define ALT_3       0x7A
#define ALT_4       0x7B
#define ALT_5       0x7C
#define ALT_6       0x7D
#define ALT_7       0x7E
#define ALT_8       0x7F
#define ALT_9       0x80
#define ALT_0       0x81

#define F1          0x3B                  /* Scan-Codes der Funktionstasten */
#define F2          0x3C
#define F3          0x3D
#define F4          0x3E
#define F5          0x3F
#define F6          0x40
#define F7          0x41
#define F8          0x42
#define F9          0x43
#define F10         0x44
#define F11         0x54
#define F12         0x55
#define F13         0x56
#define F14         0x57
#define F15         0x58
#define F16         0x59
#define F17         0x5A
#define F18         0x5B
#define F19         0x5C
#define F20         0x5D

#define CEDIT_FLAG  0x1000                /* Combo-Box-Edit-Flag im Text-Objekt */
#define UNDO_FLAG   0x2000                /* Undo-Flag im Button-Objekt */
#define HELP_FLAG   0x4000                /* Help-Flag im Button-Objekt */
#define NOECHO_FLAG 0x8000                /* Nicht-Echo-Flag im Text-Objekt */

/****** TYPES ****************************************************************/

typedef BYTE STRING [STRSIZE];            /* Zeichenkette */
typedef BYTE LONGSTR [LONGSTRSIZE];       /* Lange Zeichenkette */
typedef ULONG SET [SETSIZE];              /* Menge */

typedef BYTE HUGE *HPTR;                  /* Huge Pointer */
typedef BYTE FAR  *FPTR;                  /* Far Pointer */

typedef struct
{
  WORD x;                                 /* X-Koordinate */
  WORD y;                                 /* Y-Koordinate */
  WORD w;                                 /* Breite */
  WORD h;                                 /* Hîhe */
} RECT;

typedef struct
{
  LONG x;                                 /* X-Koordinate */
  LONG y;                                 /* Y-Koordinate */
  LONG w;                                 /* Breite */
  LONG h;                                 /* Hîhe */
} LRECT;

typedef struct
{
  WORD    mox;                            /* Maus-X-Position */
  WORD    moy;                            /* Maus-Y-Position */
  WORD    momask;                         /* Mausmaske */
  WORD    mobutton;                       /* Mausknopf oben/unten */
  WORD    kstate;                         /* Shift-Tastatur-Status */
  UWORD   kreturn;                        /* Keycode von Event-Keyboard */
  WORD    breturn;                        /* Anzahl der Klicks */
  WORD    ascii_code;                     /* ASCII-Code der Taste */
  WORD    scan_code;                      /* Scan-Code der Taste */
  BOOLEAN shift;                          /* Shift-Taste betÑtigt ? */
  BOOLEAN ctrl;                           /* Control-Taste betÑtigt ? */
  BOOLEAN alt;                            /* Alternate-Taste betÑtigt ? */
} MKINFO;                                 /* Mouse-Key-Info */

typedef struct
{
  LONG dev_w;                             /* Breite des AusgabegrÑtes in Pixel */
  LONG dev_h;                             /* Hîhe des AusgabegerÑtes in Pixel */
  WORD pix_w;                             /* Breite eines Pixel in 1/1000 mm */
  WORD pix_h;                             /* Hîhe eines Pixel in 1/1000 mm */
  LONG lPixelsPerMeter;                   /* pixels per meter on device */
  LONG lPhysPageWidth;                    /* physical page width in 1/1000 mm */
  LONG lPhysPageHeight;                   /* physical page height in 1/1000 mm */
  LONG lRealPageWidth;                    /* printable page width in 1/1000 mm */
  LONG lRealPageHeight;                   /* printable page height in 1/1000 mm */
  LONG lXOffset;                          /* x offset of printable margin */
  LONG lYOffset;                          /* y offset of printable margin */
} DEVINFO;

typedef struct
{
  USERBLK userblk;                        /* Original userblk Struktur */
  UWORD   ob_type;                        /* Original ob_type */
  VOID    *spec;                          /* FÅr speziellen Gebrauch */
} USRBLK;

typedef struct
{
  WORD version;                           /* Versionsnummer */
  WORD headlen;                           /* LÑnge des Kopfes in 16-Bit-Worten */
  WORD planes;                            /* Anzahl der planes */
  WORD pat_run;                           /* Anzahl Bytes fÅr einen pattern run */
  WORD pix_width;                         /* Pixelbreite des QuellgerÑts in 1/1000 mm */
  WORD pix_height;                        /* Pixelhîhe des QuellgerÑts in 1/1000 mm */
  WORD sl_width;                          /* Breite einer Scan-Zeile in Pixel */
  WORD sl_height;                         /* Hîhe einer Scan-Zeile in Pixel */
} IMG_HEADER;

typedef struct
{
  WORD version;                           /* Versionsnummer */
  WORD headlen;                           /* LÑnge des Kopfes in 16-Bit-Worten */
  WORD planes;                            /* Anzahl der planes */
  WORD pat_run;                           /* Anzahl Bytes fÅr einen pattern run */
  WORD pix_width;                         /* Pixelbreite des QuellgerÑts in 1/1000 mm */
  WORD pix_height;                        /* Pixelhîhe des QuellgerÑts in 1/1000 mm */
  WORD sl_width;                          /* Breite einer Scan-Zeile in Pixel */
  WORD sl_height;                         /* Hîhe einer Scan-Zeile in Pixel */
  BYTE x_id [4];                          /* "XIMG" */
  WORD color_model;                       /* color mode: 0 = RGB, 1 = CMY, 2 = Pantone */
  WORD color_table [2];                   /* color table (2 ^ planes) */
} XIMG_HEADER;

typedef struct
{
  WORD  width;				  /* Breite */
  WORD  height;				  /* Hîhe */
  WORD  planes;				  /* Anzahl Planes */
  UBYTE *mask;				  /* Maskenpuffer */
  UBYTE *data;				  /* Datenpuffer */
} ICON;

typedef BYTE FONTNAME [MAX_FONTNAME + 1]; /* Fontname */

typedef struct
{
  WORD  font;				/* Fontnummer */
  WORD  point;				/* Punktgrîûe */
  UWORD effects;			/* Effekte */
  WORD  color;				/* Farbe */
} FONTDESC;

typedef struct
{
  WORD     font;			/* Fontnummer */
  FONTNAME fontname;			/* Fontname */
  WORD     type;			/* Font-Typ (GDOS_...) */
  BOOLEAN  mono;			/* Nicht-Proportionalschrift */
} FONTINFO;

/****** VARIABLES ************************************************************/

#if DR_C | LASER_C | MW_C
EXTERN WORD    gl_apid;                   /* Identifikation fÅr Applikation */
#else
GLOBAL WORD    gl_apid;                   /* Identifikation fÅr Applikation */
#endif

#if GEM & (GEM1 | GEM2 | GEM3)
GLOBAL WORD    contrl [12];               /* GEM Arrays fÅr Parameter... */
GLOBAL WORD    intin [256];               /* ...von VDI Aufrufen */
GLOBAL WORD    ptsin [256];
GLOBAL WORD    intout [256];
GLOBAL WORD    ptsout [256];
#endif

GLOBAL WORD    gl_wchar;                  /* Breite eines Zeichens */
GLOBAL WORD    gl_hchar;                  /* Hîhe eines Zeichens */
GLOBAL WORD    gl_wbox;                   /* Breite einer Zeichenbox */
GLOBAL WORD    gl_hbox;                   /* Hîhe einer Zeichenbox */
GLOBAL WORD    gl_wattr;                  /* Breite eines Fensterattributes */
GLOBAL WORD    gl_hattr;                  /* Hîhe eines Fensterattributes */
GLOBAL WORD    gl_point;                  /* Punktgrîûe des Systemzeichensatzes */
GLOBAL WORD    colors;                    /* Anzahl der Farben */
GLOBAL WORD    planes;                    /* Anzahl der planes */
GLOBAL DEVINFO screen_info;               /* Info fÅr Bildschirm */

GLOBAL WORD    dlg_colors;                /* Anzahl der Farben fÅr 3D Effekte in Dialogboxen */
GLOBAL WORD    sys_colors [MAX_SYSCOLORS];/* Systemfarben */
GLOBAL WORD    font_btntext;              /* Font des Textes */
GLOBAL WORD    point_btntext;             /* Punktgrîûe des Textes */
GLOBAL WORD    effects_btntext;           /* Effekte des Textes */
GLOBAL BOOLEAN use_3d;                    /* Benutze 3d look */
GLOBAL BOOLEAN dlg_round_borders;         /* Benutze runde Bildrahmen bei Dialogboxen */
GLOBAL BOOLEAN use_std_fs;                /* Benutzer Standard-Dateiauswahl */
GLOBAL WORD    dlg_checkbox;              /* Checkbox Typ */
GLOBAL WORD    dlg_radiobutton;           /* Radiobutton Typ */
GLOBAL WORD    dlg_arrow;                 /* Pfeil Typ */
GLOBAL BOOLEAN btn_round_borders;         /* Abgerundete Ecken bei SchaltflÑchen */
GLOBAL WORD    btn_shadow_width;          /* Breite des Schattens bei SchaltflÑchen */
GLOBAL WORD    color_desktop;             /* Farbe des Desktop Hintergrundes */
GLOBAL WORD    pattern_desktop;           /* Muster des Desktop Hintergrundes */
GLOBAL BOOLEAN use_lfn;                   /* Benutze lange Dateinamen */
GLOBAL BOOLEAN bUseDesktopWindow;         /* desktop is in a window */
GLOBAL BOOLEAN bTopDesktopWindow;         /* desktop will be topped on click */
GLOBAL BOOLEAN bUseDesktopWindowSliders;  /* use sliders in desktop window */

GLOBAL WORD    phys_handle;               /* Physikalisches Workstation Handle */
GLOBAL WORD    vdi_handle;                /* Virtuelles Workstation Handle */
GLOBAL BOOLEAN deskacc;                   /* Als Accessory gestartet ? */
GLOBAL BOOLEAN acc_close;                 /* Letze Meldung war AC_CLOSE ? */
GLOBAL WORD    menu_id;                   /* Identifikation fÅr MenÅ als Accessory */
GLOBAL WORD    class_desk;                /* Desktop-Klasse (0 oder 1) */

GLOBAL RECT    desk;                      /* Desktop Grîûe */
GLOBAL RECT    clip;                      /* Letztes Clipping Rechteck */

GLOBAL WORD    hidden;                    /* Sichtbar-Status der Maus */
GLOBAL WORD    busy;                      /* Arbeits-Status der Maus */
GLOBAL WORD    mousenumber;               /* Aktuelle Mausform-Nummer */
GLOBAL MFORM   *mouseform;                /* Aktuelle Mausform */
GLOBAL BOOLEAN done;                      /* Ende gewÑhlt ? */
GLOBAL BOOLEAN ring_bell;                 /* Glocke eingeschaltet ? */
GLOBAL BOOLEAN grow_shrink;               /* Grow/Shrink eingeschaltet ? */
GLOBAL WORD    blinkrate;                 /* Blinkrate */
GLOBAL BOOLEAN updtmenu;                  /* MenÅ auf neuesten Stand bringen ? */
GLOBAL LONGSTR cmd;                       /* Programmname */
GLOBAL LONGSTR tail;                      /* Kommandozeile */
GLOBAL LONGSTR called_by;                 /* Name des aufrufenden Programms */
GLOBAL LONGSTR app_name;                  /* Name der Applikation */
GLOBAL LONGSTR app_path;                  /* Pfad der Applikation */
GLOBAL WORD    act_drv;                   /* Aktuelles Laufwerk beim Start */
GLOBAL LONGSTR act_path;                  /* Aktueller Pfad beim Start */
GLOBAL LONGSTR scrapdir;                  /* Clipboard-Pfad */

GLOBAL LONGSTR fs_path;                   /* Pfad der Dateiauswahl-Box */
GLOBAL LONGSTR fs_sel;                    /* Dateiname der Dateiauswahl-Box */
GLOBAL WORD    fs_button;                 /* Knopf der Dateiauswahl-Box */

GLOBAL OBJECT  *menu;                     /* MenÅ-Objekt-Baum */
GLOBAL OBJECT  *about;                    /* About-Objekt-Baum */
GLOBAL OBJECT  *desktop;                  /* Eigener Desktop */
GLOBAL OBJECT  *freetext;                 /* Freie Texte */

GLOBAL BYTE    **alertmsg;                /* Resource-Fehlermeldungen */
GLOBAL BYTE    **alerts;                  /* Zeiger auf Fehlermeldungen */

GLOBAL BOOLEAN use_adapt;                 /* use adaption routines */
GLOBAL BOOLEAN bShowDebugInfo;            /* debugmodus */
GLOBAL BYTE    *system_inf;               /* system info */

GLOBAL WORD    olga_apid;                 /* Identifikation fÅr OLGA */
GLOBAL WORD    st_guide_apid;             /* Identifikation fÅr ST-GUIDE */

GLOBAL BYTE    *global_mem1;							/* Globaler Speicherbreich */
GLOBAL BYTE    *global_mem2;							/* Globaler Speicherbreich */

/* [GS] 5.1f Start: */
GLOBAL WORD		 nvdi_version;							/* EnthÑlt NVDI Versionsnummer	*/
/* Ende */

/****** FUNCTIONS ************************************************************/

GLOBAL VOID    open_vwork        _((VOID));
GLOBAL VOID    close_vwork       _((VOID));
GLOBAL WORD    open_work         _((WORD device, DEVINFO *dev_info));
GLOBAL WORD    open_work_ex      _((WORD device, DEVINFO *dev_info, WORD pageformat, WORD orientation, BYTE *filename));
GLOBAL VOID    close_work        _((WORD device, WORD out_handle));
GLOBAL BOOLEAN gdos_ok           _((VOID));
GLOBAL UWORD   scan_to_ascii     _((UWORD scan));

GLOBAL VOID    set_mouse         _((WORD number, MFORM *addr));
GLOBAL VOID    last_mouse        _((VOID));
GLOBAL VOID    hide_mouse        _((VOID));
GLOBAL VOID    show_mouse        _((VOID));
GLOBAL VOID    busy_mouse        _((VOID));
GLOBAL VOID    arrow_mouse       _((VOID));

GLOBAL VOID    do_state          _((OBJECT *tree, WORD obj, UWORD state));
GLOBAL VOID    undo_state        _((OBJECT *tree, WORD obj, UWORD state));
GLOBAL VOID    flip_state        _((OBJECT *tree, WORD obj, UWORD state));
GLOBAL WORD    find_state        _((OBJECT *tree, WORD obj, UWORD state));
GLOBAL BOOLEAN is_state          _((OBJECT *tree, WORD obj, UWORD state));

GLOBAL VOID    do_flags          _((OBJECT *tree, WORD obj, UWORD flags));
GLOBAL VOID    undo_flags        _((OBJECT *tree, WORD obj, UWORD flags));
GLOBAL VOID    flip_flags        _((OBJECT *tree, WORD obj, UWORD flags));
GLOBAL WORD    find_flags        _((OBJECT *tree, WORD obj, UWORD flags));
GLOBAL BOOLEAN is_flags          _((OBJECT *tree, WORD obj, UWORD flags));

GLOBAL WORD    find_type         _((OBJECT *tree, WORD obj, UWORD type));
GLOBAL BOOLEAN is_type           _((OBJECT *tree, WORD obj, UWORD type));

GLOBAL VOID    set_checkbox      _((OBJECT *tree, WORD obj, BOOLEAN selected));
GLOBAL BOOLEAN get_checkbox      _((OBJECT *tree, WORD obj));
GLOBAL VOID    set_rbutton       _((OBJECT *tree, WORD obj, WORD lower, WORD upper));
GLOBAL WORD    get_rbutton       _((OBJECT *tree, WORD obj));
GLOBAL VOID    set_ptext         _((OBJECT *tree, WORD obj, BYTE *s));
GLOBAL VOID    get_ptext         _((OBJECT *tree, WORD obj, BYTE *s));
GLOBAL VOID    set_str           _((OBJECT *tree, WORD obj, BYTE *s));
GLOBAL BYTE    *get_str          _((OBJECT *tree, WORD obj));
GLOBAL VOID    set_ob_spec       _((OBJECT *tree, WORD obj, LONG ob_spec));
GLOBAL LONG    get_ob_spec       _((OBJECT *tree, WORD obj));
GLOBAL UWORD   get_ob_type       _((OBJECT *tree, WORD obj));
GLOBAL WORD    get_parent        _((OBJECT *tree, WORD obj));
GLOBAL VOID    menu_check        _((OBJECT *tree, WORD obj, BOOLEAN checkit));
GLOBAL VOID    menu_enable       _((OBJECT *tree, WORD obj, BOOLEAN enableit));

GLOBAL VOID    objc_rect         _((OBJECT *tree, WORD obj, RECT *rect, BOOLEAN calc_border));
GLOBAL VOID    trans_gimage      _((OBJECT *tree, WORD obj));

GLOBAL VOID    line_default      _((WORD vdi_handle));
GLOBAL VOID    text_default      _((WORD vdi_handle));
GLOBAL VOID    v_text            _((WORD vdi_handle, WORD x, WORD y, BYTE *string));
GLOBAL WORD    vst_arbpoint      _((WORD vdi_handle, WORD point, WORD *char_width, WORD *char_height, WORD *cell_width, WORD *cell_height));
GLOBAL VOID    text_extent       _((WORD vdi_handle, BYTE *text, BOOLEAN incl_effects, WORD *width, WORD *height));
GLOBAL VOID    draw_3d           _((WORD vdi_handle, WORD x_offset, WORD y_offset, WORD border_width, WORD width, WORD height, WORD upper_left, WORD lower_right, WORD corners, BOOLEAN draw_borderline));

GLOBAL BOOLEAN background        _((OBJECT *tree, WORD obj, BOOLEAN get, MFDB *screen, MFDB *buffer));
GLOBAL BOOLEAN opendial          _((OBJECT *tree, BOOLEAN grow, RECT *size, MFDB *screen, MFDB *buffer));
GLOBAL BOOLEAN closedial         _((OBJECT *tree, BOOLEAN shrink, RECT *size, MFDB *screen, MFDB *buffer));
GLOBAL WORD    hndl_dial         _((OBJECT *tree, WORD def, BOOLEAN grow_shrink, BOOLEAN save_back, RECT *size, BOOLEAN *ok));
GLOBAL WORD    formdo            _((OBJECT *tree, WORD start));
GLOBAL VOID    blink             _((OBJECT *tree, WORD obj, WORD blinkrate));
GLOBAL WORD    popup_menu        _((OBJECT *tree, WORD obj, WORD x, WORD y, WORD center_obj, BOOLEAN relative, WORD bmsk));
GLOBAL BOOLEAN is_menu_key       _((OBJECT *menu, MKINFO *mk, WORD *title, WORD *item));
GLOBAL WORD    check_alt         _((OBJECT *tree, MKINFO *mk));
GLOBAL VOID    draw_3d_dlg       _((OBJECT *tree));

GLOBAL VOID    scroll_area       _((CONST RECT *area, WORD dir, WORD delta));
GLOBAL BOOLEAN rc_equal          _((CONST RECT *p1, CONST RECT *p2));
GLOBAL VOID    rc_copy           _((CONST RECT *ps, RECT *pd));
GLOBAL VOID    rc_union          _((CONST RECT *p1, RECT *p2));
GLOBAL BOOLEAN rc_intersect      _((CONST RECT *p1, RECT *p2));
GLOBAL VOID    rc_inflate        _((RECT *rect, WORD x, WORD y));
GLOBAL BOOLEAN inside            _((WORD x, WORD y, CONST RECT *r));
GLOBAL VOID    rect2array        _((CONST RECT *rect, WORD *array));
GLOBAL VOID    array2rect        _((CONST WORD *array, RECT *rect));
GLOBAL VOID    xywh2array        _((WORD x, WORD y, WORD w, WORD h, WORD *array));
GLOBAL VOID    array2xywh        _((CONST WORD *array, WORD *x, WORD *y, WORD *w, WORD *h));
GLOBAL VOID    xywh2rect         _((WORD x, WORD y, WORD w, WORD h, RECT *rect));
GLOBAL VOID    rect2xywh         _((CONST RECT *rect, WORD *x, WORD *y, WORD *w, WORD *h));
GLOBAL VOID    set_clip          _((BOOLEAN flag, CONST RECT *size));
GLOBAL VOID    growbox           _((CONST RECT *st, CONST RECT *fin));
GLOBAL VOID    shrinkbox         _((CONST RECT *fin, CONST RECT *st));

GLOBAL VOID    beep              _((VOID));
GLOBAL WORD    note              _((WORD button, WORD index, WORD helpinx, OBJECT *helptree));
GLOBAL WORD    error             _((WORD button, WORD index, WORD helpinx, OBJECT *helptree));

GLOBAL VOID    setcpy            _((SET set1, SET set2));
GLOBAL VOID    setall            _((SET set));
GLOBAL VOID    setclr            _((SET set));
GLOBAL VOID    setnot            _((SET set));
GLOBAL VOID    setand            _((SET set1, SET set2));
GLOBAL VOID    setor             _((SET set1, SET set2));
GLOBAL VOID    setxor            _((SET set1, SET set2));
GLOBAL VOID    setincl           _((SET set, WORD elt));
GLOBAL VOID    setexcl           _((SET set, WORD elt));
GLOBAL BOOLEAN setin             _((SET set, WORD elt));
GLOBAL BOOLEAN setcmp            _((SET set1, SET set2));
GLOBAL WORD    setcard           _((SET set));

GLOBAL BOOLEAN select_file       _((BYTE *name, BYTE *path, BYTE *suffix, BYTE *label, BYTE *filename));

GLOBAL BYTE    *ReadInfFile      _((BYTE *pFileName));
GLOBAL BYTE    *FindSection      _((BYTE *pszInf, BYTE *pszSection));
GLOBAL BYTE    *GetKeyVal        _((BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, BYTE *pszKeyVal, INT iKeySize));
GLOBAL BYTE    *GetNextLine      _((BYTE *pszInf, BYTE *pszLine, INT iLineSize));
GLOBAL BYTE    *FindKey          _((BYTE *pszInf, BYTE *pszSection, BYTE *pszKey));
GLOBAL BYTE    *CopyKeyVal       _((BYTE *pszKey, BYTE *pszKeyVal, INT iKeySize));
GLOBAL BYTE    *GetString        _((BYTE *psz, BYTE *pszString));
GLOBAL BYTE    *GetText          _((BYTE *psz, BYTE *pszText));

GLOBAL BOOLEAN GetProfileBool    _((BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, BOOLEAN bDefault));
GLOBAL WORD    GetProfileWord    _((BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, WORD wDefault));
GLOBAL LONG    GetProfileLong    _((BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, LONG lDefault));
GLOBAL BYTE    *GetProfileString _((BYTE *pszInf, BYTE *pszSection, BYTE *pszKey, BYTE *pszDefault, BYTE *pszBuffer));

GLOBAL VOID    RemLeadSP         _((BYTE *pString));
GLOBAL VOID    RemTrailSP        _((BYTE *pString));

GLOBAL WORD    ClipboardGetMode  _((VOID));
GLOBAL WORD    ClipboardSetMode  _((WORD wMode));
GLOBAL VOID    ClipboardGetName  _((BYTE *pszFileName));
GLOBAL VOID    ClipboardSetName  _((BYTE *pszFileName));
GLOBAL LONG    ClipboardGetSize  _((WORD wFormat));
GLOBAL VOID    ClipboardSetSize  _((WORD wFormat, LONG lSize));
GLOBAL VOID    *ClipboardGetData _((WORD wFormat));
GLOBAL VOID    ClipboardSetData  _((WORD wFormat, VOID *pData));
GLOBAL VOID    ClipboardEmpty    _((VOID));

GLOBAL VOID    OlgaLink          _((BYTE *pszFileName, WORD wLink));
GLOBAL VOID    OlgaUnlink        _((BYTE *pszFileName, WORD wLink));
GLOBAL VOID    OlgaLinkRenamed   _((BYTE *pszOldName, BYTE *pszNewName, WORD wLink));
GLOBAL VOID    OlgaStartExt      _((BYTE *pszExtension, BYTE *pszFileName));

GLOBAL BYTE    *NameFromDevice   _((BYTE *pszDeviceName, WORD wDevice));
GLOBAL WORD    DeviceFromName    _((BYTE *pszDeviceName));

/* [GS] 5.1f Start */
GLOBAL WORD vqt_ext_name( WORD vdi_handle, WORD index, BYTE *name, WORD *font_format, WORD *flags );
/* Ende */

GLOBAL BOOLEAN init_global       _((INT argc, BYTE *argv [], BYTE *acc_menu, WORD class));
GLOBAL BOOLEAN term_global       _((VOID));

#endif /* __GLOBAL__ */

