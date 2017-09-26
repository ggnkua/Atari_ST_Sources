#include <aes.h>
#include <vdi.h>
#include "STIP_RSC.H"

#define FSTR0 " STip"
#define FSTR1 " Datei"
#define FSTR2 "  Åber STip...   "
#define FSTR3 "-----------------"
#define FSTR4 "  Desk-Zubehôr 1 "
#define FSTR5 "  Desk-Zubehôr 2 "
#define FSTR6 "  Desk-Zubehôr 3 "
#define FSTR7 "  Desk-Zubehôr 4 "
#define FSTR8 "  Desk-Zubehôr 5 "
#define FSTR9 "  Desk-Zubehôr 6 "
#define FSTR10 "  Beenden  ^Q "

/****************************************/
/* OBJECT-tree                          */
/****************************************/


OBJECT rs_object[] =
{	    -1,      1,      5, G_IBOX    , NONE      , NORMAL  ,                    0X0L,      0,      0,     80,     25,
	     5,      2,      2, G_BOX     , NONE      , NORMAL  ,                 0X1100L,      0,      0,     80,    513,
	     1,      3,      4, G_IBOX    , NONE      , NORMAL  ,                    0X0L,      2,      0,     13,    769,
	     4,     -1,     -1, G_TITLE   , NONE      , NORMAL  , (long) FSTR0           ,      0,      0,      6,    769,
	     2,     -1,     -1, G_TITLE   , NONE      , NORMAL  , (long) FSTR1           ,      6,      0,      7,    769,
	     0,      6,     15, G_IBOX    , NONE      , NORMAL  ,                    0X0L,      0,    769,     80,     23,
	    15,      7,     14, G_BOX     , NONE      , NORMAL  ,               0XFF1100L,      2,      0,     17,      8,
	     8,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR2           ,      0,      0,     17,      1,
	     9,     -1,     -1, G_STRING  , NONE      , DISABLED, (long) FSTR3           ,      0,      1,     17,      1,
	    10,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR4           ,      0,      2,     17,      1,
	    11,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR5           ,      0,      3,     17,      1,
	    12,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR6           ,      0,      4,     17,      1,
	    13,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR7           ,      0,      5,     17,      1,
	    14,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR8           ,      0,      6,     17,      1,
	     6,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR9           ,      0,      7,     17,      1,
	     5,     16,     16, G_BOX     , NONE      , NORMAL  ,               0XFF1100L,      8,      0,     14,      1,
	    15,     -1,     -1, G_STRING  , LASTOB    , NORMAL  , (long) FSTR10          ,      0,      0,     14,      1
};

/****************************************/
/* TREE-Index                           */
/****************************************/


OBJECT *TREE[] =
{	(OBJECT *) &rs_object[0]
};
/****************************************
 *	STD_FUNC.R2C:						*
 *	Standard-Funktionen fÅr RSH-Files	*
 ****************************************/

/*------------------------------------------------------------------*
 * Funktion : objc_init												*
 * Aufgabe	: Paût die Objektdarstellung der Auflîsung an			*
 * Ergebnis	: ----													*
 * Parameter: ----													*
 *------------------------------------------------------------------*/

void objc_init( void )
{
	int i;
	
	for(i = 0; i < NUM_OBS; i++)
	{
		rsrc_obfix(rs_object,i);
	}
}

