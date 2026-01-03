/****************************************************************************/
/****************************************************************************/
/****  DRUCKER-ACCESSORY FUER BELIEBIGE DRUCKERTYPEN       Version 4.00  ****/
/****  ---------------------------------------------                     ****/
/****  Druckertyp : EPSON FX-80                                          ****/
/****  Stand      : 20.06.86                                             ****/
/****                                                                    ****/
/****  Programmautor : Wolfram Winter                                    ****/
/****                  Eupenerstr. 5                                     ****/
/****                  D5600 Wuppertal 11                                ****/
/****************************************************************************/
/****************************************************************************/
/*--------------------------------------------------------------------------*/
/*       DEFINES fuer DR-Compiler (bei Bedarf fuer andere Compiler aendern) */
/*--------------------------------------------------------------------------*/
#define BYTE      char
#define WORD      int                   /* LATTICE-Compiler: short          */
#define UWORD     unsigned int          /* LATTICE-Compiler: unsigned short */
#define LONG      long
#define EXTERN    extern
#define VOID      /**/
/*--------------------------------------------------------------------------*/
/*       Vereinbarungen                                                     */
/*--------------------------------------------------------------------------*/
EXTERN       gl_apid;                   /* Applikationskennung              */
EXTERN LONG  gemdos();                  /* GEMDOS-Funktion                  */
#define  Cprnos()    gemdos(0x11)       /* Drucker-Anwesenheit              */
#define  Cprnout(a)  gemdos(0x5,a)      /* Drucker-Ausgabe                  */
/*--------------------------------------------------------------------------*/
WORD  contrl[12];                       /* Array der Kontrollparameter      */
WORD  intin[128];                       /* Array d. Integer-Eingabeparameter*/
WORD  ptsin[128];                       /* Array d. Eingabe-Koordinaten     */
WORD  intout[128];                      /* Array d. Integer-Ausgabeparameter*/
WORD  ptsout[128];                      /* Array d. Ausgabe-Koordinaten     */
WORD  work_in[11];                      /* Eingabe zum GSX-Array            */
WORD  work_out[57];                     /* Ausgabe vom GSX-Array            */
WORD  phys_handle;                      /* Desk-Handle                      */
/*--------------------------------------------------------------------------*/
WORD  bchar;                            /* Breite u. Hoehe einer Buchstaben-*/
WORD  hchar;                            /* zelle, quadratische Box um eine  */
WORD  bbox;                             /* Buchstabenzelle in Breite und    */
WORD  hbox;                             /* Hoehe                            */
/*--------------------------------------------------------------------------*/
WORD  menu_id;                          /* Nummer des Menue-Eintrages       */
WORD  ret;                              /* Dummy                            */
LONG  tree;                             /* Adresse Baumstruktur             */
WORD  event;                            /* Ereignis                         */
WORD  msgbuff[8];                       /* Nachrichtenpuffer                */
/*--------------------------------------------------------------------------*/
typedef struct object                   /* OBJECT-Struktur                  */
{                                       /*                                  */
WORD    ob_next;                        /* naechste Objekt-Ebene            */
WORD    ob_head;                        /* Zeiger auf Anfang der Objekte    */
WORD    ob_tail;                        /* Zeiger auf Ende der Objekte      */
UWORD   ob_type;                        /* Objekt-Typ                       */
UWORD   ob_flags;                       /* Objekt-Flag                      */
UWORD   ob_state;                       /* Objekt-Status                    */
LONG    ob_spec;                        /* Zeiger Objektspezifikation       */
WORD    ob_x;                           /* X-Koordinate Objekt              */
WORD    ob_y;                           /* Y-Koordinate Objekt              */
WORD    ob_width;                       /* Breite Objekt                    */
WORD    ob_height;                      /* Hoehe Objekt                     */
} OBJECT;                               /*                                  */
                                        /*                                  */
typedef struct grect                    /* GRECT-Struktur                   */
{                                       /*                                  */
WORD    g_x;                            /* X-Koordinate                     */
WORD    g_y;                            /* Y-Koordinate                     */
WORD    g_w;                            /* Breite                           */
WORD    g_h;                            /* Hoehe                            */
} GRECT;                                /*                                  */
                                        /*                                  */
