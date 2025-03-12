#include "atarierr.h"
#include "portab.h"


/* Desktop-Hintergrundfenster */

#define DESK	0

#ifndef NULL
#define NULL	((void*) 0L)
#endif


/* Macros */

#define min(a, b)		((a) < (b) ? (a) : (b))
#define max(a, b)		((a) > (b) ? (a) : (b))


/* Datenstruktur fÅr OEP-Objekt */

typedef struct
{
	LONG	id;
	UWORD	date;
	UWORD	time;
	LONG	systime;
	LONG	cid;
	BYTE	crname[32];
	BYTE	crfile[10];
	WORD	crid;
	BYTE	string[16];
} DATAINFO;


/*
*	Funktionsdeklarationen
*/

VOID main(VOID);
VOID init(VOID);
VOID ende(VOID);
VOID menu(WORD msg[]);
VOID messages(WORD msg[]);
VOID redraw(WORD handle, WORD x, WORD y, WORD w, WORD h);
VOID m_button(WORD clicks, WORD mx, WORD my);
VOID init_change(DATAINFO *datainfo);
VOID make_dd(WORD target_apid, WORD winid, WORD mx, WORD my);
VOID init_datainfo(DATAINFO *datainfo);
VOID fill_datainfo(DATAINFO *datainfo);
