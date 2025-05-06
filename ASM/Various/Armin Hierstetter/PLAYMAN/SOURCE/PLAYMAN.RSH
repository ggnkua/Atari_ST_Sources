/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "PLAYMAN.H"

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
{ " PlayMan v1.0 ",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x11C1, 0, 0, 15, 1,
  "+0 DB",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 6, 1,
  "-0 DB",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 6, 1,
  "VERST\216RKUNG",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 12, 1,
  "D\216MPFUNG",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 9, 1,
  "+22.5 DB",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 9, 1,
  "-22.5 DB",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 9, 1,
  "\275\04792 BY ICP-VERLAG, TOS-MAGAZIN",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 32, 1,
  " Optionen ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 11, 1,
  " \232ber PlayMan ",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x11C1, 0, -1, 15, 1,
  "PROGRAMM VON",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 13, 1,
  "COPYRIGHT \275\04792",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 15, 1
};

BYTE *rs_frstr[] =
{ "[1][PlayMan: Soundsubsystem des    |Falcon wird bereits von einer  |anderen Applikation verwendet!][ Abbruch ]"
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 MAIN ****************************************************/
        -1,        1, B_OK    , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021070L,
  0x0000, 0x0000, 0x0020, 0x0010,
  B_MUSIK ,        2,       15, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x0002114FL,
  0x0000, 0x0000, 0x0020, 0x000D,
         3,       -1,       -1, G_BOXTEXT ,   /* Object 2  */
  NONE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[0],
  0x0002, 0x0001, 0x001C, 0x0001,
        14,        4,       13, G_BOX     |0x0100,   /* Object 3  */
  NONE, NORMAL, (LONG)0x00FF1170L,
  0x0002, 0x0004, 0x001C, 0x0007,
  P1      ,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0002, 0x0001, 0x0603, 0x0001,
         7, B_GAIN  , B_GAIN  , G_BOX     ,   /* Object 5 P1 */
  NONE, NORMAL, (LONG)0x00FF1148L,
  0x0002, 0x0002, 0x0018, 0x0001,
  P1      ,       -1,       -1, G_BOX     ,   /* Object 6 B_GAIN */
  EXIT|TOUCHEXIT, NORMAL, (LONG)0x00011079L,
  0x0000, 0x0000, 0x0005, 0x0001,
  P2      ,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0002, 0x0004, 0x0603, 0x0001,
        10, B_ATTEN , B_ATTEN , G_BOX     ,   /* Object 8 P2 */
  NONE, NORMAL, (LONG)0x00FF1148L,
  0x0002, 0x0005, 0x0018, 0x0001,
  P2      ,       -1,       -1, G_BOX     ,   /* Object 9 B_ATTEN */
  TOUCHEXIT, NORMAL, (LONG)0x00011179L,
  0x0006, 0x0000, 0x0005, 0x0001,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x000A, 0x0001, 0x0208, 0x0001,
        12,       -1,       -1, G_TEXT    ,   /* Object 11  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x000B, 0x0004, 0x0006, 0x0001,
        13,       -1,       -1, G_TEXT    ,   /* Object 12  */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0014, 0x0001, 0x0006, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 13  */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0014, 0x0004, 0x0006, 0x0001,
        15,       -1,       -1, G_TEXT    ,   /* Object 14  */
  NONE, NORMAL, (LONG)&rs_tedinfo[7],
  0x0005, 0x0002, 0x0217, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 15  */
  NONE, NORMAL, (LONG)&rs_tedinfo[8],
  0x0004, 0x0003, 0x000A, 0x0002,
  B_INFO  ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 16 B_MUSIK */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"Musik",
  0x0003, 0x000E, 0x0006, 0x0001,
  B_OK    ,       -1,       -1, G_BUTTON  |0x0200,   /* Object 17 B_INFO */
  SELECTABLE|EXIT, NORMAL, (LONG)"\232ber...",
  0x000C, 0x000E, 0x0008, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x0200,   /* Object 18 B_OK */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)" OK ",
  0x0016, 0x000E, 0x0007, 0x0001,
  
  /******** Tree 1 ABOUT ****************************************************/
        -1,        1,        8, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x001A, 0x000E,
         2,       -1,       -1, G_BOXTEXT ,   /* Object 1  */
  SELECTABLE, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[9],
  0x0002, 0x0001, 0x0016, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[10],
  0x0003, 0x0003, 0x0009, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Armin Hierstetter",
  0x0004, 0x0004, 0x0011, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[11],
  0x0003, 0x0006, 0x040A, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"ICP-Verlag GmbH",
  0x0004, 0x0007, 0x0011, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"Wendelsteinstr.3",
  0x0005, 0x0008, 0x0011, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"8011 Vaterstetten",
  0x0006, 0x0009, 0x0011, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x0200,   /* Object 8  */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)"OK",
  0x000E, 0x000C, 0x0009, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MAIN     */
  &rs_object[19]    /* Tree  1 ABOUT    */
};
