/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "AHDICONF.H"

#if !defined(WHITEBAK)
#define WHITEBAK    0x0080
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0040
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
{ "(C) 1991 by Uwe Seimet",
  "",
  "",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 23, 1,
  "1",
  "0 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "1 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "2 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "3 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "4 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "5 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "6 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "7 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "0 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "1 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "2 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "3 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "4 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "5 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "6 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "1",
  "7 -> _",
  "9",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 7,
  "000",
  "Zusatzspeicher: ___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 20
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 DIALOG ****************************************************/
        -1,        1, ABORT   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0003, 0x0005, 0x002F, 0x0812,
         2,       -1,       -1, G_BUTTON  ,   /* Object 1  */
  NONE, SELECTED|OUTLINED, (LONG)"AHDI-Konfiguration",
  0x000E, 0x0001, 0x0414, 0x0002,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0010, 0x0004, 0x0410, 0x0001,
  SCSI    ,        4,       12, G_BOX     ,   /* Object 3  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0401, 0x0806, 0x000A, 0x000B,
  ACSINUM ,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"ACSI",
  0x0003, 0x0800, 0x0004, 0x0001,
         6,       -1,       -1, G_FTEXT   ,   /* Object 5 ACSINUM */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0002, 0x0802, 0x0006, 0x0001,
         7,       -1,       -1, G_FTEXT   ,   /* Object 6  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0002, 0x0803, 0x0006, 0x0001,
         8,       -1,       -1, G_FTEXT   ,   /* Object 7  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0002, 0x0804, 0x0006, 0x0001,
         9,       -1,       -1, G_FTEXT   ,   /* Object 8  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0002, 0x0805, 0x0006, 0x0001,
        10,       -1,       -1, G_FTEXT   ,   /* Object 9  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0002, 0x0806, 0x0006, 0x0001,
        11,       -1,       -1, G_FTEXT   ,   /* Object 10  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0002, 0x0807, 0x0006, 0x0001,
        12,       -1,       -1, G_FTEXT   ,   /* Object 11  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[7],
  0x0002, 0x0808, 0x0006, 0x0001,
         3,       -1,       -1, G_FTEXT   ,   /* Object 12  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[8],
  0x0002, 0x0809, 0x0006, 0x0001,
  CHUNK   ,       14,       22, G_BOX     ,   /* Object 13 SCSI */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x000D, 0x0806, 0x000A, 0x000B,
  SCSINUM ,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"SCSI",
  0x0003, 0x0800, 0x0004, 0x0001,
        16,       -1,       -1, G_FTEXT   ,   /* Object 15 SCSINUM */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[9],
  0x0002, 0x0802, 0x0006, 0x0001,
        17,       -1,       -1, G_FTEXT   ,   /* Object 16  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[10],
  0x0002, 0x0803, 0x0006, 0x0001,
        18,       -1,       -1, G_FTEXT   ,   /* Object 17  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[11],
  0x0002, 0x0804, 0x0006, 0x0001,
        19,       -1,       -1, G_FTEXT   ,   /* Object 18  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[12],
  0x0002, 0x0805, 0x0006, 0x0001,
        20,       -1,       -1, G_FTEXT   ,   /* Object 19  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[13],
  0x0002, 0x0806, 0x0006, 0x0001,
        21,       -1,       -1, G_FTEXT   ,   /* Object 20  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[14],
  0x0002, 0x0807, 0x0006, 0x0001,
        22,       -1,       -1, G_FTEXT   ,   /* Object 21  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[15],
  0x0002, 0x0808, 0x0006, 0x0001,
  SCSI    ,       -1,       -1, G_FTEXT   ,   /* Object 22  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[16],
  0x0002, 0x0809, 0x0006, 0x0001,
        24,       -1,       -1, G_FTEXT   ,   /* Object 23 CHUNK */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[17],
  0x0419, 0x0806, 0x0013, 0x0001,
  DEFBIGSE,       -1,       -1, G_STRING  ,   /* Object 24  */
  NONE, NORMAL, (LONG)"Sektormaximum:",
  0x041C, 0x0009, 0x000E, 0x0001,
        26,       -1,       -1, G_BUTTON  ,   /* Object 25 DEFBIGSE */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"512",
  0x0019, 0x000B, 0x0006, 0x0001,
        27,       -1,       -1, G_BUTTON  ,   /* Object 26  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"1024",
  0x0020, 0x000B, 0x0006, 0x0001,
        28,       -1,       -1, G_BUTTON  ,   /* Object 27  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"2048",
  0x0027, 0x000B, 0x0006, 0x0001,
        29,       -1,       -1, G_BUTTON  ,   /* Object 28  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"4096",
  0x041C, 0x000D, 0x0006, 0x0001,
        30,       -1,       -1, G_BUTTON  ,   /* Object 29  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"8192",
  0x0423, 0x000D, 0x0006, 0x0001,
  ABORT   ,       -1,       -1, G_BUTTON  ,   /* Object 30  */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"OK",
  0x001A, 0x0810, 0x0009, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 31 ABORT */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)"ABBRUCH",
  0x0024, 0x0810, 0x0009, 0x0001,
  
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree 0 DIALOG */
  
};
