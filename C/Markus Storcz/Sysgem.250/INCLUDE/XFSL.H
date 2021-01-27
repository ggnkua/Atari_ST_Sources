/*  @(#)xfsl.h, Dirk Haun/Stefan Rogel/Christoph Zwerschke, 21.07.1995
 *  @(#)Aufruf eines systemweiten Fontselektors Åber den Cookie 'xFSL'
 *
 *  Revision 4 vom 21.07.1995
 *
 */

#if !defined(__xFSL__)
#define __xFSL__

#if !defined(__AES__)
# include <aes.h>
#endif

#if !defined(__VDI__)
# include <vdi.h>
#endif

#define xFSL_REVISION  4


/******** verwendete Strukturen ******************************************/

/*  Neuer Typ fÅr Fontgrîûe in 1/65536 Punkt, gÅltig ab Speedo 4.0
 *
 *  typedef long  fix31;
 */

/*  Angabe der Fontgrîûe,
 *  wird Åber ein Kontrollflag (s.u.) unterschieden
 */

union fsize
{
 int           size;         /* Fontgrîûe in Punkt */
 fix31         size31;       /* Fontgrîûe in 1/65536 Punkt */
};


/*  allgemeine Fontinfo-Struktur
 */

typedef struct
{
 int           fontid;       /* ID des Fonts                             */
 int           fonttype;     /* Typ des Fonts, siehe vqt_info()          */
 char         *fontname;     /* Name des Fonts, siehe vqt_name()         */
 union fsize   fontsize;     /* Fontgrîûe in pt oder fix31               */
 union fsize   fontwidth;    /* Breite in pt oder fix31                  */
 char          trackkern;    /* Track-Kerning, siehe vst_kern()          */
 char          pairkern;     /* Paar-Kerning, siehe vst_kern()           */
 int           fontattr;     /* Attribute, siehe vst_attributes()        */
 int           fontskew;     /* Neigung, siehe vst_skew()                */
 int           fontcol;      /* Farbe, siehe vst_color()                 */
 int           backcol;      /* Text-Hintergrundfarbe                    */
 int           halign;       /* horizontale Textausrichtung              */
 int           valign;       /* vertikale Textausrichtung                */
 int           rotation;     /* Textrotation in 1/10 Grad                */
 int           validtype;    /* Typ (V_CHAR_...) oder Mapping (MAP_...)  */
 int          *validchars;   /* benîtigte Zeichen oder 0L                */
} PFONTINFO;


/*  ein Eintrag im Popup
 */

typedef struct
{
 char         *entry;        /* Text des Popup-Eintrags                  */
 PFONTINFO    *fontinfo;     /* Zeiger auf Fontinfo-Struktur             */
 unsigned int  fontflags;    /* erlaubte Fontarten                       */
 long          funcflags;    /* Funktionsflags, nur fÅr HuGo!            */
} xFSL_PENTRY;


/*  xFSL-Parameter
 */

typedef struct
{
 int           par_size;     /* Grîûe der xFSL_PAR-Struktur selbst       */
 int           pfi_size;     /* Grîûe der PFONTINFO-Struktur             */
 unsigned long control;      /* Kontroll-Flags, s.u.                     */
 const char   *headline;     /* öberschrift oder 0L                      */
 const char   *example;      /* Beispieltext oder 0L                     */
 const char   *helptext;     /* Text fÅr den Hilfe-Button oder 0L        */
 PFONTINFO    *font;         /* Zeiger auf Fontinfo, s.o.                */
 unsigned int  fontflags;    /* erlaubte Fontarten                       */
 const char   *poptext;      /* Text vor dem Popup (nur Calvino) oder 0L */
 int           num_entries;  /* Anzahl der EintrÑge (0..n)               */
 int           sel_entry;    /* Selektierter Eintrag (0..n-1)            */
 xFSL_PENTRY  *popup;        /* Zeiger auf ein Popup oder 0L             */
 char         *helpinfo;     /* RÅckgabe: Zeiger auf Hilfedatei & -seite */
} xFSL_PAR;



/******** Definition der Schnittstellen-Funktionen ***********************/
/*
 *  xFSL_INPUT xfsl_input    - vereinfachter Aufruf
 *  xFSL_INIT xfsl_init      - Init-Aufruf : Dialog darstellen
 *  xFSL_EVENT xfsl_event    - Event-Aufruf: Hauptschleife
 *  xFSL_EXIT xfsl_exit      - Exit-Aufruf : Dialog abmelden
 *
 */

typedef int cdecl (*xFSL_INPUT)
(
 int           vdihandle,    /* Handle einer geîffneten VDI-Workstation  */
 unsigned int  fontflags,    /* Flags, welche Fonts angeboten werden     */
 const char   *headline,     /* öberschrift oder 0L (Default-Text)       */
 int          *id,           /* RÅckgabe: ID des gewÑhlten Fonts         */
 int          *size          /* RÅckgabe: Grîûe des gewÑhlten Fonts      */
);