typedef struct text_edinfo              /* TEDINFO-Struktur                 */
{                                       /*                                  */
LONG    te_ptext;                       /* Zeiger auf aktuellen Text        */
LONG    te_ptmplt;                      /* Zeiger auf Text-Maske            */
LONG    te_pvalid;                      /* Zeiger auf erlaubte Eingabewerte */
WORD    te_font;                        /* Schriftgroesse                   */
WORD    te_junk1;                       /* nicht benutzt                    */
WORD    te_just;                        /* Text-Justierung                  */
WORD    te_color;                       /* Text-Farbe                       */
WORD    te_junk2;                       /* nicht benutzt                    */
WORD    te_thickness;                   /* Dicke der Box-Umrandung          */
WORD    te_txtlen;                      /* Text-Laenge                      */
WORD    te_tmplen;                      /* Masken-Laenge                    */
} TEDINFO;                              /*                                  */
/*--------------------------------------------------------------------------*/
#define X_BAK        0x0100             /* TOUCHEXIT-Pfeil (links)          */
#define X_FWD        0x0200             /* TOUCHEXIT-Pfeil (rechts)         */
#define NIL          -1                 /*                                  */
#define FOREVER      for(;;)            /* Endlos-Schleife                  */
#define YES          1                  /*                                  */
#define NO           0                  /*                                  */
#define MU_MESAG     0x0010             /* Nachricht fuer event             */
#define AC_OPEN      40                 /* Accessory geoeffnet?             */
#define BEG_UPDATE   1                  /* Benutzeraktivitaeten             */
#define END_UPDATE   0                  /*                                  */
/*--------------------------------------------------------------------------*/
#define ROOT         0                  /* Objekt-Formen                    */
#define G_BOX        20
#define G_TEXT       21
#define G_BOXTEXT    22
#define G_IMAGE      23
#define G_USERDEF    24
#define G_IBOX       25
#define G_BUTTON     26
#define G_BOXCHAR    27
#define G_STRING     28
#define G_FTEXT      29
#define G_FBOXTEXT   30
#define G_ICON       31
#define G_TITLE      32
#define NONE         0x0
#define SELECTABLE   0x1
#define DEFAULT      0x2
#define EXIT         0x4
#define EDITABLE     0x8
#define RBUTTON      0x10
#define LASTOB       0x20
#define TOUCHEXIT    0x40
#define HIDETREE     0x80
#define INDIRECT     0x100
#define NORMAL       0x0
#define SELECTED     0x1
#define CROSSED      0x2
#define CHECKED      0x4
#define DISABLED     0x8
#define OUTLINED     0x10
#define SHADOWED     0x20
/*--------------------------------------------------------------------------*/
#define OB_NEXT(x)   (tree + (x) * sizeof(OBJECT) + 0)  /* Objekt-Attribute */
#define OB_HEAD(x)   (tree + (x) * sizeof(OBJECT) + 2)
#define OB_TAIL(x)   (tree + (x) * sizeof(OBJECT) + 4)
#define OB_TYPE(x)   (tree + (x) * sizeof(OBJECT) + 6)
#define OB_FLAGS(x)  (tree + (x) * sizeof(OBJECT) + 8)
#define OB_STATE(x)  (tree + (x) * sizeof(OBJECT) + 10)
#define OB_SPEC(x)   (tree + (x) * sizeof(OBJECT) + 12)
#define OB_X(x)      (tree + (x) * sizeof(OBJECT) + 16)
#define OB_Y(x)      (tree + (x) * sizeof(OBJECT) + 18)
#define OB_WIDTH(x)  (tree + (x) * sizeof(OBJECT) + 20)
#define OB_HEIGHT(x) (tree + (x) * sizeof(OBJECT) + 22)
/*--------------------------------------------------------------------------*/
#define LWGET(x)     ( (WORD) *((WORD *)(x)) )  /* get WORD pointed by WORD */
#define LWSET(x, y)  ( *((WORD *)(x)) = y)      /* set WORD pointed by WORD */
#define LLGET(x)     ( *((LONG *)(x)))          /* get LONG pointed by LONG */
#define LLSET(x, y)  ( *((LONG *)(x)) = y)      /* set LONG pointed by LONG */
/*--------------------------------------------------------------------------*/
/*       Drucker-Codes und Menue-Eintrag                                    */
/*--------------------------------------------------------------------------*/
#define MENU_NAME  "  FX-80 Drucker"             /* Name Menue-Eintrag      */
WORD p_reset[]    = { 27, 64,255 };              /* Drucker-Reset           */
WORD p_unidir[]   = { 27, 85,  1,255 };          /* Druck von einer Seite   */
WORD p_bidir[]    = { 27, 85,  0,255 };          /* Druck von beiden Seiten */
WORD p_set[]      = { 27, 82,  0,255 };          /* Zeichensatz             */
#define  MIN_SET  0
#define  MAX_SET  7
BYTE  *str_set[]  = { "USA","F","D","GB","DK","S","I","S" };
WORD p_page[]     = { 27, 67,  0, 12,255 };      /* 12 Zoll-Seite           */
#define  MIN_PAGE 1
#define  MAX_PAGE 22
WORD p_skip[]     = { 27, 78,  6,255 };          /* unten 6Z. ueberspringen */
WORD p_offskip[]  = { 27, 79,255 };              /* kein Perforationssprung */
#define  MIN_SKIP 0
#define  MAX_SKIP 127
WORD p_lmar[]     = { 27,108,  0,255 };          /* 0Zeichen linker Rand    */
#define  MIN_LMAR 0
WORD p_rmar[]     = { 27, 81,135,255 };          /* 135Zeichen rechter Rand */
#define  MAX_RMAR 135
WORD p_lspace[]   = { 27, 51, 36,255 };          /* 36/216 Zeilenabstand    */
#define  MIN_LSPA 0
#define  MAX_LSPA 255
WORD p_stand[]    = { 27, 53,            255 };  /*         STANDARD an     */
WORD p_nlq[]      = { 27, 53,            255 };  /* STANDARD an             */
WORD p_ital[]     = { 27, 52,            255 };  /*          ITALIC an      */
WORD p_pica[]     = { 27, 84, 27, 80, 18,255 };  /* SUP,ELIT,COND aus       */
WORD p_cond[]     = { 27, 84, 27, 80, 15,255 };  /* SUP,ELIT aus,COND an    */
WORD p_elite[]    = { 27, 84, 18, 27, 77,255 };  /* SUP,COND aus,ELIT an    */
WORD p_micro[]    = { 27, 80, 18, 27, 83,0,255}; /* ELIT,COND aus,SUP an    */
WORD p_onexp[]    = { 27, 87,  1,255 };          /* EXPAND an               */
WORD p_offexp[]   = { 27, 87,  0,255 };          /* EXPAND aus              */
WORD p_onprop[]   = {            255 };          /* PROPORTIONAL an         */
WORD p_offprop[]  = {            255 };          /* PROPORTIONAL aus        */
WORD p_ondoub[]   = { 27, 71,255 };              /* DOPPEL an               */
WORD p_offdoub[]  = { 27, 72,255 };              /* DOPPEL aus              */
WORD p_onemph[]   = { 27, 69,255 };              /* EMPHASIZED an           */
WORD p_offemph[]  = { 27, 70,255 };              /* EMPHASIZED aus          */
WORD p_onzero[]   = {            255 };          /* durchstrichene Null     */
WORD p_offzero[]  = {            255 };          /* normale Null            */
WORD p_onform[]   = { 12,255 };                  /* Seitenvorschub          */
WORD p_ret[]      = {  7, 13,255 };              /* Klingel, Return         */
/*--------------------------------------------------------------------------*/
/*       Definitionen aus RSC-Set                                           */
/*--------------------------------------------------------------------------*/
BYTE *rs_strings[] = {
"   EPSON FX80 DRUCKER INITIALISIERUNG   ","","",
" (c) Wolfram Winter  D5600 WUPPERTAL-11 ","","",
"DRUCK","","","->","<->","SEITE","","","12","","","'L„nge","","",
"ZEICHEN","","","UMBRUCH","","","  6","","","?","ABSTAND","",""," 36","","",
"/216'","","","PROPORT","","","AN","AUS","LI.RAND","","","  0","","",
"EXPAND","","","AN","AUS","RE.RAND","","","137","","","DOUBLE","","",
"AN","AUS","EMPH","","","AN","AUS"," AUSGABE MIT: ","","","NULL","","",
"0","O","RESET","","","AN","AUS","FORMFEED","","","AN","AUS","PICA","MICRO",
"ELITE","CONDEN","STAND","NLQ","ITALIC","PRINT","","","AN","AUS","ABBRUCH",
"OK","Version 4.0 ","",""};

