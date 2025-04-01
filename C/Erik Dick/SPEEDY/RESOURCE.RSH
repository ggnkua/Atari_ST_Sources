#include <aes.h>
#include <vdi.h>
#include "RESOURCE.H"


/****************************************/
/* TEDINFO-Strings                      */
/****************************************/

char	TED0_s[36] = "Demoprogramm zum Arbeit mit Speedo.";
#define TED0_t ""
#define TED0_v ""
#define FSTR0 " Speedy"
#define FSTR1 " Datei"
#define FSTR2 "  šber Speedy...   "
#define FSTR3 "-------------------"
#define FSTR4 "  Desk Accessory 1 "
#define FSTR5 "  Desk Accessory 2 "
#define FSTR6 "  Desk Accessory 3 "
#define FSTR7 "  Desk Accessory 4 "
#define FSTR8 "  Desk Accessory 5 "
#define FSTR9 "  Desk Accessory 6 "
#define FSTR10 "  Drucken... ^D "
#define FSTR11 "----------------"
#define FSTR12 "  Ende       ^Q "
#define FSTR13 "OK"
#define FSTR14 "šber Speedy"
#define FSTR15 "Zeigt Speedo-Zeichens„tze mit verschiedenen"
#define FSTR16 "Einstellungen an."
#define FSTR17 "(C) 1993 ST Computer, Maxon Computer GmbH"
#define FSTR18 "von Erik Dick"
#define FSTR19 "Abbruch"
#define FSTR20 "Drucken"
#define FSTR21 " Drucken "
#define FSTR22 "Soll auf den Standarddrucker (Device 21)"
#define FSTR23 "ausgegeben werden?"

/****************************************/
/* TEDINFO-structures                   */
/****************************************/


TEDINFO rs_tedinfo[] =
{	TED0_s, TED0_t, TED0_v, SMALL , 0x0   , TE_LEFT, 0x1180, 0x0   ,0x0   , 0x24  , 0x1   
};

/****************************************/
/* OBJECT-tree                          */
/****************************************/


OBJECT rs_object[] =
{	    -1,      1,      5, G_IBOX    , NONE      , NORMAL  ,                    0X0L,      0,      0,     80,     25,
	     5,      2,      2, G_BOX     , NONE      , NORMAL  ,                 0X1100L,      0,      0,     80,    513,
	     1,      3,      4, G_IBOX    , NONE      , NORMAL  ,                    0X0L,      2,      0,     15,    769,
	     4,     -1,     -1, G_TITLE   , NONE      , NORMAL  , (long) FSTR0           ,      0,      0,      8,    769,
	     2,     -1,     -1, G_TITLE   , NONE      , NORMAL  , (long) FSTR1           ,      8,      0,      7,    769,
	     0,      6,     15, G_IBOX    , NONE      , NORMAL  ,                    0X0L,      0,    769,     80,     23,
	    15,      7,     14, G_BOX     , NONE      , NORMAL  ,               0XFF1100L,      2,      0,     19,      8,
	     8,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR2           ,      0,      0,     19,      1,
	     9,     -1,     -1, G_STRING  , NONE      , DISABLED, (long) FSTR3           ,      0,      1,     19,      1,
	    10,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR4           ,      0,      2,     19,      1,
	    11,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR5           ,      0,      3,     19,      1,
	    12,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR6           ,      0,      4,     19,      1,
	    13,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR7           ,      0,      5,     19,      1,
	    14,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR8           ,      0,      6,     19,      1,
	     6,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR9           ,      0,      7,     19,      1,
	     5,     16,     18, G_BOX     , NONE      , NORMAL  ,               0XFF1100L,     10,      0,     16,      3,
	    17,     -1,     -1, G_STRING  , NONE      , DISABLED, (long) FSTR10          ,      0,      0,     16,      1,
	    18,     -1,     -1, G_STRING  , NONE      , DISABLED, (long) FSTR11          ,      0,      1,     16,      1,
	    15,     -1,     -1, G_STRING  , LASTOB    , NORMAL  , (long) FSTR12          ,      0,      2,     16,      1,
	    -1,      1,      8, G_BOX     , NONE      , OUTLINED,                0X21100L,      0,      0,     47,     14,
	     2,     -1,     -1, G_BUTTON  , 0x7       , NORMAL  , (long) FSTR13          ,     17,     12,     10,      1,
	     3,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR14          ,      2,      1,     17,      1,
	     4,     -1,     -1, G_TEXT    , NONE      , NORMAL  , (long) &rs_tedinfo[0]  ,      2,      2,    538,      1,
	     5,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR15          ,      2,      8,     43,      1,
	     6,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR16          ,      2,      9,     17,      1,
	     7,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR17          ,      2,      6,     41,      1,
	     8,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR18          ,      2,      4,     16,      1,
	     0,     -1,     -1, G_BOX     , LASTOB    , NORMAL  ,                 0X1171L,      2,      2,     43,    256,
	    -1,      1,      6, G_BOX     , NONE      , OUTLINED,                0X21100L,      0,      0,     45,      9,
	     2,     -1,     -1, G_BUTTON  , 0x5       , NORMAL  , (long) FSTR19          ,     24,   2054,     10,   1025,
	     3,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR20          ,      2,      1,      7,      1,
	     4,     -1,     -1, G_BUTTON  , 0x7       , NORMAL  , (long) FSTR21          ,     11,   2054,      9,   1025,
	     5,     -1,     -1, G_BOX     , NONE      , NORMAL  ,                 0X1171L,      2,      2,     41,    256,
	     6,     -1,     -1, G_STRING  , NONE      , NORMAL  , (long) FSTR22          ,      2,      3,     41,      1,
	     0,     -1,     -1, G_STRING  , LASTOB    , NORMAL  , (long) FSTR23          ,      2,      4,     41,      1
};

/****************************************/
/* TREE-Index                           */
/****************************************/


OBJECT *TREE[] =
{	(OBJECT *) &rs_object[0],
	(OBJECT *) &rs_object[19],
	(OBJECT *) &rs_object[28]
};
/****************************************
 *	STD_FUNC.R2C:						*
 *	Standard-Funktionen fr RSH-Files	*
 ****************************************/

/*------------------------------------------------------------------*
 * Funktion : objc_init												*
 * Aufgabe	: Pažt die Objektdarstellung der Aufl”sung an			*
 * Ergebnis	: ----													*
 * Parameter: Erster Dialog nach den Mens          				*
 *------------------------------------------------------------------*/

/********************************************************************/
void fix_object_coord(int *coord,int this_size, int design_size)
{
	int px;

	px = (*coord & 0xff) * this_size;
	px += (*coord >> 8) * this_size/design_size;
		
	*coord = px;
}
/********************************************************************/
void objc_init( int start_of_dialogs )
{
	int i,dum,cw,ch;
	OBJECT *this_ob;
	
	graf_handle(&cw,&ch,&dum,&dum);
	for(i = 0; i < NUM_OBS; i++)
	{
		this_ob = &rs_object[i];

		if (this_ob >= TREE[start_of_dialogs])
		{		
			fix_object_coord(&(this_ob->ob_x),cw,8); 
			fix_object_coord(&(this_ob->ob_y),ch,16); 
			fix_object_coord(&(this_ob->ob_width),cw,8); 
			fix_object_coord(&(this_ob->ob_height),ch,16); 
		}
		else
			rsrc_obfix(this_ob,0);
	}
}
/********************************************************************/
