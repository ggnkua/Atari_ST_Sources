/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "PALASIST.H"

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
{ "A",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\001",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "A",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\001",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "A",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\001",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "A",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\001",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "A",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\001",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "A",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\001",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "A",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\001",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "A",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\001",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1
};

USERBLK rs_userblk[] =
{ 0L, 0x00000003,
  0L, 0x00000003
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 PALASSISTENT ****************************************************/
        -1,        1,       30, G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0028, 0x000E,
        20, FILL            , COL2            , G_IBOX            ,   /* Object 1  */
  FLAGS9, SELECTED, (LONG)0x00FF1100L,
  0x0001, 0x0001, 0x0026, 0x0004,
  LINE1           ,       -1,       -1, G_BUTTON          ,   /* Object 2 FILL */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"F\201lle:",
  0x0001, 0x0001, 0x0007, 0x0001,
  UL1             ,       -1,       -1, G_BOXTEXT         ,   /* Object 3 LINE1 */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x000A, 0x0001, 0x0002, 0x0001,
  DL1             ,       -1,       -1, G_BOXTEXT         ,   /* Object 4 UL1 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x000D, 0x0001, 0x0002, 0x0600,
  ROW1            ,       -1,       -1, G_BOXTEXT         ,   /* Object 5 DL1 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[2],
  0x000D, 0x0002, 0x0002, 0x0600,
  UR1             ,       -1,       -1, G_BOXTEXT         ,   /* Object 6 ROW1 */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0010, 0x0001, 0x0002, 0x0001,
  DR1             ,       -1,       -1, G_BOXTEXT         ,   /* Object 7 UR1 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[4],
  0x0013, 0x0001, 0x0002, 0x0600,
         9,       -1,       -1, G_BOXTEXT         ,   /* Object 8 DR1 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[5],
  0x0013, 0x0002, 0x0002, 0x0600,
  LINE2           ,       -1,       -1, G_STRING          ,   /* Object 9  */
  NONE, NORMAL, (LONG)"bis",
  0x0016, 0x0001, 0x0003, 0x0001,
  UL2             ,       -1,       -1, G_BOXTEXT         ,   /* Object 10 LINE2 */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x001A, 0x0001, 0x0002, 0x0001,
  DL2             ,       -1,       -1, G_BOXTEXT         ,   /* Object 11 UL2 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[7],
  0x001D, 0x0001, 0x0002, 0x0600,
  ROW2            ,       -1,       -1, G_BOXTEXT         ,   /* Object 12 DL2 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[8],
  0x001D, 0x0002, 0x0002, 0x0600,
  UR2             ,       -1,       -1, G_BOXTEXT         ,   /* Object 13 ROW2 */
  NONE, NORMAL, (LONG)&rs_tedinfo[9],
  0x0020, 0x0001, 0x0002, 0x0001,
  DR2             ,       -1,       -1, G_BOXTEXT         ,   /* Object 14 UR2 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[10],
  0x0023, 0x0001, 0x0002, 0x0600,
  UP1             ,       -1,       -1, G_BOXTEXT         ,   /* Object 15 DR2 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[11],
  0x0023, 0x0002, 0x0002, 0x0600,
  COL1            ,       -1,       -1, G_STRING          ,   /* Object 16 UP1 */
  NONE, NORMAL, (LONG)"mit Verlauf von",
  0x000A, 0x0003, 0x000F, 0x0001,
        18,       -1,       -1, G_USERDEF         ,   /* Object 17 COL1 */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[0],
  0x001A, 0x0003, 0x0002, 0x0001,
  COL2            ,       -1,       -1, G_STRING          ,   /* Object 18  */
  NONE, NORMAL, (LONG)"nach",
  0x001D, 0x0003, 0x0004, 0x0001,
         1,       -1,       -1, G_USERDEF         ,   /* Object 19 COL2 */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[1],
  0x0022, 0x0003, 0x0002, 0x0001,
        30, COPY1           , DL4             , G_IBOX            ,   /* Object 20  */
  FLAGS9, SELECTED, (LONG)0x00FF1100L,
  0x0001, 0x0006, 0x0026, 0x0003,
        22,       -1,       -1, G_BUTTON          ,   /* Object 21 COPY1 */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Kopiere:",
  0x0001, 0x0001, 0x0009, 0x0001,
  LINE3           ,       -1,       -1, G_STRING          ,   /* Object 22  */
  NONE, NORMAL, (LONG)"Zeile",
  0x000C, 0x0001, 0x0005, 0x0001,
  UL3             ,       -1,       -1, G_BOXTEXT         ,   /* Object 23 LINE3 */
  NONE, NORMAL, (LONG)&rs_tedinfo[12],
  0x0012, 0x0001, 0x0002, 0x0001,
  DL3             ,       -1,       -1, G_BOXTEXT         ,   /* Object 24 UL3 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[13],
  0x0015, 0x0001, 0x0002, 0x0600,
        26,       -1,       -1, G_BOXTEXT         ,   /* Object 25 DL3 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[14],
  0x0015, 0x0002, 0x0002, 0x0600,
  LINE4           ,       -1,       -1, G_STRING          ,   /* Object 26  */
  NONE, NORMAL, (LONG)"nach",
  0x0018, 0x0001, 0x0004, 0x0001,
  UL4             ,       -1,       -1, G_BOXTEXT         ,   /* Object 27 LINE4 */
  NONE, NORMAL, (LONG)&rs_tedinfo[15],
  0x001D, 0x0001, 0x0002, 0x0001,
  DL4             ,       -1,       -1, G_BOXTEXT         ,   /* Object 28 UL4 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[16],
  0x0020, 0x0001, 0x0002, 0x0600,
        20,       -1,       -1, G_BOXTEXT         ,   /* Object 29 DL4 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[17],
  0x0020, 0x0002, 0x0002, 0x0600,
         0, COPY2           , DR4             , G_IBOX            ,   /* Object 30  */
  FLAGS9, SELECTED, (LONG)0x00FF1100L,
  0x0001, 0x000A, 0x0026, 0x0003,
        32,       -1,       -1, G_BUTTON          ,   /* Object 31 COPY2 */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Kopiere:",
  0x0001, 0x0001, 0x0009, 0x0001,
  ROW3            ,       -1,       -1, G_STRING          ,   /* Object 32  */
  NONE, NORMAL, (LONG)"Spalte",
  0x000B, 0x0001, 0x0006, 0x0001,
  UR3             ,       -1,       -1, G_BOXTEXT         ,   /* Object 33 ROW3 */
  NONE, NORMAL, (LONG)&rs_tedinfo[18],
  0x0012, 0x0001, 0x0002, 0x0001,
  DR3             ,       -1,       -1, G_BOXTEXT         ,   /* Object 34 UR3 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[19],
  0x0015, 0x0001, 0x0002, 0x0600,
        36,       -1,       -1, G_BOXTEXT         ,   /* Object 35 DR3 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[20],
  0x0015, 0x0002, 0x0002, 0x0600,
  ROW4            ,       -1,       -1, G_STRING          ,   /* Object 36  */
  NONE, NORMAL, (LONG)"nach",
  0x0018, 0x0001, 0x0004, 0x0001,
  UR4             ,       -1,       -1, G_BOXTEXT         ,   /* Object 37 ROW4 */
  NONE, NORMAL, (LONG)&rs_tedinfo[21],
  0x001D, 0x0001, 0x0002, 0x0001,
  DR4             ,       -1,       -1, G_BOXTEXT         ,   /* Object 38 UR4 */
  TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[22],
  0x0020, 0x0001, 0x0002, 0x0600,
        30,       -1,       -1, G_BOXTEXT         ,   /* Object 39 DR4 */
  LASTOB|TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[23],
  0x0020, 0x0002, 0x0002, 0x0600
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 PALASSISTENT     */
};
