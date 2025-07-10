/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "CARD.H"

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
{ "click anywhere!",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 16, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 MENUE ****************************************************/
        -1,        1,        7, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         7,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1, MT_DESK , MT_OPTS , G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x0027, 0x0301,
  MT_DATEI,       -1,       -1, G_TITLE   ,   /* Object 3 MT_DESK */
  NONE, NORMAL, (LONG)" SOLITARE",
  0x0000, 0x0000, 0x000A, 0x0301,
  MT_EDIT ,       -1,       -1, G_TITLE   ,   /* Object 4 MT_DATEI */
  NONE, NORMAL, (LONG)" Datei",
  0x000A, 0x0000, 0x0007, 0x0301,
  MT_OPTS ,       -1,       -1, G_TITLE   ,   /* Object 5 MT_EDIT */
  NONE, NORMAL, (LONG)" Bearbeiten",
  0x0011, 0x0000, 0x000C, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 6 MT_OPTS */
  NONE, NORMAL, (LONG)" Optionen",
  0x001D, 0x0000, 0x000A, 0x0301,
         0,        8,       28, G_IBOX    ,   /* Object 7  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0017,
        17, M_PRGINFO,       16, G_BOX     ,   /* Object 8  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0014, 0x0008,
        10,       -1,       -1, G_STRING  ,   /* Object 9 M_PRGINFO */
  NONE, NORMAL, (LONG)"  \201ber Solitare  ^I ",
  0x0000, 0x0000, 0x0014, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, DISABLED, (LONG)"--------------------",
  0x0000, 0x0001, 0x0014, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"  Desk Accessory 1 ",
  0x0000, 0x0002, 0x0014, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"  Desk Accessory 2 ",
  0x0000, 0x0003, 0x0014, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"  Desk Accessory 3 ",
  0x0000, 0x0004, 0x0014, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"  Desk Accessory 4 ",
  0x0000, 0x0005, 0x0014, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"  Desk Accessory 5 ",
  0x0000, 0x0006, 0x0014, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"  Desk Accessory 6 ",
  0x0000, 0x0007, 0x0014, 0x0001,
        21, M_NEU   , M_QUIT  , G_BOX     ,   /* Object 17  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000C, 0x0000, 0x0012, 0x0003,
        19,       -1,       -1, G_STRING  ,   /* Object 18 M_NEU */
  NONE, NORMAL, (LONG)"  neues Spiel  ^N ",
  0x0000, 0x0000, 0x0012, 0x0001,
  M_QUIT  ,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, DISABLED, (LONG)"------------------",
  0x0000, 0x0001, 0x0012, 0x0001,
        17,       -1,       -1, G_STRING  ,   /* Object 20 M_QUIT */
  NONE, NORMAL, (LONG)"  Ende         ^Q ",
  0x0000, 0x0002, 0x0012, 0x0001,
        28, M_UNDO  , M_MISCHEN2, G_BOX     ,   /* Object 21  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0013, 0x0000, 0x0016, 0x0006,
        23,       -1,       -1, G_STRING  ,   /* Object 22 M_UNDO */
  NONE, NORMAL, (LONG)"  Zug zur\201ck     UNDO ",
  0x0000, 0x0000, 0x0016, 0x0001,
  M_DRAW  ,       -1,       -1, G_STRING  ,   /* Object 23  */
  NONE, DISABLED, (LONG)"----------------------",
  0x0000, 0x0001, 0x0016, 0x0001,
        25,       -1,       -1, G_STRING  ,   /* Object 24 M_DRAW */
  NONE, NORMAL, (LONG)"  herausziehen     ^X ",
  0x0000, 0x0002, 0x0016, 0x0001,
  M_MISCHEN,       -1,       -1, G_STRING  ,   /* Object 25  */
  NONE, DISABLED, (LONG)"----------------------",
  0x0000, 0x0003, 0x0016, 0x0001,
  M_MISCHEN2,       -1,       -1, G_STRING  ,   /* Object 26 M_MISCHEN */
  NONE, NORMAL, (LONG)"  erstes Mischen   ^1 ",
  0x0000, 0x0004, 0x0016, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 27 M_MISCHEN2 */
  NONE, NORMAL, (LONG)"  zweites Mischen  ^2 ",
  0x0000, 0x0005, 0x0016, 0x0001,
         7, M_CLASSIC, M_HELP  , G_BOX     ,   /* Object 28  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x001F, 0x0000, 0x0010, 0x0002,
  M_HELP  ,       -1,       -1, G_STRING  ,   /* Object 29 M_CLASSIC */
  NONE, NORMAL, (LONG)"  klassisch  ^K ",
  0x0000, 0x0000, 0x0010, 0x0001,
        28,       -1,       -1, G_STRING  ,   /* Object 30 M_HELP */
  LASTOB, NORMAL, (LONG)"  Hilfen     ^H ",
  0x0000, 0x0001, 0x0010, 0x0001,
  
  /******** Tree 1 INFOBOX ****************************************************/
        -1,        1,       11, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0030, 0x0010,
         2,       -1,       -1, G_IBOX    ,   /* Object 1  */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0030, 0x0010,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"Solitare  V1.0  3.8.1994",
  0x000C, 0x0001, 0x0018, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"yet another card game",
  0x000E, 0x0002, 0x0015, 0x0002,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"written by Th. Morus Walter",
  0x000B, 0x0004, 0x001B, 0x0002,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"(c) 1994 by Never Ready Software",
  0x0008, 0x0005, 0x0020, 0x0002,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"this program is FREEWARE!",
  0x000C, 0x0007, 0x0019, 0x0002,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"thanx to: Dirk Haun for Yukon",
  0x000A, 0x0009, 0x001D, 0x0801,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"Dirk Hagedorn and Martin Heise for the cards",
  0x0002, 0x000A, 0x002C, 0x0801,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"Solitare was written in C",
  0x000C, 0x000C, 0x0019, 0x0002,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"and compiled with PureC 1.0",
  0x000B, 0x000D, 0x001B, 0x0002,
         0,       -1,       -1, G_TEXT    ,   /* Object 11  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x000F, 0x0030, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MENUE    */
  &rs_object[31]    /* Tree  1 INFOBOX  */
};