TEDINFO rs_tedinfo[] = {
  0L,   1L,   2L, 3, 6, 2, 0x11E1, 0x0, -1, 41,1,
  3L,   4L,   5L, 5, 6, 0, 0x1180, 0x0, -1, 41,1,
  6L,   7L,   8L, 3, 6, 0, 0x1180, 0x0, -1,  6,1,
 11L,  12L,  13L, 3, 6, 0, 0x1180, 0x0, -1,  6,1,
 14L,  15L,  16L, 3, 6, 2, 0x1180, 0x0, -1,  3,1,
 17L,  18L,  19L, 3, 6, 0, 0x1180, 0x0, -1,  7,1,
 20L,  21L,  22L, 3, 6, 0, 0x1180, 0x0, -1,  8,1,
 23L,  24L,  25L, 3, 6, 0, 0x1180, 0x0, -1,  8,1,
 26L,  27L,  28L, 3, 6, 2, 0x1180, 0x0, -1,  4,1,
 30L,  31L,  32L, 3, 6, 0, 0x1180, 0x0, -1,  8,1,
 33L,  34L,  35L, 3, 6, 2, 0x1180, 0x0, -1,  4,1,
 36L,  37L,  38L, 3, 6, 0, 0x1180, 0x0, -1,  6,1,
 39L,  40L,  41L, 3, 6, 0, 0x1180, 0x0, -1,  8,1,
 44L,  45L,  46L, 3, 6, 0, 0x1180, 0x0, -1,  8,1,
 47L,  48L,  49L, 3, 6, 2, 0x1180, 0x0, -1,  4,1,
 50L,  51L,  52L, 3, 6, 0, 0x1180, 0x0, -1,  7,1,
 55L,  56L,  57L, 3, 6, 0, 0x1180, 0x0, -1,  8,1,
 58L,  59L,  60L, 3, 6, 2, 0x1180, 0x0, -1,  4,1,
 61L,  62L,  63L, 3, 6, 0, 0x1180, 0x0, -1,  7,1,
 66L,  67L,  68L, 3, 6, 0, 0x1180, 0x0, -1,  5,1,
 71L,  72L,  73L, 3, 6, 2, 0x11A1, 0x0, -1, 15,1,
 74L,  75L,  76L, 3, 6, 0, 0x1180, 0x0, -1,  5,1,
 79L,  80L,  81L, 3, 6, 0, 0x1180, 0x0, -1,  6,1,
 84L,  85L,  86L, 3, 6, 0, 0x1180, 0x0, -1,  9,1,
 96L,  97L,  98L, 3, 6, 0, 0x1180, 0x0, -1,  6,1,
103L, 104L, 105L, 5, 6, 2, 0x1180, 0x0, -1, 13,1 };

