/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "HISTOGRM.H"

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

USERBLK rs_userblk[] =
{ 0L, 0x00000000
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 HISTOGRAMM ****************************************************/
        -1, FRAME           , GO              , G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0022, 0x000B,
  GO              , GRAPH           , GRAPH           , G_BOX             ,   /* Object 1 FRAME */
  FLAGS9|FLAGS10, SELECTED, (LONG)0x00FF1180L,
  0x0001, 0x0001, 0x0020, 0x0007,
  FRAME           ,       -1,       -1, G_USERDEF         ,   /* Object 2 GRAPH */
  NONE, NORMAL, (LONG)&rs_userblk[0],
  0x0000, 0x0000, 0x001E, 0x0006,
         0,       -1,       -1, G_BUTTON          ,   /* Object 3 GO */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"Aktualisieren",
  0x0012, 0x0009, 0x000E, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 HISTOGRAMM       */
};
