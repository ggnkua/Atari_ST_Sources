/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "MAGNCONF.H"

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
{ "   ",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, 0, 4, 1,
  "\275 1995-98 Michael Schwingen",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 28, 1
};

BYTE *rs_frstr[] =
{ "[9][Lesefehler oder|falscher Treiber][OK]",
  "[9][Schreibfehler!][OK]",
  "MAGNUM.PRG laden:",
  "Parameter sichern:"
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 MAIN ****************************************************/
        -1, M_HELP          , M_OPT5          , G_BOX             ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0220, 0x000B,
         3,        2,        2, G_TEXT            |0x1500,   /* Object 1 M_HELP */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[0],
  0x001E, 0x0000, 0x0202, 0x0001,
  M_HELP          ,       -1,       -1, G_IBOX            |0x1100,   /* Object 2  */
  TOUCHEXIT, CROSSED|OUTLINED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
         4,       -1,       -1, G_STRING          |0x1300,   /* Object 3  */
  NONE, NORMAL, (LONG)"MAGNUM Konfiguration:",
  0x0002, 0x0001, 0x0015, 0x0001,
  M_PARBOX        ,       -1,       -1, G_TEXT            ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0002, 0x0002, 0x0214, 0x0001,
  M_SAVE          , M_OPT1          , M_OPT4          , G_IBOX            ,   /* Object 5 M_PARBOX */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0001, 0x0003, 0x001E, 0x0004,
  M_OPT2          ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 6 M_OPT1 */
  SELECTABLE, NORMAL, (LONG)"ausf\201hrlicher [Ramtest",
  0x0001, 0x0000, 0x001C, 0x0001,
  M_OPT3          ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 7 M_OPT2 */
  SELECTABLE, NORMAL, (LONG)"[Blitter auf 8MHz schalten",
  0x0001, 0x0001, 0x001C, 0x0001,
  M_OPT4          ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 8 M_OPT3 */
  SELECTABLE, NORMAL, (LONG)"[Nova-Kompatibilit\204t",
  0x0001, 0x0002, 0x001C, 0x0001,
  M_PARBOX        ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 9 M_OPT4 */
  SELECTABLE, NORMAL, (LONG)"[kein Ramtest",
  0x0001, 0x0003, 0x001C, 0x0001,
  M_QUIT          ,       -1,       -1, G_BUTTON          ,   /* Object 10 M_SAVE */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"Speichern",
  0x0002, 0x0009, 0x000B, 0x0001,
  M_OPT5          ,       -1,       -1, G_BUTTON          |0x1200,   /* Object 11 M_QUIT */
  SELECTABLE|EXIT|FLAGS11, NORMAL, (LONG)"[Abbruch",
  0x0013, 0x0009, 0x000B, 0x0001,
         0,       -1,       -1, G_BUTTON          |0x1200,   /* Object 12 M_OPT5 */
  SELECTABLE|LASTOB, NORMAL, (LONG)"[STE auf 16MHz schalten",
  0x0002, 0x0007, 0x001C, 0x0001,
  
  /******** Tree 1 HELP ****************************************************/
        -1,        1, H_ID            , G_BOX             ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0040, 0x0008,
         2,       -1,       -1, G_STRING          |0x1300,   /* Object 1  */
  NONE, NORMAL, (LONG)"\201ber MAGNUM Konfiguration:",
  0x0002, 0x0001, 0x001A, 0x0001,
         3,       -1,       -1, G_BUTTON          ,   /* Object 2  */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"OK",
  0x0033, 0x0006, 0x000B, 0x0001,
         4,       -1,       -1, G_IBOX            |0x1100,   /* Object 3  */
  TOUCHEXIT, CROSSED|OUTLINED, (LONG)0x00FF1100L,
  0x003E, 0x0000, 0x0002, 0x0001,
         5,       -1,       -1, G_STRING          ,   /* Object 4  */
  NONE, NORMAL, (LONG)"\275 1995-98 Michael Schwingen, rincewind@discworld.dascon.de",
  0x0002, 0x0003, 0x003A, 0x0001,
  H_ID            ,       -1,       -1, G_STRING          ,   /* Object 5  */
  NONE, NORMAL, (LONG)"MyDials von Olaf Meisiek",
  0x0002, 0x0006, 0x0018, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 6 H_ID */
  LASTOB, NORMAL, (LONG)"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  0x0002, 0x0004, 0x003C, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MAIN             */
  &rs_object[13]    /* Tree  1 HELP             */
};