OBJECT rs_object[] = {
-1,  1, 81, G_BOX,     NONE,      SHADOWED, 0x21100L,    0,  0, 47,  17,
 2, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x0L,        0,  0, 47,   2,
 3, -1, -1, G_TEXT,    NONE,      NORMAL,   0x1L,        9,  2, 30,1536,
 4, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x2L,        1,  3,  8,   1,
 7,  5,  6, G_BOX,     NONE,      NORMAL,   0xFF0121L,  10,  3, 13,   1,
 6, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x9L,        0,  0,  6,   1,
 4, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0xAL,        7,  0,  6,   1,
 8, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x3L,       24,  3,  8,   1,
13,  9, 12, G_IBOX,    NONE,      NORMAL,   0xFF1100L,  33,  3, 13,   1,
10, -1, -1, G_BOXTEXT, NONE,      NORMAL,   0x4L,        2,  0,  3,   1,
11, -1, -1, G_TEXT,    NONE,      NORMAL,   0x5L,        5,  0,  6,   1,
12, -1, -1, 0x21B,     TOUCHEXIT, SHADOWED, 0x3FF1100L, 11,  0,  2,   1,
 8, -1, -1, 0x11B,     TOUCHEXIT, NORMAL,   0x4FF1100L,  0,  0,  2,   1,
14, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x6L,        1,  4,  8,   1,
15, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x7L,       24,  4,  8,   1,
19, 16, 18, G_IBOX,    NONE,      NORMAL,   0xFF1100L,  33,  4, 13,   1,
17, -1, -1, G_BOXTEXT, NONE,      NORMAL,   0x8L,        2,  0,  9,   1,
18, -1, -1, 0x21B,     TOUCHEXIT, SHADOWED, 0x3FF1100L, 11,  0,  2,   1,
15, -1, -1, 0x11B,     TOUCHEXIT, NORMAL,   0x4FF1100L,  0,  0,  2,   1,
21, 20, 20, G_BOX,     NONE,      NORMAL,   0xFF0100L,  10,  4, 13,   1,
19, -1, -1, G_BUTTON,  TOUCHEXIT, SHADOWED, 0x1DL,       0,  0, 13,   1,
22, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x9L,       24,  5,  8,   1,
27, 23, 26, G_IBOX,    NONE,      NORMAL,   0xFF1100L,  33,  5, 13,   1,
24, -1, -1, G_BOXTEXT, NONE,      NORMAL,   0xAL,        2,  0,  4,   1,
25, -1, -1, G_TEXT,    NONE,      NORMAL,   0xBL,        6,  0,  5,   1,
26, -1, -1, 0x21B,     TOUCHEXIT, SHADOWED, 0x3FF1100L, 11,  0,  2,   1,
22, -1, -1, 0x11B,     TOUCHEXIT, NORMAL,   0x4FF1100L,  0,  0,  2,   1,
28, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0xCL,        1,  6,  8,   1,
31, 29, 30, G_BOX,     NONE,      NORMAL,   0xFF0121L,  10,  6, 13,   1,
30, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x2AL,       0,  0,  6,   1,
28, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x2BL,       7,  0,  6,   1,
32, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0xDL,       24,  6,  8,   1,
36, 33, 35, G_IBOX,    NONE,      NORMAL,   0xFF1100L,  33,  6, 13,   1,
34, -1, -1, G_BOXTEXT, NONE,      NORMAL,   0xEL,        2,  0,  9,   1,
35, -1, -1, 0x21B,     TOUCHEXIT, SHADOWED, 0x3FF1100L, 11,  0,  2,   1,
32, -1, -1, 0x11B,     TOUCHEXIT, NORMAL,   0x4FF1100L,  0,  0,  2,   1,
37, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0xFL,        1,  7,  8,   1,
40, 38, 39, G_BOX,     NONE,      NORMAL,   0xFF0121L,  10,  7, 13,   1,
39, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x35L,       0,  0,  6,   1,
37, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x36L,       7,  0,  6,   1,
41, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x10L,      24,  7,  8,   1,
45, 42, 44, G_IBOX,    NONE,      SHADOWED, 0xFF1100L,  33,  7, 13,   1,
43, -1, -1, G_BOXTEXT, NONE,      NORMAL,   0x11L,       2,  0,  9,   1,
44, -1, -1, 0x21B,     TOUCHEXIT, NORMAL,   0x3FF1100L, 11,  0,  2,   1,
41, -1, -1, 0x11B,     TOUCHEXIT, NORMAL,   0x4FF1100L,  0,  0,  2,   1,
46, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x12L,       1,  8,  8,   1,
49, 47, 48, G_BOX,     NONE,      NORMAL,   0xFF0121L,  10,  8, 13,   1,
48, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x40L,       0,  0,  6,   1,
46, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x41L,       7,  0,  6,   1,
50, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x13L,       1,  9,  8,   1,
53, 51, 52, G_BOX,     NONE,      NORMAL,   0xFF0121L,  10,  9, 13,   1,
52, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x45L,       0,  0,  6,   1,
50, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x46L,       7,  0,  6,   1,
54, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x14L,      24,  9, 22,   1,
55, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x15L,       1, 10,  8,   1,
58, 56, 57, G_BOX,     NONE,      NORMAL,   0xFF0121L,  10, 10, 13,   1,
57, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x4DL,       0,  0,  6,   1,
55, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x4EL,       7,  0,  6,   1,
59, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x16L,      24, 10,  8,   1,
62, 60, 61, G_BOX,     NONE,      NORMAL,   0xFF0121L,  33, 10, 13,   1,
61, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x52L,       0,  0,  6,   1,
59, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x53L,       7,  0,  6,   1,
63, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x17L,      24, 11,  8,   1,
66, 64, 65, G_BOX,     NONE,      NORMAL,   0xFF0121L,  33, 11, 13,   1,
65, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x57L,       0,  0,  6,   1,
63, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x58L,       7,  0,  6,   1,
71, 67, 70, G_BOX,     NONE,      NORMAL,   0xFF0100L,   2, 12,  9,   4,
68, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x59L,       0,  0,  9,   1,
69, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x5AL,       0,  1,  9,   1,
70, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x5BL,       0,  2,  9,   1,
66, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x5CL,       0,  3,  9,   1,
75, 72, 74, G_BOX,     NONE,      NORMAL,   0xFF0100L,  13, 12,  9,   3,
73, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x5DL,       0,  0,  9,   1,
74, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x5EL,       0,  1,  9,   1,
71, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x5FL,       0,  2,  9,   1,
76, -1, -1, G_BOXTEXT, NONE,      SHADOWED, 0x18L,      24, 12,  8,   1,
79, 77, 78, G_BOX,     NONE,      NORMAL,   0xFF0121L,  33, 12, 13,   1,
78, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x63L,       0,  0,  6,   1,
76, -1, -1, G_BUTTON,  0x11,      SHADOWED, 0x64L,       7,  0,  6,   1,
80, -1, -1, G_BUTTON,  0x15,      SHADOWED, 0x65L,      25, 14,  9,   2,
81, -1, -1, G_BUTTON,  0x17,      SHADOWED, 0x66L,      36, 14,  9,   2,
 0, -1, -1, G_TEXT,    LASTOB,    NORMAL,   0x19L,      12, 16,  9,1536 };

#define NUM_TI    26
#define NUM_OBS   82