typedef int cdecl (*xFSL_INIT)
(
 int           vdihandle,    /* Handle einer geîffneten VDI-Workstation  */
 xFSL_PAR     *xpar          /* Struktur mit weiteren Eingabeparametern  */
);

typedef int cdecl (*xFSL_EVENT)
(
 int           xfsl_handle,  /* Handle von xfsl_init()                   */
 EVENT        *event         /* Pure-C-Event-Struktur                    */
);

typedef void cdecl (*xFSL_EXIT)
(
 int           xfsl_handle   /* Handle von xfsl_init()                   */
);

typedef long cdecl (*xFSL_INFO)
(
 void                        /* keine Parameter                          */
);


/******** xFSL-Struktur **************************************************/

/*  Der Cookie 'xFSL' zeigt auf die folgende Struktur
 */

typedef struct
{
 unsigned long xfsl;         /* Magic 'xFSL'                             */
 unsigned int  revision;     /* Revisionsnummer der Schnittstelle        */
 unsigned long product;      /* Kennung des Fontselektors, z.B. 'CLVN'   */
 unsigned int  version;      /* Version des Fontselektors als BCD        */
 xFSL_INPUT    xfsl_input;   /* einfacher Aufruf                         */
 xFSL_INIT     xfsl_init;    /* Init-Aufruf                              */
 xFSL_EVENT    xfsl_event;   /* Event-Aufruf                             */
 xFSL_EXIT     xfsl_exit;    /* Exit-Aufruf                              */
 xFSL_INFO     xfsl_info;    /* Info-Aufruf (Features abfragen)          */
} xFSL;


/******** Flags **********************************************************/

/*  Fontflags
 */

#define FF_SYSTEM       0x0001 /* Systemfont (zusÑtzlich) anzeigen       */
#define FF_MONOSPACED   0x0002 /* monospaced Fonts anzeigen              */
#define FF_PROPORTIONAL 0x0004 /* prop. Fonts anzeigen                   */
#define FF_BITMAP       0x0008 /* alle Bitmapfonts anzeigen              */
#define FF_SPD          0x0010 /* Speedofonts                            */
#define FF_TTF          0x0020 /* TrueType-Fonts                         */
#define FF_PFB          0x0040 /* Type-1-Fonts                           */
#define FF_CFN          0x0080 /* Calamus-Fonts (nicht implementiert!)   */
#define FF_VECTOR      (FF_SPD|FF_TTF|FF_PFB|FF_CFN) /* Vektorfonts anz. */
#define FF_ALL         (FF_MONOSPACED|FF_PROPORTIONAL|FF_VECTOR|FF_BITMAP)
#define FF_CHANGED      0x8000 /* énderung erfolgt (im Popup)            */

#define FF_VEKTOR       FF_VECTOR
#define FF_MONO         FF_MONOSPACED
#define FF_PROP         FF_PROPORTIONAL

/* Kontroll-Flags (werden nicht alle von allen Selektoren unterstÅtzt)   */
#define CC_WINDOW     0x0001 /* Fontselektor als Fenster                 */
#define CC_APPMODAL   0x0002 /* Fontselektor ist applikations-modal      */
#define CC_FIX31      0x0004 /* alle Grîûenangaben in 1/65536 Point      */
#define CC_FAKESTYLE  0x0008 /* Schnitte simulieren (nur f. Bitmapfonts) */
#define CC_CLOSER     0x0010 /* Fenster mit Closer, kein OK-Button       */
#define CC_NOSIZE     0x0100 /* Grîûe nicht Ñndern                       */
#define CC_NOCOLOR    0x0200 /* Farbe nicht Ñndern                       */
#define CC_NOATTR     0x0400 /* Attribute nicht Ñndern                   */
#define CC_NOWIDTH    0x0800 /* Breite nicht Ñndern                      */
#define CC_NOKERN     0x1000 /* Kerning nicht Ñndern                     */
#define CC_NOSKEW     0x2000 /* Skewing nicht Ñndern                     */
#define CC_NOALIGN    0x4000 /* Ausrichtung nicht Ñndern                 */
#define CC_NOROTATION 0x8000 /* Textrotation nicht Ñndern                */
#define CC_DFLTSIZE  0x10000 /* Schriftgrîûe "Default"                   */
#define CC_INVSTYLE  0x20000 /* Attribut "Invers"                        */

/* horizontale Textausrichtung (wie bei vst_alignment)                   */
#define THA_LEFT          0  /* linksbÅndig                              */
#define THA_CENTER        1  /* zentriert                                */
#define THA_RIGHT         2  /* rechtsbÅndig                             */

