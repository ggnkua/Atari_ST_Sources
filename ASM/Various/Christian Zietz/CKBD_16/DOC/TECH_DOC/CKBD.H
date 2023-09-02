/************************************************************************/
/*                                                                      */
/*  CKBD.H: Composed Characters KeyBoard Driver                         */
/*                                                                      */
/*  Interface def's                                                     */
/*                                                                      */
/*                                                                      */
/*  16-mar-1994, Pascal Fellerich                                       */
/************************************************************************/


/* Cookie - Kennung */
#define CKBD  0x434B4244L

/* OpCodes: */
#define IDENTIFY    0
#define EXTKEY      1
#define COMPOSE     2
#define ALT_NNN     3
#define CKEYTBL     4
#define CBIOSKEYS   5
#define DEADKEY     6
#define MOUSE_CFG   7

/* 'mode' öbergabeparameter */
#define INQUIRE     -1
#define OFF         0
#define ON          1
#define SET         2

#define DEC_MODE        0   /* bitmapped stuff */
#define MULTICHAR_MODE  2
#define ORDER_SENSITIVE 4

#define KBD_MAP		1
#define COMPOSE_MAP	2


/*---------------------- typedefs: ----------------------------*/

/* cookie jar interface call */
typedef long cdecl interface(int opcode, ...);

/* im Hauptprogramm folgenden Zeiger deklarieren und initialisieren */
/* interface    *ckbd;    */

/* ein Compose-Tabelleneintrag */
typedef struct {
    char    primary,
            secondary,
            composed;
    char    reserved;
} Comptab_entry;

/* extended keytab */
typedef struct {
    char            *unshift;
    char            *shift;
    char            *caps;
    Comptab_entry   *compose;
    char            *name;
} XKEYTAB;

/* Mouse speeder control struct */
typedef struct {
    struct {
        unsigned resvd    :13;
        unsigned lefthand :1;       /* Button map change!?        */
        unsigned unused   :1;       /* old feature, removed...    */
        unsigned activity :1;       /* Speeder ON/OFF             */
    } switches;
    short       polynomial[4];      /* speeder polynomial         */
    short       rotation;           /* rotation in degrees        */
    short       ratio;              /* X:Y ratio * 256!           */
    short       mouse_rez;          /* M.resolution in dpi (100)  */
    short       screen_rez;         /* screen rez in dpi   ( 72)  */
} MSPEEDER_SETUP;


/*----- Funktionsmakros fÅr SETUP-Funktionen: */
#define Identify()                  (char*)ckbd(IDENTIFY)
#define Extkey(mode)                ckbd(EXTKEY, (int)(mode))
#define Compose(mode)               ckbd(COMPOSE, (int)(mode))
#define Alt_nnn(mode)               ckbd(ALT_NNN, (int)(mode))
#define Ckeytbl(us, sh, cp, cc, na) ckbd(CKEYTBL, (us), (sh), (cp), (cc), (na))
#define Cbioskeys(mode)             ckbd(CBIOSKEYS, mode)
#define Deadkey(mode, ptr)          ckbd(DEADKEY, (int)mode, (char *)(ptr))
#define Mouse_cfg(mode, ptr)        ckbd(MOUSE_CFG, (int)mode, (MSPEEDER_SETUP *)mdata);

