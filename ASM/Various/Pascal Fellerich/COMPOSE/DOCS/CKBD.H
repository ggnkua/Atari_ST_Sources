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

/* Prototypes: */
typedef long cdecl interface(int opcode, ...);

/* deklarieren mit:   'interface *ckbd;' */


/* OpCodes: */
#define IDENTIFY    0
#define EXTKEY      1
#define COMPOSE     2
#define ALT_NNN     3
#define CKEYTBL     4
#define CBIOSKEYS   5

/* šbergabeparameter */
#define INQUIRE     -1
#define OFF         0
#define ON          1

#define DEC_MODE        0   /* bitmapped stuff */
#define MULTICHAR_MODE  2

#define ORDER_SENSITIVE 4



/*----- Funktionsmakros fr SETUP-Funktionen: */

#define Identify()					ckbd(IDENTIFY)
#define Extkey(mode)				ckbd(EXTKEY, mode)
#define Compose(mode)				ckbd(COMPOSE, mode)
#define Alt_nnn(mode)				ckbd(ALT_NNN, mode)
#define Ckeytbl(us, sh, cp, cc, na)	ckbd(CKEYTBL, (us), (sh), (cp), (cc), (na))
#define Cbioskeys(mode)				ckbd(CBIOSKEYS, mode)

/*
* Der COOKIE enth„lt *setup();
* C-Deklaration: cdecl long ckbd(int opcode, ...);
*
* Werte/Bezeichner fr opcode, ZUGEH™RIGE weitere Parameter:
*   0  IDENTIFY     gibt in d0 einen Zeiger auf einen C-type ASCIIstring zurck
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
*   4  CKEYTBL       verwaltet die Tastaturtabellen.
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
*                                   char    *name;
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

/* 2. Daten -> wie gehabt! */

