/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "COLTRIS.H"

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
{ "  ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 3, 1,
  "      ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 7, 1,
  "      ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 7, 1,
  "      ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 7, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 5, 1,
  "  0 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 5, 1,
  "____________",
  "____________",
  "XXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 13, 13,
  "(for Columns and Stetris)",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 26, 1,
  "click anywhere!",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 16, 1
};

static OBJECT rs_object[] =
{ 
  /******** Tree 0 MENUE ****************************************************/
        -1,        1,        6, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         6,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1,        3,        5, G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x001B, 0x0301,
  MT_FILE ,       -1,       -1, G_TITLE   ,   /* Object 3  */
  NONE, NORMAL, (LONG)" WinColTris",
  0x0000, 0x0000, 0x000C, 0x0301,
         5,       -1,       -1, G_TITLE   ,   /* Object 4 MT_FILE */
  NONE, NORMAL, (LONG)" File",
  0x000C, 0x0000, 0x0006, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 5  */
  NONE, NORMAL, (LONG)" Options",
  0x0012, 0x0000, 0x0009, 0x0301,
         0,        7,       23, G_IBOX    ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0017,
        16, M_INFO  ,       15, G_BOX     ,   /* Object 7  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0013, 0x0008,
         9,       -1,       -1, G_STRING  ,   /* Object 8 M_INFO */
  NONE, NORMAL, (LONG)"  about WinColTris ",
  0x0000, 0x0000, 0x0013, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, DISABLED, (LONG)"-------------------",
  0x0000, 0x0001, 0x0013, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"  Desk Accessory 1 ",
  0x0000, 0x0002, 0x0013, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"  Desk Accessory 2 ",
  0x0000, 0x0003, 0x0013, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"  Desk Accessory 3 ",
  0x0000, 0x0004, 0x0013, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"  Desk Accessory 4 ",
  0x0000, 0x0005, 0x0013, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"  Desk Accessory 5 ",
  0x0000, 0x0006, 0x0013, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"  Desk Accessory 6 ",
  0x0000, 0x0007, 0x0013, 0x0001,
        23, M_START , M_QUIT  , G_BOX     ,   /* Object 16  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000E, 0x0000, 0x000E, 0x0006,
        18,       -1,       -1, G_STRING  ,   /* Object 17 M_START */
  NONE, NORMAL, (LONG)"  Play     ^R ",
  0x0000, 0x0000, 0x000E, 0x0001,
  M_HISCORE,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, DISABLED, (LONG)"--------------",
  0x0000, 0x0001, 0x000E, 0x0001,
  M_SAVE  ,       -1,       -1, G_STRING  ,   /* Object 19 M_HISCORE */
  NONE, NORMAL, (LONG)"  Hiscore  ^H ",
  0x0000, 0x0002, 0x000E, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20 M_SAVE */
  NONE, NORMAL, (LONG)"  Save     ^S ",
  0x0000, 0x0003, 0x000E, 0x0001,
  M_QUIT  ,       -1,       -1, G_STRING  ,   /* Object 21  */
  NONE, DISABLED, (LONG)"--------------",
  0x0000, 0x0004, 0x000E, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 22 M_QUIT */
  NONE, NORMAL, (LONG)"  Quit     ^Q ",
  0x0000, 0x0005, 0x000E, 0x0001,
         6, M_TETRIS, M_OPTS  , G_BOX     ,   /* Object 23  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0014, 0x0000, 0x0010, 0x0008,
  M_COLUMNS,       -1,       -1, G_STRING  ,   /* Object 24 M_TETRIS */
  NONE, NORMAL, (LONG)"  Tetris     ^T ",
  0x0000, 0x0000, 0x0010, 0x0001,
        26,       -1,       -1, G_STRING  ,   /* Object 25 M_COLUMNS */
  NONE, NORMAL, (LONG)"  Columns    ^C ",
  0x0000, 0x0001, 0x0010, 0x0001,
  M_SCORE ,       -1,       -1, G_STRING  ,   /* Object 26  */
  NONE, DISABLED, (LONG)"----------------",
  0x0000, 0x0002, 0x0010, 0x0001,
  M_PREVIEW,       -1,       -1, G_STRING  ,   /* Object 27 M_SCORE */
  NONE, NORMAL, (LONG)"  Score      ^I ",
  0x0000, 0x0003, 0x0010, 0x0001,
  M_STATISTIC,       -1,       -1, G_STRING  ,   /* Object 28 M_PREVIEW */
  NONE, NORMAL, (LONG)"  Preview    ^N ",
  0x0000, 0x0004, 0x0010, 0x0001,
        30,       -1,       -1, G_STRING  ,   /* Object 29 M_STATISTIC */
  NONE, NORMAL, (LONG)"  Statistic  ^B ",
  0x0000, 0x0005, 0x0010, 0x0001,
  M_OPTS  ,       -1,       -1, G_STRING  ,   /* Object 30  */
  NONE, DISABLED, (LONG)"----------------",
  0x0000, 0x0006, 0x0010, 0x0001,
        23,       -1,       -1, G_STRING  ,   /* Object 31 M_OPTS */
  LASTOB, NORMAL, (LONG)"  Options... ^O ",
  0x0000, 0x0007, 0x0010, 0x0001,
  
  /******** Tree 1 XSCORE ****************************************************/
        -1,        1, SCORE   , G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0014, 0x0007,
  LEVEL   ,       -1,       -1, G_STRING  ,   /* Object 1  */
  SELECTABLE, NORMAL, (LONG)"Level   :",
  0x0002, 0x0001, 0x0009, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2 LEVEL */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0011, 0x0001, 0x0002, 0x0001,
  STONES  ,       -1,       -1, G_STRING  ,   /* Object 3  */
  SELECTABLE, NORMAL, (LONG)"Stones  :",
  0x0002, 0x0002, 0x0009, 0x0002,
         5,       -1,       -1, G_TEXT    ,   /* Object 4 STONES */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x000D, 0x0002, 0x0006, 0x0002,
  LINES   ,       -1,       -1, G_STRING  ,   /* Object 5  */
  SELECTABLE, NORMAL, (LONG)"Lines   :",
  0x0002, 0x0004, 0x0009, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6 LINES */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x000D, 0x0004, 0x0006, 0x0001,
  SCORE   ,       -1,       -1, G_STRING  ,   /* Object 7  */
  SELECTABLE, NORMAL, (LONG)"Score   :",
  0x0002, 0x0005, 0x0009, 0x0002,
         0,       -1,       -1, G_TEXT    ,   /* Object 8 SCORE */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[3],
  0x000D, 0x0005, 0x0006, 0x0002,
  
  /******** Tree 2 STATISTIC ****************************************************/
        -1, TSTAT   , C_STAT  , G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x000A, 0x000A,
  C_STAT  , TSTAT0  ,        8, G_BOX     ,   /* Object 1 TSTAT */
  NONE, NORMAL, (LONG)0x00001181L,
  0x0000, 0x0000, 0x000A, 0x000A,
         3,       -1,       -1, G_TEXT    ,   /* Object 2 TSTAT0 */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0005, 0x0001, 0x0004, 0x0002,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0005, 0x0002, 0x0004, 0x0002,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0005, 0x0003, 0x0004, 0x0002,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[7],
  0x0005, 0x0004, 0x0004, 0x0002,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[8],
  0x0005, 0x0005, 0x0004, 0x0002,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[9],
  0x0005, 0x0006, 0x0004, 0x0002,
  TSTAT   ,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[10],
  0x0005, 0x0007, 0x0004, 0x0002,
         0, CSTAT0  ,       15, G_BOX     ,   /* Object 9 C_STAT */
  NONE, NORMAL, (LONG)0x00001101L,
  0x0000, 0x0000, 0x000A, 0x000A,
        11,       -1,       -1, G_TEXT    ,   /* Object 10 CSTAT0 */
  NONE, NORMAL, (LONG)&rs_tedinfo[11],
  0x0005, 0x0001, 0x0004, 0x0001,
        12,       -1,       -1, G_TEXT    ,   /* Object 11  */
  NONE, NORMAL, (LONG)&rs_tedinfo[12],
  0x0005, 0x0002, 0x0004, 0x0002,
        13,       -1,       -1, G_TEXT    ,   /* Object 12  */
  NONE, NORMAL, (LONG)&rs_tedinfo[13],
  0x0005, 0x0004, 0x0004, 0x0001,
        14,       -1,       -1, G_TEXT    ,   /* Object 13  */
  NONE, NORMAL, (LONG)&rs_tedinfo[14],
  0x0005, 0x0005, 0x0004, 0x0002,
        15,       -1,       -1, G_TEXT    ,   /* Object 14  */
  NONE, NORMAL, (LONG)&rs_tedinfo[15],
  0x0005, 0x0007, 0x0004, 0x0001,
  C_STAT  ,       -1,       -1, G_TEXT    ,   /* Object 15  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[16],
  0x0005, 0x0008, 0x0004, 0x0002,
  
  /******** Tree 3 OPTSBOX ****************************************************/
        -1,        1, OK      , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x003E, 0x000F,
  O_TETRIS,       -1,       -1, G_BUTTON  ,   /* Object 1  */
  NONE, OUTLINED|SHADOWED, (LONG)"ColTris Options",
  0x0002, 0x0001, 0x0023, 0x0001,
  O_COLUMNS,       -1,       -1, G_BUTTON  ,   /* Object 2 O_TETRIS */
  NONE, NORMAL, (LONG)"Tetris",
  0x0027, 0x0001, 0x000A, 0x0001,
         4,       -1,       -1, G_BUTTON  ,   /* Object 3 O_COLUMNS */
  NONE, NORMAL, (LONG)"Columns",
  0x0032, 0x0001, 0x000A, 0x0001,
        15, LEVEL0  , LEVEL9  , G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Level  :",
  0x0002, 0x0003, 0x003B, 0x0001,
         6,       -1,       -1, G_BOXCHAR ,   /* Object 5 LEVEL0 */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'0' << 24)|0x00FF1100L,
  0x0009, 0x0000, 0x0004, 0x0001,
         7,       -1,       -1, G_BOXCHAR ,   /* Object 6  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'1' << 24)|0x00FF1100L,
  0x000E, 0x0000, 0x0004, 0x0001,
         8,       -1,       -1, G_BOXCHAR ,   /* Object 7  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'2' << 24)|0x00FF1100L,
  0x0013, 0x0000, 0x0004, 0x0001,
         9,       -1,       -1, G_BOXCHAR ,   /* Object 8  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'3' << 24)|0x00FF1100L,
  0x0018, 0x0000, 0x0004, 0x0001,
        10,       -1,       -1, G_BOXCHAR ,   /* Object 9  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'4' << 24)|0x00FF1100L,
  0x001D, 0x0000, 0x0004, 0x0001,
        11,       -1,       -1, G_BOXCHAR ,   /* Object 10  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'5' << 24)|0x00FF1100L,
  0x0022, 0x0000, 0x0004, 0x0001,
        12,       -1,       -1, G_BOXCHAR ,   /* Object 11  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'6' << 24)|0x00FF1100L,
  0x0027, 0x0000, 0x0004, 0x0001,
        13,       -1,       -1, G_BOXCHAR ,   /* Object 12  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'7' << 24)|0x00FF1100L,
  0x002C, 0x0000, 0x0004, 0x0001,
  LEVEL9  ,       -1,       -1, G_BOXCHAR ,   /* Object 13  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'8' << 24)|0x00FF1100L,
  0x0031, 0x0000, 0x0004, 0x0001,
         4,       -1,       -1, G_BOXCHAR ,   /* Object 14 LEVEL9 */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'9' << 24)|0x00FF1100L,
  0x0036, 0x0000, 0x0004, 0x0001,
        31, RANDOM0 , RANDOM14, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"Random :",
  0x0002, 0x0005, 0x003B, 0x0001,
        17,       -1,       -1, G_BOXCHAR ,   /* Object 16 RANDOM0 */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'0' << 24)|0x00FF1100L,
  0x0009, 0x0000, 0x0002, 0x0001,
        18,       -1,       -1, G_BOXCHAR ,   /* Object 17  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'1' << 24)|0x00FF1100L,
  0x000C, 0x0000, 0x0002, 0x0001,
        19,       -1,       -1, G_BOXCHAR ,   /* Object 18  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'2' << 24)|0x00FF1100L,
  0x000F, 0x0000, 0x0002, 0x0001,
        20,       -1,       -1, G_BOXCHAR ,   /* Object 19  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'3' << 24)|0x00FF1100L,
  0x0012, 0x0000, 0x0002, 0x0001,
        21,       -1,       -1, G_BOXCHAR ,   /* Object 20  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'4' << 24)|0x00FF1100L,
  0x0015, 0x0000, 0x0002, 0x0001,
        22,       -1,       -1, G_BOXCHAR ,   /* Object 21  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'5' << 24)|0x00FF1100L,
  0x0018, 0x0000, 0x0002, 0x0001,
        23,       -1,       -1, G_BOXCHAR ,   /* Object 22  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'6' << 24)|0x00FF1100L,
  0x001B, 0x0000, 0x0002, 0x0001,
        24,       -1,       -1, G_BOXCHAR ,   /* Object 23  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'7' << 24)|0x00FF1100L,
  0x001E, 0x0000, 0x0002, 0x0001,
        25,       -1,       -1, G_BOXCHAR ,   /* Object 24  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'8' << 24)|0x00FF1100L,
  0x0021, 0x0000, 0x0002, 0x0001,
        26,       -1,       -1, G_BOXCHAR ,   /* Object 25  */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'9' << 24)|0x00FF1100L,
  0x0024, 0x0000, 0x0002, 0x0001,
        27,       -1,       -1, G_BUTTON  ,   /* Object 26  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"10",
  0x0027, 0x0000, 0x0003, 0x0001,
        28,       -1,       -1, G_BUTTON  ,   /* Object 27  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"11",
  0x002B, 0x0000, 0x0003, 0x0001,
        29,       -1,       -1, G_BUTTON  ,   /* Object 28  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"12",
  0x002F, 0x0000, 0x0003, 0x0001,
  RANDOM14,       -1,       -1, G_BUTTON  ,   /* Object 29  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"13",
  0x0033, 0x0000, 0x0003, 0x0001,
        15,       -1,       -1, G_BUTTON  ,   /* Object 30 RANDOM14 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"14",
  0x0037, 0x0000, 0x0003, 0x0001,
        34, GRAPH_ST, GRAPH_VDI, G_STRING  ,   /* Object 31  */
  NONE, NORMAL, (LONG)"Graphic:",
  0x0002, 0x0007, 0x0025, 0x0001,
  GRAPH_VDI,       -1,       -1, G_BUTTON  ,   /* Object 32 GRAPH_ST */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"ST",
  0x0009, 0x0000, 0x0009, 0x0001,
        31,       -1,       -1, G_BUTTON  ,   /* Object 33 GRAPH_VDI */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"VDI",
  0x0013, 0x0000, 0x0009, 0x0001,
        37, SINGLE  , MULTI   , G_STRING  ,   /* Object 34  */
  NONE, NORMAL, (LONG)"Mode   :",
  0x0002, 0x0009, 0x0021, 0x0001,
  MULTI   ,       -1,       -1, G_BUTTON  ,   /* Object 35 SINGLE */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"single",
  0x0009, 0x0000, 0x0009, 0x0001,
        34,       -1,       -1, G_BUTTON  ,   /* Object 36 MULTI */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"multi",
  0x0013, 0x0000, 0x0009, 0x0001,
  USER_KEY, CYCLENONE, CYCLEALL, G_STRING  ,   /* Object 37  */
  NONE, NORMAL, (LONG)"AV/VA  :",
  0x0002, 0x000B, 0x0026, 0x0001,
  CYCLEPLAY,       -1,       -1, G_BUTTON  ,   /* Object 38 CYCLENONE */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"none",
  0x0009, 0x0000, 0x0009, 0x0001,
  CYCLEALL,       -1,       -1, G_BUTTON  ,   /* Object 39 CYCLEPLAY */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"play",
  0x0013, 0x0000, 0x0009, 0x0001,
        37,       -1,       -1, G_BUTTON  ,   /* Object 40 CYCLEALL */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"all",
  0x001D, 0x0000, 0x0009, 0x0001,
        42,       -1,       -1, G_BUTTON  ,   /* Object 41 USER_KEY */
  SELECTABLE|EXIT, NORMAL, (LONG)"define user-keys",
  0x002C, 0x000B, 0x0010, 0x0001,
  ABBR    , TOP_ALL , TOP_ALL , G_STRING  ,   /* Object 42  */
  NONE, NORMAL, (LONG)"Window :",
  0x0002, 0x000D, 0x001C, 0x0001,
        42,       -1,       -1, G_BUTTON  ,   /* Object 43 TOP_ALL */
  SELECTABLE, NORMAL, (LONG)"top all",
  0x0009, 0x0000, 0x0009, 0x0001,
  OK      ,       -1,       -1, G_BUTTON  ,   /* Object 44 ABBR */
  SELECTABLE|EXIT, NORMAL, (LONG)"Cancel",
  0x0026, 0x000D, 0x000A, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 45 OK */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)"Ok",
  0x0032, 0x000D, 0x000A, 0x0001,
  
  /******** Tree 4 KEYS ****************************************************/
        -1, KEYS_TXT, KEYS_TXT, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x000A, 0x0003,
         0,       -1,       -1, G_STRING  ,   /* Object 1 KEYS_TXT */
  LASTOB, NORMAL, (LONG)"Rotate",
  0x0002, 0x0001, 0x0006, 0x0001,
  
  /******** Tree 5 HISCORE ****************************************************/
        -1, HI_TITEL, HI_OK   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0025, 0x0010,
  HI_MARKE,       -1,       -1, G_BUTTON  ,   /* Object 1 HI_TITEL */
  NONE, OUTLINED|SHADOWED, (LONG)"\0",
  0x0002, 0x0001, 0x0021, 0x0001,
  HISCORE1,       -1,       -1, G_BOXCHAR ,   /* Object 2 HI_MARKE */
  NONE, NORMAL, (LONG) ((LONG)'*' << 24)|0x00001100L,
  0x0001, 0x0003, 0x0002, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3 HISCORE1 */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x0003, 0x000C, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x0003, 0x000A, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x0003, 0x0005, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x0004, 0x000C, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x0004, 0x000A, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x0004, 0x0005, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x0005, 0x000C, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x0005, 0x000A, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x0005, 0x0005, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x0006, 0x000C, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x0006, 0x000A, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x0006, 0x0005, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x0007, 0x000C, 0x0001,
        17,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x0007, 0x000A, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x0007, 0x0005, 0x0001,
        19,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x0008, 0x000C, 0x0001,
        20,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x0008, 0x000A, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x0008, 0x0005, 0x0001,
        22,       -1,       -1, G_STRING  ,   /* Object 21  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x0009, 0x000C, 0x0001,
        23,       -1,       -1, G_STRING  ,   /* Object 22  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x0009, 0x000A, 0x0001,
        24,       -1,       -1, G_STRING  ,   /* Object 23  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x0009, 0x0005, 0x0001,
        25,       -1,       -1, G_STRING  ,   /* Object 24  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x000A, 0x000C, 0x0001,
        26,       -1,       -1, G_STRING  ,   /* Object 25  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x000A, 0x000A, 0x0001,
        27,       -1,       -1, G_STRING  ,   /* Object 26  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x000A, 0x0005, 0x0001,
        28,       -1,       -1, G_STRING  ,   /* Object 27  */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x000B, 0x000C, 0x0001,
        29,       -1,       -1, G_STRING  ,   /* Object 28  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x000B, 0x000A, 0x0001,
  HISCOREN,       -1,       -1, G_STRING  ,   /* Object 29  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x000B, 0x0005, 0x0001,
        31,       -1,       -1, G_STRING  ,   /* Object 30 HISCOREN */
  NONE, NORMAL, (LONG)"123456789012",
  0x0003, 0x000C, 0x000C, 0x0001,
        32,       -1,       -1, G_STRING  ,   /* Object 31  */
  NONE, NORMAL, (LONG)"12.12.1994",
  0x0011, 0x000C, 0x000A, 0x0001,
  CLR_HI  ,       -1,       -1, G_STRING  ,   /* Object 32  */
  NONE, NORMAL, (LONG)"12345",
  0x001D, 0x000C, 0x0005, 0x0001,
  HI_OK   ,       -1,       -1, G_BUTTON  ,   /* Object 33 CLR_HI */
  SELECTABLE|EXIT, NORMAL, (LONG)"Clear",
  0x0002, 0x000E, 0x000A, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 34 HI_OK */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)"Ok",
  0x0019, 0x000E, 0x000A, 0x0001,
  
  /******** Tree 6 NEWHI ****************************************************/
        -1, HI_NAME ,        2, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x000E, 0x0004,
         2,       -1,       -1, G_FTEXT   ,   /* Object 1 HI_NAME */
  SELECTABLE|DEFAULT|EXIT|EDITABLE, NORMAL, (LONG)&rs_tedinfo[17],
  0x0001, 0x0002, 0x000C, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 2  */
  LASTOB, NORMAL, (LONG)"enter name",
  0x0002, 0x0000, 0x000A, 0x0002,
  
  /******** Tree 7 INFOBOX ****************************************************/
        -1,        1,       11, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0030, 0x0010,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"COLTRIS  V2.0  27.12.1994",
  0x000C, 0x0001, 0x0019, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"yet another COLUMNS and TETRIS version",
  0x0005, 0x0002, 0x0026, 0x0002,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"written by Th. Morus Walter",
  0x000B, 0x0004, 0x001B, 0x0002,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"(c) 1994 by Never Ready Software",
  0x0008, 0x0005, 0x0020, 0x0002,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"this program is FREEWARE!",
  0x000C, 0x0007, 0x0019, 0x0002,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"thanx to: P.C.M van der Arend",
  0x000A, 0x000A, 0x001D, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[18],
  0x0014, 0x000B, 0x0019, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"Coltris was written in C and assembler",
  0x0006, 0x000C, 0x0026, 0x0002,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"and compiled with PureC1.0",
  0x000B, 0x000D, 0x001A, 0x0002,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[19],
  0x0000, 0x000F, 0x0030, 0x0001,
         0,       -1,       -1, G_IBOX    ,   /* Object 11  */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0030, 0x0010
};

static OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MENUE    */
  &rs_object[32],   /* Tree  1 XSCORE   */
  &rs_object[41],   /* Tree  2 STATISTIC */
  &rs_object[57],   /* Tree  3 OPTSBOX  */
  &rs_object[103],   /* Tree  4 KEYS     */
  &rs_object[105],   /* Tree  5 HISCORE  */
  &rs_object[140],   /* Tree  6 NEWHI    */
  &rs_object[143]    /* Tree  7 INFOBOX  */
};
