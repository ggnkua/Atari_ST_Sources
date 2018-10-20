/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "FGRAPH.H"

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
{ "123456",
  "______",
  "999999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -2, 7, 7,
  "123",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 4, 1
};

USERBLK rs_userblk[] =
{ 0L, 0x00000000
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 HISTOGRAMM ****************************************************/
        -1, FRAME           , MAXIMUM         , G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0022, 0x000B,
  DOWN            , GRAPH           , GRAPH           , G_BOX             ,   /* Object 1 FRAME */
  FLAGS9|FLAGS10, SELECTED, (LONG)0x00FF1180L,
  0x0001, 0x0003, 0x0020, 0x0007,
  FRAME           ,       -1,       -1, G_USERDEF         ,   /* Object 2 GRAPH */
  NONE, NORMAL, (LONG)&rs_userblk[0],
  0x0000, 0x0000, 0x001E, 0x0006,
  UP              ,       -1,       -1, G_BOXCHAR         ,   /* Object 3 DOWN */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG) ((LONG)'\002' << 24)|0x00FF1100L,
  0x0007, 0x0001, 0x0002, 0x0001,
  LINE            ,       -1,       -1, G_BOXCHAR         ,   /* Object 4 UP */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG) ((LONG)'\001' << 24)|0x00FF1100L,
  0x0012, 0x0001, 0x0002, 0x0001,
         6,       -1,       -1, G_FTEXT           ,   /* Object 5 LINE */
  FLAGS9, NORMAL, (LONG)&rs_tedinfo[0],
  0x000A, 0x0001, 0x0007, 0x0001,
         7,       -1,       -1, G_STRING          ,   /* Object 6  */
  NONE, NORMAL, (LONG)"Zeile",
  0x0001, 0x0001, 0x0005, 0x0001,
  MAXIMUM         ,       -1,       -1, G_STRING          ,   /* Object 7  */
  NONE, NORMAL, (LONG)"Max.:",
  0x0016, 0x0001, 0x0005, 0x0001,
         0,       -1,       -1, G_TEXT            ,   /* Object 8 MAXIMUM */
  LASTOB|FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x001C, 0x0001, 0x0003, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 HISTOGRAMM       */
};
