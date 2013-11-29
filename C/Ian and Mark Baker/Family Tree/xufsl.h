/**************************************************************************/
/* Definitionen fÅr den xUFSL                                             */
/*                                                                        */
/* 10.09.94 Version 1.00                                                  */
/* 14.09.94 Erweitert um Definitionen des UFSL Version 0.91-0.97          */
/*          Event-Funktion aus dem xUFSL-Aufruf entfernt                  */
/*          RÅckgabewerte an UFSL angepaût. Die Wert UFS_NO_FONTS und     */
/*          UFS_NO_FONTSIZE sind nur aus KompatibilitÑtsgrÅnden defi-     */
/*          niert. Solche Fehler werden intern vom xUFSL abfangen (hof-   */
/*          fentlich...).                                                 */
/* 18.09.94 Neue Flags UFS_AUTO_UPDATE und UFS_ERROR_MSG.                 */
/* 28.09.94 Neue Flags UFS_BITMAP_FONTS und UFS_KERNING_INFO.             */
/*          Schriftbreite erweitert: Struktur FW_INFO. In der Struktur    */
/*          wird neben der Zeichenbreite die Weite des Track-Kernings     */
/*          und die Aktivierung des Paar-Kernings zurÅckgegeben.          */
/*          Definition der max. Zeichenbreite MAX_CHAR_WIDTH.             */
/* 01.10.94 UFS_AUTO_UPDATE wieder abgeschafft.                           */
/*          Neues Flag UFS_INDIRECT und Struktur XUFSL_LIST.              */
/*          Wenn UFS_INDIRECT gesetzt ist, wird der Parameter info beim   */
/*          beim xUFSL-Aufruf als Zeiger auf eine XUFSL_LIST interpre-    */
/*          tiert. Die Anzahl der EintrÑge in dieser Liste muû im Parame- */
/*          ter fontid, der erste selektierte Eintrag in fontsize Åberge- */
/*          ben werden. öber ein Popup kînnen dann die in der Liste ange- */
/*          gebenen Sets in EINEM xUFSL-Dialog geÑndert werden! Von den   */
/*          weiteren Parametern werden in diesem Fall nur noch die Dia-   */
/*          logfont-IDs beachtet. Der xUFSL versorgt die EintrÑge in der  */
/*          XUFSL_LIST.                                                   */
/*          Verwendungsbeispiel: Siehe CALLUFSL.C!                        */
/* 02.10.94 Neues Flag UFS_VECTOR_FONTS.                                  */
/**************************************************************************/

#if !defined( __XUFSL__)

#define __XUFSL__

/**************************************************************************/
/* Kennung des xUfsl                                                      */
/**************************************************************************/
#define xUFS_ID           'xUFS'

/**************************************************************************/
/* RÅckgabewerte des xUfsl                                                */
/**************************************************************************/
#define UFS_RES_ERROR    -7       /* Auflîsung kleiner als 640*400 Punkte */
#define UFS_NO_HANDLE    -6       /* Kein Handle frei                     */
#define UFS_NO_WINDOW    -5       /* Kein Fenster frei                    */
#define UFS_NO_FONTS     -4       /* Keine Fonts geladen                  */
#define UFS_NO_FONTSIZE  -3       /* Fontgrîûe nicht identifizierbar      */
#define UFS_ACTIVE       -2       /* Fontselektor ist bereits aktiv       */
#define UFS_ERROR        -1       /* Speichermangel o.Ñ.                  */
#define UFS_STOP          0       /* <Abbruch> gewÑhlt                    */
#define UFS_OK            1       /* <Ok> gewÑhlt                         */

/**************************************************************************/
/* Dialogtypen --> dialtyp, s.u.                                          */
/**************************************************************************/
#define UFS_DIALOG        0       /* Modaler Dialog                       */
#define UFS_WINDOW        1       /* Unmodaler Dialog                     */