/* vertikale Textausrichtung (_nicht_ wie bei vst_alignment!)            */
#define TVA_BOTTOM        0  /* an der Text-Unterkante                   */
#define TVA_CENTER        1  /* vertikal zentriert                       */
#define TVA_TOP           2  /* an der Text-Oberkante                    */

/* Gruppen von erwÅnschten Zeichen im Font ('validtype' in PFONTINFO)    */
#define V_CHAR_IND       -1  /* "egal"                                   */
#define V_CHAR_ASC       -2  /* alle druckbaren ASCII-Zeichen (32-126)   */
#define V_CHAR_PRT       -3  /* alle druckbaren Zeichen (32-255)         */
#define V_CHAR_ALL       -4  /* wirklich alle Zeichen (0-255)            */

/* Mapping (ebenfalls fÅr 'validtype' in PFONTINFO)                      */
#define MAP_DIRECT        0  /* "direktes" Mapping (alle Zeichen)        */
#define MAP_ASCII         1  /* ASCII-Mapping, Bereich 0..255 (Default)  */

/* Fonttypen (erweitertes vqt_name ab SpeedoGDOS 5.0c/NVDI 3)            */
#define UNKNOWN_FONT 0x0000  /* Fonttyp unbekannt                        */
#define BITMAP_FONT  0x0001  /* Bitmapfont                               */
#define SPEEDO_FONT  0x0002  /* Speedofont                               */
#define TT_FONT      0x0004  /* TrueType-Font                            */
#define PFB_FONT     0x0008  /* Type-1-Font (Postscript)                 */
#define CFN_FONT     0x0010  /* Calamus-Font (nicht implementiert!)      */
#define ANY_FONT     0x00FF  /* als Maske (Hibyte ausmaskieren)          */


/*  Featureflags fÅr xfsl_info
 */
#define XF_SIZE      0x0001  /* GrîûenÑnderung mîglich                   */
#define XF_COLOR     0x0002  /* FarbÑnderung mîglich                     */
#define XF_ATTR      0x0004  /* AttributÑnderung mîglich                 */
#define XF_WIDTH     0x0008  /* BreitenÑnderung mîglich                  */
#define XF_KERN      0x0010  /* KerningÑnderung mîglich                  */
#define XF_SKEW      0x0020  /* NeigungsÑnderung mîglich                 */
#define XF_ALIGN     0x0040  /* énderung der Ausrichtung mîglich         */
#define XF_ROTATION  0x0080  /* Textrotation mîglich                     */
#define XF_FIX31     0x0100  /* fix31-UnterstÅtzung                      */
#define XF_POPUP     0x0200  /* Popup-UnterstÅtzung                      */
#define XF_DRAGDROP  0x0400  /* Drag&Drop-UnterstÅtzung                  */
#define XF_MAPPING   0x0800  /* beherrscht Mapping                       */


/*  Returncodes der xfsl_xxx-Aufrufe
 *  (aufwÑrtskompatibel zu den UFSL-RÅckgabewerten [markiert mit 'U'])
 */

#define xFS_PARERROR     -9  /* Parameterfehler, z.B. Aufruf nach Rev. 3 */
#define xFS_LOADERROR    -8  /* Fehler beim Nachladen des Overlays       */
#define xFS_RES_ERROR    -7  /* Auflîsung kleiner als 640*400 Punkte     */
#define xFS_NO_HANDLE    -6  /* Kein Handle frei                         */
#define xFS_NO_WINDOW    -5  /* Kein Fenster frei                        */
#define xFS_NO_FONTS     -4  /* Keine Fonts geladen                    U */
#define xFS_NO_FONTSIZE  -3  /* Fontgrîûe nicht identifizierbar        U */
#define xFS_ACTIVE       -2  /* Fontselektor ist bereits aktiv         U */
#define xFS_ERROR        -1  /* allgemeiner Fehler (Speichermangel)    U */
#define xFS_STOP          0  /* <Abbruch> gewÑhlt                      U */
#define xFS_OK            1  /* <Ok> gewÑhlt                           U */
#define xFS_HELP          2  /* Hilfe-Button angewÑhlt                   */
#define xFS_EVENT         3  /* AES-Event aufgetreten                    */
#define xFS_POPUP         4  /* das User-Popup wurde angewÑhlt           */


/*  Schriftbreiten-Informationsstruktur,
 *  wird nur fÅr das Font-Protokoll (Nachricht XFONT_CHANGED) benîtigt
 */

typedef struct
{
  unsigned int pair  : 1;    /* Pair-Kerning (0=nein, 1=ja)              */
  unsigned int track : 2;    /* Tr.-K. (0=ohne,1=norm.,2=eng,3=sehr eng) */
  unsigned int width : 13;   /* Schriftbreite in pt (0..8191)            */
} FW_INFO;

#endif
