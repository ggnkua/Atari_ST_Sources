/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "MAGICSLM.H"

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
{ "By Bernd Spellenberg & Harald Sch\224nfeld \275 Maxon \04795",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1900, 0, -1, 52, 1,
  " Input ",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 8, 1,
  " Output ",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 9, 1,
  "Seite #",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 8, 1,
  "Gelesene Befehle",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 17, 1,
  "Zustand",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 8, 1,
  "          ",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 11, 1,
  "          ",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 11, 1,
  "          ",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 11, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 SETUP ****************************************************/
        -1,        1,       16, G_BOX     ,   /* Object 0  */
  FLAGS10, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0028, 0x000D,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"MagicSLM - Setup",
  0x0002, 0x0001, 0x0010, 0x0001,
  START   ,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0001, 0x000C, 0x0226, 0x0001,
  STOP    ,       -1,       -1, G_BUTTON  ,   /* Object 3 START */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Start",
  0x0011, 0x000A, 0x0008, 0x0001,
         5,       -1,       -1, G_BUTTON  ,   /* Object 4 STOP */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"STOP",
  0x001C, 0x000A, 0x0008, 0x0001,
        10,        6, FILEIN  , G_BOX     ,   /* Object 5  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0003, 0x0004, 0x0010, 0x0005,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"Modem",
  0x0005, 0x0001, 0x0005, 0x0001,
  MODEMIN ,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"File",
  0x0005, 0x0003, 0x0004, 0x0001,
  FILEIN  ,       -1,       -1, G_BOX     ,   /* Object 8 MODEMIN */
  SELECTABLE|RBUTTON|FLAGS9|FLAGS10, SELECTED, (LONG)0x00011100L,
  0x0002, 0x0001, 0x0002, 0x0001,
         5,       -1,       -1, G_BOX     ,   /* Object 9 FILEIN */
  SELECTABLE|RBUTTON|FLAGS9|FLAGS10, NORMAL, (LONG)0x00011100L,
  0x0002, 0x0003, 0x0002, 0x0001,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x0004, 0x0003, 0x0205, 0x0001,
        16,       12, PCXOUT  , G_BOX     ,   /* Object 11  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0015, 0x0004, 0x0010, 0x0005,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"Diablo SLM",
  0x0005, 0x0001, 0x000A, 0x0001,
  SLMOUT  ,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"PCX File",
  0x0005, 0x0003, 0x0008, 0x0001,
  PCXOUT  ,       -1,       -1, G_BOX     ,   /* Object 14 SLMOUT */
  SELECTABLE|RBUTTON|FLAGS9|FLAGS10, SELECTED, (LONG)0x00011100L,
  0x0002, 0x0001, 0x0002, 0x0001,
        11,       -1,       -1, G_BOX     ,   /* Object 15 PCXOUT */
  SELECTABLE|RBUTTON|FLAGS9|FLAGS10, NORMAL, (LONG)0x00011100L,
  0x0002, 0x0003, 0x0002, 0x0001,
         0,       -1,       -1, G_TEXT    ,   /* Object 16  */
  LASTOB|FLAGS10, NORMAL, (LONG)&rs_tedinfo[2],
  0x0016, 0x0003, 0x0006, 0x0001,
  
  /******** Tree 1 PRINT ****************************************************/
        -1,        1, ABBR    , G_BOX     ,   /* Object 0  */
  FLAGS10, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0024, 0x0009,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"MagicSLM - Status",
  0x0002, 0x0001, 0x0011, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0003, 0x0003, 0x0205, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0003, 0x0004, 0x000C, 0x0001,
  PAGENR  ,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0003, 0x0005, 0x0205, 0x0001,
  BYTES   ,       -1,       -1, G_TEXT    ,   /* Object 5 PAGENR */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[6],
  0x0010, 0x0003, 0x0407, 0x0001,
  ZUSTAND ,       -1,       -1, G_TEXT    ,   /* Object 6 BYTES */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[7],
  0x0010, 0x0004, 0x0407, 0x0001,
  RESET   ,       -1,       -1, G_TEXT    ,   /* Object 7 ZUSTAND */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[8],
  0x0010, 0x0005, 0x0407, 0x0001,
  FF      ,       -1,       -1, G_BUTTON  ,   /* Object 8 RESET */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Reset",
  0x0010, 0x0007, 0x0008, 0x0001,
  ABBR    ,       -1,       -1, G_BUTTON  ,   /* Object 9 FF */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"FF",
  0x001A, 0x0007, 0x0008, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 10 ABBR */
  SELECTABLE|LASTOB|TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Abbruch",
  0x0006, 0x0007, 0x0008, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 SETUP    */
  &rs_object[17]    /* Tree  1 PRINT    */
};