/**************************************************************************/
/* Flags fÅr xUFSL --> flags, s.u.                                        */
/**************************************************************************/
#define UFS_SIZE_CHANGE   0x00000001  /* Schriftgrîûe Ñnderbar?           */
#define UFS_WIDTH_CHANGE  0x00000002  /* Schriftbreite Ñnderbar?          */
#define UFS_ATTR_CHANGE   0x00000004  /* Schriftattribute wÑhlbar?        */
#define UFS_SKEW_CHANGE   0x00000008  /* Schriftneigung Ñnderbar?         */
#define UFS_COLOR_CHANGE  0x00000010  /* Schriftfarbe Ñnderbar?           */
#define UFS_SIZE_DEFAULT  0x00000020  /* Schriftgrîûe "DEFAULT" erlaubt?  */
#define UFS_ATTR_INVERS   0x00000040  /* Sonderattribut "invers" wÑhlbar? */
#define UFS_KERNING_INFO  0x00000080  /* Kerning-Informationen Ñnderbar?  */
#define UFS_GDOS_FONTS    0x00000100  /* GDOS-Fonts erlaubt?              */
#define UFS_PROP_FONTS    0x00000200  /* Proportionalfonts erlaubt?       */
#define UFS_BITMAP_FONTS  0x00000400  /* Nur Bitmap-Fonts erlaubt?        */
#define UFS_VECTOR_FONTS  0x00000800  /* Nur Vektor-Fonts erlaubt?        */
#define UFS_WIND_DIALOG   0x00001000  /* Dialog im Fenster?               */
#define UFS_ERROR_MSG     0x00008000  /* Fehler als Alertbox anzeigen?    */
#define UFS_INDIRECT      0x80000000L /* Wird eine XUFSL_LIST verwendet?  */

/**************************************************************************/
/* UFSL-Initialisierungsfunktion, nur aus KompatibilitÑtsgrÅnden imple-   */
/* mentiert. Liefert immer SUCCESS.                                       */
/**************************************************************************/
typedef int (*UFSL_INIT)(void);

/**************************************************************************/
/* Standard-Fontselektor                                                  */
/**************************************************************************/
typedef int (*UFSL)(
  int   handle,   /* Handle der VDI-Workstation                           */
  int   fonts,    /* Gesamtzahl der geladenen Fonts                       */
  int   flag,     /* 0=Alle Fonts, 1=Nur unproportionale Fonts            */
  char  *info,    /* Infotext                                             */
  int   *fontid,  /* GewÑhlte Font-ID                                     */
  int   *fontsize /* GewÑhlte Font-Grîûe                                  */
);

/**************************************************************************/
/* Neuer Standard-Fontselektor ab UFSL 0.97                               */
/**************************************************************************/
typedef int (*NUFSL)(
  int   handle,   /* Handle der VDI-Workstation                           */
  int   flag,     /* 0=Alle Fonts, 1=Nur unproportionale Fonts            */
  char  *info,    /* Infotext                                             */
  int   *fontid,  /* GewÑhlte Font-ID                                     */
  int   *fontsize /* GewÑhlte Font-Grîûe                                  */
);

/**************************************************************************/
/* Benutzerdefinierte Hilfefunktion, sofern gewÅnscht. Nur wenn diese     */
/* ungleich NULL ist, wird der Hilfe-Knopf Åberhaupt aktiviert.           */
/**************************************************************************/
typedef int (*UFSL_HELP)(void);

/**************************************************************************/
/* Redraw-Funktion                                                        */
/* Die Redraw-Funktion wird NICHT bei folgenden Ereignissen aufgerufen:   */
/* WM_TOPPED, WM_NEWTOP, WM_CLOSED.                                       */
/**************************************************************************/
typedef void (*MSGFUNC)(
  int event,    /* Event                                                  */
  int *msgbuff  /* Message-Puffer                                         */
);

/**************************************************************************/
/* Schriftbreiten-Informationsstruktur ('FontWidthInfo')                  */
/* pair   Pair-Kerning (0=nein, 1=ja): "Zusammenschieben" bestimmter      */
/*        Buchstabenpaare (z.B. "Fa", "Ve").                              */
/* track  Art des Track-Kernings (0=ohne, 1=normal, 2=eng, 3=sehr eng):   */
/*        Hiermit wird der generelle Abstand zwischen den Buchstaben be-  */
/*        stimmt.                                                         */
/* width  Schriftbreite (0..MAX_CHAR_WIDTH Punkte)                        */
/**************************************************************************/
#define MAX_CHAR_WIDTH  8191

