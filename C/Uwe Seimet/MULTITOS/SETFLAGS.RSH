/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "SETFLAGS.H"

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
{ "1993 by Uwe Seimet",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 19, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 DIALOG ****************************************************/
        -1,        1,       13, G_BOX     ,   /* Object 0  */
  FLAGS10, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x002F, 0x0015,
         2,       -1,       -1, G_BUTTON  ,   /* Object 1  */
  SELECTABLE, SELECTED|OUTLINED, (LONG)"Programmheader manipulieren",
  0x0009, 0x0001, 0x041D, 0x0002,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0011, 0x0004, 0x040D, 0x0600,
  FILENAME,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Dateiname:",
  0x000C, 0x0006, 0x000A, 0x0001,
  FASTLOAD,       -1,       -1, G_STRING  ,   /* Object 4 FILENAME */
  NONE, NORMAL, (LONG)"FILENAME.EXT",
  0x0017, 0x0006, 0x000C, 0x0001,
  TTMEM   ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 5 FASTLOAD */
  SELECTABLE|FLAGS9, NORMAL, (LONG)"Fast-Load-Flag setzen",
  0x0405, 0x0009, 0x0024, 0x0001,
  TTRAM   ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 6 TTMEM */
  SELECTABLE|FLAGS9, NORMAL, (LONG)"Programm l\204uft im alternativen RAM",
  0x0405, 0x000B, 0x0024, 0x0001,
  PRIVATE ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 7 TTRAM */
  SELECTABLE|FLAGS9, NORMAL, (LONG)"Speicher aus dem alternativen RAM",
  0x0405, 0x000D, 0x0024, 0x0001,
  GLOBAL  ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 8 PRIVATE */
  SELECTABLE|RBUTTON|FLAGS9, NORMAL, (LONG)"PRIVATE",
  0x0002, 0x0010, 0x000A, 0x0001,
  SUPER   ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 9 GLOBAL */
  SELECTABLE|RBUTTON|FLAGS9, NORMAL, (LONG)"GLOBAL",
  0x000D, 0x0010, 0x000A, 0x0001,
  READABLE,       -1,       -1, G_BUTTON  |0x0100,   /* Object 10 SUPER */
  SELECTABLE|RBUTTON|FLAGS9, NORMAL, (LONG)"SUPER",
  0x0018, 0x0010, 0x000A, 0x0001,
  OK      ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 11 READABLE */
  SELECTABLE|RBUTTON|FLAGS9, NORMAL, (LONG)"READABLE",
  0x0023, 0x0010, 0x000A, 0x0001,
        13,       -1,       -1, G_BUTTON  |0x0200,   /* Object 12 OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x000E, 0x0013, 0x0009, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x0200,   /* Object 13  */
  SELECTABLE|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"Abbruch",
  0x0418, 0x0013, 0x0009, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 DIALOG   */
};
