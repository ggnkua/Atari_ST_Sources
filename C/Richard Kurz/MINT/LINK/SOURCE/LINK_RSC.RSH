/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "LINK_RSC.H"

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
{ "Symb.-Link anlegen",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 19, 1,
  "Link anzeigen",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 14, 1,
  "Link l\224schen",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 13, 1,
  "123456789012345678901234567890",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "123456789012345678901234567890",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "123456789012345678901234567890",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "123456789012345678901234567890",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 31, 1,
  "Symb.-Link anlegen",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 19, 1,
  "Link anzeigen",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 14, 1,
  "Link l\224schen",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 13, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 DIALOG ****************************************************/
        -1, SYMBLINK, LOESCHEN, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1131L,
  0x0000, 0x0000, 0x0018, 0x000A,
  READLINK,       -1,       -1, G_BOXTEXT ,   /* Object 1 SYMBLINK */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[0],
  0x0001, 0x0001, 0x0016, 0x0001,
         3,       -1,       -1, G_BOXTEXT ,   /* Object 2 READLINK */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[1],
  0x0001, 0x0003, 0x0016, 0x0001,
  LOESCHEN, ENDE    , BYRK    , G_BOX     ,   /* Object 3  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0007, 0x0018, 0x0003,
  HILFE   ,       -1,       -1, G_BUTTON  ,   /* Object 4 ENDE */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"OK",
  0x0011, 0x0001, 0x0006, 0x0001,
  BYRK    ,       -1,       -1, G_BUTTON  ,   /* Object 5 HILFE */
  SELECTABLE|EXIT, NORMAL, (LONG)"Hilfe",
  0x0001, 0x0001, 0x0006, 0x0001,
         3,       -1,       -1, G_BUTTON  ,   /* Object 6 BYRK */
  SELECTABLE|EXIT, NORMAL, (LONG)"Info",
  0x0009, 0x0001, 0x0006, 0x0001,
         0,       -1,       -1, G_BOXTEXT ,   /* Object 7 LOESCHEN */
  SELECTABLE|EXIT|LASTOB, SHADOWED, (LONG)&rs_tedinfo[2],
  0x0001, 0x0005, 0x0016, 0x0001,
  
  /******** Tree 1 MELDUNG ****************************************************/
        -1, FZ1     ,        5, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1181L,
  0x0000, 0x0000, 0x0020, 0x0009,
  FZ2     ,       -1,       -1, G_TEXT    ,   /* Object 1 FZ1 */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0001, 0x0001, 0x001E, 0x0001,
  FZ3     ,       -1,       -1, G_TEXT    ,   /* Object 2 FZ2 */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0001, 0x0003, 0x001E, 0x0001,
  FZ4     ,       -1,       -1, G_TEXT    ,   /* Object 3 FZ3 */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0001, 0x0004, 0x001E, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4 FZ4 */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0001, 0x0005, 0x001E, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 5  */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)"OK",
  0x0016, 0x0007, 0x0009, 0x0001,
  
  /******** Tree 2 EINFO ****************************************************/
        -1,        1,       10, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0022, 0x0011,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"Demonstration f\201r die",
  0x0007, 0x0004, 0x0015, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"Programmierung unter MiNT",
  0x0005, 0x0005, 0x0019, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)" \275 1992 by Richard Kurz",
  0x0006, 0x0007, 0x0017, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Vogelherdbogen 62",
  0x0009, 0x0008, 0x0011, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"7992 Tettnang",
  0x000B, 0x0009, 0x000D, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"TOS-Magazin",
  0x000C, 0x000C, 0x000B, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"ICP-Verlag GmbH & Co. KG",
  0x0005, 0x000D, 0x0018, 0x0001,
         9,       -1,       -1, G_BUTTON  ,   /* Object 8  */
  NONE, SHADOWED, (LONG)"Link V1.0",
  0x0003, 0x0001, 0x001C, 0x0002,
        10,       -1,       -1, G_BUTTON  ,   /* Object 9  */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"Okay",
  0x000D, 0x000F, 0x0008, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 10  */
  LASTOB, NORMAL, (LONG)"Fido: 2:241/7232.5",
  0x0008, 0x000A, 0x0012, 0x0001,
  
  /******** Tree 3 HELP ****************************************************/
        -1,        1,        9, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0000, 0x0022, 0x0011,
         2,       -1,       -1, G_BOXTEXT ,   /* Object 1  */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[7],
  0x0001, 0x0001, 0x0016, 0x0001,
         3,       -1,       -1, G_BOXTEXT ,   /* Object 2  */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[8],
  0x0001, 0x0005, 0x0016, 0x0001,
         4,       -1,       -1, G_BOXTEXT ,   /* Object 3  */
  SELECTABLE|EXIT, SHADOWED, (LONG)&rs_tedinfo[9],
  0x0001, 0x000A, 0x0016, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"Legt einen symbolischen Link an.",
  0x0001, 0x0003, 0x0020, 0x0001,
         6,       -1,       -1, G_BUTTON  ,   /* Object 5  */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"OK",
  0x0016, 0x000F, 0x0009, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"Zeigt den original Pfad eines",
  0x0001, 0x0007, 0x001D, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"Links an.",
  0x0001, 0x0008, 0x0009, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"L\224scht einen symbolischen Link,",
  0x0001, 0x000C, 0x001F, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 9  */
  LASTOB, NORMAL, (LONG)"das Original bleibt erhalten.",
  0x0001, 0x000D, 0x001D, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 DIALOG   */
  &rs_object[8],   /* Tree  1 MELDUNG  */
  &rs_object[14],   /* Tree  2 EINFO    */
  &rs_object[25]    /* Tree  3 HELP     */
};
