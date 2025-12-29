/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "GEMDUMP.H"

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
{ "V1.0 15.4.1994",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 15, 1,
  "(c) 1994 by TMMW Morus Walter",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 30, 1,
  "______________________________________                    ",
  "______________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 39, 39
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 SCREENDUMP ****************************************************/
        -1,        1, CANCEL  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0028, 0x000E,
         2,       -1,       -1, G_TEXT    ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x0000, 0x0028, 0x0001,
         3,       -1,       -1, G_BUTTON  ,   /* Object 2  */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)"xImage Screendump",
  0x0002, 0x0001, 0x0024, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0000, 0x0002, 0x0028, 0x0001,
  SELECT  ,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Bildnamen:",
  0x0002, 0x0003, 0x000A, 0x0001,
  PATH    ,       -1,       -1, G_BOX     ,   /* Object 5 SELECT */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)0x00011181L,
  0x0024, 0x0003, 0x0002, 0x0001,
  RESET   ,       -1,       -1, G_FTEXT   ,   /* Object 6 PATH */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0001, 0x0004, 0x0026, 0x0001,
         8,       -1,       -1, G_BOX     ,   /* Object 7 RESET */
  SELECTABLE, NORMAL, (LONG)0x00011181L,
  0x0002, 0x0006, 0x0002, 0x0001,
  XIMG    ,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"Bildnummer zur\201cksetzen",
  0x0005, 0x0006, 0x0017, 0x0001,
        10,       -1,       -1, G_BOX     ,   /* Object 9 XIMG */
  SELECTABLE, NORMAL, (LONG)0x00011181L,
  0x0002, 0x0007, 0x0002, 0x0001,
  ALTHELP ,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"X-Image schreiben",
  0x0005, 0x0007, 0x0011, 0x0001,
        12,       -1,       -1, G_BOX     ,   /* Object 11 ALTHELP */
  SELECTABLE, NORMAL, (LONG)0x00011181L,
  0x0002, 0x0008, 0x0002, 0x0001,
  WINDOW  ,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"ALT/HELP abfragen",
  0x0005, 0x0008, 0x0011, 0x0001,
  DRAG    ,       -1,       -1, G_BUTTON  ,   /* Object 13 WINDOW */
  SELECTABLE|EXIT, NORMAL, (LONG)"Fenster",
  0x0003, 0x000A, 0x000A, 0x0001,
  SCREEN  ,       -1,       -1, G_BUTTON  ,   /* Object 14 DRAG */
  SELECTABLE|EXIT, NORMAL, (LONG)"Rahmen",
  0x000F, 0x000A, 0x000A, 0x0001,
  SAVE    ,       -1,       -1, G_BUTTON  ,   /* Object 15 SCREEN */
  SELECTABLE|EXIT, NORMAL, (LONG)"alles",
  0x001B, 0x000A, 0x000A, 0x0001,
  SET     ,       -1,       -1, G_BUTTON  ,   /* Object 16 SAVE */
  SELECTABLE|EXIT, NORMAL, (LONG)"Sichern",
  0x0003, 0x000C, 0x000A, 0x0001,
  CANCEL  ,       -1,       -1, G_BUTTON  ,   /* Object 17 SET */
  SELECTABLE|EXIT, NORMAL, (LONG)"Setzen",
  0x000F, 0x000C, 0x000A, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 18 CANCEL */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)"Abbruch",
  0x001B, 0x000C, 0x000A, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 SCREENDUMP */
};
