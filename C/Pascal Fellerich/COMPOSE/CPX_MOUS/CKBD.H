/************************************************************************/
/*                                                                      */
/*  CKBD.H: Composed Characters KeyBoard Driver                         */
/*                                                                      */
/*  Interface def's                                                     */
/*                                                                      */
/*                                                                      */
/*                                                                      */
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
#define DEADKEY		6
#define MOUSE_CFG	7

/* šbergabeparameter */
#define INQUIRE     -1
#define OFF         0
#define ON          1
#define SET			2

#define DEC_MODE        0   /* bitmapped stuff */
#define MULTICHAR_MODE  2
#define ORDER_SENSITIVE 4

/*-- standard defs -----------------------------------------------------*/
#define TRUE    1
#define FALSE   0
#define MESSAGE -1
#define EXTERN extern


/*----- Funktionsmakros fr SETUP-Funktionen: */

/* Prototypes: */
typedef long cdecl interface(int opcode, ...);

#define Identify()					(char*)ckbd(IDENTIFY)
#define Extkey(mode)				ckbd(EXTKEY, (int)(mode))
#define Compose(mode)				ckbd(COMPOSE, (int)(mode))
#define Alt_nnn(mode)				ckbd(ALT_NNN, (int)(mode))
#define Ckeytbl(us, sh, cp, cc, na)	ckbd(CKEYTBL, (us), (sh), (cp), (cc), (na))
#define Cbioskeys(mode)				ckbd(CBIOSKEYS, mode)
#define Deadkey(mode, ptr)			ckbd(DEADKEY, (int)mode, (char *)(ptr))
#define Mouse_cfg(mode, ptr)		ckbd(MOUSE_CFG, (int)mode, (MSPEEDER_SETUP *)(ptr))

/*
*
* Funktionsdeklarationen fr SETUP-Funktionen:
*
* Der COOKIE enth„lt *setup();
* C-Deklaration: cdecl long setup(int opcode, ...);
*
* Werte/Bezeichner fr opcode, ZUGEH™RIGE weitere Parameter:
*   0  IDENTIFY     gibt in d0 einen Zeiger auf einen C-type ASCIIstring zurck
*
*   1  EXTKEY       schaltet EXTKEY-Modus ein/aus bzw. fragt akt. Status ab
*         long setup(EXTKEY, int mode);
*         mode:     -1 (INQUIRE), 0 (OFF), 1 (ON)
*         return:   vorheriger Wert
*
*   2  COMPOSE      schaltet COMPOSE-Modus ein/aus bzw fragt akt. Status ab
*         long setup(COMPOSE, int mode);
*         mode:     -1 (INQUIRE)
*                   >=0: BITMAPPED:  0/1
*                       bit #0:     OFF/ON
*                       bit #1:     DEC/MULTICHAR MODE
*                       bit #2:     ORDER SENSITIVE NO/YES
*         return:   vorheriger Wert
*
*   3  ALT_NNN      verwaltet die MSDOS-ALT-ASCII Funktion.
*         long setup(ALT_NNN, int mode);
*         mode:     -1 (INQUIRE), 0 (OFF), 1 (ON)
*         return:   vorheriger Wert
*
*   4  CKEYTBL      verwaltet die Tastaturtabellen.
*         long setup(CKEYTBL, char *unshift, char *shift, char *caps,
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
*                   dieser Wert intern nicht ver„ndert.
*                   Die vier Tabellen werden in einen internen Puffer kopiert,
*                   der Aufrufer braucht die Tabellen also nicht selbst im
*                   Speicher zu behalten.
*
*   5 CBIOSKEYS     setzt die Originaltabellen wieder ein oder schaltet
*                   zwischen den Tabellen hin und her
*         int setup(CBIOSKEYS, switch);
*         switch:   -1  INQUIRE  (returns XKEYTAB - adr only)
*                   >=0: bitmapped.
*                   bit #0: keyboard translation table - SET: use loaded -
*                   bit #1: compose tables             - SET: use loaded -
*         return:  last setup value.
*
*
*   6 DEADKEY       kontrolliert die Toten Tasten...
*         long setup(DEADKEY, short mode, char *deadkeys)
*         mode:     -1 (INQUIRE), 0 (OFF), 1 (ON), 2 (SETUP)
*         return:   0/1 fr OFF/ON
*					Wenn char* deadkeys gltig ist bei INQUIRE werden
*					die Deadkeys in diesen String geschrieben.
*
*
* Mouse speeder config
* --------------------
*
*   7 MOUSE_CFG:    stellt die Mausbeschleuniger-Parameter ein
*         int setup(MOUSE_CFG, int mode, MSPEEDER_SETUP *mdata);
*         mode: WORD,
*               -1: INQUIRE, fill out MSPEEDER_SETUP structure if ptr set!
*                0: OFF - deactivate Speeder
*                1: ON  - activate Speeder
*                2: SET - install new params
*         return: zeiger auf MSPEEDER_SETUP-Struktur mit den aktiven Daten
*
*         Kontrollstruktur:
*         typedef struct {
*             union {
*                 unsigned resvd    :13;
*                 unsigned lefthand :1;       /* Button map change!?        */
*                 unsigned unused   :1;       /* old feature, removed...    */
*                 unsigned activity :1;       /* Speeder ON/OFF             */
*             } switches;
*             short       polynomial[4];      /* speeder polynomial         */
*             short       rotation;           /* rotation in degrees        */
*             short       ratio;              /* X:Y ratio * 256!           */
*             short       mouse_rez;          /* M.resolution in dpi (130)  */
*             short       screen_rez;         /* screen rez in dpi   ( 72)  */
*         } MSPEEDER_SETUP;
*
*         Die Polynomfaktoren und X-Y-Ratio Werte sind (int)(float_val*256)
*
*/

typedef struct {
	char	primary,
			secondary,
			composed;
	char	reserved;
} Comptab;

typedef struct {
	char    *unshift;
	char    *shift;
	char    *caps;
	Comptab *compose;
	char    *name;
} XKEYTAB;

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

/* FileFormat fr CKB Tabellen: */
/* 1. header: */
typedef struct {
	long	magic;				/* 'CKBD' */
	char	name[12];
	int		unshift_offset,
			shift_offset,
			caps_offset,
			compose_offset;
	int		compose_setup;		/* nur fr's AUTOLOAD */
} CKB_FILE_HEADER;


/* prototypes from polyfit.c*/

#define PDEGREE 3						/* polynom degree */
#define MAX(a,b)		(((a)>(b)) ? (a) : (b))
#define MIN(a,b)		(((a)<(b)) ? (a) : (b))

void init_uvdi(void);
void exit_uvdi(void);
void read_editfield(int *);
void read_polyfactors(int *polynomial);
void set_editfield(int *polyfactors, int force);
WORD cdecl draw_polynomial(PARMBLK *pb);


/* defines */
#define UM_PER_INCH 20000L			/* mikrometer per inch (kompromiž!)*/

/* eof */