typedef struct {
  unsigned int  pair  : 1;
  unsigned int  track : 2;
  unsigned int  width : 13;
} FW_INFO;

/**************************************************************************/
/* Bei gesetztem UFS_INDIRECT-Bit wird statt in info ein Zeiger auf eine  */
/* XUFSL_LIST Åbergeben. Die Anzahl der EintrÑge dieser Liste muû im Pa-  */
/* rameter fontid Åbergeben werden.                                       */
/**************************************************************************/
typedef struct {
  unsigned long flags;        /* Flags zur FunktionsÅberwachung           */
  char          *entry;       /* Popup-Eintrag, muû eindeutig sein!       */
  int           fontid;       /* Voreingestellte/gewÑhlte ID              */
  int           fontsize;     /* Voreingestellte/gewÑhlte Grîûe           */
  FW_INFO       fontwidth;    /* Voreingestellte/gewÑhlte Breite+Kerning  */
  int           fontattr;     /* Voreingestellte/gewÑhlte Attribute       */
  int           fontcol;      /* Voreingestellte/gewÑhlte Farbe           */
  int           fontskew;     /* Voreingestellte/gewÑhlte Neigung         */
} XUFSL_LIST;

/**************************************************************************/
/* Extended-Fontselektor                                                  */
/**************************************************************************/
typedef int (*XUFSL)(
  int           handle,       /* Handle der VDI-Workstation               */
  unsigned long flags,        /* Flags zur FunktionsÅberwachung           */
  char          *title,       /* Fenstertitel, Default: Copyright-Info    */
  char          *info,        /* Fensterinfo, Default: 'Schriftauswahl'   */
                              /* bzw. Zeiger auf eine XUFSL_LIST          */
  int           smallid,      /* ID SMALL-Zeichensatz im xUFSL-Dialog     */
  int           ibmid,        /* ID IBM-Zeichensatz im xUFSL-Dialog       */
  int           *fontid,      /* Voreingestellte/gewÑhlte ID              */
                              /* bzw. Anzahl der EintrÑge der XUFSL_LIST  */
  int           *fontsize,    /* Voreingestellte/gewÑhlte Grîûe           */
                              /* bzw. Aufsatzpunkt in der XUFSL_LIST      */
  FW_INFO       *fontwidth,   /* Voreingestellte/gewÑhlte Breite und      */
                              /* Kerning-Informationen                    */
  int           *fontattr,    /* Voreingestellte/gewÑhlte Attribute       */
  int           *fontcol,     /* Voreingestellte/gewÑhlte Farbe           */
  int           *fontskew     /* Voreingestellte/gewÑhlte Neigung         */
);

/**************************************************************************/
/* Eigentliche xUFSL-Struktur                                             */
/**************************************************************************/
typedef struct {
  unsigned long id;               /* Kennung des xUFSL (xUFS)             */
  unsigned int  version;          /* Version (BCD-Format)                 */
  unsigned int  dialtyp;          /* Dialogtyp                            */
  UFSL_INIT     fontsel_init;     /* Initialisierungsfunktion (Dummy)     */
  UFSL          fontsel_input;    /* Standard-Selektorfunktion            */
  OBJECT        *helpbutton;      /* Hilfe-Knopf (BOXTEXT), maximale      */
                                  /* TextlÑnge 9 Zeichen (OHNE PrÅfung!). */
  UFSL_HELP     helpfunc;         /* Eigene Hilfefunktion                 */
  char          *examplestr;      /* Beispieltext fÅr Fontdarstellung     */
  MSGFUNC       msgfunc;          /* Redrawfunktion                       */
  NUFSL         fontsel_exinput;  /* Neuer Standard-Selektor              */
  XUFSL         font_selexinput;  /* Extended-Selektorfunktion            */
} xUFSL_struct;

#endif
