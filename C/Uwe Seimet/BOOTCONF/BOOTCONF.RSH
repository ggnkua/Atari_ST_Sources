/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "BOOTCONF.H"

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
{ "1992 by Uwe Seimet",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1480, 0, -1, 19, 1,
  "Franz.",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 7, 1,
  "Deutsch",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 8, 1,
  "@",
  "Separator: _",
  "X",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 13
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 DIALOG ****************************************************/
        -1,        1, ABORT   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x003F, 0x0817,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"Boot-Konfiguration Falcon030/TT",
  0x0010, 0x0001, 0x001F, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0019, 0x0002, 0x040D, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Farben:",
  0x0006, 0x0804, 0x0007, 0x0001,
        10, COLOURS ,        9, G_BOX     ,   /* Object 4  */
  NONE, NORMAL, (LONG)0x00001101L,
  0x000E, 0x0804, 0x0027, 0x0001,
         6,       -1,       -1, G_BUTTON  |0x0100,   /* Object 5 COLOURS */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"2",
  0x0000, 0x0000, 0x0007, 0x0001,
         7,       -1,       -1, G_BUTTON  |0x0100,   /* Object 6  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"4",
  0x0008, 0x0000, 0x0007, 0x0001,
         8,       -1,       -1, G_BUTTON  |0x0100,   /* Object 7  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"16",
  0x0010, 0x0000, 0x0007, 0x0001,
         9,       -1,       -1, G_BUTTON  |0x0100,   /* Object 8  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"256",
  0x0018, 0x0000, 0x0007, 0x0001,
         4,       -1,       -1, G_BUTTON  |0x0100,   /* Object 9  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"65536",
  0x0020, 0x0000, 0x0007, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"Videonorm:",
  0x0003, 0x0006, 0x000A, 0x0001,
        14, PALMODE , NTSCMODE, G_BOX     ,   /* Object 11  */
  NONE, NORMAL, (LONG)0x00001101L,
  0x000E, 0x0006, 0x000D, 0x0001,
  NTSCMODE,       -1,       -1, G_BUTTON  |0x0100,   /* Object 12 PALMODE */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"PAL",
  0x0000, 0x0000, 0x0006, 0x0001,
        11,       -1,       -1, G_BUTTON  |0x0100,   /* Object 13 NTSCMODE */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"NTSC",
  0x0007, 0x0000, 0x0006, 0x0001,
        17, VGAMODE , TVMODE  , G_BOX     ,   /* Object 14  */
  NONE, NORMAL, (LONG)0x00001101L,
  0x001D, 0x0006, 0x000B, 0x0001,
  TVMODE  ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 15 VGAMODE */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"VGA",
  0x0000, 0x0000, 0x0005, 0x0001,
        14,       -1,       -1, G_BUTTON  |0x0100,   /* Object 16 TVMODE */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"TV",
  0x0006, 0x0000, 0x0005, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, NORMAL, (LONG)"Spalten:",
  0x002B, 0x0006, 0x0008, 0x0001,
        21, COLS40  , COLS80  , G_BOX     ,   /* Object 18  */
  NONE, NORMAL, (LONG)0x00001101L,
  0x0034, 0x0006, 0x0009, 0x0001,
  COLS80  ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 19 COLS40 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"40",
  0x0000, 0x0000, 0x0004, 0x0001,
        18,       -1,       -1, G_BUTTON  |0x0100,   /* Object 20 COLS80 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"80",
  0x0005, 0x0000, 0x0004, 0x0001,
  INTRLACE,       -1,       -1, G_STRING  ,   /* Object 21  */
  NONE, NORMAL, (LONG)"Videomodus:",
  0x0002, 0x0807, 0x000B, 0x0001,
  OVRSCAN ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 22 INTRLACE */
  SELECTABLE, NORMAL, (LONG)"Zeilenverdopplung (VGA) / Halbbildmodus (TV)",
  0x000E, 0x0807, 0x002F, 0x0001,
  STMODE  ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 23 OVRSCAN */
  SELECTABLE, NORMAL, (LONG)"Overscan (nur TV)",
  0x000E, 0x0009, 0x0017, 0x0001,
        25,       -1,       -1, G_BUTTON  |0x0100,   /* Object 24 STMODE */
  SELECTABLE, NORMAL, (LONG)"Kompatibilit\204tsmodus",
  0x0026, 0x0009, 0x0017, 0x0001,
        26,       -1,       -1, G_STRING  ,   /* Object 25  */
  NONE, NORMAL, (LONG)"Sprache:",
  0x0005, 0x000B, 0x0008, 0x0001,
        32, LANG_GB , LANG_I  , G_BOX     ,   /* Object 26  */
  NONE, NORMAL, (LONG)0x00001101L,
  0x000E, 0x000B, 0x001D, 0x0001,
  LANG_D  ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 27 LANG_GB */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"GB",
  0x0000, 0x0000, 0x0005, 0x0001,
  LANG_F  ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 28 LANG_D */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"D",
  0x0006, 0x0000, 0x0005, 0x0001,
  LANG_ESP,       -1,       -1, G_BUTTON  |0x0100,   /* Object 29 LANG_F */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"F",
  0x000C, 0x0000, 0x0005, 0x0001,
  LANG_I  ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 30 LANG_ESP */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"ESP",
  0x0012, 0x0000, 0x0005, 0x0001,
        26,       -1,       -1, G_BUTTON  |0x0100,   /* Object 31 LANG_I */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"I",
  0x0018, 0x0000, 0x0005, 0x0001,
        33,       -1,       -1, G_STRING  ,   /* Object 32  */
  NONE, NORMAL, (LONG)"Tastatur:",
  0x0004, 0x000D, 0x0009, 0x0001,
        42, KEY_GB  , KEY_CHD , G_BOX     ,   /* Object 33  */
  NONE, NORMAL, (LONG)0x00001101L,
  0x000E, 0x000D, 0x002F, 0x0001,
  KEY_D   ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 34 KEY_GB */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"GB",
  0x0000, 0x0000, 0x0005, 0x0001,
  KEY_F   ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 35 KEY_D */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"D",
  0x0006, 0x0000, 0x0005, 0x0001,
  KEY_ESP ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 36 KEY_F */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"F",
  0x000C, 0x0000, 0x0005, 0x0001,
  KEY_I   ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 37 KEY_ESP */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"ESP",
  0x0012, 0x0000, 0x0005, 0x0001,
  KEY_USA ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 38 KEY_I */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"I",
  0x0018, 0x0000, 0x0005, 0x0001,
  KEY_CHF ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 39 KEY_USA */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"USA",
  0x001E, 0x0000, 0x0005, 0x0001,
  KEY_CHD ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 40 KEY_CHF */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"CH",
  0x0024, 0x0000, 0x0005, 0x0001,
        33,       -1,       -1, G_BUTTON  |0x0100,   /* Object 41 KEY_CHD */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"CH",
  0x002A, 0x0000, 0x0005, 0x0001,
        43,       -1,       -1, G_TEXT    ,   /* Object 42  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0032, 0x000E, 0x0404, 0x0001,
        44,       -1,       -1, G_TEXT    ,   /* Object 43  */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0038, 0x000E, 0x0205, 0x0001,
        45,       -1,       -1, G_STRING  ,   /* Object 44  */
  NONE, NORMAL, (LONG)"Uhrzeit:",
  0x0005, 0x000F, 0x0008, 0x0001,
        48, HOURS12 ,       47, G_BOX     ,   /* Object 45  */
  NONE, NORMAL, (LONG)0x00001101L,
  0x000E, 0x000F, 0x0019, 0x0001,
        47,       -1,       -1, G_BUTTON  |0x0100,   /* Object 46 HOURS12 */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"12 Stunden",
  0x0000, 0x0000, 0x000C, 0x0001,
        45,       -1,       -1, G_BUTTON  |0x0100,   /* Object 47  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"24 Stunden",
  0x000D, 0x0000, 0x000C, 0x0001,
        49,       -1,       -1, G_STRING  ,   /* Object 48  */
  NONE, NORMAL, (LONG)"Datum:",
  0x0007, 0x0011, 0x0006, 0x0001,
  SEPERATOR, DATE    ,       52, G_BOX     ,   /* Object 49  */
  NONE, NORMAL, (LONG)0x00001101L,
  0x000E, 0x0011, 0x001E, 0x0001,
        51,       -1,       -1, G_BUTTON  |0x0100,   /* Object 50 DATE */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"MM-TT-JJ",
  0x0000, 0x0000, 0x000A, 0x0001,
        52,       -1,       -1, G_BUTTON  |0x0100,   /* Object 51  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"TT-MM-JJ",
  0x000B, 0x0000, 0x0009, 0x0001,
        49,       -1,       -1, G_BUTTON  |0x0100,   /* Object 52  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"JJ-MM-TT",
  0x0015, 0x0000, 0x0009, 0x0001,
        54,       -1,       -1, G_FTEXT   ,   /* Object 53 SEPERATOR */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0031, 0x0011, 0x000C, 0x0001,
  NOPREF  ,       -1,       -1, G_STRING  ,   /* Object 54  */
  NONE, NORMAL, (LONG)"Pr\204ferenz:",
  0x0003, 0x0013, 0x000A, 0x0001,
  TOS     ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 55 NOPREF */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"keine",
  0x000E, 0x0013, 0x0007, 0x0001,
  UNIX    ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 56 TOS */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"TOS",
  0x0016, 0x0013, 0x0007, 0x0001,
  OK      ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 57 UNIX */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"UNIX",
  0x001E, 0x0013, 0x0007, 0x0001,
  ABORT   ,       -1,       -1, G_BUTTON  |0x0200,   /* Object 58 OK */
  SELECTABLE|DEFAULT|EXIT, NORMAL, (LONG)"OK",
  0x0016, 0x0815, 0x0009, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x0200,   /* Object 59 ABORT */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)"Abbruch",
  0x0021, 0x0815, 0x0009, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 DIALOG   */
};