/*
*
* Funktionsdeklarationen fÅr SETUP-Funktionen:
*
* Der COOKIE enthÑlt *ckbd();
* C-Deklaration: cdecl long ckbd(int opcode, ...);
*
* Werte/Bezeichner fÅr opcode, ZUGEHôRIGE weitere Parameter:
*   0  IDENTIFY     gibt in d0 einen Zeiger auf einen C-type ASCIIstring zurÅck
*
*   1  EXTKEY       schaltet EXTKEY-Modus ein/aus bzw. fragt akt. Status ab
*         long ckbd(EXTKEY, int mode);
*         mode:     -1 (INQUIRE), 0 (OFF), 1 (ON)
*         return:   vorheriger Wert
*
*   2  COMPOSE      schaltet COMPOSE-Modus ein/aus bzw fragt akt. Status ab
*         long ckbd(COMPOSE, int mode);
*         mode:     -1 (INQUIRE)
*                   >=0: BITMAPPED:  0/1
*                       bit #0:     OFF/ON
*                       bit #1:     DEC/MULTICHAR MODE
*                       bit #2:     ORDER SENSITIVE NO/YES
*         return:   vorheriger Wert
*
*   3  ALT_NNN      verwaltet die MSDOS-ALT-ASCII Funktion.
*         long ckbd(ALT_NNN, int mode);
*         mode:     -1 (INQUIRE), 0 (OFF), 1 (ON)
*         return:   vorheriger Wert
*
*   4  CKEYTBL      verwaltet die Tastaturtabellen.
*         long ckbd(CKEYTBL, char *unshift, char *shift, char *caps,
*                                                       char *compose );
*         unshift, shift, caps: Zeiger auf die entsprechenden Tabellen
*                   (siehe XBIOS Keytbl !!!!)
*         compose:  Zeiger auf die Compose-Tabelle.
*         return:   Zeiger auf  struct {
*                                   char    *unshift;
*                                   char    *shift;
*                                   char    *caps;
*                                   comptab *compose;
*                               } XKEYTAB;
*                   darin ist comptab *:
*                                   struct {
*                                       char    primary;
*                                       char    secondary;
*                                       char    composed;
*                                       char    flags;
*                                   } comptab[];
*         Bemerkung: wenn ein Zeiger den Wert 0 oder -1 besitzt, dann wird
*                   dieser Wert intern nicht verÑndert.
*                   Die vier Tabellen werden in einen internen Puffer kopiert,
*                   der Aufrufer braucht die Tabellen also nicht selbst im
*                   Speicher zu behalten.
*
*   5 CBIOSKEYS     setzt die Originaltabellen wieder ein oder schaltet
*                   zwischen den Tabellen hin und her
*         int ckbd(CBIOSKEYS, switch);
*         switch:   -1  INQUIRE
*                   >=0: bitmapped.
*                   bit #0: keyboard translation table - SET: use loaded -
*                   bit #1: compose tables             - SET: use loaded -
*         return:  last setup value.
*
*
*   6 DEADKEY       kontrolliert die Toten Tasten...
*         long ckbd(DEADKEY, short mode, char *deadkeys)
*         mode:     -1 (INQUIRE), 0 (OFF), 1 (ON), 2 (SETUP)
*         return:   0/1 fÅr OFF/ON
*                   Wenn char* deadkeys gÅltig ist bei INQUIRE werden
*                   die Deadkeys in diesen String geschrieben.
*
*
* Mouse speeder config
* --------------------
*
*   7 MOUSE_CFG:    stellt die Mausbeschleuniger-Parameter ein
*         int ckbd(MOUSE_CFG, int mode, MSPEEDER_SETUP *mdata);
*         mode: WORD,
*               -1: INQUIRE, fill out MSPEEDER_SETUP structure if ptr set!
*                0: OFF - deactivate Speeder
*                1: ON  - activate Speeder
*                2: SET - install new params
*         return: zeiger auf MSPEEDER_SETUP-Struktur mit den aktiven Daten
*
*         Kontrollstruktur:
*         typedef struct {
*             struct {
*                 unsigned resvd    :13;
*                 unsigned lefthand :1;       /* Button map change!?        */
*                 unsigned unused   :1;       /* old feature, removed...    */
*                 unsigned activity :1;       /* Speeder ON/OFF             */
*             } switches;
*             short       polynomial[4];      /* speeder polynomial         */
*             short       rotation;           /* rotation in degrees        */
*             short       ratio;              /* X:Y ratio * 256!           */
*             short       mouse_rez;          /* M.resolution in dpi (100)  */
*             short       screen_rez;         /* screen rez in dpi   ( 72)  */
*         } MSPEEDER_SETUP;
*
*         Die Polynomfaktoren und X-Y-Ratio Werte sind (int)(float_val*256)
*
*/

/* eof */