#define DRUCKER   0     /* TREE */
#define STANDON   72    /* OBJECT in TREE #0 */
#define CANCEL    79    /* OBJECT in TREE #0 */
#define OKAY      80    /* OBJECT in TREE #0 */
#define NLQON     73    /* OBJECT in TREE #0 */
#define ITALON    74    /* OBJECT in TREE #0 */
#define PROPON    29    /* OBJECT in TREE #0 */
#define PROPOFF   30    /* OBJECT in TREE #0 */
#define RESON     60    /* OBJECT in TREE #0 */
#define FORMON    64    /* OBJECT in TREE #0 */
#define RESOFF    61    /* OBJECT in TREE #0 */
#define FORMOFF   65    /* OBJECT in TREE #0 */
#define UNIDIR    5     /* OBJECT in TREE #0 */
#define BIDIR     6     /* OBJECT in TREE #0 */
#define IMAGE     2     /* OBJECT in TREE #0 */
#define EXPON     38    /* OBJECT in TREE #0 */
#define EXPOFF    39    /* OBJECT in TREE #0 */
#define DOUBON    47    /* OBJECT in TREE #0 */
#define DOUBOFF   48    /* OBJECT in TREE #0 */
#define EMPHON    51    /* OBJECT in TREE #0 */
#define EMPHOFF   52    /* OBJECT in TREE #0 */
#define ZEROON    56    /* OBJECT in TREE #0 */
#define ZEROOFF   57    /* OBJECT in TREE #0 */
#define PICAON    67    /* OBJECT in TREE #0 */
#define MICROON   68    /* OBJECT in TREE #0 */
#define ELITEON   69    /* OBJECT in TREE #0 */
#define CONDON    70    /* OBJECT in TREE #0 */
#define PAGE      9     /* OBJECT in TREE #0 */
#define PRINTON   77    /* OBJECT in TREE #0 */
#define PRINTOFF  78    /* OBJECT in TREE #0 */
#define LSPACE    23    /* OBJECT in TREE #0 */
#define SKIP      16    /* OBJECT in TREE #0 */
#define LMAR      33    /* OBJECT in TREE #0 */
#define RMAR      42    /* OBJECT in TREE #0 */
#define SET       20    /* OBJECT in TREE #0 */
#define PASET     19    /* OBJECT in TREE #0 */
#define PAPAGE    8     /* OBJECT in TREE #0 */
#define PASKIP    15    /* OBJECT in TREE #0 */
#define PALSPACE  22    /* OBJECT in TREE #0 */
#define PALMAR    32    /* OBJECT in TREE #0 */
#define PARMAR    41    /* OBJECT in TREE #0 */
/*--------------------------------------------------------------------------*/
/*       Fehlermeldung                                                      */
/*--------------------------------------------------------------------------*/
BYTE fehler[] = {
"[3][     !!! FEHLER !!!|Es ist kein Drucker ange-|schlossen oder der \
Drucker|ist nicht empfangsbereit.][OK|ABBRUCH]" };
/*--------------------------------------------------------------------------*/
/*       fix_objects                                                        */
/*--------------------------------------------------------------------------*/
VOID fix_objects()                      /* Setzen der Objektstrukturadressen*/
{                                       /*                                  */
 WORD   test, ii;                       /* Objektindex, Zaehler             */
 for(ii = 0; ii < NUM_OBS; ii++) {      /* Schleife ueber Anzahl Objekte    */
    test = (WORD) rs_object[ii].ob_spec; /*                                 */
    rs_object[ii].ob_x      *= bchar;   /* x-Koord. * Zeichenbreite (Pixel) */
    rs_object[ii].ob_y      *= hchar;   /* y-Koord. * Zeichenhoehe  (Pixel) */
    if(rs_object[ii].ob_height == 1536) { /* wenn kleine Schrift            */
      rs_object[ii].ob_width  = rs_tedinfo[test].te_txtlen - 1; /* Laenge   */
      rs_object[ii].ob_height = 1;      /* Hoehe                            */
    }                                   /*                                  */
    rs_object[ii].ob_width  *= bchar;   /* Breite * Zeichenbreite (Pixel)   */
    rs_object[ii].ob_height *= hchar;   /* Hoehe  * Zeichenbreite (Pixel)   */
    switch (rs_object[ii].ob_type) {    /* Zeigeradressen entsprechend des  */
           case G_TITLE:                /* Objekt-Typs setzen               */
           case G_STRING:               /*                                  */
           case G_BUTTON:               /*                                  */
                fix_str(&rs_object[ii].ob_spec); /* Zeiger auf Text-String  */
                break;                  /*                                  */
           case G_TEXT:                 /*                                  */
           case G_BOXTEXT:              /*                                  */
           case G_FTEXT:                /*                                  */
           case G_FBOXTEXT:             /*                                  */
                if(test != NIL)         /* wenn nicht (-1), Zeiger auf die  */
                  rs_object[ii].ob_spec = (LONG) (&rs_tedinfo[test]); /*    */
                break;                  /* TEDINFO-Adresse setzen           */
           default:                     /*                                  */
    }                                   /* Ende 'case'-Anweisung            */
 }                                      /* Ende 'for'-Schleife              */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       fix_tedinfo                                                        */
/*--------------------------------------------------------------------------*/
VOID fix_tedinfo()                      /* TEDINFO-Adressen setzen          */
{                                       /*                                  */
 WORD   ii;                             /* Zaehler                          */
 for(ii = 0; ii < NUM_TI; ii++) {       /* Schleife ueber Anzahl TEDINFO's  */
    fix_str(&rs_tedinfo[ii].te_ptext);  /* Adresse fuer te_ptext            */
    fix_str(&rs_tedinfo[ii].te_ptmplt); /* Adresse fuer te_ptmplt           */
    fix_str(&rs_tedinfo[ii].te_pvalid); /* Adresse fuer te_pvalid           */
 }                                      /* Ende der Schleife                */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       fix_str                                                            */
/*--------------------------------------------------------------------------*/
VOID fix_str(where)                     /* Adresse des Stringanfangs wird   */
LONG   *where;                          /* an die in 'where' angegebene     */
{                                       /* Speicherstelle geschrieben       */
 if (*where != NIL)                     /* wenn ungleich (-1)               */
    *where=(LONG)(rs_strings[(WORD) *where]); /* LONG-Adresse               */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       do_obj                                                             */
/*--------------------------------------------------------------------------*/
VOID do_obj(which, bit)                 /* Objektbehandl. d. Objektbaumes   */
WORD   which, bit;                      /* welches Objekt, Bit              */
{                                       /*                                  */
 WORD state;                            /* Status                           */
 state = LWGET(OB_STATE(which));        /* Status des Objekts holen         */
 LWSET(OB_STATE(which), state | bit );  /* Bit im Objektstatus setzen       */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       undo_obj                                                           */
/*--------------------------------------------------------------------------*/
VOID undo_obj(which, bit)               /* Objektbehandl. d. Objektbaumes   */
WORD   which, bit;                      /* welches Objekt, Bit              */
{                                       /*                                  */
 WORD state;                            /* Status                           */
 state = LWGET(OB_STATE(which));        /* Status des Objekts holen         */
 LWSET(OB_STATE(which), state & ~bit ); /* Bit im Objektstatus loeschen     */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       select_obj                                                         */
/*--------------------------------------------------------------------------*/
VOID select_obj(which)                  /* Objekt als angewaehlt darstellen */
WORD   which;                           /* welches Objekt                   */
{                                       /*                                  */
 do_obj(which,SELECTED);                /* Objekt anwaehlen                 */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       deselect_obj                                                       */
/*--------------------------------------------------------------------------*/
VOID deselect_obj(which)                /* Obj. als nicht angewaehlt darst. */
WORD   which;                           /* welches Objekt                   */
{                                       /*                                  */
 undo_obj(which,SELECTED);              /* Objekt nicht anwaehlen           */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       get_parent                                                         */
/*--------------------------------------------------------------------------*/
WORD get_parent(obj)                    /* findet Wurzel des Objekts        */
WORD   obj;                             /* Objekt                           */
{                                       /*                                  */
 WORD   pobj;                           /* Eltern-Objekt                    */
 if(obj == NIL)                         /* wenn Objekt = Wurzelobjekt       */
   return (NIL);                        /* Ruecksprung mit NIL              */
 pobj = LWGET(OB_NEXT(obj));            /* naechstes Objekt holen           */
 if(pobj != NIL) {                      /* wenn kein Wurzelobjekt           */
   while( LWGET(OB_TAIL(pobj)) != obj ) {  /* suche bis letztes Objekt      */
        obj = pobj;                     /* vertauschen                      */
        pobj = LWGET(OB_NEXT(obj));     /* naechstes Objekt                 */
   }                                    /*                                  */
 }                                      /*                                  */
 return(pobj);                          /* Ruecksprung mit Eltern-Objekt    */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       objc_xywh                                                          */
/*--------------------------------------------------------------------------*/
VOID objc_xywh(obj, p)                  /* holt x,y,w,h des Objektes        */
WORD   obj;                             /* Objekt                           */
GRECT  *p;                              /* Zeiger auf Struktur fuer x,y,w,h */
{                                       /*                                  */
 objc_offset(tree, obj, &p->g_x, &p->g_y); /* x,y-Koordinaten des Objekts   */
 p->g_w = LWGET(OB_WIDTH(obj));         /* w des Objekts                    */
 p->g_h = LWGET(OB_HEIGHT(obj));        /* h des Objekts                    */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       do_string                                                          */
/*--------------------------------------------------------------------------*/
VOID do_string(obj, num)                /* Zahl in Objekt-String schreiben  */
WORD obj;                               /* Objekt                           */
WORD num;                               /* Zahl                             */
{                                       /*                                  */
 BYTE   *ptr;                           /* Zeiger auf String                */
 WORD   length;                         /* Stringlaenge                     */
 ptr = (BYTE *) LLGET(LLGET(OB_SPEC(obj)));  /* Zeiger ermitteln            */
 length = strlen(ptr);                  /* Laenge des Strings               */
 ptr += length;                         /* Stringpointer auf letztes Zeichen*/
 do{                                    /* Schleife ueber Anzahl der Zahlen */
   *--ptr = num % 10 + '0';             /* MOD(num,10)=letzte Stelle->String*/
   length--;                            /* Zeichenzaehler - 1               */
 } while((num /= 10) > 0);              /* num=INT(num/10),Schleife b. num=0*/
 while(length-- != 0)                   /* String mit Leerzeichen auffuellen*/
   *--ptr = ' ';                        /* bis Zeichenzaehler = 0 ist       */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       prout                                                              */
/*--------------------------------------------------------------------------*/
VOID prout()                            /* Abfrage d. Tasten u. Druckerausg.*/
{                                       /*                                  */
 WORD  i;                               /* Zaehler                          */
 if(LWGET(OB_STATE(RESON)) & SELECTED)  /* Taste RESET ON ?                 */
     output(p_reset);                   /*                                  */
 if(LWGET(OB_STATE(UNIDIR)) & SELECTED) /* Taste UNIDIR ?                   */
     output(p_unidir);                  /*                                  */
   else                                 /* Nein: also BIDIR                 */
     output(p_bidir);                   /*                                  */
 output(p_set);                         /* Zeichensatz                      */
 output(p_page);                        /* Seitenlaenge                     */
 if(p_skip[2] == 0)                     /* wenn kein Perforations-Sprung    */
     output(p_offskip);                 /* Sprung loeschen                  */
   else                                 /* sonst                            */
     output(p_skip);                    /* Sprung setzen                    */
 output(p_lmar);                        /* linker Druckrand                 */
 output(p_rmar);                        /* rechter Druckrand                */
 output(p_lspace);                      /* Zeilenabstand                    */
 if(LWGET(OB_STATE(MICROON)) & SELECTED) /* Taste MICRO ON ?                */
     output(p_micro);                   /*                                  */
   else                                 /* Nein: also MICRO OFF             */
   { if(LWGET(OB_STATE(ELITEON)) & SELECTED) /* Taste ELITE ?               */
         output(p_elite);               /*                                  */
       else                             /* Nein: weiter abfragen            */
       { if(LWGET(OB_STATE(CONDON)) & SELECTED) /* Taste COND ?             */
           output(p_cond);              /*                                  */
         else                           /* Nein: also PICA                  */
           output(p_pica);              /*                                  */
       }                                /*                                  */
   }                                    /*                                  */
 if(LWGET(OB_STATE(NLQON)) & SELECTED)  /* Taste NLQ ?                      */
   { output(p_pica);                    /*                                  */
     output(p_nlq);  }                  /*                                  */
   else                                 /* Nein: weiter abfragen            */
   { if(LWGET(OB_STATE(ITALON)) & SELECTED) /* Taste ITALIC ?               */
         output(p_ital);                /*                                  */
       else                             /* Nein: also STANDARD              */
         output(p_stand);               /*                                  */
   }                                    /*                                  */
 if(LWGET(OB_STATE(EXPON)) & SELECTED)  /* Taste EXPANDED ON ?              */
     output(p_onexp);                   /*                                  */
   else                                 /* Nein: also EXPANDED OFF          */
     output(p_offexp);                  /*                                  */
 if(LWGET(OB_STATE(PROPON)) & SELECTED) /* Taste PROPORT ON ?               */
     output(p_onprop);                  /*                                  */
   else                                 /* Nein: also PROPORT OFF           */
     output(p_offprop);                 /*                                  */
 if(LWGET(OB_STATE(DOUBON)) & SELECTED) /* Taste DOUBLE ON ?                */
     output(p_ondoub);                  /*                                  */
   else                                 /* Nein: also DOUBLE OFF            */
     output(p_offdoub);                 /*                                  */
 if(LWGET(OB_STATE(EMPHON)) & SELECTED) /* Taste EMPHASIZED ON ?            */
     output(p_onemph);                  /*                                  */
   else                                 /* Nein: also EMPHASIZED OFF        */
     output(p_offemph);                 /*                                  */
 if(LWGET(OB_STATE(ZEROON)) & SELECTED) /* Taste durchstrichene Null ?      */
     output(p_onzero);                  /*                                  */
   else                                 /* Nein: also normale Null          */
     output(p_offzero);                 /*                                  */
 output(p_ret);                         /* Return ausgeben                  */
 if(LWGET(OB_STATE(PRINTON)) & SELECTED) /* Test-Ausdruck ?                 */
   { Cprnout(10);                       /* Linefeed                         */
     for(i=32;i<127;i++)                /* ASCII-Satz                       */
        Cprnout(i);                     /* Zeichen ausgeben                 */
     Cprnout(10);                       /* Linefeed                         */
   }                                    /*                                  */
 if(LWGET(OB_STATE(FORMON)) & SELECTED) /* Taste Seitenvorschub ?           */
     output(p_onform);                  /*                                  */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       output                                                             */
/*--------------------------------------------------------------------------*/
VOID output(pointer)                    /* Ausgabe Control-Codes bis $FF    */
WORD  *pointer;                         /* Zeiger auf Ausgabebereich        */
{                                       /*                                  */
 while( *pointer != 255 )               /* solange Zeichen ausgeben bis $FF */
      Cprnout(*pointer++);              /* ein Zeichen an Ausgabegeraet     */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       do_dialog                                                          */
/*--------------------------------------------------------------------------*/
VOID do_dialog()                        /* Dialogbehandlung                 */
{                                       /*                                  */
 LONG  printer = NO;                    /* Druckeranwesenheitsflag          */
 WORD  xdial,ydial,bdial,hdial;         /* Koordinaten                      */
 WORD  parent,exit_obj;                 /* Eltern- und Exit-Objekt          */
 WORD  xtype;                           /* Exit-Pfeil                       */
 GRECT ob;                              /* Struktur fuer x,y,w,h exit_obj   */
 form_center(tree,&xdial,&ydial,&bdial,&hdial); /* Koordinaten holen        */
 form_dial(0,1,1,1,1,xdial,ydial,bdial,hdial);  /* Bereich sichern          */
 form_dial(1,1,1,1,1,xdial,ydial,bdial,hdial);  /* aufgehender Kasten       */
 objc_draw(tree,0,10,xdial,ydial,bdial,hdial);  /* Baumobjekt zeichnen      */
                                        /*                                  */
 FOREVER                                /* Endlos-Schleife                  */
 {                                      /*                                  */
  exit_obj = form_do(tree, 0) & 0x7FFF; /* Objekt-Kontrolle abgeben         */
  xtype = LWGET(OB_TYPE(exit_obj)) & 0xFF00; /* Exit-Pfeil herausshiften    */
  if((!xtype) && (exit_obj != SET))     /* wenn kein Exitpfeil od. SET-Feld */
    break;                              /* Verlassen der Endlos-Schleife    */
                                        /*                                  */
  xtype = (xtype == X_BAK) ? -1 : 1;    /* xtype auf +1 oder -1 setzen      */
  parent = get_parent(exit_obj);        /* Objekt-Index des Eltern-Objekts  */
        switch(parent) {                /* Funktionen je nach Eltern-Objekt */
          case PASET:                   /* wenn Zeichensatz                 */
               exit_obj = SET;          /* neu zu zeichnendes Objekt        */
               p_set[2] = (p_set[2] == MAX_SET) ? MIN_SET : ++p_set[2];
               LLSET(OB_SPEC(SET),(LONG)str_set[p_set[2]]); /* String-      */
               break;                   /* pointer erhoehen, umsetzen       */
          case PAPAGE:                  /* wenn Seitenlaenge                */
               exit_obj = PAGE;         /* neu zu zeichnendes Objekt        */
               p_page[3] = (p_page[3]+xtype) % (MAX_PAGE+1);
               if (p_page[3] < MIN_PAGE)
                  p_page[3] = (xtype == -1) ? MAX_PAGE : MIN_PAGE;
               do_string(PAGE,p_page[3]);
               break;                   /*                                  */
          case PASKIP:                  /* wenn Seitenperforation           */
               exit_obj = SKIP;         /* neu zu zeichnendes Objekt        */
               p_skip[2] = (p_skip[2]+xtype) % (MAX_SKIP+1);
               if (p_skip[2] < MIN_SKIP)
                  p_skip[2] = (xtype == -1) ? MAX_SKIP : MIN_SKIP;
               do_string(SKIP,p_skip[2]);
               break;                   /*                                  */
          case PALSPACE:                /* wenn Zeilenabstand               */
               exit_obj = LSPACE;       /* neu zu zeichnendes Objekt        */
               p_lspace[2] = (p_lspace[2]+xtype) % (MAX_LSPA+1);
               if (p_lspace[2] < MIN_LSPA)
                  p_lspace[2] = (xtype == -1) ? MAX_LSPA : MIN_LSPA;
               do_string(LSPACE,p_lspace[2]);
               break;                   /*                                  */
          case PALMAR:                  /* wenn linker Druckrand            */
               exit_obj = LMAR;         /* neu zu zeichnendes Objekt        */
               p_lmar[2] = (p_lmar[2]+xtype) % p_rmar[2];
               if (p_lmar[2] < MIN_LMAR)
                  p_lmar[2] = (xtype == -1) ? (p_rmar[2]-1) : MIN_LMAR;
               do_string(LMAR,p_lmar[2]);
               break;                   /*                                  */
          case PARMAR:                  /* wenn rechter Druckrand           */
               exit_obj = RMAR;         /* neu zu zeichnendes Objekt        */
               p_rmar[2] = (p_rmar[2]+xtype) % (MAX_RMAR+1);
               if (p_rmar[2] < (p_lmar[2]+1))
                  p_rmar[2] = (xtype == -1) ? MAX_RMAR : (p_lmar[2]+1);
               do_string(RMAR,p_rmar[2]);
          default: break;               /*                                  */
        }                               /*                                  */
  objc_xywh(exit_obj,&ob);              /* x,y,w,h des Objekts holen        */
  objc_draw(tree,parent,1,ob.g_x+1,ob.g_y+1,ob.g_w-2,ob.g_h-2);
 }                                      /* Ende der Endlos-Schleife         */
                                        /*                                  */
 if(exit_obj == OKAY) {                 /* wenn D.Ausgabe D.Status abfragen */
   while(printer == NO) {               /* Schleife ueber Druckeranwesenheit*/
     printer = Cprnos();                /* Druckerstatus abfragen           */
     if(printer == NO) {                /* wenn kein Drucker                */
       if(form_alert(2,fehler) == 2) {  /* Ausgabe Fehlermeldung            */
         printer = YES;                 /* wenn Abbruch gefordert wurde     */
         exit_obj = CANCEL;             /* Abbruch der Ausgabe setzen und   */
       }                                /* keine Druckerausgabe             */
     }                                  /*                                  */
   }                                    /* Ende der while-Schleife          */
 }                                      /* Ende der Anwesenheitsabfrage     */
 form_dial(2,1,1,1,1,xdial,ydial,bdial,hdial); /* zugehender Kasten         */
 form_dial(3,1,1,1,1,xdial,ydial,bdial,hdial); /* Bereich herstellen        */
 if(exit_obj == OKAY) {                 /* Druckercodes abschicken          */
   prout();                             /* Ausgabe der Drucker-Codes        */
 }                                      /*                                  */
 deselect_obj(OKAY);                    /* nicht angewaehlt darstellen      */
 deselect_obj(CANCEL);                  /* nicht angewaehlt darstellen      */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       do_vwork                                                           */
/*--------------------------------------------------------------------------*/
VOID do_vwork()                         /* Initialisierung der Anwendung    */
{                                       /*                                  */
WORD i;                                 /* Zaehler                          */
 for(i=0; i<10; work_in[i++]=1);        /* workin-Array initialisieren      */
 work_in[10] = 2;                       /* Bildschirmkoordinaten            */
 v_opnvwk(work_in,&phys_handle,work_out); /* anmelden der Arbeitsstation    */
}                                       /* Ende der Funktion                */
/*--------------------------------------------------------------------------*/
/*       Event-Handler                                                      */
/*--------------------------------------------------------------------------*/
VOID h_event()                          /*                                  */
{                                       /*                                  */
       FOREVER                          /* Endlosschleife                   */
       {                                /*                                  */
        event = evnt_multi(MU_MESAG,    /* warten auf eine Nachricht        */
                 1,1,                   /* 1 Maustastendruck von Maustaste 1*/
                 1,                     /* fuer Taste unten                 */
                 0,0,0,0,0,             /*                                  */
                 0,0,0,0,0,             /*                                  */
                 msgbuff,               /* Adresse Buffer fuer Nachrichten  */
                 &ret,&ret,             /* nicht benutzte Funktionen        */
                 &ret,&ret,&ret,&ret);  /*                                  */
        if (event & MU_MESAG) {         /* Nachricht?                       */
          switch (msgbuff[0]) {         /* Menuewahl                        */
          case AC_OPEN:                 /* Desk-Accessory angewaehlt        */
              if (msgbuff[4] == menu_id) { /* eigenes Programm gewaehlt?    */
               wind_update(BEG_UPDATE); /* keine Benutzeraktivitaet zulassen*/
               do_vwork();              /* Arbeit initialisieren            */
               do_dialog();             /* Dialogbehandlung                 */
               v_clsvwk(phys_handle);   /* Arbeitsstation schliessen        */
               wind_update(END_UPDATE); /* Benutzeraktivitaet zulassen      */
              }                         /*                                  */
          default: break;               /*                                  */
          }                             /* Ende der switch-Anweisung        */
         }                              /* Ende der if-Anweisung            */
       }                                /* Schleifenende                    */
}                                       /* Ende der Funktion                */
/****************************************************************************/
/****                          Hauptprogramm                             ****/
/****************************************************************************/
main()                                  /*                                  */
{                                       /*                                  */
 appl_init();                           /* initialisieren der Applikation   */
 phys_handle = graf_handle(&bchar,&hchar,&bbox,&hbox); /* handle holen      */
 fix_objects();                         /* OBJEKT-Struktur initialisieren   */
 fix_tedinfo();                         /* TEDINFO-Struktur initialisieren  */
 tree = (LONG)rs_object;                /* Anfangsadresse der Baumstruktur  */
  menu_id = menu_register(gl_apid,MENU_NAME); /* Menue-Eintrag vornehmen    */
  select_obj(BIDIR);                    /* Bidirektionaler Druck            */
  select_obj(PICAON);                   /* Pica an                          */
  select_obj(EXPOFF);                   /* Expanded aus                     */
    do_obj(PROPON,DISABLED);            /* Taste Proport. AN nicht waehlbar */
    do_obj(PROPOFF,DISABLED);           /* Taste Proport. AUS nicht waehlbar*/
  select_obj(RESOFF);                   /* Drucker-Reset aus                */
  select_obj(FORMOFF);                  /* Seitenvorschub aus               */
  select_obj(STANDON);                  /* Standard an                      */
  select_obj(DOUBOFF);                  /* Doppeldruck aus                  */
  select_obj(EMPHOFF);                  /* Emphasizeddruck aus              */
    do_obj(ZEROON,DISABLED);            /* Taste Null AN nicht waehlbar     */
    do_obj(ZEROOFF,DISABLED);           /* Taste Null AUS nicht waehlbar    */
  select_obj(PRINTOFF);                 /* kein Testdruck                   */
    do_obj(NLQON,DISABLED);             /* Taste NLQ nicht waehlbar         */
  LLSET(OB_SPEC(SET),(LONG)str_set[p_set[2]]); /* Zeichensatz               */
  do_string(PAGE,p_page[3]);            /* Seitenlaenge                     */
  do_string(SKIP,p_skip[2]);            /* Perforations-Sprung              */
  do_string(LSPACE,p_lspace[2]);        /* Zeilenabstand                    */
  do_string(LMAR,p_lmar[2]);            /* linker Druckrand                 */
  do_string(RMAR,p_rmar[2]);            /* rechter Druckrand                */
  if( Cprnos() != NO )                  /* wenn Drucker vorhanden           */
    prout();                            /* Grundeinstellung initialisieren  */
  h_event();                            /* Event-Handler (Endlosschleife)   */
}                                       /* Ende main                        */
/**** ende ******************************************************************/
/****************************************************************************/
