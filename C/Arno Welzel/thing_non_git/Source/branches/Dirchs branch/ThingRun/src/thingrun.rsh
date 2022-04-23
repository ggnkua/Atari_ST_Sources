/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "THINGRUN.H"

#if !defined(WHITEBAK)
#define WHITEBAK    0x0040
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0080
#endif

#define FLAGS9  0x0200
#define FLAGS10 0x0400
#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000

TEDINFO rs_tedinfo[] =
{ "AAAAAAAA.AAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 13, 1
};

BYTE *rs_frstr[] =
{ "[0][ThingRun 1.11|Copyright \275 1995 Arno Welzel|Copyright \275 1996-98 T. Binder][  OK  ]",
  "[3][Es steht nicht mehr gen\201gend|Arbeitsspeicher zur Verf\201gung!| |Not enough memory!][Abbruch / Cancel]",
  "Programm beendet, Taste dr\201cken / Program terminated, press any key"
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 DESKAPP ****************************************************/
        -1,       -1,       -1, G_BOXTEXT ,   /* Object 0  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x0000, 0x0022, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 DESKAPP  */
};
