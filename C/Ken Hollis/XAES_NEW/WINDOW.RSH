/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "WINDOW.H"

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

static TEDINFO rs_tedinfo[] =
{ "-",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\360",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\004",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  " WINDOW NAME BAR ",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x11A1, 0, -1, 18, 1,
  "=",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\004",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\003",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "Info display",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -1, 13, 1,
  "\003",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\004",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\0",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 1, 1,
  "\001",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\003",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "O",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "-",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\360",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "=",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\002",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\003",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\004",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  " WINDOW NAME BAR ",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x11A1, 0, -1, 18, 1,
  "\004",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\003",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "Info display",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 13, 1,
  "\003",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\004",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "O",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\001",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "\0",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x11F0, 0, -1, 1, 1
};

static OBJECT rs_object[] =
{ 
  /******** Tree 0 WINDOW ****************************************************/
        -1, W_ULSIZE, W_OPTION, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0528, 0x080B,
  W_TSIZE , W_PCLOSE, W_PCLOSE, G_BOX     |0x1200,   /* Object 1 W_ULSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0000, 0x0000, 0x0303, 0x0501,
  W_ULSIZE, W_CLOSER, W_CLOSER, G_BOX     |0x1200,   /* Object 2 W_PCLOSE */
  FLAGS9|FLAGS10, DISABLED|DRAW3D, (LONG)0x00FF1100L,
  0x0500, 0x0400, 0x0602, 0x0101,
  W_PCLOSE,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 3 W_CLOSER */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[0],
  0x0000, 0x0000, 0x0602, 0x0101,
  W_URSIZE,       -1,       -1, G_BOX     |0x1200,   /* Object 4 W_TSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0403, 0x0000, 0x0521, 0x0300,
  W_LSIZE , W_PCASC , W_PCASC , G_BOX     |0x1200,   /* Object 5 W_URSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0225, 0x0000, 0x0303, 0x0501,
  W_URSIZE, W_FULLER, W_FULLER, G_BOX     |0x1200,   /* Object 6 W_PCASC */
  FLAGS9|FLAGS10, DISABLED|DRAW3D, (LONG)0x00FF1100L,
  0x0000, 0x0400, 0x0602, 0x0101,
  W_PCASC ,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 7 W_FULLER */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[1],
  0x0000, 0x0000, 0x0602, 0x0101,
  W_RSIZE ,       -1,       -1, G_BOX     |0x1200,   /* Object 8 W_LSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0000, 0x0601, 0x0400, 0x0C08,
  W_LLSIZE,       -1,       -1, G_BOX     |0x1200,   /* Object 9 W_RSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0128, 0x0601, 0x0400, 0x0C08,
  W_BSIZE , W_PSLLT , W_PSLLT , G_BOX     |0x1200,   /* Object 10 W_LLSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0000, 0x030A, 0x0303, 0x0501,
  W_LLSIZE, W_SLLT  , W_SLLT  , G_BOX     |0x1200,   /* Object 11 W_PSLLT */
  FLAGS9|FLAGS10, DISABLED|DRAW3D, (LONG)0x00FF1100L,
  0x0500, 0x0000, 0x0602, 0x0101,
  W_PSLLT ,       -1,       -1, G_BOXTEXT |0x6400,   /* Object 12 W_SLLT */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[2],
  0x0000, 0x0000, 0x0602, 0x0101,
  W_LRSIZE,       -1,       -1, G_BOX     |0x1200,   /* Object 13 W_BSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0403, 0x050B, 0x0521, 0x0300,
  W_MOVER , W_PSLDN , W_PSLDN , G_BOX     |0x1200,   /* Object 14 W_LRSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0225, 0x030A, 0x0303, 0x0501,
  W_LRSIZE, W_SLDN  , W_SLDN  , G_BOX     |0x1200,   /* Object 15 W_PSLDN */
  FLAGS9|FLAGS10, DISABLED|DRAW3D, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0602, 0x0101,
  W_PSLDN ,       -1,       -1, G_BOXTEXT |0x6700,   /* Object 16 W_SLDN */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[3],
  0x0000, 0x0000, 0x0602, 0x0101,
  W_CASCADE,       -1,       -1, G_BOXTEXT |0x1100,   /* Object 17 W_MOVER */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[4],
  0x0403, 0x0400, 0x061E, 0x0101,
  W_MENU  ,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 18 W_CASCADE */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[5],
  0x0322, 0x0400, 0x0602, 0x0101,
  W_INFO  , W_MENU_L, W_MENU_R, G_BOX     |0x1200,   /* Object 19 W_MENU */
  FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1100L,
  0x0500, 0x0601, 0x0327, 0x0101,
  W_MENU_R,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 20 W_MENU_L */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[6],
  0x0000, 0x0000, 0x0602, 0x0101,
  W_MENU  ,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 21 W_MENU_R */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[7],
  0x0702, 0x0000, 0x0602, 0x0101,
  WORKAREA, W_INFO_R, W_INFO_L, G_BOXTEXT |0x1200,   /* Object 22 W_INFO */
  FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[8],
  0x0500, 0x0802, 0x0424, 0x0101,
  W_INFO_L,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 23 W_INFO_R */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[9],
  0x0702, 0x0000, 0x0602, 0x0101,
  W_INFO  ,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 24 W_INFO_L */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[10],
  0x0000, 0x0000, 0x0602, 0x0101,
  W_SLUP  ,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 25 WORKAREA */
  FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[11],
  0x0500, 0x0A03, 0x0424, 0x0806,
  W_VERTRK,       -1,       -1, G_BOXTEXT |0x6600,   /* Object 26 W_SLUP */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[12],
  0x0225, 0x0A03, 0x0602, 0x0101,
  W_HORTRK, W_VERSL , W_VERSL , G_BOX     |0x6800,   /* Object 27 W_VERTRK */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1141L,
  0x0225, 0x0C04, 0x0602, 0x0605,
  W_VERTRK,       -1,       -1, G_BOX     |0x6900,   /* Object 28 W_VERSL */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1100L,
  0x0000, 0x0400, 0x0602, 0x0002,
  W_SLRT  , W_HORSL , W_HORSL , G_BOX     |0x6800,   /* Object 29 W_HORTRK */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1141L,
  0x0403, 0x030A, 0x061E, 0x0101,
  W_HORTRK,       -1,       -1, G_BOX     |0x6900,   /* Object 30 W_HORSL */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1100L,
  0x0202, 0x0000, 0x0604, 0x0101,
  W_OPTION,       -1,       -1, G_BOXTEXT |0x6500,   /* Object 31 W_SLRT */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[13],
  0x0322, 0x030A, 0x0602, 0x0101,
         0,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 32 W_OPTION */
  SELECTABLE|LASTOB|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[14],
  0x0225, 0x0802, 0x0602, 0x0101,
  
  /******** Tree 1 WINDSM ****************************************************/
        -1, S_ULSIZE, S_WORK  , G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0325, 0x0709,
  S_TSIZE ,        2,        2, G_BOX     ,   /* Object 1 S_ULSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0000, 0x0000, 0x0403, 0x0501,
  S_ULSIZE, S_CLOSER, S_CLOSER, G_BOX     ,   /* Object 2  */
  NONE, DISABLED, (LONG)0x00FF1100L,
  0x0600, 0x0400, 0x0602, 0x0101,
         2,       -1,       -1, G_BOXTEXT ,   /* Object 3 S_CLOSER */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[15],
  0x0000, 0x0000, 0x0001, 0x0800,
  S_URSIZE,       -1,       -1, G_BOX     ,   /* Object 4 S_TSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1172L,
  0x0503, 0x0000, 0x011E, 0x0300,
  S_RSIZE ,        6,        6, G_BOX     ,   /* Object 5 S_URSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0721, 0x0000, 0x0403, 0x0501,
  S_URSIZE, S_FULLER, S_CASCADE, G_BOX     ,   /* Object 6  */
  NONE, DISABLED, (LONG)0x00FF1100L,
  0x0000, 0x0400, 0x0602, 0x0101,
  S_CASCADE,       -1,       -1, G_BOXTEXT ,   /* Object 7 S_FULLER */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[16],
  0x0301, 0x0000, 0x0301, 0x0800,
         6,       -1,       -1, G_BOXTEXT ,   /* Object 8 S_CASCADE */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[17],
  0x0000, 0x0000, 0x0201, 0x0800,
  S_LRSIZE,       -1,       -1, G_BOX     ,   /* Object 9 S_RSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1172L,
  0x0624, 0x0601, 0x0500, 0x0906,
  S_BSIZE ,       11, S_SLRT  , G_BOX     ,   /* Object 10 S_LRSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0721, 0x0108, 0x0403, 0x0601,
  S_SLRT  , S_SLDN  , S_SLDN  , G_BOX     ,   /* Object 11  */
  NONE, DISABLED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0602, 0x0101,
        11,       -1,       -1, G_BOXTEXT ,   /* Object 12 S_SLDN */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[18],
  0x0301, 0x0900, 0x0301, 0x0800,
  S_LRSIZE,       -1,       -1, G_BOXTEXT ,   /* Object 13 S_SLRT */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[19],
  0x0000, 0x0900, 0x0201, 0x0800,
  S_LLSIZE,       -1,       -1, G_BOX     ,   /* Object 14 S_BSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1172L,
  0x0503, 0x0409, 0x011E, 0x0300,
  S_LSIZE ,       16,       16, G_BOX     ,   /* Object 15 S_LLSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1142L,
  0x0000, 0x0208, 0x0403, 0x0501,
  S_LLSIZE, S_SLLT  , S_SLLT  , G_BOX     ,   /* Object 16  */
  NONE, DISABLED, (LONG)0x00FF1100L,
  0x0600, 0x0000, 0x0602, 0x0001,
        16,       -1,       -1, G_BOXTEXT ,   /* Object 17 S_SLLT */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[20],
  0x0000, 0x0800, 0x0001, 0x0800,
  S_MOVER ,       -1,       -1, G_BOX     ,   /* Object 18 S_LSIZE */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1172L,
  0x0000, 0x0601, 0x0500, 0x0B06,
  S_MENU  ,       -1,       -1, G_BOXTEXT |0x1100,   /* Object 19 S_MOVER */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[21],
  0x0701, 0x0400, 0x071F, 0x0800,
  S_INFO  , S_MENU_L, S_MENU_R, G_BOX     ,   /* Object 20 S_MENU */
  FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1100L,
  0x0600, 0x0D00, 0x0723, 0x0800,
  S_MENU_R,       -1,       -1, G_BOXTEXT ,   /* Object 21 S_MENU_L */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[22],
  0x0000, 0x0000, 0x0001, 0x0800,
  S_MENU  ,       -1,       -1, G_BOXTEXT ,   /* Object 22 S_MENU_R */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[23],
  0x0101, 0x0000, 0x0001, 0x0800,
  S_OPTIONS, S_INFO_R, S_INFO_L, G_BOXTEXT ,   /* Object 23 S_INFO */
  FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[24],
  0x0600, 0x0601, 0x0322, 0x0800,
  S_INFO_L,       -1,       -1, G_BOXTEXT ,   /* Object 24 S_INFO_R */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[25],
  0x0101, 0x0000, 0x0001, 0x0800,
  S_INFO  ,       -1,       -1, G_BOXTEXT ,   /* Object 25 S_INFO_L */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[26],
  0x0000, 0x0000, 0x0001, 0x0800,
  S_UP    ,       -1,       -1, G_BOXTEXT ,   /* Object 26 S_OPTIONS */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[27],
  0x0223, 0x0601, 0x0301, 0x0800,
  S_VERTRK,       -1,       -1, G_BOXTEXT ,   /* Object 27 S_UP */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[28],
  0x0223, 0x0F01, 0x0301, 0x0800,
  S_HORTRK, S_VERSL , S_VERSL , G_BOX     ,   /* Object 28 S_VERTRK */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1141L,
  0x0223, 0x0802, 0x0301, 0x0106,
  S_VERTRK,       -1,       -1, G_BOX     ,   /* Object 29 S_VERSL */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1100L,
  0x0000, 0x0400, 0x0301, 0x0F01,
  S_WORK  , S_HORSL , S_HORSL , G_BOX     ,   /* Object 30 S_HORTRK */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1141L,
  0x0701, 0x0A08, 0x071F, 0x0800,
  S_HORTRK,       -1,       -1, G_BOX     ,   /* Object 31 S_HORSL */
  TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1100L,
  0x0202, 0x0000, 0x0504, 0x0800,
         0,       -1,       -1, G_BOXTEXT ,   /* Object 32 S_WORK */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[29],
  0x0600, 0x0F01, 0x0322, 0x0A06
};

static OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 WINDOW   */
  &rs_object[33]    /* Tree  1 WINDSM   */
};
