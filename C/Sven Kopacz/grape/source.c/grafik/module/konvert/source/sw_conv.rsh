/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "SW_CONV.H"

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
  "123",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -2, 4, 1,
  "\004",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -2, 2, 1,
  "\003",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -2, 2, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 SW_KONVERT ****************************************************/
        -1, GO              ,        8, G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x002A, 0x0009,
  BAR             ,       -1,       -1, G_BUTTON          ,   /* Object 1 GO */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Ausf\201hren",
  0x001C, 0x0007, 0x000A, 0x0001,
  LEFT            , SLIDE           , SLIDE           , G_BOXTEXT         ,   /* Object 2 BAR */
  TOUCHEXIT|FLAGS9|FLAGS10, SELECTED, (LONG)&rs_tedinfo[0],
  0x0006, 0x0002, 0x0020, 0x0001,
  BAR             ,       -1,       -1, G_BOXTEXT         ,   /* Object 3 SLIDE */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x0000, 0x0000, 0x0004, 0x0001,
  RIGHT           ,       -1,       -1, G_BOXTEXT         ,   /* Object 4 LEFT */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[2],
  0x0003, 0x0002, 0x0002, 0x0001,
  SCHWELL         ,       -1,       -1, G_BOXTEXT         ,   /* Object 5 RIGHT */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[3],
  0x0027, 0x0002, 0x0002, 0x0001,
  DIFFUS          ,       -1,       -1, G_BUTTON          ,   /* Object 6 SCHWELL */
  SELECTABLE|RBUTTON|TOUCHEXIT|FLAGS9, WHITEBAK|STATE14|STATE15, (LONG)"Schwellwert",
  0x0002, 0x0000, 0x000E, 0x0001,
         8,       -1,       -1, G_BUTTON          ,   /* Object 7 DIFFUS */
  SELECTABLE|RBUTTON|TOUCHEXIT|FLAGS9, WHITEBAK|STATE14|STATE15, (LONG)"Fehlerdiffusion",
  0x0002, 0x0004, 0x0012, 0x0001,
         0, DIFF1           , DIFF3           , G_IBOX            ,   /* Object 8  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0005, 0x0005, 0x0013, 0x0003,
  DIFF2           ,       -1,       -1, G_BUTTON          ,   /* Object 9 DIFF1 */
  SELECTABLE|RBUTTON|TOUCHEXIT|FLAGS9, WHITEBAK|STATE14|STATE15, (LONG)"Verteilung 50/50",
  0x0000, 0x0000, 0x0013, 0x0001,
  DIFF3           ,       -1,       -1, G_BUTTON          ,   /* Object 10 DIFF2 */
  SELECTABLE|RBUTTON|TOUCHEXIT|FLAGS9, WHITEBAK|STATE14|STATE15, (LONG)"Verteilung 1/3",
  0x0000, 0x0001, 0x0011, 0x0001,
         8,       -1,       -1, G_BUTTON          ,   /* Object 11 DIFF3 */
  SELECTABLE|RBUTTON|LASTOB|TOUCHEXIT|FLAGS9, WHITEBAK|STATE14|STATE15, (LONG)"Floyd-Steinberg",
  0x0000, 0x0002, 0x0012, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 SW_KONVERT       */
};
