/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "UMFANG.H"

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
{ "\0",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1149, 0, -2, 1, 1,
  "-123",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -2, 5, 1,
  "\004",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -2, 2, 1,
  "\003",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -2, 2, 1,
  "WEISS GRENZE",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 13, 1,
  "\0",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1149, 0, -2, 1, 1,
  "-123",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -2, 5, 1,
  "\004",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -2, 2, 1,
  "\003",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -2, 2, 1,
  "SCHWARZ GRENZE",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 15, 1,
  "RESET",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -2, 6, 1
};

WORD RSBB0DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0180, 0x03C0, 0x07E0, 0x07E0, 
  0x03C0, 0x0180, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

WORD RSBB1DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0180, 0x03C0, 0x07E0, 0x07E0, 
  0x03C0, 0x0180, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

WORD RSBB2DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0180, 0x03C0, 0x07E0, 0x07E0, 
  0x03C0, 0x0180, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,   2,  16,   0,   0, 0x0001,
  RSBB1DATA,   2,  16,   0,   0, 0x0000,
  RSBB2DATA,   2,  16,   0,   0, 0x0009
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 SW_KONVERT ****************************************************/
        -1, GO              ,       15, G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0028, 0x0006,
  BAR             ,       -1,       -1, G_BUTTON          ,   /* Object 1 GO */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Ausf\201hren",
  0x001A, 0x0005, 0x000A, 0x0001,
  LEFT            , SLIDE           , SLIDE           , G_BOXTEXT         ,   /* Object 2 BAR */
  TOUCHEXIT|FLAGS9|FLAGS10, SELECTED, (LONG)&rs_tedinfo[0],
  0x0004, 0x0003, 0x0020, 0x0001,
  BAR             ,       -1,       -1, G_BOXTEXT         ,   /* Object 3 SLIDE */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x0000, 0x0000, 0x0005, 0x0001,
  RIGHT           ,       -1,       -1, G_BOXTEXT         ,   /* Object 4 LEFT */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[2],
  0x0001, 0x0003, 0x0002, 0x0001,
         6,       -1,       -1, G_BOXTEXT         ,   /* Object 5 RIGHT */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[3],
  0x0025, 0x0003, 0x0002, 0x0001,
  BAR1            ,       -1,       -1, G_TEXT            ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0004, 0x0004, 0x0009, 0x0001,
  LEFT1           , SLIDE1          , SLIDE1          , G_BOXTEXT         ,   /* Object 7 BAR1 */
  TOUCHEXIT|FLAGS9|FLAGS10, SELECTED, (LONG)&rs_tedinfo[5],
  0x0004, 0x0001, 0x0020, 0x0001,
  BAR1            ,       -1,       -1, G_BOXTEXT         ,   /* Object 8 SLIDE1 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[6],
  0x0000, 0x0000, 0x0005, 0x0001,
  RIGHT1          ,       -1,       -1, G_BOXTEXT         ,   /* Object 9 LEFT1 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[7],
  0x0001, 0x0001, 0x0002, 0x0001,
        11,       -1,       -1, G_BOXTEXT         ,   /* Object 10 RIGHT1 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[8],
  0x0025, 0x0001, 0x0002, 0x0001,
  RESET           ,       -1,       -1, G_TEXT            ,   /* Object 11  */
  NONE, NORMAL, (LONG)&rs_tedinfo[9],
  0x0004, 0x0002, 0x040A, 0x0001,
        13,       -1,       -1, G_BOXTEXT         ,   /* Object 12 RESET */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[10],
  0x0004, 0x0005, 0x0005, 0x0600,
        14,       -1,       -1, G_IMAGE           ,   /* Object 13  */
  NONE, NORMAL, (LONG)&rs_bitblk[0],
  0x0001, 0x0000, 0x0002, 0x0001,
        15,       -1,       -1, G_IMAGE           ,   /* Object 14  */
  NONE, NORMAL, (LONG)&rs_bitblk[1],
  0x0025, 0x0000, 0x0002, 0x0001,
         0,       -1,       -1, G_IMAGE           ,   /* Object 15  */
  LASTOB, NORMAL, (LONG)&rs_bitblk[2],
  0x0013, 0x0000, 0x0002, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 SW_KONVERT       */
};
