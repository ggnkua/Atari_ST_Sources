/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "DESIGNER.H"

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
{ "VERSION 5.0 VOM 05.04.1997",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 27, 1,
  "Seriennummer:",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 14, 1,
  "ssssssssss",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 11, 1,
  "Lizenznehmer",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 13, 1,
  "       Firma:",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 14, 1,
  "ffffffffffffffffffffffffffffff",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 31, 1,
  "        Name:",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 14, 1,
  "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 31, 1,
  "VON",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 4, 1,
  "DIETER GEISS & J\232RGEN GEISS",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 28, 1,
  "ISBN: 3-7785-1792-9",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 20, 1,
  "(C) 1990 - 1993",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 16, 1,
  "H\232THIG BUCH VERLAG",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 19, 1,
  "IM WEIHER 10",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 13, 1,
  "69121 HEIDELBERG 1",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 19, 1,
  "GERMANY",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 8, 1,
  "____________",
  "____________",
  "XXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 13, 13,
  "________________________________",
  "________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 33, 33,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "Breite:",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 8, 1,
  "9999",
  "\0",
  "\0",
  IBM  , 0, TE_RIGHT, 0x1180, 0, -1, 5, 1,
  "H\224he:",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 1,
  "9999",
  "\0",
  "\0",
  IBM  , 0, TE_RIGHT, 0x1180, 0, -1, 5, 1,
  "3",
  "_",
  "9",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 2,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "400_",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "400_",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "999",
  "___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 4,
  "75__",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "16__",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "1",
  "_",
  "9",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 2,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "64___",
  "_____",
  "99999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 6,
  "64___",
  "_____",
  "99999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 6,
  "_________________________________",
  "_________________________________",
  "FXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "________",
  "________",
  "99999999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 9, 9,
  "________",
  "________",
  "99999999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 9, 9,
  "________",
  "________",
  "99999999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 9, 9,
  "__",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "__",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "99",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 1,
  "________________________________________",
  "________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 41,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  " Ger\204tetyp ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1480, 0, 0, 12, 1,
  "XXXXXXXXXX",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 11, 1,
  "99 Punkt",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 9, 1,
  "16___",
  "_____",
  "99999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 6,
  "16___",
  "_____",
  "99999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 6, 6,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "___________",
  "___________",
  "XXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 12, 12,
  "___________",
  "___________",
  "XXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 12, 12,
  "__",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "8_",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "4_",
  "__",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 3,
  "9999",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "9999",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____________________________________________________________",
  "____________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 61, 61,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____________________________________________________________",
  "____________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 61, 61,
  "____________________________________________________________",
  "____________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 61, 61,
  "____________________________________________________________",
  "____________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 61, 61,
  "____________________________________________________________",
  "____________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 61, 61,
  "________________________________________",
  "________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 41,
  "________________________________________",
  "________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 41,
  "__________________________________________________",
  "__________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 51, 51,
  "__________________________________________________",
  "__________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 51, 51,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____________________________________________________",
  "____________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 53, 53,
  "____________________________________________________",
  "____________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 53, 53,
  "____________________________________________________",
  "____________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 53, 53,
  "____________________________________________________",
  "____________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 53, 53,
  "____________________________________________________",
  "____________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 53, 53,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "_________________________________",
  "_________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 34, 34,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "____",
  "____",
  "9999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 5, 5,
  "VON",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 4, 1,
  "DIPL.-INFORM.",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 14, 1,
  "DIPL.-INFORM.",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 14, 1,
  "DIETER GEISS",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 13, 1,
  "&",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 2, 1,
  "J\232RGEN GEISS",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 13, 1,
  "(c) 1993",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 9, 1,
  "APPLICATION SYSTEMS /// HEIDELBERG",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 35, 1,
  "POSTFACH 102646",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 16, 1,
  "69126 HEIDELBERG",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 17, 1,
  "GERMANY",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, -1, 8, 1
};

RSIB0MASK[] =
{ 0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

RSIB0DATA[] =
{ 0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x5AFE, 0xBAFA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

RSIB1MASK[] =
{ 0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

RSIB1DATA[] =
{ 0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x5AFE, 0xBAFA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x6AAA, 0xAAAA, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x4200, 0x8202, 0x0000, 
  0x0000, 0x7FFF, 0xFFFE, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
};

ICONBLK rs_iconblk[] =
{ RSIB0MASK, RSIB0DATA, "123456789012", 0x1000|'\0',
    0,   0,   4,   0,  64,  32,   0,  32,  72,   8,
  RSIB1MASK, RSIB1DATA, "TABELLE\000\000\000\000\000", 0x1000|'\0',
    0,   0,   4,   0,  64,  32,   0,  32,  72,   8
};

WORD RSBB0DATA[] =
{ 0x03C0, 0x0C30, 0x1008, 0x1008, 
  0x2004, 0x2004, 0x2004, 0x2004, 
  0x1008, 0x1008, 0x0C30, 0x03C0
};

WORD RSBB1DATA[] =
{ 0x03C0, 0x0C30, 0x1008, 0x13C8, 
  0x27E4, 0x27E4, 0x27E4, 0x27E4, 
  0x13C8, 0x1008, 0x0C30, 0x03C0
};

WORD RSBB2DATA[] =
{ 0x3FFC, 0x2004, 0x2004, 0x2004, 
  0x2004, 0x2004, 0x2004, 0x2004, 
  0x2004, 0x2004, 0x2004, 0x3FFC
};

WORD RSBB3DATA[] =
{ 0x3FFC, 0x300C, 0x2814, 0x2424, 
  0x2244, 0x2184, 0x2184, 0x2244, 
  0x2424, 0x2814, 0x300C, 0x3FFC
};

WORD RSBB4DATA[] =
{ 0x0FF0, 0x781E, 0xE007, 0xC003, 
  0xC003, 0xE007, 0x781E, 0x0FF0
};

WORD RSBB5DATA[] =
{ 0x0FF0, 0x781E, 0xE3C7, 0xCFF3, 
  0xCFF3, 0xE3C7, 0x781E, 0x0FF0
};

WORD RSBB6DATA[] =
{ 0x3FFC, 0x2004, 0x2004, 0x2004, 
  0x2004, 0x2004, 0x3FFC, 0x0000
};

WORD RSBB7DATA[] =
{ 0x3FFC, 0x381C, 0x2664, 0x2184, 
  0x2664, 0x381C, 0x3FFC, 0x0000
};

WORD RSBB8DATA[] =
{ 0x0380, 0x0440, 0x0820, 0x0820, 
  0x0820, 0x0440, 0x0380
};

WORD RSBB9DATA[] =
{ 0x0380, 0x0440, 0x0920, 0x0BA0, 
  0x0920, 0x0440, 0x0380
};

WORD RSBB10DATA[] =
{ 0x07F0, 0x0410, 0x0410, 0x0410, 
  0x0410, 0x0410, 0x07F0
};

WORD RSBB11DATA[] =
{ 0x07F0, 0x0630, 0x0550, 0x0490, 
  0x0550, 0x0630, 0x07F0
};

WORD RSBB12DATA[] =
{ 0x0380, 0x0440, 0x0440, 0x0440, 
  0x0380
};

WORD RSBB13DATA[] =
{ 0x0380, 0x0440, 0x0540, 0x0440, 
  0x0380
};

WORD RSBB14DATA[] =
{ 0x03E0, 0x0220, 0x0220, 0x0220, 
  0x03E0
};

WORD RSBB15DATA[] =
{ 0x03E0, 0x0360, 0x02A0, 0x0360, 
  0x03E0
};

WORD RSBB16DATA[] =
{ 0x1000, 0x1000, 0x7C00, 0x3800, 
  0x1000, 0x7C00
};

WORD RSBB17DATA[] =
{ 0x1C00, 0x1C00, 0x1C00, 0x7F00, 
  0x3E00, 0x1C00, 0x0800, 0x7F00
};

WORD RSBB18DATA[] =
{ 0x0E00, 0x0E00, 0x0E00, 0x0E00, 
  0x3F80, 0x1F00, 0x0E00, 0x0400, 
  0x0000, 0x3F80
};

WORD RSBB19DATA[] =
{ 0x0700, 0x0700, 0x0700, 0x0700, 
  0x0700, 0x3FE0, 0x1FC0, 0x0F80, 
  0x0700, 0x0200, 0x0000, 0x3FE0
};

WORD RSBB20DATA[] =
{ 0x07C0, 0x07C0, 0x07C0, 0x07C0, 
  0x07C0, 0x07C0, 0x3FF8, 0x1FF0, 
  0x0FE0, 0x07C0, 0x0380, 0x0100, 
  0x0000, 0x3FF8
};

WORD RSBB21DATA[] =
{ 0x03E0, 0x03E0, 0x03E0, 0x03E0, 
  0x03E0, 0x03E0, 0x03E0, 0x3FFE, 
  0x1FFC, 0x0FF8, 0x07F0, 0x03E0, 
  0x01C0, 0x0080, 0x0000, 0x3FFE
};

WORD RSBB22DATA[] =
{ 0x000F, 0xF800, 0x000F, 0xF800, 
  0x000F, 0xF800, 0x000F, 0xF800, 
  0x000F, 0xF800, 0x000F, 0xF800, 
  0x000F, 0xF800, 0x000F, 0xF800, 
  0x000F, 0xF800, 0x000F, 0xF800, 
  0x000F, 0xF800, 0x000F, 0xF800, 
  0x000F, 0xF800, 0x3FFF, 0xFFFE, 
  0x1FFF, 0xFFFC, 0x0FFF, 0xFFF8, 
  0x07FF, 0xFFF0, 0x03FF, 0xFFE0, 
  0x01FF, 0xFFC0, 0x00FF, 0xFF80, 
  0x007F, 0xFF00, 0x003F, 0xFE00, 
  0x001F, 0xFC00, 0x000F, 0xF800, 
  0x0007, 0xF000, 0x0003, 0xE000, 
  0x0001, 0xC000, 0x0000, 0x8000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x3FFF, 0xFFFE, 0x3FFF, 0xFFFE
};

WORD RSBB23DATA[] =
{ 0x3FFF, 0xFFFC, 0x7FFF, 0xFFFE, 
  0x7FFC, 0x3FFE, 0x7FF8, 0x1FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF8, 0x1FFE, 
  0x7FFC, 0x3FFE, 0x7FFF, 0xFFFE, 
  0x7FFF, 0xFFFE, 0x7F80, 0x0FFE, 
  0x7F80, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7F80, 0x01FE, 
  0x7F80, 0x01FE, 0x7FFF, 0xFFFE, 
  0x3FFF, 0xFFFC, 0x0000, 0x0000
};

WORD RSBB24DATA[] =
{ 0x0003, 0xC000, 0x0006, 0x6000, 
  0x000D, 0xB000, 0x001B, 0xD800, 
  0x0037, 0xEC00, 0x006F, 0xF600, 
  0x00DC, 0x3B00, 0x01BC, 0x3D80, 
  0x037C, 0x3EC0, 0x06FC, 0x3F60, 
  0x0DFC, 0x3FB0, 0x1BFC, 0x3FD8, 
  0x37FC, 0x3FEC, 0x6FFC, 0x3FF6, 
  0xDFFC, 0x3FFB, 0xBFFC, 0x3FFD, 
  0xBFFC, 0x3FFD, 0xDFFC, 0x3FFB, 
  0x6FFC, 0x3FF6, 0x37FC, 0x3FEC, 
  0x1BFF, 0xFFD8, 0x0DFF, 0xFFB0, 
  0x06FC, 0x3F60, 0x037C, 0x3EC0, 
  0x01BC, 0x3D80, 0x00DC, 0x3B00, 
  0x006F, 0xF600, 0x0037, 0xEC00, 
  0x001B, 0xD800, 0x000D, 0xB000, 
  0x0006, 0x6000, 0x0003, 0xC000
};

WORD RSBB25DATA[] =
{ 0x3FFF, 0xFFFC, 0xC000, 0x0003, 
  0x9FFF, 0xFFF9, 0xBFFF, 0xFFFD, 
  0xDFF8, 0x3FFB, 0x5FE0, 0x0FFA, 
  0x6FC0, 0x07F6, 0x2F83, 0x83F4, 
  0x3787, 0xC3EC, 0x1787, 0xC3E8, 
  0x1BFF, 0x83D8, 0x0BFF, 0x07D0, 
  0x0DFE, 0x0FB0, 0x05FC, 0x1FA0, 
  0x06FC, 0x3F60, 0x02FC, 0x3F40, 
  0x037C, 0x3EC0, 0x017C, 0x3E80, 
  0x01BF, 0xFD80, 0x00BF, 0xFD00, 
  0x00DC, 0x3B00, 0x005C, 0x3A00, 
  0x006C, 0x3600, 0x002F, 0xF400, 
  0x0037, 0xEC00, 0x0017, 0xE800, 
  0x001B, 0xD800, 0x000B, 0xD000, 
  0x000D, 0xB000, 0x0005, 0xA000, 
  0x0006, 0x6000, 0x0003, 0xC000
};

WORD RSBB26DATA[] =
{ 0x007F, 0xFE00, 0x00C0, 0x0300, 
  0x01BF, 0xFD80, 0x037F, 0xFEC0, 
  0x06FF, 0xFF60, 0x0DFF, 0xFFB0, 
  0x1BFF, 0xFFD8, 0x37FF, 0xFFEC, 
  0x6FFF, 0xFFF6, 0xDFFF, 0xFFFB, 
  0xB181, 0x860D, 0xA081, 0x0205, 
  0xA4E7, 0x3265, 0xA7E7, 0x3265, 
  0xA3E7, 0x3265, 0xB1E7, 0x3205, 
  0xB8E7, 0x320D, 0xBCE7, 0x327D, 
  0xA4E7, 0x327D, 0xA0E7, 0x027D, 
  0xB1E7, 0x867D, 0xBFFF, 0xFFFD, 
  0xDFFF, 0xFFFB, 0x6FFF, 0xFFF6, 
  0x37FF, 0xFFEC, 0x1BFF, 0xFFD8, 
  0x0DFF, 0xFFB0, 0x06FF, 0xFF60, 
  0x037F, 0xFEC0, 0x01BF, 0xFD80, 
  0x00C0, 0x0300, 0x007F, 0xFE00
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,   2,  12,   0,   0, 0x0001,
  RSBB1DATA,   2,  12,   0,   0, 0x0001,
  RSBB2DATA,   2,  12,   0,   0, 0x0001,
  RSBB3DATA,   2,  12,   0,   0, 0x0001,
  RSBB4DATA,   2,   8,   0,   0, 0x0001,
  RSBB5DATA,   2,   8,   0,   0, 0x0001,
  RSBB6DATA,   2,   8,   0,   0, 0x0001,
  RSBB7DATA,   2,   8,   0,   0, 0x0001,
  RSBB8DATA,   2,   7,   0,   0, 0x0001,
  RSBB9DATA,   2,   7,   0,   0, 0x0001,
  RSBB10DATA,   2,   7,   0,   0, 0x0001,
  RSBB11DATA,   2,   7,   0,   0, 0x0001,
  RSBB12DATA,   2,   5,   0,   0, 0x0001,
  RSBB13DATA,   2,   5,   0,   0, 0x0001,
  RSBB14DATA,   2,   5,   0,   0, 0x0001,
  RSBB15DATA,   2,   5,   0,   0, 0x0001,
  RSBB16DATA,   2,   6,   0,   0, 0x0001,
  RSBB17DATA,   2,   8,   0,   0, 0x0001,
  RSBB18DATA,   2,  10,   0,   0, 0x0001,
  RSBB19DATA,   2,  12,   0,   0, 0x0001,
  RSBB20DATA,   2,  14,   0,   0, 0x0001,
  RSBB21DATA,   2,  16,   0,   0, 0x0001,
  RSBB22DATA,   4,  32,   0,   0, 0x0001,
  RSBB23DATA,   4,  32,   0,   0, 0x0004,
  RSBB24DATA,   4,  32,   0,   0, 0x000B,
  RSBB25DATA,   4,  32,   0,   0, 0x000F,
  RSBB26DATA,   4,  32,   0,   0, 0x0002
};

WORD RS0_MMASK[] =
{ 0x0038, 0x0000, 0x01FE, 0x0000, 
  0x0FFF, 0x8000, 0x3FFF, 0xE000, 
  0x7FFF, 0xF800, 0x7FFF, 0xFE00, 
  0x7FFF, 0xFF80, 0x7FFF, 0xFFE0, 
  0x7FFF, 0xFFF8, 0x3FFF, 0xFFFC, 
  0x3FFF, 0xFFFC, 0x3FFF, 0xFFFC, 
  0x3FFF, 0xFFFC, 0x1FFF, 0xFFF8, 
  0x1FFF, 0xFFF8, 0x1FFF, 0xFFF8, 
  0x1FFF, 0xFFF8, 0x0FFF, 0xFFF0, 
  0x0FFF, 0xFFF0, 0x0FFF, 0xFFF0, 
  0x0FFF, 0xFFF0, 0x07FF, 0xFFE0, 
  0x07FF, 0xFFE0, 0x07FF, 0xFFE0, 
  0x07FF, 0xFFE0, 0x03FF, 0xFFC0, 
  0x00FF, 0xFFC0, 0x003F, 0xFFC0, 
  0x000F, 0xFFC0, 0x0003, 0xFF80, 
  0x0000, 0xFE00, 0x0000, 0x3800
};

WORD RS0_MDATA[] =
{ 0x0038, 0x0000, 0x01D6, 0x0000, 
  0x0E39, 0x8000, 0x31F8, 0x6000, 
  0x4FFC, 0x1800, 0x5FFC, 0x0600, 
  0x4FFE, 0x0180, 0x43FE, 0x0060, 
  0x40FF, 0x0018, 0x203F, 0x0004, 
  0x200F, 0x8004, 0x2003, 0xC01C, 
  0x2000, 0xC0FC, 0x101C, 0x07F8, 
  0x103E, 0x9FF8, 0x13C7, 0x9FF8, 
  0x11C3, 0x9FF8, 0x0BC7, 0x9FF0, 
  0x0B40, 0x1FF0, 0x0B00, 0x9FF0, 
  0x0B08, 0x9FF0, 0x0599, 0x9FE0, 
  0x04BF, 0x9FE0, 0x043F, 0x1FE0, 
  0x0718, 0x1FE0, 0x03C8, 0x1FC0, 
  0x00F0, 0x1FC0, 0x003C, 0x1FC0, 
  0x000F, 0x1FC0, 0x0003, 0xDF80, 
  0x0000, 0xFE00, 0x0000, 0x3800
};

WORD RS0_4CMASK[] =
{ 0x0038, 0x0000, 0x01FE, 0x0000, 
  0x0FFF, 0x8000, 0x3FFF, 0xE000, 
  0x7FFF, 0xF800, 0x7FFF, 0xFE00, 
  0x7FFF, 0xFF80, 0x7FFF, 0xFFE0, 
  0x7FFF, 0xFFF8, 0x3FFF, 0xFFFC, 
  0x3FFF, 0xFFFC, 0x3FFF, 0xFFFC, 
  0x3FFF, 0xFFFC, 0x1FFF, 0xFFF8, 
  0x1FFF, 0xFFF8, 0x1FFF, 0xFFF8, 
  0x1FFF, 0xFFF8, 0x0FFF, 0xFFF0, 
  0x0FFF, 0xFFF0, 0x0FFF, 0xFFF0, 
  0x0FFF, 0xFFF0, 0x07FF, 0xFFE0, 
  0x07FF, 0xFFE0, 0x07FF, 0xFFE0, 
  0x07FF, 0xFFE0, 0x03FF, 0xFFC0, 
  0x00FF, 0xFFC0, 0x003F, 0xFFC0, 
  0x000F, 0xFFC0, 0x0003, 0xFF80, 
  0x0000, 0xFE00, 0x0000, 0x3800
};

WORD RS0_4CDATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x0010, 0x0000, 0x0016, 0x0000, 
  0x0013, 0x8000, 0x0013, 0xE000, 
  0x0011, 0xF800, 0x3011, 0xFE00, 
  0x3C10, 0xFF80, 0x1F10, 0xFFE4, 
  0x1FC0, 0x7FE4, 0x1FF0, 0x3F04, 
  0x1FFC, 0x3804, 0x0FFF, 0x0008, 
  0x0FFF, 0xE008, 0x0FFF, 0xE008, 
  0x0FFF, 0xE008, 0x07FF, 0xE010, 
  0x07FF, 0xE010, 0x07FF, 0xE010, 
  0x07FF, 0xE010, 0x03FF, 0xE020, 
  0x03FF, 0xE020, 0x03FF, 0xE020, 
  0x00FF, 0xE020, 0x033F, 0xE040, 
  0x00CF, 0xE040, 0x0033, 0xE040, 
  0x000C, 0xE040, 0x0003, 0x2180, 
  0x0000, 0xC600, 0x0000, 0x3800, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0010, 0x0000, 0x0016, 0x0000, 
  0x0013, 0x8000, 0x0013, 0xE000, 
  0x0011, 0xF800, 0x3011, 0xFE00, 
  0x3C10, 0xFF80, 0x1F10, 0xFFE4, 
  0x1FC0, 0x7FE4, 0x1FF0, 0x3F04, 
  0x1FFC, 0x3804, 0x0FFF, 0x0008, 
  0x0FFF, 0xE008, 0x0FFF, 0xE008, 
  0x0FFF, 0xE008, 0x07FF, 0xE010, 
  0x07FF, 0xE010, 0x07FF, 0xE010, 
  0x07FF, 0xE010, 0x03FF, 0xE020, 
  0x03FF, 0xE020, 0x03FF, 0xE020, 
  0x00FF, 0xE020, 0x033F, 0xE040, 
  0x00CF, 0xE040, 0x0033, 0xE040, 
  0x000C, 0xE040, 0x0003, 0x2180, 
  0x0000, 0xC600, 0x0000, 0x3800, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0010, 0x0000, 0x0016, 0x0000, 
  0x0013, 0x8000, 0x0013, 0xE000, 
  0x0011, 0xF800, 0x3011, 0xFE00, 
  0x3C10, 0xFF80, 0x1F10, 0xFFE4, 
  0x1FC0, 0x7FE4, 0x1FF0, 0x3F04, 
  0x1FFC, 0x3804, 0x0FFF, 0x0008, 
  0x0FFF, 0xE008, 0x0FFF, 0xE008, 
  0x0FFF, 0xE008, 0x07FF, 0xE010, 
  0x07FF, 0xE010, 0x07FF, 0xE010, 
  0x07FF, 0xE010, 0x03FF, 0xE020, 
  0x03FF, 0xE020, 0x03FF, 0xE020, 
  0x00FF, 0xE020, 0x033F, 0xE040, 
  0x00CF, 0xE040, 0x0033, 0xE040, 
  0x000C, 0xE040, 0x0003, 0x2180, 
  0x0000, 0xC600, 0x0000, 0x3800, 
  0x0038, 0x0000, 0x01D6, 0x0000, 
  0x0E39, 0x8000, 0x31F8, 0x6000, 
  0x4FFC, 0x1800, 0x5FFC, 0x0600, 
  0x4FFE, 0x0180, 0x43FE, 0x0060, 
  0x40FF, 0x0018, 0x203F, 0x0004, 
  0x200F, 0x8004, 0x2003, 0xC01C, 
  0x2000, 0xC0FC, 0x1000, 0x07F8, 
  0x1000, 0x1FF8, 0x1000, 0x1FF8, 
  0x1000, 0x1FF8, 0x0800, 0x1FF0, 
  0x0800, 0x1FF0, 0x0800, 0x1FF0, 
  0x0800, 0x1FF0, 0x0400, 0x1FE0, 
  0x0400, 0x1FE0, 0x0400, 0x1FE0, 
  0x0700, 0x1FE0, 0x03C0, 0x1FC0, 
  0x00F0, 0x1FC0, 0x003C, 0x1FC0, 
  0x000F, 0x1FC0, 0x0003, 0xDF80, 
  0x0000, 0xFE00, 0x0000, 0x3800
};

WORD RS1_MMASK[] =
{ 0x0000, 0x0000, 0x00FF, 0xFC00, 
  0x01FF, 0xFE00, 0x03FF, 0xFF00, 
  0x7FFF, 0xFFF8, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x3FFF, 0xFFFC, 
  0x0000, 0x0000, 0x0000, 0x0000
};

WORD RS1_MDATA[] =
{ 0x0000, 0x0000, 0x00FF, 0xFC00, 
  0x0180, 0x0600, 0x0300, 0x0300, 
  0x7E00, 0x01F8, 0x4200, 0x018C, 
  0x43FF, 0xFF8C, 0x41FF, 0xFF8C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x7FFF, 0xFFFC, 0x3FFF, 0xFFFC, 
  0x0000, 0x0000, 0x0000, 0x0000
};

WORD RS1_4CMASK[] =
{ 0x0000, 0x0000, 0x00FF, 0xFC00, 
  0x01FF, 0xFE00, 0x03FF, 0xFF00, 
  0x7FFF, 0xFFF8, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x7FFF, 0xFFFC, 
  0x7FFF, 0xFFFC, 0x3FFF, 0xFFFC, 
  0x0000, 0x0000, 0x0000, 0x0000
};

WORD RS1_4CDATA[] =
{ 0x0000, 0x0000, 0x00FF, 0xFC00, 
  0x01FF, 0xFE00, 0x0300, 0x0700, 
  0x7FFF, 0xFFF8, 0x57FF, 0xFF5C, 
  0x6BFF, 0xFF2C, 0x5400, 0x005C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x7FFF, 0xFFFC, 0x3FFF, 0xFFFC, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x00FF, 0xFC00, 
  0x01FF, 0xFE00, 0x0300, 0x0700, 
  0x7FFF, 0xFFF8, 0x57FF, 0xFF5C, 
  0x6BFF, 0xFF2C, 0x5400, 0x005C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x7FFF, 0xFFFC, 0x3FFF, 0xFFFC, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x00FF, 0xFC00, 
  0x01FF, 0xFE00, 0x0300, 0x0700, 
  0x7FFF, 0xFFF8, 0x57FF, 0xFF5C, 
  0x6BFF, 0xFF2C, 0x5400, 0x005C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x6AAA, 0xAAAC, 0x5555, 0x555C, 
  0x7FFF, 0xFFFC, 0x3FFF, 0xFFFC, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x00FF, 0xFC00, 
  0x0180, 0x0600, 0x0300, 0x0300, 
  0x7E00, 0x01F8, 0x4200, 0x018C, 
  0x43FF, 0xFF8C, 0x41FF, 0xFF8C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x4000, 0x000C, 0x4000, 0x000C, 
  0x7FFF, 0xFFFC, 0x3FFF, 0xFFFC, 
  0x0000, 0x0000, 0x0000, 0x0000
};

CICON rs_cicon[] =
{ 4, RS0_4CDATA, RS0_4CMASK, NULL, NULL, NULL,
  4, RS1_4CDATA, RS1_4CMASK, NULL, NULL, NULL
};

CICONBLK rs_ciconblk[] =
{ RS0_MMASK, RS0_MDATA, "PAPIERKORB\000\000", 0x1000|'\0',
   14,  21,  20,   0,  32,  32,   0,  32,  72,   8, &rs_cicon[0],
  RS1_MMASK, RS1_MDATA, "KLEMMBRETT\000\000", 0x1000|'\0',
   12,  14,  20,   0,  32,  32,   0,  32,  72,   8, &rs_cicon[1]
};

WORD rgb_palette[][4] =
{ 0x03E8, 0x03E8, 0x03E8, 0x0000, 
  0x03E8, 0x0000, 0x0000, 0x0002, 
  0x0000, 0x03E8, 0x0000, 0x0003, 
  0x03E8, 0x03E8, 0x0000, 0x0006, 
  0x0000, 0x0000, 0x03E8, 0x0004, 
  0x03E8, 0x0000, 0x03E8, 0x0007, 
  0x0000, 0x03E8, 0x03E8, 0x0005, 
  0x0320, 0x0320, 0x0320, 0x0008, 
  0x01F5, 0x01F5, 0x01F5, 0x0009, 
  0x029A, 0x0000, 0x0000, 0x000A, 
  0x0000, 0x029A, 0x0000, 0x000B, 
  0x029A, 0x029A, 0x0000, 0x000E, 
  0x0000, 0x0000, 0x029A, 0x000C, 
  0x029A, 0x0000, 0x029A, 0x000F, 
  0x0000, 0x029A, 0x029A, 0x000D, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0001
};

BYTE *rs_frstr[] =
{ "[3][Es stehen keine weiteren|Fenster mehr zur Verf\201gung!][ Abbruch ]",
  "[3][Nicht gen\201gend Speicher|vorhanden, um Funktion|auszuf\201hren!][ Abbruch ]",
  "[3][Fehler beim Lesen des|Hilfe-Datensatzes f\201r Index|\042%s\042!][ Abbruch ]"
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 MENU ****************************************************/
        -1,        1,        8, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x00A0, 0x0019,
         8,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x00A0, 0x0201,
         1, MDESK   , MHELP   , G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x002E, 0x0301,
  MFILE   ,       -1,       -1, G_TITLE   ,   /* Object 3 MDESK */
  NONE, NORMAL, (LONG)" DESIGNER",
  0x0000, 0x0000, 0x000A, 0x0301,
  MEDIT   ,       -1,       -1, G_TITLE   ,   /* Object 4 MFILE */
  NONE, NORMAL, (LONG)" Datei",
  0x000A, 0x0000, 0x0007, 0x0301,
  MOPTIONS,       -1,       -1, G_TITLE   ,   /* Object 5 MEDIT */
  NONE, NORMAL, (LONG)" Bearbeiten",
  0x0011, 0x0000, 0x000C, 0x0301,
  MHELP   ,       -1,       -1, G_TITLE   ,   /* Object 6 MOPTIONS */
  NONE, NORMAL, (LONG)" Optionen",
  0x001D, 0x0000, 0x000A, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 7 MHELP */
  NONE, NORMAL, (LONG)" Hilfe ",
  0x0027, 0x0000, 0x0007, 0x0301,
         0,        9,       53, G_IBOX    ,   /* Object 8  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0013,
        18, MABOUT  ,       17, G_BOX     ,   /* Object 9  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0014, 0x0008,
        11,       -1,       -1, G_STRING  ,   /* Object 10 MABOUT */
  NONE, NORMAL, (LONG)"  \232ber Designer...",
  0x0000, 0x0000, 0x0014, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, DISABLED, (LONG)"--------------------",
  0x0000, 0x0001, 0x0014, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"  Desk Accessory 1",
  0x0000, 0x0002, 0x0014, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"  Desk Accessory 2",
  0x0000, 0x0003, 0x0014, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"  Desk Accessory 3",
  0x0000, 0x0004, 0x0014, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"  Desk Accessory 4",
  0x0000, 0x0005, 0x0014, 0x0001,
        17,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"  Desk Accessory 5",
  0x0000, 0x0006, 0x0014, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, NORMAL, (LONG)"  Desk Accessory 6",
  0x0000, 0x0007, 0x0014, 0x0001,
        34, MNEW    , MQUIT   , G_BOX     ,   /* Object 18  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000C, 0x0000, 0x001B, 0x000F,
  MOPEN   ,       -1,       -1, G_STRING  ,   /* Object 19 MNEW */
  NONE, NORMAL, (LONG)"  Neu anlegen          ^N",
  0x0000, 0x0000, 0x001B, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20 MOPEN */
  NONE, NORMAL, (LONG)"  \231ffnen...            ^O",
  0x0000, 0x0001, 0x001B, 0x0001,
  MCLOSE  ,       -1,       -1, G_STRING  ,   /* Object 21  */
  NONE, DISABLED, (LONG)"---------------------------",
  0x0000, 0x0002, 0x001B, 0x0001,
  MSAVE   ,       -1,       -1, G_STRING  ,   /* Object 22 MCLOSE */
  NONE, NORMAL, (LONG)"  Schlie\236en            ^U",
  0x0000, 0x0003, 0x001B, 0x0001,
  MSAVEAS ,       -1,       -1, G_STRING  ,   /* Object 23 MSAVE */
  NONE, NORMAL, (LONG)"  Sichern              ^S",
  0x0000, 0x0004, 0x001B, 0x0001,
  MABORT  ,       -1,       -1, G_STRING  ,   /* Object 24 MSAVEAS */
  NONE, NORMAL, (LONG)"  Sichern als...       ^M",
  0x0000, 0x0005, 0x001B, 0x0001,
        26,       -1,       -1, G_STRING  ,   /* Object 25 MABORT */
  NONE, NORMAL, (LONG)"  Abbrechen            ^B",
  0x0000, 0x0006, 0x001B, 0x0001,
  MEXPORT ,       -1,       -1, G_STRING  ,   /* Object 26  */
  NONE, DISABLED, (LONG)"---------------------------",
  0x0000, 0x0007, 0x001B, 0x0001,
  MIMPORT ,       -1,       -1, G_STRING  ,   /* Object 27 MEXPORT */
  NONE, NORMAL, (LONG)"  DBS speichern...     ^E",
  0x0000, 0x0008, 0x001B, 0x0001,
  MASCEXP ,       -1,       -1, G_STRING  ,   /* Object 28 MIMPORT */
  NONE, NORMAL, (LONG)"  DBS laden...         ^L",
  0x0000, 0x0009, 0x001B, 0x0001,
        30,       -1,       -1, G_STRING  ,   /* Object 29 MASCEXP */
  NONE, NORMAL, (LONG)"  ASCII exportieren... ^F",
  0x0000, 0x000A, 0x001B, 0x0001,
  MPRINT  ,       -1,       -1, G_STRING  ,   /* Object 30  */
  NONE, DISABLED, (LONG)"---------------------------",
  0x0000, 0x000B, 0x001B, 0x0001,
        32,       -1,       -1, G_STRING  ,   /* Object 31 MPRINT */
  NONE, NORMAL, (LONG)"  Drucken              ^P",
  0x0000, 0x000C, 0x001B, 0x0001,
  MQUIT   ,       -1,       -1, G_STRING  ,   /* Object 32  */
  NONE, DISABLED, (LONG)"---------------------------",
  0x0000, 0x000D, 0x001B, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 33 MQUIT */
  NONE, NORMAL, (LONG)"  Beenden              ^Q",
  0x0000, 0x000E, 0x001B, 0x0001,
        46, MUNDO   , MTOCLIP , G_BOX     ,   /* Object 34  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0013, 0x0000, 0x0019, 0x000B,
        36,       -1,       -1, G_STRING  ,   /* Object 35 MUNDO */
  NONE, NORMAL, (LONG)"  Undo               ^Z",
  0x0000, 0x0000, 0x0019, 0x0001,
  MCUT    ,       -1,       -1, G_STRING  ,   /* Object 36  */
  NONE, DISABLED, (LONG)"-------------------------",
  0x0000, 0x0001, 0x0019, 0x0001,
  MCOPY   ,       -1,       -1, G_STRING  ,   /* Object 37 MCUT */
  NONE, NORMAL, (LONG)"  Ausschneiden       ^X",
  0x0000, 0x0002, 0x0019, 0x0001,
  MPASTE  ,       -1,       -1, G_STRING  ,   /* Object 38 MCOPY */
  NONE, NORMAL, (LONG)"  Kopieren           ^C",
  0x0000, 0x0003, 0x0019, 0x0001,
  MCLEAR  ,       -1,       -1, G_STRING  ,   /* Object 39 MPASTE */
  NONE, NORMAL, (LONG)"  Einf\201gen           ^V",
  0x0000, 0x0004, 0x0019, 0x0001,
  MSELALL ,       -1,       -1, G_STRING  ,   /* Object 40 MCLEAR */
  NONE, NORMAL, (LONG)"  L\224schen            ^D",
  0x0000, 0x0005, 0x0019, 0x0001,
        42,       -1,       -1, G_STRING  ,   /* Object 41 MSELALL */
  NONE, NORMAL, (LONG)"  Alles ausw\204hlen    ^A",
  0x0000, 0x0006, 0x0019, 0x0001,
  MCYCLEWI,       -1,       -1, G_STRING  ,   /* Object 42  */
  NONE, DISABLED, (LONG)"-------------------------",
  0x0000, 0x0007, 0x0019, 0x0001,
        44,       -1,       -1, G_STRING  ,   /* Object 43 MCYCLEWI */
  NONE, NORMAL, (LONG)"  Fenster wechseln   ^W",
  0x0000, 0x0008, 0x0019, 0x0001,
  MTOCLIP ,       -1,       -1, G_STRING  ,   /* Object 44  */
  NONE, DISABLED, (LONG)"-------------------------",
  0x0000, 0x0009, 0x0019, 0x0001,
        34,       -1,       -1, G_STRING  ,   /* Object 45 MTOCLIP */
  NONE, NORMAL, (LONG)"  Auf GEM-Klemmbrett ^G",
  0x0000, 0x000A, 0x0019, 0x0001,
        53, MCONFIG , MUSERINT, G_BOX     ,   /* Object 46  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x001F, 0x0000, 0x001F, 0x0006,
  MPARAMS ,       -1,       -1, G_STRING  ,   /* Object 47 MCONFIG */
  NONE, NORMAL, (LONG)"  Konfiguration...         \007C",
  0x0000, 0x0000, 0x001F, 0x0001,
  MLOADCFG,       -1,       -1, G_STRING  ,   /* Object 48 MPARAMS */
  NONE, NORMAL, (LONG)"  Parameter...             \007Y",
  0x0000, 0x0001, 0x001F, 0x0001,
  MSAVECFG,       -1,       -1, G_STRING  ,   /* Object 49 MLOADCFG */
  NONE, NORMAL, (LONG)"  Konfiguration laden...   \007L",
  0x0000, 0x0002, 0x001F, 0x0001,
        51,       -1,       -1, G_STRING  ,   /* Object 50 MSAVECFG */
  NONE, NORMAL, (LONG)"  Konfiguration sichern... \007S",
  0x0000, 0x0003, 0x001F, 0x0001,
  MUSERINT,       -1,       -1, G_STRING  ,   /* Object 51  */
  EDITABLE, DISABLED, (LONG)"-------------------------------",
  0x0000, 0x0004, 0x001F, 0x0001,
        46,       -1,       -1, G_STRING  ,   /* Object 52 MUSERINT */
  NONE, NORMAL, (LONG)"  Benutzer-Oberfl\204che...   \007B",
  0x0000, 0x0005, 0x001F, 0x0001,
         8, MHELPCXT, MINFO   , G_BOX     ,   /* Object 53  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0029, 0x0000, 0x0015, 0x0006,
  MHELPINX,       -1,       -1, G_STRING  ,   /* Object 54 MHELPCXT */
  NONE, NORMAL, (LONG)"  Kontext-Hilfe  F1",
  0x0000, 0x0000, 0x0015, 0x0001,
  MHELPCON,       -1,       -1, G_STRING  ,   /* Object 55 MHELPINX */
  NONE, NORMAL, (LONG)"  Index         \007F1",
  0x0000, 0x0001, 0x0015, 0x0001,
  MHELPOBJ,       -1,       -1, G_STRING  ,   /* Object 56 MHELPCON */
  NONE, NORMAL, (LONG)"  Inhalt        ^F1",
  0x0000, 0x0002, 0x0015, 0x0001,
        58,       -1,       -1, G_STRING  ,   /* Object 57 MHELPOBJ */
  NONE, NORMAL, (LONG)"  Objekt/Men\201   \001F1",
  0x0000, 0x0003, 0x0015, 0x0001,
  MINFO   ,       -1,       -1, G_STRING  ,   /* Object 58  */
  NONE, DISABLED, (LONG)"---------------------",
  0x0000, 0x0004, 0x0015, 0x0001,
        53,       -1,       -1, G_STRING  ,   /* Object 59 MINFO */
  LASTOB, NORMAL, (LONG)"  Info...       \001F2",
  0x0000, 0x0005, 0x0015, 0x0001,
  
  /******** Tree 1 ABOUT ****************************************************/
        -1, ALOGO   , AINFO   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0029, 0x0017,
         2,       -1,       -1, G_BOX     ,   /* Object 1 ALOGO */
  NONE, DRAW3D, (LONG)0x00FF1101L,
  0x0001, 0x0001, 0x0027, 0x000D,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x000E, 0x0029, 0x0600,
  ASERIAL ,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0001, 0x000F, 0x0609, 0x0600,
         5,       -1,       -1, G_TEXT    ,   /* Object 4 ASERIAL */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x000C, 0x000F, 0x0407, 0x0600,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0001, 0x0010, 0x0009, 0x0600,
  ACOMPANY,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0001, 0x0011, 0x0609, 0x0600,
         8,       -1,       -1, G_TEXT    ,   /* Object 7 ACOMPANY */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x000C, 0x0011, 0x0416, 0x0600,
  ANAME   ,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0001, 0x0012, 0x0609, 0x0600,
  AOK     ,       -1,       -1, G_TEXT    ,   /* Object 9 ANAME */
  NONE, NORMAL, (LONG)&rs_tedinfo[7],
  0x000C, 0x0012, 0x0416, 0x0600,
  AINFO   ,       -1,       -1, G_BUTTON  ,   /* Object 10 AOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0008, 0x0014, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 11 AINFO */
  SELECTABLE|LASTOB, WHITEBAK, (LONG)"~Info...",
  0x0016, 0x0014, 0x000A, 0x0002,
  
  /******** Tree 2 MOREINFO ****************************************************/
        -1,        1,       13, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0028, 0x0014,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, DRAW3D|STATE11|STATE13|STATE15, (LONG)"PHOENIX",
  0x0010, 0x0001, 0x0008, 0x0002,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, STATE13|STATE15, (LONG)"Entwickelt mit Hilfe des Toolkits",
  0x0004, 0x0003, 0x0021, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE13|STATE15, (LONG)"aus dem Buch",
  0x000E, 0x0004, 0x000C, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, STATE11|STATE13|STATE15, (LONG)"Vom Anf\204nger zum GEM-Profi",
  0x0006, 0x0006, 0x001A, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[8],
  0x0012, 0x0008, 0x0202, 0x0600,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[9],
  0x0009, 0x0009, 0x0214, 0x0600,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[10],
  0x000C, 0x000A, 0x020E, 0x0600,
         9,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[11],
  0x000D, 0x000B, 0x020B, 0x0600,
        10,       -1,       -1, G_TEXT    ,   /* Object 9  */
  NONE, NORMAL, (LONG)&rs_tedinfo[12],
  0x000C, 0x000C, 0x040D, 0x0800,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[13],
  0x000E, 0x000D, 0x0009, 0x0600,
        12,       -1,       -1, G_TEXT    ,   /* Object 11  */
  NONE, NORMAL, (LONG)&rs_tedinfo[14],
  0x000C, 0x000E, 0x040D, 0x0600,
        13,       -1,       -1, G_TEXT    ,   /* Object 12  */
  NONE, NORMAL, (LONG)&rs_tedinfo[15],
  0x0011, 0x000F, 0x0205, 0x0600,
         0,       -1,       -1, G_BUTTON  ,   /* Object 13  */
  SELECTABLE|DEFAULT|EXIT|LASTOB, WHITEBAK, (LONG)"~OK",
  0x000F, 0x0011, 0x000A, 0x0002,
  
  /******** Tree 3 DESKTOP ****************************************************/
        -1, ITRASH  , FKEYS   , G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000141L,
  0x0000, 0x0000, 0x0050, 0x0019,
  ICLIPBRD,       -1,       -1, G_CICON   ,   /* Object 1 ITRASH */
  NONE, NORMAL, (LONG)&rs_ciconblk[0],
  0x0000, 0x0014, 0x0009, 0x0802,
  FKEYS   ,       -1,       -1, G_CICON   ,   /* Object 2 ICLIPBRD */
  NONE, NORMAL, (LONG)&rs_ciconblk[1],
  0x000A, 0x0014, 0x0009, 0x0802,
         0,        4, INFOBOX , G_IBOX    ,   /* Object 3 FKEYS */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0400, 0x0017, 0x004F, 0x0B01,
         5,       -1,       -1, G_BUTTON  ,   /* Object 4  */
  SELECTABLE, STATE12, (LONG)"F1",
  0x0000, 0x0000, 0x0007, 0x0B01,
         6,       -1,       -1, G_BUTTON  ,   /* Object 5  */
  SELECTABLE, STATE12, (LONG)"F2",
  0x0706, 0x0000, 0x0007, 0x0B01,
         7,       -1,       -1, G_BUTTON  ,   /* Object 6  */
  SELECTABLE, STATE12, (LONG)"F3",
  0x060D, 0x0000, 0x0007, 0x0B01,
         8,       -1,       -1, G_BUTTON  ,   /* Object 7  */
  SELECTABLE, STATE12, (LONG)"F4",
  0x0514, 0x0000, 0x0007, 0x0B01,
         9,       -1,       -1, G_BUTTON  ,   /* Object 8  */
  SELECTABLE, STATE12, (LONG)"F5",
  0x041B, 0x0000, 0x0007, 0x0B01,
        10,       -1,       -1, G_BUTTON  ,   /* Object 9  */
  SELECTABLE, STATE12, (LONG)"F6",
  0x0322, 0x0000, 0x0007, 0x0B01,
        11,       -1,       -1, G_BUTTON  ,   /* Object 10  */
  SELECTABLE, STATE12, (LONG)"F7",
  0x0229, 0x0000, 0x0007, 0x0B01,
        12,       -1,       -1, G_BUTTON  ,   /* Object 11  */
  SELECTABLE, STATE12, (LONG)"F8",
  0x0130, 0x0000, 0x0007, 0x0B01,
        13,       -1,       -1, G_BUTTON  ,   /* Object 12  */
  SELECTABLE, STATE12, (LONG)"F9",
  0x0037, 0x0000, 0x0007, 0x0B01,
  INFOBOX ,       -1,       -1, G_BUTTON  ,   /* Object 13  */
  SELECTABLE, STATE12, (LONG)"F10",
  0x073D, 0x0000, 0x0007, 0x0B01,
  FKEYS   ,       -1,       -1, G_BUTTON  ,   /* Object 14 INFOBOX */
  LASTOB, STATE12, (LONG)"MEM",
  0x0145, 0x0000, 0x0709, 0x0B01,
  
  /******** Tree 4 USERIMG ****************************************************/
        -1, RBHNORM , ARROW32 , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0013, 0x000C,
  RBHSEL  ,       -1,       -1, G_IMAGE   ,   /* Object 1 RBHNORM */
  NONE, NORMAL, (LONG)&rs_bitblk[0],
  0x0002, 0x0001, 0x0002, 0x0C00,
  CBHNORM ,       -1,       -1, G_IMAGE   ,   /* Object 2 RBHSEL */
  NONE, NORMAL, (LONG)&rs_bitblk[1],
  0x0005, 0x0001, 0x0002, 0x0C00,
  CBHSEL  ,       -1,       -1, G_IMAGE   ,   /* Object 3 CBHNORM */
  NONE, NORMAL, (LONG)&rs_bitblk[2],
  0x0009, 0x0001, 0x0002, 0x0C00,
  RBLNORM ,       -1,       -1, G_IMAGE   ,   /* Object 4 CBHSEL */
  NONE, NORMAL, (LONG)&rs_bitblk[3],
  0x000D, 0x0001, 0x0002, 0x0C00,
  RBLSEL  ,       -1,       -1, G_IMAGE   ,   /* Object 5 RBLNORM */
  NONE, NORMAL, (LONG)&rs_bitblk[4],
  0x0002, 0x0003, 0x0002, 0x0800,
  CBLNORM ,       -1,       -1, G_IMAGE   ,   /* Object 6 RBLSEL */
  NONE, NORMAL, (LONG)&rs_bitblk[5],
  0x0005, 0x0003, 0x0002, 0x0800,
  CBLSEL  ,       -1,       -1, G_IMAGE   ,   /* Object 7 CBLNORM */
  NONE, NORMAL, (LONG)&rs_bitblk[6],
  0x0009, 0x0003, 0x0002, 0x0800,
  RB7NORM ,       -1,       -1, G_IMAGE   ,   /* Object 8 CBLSEL */
  NONE, NORMAL, (LONG)&rs_bitblk[7],
  0x000D, 0x0003, 0x0002, 0x0800,
  RB7SEL  ,       -1,       -1, G_IMAGE   ,   /* Object 9 RB7NORM */
  NONE, NORMAL, (LONG)&rs_bitblk[8],
  0x0002, 0x0004, 0x0002, 0x0700,
  CB7NORM ,       -1,       -1, G_IMAGE   ,   /* Object 10 RB7SEL */
  NONE, NORMAL, (LONG)&rs_bitblk[9],
  0x0005, 0x0004, 0x0002, 0x0700,
  CB7SEL  ,       -1,       -1, G_IMAGE   ,   /* Object 11 CB7NORM */
  NONE, NORMAL, (LONG)&rs_bitblk[10],
  0x0009, 0x0004, 0x0002, 0x0700,
  RB5NORM ,       -1,       -1, G_IMAGE   ,   /* Object 12 CB7SEL */
  NONE, NORMAL, (LONG)&rs_bitblk[11],
  0x000D, 0x0004, 0x0002, 0x0700,
  RB5SEL  ,       -1,       -1, G_IMAGE   ,   /* Object 13 RB5NORM */
  NONE, NORMAL, (LONG)&rs_bitblk[12],
  0x0002, 0x0005, 0x0002, 0x0500,
  CB5NORM ,       -1,       -1, G_IMAGE   ,   /* Object 14 RB5SEL */
  NONE, NORMAL, (LONG)&rs_bitblk[13],
  0x0005, 0x0005, 0x0002, 0x0500,
  CB5SEL  ,       -1,       -1, G_IMAGE   ,   /* Object 15 CB5NORM */
  NONE, NORMAL, (LONG)&rs_bitblk[14],
  0x0009, 0x0005, 0x0002, 0x0500,
  ARROW6  ,       -1,       -1, G_IMAGE   ,   /* Object 16 CB5SEL */
  NONE, NORMAL, (LONG)&rs_bitblk[15],
  0x000D, 0x0005, 0x0002, 0x0500,
  ARROW8  ,       -1,       -1, G_IMAGE   ,   /* Object 17 ARROW6 */
  NONE, NORMAL, (LONG)&rs_bitblk[16],
  0x0002, 0x0007, 0x0002, 0x0600,
  ARROW10 ,       -1,       -1, G_IMAGE   ,   /* Object 18 ARROW8 */
  NONE, NORMAL, (LONG)&rs_bitblk[17],
  0x0004, 0x0007, 0x0002, 0x0800,
  ARROW12 ,       -1,       -1, G_IMAGE   ,   /* Object 19 ARROW10 */
  NONE, NORMAL, (LONG)&rs_bitblk[18],
  0x0006, 0x0007, 0x0002, 0x0A00,
  ARROW14 ,       -1,       -1, G_IMAGE   ,   /* Object 20 ARROW12 */
  NONE, NORMAL, (LONG)&rs_bitblk[19],
  0x0008, 0x0007, 0x0002, 0x0C00,
  ARROW16 ,       -1,       -1, G_IMAGE   ,   /* Object 21 ARROW14 */
  NONE, NORMAL, (LONG)&rs_bitblk[20],
  0x000A, 0x0007, 0x0002, 0x0E00,
  ARROW32 ,       -1,       -1, G_IMAGE   ,   /* Object 22 ARROW16 */
  NONE, NORMAL, (LONG)&rs_bitblk[21],
  0x000C, 0x0007, 0x0002, 0x0001,
         0,       -1,       -1, G_IMAGE   ,   /* Object 23 ARROW32 */
  LASTOB, NORMAL, (LONG)&rs_bitblk[22],
  0x000E, 0x0007, 0x0004, 0x0002,
  
  /******** Tree 5 ALERT ****************************************************/
        -1,        1,       14, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0048, 0x000D,
         2,       -1,       -1, G_IMAGE   ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_bitblk[23],
  0x0001, 0x0001, 0x0004, 0x0002,
         3,       -1,       -1, G_IMAGE   ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_bitblk[24],
  0x0001, 0x0003, 0x0004, 0x0002,
         4,       -1,       -1, G_IMAGE   ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_bitblk[25],
  0x0001, 0x0005, 0x0004, 0x0002,
         5,       -1,       -1, G_IMAGE   ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_bitblk[26],
  0x0001, 0x0007, 0x0004, 0x0002,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0007, 0x0001, 0x0028, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0007, 0x0002, 0x0028, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0007, 0x0003, 0x0028, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0007, 0x0004, 0x0028, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0007, 0x0005, 0x0028, 0x0001,
        11,       -1,       -1, G_BUTTON  ,   /* Object 10  */
  SELECTABLE|EXIT, WHITEBAK, (LONG)"123456789012",
  0x0001, 0x000A, 0x000D, 0x0002,
        12,       -1,       -1, G_BUTTON  ,   /* Object 11  */
  SELECTABLE|EXIT, WHITEBAK, (LONG)"123456789012",
  0x000F, 0x000A, 0x000D, 0x0002,
        13,       -1,       -1, G_BUTTON  ,   /* Object 12  */
  SELECTABLE|EXIT, WHITEBAK, (LONG)"123456789012",
  0x001D, 0x000A, 0x000D, 0x0002,
        14,       -1,       -1, G_BUTTON  ,   /* Object 13  */
  SELECTABLE|EXIT, WHITEBAK, (LONG)"123456789012",
  0x002B, 0x000A, 0x000D, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 14  */
  SELECTABLE|EXIT|LASTOB, WHITEBAK, (LONG)"123456789012",
  0x0039, 0x000A, 0x000D, 0x0002,
  
  /******** Tree 6 SELFILE ****************************************************/
        -1,        1, FLHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x004B, 0x0011,
  FLNAME  ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, DRAW3D|STATE15, (LONG)"Datei~name:",
  0x0002, 0x0001, 0x000B, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 FLNAME */
  EDITABLE|FLAGS12, NORMAL, (LONG)&rs_tedinfo[16],
  0x0002, 0x0002, 0x000E, 0x0001,
  FLDIR   ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, DRAW3D|STATE15, (LONG)"Verzeichnisse:",
  0x001F, 0x0001, 0x000E, 0x0001,
  FLNAMES ,       -1,       -1, G_STRING  ,   /* Object 4 FLDIR */
  NONE, STATE12|STATE15, (LONG)"123456789012345678901234567",
  0x001F, 0x0002, 0x001B, 0x0001,
  FLDIRS  ,       -1,       -1, G_BOX     ,   /* Object 5 FLNAMES */
  SELECTABLE, STATE13, (LONG)0x00FF1101L,
  0x0002, 0x0004, 0x001B, 0x0009,
         7,       -1,       -1, G_BOX     ,   /* Object 6 FLDIRS */
  SELECTABLE, STATE13, (LONG)0x00FF1101L,
  0x001F, 0x0004, 0x001B, 0x0009,
  FLTYPES ,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, DRAW3D|STATE15, (LONG)"Datei~formate:",
  0x0002, 0x000E, 0x000E, 0x0001,
         9,       -1,       -1, G_BUTTON  ,   /* Object 8 FLTYPES */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"\0",
  0x0002, 0x000F, 0x001B, 0x0001,
  FLDRIVES,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, DRAW3D|STATE15, (LONG)"~Laufwerke:",
  0x001F, 0x000E, 0x000B, 0x0001,
        11,       -1,       -1, G_BUTTON  ,   /* Object 10 FLDRIVES */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"\0",
  0x001F, 0x000F, 0x001B, 0x0001,
  FLORDER ,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, DRAW3D|STATE15, (LONG)"~Sortierung:",
  0x003C, 0x000E, 0x000C, 0x0001,
  FLOK    ,       -1,       -1, G_BUTTON  ,   /* Object 12 FLORDER */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"\0",
  0x003C, 0x000F, 0x000D, 0x0001,
  FLCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 13 FLOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x003F, 0x0004, 0x000A, 0x0002,
  FLHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 14 FLCANCEL */
  SELECTABLE|EXIT|FLAGS13, DRAW3D|WHITEBAK, (LONG)"~Abbruch",
  0x003F, 0x0007, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 15 FLHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x003F, 0x0009, 0x000A, 0x0002,
  
  /******** Tree 7 SELPATH ****************************************************/
        -1,        1, PTHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x002E, 0x0011,
  PTDIR   ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, DRAW3D|STATE15, (LONG)"Verzeichnisse:",
  0x0002, 0x0001, 0x000E, 0x0001,
  PTDIRS  ,       -1,       -1, G_STRING  ,   /* Object 2 PTDIR */
  NONE, STATE12|STATE15, (LONG)"123456789012345678901234567890123456789012",
  0x0002, 0x0002, 0x002A, 0x0001,
         4,       -1,       -1, G_BOX     ,   /* Object 3 PTDIRS */
  SELECTABLE, STATE13, (LONG)0x00FF1101L,
  0x0002, 0x0004, 0x001B, 0x0009,
  PTDRIVES,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, DRAW3D|STATE15, (LONG)"~Laufwerke:",
  0x0002, 0x000E, 0x000B, 0x0001,
         6,       -1,       -1, G_BUTTON  ,   /* Object 5 PTDRIVES */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"\0",
  0x0002, 0x000F, 0x001B, 0x0001,
  PTORDER ,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, DRAW3D|STATE15, (LONG)"~Sortierung:",
  0x001F, 0x000E, 0x000C, 0x0001,
  PTOK    ,       -1,       -1, G_BUTTON  ,   /* Object 7 PTORDER */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"\0",
  0x001F, 0x000F, 0x000D, 0x0001,
  PTCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 8 PTOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0022, 0x0004, 0x000A, 0x0002,
  PTHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 9 PTCANCEL */
  SELECTABLE|EXIT|FLAGS13, DRAW3D|WHITEBAK, (LONG)"~Abbruch",
  0x0022, 0x0007, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 10 PTHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0022, 0x0009, 0x000A, 0x0002,
  
  /******** Tree 8 SELFONT ****************************************************/
        -1,        1, FNHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x003E, 0x0014,
  FNNAME  ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, DRAW3D|STATE15, (LONG)"~Schriftart:",
  0x0002, 0x0001, 0x000C, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 FNNAME */
  EDITABLE|FLAGS12, NORMAL, (LONG)&rs_tedinfo[17],
  0x0002, 0x0002, 0x0022, 0x0001,
  FNPOINT ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, DRAW3D|STATE15, (LONG)"~Gr\224\236e:",
  0x0026, 0x0001, 0x0007, 0x0001,
  FNNAMES ,       -1,       -1, G_FBOXTEXT,   /* Object 4 FNPOINT */
  EDITABLE|FLAGS12, STATE15, (LONG)&rs_tedinfo[18],
  0x0026, 0x0002, 0x0008, 0x0001,
  FNPOINTS,       -1,       -1, G_BOX     ,   /* Object 5 FNNAMES */
  SELECTABLE, STATE13, (LONG)0x00FF1101L,
  0x0002, 0x0004, 0x0022, 0x0006,
  FNEFFECT,       -1,       -1, G_BOX     ,   /* Object 6 FNPOINTS */
  SELECTABLE, STATE13, (LONG)0x00FF1101L,
  0x0026, 0x0004, 0x0008, 0x0006,
  FNCLABEL, FNTHICK , FNOUTLN , G_BUTTON  ,   /* Object 7 FNEFFECT */
  NONE, STATE14, (LONG)"Effekte",
  0x0002, 0x000C, 0x0012, 0x0007,
  FNLIGHT ,       -1,       -1, G_BUTTON  ,   /* Object 8 FNTHICK */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Fe~tt",
  0x0001, 0x0002, 0x0005, 0x0001,
  FNSKEWED,       -1,       -1, G_BUTTON  ,   /* Object 9 FNLIGHT */
  SELECTABLE, DRAW3D|STATE13, (LONG)"He~ll",
  0x0001, 0x0003, 0x0005, 0x0001,
  FNUNDER ,       -1,       -1, G_BUTTON  ,   /* Object 10 FNSKEWED */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Kursiv",
  0x0001, 0x0004, 0x0007, 0x0001,
  FNOUTLN ,       -1,       -1, G_BUTTON  ,   /* Object 11 FNUNDER */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Unterstrichen",
  0x0001, 0x0005, 0x000E, 0x0001,
  FNEFFECT,       -1,       -1, G_BUTTON  ,   /* Object 12 FNOUTLN */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Um~rahmt",
  0x0001, 0x0006, 0x0008, 0x0001,
  FNCOLOR ,       -1,       -1, G_STRING  ,   /* Object 13 FNCLABEL */
  NONE, DRAW3D|STATE15, (LONG)"~Farbe:",
  0x0016, 0x000B, 0x0007, 0x0001,
        15,       -1,       -1, G_BUTTON  ,   /* Object 14 FNCOLOR */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"\0",
  0x0016, 0x000C, 0x0010, 0x0001,
  FNORDER ,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, DRAW3D|STATE15, (LONG)"Sort~ierung:",
  0x0028, 0x000B, 0x000C, 0x0001,
        17,       -1,       -1, G_BUTTON  ,   /* Object 16 FNORDER */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"\0",
  0x0028, 0x000C, 0x000D, 0x0001,
  FNSAMPLE,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, DRAW3D|STATE15, (LONG)"Beispiel:",
  0x0016, 0x000E, 0x0009, 0x0001,
  FNOK    ,       -1,       -1, G_IBOX    ,   /* Object 18 FNSAMPLE */
  NONE, STATE13|STATE14|STATE15, (LONG)0x00FF1100L,
  0x0016, 0x000F, 0x0026, 0x0004,
  FNCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 19 FNOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0032, 0x0002, 0x000A, 0x0002,
  FNHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 20 FNCANCEL */
  SELECTABLE|EXIT|FLAGS13, DRAW3D|WHITEBAK, (LONG)"~Abbruch",
  0x0032, 0x0005, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 21 FNHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0032, 0x0007, 0x000A, 0x0002,
  
  /******** Tree 9 HELPINX ****************************************************/
        -1, HINDEX  , HSELFILE, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0024, 0x002E,
  HCONTENT,       -1,       -1, G_STRING  ,   /* Object 1 HINDEX */
  NONE, NORMAL, (LONG)"Index",
  0x0001, 0x0001, 0x0005, 0x0001,
  HHELP   ,       -1,       -1, G_STRING  ,   /* Object 2 HCONTENT */
  NONE, NORMAL, (LONG)"Inhalt",
  0x0001, 0x0002, 0x0006, 0x0001,
  HDESKTOP,       -1,       -1, G_STRING  ,   /* Object 3 HHELP */
  NONE, NORMAL, (LONG)"Hilfe verwenden",
  0x0001, 0x0003, 0x000F, 0x0001,
  HTRASH  ,       -1,       -1, G_STRING  ,   /* Object 4 HDESKTOP */
  NONE, NORMAL, (LONG)"Schreibtisch des Designers",
  0x0001, 0x0004, 0x001A, 0x0001,
  HCLIPBRD,       -1,       -1, G_STRING  ,   /* Object 5 HTRASH */
  NONE, NORMAL, (LONG)"Papierkorb",
  0x0001, 0x0005, 0x000A, 0x0001,
  HBASE   ,       -1,       -1, G_STRING  ,   /* Object 6 HCLIPBRD */
  NONE, NORMAL, (LONG)"Klemmbrett",
  0x0001, 0x0006, 0x000A, 0x0001,
  HMASK   ,       -1,       -1, G_STRING  ,   /* Object 7 HBASE */
  NONE, NORMAL, (LONG)"Datenbankfenster",
  0x0001, 0x0007, 0x0010, 0x0001,
  HCONFIG ,       -1,       -1, G_STRING  ,   /* Object 8 HMASK */
  NONE, NORMAL, (LONG)"Maskenfenster",
  0x0001, 0x0008, 0x000D, 0x0001,
  HPARAMS ,       -1,       -1, G_STRING  ,   /* Object 9 HCONFIG */
  NONE, NORMAL, (LONG)"Dialogbox Konfiguration",
  0x0001, 0x000A, 0x0017, 0x0001,
  HUSERINT,       -1,       -1, G_STRING  ,   /* Object 10 HPARAMS */
  NONE, NORMAL, (LONG)"Dialogbox Parameter",
  0x0001, 0x000B, 0x0015, 0x0001,
  HOPENDB ,       -1,       -1, G_STRING  ,   /* Object 11 HUSERINT */
  NONE, NORMAL, (LONG)"Dialogbox Benutzer-Oberfl\204che",
  0x0001, 0x000C, 0x001D, 0x0001,
  HDBPARAM,       -1,       -1, G_STRING  ,   /* Object 12 HOPENDB */
  NONE, NORMAL, (LONG)"Dialogbox Datenbank \224ffnen",
  0x0001, 0x000D, 0x001A, 0x0001,
  HDBINFO ,       -1,       -1, G_STRING  ,   /* Object 13 HDBPARAM */
  NONE, NORMAL, (LONG)"Dialogbox DB-Parameter",
  0x0001, 0x000E, 0x0016, 0x0001,
  HTBLINFO,       -1,       -1, G_STRING  ,   /* Object 14 HDBINFO */
  NONE, NORMAL, (LONG)"Dialogbox Datenbank-Info",
  0x0001, 0x000F, 0x0018, 0x0001,
  HNEWTBL ,       -1,       -1, G_STRING  ,   /* Object 15 HTBLINFO */
  NONE, NORMAL, (LONG)"Dialogbox Tabellen-Info",
  0x0001, 0x0010, 0x0017, 0x0001,
  HNEWFIEL,       -1,       -1, G_STRING  ,   /* Object 16 HNEWTBL */
  NONE, NORMAL, (LONG)"Dialogbox Tabelle \204ndern/neu",
  0x0001, 0x0011, 0x001C, 0x0001,
  HNEWKEY ,       -1,       -1, G_STRING  ,   /* Object 17 HNEWFIEL */
  NONE, NORMAL, (LONG)"Dialogbox Feld \204ndern/neu",
  0x0001, 0x0012, 0x0019, 0x0001,
  HDOICONS,       -1,       -1, G_STRING  ,   /* Object 18 HNEWKEY */
  NONE, NORMAL, (LONG)"Dialogbox Multi-Index \204ndern/neu",
  0x0001, 0x0013, 0x0020, 0x0001,
  HFORMAT ,       -1,       -1, G_STRING  ,   /* Object 19 HDOICONS */
  NONE, NORMAL, (LONG)"Dialogbox Sinnbilder",
  0x0001, 0x0014, 0x0014, 0x0001,
  HRELRULE,       -1,       -1, G_STRING  ,   /* Object 20 HFORMAT */
  NONE, NORMAL, (LONG)"Dialogbox Format",
  0x0001, 0x0015, 0x0010, 0x0001,
  HSELFONT,       -1,       -1, G_STRING  ,   /* Object 21 HRELRULE */
  NONE, NORMAL, (LONG)"Dialogbox Referentielle Integrit\204t",
  0x0001, 0x0016, 0x0022, 0x0001,
  HSELMASK,       -1,       -1, G_STRING  ,   /* Object 22 HSELFONT */
  NONE, NORMAL, (LONG)"Dialogbox Schriftart",
  0x0001, 0x0017, 0x0014, 0x0001,
  HMASKINF,       -1,       -1, G_STRING  ,   /* Object 23 HSELMASK */
  NONE, NORMAL, (LONG)"Dialogbox Masken",
  0x0001, 0x0018, 0x0010, 0x0001,
  HFIELDAT,       -1,       -1, G_STRING  ,   /* Object 24 HMASKINF */
  NONE, NORMAL, (LONG)"Dialogbox Masken-Info",
  0x0001, 0x0019, 0x0015, 0x0001,
  HSELFILL,       -1,       -1, G_STRING  ,   /* Object 25 HFIELDAT */
  NONE, NORMAL, (LONG)"Dialogbox Feldattribute",
  0x0001, 0x001A, 0x0017, 0x0001,
  HSELLINE,       -1,       -1, G_STRING  ,   /* Object 26 HSELFILL */
  NONE, NORMAL, (LONG)"Dialogbox F\201llmuster & Farbe",
  0x0001, 0x001B, 0x001C, 0x0001,
  HSELGRID,       -1,       -1, G_STRING  ,   /* Object 27 HSELLINE */
  NONE, NORMAL, (LONG)"Dialogbox Linienattribute",
  0x0001, 0x001C, 0x0019, 0x0001,
  HSELSIZE,       -1,       -1, G_STRING  ,   /* Object 28 HSELGRID */
  NONE, NORMAL, (LONG)"Dialogbox Gitter",
  0x0001, 0x001D, 0x0010, 0x0001,
  HTEXT   ,       -1,       -1, G_STRING  ,   /* Object 29 HSELSIZE */
  NONE, NORMAL, (LONG)"Dialogbox Dokumentgr\224\236e",
  0x0001, 0x001E, 0x0017, 0x0001,
  HOBJSIZE,       -1,       -1, G_STRING  ,   /* Object 30 HTEXT */
  NONE, NORMAL, (LONG)"Dialogbox Text",
  0x0001, 0x001F, 0x000E, 0x0001,
  HPICSIZE,       -1,       -1, G_STRING  ,   /* Object 31 HOBJSIZE */
  NONE, NORMAL, (LONG)"Dialogbox Objektgr\224\236e",
  0x0001, 0x0020, 0x0015, 0x0001,
  HLINESIZ,       -1,       -1, G_STRING  ,   /* Object 32 HPICSIZE */
  NONE, NORMAL, (LONG)"Dialogbox Bildgr\224\236e",
  0x0001, 0x0021, 0x0013, 0x0001,
  HRVALUES,       -1,       -1, G_STRING  ,   /* Object 33 HLINESIZ */
  NONE, NORMAL, (LONG)"Dialogbox Liniengr\224\236e",
  0x0001, 0x0022, 0x0015, 0x0001,
  HCVALUES,       -1,       -1, G_STRING  ,   /* Object 34 HRVALUES */
  NONE, NORMAL, (LONG)"Dialogbox Radio-Werte",
  0x0001, 0x0023, 0x0015, 0x0001,
  HSUBMASK,       -1,       -1, G_STRING  ,   /* Object 35 HCVALUES */
  NONE, NORMAL, (LONG)"Dialogbox Checkbox-Werte",
  0x0001, 0x0024, 0x0018, 0x0001,
  HBUTTON ,       -1,       -1, G_STRING  ,   /* Object 36 HSUBMASK */
  NONE, NORMAL, (LONG)"Dialogbox Verbund/Untermaske",
  0x0001, 0x0025, 0x001C, 0x0001,
  HACCESS ,       -1,       -1, G_STRING  ,   /* Object 37 HBUTTON */
  NONE, NORMAL, (LONG)"Dialogbox Kn\224pfe",
  0x0001, 0x0026, 0x0010, 0x0001,
  HUSERINF,       -1,       -1, G_STRING  ,   /* Object 38 HACCESS */
  NONE, NORMAL, (LONG)"Dialogbox Zugriffsrechte",
  0x0001, 0x0027, 0x0018, 0x0001,
  HSELFILE,       -1,       -1, G_STRING  ,   /* Object 39 HUSERINF */
  NONE, NORMAL, (LONG)"Dialogbox Benutzer-Info",
  0x0001, 0x0028, 0x0017, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 40 HSELFILE */
  LASTOB, NORMAL, (LONG)"Dialogbox Dateiauswahl",
  0x0001, 0x0029, 0x0016, 0x0001,
  
  /******** Tree 10 POPUPS ****************************************************/
        -1, COLPOPUP,       34, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0021, 0x0012,
        34,        2, CODMAGEN, G_BOX     ,   /* Object 1 COLPOPUP */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0002, 0x0001, 0x0010, 0x0010,
         3,       -1,       -1, G_BOX     ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
         4,       -1,       -1, G_BOX     ,   /* Object 3  */
  NONE, NORMAL, (LONG)0x000111F1L,
  0x0000, 0x0001, 0x0001, 0x0001,
         5,       -1,       -1, G_BOX     ,   /* Object 4  */
  NONE, NORMAL, (LONG)0x000111F2L,
  0x0000, 0x0002, 0x0001, 0x0001,
         6,       -1,       -1, G_BOX     ,   /* Object 5  */
  NONE, NORMAL, (LONG)0x000111F3L,
  0x0000, 0x0003, 0x0001, 0x0001,
         7,       -1,       -1, G_BOX     ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x000111F4L,
  0x0000, 0x0004, 0x0001, 0x0001,
         8,       -1,       -1, G_BOX     ,   /* Object 7  */
  NONE, NORMAL, (LONG)0x000111F5L,
  0x0000, 0x0005, 0x0001, 0x0001,
         9,       -1,       -1, G_BOX     ,   /* Object 8  */
  NONE, NORMAL, (LONG)0x000111F6L,
  0x0000, 0x0006, 0x0001, 0x0001,
        10,       -1,       -1, G_BOX     ,   /* Object 9  */
  NONE, NORMAL, (LONG)0x000111F7L,
  0x0000, 0x0007, 0x0001, 0x0001,
        11,       -1,       -1, G_BOX     ,   /* Object 10  */
  NONE, NORMAL, (LONG)0x000111F8L,
  0x0000, 0x0008, 0x0001, 0x0001,
        12,       -1,       -1, G_BOX     ,   /* Object 11  */
  NONE, NORMAL, (LONG)0x000111F9L,
  0x0000, 0x0009, 0x0001, 0x0001,
        13,       -1,       -1, G_BOX     ,   /* Object 12  */
  NONE, NORMAL, (LONG)0x000111FAL,
  0x0000, 0x000A, 0x0001, 0x0001,
        14,       -1,       -1, G_BOX     ,   /* Object 13  */
  NONE, NORMAL, (LONG)0x000111FBL,
  0x0000, 0x000B, 0x0001, 0x0001,
        15,       -1,       -1, G_BOX     ,   /* Object 14  */
  NONE, NORMAL, (LONG)0x000111FCL,
  0x0000, 0x000C, 0x0001, 0x0001,
        16,       -1,       -1, G_BOX     ,   /* Object 15  */
  NONE, NORMAL, (LONG)0x000111FDL,
  0x0000, 0x000D, 0x0001, 0x0001,
        17,       -1,       -1, G_BOX     ,   /* Object 16  */
  NONE, NORMAL, (LONG)0x000111FEL,
  0x0000, 0x000E, 0x0001, 0x0001,
  COWHITE ,       -1,       -1, G_BOX     ,   /* Object 17  */
  NONE, NORMAL, (LONG)0x000111FFL,
  0x0000, 0x000F, 0x0001, 0x0001,
  COBLACK ,       -1,       -1, G_STRING  ,   /* Object 18 COWHITE */
  SELECTABLE, STATE15, (LONG)" Wei\236",
  0x0001, 0x0000, 0x000F, 0x0001,
  CORED   ,       -1,       -1, G_STRING  ,   /* Object 19 COBLACK */
  SELECTABLE, STATE15, (LONG)" Schwarz",
  0x0001, 0x0001, 0x0008, 0x0001,
  COGREEN ,       -1,       -1, G_STRING  ,   /* Object 20 CORED */
  SELECTABLE, STATE15, (LONG)" Rot",
  0x0001, 0x0002, 0x0004, 0x0001,
  COBLUE  ,       -1,       -1, G_STRING  ,   /* Object 21 COGREEN */
  SELECTABLE, STATE15, (LONG)" Gr\201n",
  0x0001, 0x0003, 0x0005, 0x0001,
  COCYAN  ,       -1,       -1, G_STRING  ,   /* Object 22 COBLUE */
  SELECTABLE, STATE15, (LONG)" Blau",
  0x0001, 0x0004, 0x0005, 0x0001,
  COYELLOW,       -1,       -1, G_STRING  ,   /* Object 23 COCYAN */
  SELECTABLE, STATE15, (LONG)" Hellblau",
  0x0001, 0x0005, 0x0009, 0x0001,
  COMAGENT,       -1,       -1, G_STRING  ,   /* Object 24 COYELLOW */
  SELECTABLE, STATE15, (LONG)" Gelb",
  0x0001, 0x0006, 0x0005, 0x0001,
  COGRAY  ,       -1,       -1, G_STRING  ,   /* Object 25 COMAGENT */
  SELECTABLE, STATE15, (LONG)" Rosa",
  0x0001, 0x0007, 0x0005, 0x0001,
  CODGRAY ,       -1,       -1, G_STRING  ,   /* Object 26 COGRAY */
  SELECTABLE, STATE15, (LONG)" Grau",
  0x0001, 0x0008, 0x0005, 0x0001,
  CODRED  ,       -1,       -1, G_STRING  ,   /* Object 27 CODGRAY */
  SELECTABLE, STATE15, (LONG)" Dunkelgrau",
  0x0001, 0x0009, 0x000B, 0x0001,
  CODGREEN,       -1,       -1, G_STRING  ,   /* Object 28 CODRED */
  SELECTABLE, STATE15, (LONG)" Braun",
  0x0001, 0x000A, 0x0006, 0x0001,
  CODBLUE ,       -1,       -1, G_STRING  ,   /* Object 29 CODGREEN */
  SELECTABLE, STATE15, (LONG)" Dunkelgr\201n",
  0x0001, 0x000B, 0x000B, 0x0001,
  CODCYAN ,       -1,       -1, G_STRING  ,   /* Object 30 CODBLUE */
  SELECTABLE, STATE15, (LONG)" Marineblau",
  0x0001, 0x000C, 0x000B, 0x0001,
  CODYELLO,       -1,       -1, G_STRING  ,   /* Object 31 CODCYAN */
  SELECTABLE, STATE15, (LONG)" T\201rkis",
  0x0001, 0x000D, 0x0007, 0x0001,
  CODMAGEN,       -1,       -1, G_STRING  ,   /* Object 32 CODYELLO */
  SELECTABLE, STATE15, (LONG)" Ocker",
  0x0001, 0x000E, 0x0006, 0x0001,
  COLPOPUP,       -1,       -1, G_STRING  ,   /* Object 33 CODMAGEN */
  SELECTABLE, STATE15, (LONG)" Purpur",
  0x0001, 0x000F, 0x0007, 0x0001,
         0, PWIDTH  , PHEIGHT , G_BOX     ,   /* Object 34  */
  NONE, SHADOWED, (LONG)0x00FF1101L,
  0x0014, 0x0001, 0x000B, 0x0002,
        36,       -1,       -1, G_TEXT    ,   /* Object 35 PWIDTH */
  NONE, NORMAL, (LONG)&rs_tedinfo[19],
  0x0000, 0x0000, 0x0007, 0x0001,
        37,       -1,       -1, G_TEXT    ,   /* Object 36  */
  NONE, NORMAL, (LONG)&rs_tedinfo[20],
  0x0007, 0x0000, 0x0004, 0x0001,
  PHEIGHT ,       -1,       -1, G_TEXT    ,   /* Object 37  */
  NONE, NORMAL, (LONG)&rs_tedinfo[21],
  0x0002, 0x0001, 0x0005, 0x0001,
        34,       -1,       -1, G_TEXT    ,   /* Object 38 PHEIGHT */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[22],
  0x0007, 0x0001, 0x0004, 0x0001,
  
  /******** Tree 11 CONFIG ****************************************************/
        -1,        1, CHELP   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0044, 0x0015,
        12,        2, CDBDIR  , G_BUTTON  ,   /* Object 1  */
  NONE, STATE14, (LONG)"Verzeichnisse (Doppelklick w\204hlt neu)",
  0x0002, 0x0001, 0x0040, 0x0007,
  CTMPDIR ,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, DRAW3D|STATE15, (LONG)"Temp-Dateien:",
  0x0002, 0x0002, 0x000D, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3 CTMPDIR */
  NONE, DRAW3D|STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0011, 0x0002, 0x0028, 0x0001,
  CICNDIR ,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, DRAW3D|STATE15, (LONG)"Piktogramme:",
  0x0002, 0x0003, 0x000C, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5 CICNDIR */
  NONE, DRAW3D|STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0011, 0x0003, 0x0028, 0x0001,
  CPICDIR ,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, DRAW3D|STATE15, (LONG)"Bilder:",
  0x0002, 0x0004, 0x0007, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7 CPICDIR */
  NONE, DRAW3D|STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0011, 0x0004, 0x0028, 0x0001,
  CEXPDIR ,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, DRAW3D|STATE15, (LONG)"Import/Export:",
  0x0002, 0x0005, 0x000E, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9 CEXPDIR */
  NONE, DRAW3D|STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0011, 0x0005, 0x0028, 0x0001,
  CDBDIR  ,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, DRAW3D|STATE15, (LONG)"DB-Dateien:",
  0x0002, 0x0006, 0x000B, 0x0001,
         1,       -1,       -1, G_STRING  ,   /* Object 11 CDBDIR */
  NONE, DRAW3D|STATE15, (LONG)"1234567890123456789012345678901234567890",
  0x0011, 0x0006, 0x0028, 0x0001,
  COK     ,       13, CUNIX   , G_BUTTON  ,   /* Object 12  */
  NONE, STATE14, (LONG)"Systemparamter",
  0x0002, 0x0009, 0x0040, 0x0008,
  CBLINK  ,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, DRAW3D|STATE15, (LONG)"~Blinkrate:",
  0x0002, 0x0002, 0x000B, 0x0001,
  CBEEP   ,       -1,       -1, G_FBOXTEXT,   /* Object 14 CBLINK */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[23],
  0x000D, 0x0002, 0x0002, 0x0001,
  CUSEFONT,       -1,       -1, G_BUTTON  ,   /* Object 15 CBEEP */
  SELECTABLE, SELECTED|DRAW3D|STATE13, (LONG)"~Ton bei Fehlermeldungen",
  0x0002, 0x0004, 0x0018, 0x0001,
  CGROW   ,       -1,       -1, G_BUTTON  ,   /* Object 16 CUSEFONT */
  SELECTABLE, SELECTED|DRAW3D|STATE13, (LONG)"~Externe Schriften benutzen",
  0x0021, 0x0004, 0x001C, 0x0001,
  CEXPORT ,       -1,       -1, G_BUTTON  ,   /* Object 17 CGROW */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Grow/Shrinkbox zeichnen",
  0x0002, 0x0005, 0x0018, 0x0001,
  CAUTO   ,       -1,       -1, G_BUTTON  ,   /* Object 18 CEXPORT */
  SELECTABLE, SELECTED|DRAW3D|STATE13, (LONG)"Automatische DB~S-Erzeugung",
  0x0021, 0x0005, 0x001B, 0x0001,
  CFUNCS  ,       -1,       -1, G_BUTTON  ,   /* Object 19 CAUTO */
  SELECTABLE, SELECTED|DRAW3D|STATE13, (LONG)"A~utomatisches Speichern",
  0x0002, 0x0006, 0x0019, 0x0001,
  CMETA   ,       -1,       -1, G_BUTTON  ,   /* Object 20 CFUNCS */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Funktionstasten verstecken",
  0x0021, 0x0006, 0x001C, 0x0001,
  CUNIX   ,       -1,       -1, G_BUTTON  ,   /* Object 21 CMETA */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Druckausgabe auf ~Metadatei",
  0x0002, 0x0007, 0x001B, 0x0001,
        12,       -1,       -1, G_BUTTON  ,   /* Object 22 CUNIX */
  SELECTABLE, DRAW3D|STATE13, (LONG)"UNI~X kompatible Struktur",
  0x0021, 0x0007, 0x001A, 0x0001,
  CCANCEL ,       -1,       -1, G_BUTTON  ,   /* Object 23 COK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0010, 0x0012, 0x000A, 0x0002,
  CHELP   ,       -1,       -1, G_BUTTON  ,   /* Object 24 CCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x001D, 0x0012, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 25 CHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x002A, 0x0012, 0x000A, 0x0002,
  
  /******** Tree 12 PARAMS ****************************************************/
        -1,        1, PFONT   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x004B, 0x0013,
        22,        2, PDUSAGE , G_BUTTON  ,   /* Object 1  */
  NONE, STATE14, (LONG)"Datenbankfenster",
  0x0002, 0x0001, 0x0017, 0x0011,
  PTABLES ,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, DRAW3D|STATE15, (LONG)"~Tabellen:",
  0x0001, 0x0002, 0x000A, 0x0001,
         4,       -1,       -1, G_FBOXTEXT,   /* Object 3 PTABLES */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[24],
  0x0011, 0x0002, 0x0004, 0x0001,
  PFIELDS ,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, STATE15, (LONG)"~Felder:",
  0x0001, 0x0003, 0x0008, 0x0001,
         6,       -1,       -1, G_FBOXTEXT,   /* Object 5 PFIELDS */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[25],
  0x0011, 0x0003, 0x0004, 0x0001,
  PKEYS   ,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, DRAW3D|STATE15, (LONG)"~Indizes:",
  0x0001, 0x0005, 0x0009, 0x0001,
         8,       -1,       -1, G_FBOXTEXT,   /* Object 7 PKEYS */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[26],
  0x0011, 0x0005, 0x0004, 0x0001,
  PRELS   ,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, STATE15, (LONG)"~Beziehungen:",
  0x0001, 0x0006, 0x000D, 0x0001,
        10,       -1,       -1, G_FBOXTEXT,   /* Object 9 PRELS */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[27],
  0x0011, 0x0006, 0x0004, 0x0001,
  PUSERS  ,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, DRAW3D|STATE15, (LONG)"Benut~zer:",
  0x0001, 0x0008, 0x000A, 0x0001,
        12,       -1,       -1, G_FBOXTEXT,   /* Object 11 PUSERS */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[28],
  0x0011, 0x0008, 0x0004, 0x0001,
  PICONS  ,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, STATE15, (LONG)"Si~nnbilder:",
  0x0001, 0x0009, 0x000C, 0x0001,
        14,       -1,       -1, G_FBOXTEXT,   /* Object 13 PICONS */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[29],
  0x0011, 0x0009, 0x0004, 0x0001,
  PFORMATS,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, DRAW3D|STATE15, (LONG)"F~ormate:",
  0x0001, 0x000B, 0x0009, 0x0001,
        16,       -1,       -1, G_FBOXTEXT,   /* Object 15 PFORMATS */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[30],
  0x0011, 0x000B, 0x0004, 0x0001,
  PLOOKUPS,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, STATE15, (LONG)"~Wertetabellen:",
  0x0001, 0x000C, 0x000F, 0x0001,
        18,       -1,       -1, G_FBOXTEXT,   /* Object 17 PLOOKUPS */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[31],
  0x0011, 0x000C, 0x0004, 0x0001,
  PMASKS  ,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, DRAW3D|STATE15, (LONG)"~Masken:",
  0x0001, 0x000E, 0x0008, 0x0001,
  PDTXT   ,       -1,       -1, G_FBOXTEXT,   /* Object 19 PMASKS */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[32],
  0x0011, 0x000E, 0x0004, 0x0001,
  PDUSAGE ,       -1,       -1, G_STRING  ,   /* Object 20 PDTXT */
  NONE, DRAW3D|STATE15, (LONG)"Verbrauch (KB):",
  0x0001, 0x0010, 0x000F, 0x0001,
         1,       -1,       -1, G_STRING  ,   /* Object 21 PDUSAGE */
  NONE, DRAW3D|STATE15, (LONG)"9999",
  0x0011, 0x0010, 0x0004, 0x0001,
        29,       23,       28, G_BUTTON  ,   /* Object 22  */
  NONE, STATE14, (LONG)"Dokumentparameter",
  0x001A, 0x0001, 0x002F, 0x0005,
  PDOCW   ,       -1,       -1, G_STRING  ,   /* Object 23  */
  NONE, DRAW3D|STATE15, (LONG)"B~reite:",
  0x0002, 0x0002, 0x0008, 0x0001,
        25,       -1,       -1, G_FBOXTEXT,   /* Object 24 PDOCW */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[33],
  0x000A, 0x0002, 0x0005, 0x0001,
        26,       -1,       -1, G_STRING  ,   /* Object 25  */
  NONE, DRAW3D|STATE15, (LONG)"Zeichen",
  0x0010, 0x0002, 0x0007, 0x0001,
  PDOCH   ,       -1,       -1, G_STRING  ,   /* Object 26  */
  NONE, DRAW3D|STATE15, (LONG)"H\224h~e:",
  0x0002, 0x0004, 0x0006, 0x0001,
        28,       -1,       -1, G_FBOXTEXT,   /* Object 27 PDOCH */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[34],
  0x000A, 0x0004, 0x0005, 0x0001,
        22,       -1,       -1, G_STRING  ,   /* Object 28  */
  NONE, DRAW3D|STATE15, (LONG)"Zeichen",
  0x0010, 0x0004, 0x0007, 0x0001,
        34,       30, PMUSAGE , G_BUTTON  ,   /* Object 29  */
  NONE, STATE14, (LONG)"Maskenfenster",
  0x001A, 0x0007, 0x002F, 0x0003,
  PPICS   ,       -1,       -1, G_STRING  ,   /* Object 30  */
  NONE, DRAW3D|STATE15, (LONG)"Bi~lder:",
  0x0002, 0x0002, 0x0008, 0x0001,
  PMTXT   ,       -1,       -1, G_FBOXTEXT,   /* Object 31 PPICS */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[35],
  0x000A, 0x0002, 0x0004, 0x0001,
  PMUSAGE ,       -1,       -1, G_STRING  ,   /* Object 32 PMTXT */
  NONE, DRAW3D|STATE15, (LONG)"Verbrauch (KB):",
  0x0017, 0x0002, 0x000F, 0x0001,
        29,       -1,       -1, G_STRING  ,   /* Object 33 PMUSAGE */
  NONE, DRAW3D|STATE15, (LONG)"9999",
  0x0027, 0x0002, 0x0004, 0x0001,
  POK     ,       35, PWINH   , G_BUTTON  ,   /* Object 34  */
  NONE, WHITEBAK|STATE14, (LONG)"Anfangsschrift & Fenstergr\224\236e",
  0x001A, 0x000B, 0x002F, 0x0005,
  PDOCFONT,       -1,       -1, G_STRING  ,   /* Object 35  */
  NONE, DRAW3D|STATE15, (LONG)"Schrift:",
  0x0001, 0x0002, 0x0008, 0x0001,
        37,       -1,       -1, G_STRING  ,   /* Object 36 PDOCFONT */
  NONE, DRAW3D|STATE12|STATE15, (LONG)"1234567890123456",
  0x000A, 0x0002, 0x0010, 0x0001,
  PWINW   ,       -1,       -1, G_STRING  ,   /* Object 37  */
  NONE, DRAW3D|STATE15, (LONG)"Breite:",
  0x001E, 0x0002, 0x0007, 0x0001,
        39,       -1,       -1, G_FBOXTEXT,   /* Object 38 PWINW */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[36],
  0x0026, 0x0002, 0x0005, 0x0001,
  PDOCPOIN,       -1,       -1, G_STRING  ,   /* Object 39  */
  NONE, STATE15, (LONG)"Punkt:",
  0x0003, 0x0003, 0x0006, 0x0001,
        41,       -1,       -1, G_STRING  ,   /* Object 40 PDOCPOIN */
  NONE, STATE12|STATE15, (LONG)"999",
  0x000A, 0x0003, 0x0003, 0x0001,
  PWINH   ,       -1,       -1, G_STRING  ,   /* Object 41  */
  NONE, STATE15, (LONG)"H\224he:",
  0x0020, 0x0003, 0x0005, 0x0001,
        34,       -1,       -1, G_FBOXTEXT,   /* Object 42 PWINH */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[37],
  0x0026, 0x0003, 0x0005, 0x0001,
  PCANCEL ,       -1,       -1, G_BUTTON  ,   /* Object 43 POK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x001A, 0x0011, 0x000A, 0x0002,
  PHELP   ,       -1,       -1, G_BUTTON  ,   /* Object 44 PCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x0026, 0x0011, 0x000A, 0x0002,
  PFONT   ,       -1,       -1, G_BUTTON  ,   /* Object 45 PHELP */
  SELECTABLE|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0032, 0x0011, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 46 PFONT */
  SELECTABLE|LASTOB, WHITEBAK, (LONG)"~Schrift...",
  0x003E, 0x0011, 0x000B, 0x0002,
  
  /******** Tree 13 USERINTR ****************************************************/
        -1,        1, UIHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0048, 0x0016,
         6,        2, UISYSCOL, G_BUTTON  ,   /* Object 1  */
  NONE, WHITEBAK|STATE14, (LONG)"Farben",
  0x0002, 0x0001, 0x0044, 0x0004,
  UISYSINX,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, DRAW3D|STATE15, (LONG)"~Element:",
  0x0001, 0x0002, 0x0009, 0x0001,
         4,       -1,       -1, G_BUTTON  ,   /* Object 3 UISYSINX */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"1234567890123456789012345678",
  0x000B, 0x0002, 0x001C, 0x0001,
  UISYSCOL,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, DRAW3D|STATE15, (LONG)"Far~be:",
  0x002B, 0x0002, 0x0007, 0x0001,
         1,       -1,       -1, G_BUTTON  ,   /* Object 5 UISYSCOL */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"\0",
  0x0033, 0x0002, 0x0010, 0x0001,
        10, UIUSE3D , UISTDFS , G_BUTTON  ,   /* Object 6  */
  NONE, STATE14, (LONG)"Darstellung",
  0x0002, 0x0005, 0x0023, 0x0005,
  UIROUND ,       -1,       -1, G_BUTTON  ,   /* Object 7 UIUSE3D */
  SELECTABLE, SELECTED|DRAW3D|STATE13, (LONG)"Oberfl\204che im ~3D-Look",
  0x0001, 0x0002, 0x0016, 0x0001,
  UISTDFS ,       -1,       -1, G_BUTTON  ,   /* Object 8 UIROUND */
  SELECTABLE, SELECTED|DRAW3D|STATE13, (LONG)"~Dialoge mit Bildrahmen",
  0x0001, 0x0003, 0x0017, 0x0001,
         6,       -1,       -1, G_BUTTON  ,   /* Object 9 UISTDFS */
  SELECTABLE, DRAW3D|STATE13, (LONG)"S~tandard-Dateiauswahl benutzen",
  0x0001, 0x0004, 0x001F, 0x0001,
        18,       11, UISB    , G_BUTTON  ,   /* Object 10  */
  NONE, STATE14, (LONG)"Desktop",
  0x0027, 0x0005, 0x001F, 0x0009,
  UICOLOR ,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, DRAW3D|STATE15, (LONG)"~Farbe:",
  0x0001, 0x0002, 0x0007, 0x0001,
        13,       -1,       -1, G_BUTTON  ,   /* Object 12 UICOLOR */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"\0",
  0x000A, 0x0002, 0x0010, 0x0001,
  UIPAT   ,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, DRAW3D|STATE15, (LONG)"~Muster:",
  0x0001, 0x0004, 0x0008, 0x0001,
  UIUSEWND,       -1,       -1, G_BUTTON  ,   /* Object 14 UIPAT */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"\0",
  0x000A, 0x0004, 0x0010, 0x0001,
  UITOP   ,       -1,       -1, G_BUTTON  ,   /* Object 15 UIUSEWND */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~In Fenster darstellen",
  0x0001, 0x0006, 0x0016, 0x0001,
  UISB    ,       -1,       -1, G_BUTTON  ,   /* Object 16 UITOP */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Bei K~lick aktivieren",
  0x0001, 0x0007, 0x0015, 0x0001,
        10,       -1,       -1, G_BUTTON  ,   /* Object 17 UISB */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Bildlaufleisten ~zeigen",
  0x0001, 0x0008, 0x0017, 0x0001,
        25,       19, UIARROW , G_BUTTON  ,   /* Object 18  */
  NONE, WHITEBAK|STATE14, (LONG)"Kontrollelemente",
  0x0002, 0x000B, 0x0023, 0x0008,
  UICHECK ,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, DRAW3D|STATE15, (LONG)"~Checkbox:",
  0x0001, 0x0002, 0x000A, 0x0001,
        21,       -1,       -1, G_BUTTON  ,   /* Object 20 UICHECK */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"\0",
  0x000F, 0x0002, 0x000E, 0x0001,
  UIRADIO ,       -1,       -1, G_STRING  ,   /* Object 21  */
  NONE, DRAW3D|STATE15, (LONG)"~Radio-Knopf:",
  0x0001, 0x0004, 0x000D, 0x0001,
        23,       -1,       -1, G_BUTTON  ,   /* Object 22 UIRADIO */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"\0",
  0x000F, 0x0004, 0x000E, 0x0001,
  UIARROW ,       -1,       -1, G_STRING  ,   /* Object 23  */
  NONE, DRAW3D|STATE15, (LONG)"~Pfeile:",
  0x0001, 0x0006, 0x0008, 0x0001,
        18,       -1,       -1, G_BUTTON  ,   /* Object 24 UIARROW */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"\0",
  0x000F, 0x0006, 0x000E, 0x0001,
  UIOK    , UIROUNDB, UISHADOW, G_BUTTON  ,   /* Object 25  */
  NONE, WHITEBAK|STATE14, (LONG)"Schaltfl\204chen",
  0x0027, 0x000E, 0x001F, 0x0005,
        27,       -1,       -1, G_BUTTON  ,   /* Object 26 UIROUNDB */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Abgerundete Ec~ken",
  0x0001, 0x0002, 0x0012, 0x0001,
  UISHADOW,       -1,       -1, G_STRING  ,   /* Object 27  */
  NONE, STATE15, (LONG)"Schatte~nbreite:",
  0x0001, 0x0003, 0x0010, 0x0001,
        25,       -1,       -1, G_FBOXTEXT,   /* Object 28 UISHADOW */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[38],
  0x0011, 0x0003, 0x0002, 0x0001,
  UICANCEL,       -1,       -1, G_BUTTON  ,   /* Object 29 UIOK */
  SELECTABLE|DEFAULT|EXIT, DRAW3D|WHITEBAK, (LONG)"~OK",
  0x0015, 0x0014, 0x000A, 0x0002,
  UIRESET ,       -1,       -1, G_BUTTON  ,   /* Object 30 UICANCEL */
  SELECTABLE|EXIT|FLAGS13, DRAW3D|WHITEBAK, (LONG)"~Abbruch",
  0x0022, 0x0014, 0x000A, 0x0002,
  UIHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 31 UIRESET */
  SELECTABLE, DRAW3D|WHITEBAK, (LONG)"~Standard",
  0x002F, 0x0014, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 32 UIHELP */
  SELECTABLE|LASTOB|FLAGS14, DRAW3D|WHITEBAK, (LONG)"~Hilfe",
  0x003C, 0x0014, 0x000A, 0x0002,
  
  /******** Tree 14 OPENDB ****************************************************/
        -1,        1, BHELP   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x003C, 0x0013,
  BBASE   ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datenbank:",
  0x0002, 0x0001, 0x000A, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 BBASE */
  NONE, STATE12|STATE15, (LONG)"________________________________________",
  0x000D, 0x0001, 0x0028, 0x0001,
  BUSER   ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"~Benutzer:",
  0x0002, 0x0003, 0x000A, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 4 BUSER */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[39],
  0x000D, 0x0003, 0x0023, 0x0001,
  BPASS   ,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"~Pa\236wort:",
  0x0002, 0x0005, 0x0009, 0x0001,
         7,       -1,       -1, G_FBOXTEXT,   /* Object 6 BPASS */
  EDITABLE|FLAGS15, STATE15, (LONG)&rs_tedinfo[40],
  0x000D, 0x0005, 0x0023, 0x0001,
        16,        8, BDATFLSH, G_BUTTON  ,   /* Object 7  */
  NONE, STATE14, (LONG)"Cache",
  0x0002, 0x0007, 0x0019, 0x0008,
  BINDCACH,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, DRAW3D|STATE15, (LONG)"Inde~x-Cache:",
  0x0002, 0x0002, 0x000D, 0x0001,
        10,       -1,       -1, G_FBOXTEXT,   /* Object 9 BINDCACH */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[41],
  0x000F, 0x0002, 0x0006, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, DRAW3D|STATE15, (LONG)"KB",
  0x0016, 0x0002, 0x0002, 0x0001,
  BDATCACH,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, DRAW3D|STATE15, (LONG)"Date~n-Cache:",
  0x0002, 0x0004, 0x000D, 0x0001,
        13,       -1,       -1, G_FBOXTEXT,   /* Object 12 BDATCACH */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[42],
  0x000F, 0x0004, 0x0006, 0x0001,
  BINDFLSH,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, DRAW3D|STATE15, (LONG)"KB",
  0x0016, 0x0004, 0x0002, 0x0001,
  BDATFLSH,       -1,       -1, G_BUTTON  ,   /* Object 14 BINDFLSH */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Index schreiben",
  0x0002, 0x0006, 0x0010, 0x0001,
         7,       -1,       -1, G_BUTTON  ,   /* Object 15 BDATFLSH */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Daten schreiben",
  0x0002, 0x0007, 0x0010, 0x0001,
  BOK     , BSINGLE , BRDONLY , G_BUTTON  ,   /* Object 16  */
  NONE, STATE14, (LONG)"Modus",
  0x001C, 0x0007, 0x001E, 0x0008,
  BMULTI  ,       -1,       -1, G_BUTTON  ,   /* Object 17 BSINGLE */
  SELECTABLE|RBUTTON, SELECTED|DRAW3D|STATE13, (LONG)"~Single-User (Exklusiv)",
  0x0002, 0x0002, 0x0017, 0x0001,
  BRDONLY ,       -1,       -1, G_BUTTON  ,   /* Object 18 BMULTI */
  SELECTABLE|RBUTTON, DISABLED|DRAW3D|STATE13, (LONG)"~Multi-User/Multitasking",
  0x0002, 0x0003, 0x0018, 0x0001,
        16,       -1,       -1, G_BUTTON  ,   /* Object 19 BRDONLY */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Nur ~Lesen",
  0x0002, 0x0006, 0x000A, 0x0001,
  BCANCEL ,       -1,       -1, G_BUTTON  ,   /* Object 20 BOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x000C, 0x0010, 0x000A, 0x0002,
  BHELP   ,       -1,       -1, G_BUTTON  ,   /* Object 21 BCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x0019, 0x0010, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 22 BHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0026, 0x0010, 0x000A, 0x0002,
  
  /******** Tree 15 BASEMENU ****************************************************/
        -1,        1,        7, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         7,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1, MBINFO  , MBPARAM , G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x0022, 0x0301,
  MBVIEW  ,       -1,       -1, G_TITLE   ,   /* Object 3 MBINFO */
  NONE, NORMAL, (LONG)" Info",
  0x0000, 0x0000, 0x0006, 0x0301,
  MBOPTION,       -1,       -1, G_TITLE   ,   /* Object 4 MBVIEW */
  NONE, NORMAL, (LONG)" Sicht",
  0x0006, 0x0000, 0x0007, 0x0301,
  MBPARAM ,       -1,       -1, G_TITLE   ,   /* Object 5 MBOPTION */
  NONE, NORMAL, (LONG)" Optionen",
  0x000D, 0x0000, 0x000A, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 6 MBPARAM */
  NONE, NORMAL, (LONG)" Parameter",
  0x0017, 0x0000, 0x000B, 0x0301,
         0,        8,       31, G_IBOX    ,   /* Object 7  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0013,
        10, MBBASEIN, MBBASEIN, G_BOX     ,   /* Object 8  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x000F, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 9 MBBASEIN */
  NONE, NORMAL, (LONG)"  Info... \001F2",
  0x0000, 0x0000, 0x000F, 0x0001,
        19, MBFULL  , MBLONG  , G_BOX     ,   /* Object 10  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0008, 0x0000, 0x0015, 0x0008,
  MBBESTFI,       -1,       -1, G_STRING  ,   /* Object 11 MBFULL */
  NONE, CHECKED, (LONG)"  Original       \007O",
  0x0000, 0x0000, 0x0015, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12 MBBESTFI */
  NONE, NORMAL, (LONG)"  Einpassen      \007P",
  0x0000, 0x0001, 0x0015, 0x0001,
  MBRELS  ,       -1,       -1, G_STRING  ,   /* Object 13  */
  EDITABLE, DISABLED, (LONG)"---------------------",
  0x0000, 0x0002, 0x0015, 0x0001,
  MBLOOKUP,       -1,       -1, G_STRING  ,   /* Object 14 MBRELS */
  NONE, CHECKED, (LONG)"  Beziehungen    \007B",
  0x0000, 0x0003, 0x0015, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15 MBLOOKUP */
  NONE, NORMAL, (LONG)"  Wertetabellen  \007U",
  0x0000, 0x0004, 0x0015, 0x0001,
  MBSHORT ,       -1,       -1, G_STRING  ,   /* Object 16  */
  EDITABLE, DISABLED, (LONG)"---------------------",
  0x0000, 0x0005, 0x0015, 0x0001,
  MBLONG  ,       -1,       -1, G_STRING  ,   /* Object 17 MBSHORT */
  NONE, CHECKED, (LONG)"  Normal         \007S",
  0x0000, 0x0006, 0x0015, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 18 MBLONG */
  NONE, NORMAL, (LONG)"  Ausf\201hrlich    \007L",
  0x0000, 0x0007, 0x0015, 0x0001,
        31, MBTOOLS , MBDELRUL, G_BOX     ,   /* Object 19  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000F, 0x0000, 0x001B, 0x000B,
        21,       -1,       -1, G_STRING  ,   /* Object 20 MBTOOLS */
  NONE, CHECKED, (LONG)"  Werkzeuge            \007W",
  0x0000, 0x0000, 0x001B, 0x0001,
  MBTABLE ,       -1,       -1, G_STRING  ,   /* Object 21  */
  EDITABLE, DISABLED, (LONG)"---------------------------",
  0x0000, 0x0001, 0x001B, 0x0001,
  MBFIELD ,       -1,       -1, G_STRING  ,   /* Object 22 MBTABLE */
  NONE, NORMAL, (LONG)"  Neue Tabelle...      \007T",
  0x0000, 0x0002, 0x001B, 0x0001,
  MBKEY   ,       -1,       -1, G_STRING  ,   /* Object 23 MBFIELD */
  NONE, NORMAL, (LONG)"  Neues Feld...        \007F",
  0x0000, 0x0003, 0x001B, 0x0001,
        25,       -1,       -1, G_STRING  ,   /* Object 24 MBKEY */
  NONE, NORMAL, (LONG)"  Neuer Multi-Index... \007K",
  0x0000, 0x0004, 0x001B, 0x0001,
  MBMASK  ,       -1,       -1, G_STRING  ,   /* Object 25  */
  EDITABLE, DISABLED, (LONG)"---------------------------",
  0x0000, 0x0005, 0x001B, 0x0001,
  MBFORMAT,       -1,       -1, G_STRING  ,   /* Object 26 MBMASK */
  NONE, NORMAL, (LONG)"  Masken...            \007M",
  0x0000, 0x0006, 0x001B, 0x0001,
  MBICONS ,       -1,       -1, G_STRING  ,   /* Object 27 MBFORMAT */
  NONE, NORMAL, (LONG)"  Format...            \007G",
  0x0000, 0x0007, 0x001B, 0x0001,
        29,       -1,       -1, G_STRING  ,   /* Object 28 MBICONS */
  NONE, NORMAL, (LONG)"  Sinnbilder...        \007I",
  0x0000, 0x0008, 0x001B, 0x0001,
  MBDELRUL,       -1,       -1, G_STRING  ,   /* Object 29  */
  EDITABLE, DISABLED, (LONG)"---------------------------",
  0x0000, 0x0009, 0x001B, 0x0001,
        19,       -1,       -1, G_STRING  ,   /* Object 30 MBDELRUL */
  NONE, NORMAL, (LONG)"  Regel(n) l\224schen     \007R",
  0x0000, 0x000A, 0x001B, 0x0001,
         7, MBFONT  , MBCIFACE, G_BOX     ,   /* Object 31  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0019, 0x0000, 0x001C, 0x0008,
  MBSIZE  ,       -1,       -1, G_STRING  ,   /* Object 32 MBFONT */
  NONE, NORMAL, (LONG)"  Schrift...            \007N",
  0x0000, 0x0000, 0x001C, 0x0001,
        34,       -1,       -1, G_STRING  ,   /* Object 33 MBSIZE */
  NONE, NORMAL, (LONG)"  Dokumentgr\224\236e...      \007E",
  0x0000, 0x0001, 0x001C, 0x0001,
  MBACCESS,       -1,       -1, G_STRING  ,   /* Object 34  */
  EDITABLE, DISABLED, (LONG)"----------------------------",
  0x0000, 0x0002, 0x001C, 0x0001,
  MBPARAMS,       -1,       -1, G_STRING  ,   /* Object 35 MBACCESS */
  NONE, NORMAL, (LONG)"  Zugriffsrechte...     \007Z",
  0x0000, 0x0003, 0x001C, 0x0001,
        37,       -1,       -1, G_STRING  ,   /* Object 36 MBPARAMS */
  NONE, NORMAL, (LONG)"  DB-Parameter...       \007D",
  0x0000, 0x0004, 0x001C, 0x0001,
  MBTXT   ,       -1,       -1, G_STRING  ,   /* Object 37  */
  EDITABLE, DISABLED, (LONG)"----------------------------",
  0x0000, 0x0005, 0x001C, 0x0001,
  MBCIFACE,       -1,       -1, G_STRING  ,   /* Object 38 MBTXT */
  NONE, NORMAL, (LONG)"  Textbeschreibung...   \007H",
  0x0000, 0x0006, 0x001C, 0x0001,
        31,       -1,       -1, G_STRING  ,   /* Object 39 MBCIFACE */
  LASTOB, NORMAL, (LONG)"  C-Schnittstelle...    \007V",
  0x0000, 0x0007, 0x001C, 0x0001,
  
  /******** Tree 16 MASKMENU ****************************************************/
        -1,        1,        5, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x00A0, 0x0019,
         5,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x00A0, 0x0201,
         1, MMINFO  , MMOPTION, G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x0010, 0x0301,
  MMOPTION,       -1,       -1, G_TITLE   ,   /* Object 3 MMINFO */
  NONE, NORMAL, (LONG)" Info",
  0x0000, 0x0000, 0x0006, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 4 MMOPTION */
  NONE, NORMAL, (LONG)" Optionen",
  0x0006, 0x0000, 0x000A, 0x0301,
         0,        6,        8, G_IBOX    ,   /* Object 5  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0013,
         8, MMASKINF, MMASKINF, G_BOX     ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x000F, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 7 MMASKINF */
  NONE, NORMAL, (LONG)"  Info... \001F2",
  0x0000, 0x0000, 0x000F, 0x0001,
         5, MMTOOLS , MMSIZE  , G_BOX     ,   /* Object 8  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0008, 0x0000, 0x0019, 0x000C,
        10,       -1,       -1, G_STRING  ,   /* Object 9 MMTOOLS */
  NONE, CHECKED, (LONG)"  Werkzeuge          \007W",
  0x0000, 0x0000, 0x0019, 0x0001,
  MMCHECK ,       -1,       -1, G_STRING  ,   /* Object 10  */
  EDITABLE, DISABLED, (LONG)"-------------------------",
  0x0000, 0x0001, 0x0019, 0x0001,
  MMSORT  ,       -1,       -1, G_STRING  ,   /* Object 11 MMCHECK */
  NONE, NORMAL, (LONG)"  Maske pr\201fen       \007K",
  0x0000, 0x0002, 0x0019, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12 MMSORT */
  NONE, NORMAL, (LONG)"  Sortieren          \007R",
  0x0000, 0x0003, 0x0019, 0x0001,
  MMFONT  ,       -1,       -1, G_STRING  ,   /* Object 13  */
  EDITABLE, DISABLED, (LONG)"-------------------------",
  0x0000, 0x0004, 0x0019, 0x0001,
  MMFILL  ,       -1,       -1, G_STRING  ,   /* Object 14 MMFONT */
  NONE, NORMAL, (LONG)"  Schrift...         \007N",
  0x0000, 0x0005, 0x0019, 0x0001,
  MMCOLOR ,       -1,       -1, G_STRING  ,   /* Object 15 MMFILL */
  NONE, NORMAL, (LONG)"  F\201llmuster...      \007M",
  0x0000, 0x0006, 0x0019, 0x0001,
  MMLINES ,       -1,       -1, G_STRING  ,   /* Object 16 MMCOLOR */
  NONE, NORMAL, (LONG)"  Farbe...           \007A",
  0x0000, 0x0007, 0x0019, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 17 MMLINES */
  NONE, NORMAL, (LONG)"  Linienattribute... \007I",
  0x0000, 0x0008, 0x0019, 0x0001,
  MMGRID  ,       -1,       -1, G_STRING  ,   /* Object 18  */
  EDITABLE, DISABLED, (LONG)"-------------------------",
  0x0000, 0x0009, 0x0019, 0x0001,
  MMSIZE  ,       -1,       -1, G_STRING  ,   /* Object 19 MMGRID */
  NONE, NORMAL, (LONG)"  Gitter...          \007G",
  0x0000, 0x000A, 0x0019, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 20 MMSIZE */
  LASTOB, NORMAL, (LONG)"  Dokumentgr\224\236e...   \007E",
  0x0000, 0x000B, 0x0019, 0x0001,
  
  /******** Tree 17 DBICONS ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, STATE14, (LONG)0x00FF1140L,
  0x0000, 0x0000, 0x001B, 0x0003,
         0, DBARROW , IMASK   , G_IBOX    ,   /* Object 1  */
  NONE, STATE10|STATE15, (LONG)0x00011100L,
  0x0000, 0x0000, 0x001B, 0x0003,
  DBLINK  ,       -1,       -1, G_BUTTON  ,   /* Object 2 DBARROW */
  SELECTABLE|RBUTTON, DRAW3D|STATE15, (LONG)"arrow",
  0x0001, 0x0001, 0x0005, 0x0002,
  ITABLE  ,       -1,       -1, G_BUTTON  ,   /* Object 3 DBLINK */
  SELECTABLE|RBUTTON, DRAW3D|STATE15, (LONG)"link",
  0x0005, 0x0001, 0x0004, 0x0002,
  IFIELD  ,       -1,       -1, G_BUTTON  ,   /* Object 4 ITABLE */
  SELECTABLE, DRAW3D|STATE15, (LONG)"table",
  0x000A, 0x0001, 0x0005, 0x0002,
  IKEY    ,       -1,       -1, G_BUTTON  ,   /* Object 5 IFIELD */
  SELECTABLE, DRAW3D|STATE15, (LONG)"field",
  0x000E, 0x0001, 0x0005, 0x0002,
  IMASK   ,       -1,       -1, G_BUTTON  ,   /* Object 6 IKEY */
  SELECTABLE, DRAW3D|STATE15, (LONG)"mltkey",
  0x0012, 0x0001, 0x0006, 0x0002,
         1,       -1,       -1, G_BUTTON  ,   /* Object 7 IMASK */
  SELECTABLE|LASTOB, DRAW3D|STATE15, (LONG)"mask",
  0x0016, 0x0001, 0x0004, 0x0002,
  
  /******** Tree 18 DBINFO ****************************************************/
        -1,        1, DIHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x003D, 0x0016,
  DIDBNAME,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datenbank:",
  0x0002, 0x0001, 0x000A, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 DIDBNAME */
  NONE, STATE12|STATE15, (LONG)"_____________________________________________",
  0x000D, 0x0001, 0x002D, 0x0001,
  DIUSER  ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"Benutzer:",
  0x0002, 0x0003, 0x0009, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4 DIUSER */
  NONE, STATE12|STATE15, (LONG)"_________________________________",
  0x000D, 0x0003, 0x0021, 0x0001,
  DICREAT ,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"Erzeugt:",
  0x0002, 0x0005, 0x0008, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6 DICREAT */
  NONE, STATE12|STATE13|STATE15, (LONG)"__.__.____   __:__:__",
  0x0013, 0x0005, 0x0015, 0x0001,
  DILASTUS,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, DRAW3D|STATE15, (LONG)"Zuletzt benutzt:",
  0x0002, 0x0007, 0x0010, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8 DILASTUS */
  NONE, DRAW3D|STATE12|STATE13|STATE15, (LONG)"__.__.____   __:__:__",
  0x0013, 0x0007, 0x0015, 0x0001,
        31,       10, DIRDWR  , G_BUTTON  ,   /* Object 9  */
  NONE, STATE14, (LONG)"Datendatei",
  0x0002, 0x0008, 0x001C, 0x000D,
  DIDATSIZ,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, DRAW3D|STATE15, (LONG)"Gr\224\236e:",
  0x0001, 0x0002, 0x0006, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11 DIDATSIZ */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"99999 KB",
  0x000C, 0x0002, 0x0008, 0x0001,
  DIDATUSE,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, DRAW3D|STATE15, (LONG)"Belegt:",
  0x0001, 0x0003, 0x0007, 0x0001,
  DIDATUSP,       -1,       -1, G_STRING  ,   /* Object 13 DIDATUSE */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"99999 KB",
  0x000C, 0x0003, 0x0008, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14 DIDATUSP */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"(100%)",
  0x0015, 0x0003, 0x0006, 0x0001,
  DIDATFRE,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, DRAW3D|STATE15, (LONG)"Frei:",
  0x0001, 0x0004, 0x0005, 0x0001,
  DIDATFRP,       -1,       -1, G_STRING  ,   /* Object 16 DIDATFRE */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"99999 KB",
  0x000C, 0x0004, 0x0008, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 17 DIDATFRP */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"(100%)",
  0x0015, 0x0004, 0x0006, 0x0001,
  DIDATCAC,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, DRAW3D|STATE15, (LONG)"Cache:",
  0x0001, 0x0006, 0x0006, 0x0001,
        20,       -1,       -1, G_STRING  ,   /* Object 19 DIDATCAC */
  NONE, DRAW3D|STATE15, (LONG)"99999 KB",
  0x000C, 0x0006, 0x0008, 0x0001,
  DIDATHIT,       -1,       -1, G_STRING  ,   /* Object 20  */
  NONE, DRAW3D|STATE15, (LONG)"Treffer:",
  0x0001, 0x0007, 0x0008, 0x0001,
        22,       -1,       -1, G_STRING  ,   /* Object 21 DIDATHIT */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"100%",
  0x000C, 0x0007, 0x0004, 0x0001,
  DIDATFLU,       -1,       -1, G_STRING  ,   /* Object 22  */
  NONE, DRAW3D|STATE15, (LONG)"Autoflush:",
  0x0001, 0x0008, 0x000A, 0x0001,
        24,       -1,       -1, G_STRING  ,   /* Object 23 DIDATFLU */
  NONE, DRAW3D|STATE15, (LONG)"nein",
  0x000C, 0x0008, 0x0004, 0x0001,
  DIHOLES ,       -1,       -1, G_STRING  ,   /* Object 24  */
  NONE, DRAW3D|STATE15, (LONG)"L\224cher:",
  0x0001, 0x000A, 0x0007, 0x0001,
  DIHOLESP,       -1,       -1, G_STRING  ,   /* Object 25 DIHOLES */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"99999 KB",
  0x000C, 0x000A, 0x0008, 0x0001,
        27,       -1,       -1, G_STRING  ,   /* Object 26 DIHOLESP */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"(100%)",
  0x0015, 0x000A, 0x0006, 0x0001,
  DIDATMOD,       -1,       -1, G_STRING  ,   /* Object 27  */
  NONE, DRAW3D|STATE15, (LONG)"Modus:",
  0x0001, 0x000B, 0x0006, 0x0001,
        29,       -1,       -1, G_STRING  ,   /* Object 28 DIDATMOD */
  NONE, DRAW3D|STATE15, (LONG)"Multi-Tasking",
  0x000C, 0x000B, 0x000D, 0x0001,
  DIRDWR  ,       -1,       -1, G_STRING  ,   /* Object 29  */
  NONE, DRAW3D|STATE15, (LONG)"R/W:",
  0x0001, 0x000C, 0x0004, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 30 DIRDWR */
  NONE, DRAW3D|STATE15, (LONG)"Lesen+Schreiben",
  0x000C, 0x000C, 0x000F, 0x0001,
  DIOK    ,       32, DIINDFLU, G_BUTTON  ,   /* Object 31  */
  NONE, STATE14, (LONG)"Indexdatei",
  0x001F, 0x0008, 0x001C, 0x0009,
  DIINDSIZ,       -1,       -1, G_STRING  ,   /* Object 32  */
  NONE, DRAW3D|STATE15, (LONG)"Gr\224\236e:",
  0x0001, 0x0002, 0x0006, 0x0001,
        34,       -1,       -1, G_STRING  ,   /* Object 33 DIINDSIZ */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"99999 KB",
  0x000C, 0x0002, 0x0008, 0x0001,
  DIINDUSE,       -1,       -1, G_STRING  ,   /* Object 34  */
  NONE, DRAW3D|STATE15, (LONG)"Belegt:",
  0x0001, 0x0003, 0x0007, 0x0001,
  DIINDUSP,       -1,       -1, G_STRING  ,   /* Object 35 DIINDUSE */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"99999 KB",
  0x000C, 0x0003, 0x0008, 0x0001,
        37,       -1,       -1, G_STRING  ,   /* Object 36 DIINDUSP */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"(100%)",
  0x0015, 0x0003, 0x0006, 0x0001,
  DIINDFRE,       -1,       -1, G_STRING  ,   /* Object 37  */
  NONE, DRAW3D|STATE15, (LONG)"Frei:",
  0x0001, 0x0004, 0x0005, 0x0001,
  DIINDFRP,       -1,       -1, G_STRING  ,   /* Object 38 DIINDFRE */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"99999 KB",
  0x000C, 0x0004, 0x0008, 0x0001,
        40,       -1,       -1, G_STRING  ,   /* Object 39 DIINDFRP */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"(100%)",
  0x0015, 0x0004, 0x0006, 0x0001,
  DIINDCAC,       -1,       -1, G_STRING  ,   /* Object 40  */
  NONE, DRAW3D|STATE15, (LONG)"Cache:",
  0x0001, 0x0006, 0x0006, 0x0001,
        42,       -1,       -1, G_STRING  ,   /* Object 41 DIINDCAC */
  NONE, DRAW3D|STATE15, (LONG)"99999 KB",
  0x000C, 0x0006, 0x0008, 0x0001,
  DIINDHIT,       -1,       -1, G_STRING  ,   /* Object 42  */
  NONE, DRAW3D|STATE15, (LONG)"Treffer:",
  0x0001, 0x0007, 0x0008, 0x0001,
        44,       -1,       -1, G_STRING  ,   /* Object 43 DIINDHIT */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"100%",
  0x000C, 0x0007, 0x0004, 0x0001,
  DIINDFLU,       -1,       -1, G_STRING  ,   /* Object 44  */
  NONE, DRAW3D|STATE15, (LONG)"Autoflush:",
  0x0001, 0x0008, 0x000A, 0x0001,
        31,       -1,       -1, G_STRING  ,   /* Object 45 DIINDFLU */
  NONE, DRAW3D|STATE15, (LONG)"nein",
  0x000C, 0x0008, 0x0004, 0x0001,
  DIHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 46 DIOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0022, 0x0013, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 47 DIHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x002F, 0x0013, 0x000A, 0x0002,
  
  /******** Tree 19 NEWTABLE ****************************************************/
        -1,        1, NTHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0046, 0x0011,
  NTDBNAME,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datenbank:",
  0x0002, 0x0001, 0x000A, 0x0001,
  NTNAME  ,       -1,       -1, G_STRING  ,   /* Object 2 NTDBNAME */
  NONE, STATE12|STATE15, (LONG)"________________________________________",
  0x000D, 0x0001, 0x0028, 0x0001,
  NTTABLE ,       -1,       -1, G_STRING  ,   /* Object 3 NTNAME */
  NONE, STATE15, (LONG)"~Tabelle:",
  0x0002, 0x0003, 0x0009, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 4 NTTABLE */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[43],
  0x000D, 0x0003, 0x0023, 0x0001,
  NTCOLOR ,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"Farbe:",
  0x0002, 0x0005, 0x0006, 0x0001,
         7,       -1,       -1, G_BUTTON  ,   /* Object 6 NTCOLOR */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"\0",
  0x000D, 0x0005, 0x0010, 0x0001,
  NTMTON  ,        8, NTILOAD , G_BUTTON  ,   /* Object 7  */
  NONE, WHITEBAK|STATE14, (LONG)"Sinnbild",
  0x0002, 0x0007, 0x001E, 0x0009,
  NTINUM  ,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, STATE15, (LONG)"Nummer: ",
  0x0001, 0x0002, 0x0008, 0x0001,
  NTICNBOX,       -1,       -1, G_STRING  ,   /* Object 9 NTINUM */
  NONE, STATE12|STATE14|STATE15, (LONG)"999",
  0x0009, 0x0002, 0x0003, 0x0001,
  NTSB    ,       11,       11, G_IBOX    ,   /* Object 10 NTICNBOX */
  NONE, DRAW3D|WHITEBAK|STATE12, (LONG)0x00FF1141L,
  0x0012, 0x0002, 0x0009, 0x0007,
  NTICNBOX, NTICON  , NTICON  , G_BOX     ,   /* Object 11  */
  NONE, WHITEBAK, (LONG)0x00001141L,
  0x0000, 0x0000, 0x0009, 0x0007,
        11,       -1,       -1, G_ICON    ,   /* Object 12 NTICON */
  NONE, NORMAL, (LONG)&rs_iconblk[0],
  0x0000, 0x0001, 0x0009, 0x0802,
  NTILOAD ,       -1,       -1, G_BOX     ,   /* Object 13 NTSB */
  NONE, DRAW3D|WHITEBAK|STATE12, (LONG)0x00FF1111L,
  0x001B, 0x0002, 0x0002, 0x0007,
         7,       -1,       -1, G_BUTTON  ,   /* Object 14 NTILOAD */
  SELECTABLE, WHITEBAK, (LONG)"~Laden...",
  0x0001, 0x0006, 0x0009, 0x0002,
  NTHIDE  ,       -1,       -1, G_BUTTON  ,   /* Object 15 NTMTON */
  SELECTABLE|HIDETREE, DRAW3D|STATE13, (LONG)"~m:n Beziehung",
  0x001F, 0x0007, 0x000E, 0x0001,
  NTOK    ,       -1,       -1, G_BUTTON  ,   /* Object 16 NTHIDE */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Im Manager verstecken",
  0x0022, 0x0008, 0x0016, 0x0001,
  NTCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 17 NTOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0022, 0x000E, 0x000A, 0x0002,
  NTHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 18 NTCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x002E, 0x000E, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 19 NTHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x003A, 0x000E, 0x000A, 0x0002,
  
  /******** Tree 20 NEWFIELD ****************************************************/
        -1,        1, NFFORMAT, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0042, 0x0015,
  NFTABLE ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Tabelle:",
  0x0003, 0x0001, 0x0008, 0x0001,
  NFNAME  ,       -1,       -1, G_STRING  ,   /* Object 2 NFTABLE */
  NONE, NORMAL, (LONG)"_________________________________",
  0x000D, 0x0001, 0x0021, 0x0001,
  NFFIELD ,       -1,       -1, G_STRING  ,   /* Object 3 NFNAME */
  NONE, DRAW3D|STATE15, (LONG)"Feldname:",
  0x0003, 0x0003, 0x0009, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 4 NFFIELD */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[44],
  0x000D, 0x0003, 0x0023, 0x0001,
        21, NFDTEXT , NFDBLEN , G_BUTTON  ,   /* Object 5  */
  NONE, STATE14, (LONG)"Datentyp",
  0x0002, 0x0004, 0x001E, 0x000E,
  NFDTLEN ,       -1,       -1, G_BUTTON  ,   /* Object 6 NFDTEXT */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Text",
  0x0001, 0x0002, 0x0005, 0x0001,
  NFDWORD ,       -1,       -1, G_FBOXTEXT,   /* Object 7 NFDTLEN */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[45],
  0x0013, 0x0002, 0x0009, 0x0001,
  NFDLONG ,       -1,       -1, G_BUTTON  ,   /* Object 8 NFDWORD */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Zahl",
  0x0001, 0x0003, 0x0005, 0x0001,
  NFDFLOAT,       -1,       -1, G_BUTTON  ,   /* Object 9 NFDLONG */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Langzahl",
  0x0001, 0x0004, 0x0009, 0x0001,
  NFDDATE ,       -1,       -1, G_BUTTON  ,   /* Object 10 NFDFLOAT */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Flie\236ko~mma",
  0x0001, 0x0005, 0x000B, 0x0001,
  NFDTIME ,       -1,       -1, G_BUTTON  ,   /* Object 11 NFDDATE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Datum",
  0x0001, 0x0006, 0x0006, 0x0001,
  NFDTSTAM,       -1,       -1, G_BUTTON  ,   /* Object 12 NFDTIME */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Ze~it",
  0x0001, 0x0007, 0x0005, 0x0001,
  NFDEXTRN,       -1,       -1, G_BUTTON  ,   /* Object 13 NFDTSTAM */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Datum ~+ Zeit",
  0x0001, 0x0008, 0x000D, 0x0001,
  NFDPIC  ,       -1,       -1, G_BUTTON  ,   /* Object 14 NFDEXTRN */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Externe Datei",
  0x0001, 0x0009, 0x000E, 0x0001,
  NFDPLEN ,       -1,       -1, G_BUTTON  ,   /* Object 15 NFDPIC */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Grafik",
  0x0001, 0x000A, 0x0007, 0x0001,
  NFDDBADR,       -1,       -1, G_FBOXTEXT,   /* Object 16 NFDPLEN */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[46],
  0x0013, 0x000A, 0x0009, 0x0001,
  NFDBLOB ,       -1,       -1, G_BUTTON  ,   /* Object 17 NFDDBADR */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"DB-Adresse",
  0x0001, 0x000B, 0x000A, 0x0001,
  NFBTYPE ,       -1,       -1, G_BUTTON  ,   /* Object 18 NFDBLOB */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~BLOB",
  0x0001, 0x000C, 0x0005, 0x0001,
  NFDBLEN ,       -1,       -1, G_BUTTON  ,   /* Object 19 NFBTYPE */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"BYTE",
  0x0009, 0x000C, 0x0008, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 20 NFDBLEN */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[47],
  0x0013, 0x000C, 0x0009, 0x0001,
  NFOK    ,       22, NFAINDEX, G_BUTTON  ,   /* Object 21  */
  NONE, STATE14, (LONG)"Feldattribute",
  0x0022, 0x0004, 0x001E, 0x000E,
  NFAMANDA, NFANONE , NFAINDLE, G_BUTTON  ,   /* Object 22  */
  NONE, STATE14, (LONG)"Indexattribute",
  0x0001, 0x0007, 0x001C, 0x0006,
  NFAPRIMA,       -1,       -1, G_BUTTON  ,   /* Object 23 NFANONE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Keine",
  0x0001, 0x0002, 0x0006, 0x0001,
  NFAUNIQU,       -1,       -1, G_BUTTON  ,   /* Object 24 NFAPRIMA */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Prim\204rschl\201ssel",
  0x0001, 0x0003, 0x0010, 0x0001,
  NFAINDLT,       -1,       -1, G_BUTTON  ,   /* Object 25 NFAUNIQU */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Eindeutig",
  0x0001, 0x0004, 0x0009, 0x0001,
  NFAINDLE,       -1,       -1, G_STRING  ,   /* Object 26 NFAINDLT */
  NONE, DRAW3D|STATE15, (LONG)"Signifikante L\204nge:",
  0x0001, 0x0005, 0x0013, 0x0001,
        22,       -1,       -1, G_FBOXTEXT,   /* Object 27 NFAINDLE */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[48],
  0x0015, 0x0005, 0x0003, 0x0001,
  NFADEFAU,       -1,       -1, G_BUTTON  ,   /* Object 28 NFAMANDA */
  SELECTABLE, DRAW3D|STATE13, (LONG)"M~u\236feld",
  0x0001, 0x0002, 0x0008, 0x0001,
  NFAOUT  ,       -1,       -1, G_BUTTON  ,   /* Object 29 NFADEFAU */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Default~-Wert",
  0x0001, 0x0003, 0x000D, 0x0001,
  NFALOOKU,       -1,       -1, G_BUTTON  ,   /* Object 30 NFAOUT */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Au~sgabefeld",
  0x0001, 0x0004, 0x000C, 0x0001,
  NFAINDEX,       -1,       -1, G_BUTTON  ,   /* Object 31 NFALOOKU */
  SELECTABLE, DRAW3D|STATE13, (LONG)"In We~rtetabelle einf\201gen",
  0x0001, 0x0005, 0x0019, 0x0001,
        21,       -1,       -1, G_BUTTON  ,   /* Object 32 NFAINDEX */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Inde~x",
  0x0001, 0x0006, 0x0006, 0x0001,
  NFCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 33 NFOK */
  SELECTABLE|EXIT, DRAW3D|WHITEBAK, (LONG)"~OK",
  0x0002, 0x0013, 0x000A, 0x0002,
  NFHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 34 NFCANCEL */
  SELECTABLE|EXIT|FLAGS13, DRAW3D|WHITEBAK, (LONG)"~Abbruch",
  0x000E, 0x0013, 0x000A, 0x0002,
  NFNEXT  ,       -1,       -1, G_BUTTON  ,   /* Object 35 NFHELP */
  SELECTABLE|FLAGS14, DRAW3D|WHITEBAK, (LONG)"~Hilfe",
  0x001A, 0x0013, 0x000A, 0x0002,
  NFFORMAT,       -1,       -1, G_BUTTON  ,   /* Object 36 NFNEXT */
  SELECTABLE|DEFAULT|EXIT, DRAW3D|WHITEBAK, (LONG)"OK & ~Weiter",
  0x0027, 0x0013, 0x000C, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 37 NFFORMAT */
  SELECTABLE|LASTOB, DRAW3D|WHITEBAK, (LONG)"~Format...",
  0x0036, 0x0013, 0x000A, 0x0002,
  
  /******** Tree 21 NEWKEY ****************************************************/
        -1,        1, NKHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|DRAW3D|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0042, 0x0014,
  NKTABLE ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Tabelle:",
  0x0002, 0x0001, 0x0008, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 NKTABLE */
  NONE, STATE12|STATE15, (LONG)"_________________________________",
  0x000D, 0x0001, 0x0021, 0x0001,
  NKINDEX ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, DRAW3D|STATE15, (LONG)"~Indexname:",
  0x0002, 0x0003, 0x000B, 0x0001,
  NKFHEAD ,       -1,       -1, G_FBOXTEXT,   /* Object 4 NKINDEX */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[49],
  0x000D, 0x0003, 0x0023, 0x0001,
  NKMHEAD ,       -1,       -1, G_STRING  ,   /* Object 5 NKFHEAD */
  NONE, STATE15, (LONG)"Felder:",
  0x0003, 0x0004, 0x0007, 0x0001,
  NKFIELDS,       -1,       -1, G_STRING  ,   /* Object 6 NKMHEAD */
  NONE, NORMAL, (LONG)"Indizes:          L\204nge:",
  0x0027, 0x0004, 0x0018, 0x0001,
  NKCOPY  ,       -1,       -1, G_BOX     ,   /* Object 7 NKFIELDS */
  NONE, DRAW3D|STATE13, (LONG)0x00FF1101L,
  0x0003, 0x0006, 0x0016, 0x0006,
  NKKEYS  ,       -1,       -1, G_BUTTON  ,   /* Object 8 NKCOPY */
  SELECTABLE, DRAW3D|WHITEBAK, (LONG)">>>>>",
  0x001B, 0x0006, 0x000A, 0x0002,
  NKUPDATE,       -1,       -1, G_BOX     ,   /* Object 9 NKKEYS */
  NONE, DRAW3D|STATE13, (LONG)0x00FF1101L,
  0x0027, 0x0006, 0x0018, 0x0006,
  NKDELETE,       -1,       -1, G_BUTTON  ,   /* Object 10 NKUPDATE */
  SELECTABLE, DRAW3D|WHITEBAK, (LONG)"\216~ndern",
  0x001B, 0x0008, 0x000A, 0x0002,
        12,       -1,       -1, G_BUTTON  ,   /* Object 11 NKDELETE */
  SELECTABLE, DRAW3D|WHITEBAK, (LONG)"<<<<<",
  0x001B, 0x000A, 0x000A, 0x0002,
  NKINDLEN,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, STATE15, (LONG)"~Signifikante L\204nge:",
  0x0002, 0x000C, 0x0014, 0x0001,
        14,       -1,       -1, G_FBOXTEXT,   /* Object 13 NKINDLEN */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[50],
  0x0016, 0x000C, 0x0003, 0x0001,
  NKSIZE  ,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, STATE15, (LONG)"Gesamtl\204nge:",
  0x002A, 0x000C, 0x000C, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15 NKSIZE */
  NONE, STATE12|STATE14|STATE15, (LONG)"999",
  0x0038, 0x000C, 0x0003, 0x0001,
  NKOK    , NKNONE  , NKUNIQUE, G_BUTTON  ,   /* Object 16  */
  NONE, DRAW3D|STATE14, (LONG)"Indexattribute",
  0x0002, 0x000E, 0x001B, 0x0005,
  NKPRIMAR,       -1,       -1, G_BUTTON  ,   /* Object 17 NKNONE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Keine",
  0x0001, 0x0002, 0x0006, 0x0001,
  NKUNIQUE,       -1,       -1, G_BUTTON  ,   /* Object 18 NKPRIMAR */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Prim\204rschl\201ssel",
  0x0001, 0x0003, 0x0010, 0x0001,
        16,       -1,       -1, G_BUTTON  ,   /* Object 19 NKUNIQUE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Eindeutig",
  0x0001, 0x0004, 0x000A, 0x0001,
  NKCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 20 NKOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x001E, 0x0011, 0x000A, 0x0002,
  NKHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 21 NKCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x002A, 0x0011, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 22 NKHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0036, 0x0011, 0x000A, 0x0002,
  
  /******** Tree 22 DOICONS ****************************************************/
        -1,        1, DHELP   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x001E, 0x000F,
  DDBNAME ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datenbank:",
  0x0002, 0x0001, 0x000A, 0x0001,
  DLOAD   ,       -1,       -1, G_STRING  ,   /* Object 2 DDBNAME */
  NONE, STATE12|STATE15, (LONG)"_______________",
  0x000D, 0x0001, 0x000F, 0x0001,
  DICNBOX ,       -1,       -1, G_BUTTON  ,   /* Object 3 DLOAD */
  SELECTABLE, WHITEBAK, (LONG)"~Laden...",
  0x0002, 0x0003, 0x000F, 0x0002,
  DUPDATE , DINUMBOX, DICON   , G_BOX     ,   /* Object 4 DICNBOX */
  NONE, WHITEBAK, (LONG)0x00FF1141L,
  0x0013, 0x0003, 0x0009, 0x0008,
  DICON   , DDOWN   , DUP     , G_BOX     ,   /* Object 5 DINUMBOX */
  NONE, NORMAL, (LONG)0x00001140L,
  0x0000, 0x0000, 0x0009, 0x0001,
  DINUM   ,       -1,       -1, G_BOXCHAR ,   /* Object 6 DDOWN */
  NONE, NORMAL, (LONG) ((LONG)'\004' << 24)|0x00FF1100L,
  0x0000, 0x0000, 0x0003, 0x0001,
  DUP     ,       -1,       -1, G_BOXTEXT ,   /* Object 7 DINUM */
  NONE, NORMAL, (LONG)&rs_tedinfo[51],
  0x0003, 0x0000, 0x0003, 0x0001,
  DINUMBOX,       -1,       -1, G_BOXCHAR ,   /* Object 8 DUP */
  NONE, NORMAL, (LONG) ((LONG)'\003' << 24)|0x00FF1100L,
  0x0006, 0x0000, 0x0003, 0x0001,
  DICNBOX ,       -1,       -1, G_ICON    ,   /* Object 9 DICON */
  NONE, NORMAL, (LONG)&rs_iconblk[1],
  0x0000, 0x0002, 0x0009, 0x0802,
  DEXPORT ,       -1,       -1, G_BUTTON  ,   /* Object 10 DUPDATE */
  SELECTABLE, WHITEBAK, (LONG)"~Ersetzen...",
  0x0002, 0x0005, 0x000F, 0x0002,
  DDELETE ,       -1,       -1, G_BUTTON  ,   /* Object 11 DEXPORT */
  SELECTABLE, WHITEBAK, (LONG)"E~xportieren...",
  0x0002, 0x0007, 0x000F, 0x0002,
  DOK     ,       -1,       -1, G_BUTTON  ,   /* Object 12 DDELETE */
  SELECTABLE, WHITEBAK, (LONG)"L\224~schen",
  0x0002, 0x0009, 0x000F, 0x0002,
  DHELP   ,       -1,       -1, G_BUTTON  ,   /* Object 13 DOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0004, 0x000C, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 14 DHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0011, 0x000C, 0x000A, 0x0002,
  
  /******** Tree 23 FORMATS ****************************************************/
        -1,        1, FHELP   , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x003A, 0x0011,
  FNAME   ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Feld:",
  0x0006, 0x0001, 0x0005, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 FNAME */
  NONE, STATE12|STATE15, (LONG)"_________________________________",
  0x000E, 0x0001, 0x0021, 0x0001,
  FTYPE   ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, DRAW3D|STATE15, (LONG)"Typ:",
  0x0006, 0x0003, 0x0004, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4 FTYPE */
  NONE, DRAW3D|STATE12|STATE15, (LONG)"______",
  0x000E, 0x0003, 0x0006, 0x0001,
  FNEW    ,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"For~mat:",
  0x0006, 0x0004, 0x0008, 0x0001,
         7,       -1,       -1, G_FBOXTEXT,   /* Object 6 FNEW */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[52],
  0x000E, 0x0004, 0x0029, 0x0001,
  FLISTBOX,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, DRAW3D|STATE15, (LONG)"Formate:",
  0x000E, 0x0006, 0x0008, 0x0001,
  FUPDATE ,       -1,       -1, G_BOX     ,   /* Object 8 FLISTBOX */
  NONE, STATE13, (LONG)0x00FF1101L,
  0x000E, 0x0007, 0x002A, 0x0006,
  FDELETE ,       -1,       -1, G_BUTTON  ,   /* Object 9 FUPDATE */
  SELECTABLE|EXIT, WHITEBAK, (LONG)"\216~ndern",
  0x0002, 0x0008, 0x000A, 0x0002,
  FOK     ,       -1,       -1, G_BUTTON  ,   /* Object 10 FDELETE */
  SELECTABLE, WHITEBAK, (LONG)"~L\224schen",
  0x0002, 0x000A, 0x000A, 0x0002,
  FCANCEL ,       -1,       -1, G_BUTTON  ,   /* Object 11 FOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x000E, 0x000A, 0x0002,
  FHELP   ,       -1,       -1, G_BUTTON  ,   /* Object 12 FCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x000E, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 13 FHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001C, 0x000E, 0x000A, 0x0002,
  
  /******** Tree 24 SELMASK ****************************************************/
        -1,        1, SMHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0037, 0x0010,
  SMDBNAME,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datenbank:",
  0x0002, 0x0001, 0x000A, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 SMDBNAME */
  NONE, STATE12|STATE15, (LONG)"________________________________________",
  0x000D, 0x0001, 0x0028, 0x0001,
  SMNAME  ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"~Maske:",
  0x0002, 0x0003, 0x0007, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 4 SMNAME */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[53],
  0x000D, 0x0003, 0x0023, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, DRAW3D|STATE15, (LONG)"Masken:",
  0x0003, 0x0005, 0x0007, 0x0001,
  SMLIST  ,        7,       11, G_BOX     ,   /* Object 6  */
  HIDETREE, NORMAL, (LONG)0x00011100L,
  0x0026, 0x0005, 0x000F, 0x0004,
  SMSCREEN,       -1,       -1, G_BOXTEXT ,   /* Object 7  */
  NONE, DRAW3D, (LONG)&rs_tedinfo[54],
  0x0001, 0x0000, 0x000B, 0x0001,
         9,       -1,       -1, G_BOX     ,   /* Object 8 SMSCREEN */
  SELECTABLE|RBUTTON, CROSSED, (LONG)0x00011101L,
  0x0001, 0x0001, 0x0002, 0x0001,
  SMPRINTR,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)" Bildschirm",
  0x0003, 0x0001, 0x000B, 0x0001,
        11,       -1,       -1, G_BOX     ,   /* Object 10 SMPRINTR */
  SELECTABLE|RBUTTON, CROSSED, (LONG)0x00011101L,
  0x0001, 0x0002, 0x0002, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)" Drucker",
  0x0003, 0x0002, 0x0008, 0x0001,
  SMOPEN  ,       -1,       -1, G_BOX     ,   /* Object 12 SMLIST */
  NONE, STATE13, (LONG)0x00FF1101L,
  0x0003, 0x0006, 0x0031, 0x0006,
  SMDELETE,       -1,       -1, G_BUTTON  ,   /* Object 13 SMOPEN */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"\231~ffnen",
  0x0003, 0x000D, 0x000A, 0x0002,
  SMCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 14 SMDELETE */
  SELECTABLE, WHITEBAK, (LONG)"~L\224schen",
  0x0010, 0x000D, 0x000A, 0x0002,
  SMHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 15 SMCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Schlie\236en",
  0x001D, 0x000D, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 16 SMHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x002A, 0x000D, 0x000A, 0x0002,
  
  /******** Tree 25 MASKICON ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, STATE14, (LONG)0x00FF1140L,
  0x0000, 0x0000, 0x003B, 0x0003,
         0, MIARROW , MIPOINT , G_IBOX    ,   /* Object 1  */
  NONE, STATE10|STATE15, (LONG)0x00011100L,
  0x0000, 0x0000, 0x003B, 0x0003,
  MILINE  ,       -1,       -1, G_BUTTON  ,   /* Object 2 MIARROW */
  SELECTABLE|RBUTTON, STATE15, (LONG)"arrow",
  0x0001, 0x0001, 0x0005, 0x0002,
  MIBOX   ,       -1,       -1, G_BUTTON  ,   /* Object 3 MILINE */
  SELECTABLE|RBUTTON, STATE15, (LONG)"line",
  0x0005, 0x0001, 0x0004, 0x0002,
  MIRBOX  ,       -1,       -1, G_BUTTON  ,   /* Object 4 MIBOX */
  SELECTABLE|RBUTTON, STATE15, (LONG)"box",
  0x0009, 0x0001, 0x0004, 0x0002,
  MITEXT  ,       -1,       -1, G_BUTTON  ,   /* Object 5 MIRBOX */
  SELECTABLE|RBUTTON, STATE15, (LONG)"rbox",
  0x000D, 0x0001, 0x0004, 0x0002,
  MIGRAF  ,       -1,       -1, G_BUTTON  ,   /* Object 6 MITEXT */
  SELECTABLE|RBUTTON, STATE15, (LONG)"text",
  0x0011, 0x0001, 0x0004, 0x0002,
  MIBUTTON,       -1,       -1, G_BUTTON  ,   /* Object 7 MIGRAF */
  SELECTABLE|RBUTTON, STATE15, (LONG)"graf",
  0x0015, 0x0001, 0x0004, 0x0002,
  MIMASK  ,       -1,       -1, G_BUTTON  ,   /* Object 8 MIBUTTON */
  SELECTABLE|RBUTTON, STATE15, (LONG)"button",
  0x0019, 0x0001, 0x0006, 0x0002,
  MIFONT  ,       -1,       -1, G_BUTTON  ,   /* Object 9 MIMASK */
  SELECTABLE, DRAW3D|STATE15, (LONG)"mask",
  0x001D, 0x0001, 0x0004, 0x0002,
  MIFILL  ,       -1,       -1, G_BOXTEXT ,   /* Object 10 MIFONT */
  NONE, DRAW3D, (LONG)&rs_tedinfo[55],
  0x0022, 0x0001, 0x000A, 0x0001,
  MILINES ,       -1,       -1, G_IBOX    ,   /* Object 11 MIFILL */
  NONE, DRAW3D, (LONG)0x00FF1101L,
  0x002D, 0x0001, 0x0006, 0x0002,
  MIPOINT ,       -1,       -1, G_BOX     ,   /* Object 12 MILINES */
  NONE, DRAW3D, (LONG)0x00FF1101L,
  0x0034, 0x0001, 0x0006, 0x0002,
         1,       -1,       -1, G_BOXTEXT ,   /* Object 13 MIPOINT */
  LASTOB, DRAW3D, (LONG)&rs_tedinfo[56],
  0x0022, 0x0002, 0x000A, 0x0001,
  
  /******** Tree 26 DBPARAMS ****************************************************/
        -1,        1, BPHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0037, 0x000C,
  BPBASE  ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datenbank:",
  0x0002, 0x0001, 0x000A, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 BPBASE */
  NONE, STATE12|STATE15, (LONG)"________________________________________",
  0x000D, 0x0001, 0x0028, 0x0001,
         8,        4, BPDENCOD, G_BUTTON  ,   /* Object 3  */
  NONE, STATE14, (LONG)"Daten",
  0x0002, 0x0003, 0x0017, 0x0005,
  BPDSIZE ,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, DRAW3D|STATE15, (LONG)"~Dateigr\224\236e:",
  0x0001, 0x0002, 0x000C, 0x0001,
         6,       -1,       -1, G_FBOXTEXT,   /* Object 5 BPDSIZE */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[57],
  0x000D, 0x0002, 0x0006, 0x0001,
  BPDENCOD,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, DRAW3D|STATE15, (LONG)"KB",
  0x0014, 0x0002, 0x0002, 0x0001,
         3,       -1,       -1, G_BUTTON  ,   /* Object 7 BPDENCOD */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Verschl\201sseln",
  0x0001, 0x0004, 0x000E, 0x0001,
  BPOK    ,        9, BPTENCOD, G_BUTTON  ,   /* Object 8  */
  SELECTABLE, STATE14, (LONG)"Indizes",
  0x001A, 0x0003, 0x0018, 0x0005,
  BPTSIZE ,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, DRAW3D|STATE15, (LONG)"Datei~gr\224\236e:",
  0x0001, 0x0002, 0x000C, 0x0001,
        11,       -1,       -1, G_FBOXTEXT,   /* Object 10 BPTSIZE */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[58],
  0x000D, 0x0002, 0x0006, 0x0001,
  BPTENCOD,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, DRAW3D|STATE15, (LONG)"KB",
  0x0014, 0x0002, 0x0002, 0x0001,
         8,       -1,       -1, G_BUTTON  ,   /* Object 12 BPTENCOD */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Ver~schl\201sseln",
  0x0001, 0x0004, 0x000E, 0x0001,
  BPCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 13 BPOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x000A, 0x0009, 0x000A, 0x0002,
  BPHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 14 BPCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x0017, 0x0009, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 15 BPHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0024, 0x0009, 0x000A, 0x0002,
  
  /******** Tree 27 RELRULES ****************************************************/
        -1, RREF    , RDELETE , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0036, 0x0012,
         2,       -1,       -1, G_STRING  ,   /* Object 1 RREF */
  NONE, STATE12|STATE15, (LONG)"12345678901234567890123456789012345678901234567890",
  0x0002, 0x0001, 0x0032, 0x0001,
         7, RDNONE  , RDSETNUL, G_BUTTON  ,   /* Object 2  */
  NONE, STATE14, (LONG)"Regel f\201r \042L\224schen\042",
  0x0002, 0x0003, 0x0018, 0x0006,
  RDRESTRI,       -1,       -1, G_BUTTON  ,   /* Object 3 RDNONE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Keine Regel",
  0x0002, 0x0002, 0x000C, 0x0001,
  RDCASCAD,       -1,       -1, G_BUTTON  ,   /* Object 4 RDRESTRI */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Verboten",
  0x0002, 0x0003, 0x0009, 0x0001,
  RDSETNUL,       -1,       -1, G_BUTTON  ,   /* Object 5 RDCASCAD */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Ka~skadiert",
  0x0002, 0x0004, 0x000B, 0x0001,
         2,       -1,       -1, G_BUTTON  ,   /* Object 6 RDSETNUL */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Au~f \042NULL\042 setzen",
  0x0002, 0x0005, 0x0012, 0x0001,
        12, RUNONE  , RUSETNUL, G_BUTTON  ,   /* Object 7  */
  NONE, STATE14, (LONG)"Regel f\201r \042\216ndern\042",
  0x001C, 0x0003, 0x0018, 0x0006,
  RURESTRI,       -1,       -1, G_BUTTON  ,   /* Object 8 RUNONE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Keine ~Regel",
  0x0002, 0x0002, 0x000C, 0x0001,
  RUCASCAD,       -1,       -1, G_BUTTON  ,   /* Object 9 RURESTRI */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Ver~boten",
  0x0002, 0x0003, 0x0009, 0x0001,
  RUSETNUL,       -1,       -1, G_BUTTON  ,   /* Object 10 RUCASCAD */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Kaska~diert",
  0x0002, 0x0004, 0x000B, 0x0001,
         7,       -1,       -1, G_BUTTON  ,   /* Object 11 RUSETNUL */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Auf \042~NULL\042 setzen",
  0x0002, 0x0005, 0x0012, 0x0001,
        15, RINONE  , RIRESTRI, G_BUTTON  ,   /* Object 12  */
  NONE, STATE14, (LONG)"Regel f\201r \042Einf\201gen\042",
  0x0002, 0x000A, 0x0018, 0x0004,
  RIRESTRI,       -1,       -1, G_BUTTON  ,   /* Object 13 RINONE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"K~eine Regel",
  0x0002, 0x0002, 0x000C, 0x0001,
        12,       -1,       -1, G_BUTTON  ,   /* Object 14 RIRESTRI */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Verb~oten",
  0x0002, 0x0003, 0x0009, 0x0001,
  ROK     , R11     , R1N     , G_BUTTON  ,   /* Object 15  */
  NONE, STATE14, (LONG)"Beziehungstyp",
  0x001C, 0x000A, 0x0018, 0x0004,
  R1N     ,       -1,       -1, G_BUTTON  ,   /* Object 16 R11 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~1:1",
  0x0002, 0x0002, 0x0004, 0x0001,
        15,       -1,       -1, G_BUTTON  ,   /* Object 17 R1N */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"1~:n",
  0x0002, 0x0003, 0x0004, 0x0001,
  RCANCEL ,       -1,       -1, G_BUTTON  ,   /* Object 18 ROK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x000F, 0x000A, 0x0002,
  RHELP   ,       -1,       -1, G_BUTTON  ,   /* Object 19 RCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x000F, 0x000A, 0x0002,
  RDELETE ,       -1,       -1, G_BUTTON  ,   /* Object 20 RHELP */
  SELECTABLE|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001C, 0x000F, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 21 RDELETE */
  SELECTABLE|EXIT|LASTOB, WHITEBAK, (LONG)"~L\224schen",
  0x002A, 0x000F, 0x000A, 0x0002,
  
  /******** Tree 28 SELFIELD ****************************************************/
        -1,        1, SDVALUES, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x004A, 0x0013,
  SDTABLE ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"~Tabelle:",
  0x0002, 0x0001, 0x0009, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 SDTABLE */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[59],
  0x000B, 0x0001, 0x0023, 0x0001,
  SDFONTN ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"Schrift:",
  0x002F, 0x0001, 0x0008, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4 SDFONTN */
  NONE, STATE12|STATE15, (LONG)"1234567890123456",
  0x0038, 0x0001, 0x0010, 0x0001,
  SDFIELD ,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, DRAW3D|STATE15, (LONG)"~Feld:",
  0x0002, 0x0003, 0x0006, 0x0001,
         7,       -1,       -1, G_FBOXTEXT,   /* Object 6 SDFIELD */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[60],
  0x000B, 0x0003, 0x0023, 0x0001,
  SDPOINT ,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, DRAW3D|STATE15, (LONG)"Punkt:",
  0x002F, 0x0003, 0x0006, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8 SDPOINT */
  NONE, DRAW3D|STATE12|STATE15, (LONG)"999",
  0x0038, 0x0003, 0x0003, 0x0001,
  SDLABEL ,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, STATE15, (LONG)"~Label:",
  0x0002, 0x0004, 0x0007, 0x0001,
  SDREPLAC,       -1,       -1, G_FBOXTEXT,   /* Object 10 SDLABEL */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[61],
  0x000B, 0x0004, 0x0023, 0x0001,
  SDTRANS ,       -1,       -1, G_BUTTON  ,   /* Object 11 SDREPLAC */
  SELECTABLE|RBUTTON, STATE13, (LONG)"Dec~kend",
  0x002F, 0x0004, 0x0008, 0x0001,
        13,       -1,       -1, G_BUTTON  ,   /* Object 12 SDTRANS */
  SELECTABLE|RBUTTON, STATE13, (LONG)"Trans~parent",
  0x003A, 0x0004, 0x000C, 0x0001,
        21, SDSTDLBL, SDWHUNIT, G_BUTTON  ,   /* Object 13  */
  NONE, STATE14, (LONG)"Attribute",
  0x0002, 0x0006, 0x001E, 0x0009,
  SDHSLIDR,       -1,       -1, G_BUTTON  ,   /* Object 14 SDSTDLBL */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Sta~ndardlabel (Feldname)",
  0x0001, 0x0002, 0x0019, 0x0001,
  SDVSLIDR,       -1,       -1, G_BUTTON  ,   /* Object 15 SDHSLIDR */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Ho~rizontaler Schieber",
  0x0001, 0x0003, 0x0016, 0x0001,
  SDWORDWR,       -1,       -1, G_BUTTON  ,   /* Object 16 SDVSLIDR */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Vertikaler Schieber",
  0x0001, 0x0004, 0x0014, 0x0001,
  SDBOUNDS,       -1,       -1, G_BUTTON  ,   /* Object 17 SDWORDWR */
  SELECTABLE, DRAW3D|STATE13, (LONG)"A~utomatischer Wortumbruch",
  0x0001, 0x0005, 0x001A, 0x0001,
  SDNOCLEA,       -1,       -1, G_BUTTON  ,   /* Object 18 SDBOUNDS */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Grenzen benutzen",
  0x0001, 0x0006, 0x0011, 0x0001,
  SDWHUNIT,       -1,       -1, G_BUTTON  ,   /* Object 19 SDNOCLEA */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Bei~m Einf\201gen beibehalten",
  0x0001, 0x0007, 0x001A, 0x0001,
        13,       -1,       -1, G_BUTTON  ,   /* Object 20 SDWHUNIT */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Breite~/H\224he in Einheiten",
  0x0001, 0x0008, 0x0019, 0x0001,
  SDX     ,       -1,       -1, G_STRING  ,   /* Object 21  */
  NONE, STATE15, (LONG)"~X:",
  0x0021, 0x0006, 0x0003, 0x0001,
        23,       -1,       -1, G_FBOXTEXT,   /* Object 22 SDX */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[62],
  0x0024, 0x0006, 0x0005, 0x0001,
        24,       -1,       -1, G_STRING  ,   /* Object 23  */
  NONE, STATE15, (LONG)"Einheiten",
  0x002A, 0x0006, 0x0009, 0x0001,
  SDW     ,       -1,       -1, G_STRING  ,   /* Object 24  */
  NONE, STATE15, (LONG)"~Breite:",
  0x0037, 0x0006, 0x0008, 0x0001,
        26,       -1,       -1, G_FBOXTEXT,   /* Object 25 SDW */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[63],
  0x003F, 0x0006, 0x0005, 0x0001,
  SDY     ,       -1,       -1, G_STRING  ,   /* Object 26  */
  NONE, STATE15, (LONG)"~Y:",
  0x0021, 0x0008, 0x0003, 0x0001,
        28,       -1,       -1, G_FBOXTEXT,   /* Object 27 SDY */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[64],
  0x0024, 0x0008, 0x0005, 0x0001,
        29,       -1,       -1, G_STRING  ,   /* Object 28  */
  NONE, STATE15, (LONG)"Einheiten",
  0x002A, 0x0008, 0x0009, 0x0001,
  SDH     ,       -1,       -1, G_STRING  ,   /* Object 29  */
  NONE, STATE15, (LONG)"H\224h~e:",
  0x0037, 0x0008, 0x0006, 0x0001,
        31,       -1,       -1, G_FBOXTEXT,   /* Object 30 SDH */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[65],
  0x003F, 0x0008, 0x0005, 0x0001,
  SDTYPE  ,       -1,       -1, G_STRING  ,   /* Object 31  */
  NONE, STATE15, (LONG)"~Darstellung:",
  0x0021, 0x000A, 0x000D, 0x0001,
        33,       -1,       -1, G_BUTTON  ,   /* Object 32 SDTYPE */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"1234567890123456789012",
  0x002E, 0x000A, 0x0016, 0x0001,
  SDLOWER ,       -1,       -1, G_STRING  ,   /* Object 33  */
  NONE, STATE15, (LONG)"~Untergrenze:",
  0x0021, 0x000C, 0x000D, 0x0001,
        35,       -1,       -1, G_FBOXTEXT,   /* Object 34 SDLOWER */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[66],
  0x002E, 0x000C, 0x000C, 0x0001,
  SDUPPER ,       -1,       -1, G_STRING  ,   /* Object 35  */
  NONE, STATE15, (LONG)"Obergren~ze:",
  0x0021, 0x000E, 0x000C, 0x0001,
  SDOK    ,       -1,       -1, G_FBOXTEXT,   /* Object 36 SDUPPER */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[67],
  0x002E, 0x000E, 0x000C, 0x0001,
  SDCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 37 SDOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x0010, 0x000A, 0x0002,
  SDHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 38 SDCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x0010, 0x000A, 0x0002,
  SDFONT  ,       -1,       -1, G_BUTTON  ,   /* Object 39 SDHELP */
  SELECTABLE|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001C, 0x0010, 0x000A, 0x0002,
  SDVALUES,       -1,       -1, G_BUTTON  ,   /* Object 40 SDFONT */
  SELECTABLE, WHITEBAK, (LONG)"~Schrift...",
  0x002F, 0x0010, 0x000B, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 41 SDVALUES */
  SELECTABLE|LASTOB, WHITEBAK, (LONG)"~Werte...",
  0x003D, 0x0010, 0x000B, 0x0002,
  
  /******** Tree 29 SELFILL ****************************************************/
        -1, SITNAME , SIHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0030, 0x0012,
         2,       -1,       -1, G_STRING  ,   /* Object 1 SITNAME */
  NONE, DRAW3D|STATE15, (LONG)"Mustertabelle:",
  0x001C, 0x0001, 0x000E, 0x0001,
  SICOLOR ,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, STATE15, (LONG)"~Farbe:",
  0x0002, 0x0002, 0x0007, 0x0001,
  SIPATTER,       -1,       -1, G_BUTTON  ,   /* Object 3 SICOLOR */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"\0",
  0x000A, 0x0002, 0x0010, 0x0001,
  SISELECT,       -1,       -1, G_BOX     ,   /* Object 4 SIPATTER */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x001C, 0x0002, 0x0012, 0x000C,
         6,       -1,       -1, G_BOX     ,   /* Object 5 SISELECT */
  NONE, NORMAL, (LONG)0x00011101L,
  0x000C, 0x0005, 0x000E, 0x0003,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, STATE15, (LONG)"Ergebnis:",
  0x0002, 0x0006, 0x0009, 0x0001,
  SIOK    , SIHOLLOW, SITABLE , G_BUTTON  ,   /* Object 7  */
  NONE, STATE14, (LONG)" Muster ",
  0x0002, 0x0009, 0x0018, 0x0005,
  SIWHITE ,       -1,       -1, G_BUTTON  ,   /* Object 8 SIHOLLOW */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Glas",
  0x0001, 0x0002, 0x0005, 0x0001,
  SITABLE ,       -1,       -1, G_BUTTON  ,   /* Object 9 SIWHITE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Wei\236",
  0x0001, 0x0003, 0x0005, 0x0001,
         7,       -1,       -1, G_BUTTON  ,   /* Object 10 SITABLE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Aus ~Mustertabelle",
  0x0001, 0x0004, 0x0012, 0x0001,
  SICANCEL,       -1,       -1, G_BUTTON  ,   /* Object 11 SIOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0006, 0x000F, 0x000A, 0x0002,
  SIHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 12 SICANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x0013, 0x000F, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 13 SIHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0020, 0x000F, 0x000A, 0x0002,
  
  /******** Tree 30 SELLINE ****************************************************/
        -1,        1, SLHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x003F, 0x000F,
         8, SLBS1   ,        7, G_BUTTON  ,   /* Object 1  */
  NONE, STATE14, (LONG)"Anfang",
  0x0002, 0x0001, 0x000E, 0x0007,
         3,       -1,       -1, G_BUTTON  ,   /* Object 2 SLBS1 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0001, 0x0002, 0x0002, 0x0001,
  SLBS2   ,       -1,       -1, G_IBOX    ,   /* Object 3  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0005, 0x0002, 0x0008, 0x0001,
         5,       -1,       -1, G_BUTTON  ,   /* Object 4 SLBS2 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0001, 0x0004, 0x0002, 0x0001,
  SLBS3   ,       -1,       -1, G_IBOX    ,   /* Object 5  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0005, 0x0004, 0x0008, 0x0001,
         7,       -1,       -1, G_BUTTON  ,   /* Object 6 SLBS3 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0001, 0x0006, 0x0002, 0x0001,
         1,       -1,       -1, G_IBOX    ,   /* Object 7  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0005, 0x0006, 0x0008, 0x0001,
        15, SLES1   ,       14, G_BUTTON  ,   /* Object 8  */
  NONE, STATE14, (LONG)"Ende",
  0x0011, 0x0001, 0x000E, 0x0007,
        10,       -1,       -1, G_BUTTON  ,   /* Object 9 SLES1 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0001, 0x0002, 0x0002, 0x0001,
  SLES2   ,       -1,       -1, G_IBOX    ,   /* Object 10  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0005, 0x0002, 0x0008, 0x0001,
        12,       -1,       -1, G_BUTTON  ,   /* Object 11 SLES2 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0001, 0x0004, 0x0002, 0x0001,
  SLES3   ,       -1,       -1, G_IBOX    ,   /* Object 12  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0005, 0x0004, 0x0008, 0x0001,
        14,       -1,       -1, G_BUTTON  ,   /* Object 13 SLES3 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0001, 0x0006, 0x0002, 0x0001,
         8,       -1,       -1, G_IBOX    ,   /* Object 14  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0005, 0x0006, 0x0008, 0x0001,
        28, SLT1    ,       27, G_BUTTON  ,   /* Object 15  */
  NONE, STATE14, (LONG)"Typ",
  0x0020, 0x0001, 0x001D, 0x0007,
        17,       -1,       -1, G_BUTTON  ,   /* Object 16 SLT1 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0001, 0x0002, 0x0002, 0x0001,
  SLT2    ,       -1,       -1, G_IBOX    ,   /* Object 17  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0005, 0x0002, 0x0008, 0x0001,
        19,       -1,       -1, G_BUTTON  ,   /* Object 18 SLT2 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0010, 0x0002, 0x0002, 0x0001,
  SLT3    ,       -1,       -1, G_IBOX    ,   /* Object 19  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0014, 0x0002, 0x0008, 0x0001,
        21,       -1,       -1, G_BUTTON  ,   /* Object 20 SLT3 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0001, 0x0004, 0x0002, 0x0001,
  SLT4    ,       -1,       -1, G_IBOX    ,   /* Object 21  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0005, 0x0004, 0x0008, 0x0001,
        23,       -1,       -1, G_BUTTON  ,   /* Object 22 SLT4 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0010, 0x0004, 0x0002, 0x0001,
  SLT5    ,       -1,       -1, G_IBOX    ,   /* Object 23  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0014, 0x0004, 0x0008, 0x0001,
        25,       -1,       -1, G_BUTTON  ,   /* Object 24 SLT5 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0001, 0x0006, 0x0002, 0x0001,
  SLT6    ,       -1,       -1, G_IBOX    ,   /* Object 25  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0005, 0x0006, 0x0008, 0x0001,
        27,       -1,       -1, G_BUTTON  ,   /* Object 26 SLT6 */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"\0",
  0x0010, 0x0006, 0x0002, 0x0001,
        15,       -1,       -1, G_IBOX    ,   /* Object 27  */
  NONE, DRAW3D, (LONG)0x00011100L,
  0x0014, 0x0006, 0x0008, 0x0001,
  SLWIDTH ,       -1,       -1, G_STRING  ,   /* Object 28  */
  NONE, DRAW3D|STATE15, (LONG)"~Dicke:",
  0x0002, 0x0009, 0x0007, 0x0001,
  SLSELECT,       -1,       -1, G_FBOXTEXT,   /* Object 29 SLWIDTH */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[68],
  0x0009, 0x0009, 0x0003, 0x0001,
        31,       -1,       -1, G_BOX     ,   /* Object 30 SLSELECT */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0020, 0x0009, 0x001D, 0x0002,
  SLOK    ,       -1,       -1, G_STRING  ,   /* Object 31  */
  NONE, DRAW3D|STATE15, (LONG)"Ergebnis:",
  0x0016, 0x000A, 0x0009, 0x0001,
  SLCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 32 SLOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x000D, 0x000C, 0x000A, 0x0002,
  SLHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 33 SLCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x001B, 0x000C, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 34 SLHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0028, 0x000C, 0x000A, 0x0002,
  
  /******** Tree 31 SELGRID ****************************************************/
        -1,        1, MGHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x002A, 0x0009,
  MGRIDX  ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"~X-Richtung:",
  0x0004, 0x0001, 0x000C, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 MGRIDX */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[69],
  0x0010, 0x0001, 0x0003, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"1/8 Zeichenbreite",
  0x0014, 0x0001, 0x0011, 0x0001,
  MGRIDY  ,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, STATE15, (LONG)"~Y-Richtung:",
  0x0004, 0x0003, 0x000C, 0x0001,
         6,       -1,       -1, G_FBOXTEXT,   /* Object 5 MGRIDY */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[70],
  0x0010, 0x0003, 0x0003, 0x0001,
  MGOK    ,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, STATE15, (LONG)"1/8 Zeichenh\224he",
  0x0014, 0x0003, 0x000F, 0x0001,
  MGCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 7 MGOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0003, 0x0006, 0x000A, 0x0002,
  MGHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 8 MGCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x0010, 0x0006, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 9 MGHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001D, 0x0006, 0x000A, 0x0002,
  
  /******** Tree 32 SELSIZE ****************************************************/
        -1,        1, MSHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0028, 0x0009,
  MSIZEX  ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"~X-Richtung:",
  0x0003, 0x0001, 0x000C, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 MSIZEX */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[71],
  0x000F, 0x0001, 0x0005, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"Zeichen",
  0x0015, 0x0001, 0x0007, 0x0001,
  MSIZEY  ,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, STATE15, (LONG)"~Y-Richtung:",
  0x0003, 0x0003, 0x000C, 0x0001,
         6,       -1,       -1, G_FBOXTEXT,   /* Object 5 MSIZEY */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[72],
  0x000F, 0x0003, 0x0005, 0x0001,
  MSOK    ,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, STATE15, (LONG)"Zeichen",
  0x0015, 0x0003, 0x0007, 0x0001,
  MSCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 7 MSOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x0006, 0x000A, 0x0002,
  MSHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 8 MSCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x0006, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 9 MSHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001C, 0x0006, 0x000A, 0x0002,
  
  /******** Tree 33 SELTEXT ****************************************************/
        -1,        1, STFONT  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0048, 0x000E,
  STTEXT  ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"~Text:",
  0x0002, 0x0001, 0x0006, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 STTEXT */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[73],
  0x0008, 0x0001, 0x003E, 0x0001,
  STFONTN ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"Schrift:",
  0x0002, 0x0003, 0x0008, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4 STFONTN */
  NONE, STATE12|STATE15, (LONG)"1234567890123456",
  0x000B, 0x0003, 0x0010, 0x0001,
        11, STTHICK , STOUTLIN, G_BUTTON  ,   /* Object 5  */
  NONE, STATE14, (LONG)"Effekte",
  0x001E, 0x0003, 0x0012, 0x0007,
  STLIGHT ,       -1,       -1, G_BUTTON  ,   /* Object 6 STTHICK */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Fett",
  0x0001, 0x0002, 0x0005, 0x0001,
  STSKEWED,       -1,       -1, G_BUTTON  ,   /* Object 7 STLIGHT */
  SELECTABLE, DRAW3D|STATE13, (LONG)"He~ll",
  0x0001, 0x0003, 0x0005, 0x0001,
  STUNDERL,       -1,       -1, G_BUTTON  ,   /* Object 8 STSKEWED */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Kursiv",
  0x0001, 0x0004, 0x0007, 0x0001,
  STOUTLIN,       -1,       -1, G_BUTTON  ,   /* Object 9 STUNDERL */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Unterstrichen",
  0x0001, 0x0005, 0x000E, 0x0001,
         5,       -1,       -1, G_BUTTON  ,   /* Object 10 STOUTLIN */
  SELECTABLE, DRAW3D|STATE13, (LONG)"Um~rahmt",
  0x0001, 0x0006, 0x0008, 0x0001,
        14, STREPLAC, STTRANS , G_BUTTON  ,   /* Object 11  */
  NONE, STATE14, (LONG)"Modus",
  0x0032, 0x0003, 0x0011, 0x0004,
  STTRANS ,       -1,       -1, G_BUTTON  ,   /* Object 12 STREPLAC */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Deckend",
  0x0001, 0x0002, 0x0008, 0x0001,
        11,       -1,       -1, G_BUTTON  ,   /* Object 13 STTRANS */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Trans~parent",
  0x0001, 0x0003, 0x000C, 0x0001,
  STPOINT ,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, STATE15, (LONG)"Punkt:",
  0x0002, 0x0005, 0x0006, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15 STPOINT */
  NONE, STATE12|STATE15, (LONG)"999",
  0x000B, 0x0005, 0x0003, 0x0001,
  STXPOS  ,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, STATE15, (LONG)"~X:",
  0x0002, 0x0007, 0x0003, 0x0001,
        18,       -1,       -1, G_FBOXTEXT,   /* Object 17 STXPOS */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[74],
  0x0005, 0x0007, 0x0005, 0x0001,
        19,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, STATE15, (LONG)"Einheiten",
  0x000B, 0x0007, 0x0009, 0x0001,
  STYPOS  ,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, STATE15, (LONG)"~Y:",
  0x0002, 0x0009, 0x0003, 0x0001,
        21,       -1,       -1, G_FBOXTEXT,   /* Object 20 STYPOS */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[75],
  0x0005, 0x0009, 0x0005, 0x0001,
  STOK    ,       -1,       -1, G_STRING  ,   /* Object 21  */
  NONE, STATE15, (LONG)"Einheiten",
  0x000B, 0x0009, 0x0009, 0x0001,
  STCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 22 STOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x000B, 0x000A, 0x0002,
  STHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 23 STCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x000B, 0x000A, 0x0002,
  STFONT  ,       -1,       -1, G_BUTTON  ,   /* Object 24 STHELP */
  SELECTABLE|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001C, 0x000B, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 25 STFONT */
  SELECTABLE|LASTOB, WHITEBAK, (LONG)"~Schrift...",
  0x003A, 0x000B, 0x000C, 0x0002,
  
  /******** Tree 34 OBJSIZE ****************************************************/
        -1,        1, OSHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0028, 0x0009,
  OSX     ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"~X:",
  0x0002, 0x0001, 0x0003, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 OSX */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[76],
  0x000A, 0x0001, 0x0005, 0x0001,
  OSY     ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"~Y:",
  0x0011, 0x0001, 0x0003, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 4 OSY */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[77],
  0x0017, 0x0001, 0x0005, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"Einheiten",
  0x001D, 0x0001, 0x0009, 0x0001,
  OSW     ,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, STATE15, (LONG)"~Breite:",
  0x0002, 0x0003, 0x0008, 0x0001,
         8,       -1,       -1, G_FBOXTEXT,   /* Object 7 OSW */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[78],
  0x000A, 0x0003, 0x0005, 0x0001,
  OSH     ,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, STATE15, (LONG)"H\224h~e:",
  0x0011, 0x0003, 0x0006, 0x0001,
        10,       -1,       -1, G_FBOXTEXT,   /* Object 9 OSH */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[79],
  0x0017, 0x0003, 0x0005, 0x0001,
  OSOK    ,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, STATE15, (LONG)"Einheiten",
  0x001D, 0x0003, 0x0009, 0x0001,
  OSCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 11 OSOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x0006, 0x000A, 0x0002,
  OSHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 12 OSCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x0006, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 13 OSHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001C, 0x0006, 0x000A, 0x0002,
  
  /******** Tree 35 PICSIZE ****************************************************/
        -1,        1, PSHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0035, 0x000C,
  PSFNAME ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datei:",
  0x0002, 0x0001, 0x0006, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 PSFNAME */
  NONE, STATE12|STATE15, (LONG)"________________________________________",
  0x000A, 0x0001, 0x0028, 0x0001,
  PSX     ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"~X:",
  0x0002, 0x0003, 0x0003, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 4 PSX */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[80],
  0x000A, 0x0003, 0x0005, 0x0001,
  PSY     ,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"~Y:",
  0x0011, 0x0003, 0x0003, 0x0001,
         7,       -1,       -1, G_FBOXTEXT,   /* Object 6 PSY */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[81],
  0x0017, 0x0003, 0x0005, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, STATE15, (LONG)"Einheiten",
  0x001D, 0x0003, 0x0009, 0x0001,
  PSW     ,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, STATE15, (LONG)"~Breite:",
  0x0002, 0x0005, 0x0008, 0x0001,
        10,       -1,       -1, G_FBOXTEXT,   /* Object 9 PSW */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[82],
  0x000A, 0x0005, 0x0005, 0x0001,
  PSH     ,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, STATE15, (LONG)"H\224h~e:",
  0x0011, 0x0005, 0x0006, 0x0001,
        12,       -1,       -1, G_FBOXTEXT,   /* Object 11 PSH */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[83],
  0x0017, 0x0005, 0x0005, 0x0001,
  PSFRAME ,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, STATE15, (LONG)"Einheiten",
  0x001D, 0x0005, 0x0009, 0x0001,
  PSOK    ,       -1,       -1, G_BUTTON  ,   /* Object 13 PSFRAME */
  SELECTABLE, SELECTED|STATE13, (LONG)"Bildrahmen ~zeichnen",
  0x0002, 0x0007, 0x0014, 0x0001,
  PSCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 14 PSOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x0009, 0x000A, 0x0002,
  PSEDIT  ,       -1,       -1, G_BUTTON  ,   /* Object 15 PSCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x0009, 0x000A, 0x0002,
  PSHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 16 PSEDIT */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Edit",
  0x001C, 0x0009, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 17 PSHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0029, 0x0009, 0x000A, 0x0002,
  
  /******** Tree 36 LINESIZE ****************************************************/
        -1,        1, LSHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0028, 0x0009,
  LSX1    ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"X~1:",
  0x0002, 0x0001, 0x0004, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 LSX1 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[84],
  0x0006, 0x0001, 0x0005, 0x0001,
  LSY1    ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"Y~1:",
  0x000D, 0x0001, 0x0004, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 4 LSY1 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[85],
  0x0011, 0x0001, 0x0005, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"Einheiten",
  0x0017, 0x0001, 0x0009, 0x0001,
  LSX2    ,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, STATE15, (LONG)"X~2:",
  0x0002, 0x0003, 0x0004, 0x0001,
         8,       -1,       -1, G_FBOXTEXT,   /* Object 7 LSX2 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[86],
  0x0006, 0x0003, 0x0005, 0x0001,
  LSY2    ,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, STATE15, (LONG)"Y~2:",
  0x000D, 0x0003, 0x0004, 0x0001,
        10,       -1,       -1, G_FBOXTEXT,   /* Object 9 LSY2 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[87],
  0x0011, 0x0003, 0x0005, 0x0001,
  LSOK    ,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, STATE15, (LONG)"Einheiten",
  0x0017, 0x0003, 0x0009, 0x0001,
  LSCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 11 LSOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x0006, 0x000A, 0x0002,
  LSHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 12 LSCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x0006, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 13 LSHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001C, 0x0006, 0x000A, 0x0002,
  
  /******** Tree 37 RBVALUES ****************************************************/
        -1,        1, RVHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0042, 0x000B,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE11, (LONG)"Werte werden mit \047|\047 getrennt. Bsp.: Herr|Frau|Firma",
  0x0002, 0x0001, 0x0034, 0x0001,
  RVOK    , RVTEXT1 ,        6, G_BOX     ,   /* Object 2  */
  NONE, OUTLINED, (LONG)0x00003100L,
  0x0002, 0x0003, 0x003E, 0x0004,
         4,       -1,       -1, G_FTEXT   ,   /* Object 3 RVTEXT1 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[88],
  0x0001, 0x0000, 0x003C, 0x0001,
         5,       -1,       -1, G_FTEXT   ,   /* Object 4  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[89],
  0x0001, 0x0001, 0x003C, 0x0001,
         6,       -1,       -1, G_FTEXT   ,   /* Object 5  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[90],
  0x0001, 0x0002, 0x003C, 0x0001,
         2,       -1,       -1, G_FTEXT   ,   /* Object 6  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[91],
  0x0001, 0x0003, 0x003C, 0x0001,
  RVCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 7 RVOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x000F, 0x0008, 0x000A, 0x0002,
  RVHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 8 RVCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x001C, 0x0008, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 9 RVHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x0029, 0x0008, 0x000A, 0x0002,
  
  /******** Tree 38 CBVALUES ****************************************************/
        -1,        1, CVHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0040, 0x0008,
  CVSEL   ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"~Selektiert:",
  0x0002, 0x0001, 0x000C, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 CVSEL */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[92],
  0x0014, 0x0001, 0x002A, 0x0001,
  CVUNSEL ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"~Nicht Selektiert:",
  0x0002, 0x0003, 0x0012, 0x0001,
  CVOK    ,       -1,       -1, G_FBOXTEXT,   /* Object 4 CVUNSEL */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[93],
  0x0014, 0x0003, 0x002A, 0x0001,
  CVCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 5 CVOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0010, 0x0005, 0x000A, 0x0002,
  CVHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 6 CVCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x001D, 0x0005, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 7 CVHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x002A, 0x0005, 0x000A, 0x0002,
  
  /******** Tree 39 SELSUBM ****************************************************/
        -1,        1, SSFONT  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x004A, 0x0012,
  SSSOURCE,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"~Herkunftsmaske:",
  0x0002, 0x0001, 0x0010, 0x0001,
         3,       -1,       -1, G_BUTTON  ,   /* Object 2 SSSOURCE */
  SELECTABLE|TOUCHEXIT, STATE11, (LONG)"12345678901234567890123456789012",
  0x0014, 0x0001, 0x0020, 0x0001,
  SSMASTER,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"~Verkn\201pfen von:",
  0x0002, 0x0003, 0x0010, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 4 SSMASTER */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[94],
  0x0014, 0x0003, 0x0034, 0x0001,
  SSCHILD ,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"Verkn\201pfen ~nach:",
  0x0002, 0x0005, 0x0011, 0x0001,
         7,       -1,       -1, G_FBOXTEXT,   /* Object 6 SSCHILD */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[95],
  0x0014, 0x0005, 0x0034, 0x0001,
  SSFONTN ,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, STATE15, (LONG)"Schrift:",
  0x0002, 0x0007, 0x0008, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8 SSFONTN */
  NONE, STATE12|STATE15, (LONG)"1234567890123456",
  0x000B, 0x0007, 0x0010, 0x0001,
  SSPOINT ,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, STATE15, (LONG)"Punkt:",
  0x0002, 0x0009, 0x0006, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10 SSPOINT */
  NONE, STATE12|STATE15, (LONG)"999",
  0x000B, 0x0009, 0x0003, 0x0001,
  SSX     ,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, STATE15, (LONG)"~X:",
  0x0002, 0x000B, 0x0003, 0x0001,
        13,       -1,       -1, G_FBOXTEXT,   /* Object 12 SSX */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[96],
  0x000A, 0x000B, 0x0005, 0x0001,
  SSY     ,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, STATE15, (LONG)"~Y:",
  0x0011, 0x000B, 0x0003, 0x0001,
        15,       -1,       -1, G_FBOXTEXT,   /* Object 14 SSY */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[97],
  0x0017, 0x000B, 0x0005, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, STATE15, (LONG)"Einheiten",
  0x001D, 0x000B, 0x0009, 0x0001,
  SSW     ,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, STATE15, (LONG)"~Breite:",
  0x0002, 0x000D, 0x0008, 0x0001,
        18,       -1,       -1, G_FBOXTEXT,   /* Object 17 SSW */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[98],
  0x000A, 0x000D, 0x0005, 0x0001,
  SSH     ,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, STATE15, (LONG)"H\224h~e:",
  0x0011, 0x000D, 0x0006, 0x0001,
        20,       -1,       -1, G_FBOXTEXT,   /* Object 19 SSH */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[99],
  0x0017, 0x000D, 0x0005, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20  */
  NONE, STATE15, (LONG)"Einheiten",
  0x001D, 0x000D, 0x0009, 0x0001,
  SSOK    , SSTABLE , SSMASK  , G_BUTTON  ,   /* Object 21  */
  NONE, STATE14, (LONG)"Anzeigeart",
  0x0028, 0x000A, 0x000D, 0x0004,
  SSMASK  ,       -1,       -1, G_BUTTON  ,   /* Object 22 SSTABLE */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Tabelle",
  0x0001, 0x0002, 0x0008, 0x0001,
        21,       -1,       -1, G_BUTTON  ,   /* Object 23 SSMASK */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"~Maske",
  0x0001, 0x0003, 0x0006, 0x0001,
  SSCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 24 SSOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x000F, 0x000A, 0x0002,
  SSHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 25 SSCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x000F, 0x000A, 0x0002,
  SSFONT  ,       -1,       -1, G_BUTTON  ,   /* Object 26 SSHELP */
  SELECTABLE|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001C, 0x000F, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 27 SSFONT */
  SELECTABLE|LASTOB, WHITEBAK, (LONG)"~Schrift...",
  0x003B, 0x000F, 0x000C, 0x0002,
  
  /******** Tree 40 SELBUTTO ****************************************************/
        -1,        1, SBFONT  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0048, 0x0012,
  SBTEXT  ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"~Text:",
  0x0002, 0x0001, 0x0006, 0x0001,
         3,       -1,       -1, G_FBOXTEXT,   /* Object 2 SBTEXT */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[100],
  0x000D, 0x0001, 0x0036, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"~Parameter:",
  0x0002, 0x0003, 0x000B, 0x0001,
         9, SBPARAM1,        8, G_BOX     ,   /* Object 4  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000D, 0x0003, 0x0036, 0x0004,
         6,       -1,       -1, G_FTEXT   ,   /* Object 5 SBPARAM1 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[101],
  0x0001, 0x0000, 0x0034, 0x0001,
         7,       -1,       -1, G_FTEXT   ,   /* Object 6  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[102],
  0x0001, 0x0001, 0x0034, 0x0001,
         8,       -1,       -1, G_FTEXT   ,   /* Object 7  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[103],
  0x0001, 0x0002, 0x0034, 0x0001,
         4,       -1,       -1, G_FTEXT   ,   /* Object 8  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[104],
  0x0001, 0x0003, 0x0034, 0x0001,
        11, SBFUNC  , SBFUNC  , G_BUTTON  ,   /* Object 9  */
  NONE, WHITEBAK|STATE14, (LONG)" Funktion ",
  0x0002, 0x0008, 0x0020, 0x0004,
         9,       -1,       -1, G_BUTTON  ,   /* Object 10 SBFUNC */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"123456789012345678901234567890",
  0x0001, 0x0002, 0x001E, 0x0001,
  SBX     ,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, STATE15, (LONG)"~X:",
  0x0023, 0x0008, 0x0003, 0x0001,
        13,       -1,       -1, G_FBOXTEXT,   /* Object 12 SBX */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[105],
  0x002B, 0x0008, 0x0005, 0x0001,
  SBY     ,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, STATE15, (LONG)"~Y:",
  0x0031, 0x0008, 0x0003, 0x0001,
        15,       -1,       -1, G_FBOXTEXT,   /* Object 14 SBY */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[106],
  0x0037, 0x0008, 0x0005, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, STATE15, (LONG)"Einheiten",
  0x003D, 0x0008, 0x0009, 0x0001,
  SBW     ,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, DRAW3D|STATE15, (LONG)"~Breite:",
  0x0023, 0x000A, 0x0008, 0x0001,
        18,       -1,       -1, G_FBOXTEXT,   /* Object 17 SBW */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[107],
  0x002B, 0x000A, 0x0005, 0x0001,
  SBH     ,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, DRAW3D|STATE15, (LONG)"H\224h~e:",
  0x0031, 0x000A, 0x0006, 0x0001,
        20,       -1,       -1, G_FBOXTEXT,   /* Object 19 SBH */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[108],
  0x0037, 0x000A, 0x0005, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20  */
  NONE, DRAW3D|STATE15, (LONG)"Einheiten",
  0x003D, 0x000A, 0x0009, 0x0001,
        24, SBROUND , SBRECT  , G_BUTTON  ,   /* Object 21  */
  NONE, STATE14, (LONG)"Form",
  0x0002, 0x000C, 0x000F, 0x0004,
  SBRECT  ,       -1,       -1, G_BUTTON  ,   /* Object 22 SBROUND */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Ab~gerundet",
  0x0001, 0x0002, 0x000B, 0x0001,
        21,       -1,       -1, G_BUTTON  ,   /* Object 23 SBRECT */
  SELECTABLE|RBUTTON, DRAW3D|STATE13, (LONG)"Ec~kig",
  0x0001, 0x0003, 0x0006, 0x0001,
  SBFONTN ,       -1,       -1, G_STRING  ,   /* Object 24  */
  NONE, STATE15, (LONG)"Schrift:",
  0x0023, 0x000C, 0x0008, 0x0001,
  SBHIDDEN,       -1,       -1, G_STRING  ,   /* Object 25 SBFONTN */
  NONE, STATE12|STATE15, (LONG)"1234567890123456",
  0x002C, 0x000C, 0x0010, 0x0001,
        27,       -1,       -1, G_BUTTON  ,   /* Object 26 SBHIDDEN */
  SELECTABLE, DRAW3D|STATE13, (LONG)"~Versteckt",
  0x0013, 0x000D, 0x000A, 0x0001,
  SBPOINT ,       -1,       -1, G_STRING  ,   /* Object 27  */
  NONE, DRAW3D|STATE15, (LONG)"Punkt:",
  0x0023, 0x000E, 0x0006, 0x0001,
  SBOK    ,       -1,       -1, G_STRING  ,   /* Object 28 SBPOINT */
  NONE, DRAW3D|STATE12|STATE15, (LONG)"999",
  0x002C, 0x000E, 0x0003, 0x0001,
  SBCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 29 SBOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0013, 0x000F, 0x000A, 0x0002,
  SBHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 30 SBCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x0020, 0x000F, 0x000A, 0x0002,
  SBFONT  ,       -1,       -1, G_BUTTON  ,   /* Object 31 SBHELP */
  SELECTABLE|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x002D, 0x000F, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 32 SBFONT */
  SELECTABLE|LASTOB, WHITEBAK, (LONG)"~Schrift...",
  0x003A, 0x000F, 0x000C, 0x0002,
  
  /******** Tree 41 BACCESS ****************************************************/
        -1,        1, ACHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0045, 0x0015,
  ADBNAME ,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datenbank:",
  0x0002, 0x0001, 0x000A, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 ADBNAME */
  NONE, STATE12|STATE15, (LONG)"________________________________________",
  0x0010, 0x0001, 0x0028, 0x0001,
  AUSER   ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"~Benutzername:",
  0x0002, 0x0003, 0x000E, 0x0001,
         5,       -1,       -1, G_FBOXTEXT,   /* Object 4 AUSER */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[109],
  0x0010, 0x0003, 0x0023, 0x0001,
        12, BAUSERS , AUINFO  , G_BUTTON  ,   /* Object 5  */
  NONE, STATE14, (LONG)"Benutzer",
  0x0002, 0x0005, 0x0015, 0x000C,
  AUREADON,       -1,       -1, G_BOX     ,   /* Object 6 BAUSERS */
  NONE, DRAW3D|STATE13, (LONG)0x00FF1101L,
  0x0001, 0x0002, 0x0013, 0x0004,
  AUINSERT,       -1,       -1, G_BUTTON  ,   /* Object 7 AUREADON */
  SELECTABLE, STATE13, (LONG)"~Nur Lesen",
  0x0001, 0x0006, 0x000A, 0x0001,
  AUDELETE,       -1,       -1, G_BUTTON  ,   /* Object 8 AUINSERT */
  SELECTABLE, DRAW3D|WHITEBAK, (LONG)"~Einf\201gen",
  0x0001, 0x0008, 0x0009, 0x0002,
  AUUPDATE,       -1,       -1, G_BUTTON  ,   /* Object 9 AUDELETE */
  SELECTABLE, DRAW3D|WHITEBAK, (LONG)"~L\224schen",
  0x000B, 0x0008, 0x0009, 0x0002,
  AUINFO  ,       -1,       -1, G_BUTTON  ,   /* Object 10 AUUPDATE */
  SELECTABLE, DRAW3D|WHITEBAK, (LONG)"\216~ndern",
  0x0001, 0x000A, 0x0009, 0x0002,
         5,       -1,       -1, G_BUTTON  ,   /* Object 11 AUINFO */
  SELECTABLE, DRAW3D|WHITEBAK, (LONG)"~Info...",
  0x000B, 0x000A, 0x0009, 0x0002,
        19, BATABLES, ATSYSTAB, G_BUTTON  ,   /* Object 12  */
  NONE, STATE14, (LONG)"Tabellen",
  0x0018, 0x0005, 0x0015, 0x000C,
  ATSELECT,       -1,       -1, G_BOX     ,   /* Object 13 BATABLES */
  NONE, DRAW3D|STATE13, (LONG)0x00FF1101L,
  0x0001, 0x0002, 0x0013, 0x0004,
  ATINSERT,       -1,       -1, G_BUTTON  ,   /* Object 14 ATSELECT */
  SELECTABLE, STATE13, (LONG)"Aus~gabe",
  0x0001, 0x0006, 0x0008, 0x0001,
  ATUPDATE,       -1,       -1, G_BUTTON  ,   /* Object 15 ATINSERT */
  SELECTABLE, STATE13, (LONG)"Ein~f\201gen",
  0x0001, 0x0007, 0x0009, 0x0001,
  ATDELETE,       -1,       -1, G_BUTTON  ,   /* Object 16 ATUPDATE */
  SELECTABLE, STATE13, (LONG)"\216n~dern",
  0x0001, 0x0008, 0x0007, 0x0001,
  ATSYSTAB,       -1,       -1, G_BUTTON  ,   /* Object 17 ATDELETE */
  SELECTABLE, STATE13, (LONG)"L\224s~chen",
  0x0001, 0x0009, 0x0008, 0x0001,
        12,       -1,       -1, G_BUTTON  ,   /* Object 18 ATSYSTAB */
  SELECTABLE, DRAW3D|STATE13, (LONG)"System~tabellen",
  0x0001, 0x000B, 0x000F, 0x0001,
  ACOK    , BAFIELDS, AFUPDATE, G_BUTTON  ,   /* Object 19  */
  NONE, STATE14, (LONG)"Felder",
  0x002E, 0x0005, 0x0015, 0x000C,
  AFNONE  ,       -1,       -1, G_BOX     ,   /* Object 20 BAFIELDS */
  NONE, DRAW3D|STATE13, (LONG)0x00FF1101L,
  0x0001, 0x0002, 0x0013, 0x0004,
  AFSELECT,       -1,       -1, G_BUTTON  ,   /* Object 21 AFNONE */
  SELECTABLE|RBUTTON, STATE13, (LONG)"~Keine Rechte",
  0x0001, 0x0006, 0x000D, 0x0001,
  AFINSERT,       -1,       -1, G_BUTTON  ,   /* Object 22 AFSELECT */
  SELECTABLE|RBUTTON, STATE13, (LONG)"N~ur Lesen",
  0x0001, 0x0007, 0x000A, 0x0001,
  AFUPDATE,       -1,       -1, G_BUTTON  ,   /* Object 23 AFINSERT */
  SELECTABLE|RBUTTON, STATE13, (LONG)"Lesen+~Schreiben",
  0x0001, 0x0008, 0x0010, 0x0001,
        19,       -1,       -1, G_BUTTON  ,   /* Object 24 AFUPDATE */
  SELECTABLE|RBUTTON, STATE13, (LONG)"\216nde~rn",
  0x0001, 0x0009, 0x0007, 0x0001,
  ACCANCEL,       -1,       -1, G_BUTTON  ,   /* Object 25 ACOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0010, 0x0012, 0x000A, 0x0002,
  ACHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 26 ACCANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x001D, 0x0012, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 27 ACHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x002A, 0x0012, 0x000A, 0x0002,
  
  /******** Tree 42 STDFORMA ****************************************************/
        -1,        1, STDSTRIN, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0036, 0x0017,
         2,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, NORMAL, (LONG)"Format string is 40 chars max!",
  0x000D, 0x0001, 0x001E, 0x0001,
  STDSTRIN,        3,       22, G_BOX     ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0001, 0x0002, 0x000B, 0x0014,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"TEXT",
  0x0000, 0x0000, 0x0004, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"WORD",
  0x0000, 0x0001, 0x0004, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"LONG",
  0x0000, 0x0002, 0x0004, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"FLOAT",
  0x0000, 0x0003, 0x0005, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"CHAR-FLOAT",
  0x0000, 0x0004, 0x000A, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"DATE",
  0x0000, 0x0005, 0x0004, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"TIME",
  0x0000, 0x0006, 0x0004, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"TIMESTAMP",
  0x0000, 0x0007, 0x0009, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"BLOB (BYTE)",
  0x0000, 0x0008, 0x000B, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"BLOB (WORD)",
  0x0000, 0x0009, 0x000B, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"BLOB (LONG)",
  0x0000, 0x000A, 0x000B, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"PICTURE",
  0x0000, 0x000B, 0x0007, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"EXTERN",
  0x0000, 0x000C, 0x0006, 0x0001,
        17,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, NORMAL, (LONG)"DBADDRESS",
  0x0000, 0x000D, 0x0009, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, NORMAL, (LONG)"BLOB (var.)",
  0x0000, 0x000E, 0x000B, 0x0001,
        19,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, NORMAL, (LONG)"RESERVED15",
  0x0000, 0x000F, 0x000A, 0x0001,
        20,       -1,       -1, G_STRING  ,   /* Object 19  */
  NONE, NORMAL, (LONG)"RESERVED16",
  0x0000, 0x0010, 0x000A, 0x0001,
        21,       -1,       -1, G_STRING  ,   /* Object 20  */
  NONE, NORMAL, (LONG)"RESERVED17",
  0x0000, 0x0011, 0x000A, 0x0001,
        22,       -1,       -1, G_STRING  ,   /* Object 21  */
  NONE, NORMAL, (LONG)"RESERVED18",
  0x0000, 0x0012, 0x000A, 0x0001,
         2,       -1,       -1, G_STRING  ,   /* Object 22  */
  NONE, NORMAL, (LONG)"RESERVED19",
  0x0000, 0x0013, 0x000A, 0x0001,
         0,       24,       43, G_BOX     ,   /* Object 23 STDSTRIN */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x000D, 0x0002, 0x0028, 0x0014,
        25,       -1,       -1, G_STRING  ,   /* Object 24  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x0000, 0x0004, 0x0001,
        26,       -1,       -1, G_STRING  ,   /* Object 25  */
  NONE, NORMAL, (LONG)"999999",
  0x0000, 0x0001, 0x0006, 0x0001,
        27,       -1,       -1, G_STRING  ,   /* Object 26  */
  NONE, NORMAL, (LONG)"99999999999",
  0x0000, 0x0002, 0x000B, 0x0001,
        28,       -1,       -1, G_STRING  ,   /* Object 27  */
  NONE, NORMAL, (LONG)"9999999990,00",
  0x0000, 0x0003, 0x000D, 0x0001,
        29,       -1,       -1, G_STRING  ,   /* Object 28  */
  NONE, NORMAL, (LONG)"9999999990,00",
  0x0000, 0x0004, 0x000D, 0x0001,
        30,       -1,       -1, G_STRING  ,   /* Object 29  */
  NONE, NORMAL, (LONG)"DD.MM.YYYY",
  0x0000, 0x0005, 0x000A, 0x0001,
        31,       -1,       -1, G_STRING  ,   /* Object 30  */
  NONE, NORMAL, (LONG)"HH:MI:SS",
  0x0000, 0x0006, 0x0008, 0x0001,
        32,       -1,       -1, G_STRING  ,   /* Object 31  */
  NONE, NORMAL, (LONG)"DD. MON YYYY HH:MI:SS",
  0x0000, 0x0007, 0x0015, 0x0001,
        33,       -1,       -1, G_STRING  ,   /* Object 32  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x0008, 0x0004, 0x0001,
        34,       -1,       -1, G_STRING  ,   /* Object 33  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x0009, 0x0004, 0x0001,
        35,       -1,       -1, G_STRING  ,   /* Object 34  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x000A, 0x0004, 0x0001,
        36,       -1,       -1, G_STRING  ,   /* Object 35  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x000B, 0x0004, 0x0001,
        37,       -1,       -1, G_STRING  ,   /* Object 36  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x000C, 0x0004, 0x0001,
        38,       -1,       -1, G_STRING  ,   /* Object 37  */
  NONE, NORMAL, (LONG)"99999999999",
  0x0000, 0x000D, 0x000B, 0x0001,
        39,       -1,       -1, G_STRING  ,   /* Object 38  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x000E, 0x0004, 0x0001,
        40,       -1,       -1, G_STRING  ,   /* Object 39  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x000F, 0x0004, 0x0001,
        41,       -1,       -1, G_STRING  ,   /* Object 40  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x0010, 0x0004, 0x0001,
        42,       -1,       -1, G_STRING  ,   /* Object 41  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x0011, 0x0004, 0x0001,
        43,       -1,       -1, G_STRING  ,   /* Object 42  */
  NONE, NORMAL, (LONG)"NULL",
  0x0000, 0x0012, 0x0004, 0x0001,
  STDSTRIN,       -1,       -1, G_STRING  ,   /* Object 43  */
  LASTOB, NORMAL, (LONG)"NULL",
  0x0000, 0x0013, 0x0004, 0x0001,
  
  /******** Tree 43 MASKINFO ****************************************************/
        -1,        1, MIGETSIZ, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x004B, 0x0014,
  MIDBNAME,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datenbank:",
  0x0002, 0x0001, 0x000A, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 MIDBNAME */
  NONE, STATE12|STATE15, (LONG)"________________________________",
  0x0014, 0x0001, 0x0020, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"Hintergrund-~Farbe:",
  0x0038, 0x0001, 0x0013, 0x0001,
  MIDEVICE,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, DRAW3D|STATE15, (LONG)"Ausgabeger\204t:",
  0x0002, 0x0003, 0x000D, 0x0001,
  MICOLOR ,       -1,       -1, G_STRING  ,   /* Object 5 MIDEVICE */
  NONE, DRAW3D|STATE12|STATE15, (LONG)"________________________________",
  0x0014, 0x0003, 0x0020, 0x0001,
         7,       -1,       -1, G_BUTTON  ,   /* Object 6 MICOLOR */
  SELECTABLE|TOUCHEXIT, DRAW3D|STATE11, (LONG)"\0",
  0x0038, 0x0003, 0x0010, 0x0001,
  MINAME  ,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, STATE15, (LONG)"~Name:",
  0x0002, 0x0004, 0x0006, 0x0001,
         9,       -1,       -1, G_FBOXTEXT,   /* Object 8 MINAME */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[110],
  0x0014, 0x0004, 0x0023, 0x0001,
  MITABLE ,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, STATE15, (LONG)"~Tabelle/Abfrage:",
  0x0002, 0x0006, 0x0011, 0x0001,
        11,       -1,       -1, G_FBOXTEXT,   /* Object 10 MITABLE */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[111],
  0x0014, 0x0006, 0x0023, 0x0001,
  MIUSER  ,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, STATE15, (LONG)"Benut~zer:",
  0x0002, 0x0008, 0x000A, 0x0001,
        13,       -1,       -1, G_FBOXTEXT,   /* Object 12 MIUSER */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[112],
  0x0014, 0x0008, 0x0023, 0x0001,
  MICENTRY,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, STATE15, (LONG)"Ein~gangsrechnung:",
  0x0002, 0x000A, 0x0012, 0x0001,
        15,       -1,       -1, G_FBOXTEXT,   /* Object 14 MICENTRY */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[113],
  0x0014, 0x000A, 0x0023, 0x0001,
  MICEXIT ,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, STATE15, (LONG)"Ausgangs~rechnung:",
  0x0002, 0x000C, 0x0012, 0x0001,
        17,       -1,       -1, G_FBOXTEXT,   /* Object 16 MICEXIT */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[114],
  0x0014, 0x000C, 0x0023, 0x0001,
  MIICONS ,       18, MIH     , G_BUTTON  ,   /* Object 17  */
  NONE, DRAW3D|STATE14, (LONG)"Anfangsgr\224\236e",
  0x0038, 0x0005, 0x0010, 0x000A,
  MIX     ,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, STATE15, (LONG)"~X:",
  0x0001, 0x0002, 0x0003, 0x0001,
        20,       -1,       -1, G_FBOXTEXT,   /* Object 19 MIX */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[115],
  0x0009, 0x0002, 0x0005, 0x0001,
  MIY     ,       -1,       -1, G_STRING  ,   /* Object 20  */
  NONE, STATE15, (LONG)"~Y:",
  0x0001, 0x0004, 0x0003, 0x0001,
        22,       -1,       -1, G_FBOXTEXT,   /* Object 21 MIY */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[116],
  0x0009, 0x0004, 0x0005, 0x0001,
  MIW     ,       -1,       -1, G_STRING  ,   /* Object 22  */
  NONE, STATE15, (LONG)"~Breite:",
  0x0001, 0x0006, 0x0008, 0x0001,
        24,       -1,       -1, G_FBOXTEXT,   /* Object 23 MIW */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[117],
  0x0009, 0x0006, 0x0005, 0x0001,
  MIH     ,       -1,       -1, G_STRING  ,   /* Object 24  */
  NONE, STATE15, (LONG)"H\224h~e:",
  0x0001, 0x0008, 0x0006, 0x0001,
        17,       -1,       -1, G_FBOXTEXT,   /* Object 25 MIH */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[118],
  0x0009, 0x0008, 0x0005, 0x0001,
  MIINFO  ,       -1,       -1, G_BUTTON  ,   /* Object 26 MIICONS */
  SELECTABLE, STATE13, (LONG)"~Symbolleiste",
  0x0002, 0x000E, 0x000D, 0x0001,
        28,       -1,       -1, G_BUTTON  ,   /* Object 27 MIINFO */
  SELECTABLE, STATE13, (LONG)"~Infozeile",
  0x0014, 0x000E, 0x000A, 0x0001,
  MIOBJS  ,       -1,       -1, G_STRING  ,   /* Object 28  */
  NONE, STATE15, (LONG)"Objekte:",
  0x0025, 0x000E, 0x0008, 0x0001,
  MI3D    ,       -1,       -1, G_STRING  ,   /* Object 29 MIOBJS */
  NONE, STATE14|STATE15, (LONG)"9999",
  0x0033, 0x000E, 0x0004, 0x0001,
  MIMENU  ,       -1,       -1, G_BUTTON  ,   /* Object 30 MI3D */
  SELECTABLE, STATE13, (LONG)"~3D-Effekte",
  0x0002, 0x000F, 0x000B, 0x0001,
        32,       -1,       -1, G_BUTTON  ,   /* Object 31 MIMENU */
  SELECTABLE, STATE13, (LONG)"~Men\201zeile",
  0x0014, 0x000F, 0x000A, 0x0001,
  MIMAXOBJ,       -1,       -1, G_STRING  ,   /* Object 32  */
  NONE, STATE15, (LONG)"Max. Objekte:",
  0x0025, 0x000F, 0x000D, 0x0001,
  MIOK    ,       -1,       -1, G_STRING  ,   /* Object 33 MIMAXOBJ */
  NONE, STATE14|STATE15, (LONG)"9999",
  0x0033, 0x000F, 0x0004, 0x0001,
  MICANCEL,       -1,       -1, G_BUTTON  ,   /* Object 34 MIOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0002, 0x0011, 0x000A, 0x0002,
  MIHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 35 MICANCEL */
  SELECTABLE|EXIT|FLAGS13, WHITEBAK, (LONG)"~Abbruch",
  0x000F, 0x0011, 0x000A, 0x0002,
  MIGETSIZ,       -1,       -1, G_BUTTON  ,   /* Object 36 MIHELP */
  SELECTABLE|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001C, 0x0011, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 37 MIGETSIZ */
  SELECTABLE|LASTOB, WHITEBAK, (LONG)"Breite~/H\224he berechnen",
  0x0031, 0x0011, 0x0017, 0x0002,
  
  /******** Tree 44 TBLINFO ****************************************************/
        -1,        1, TIHELP  , G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0038, 0x0015,
  TIDBNAME,       -1,       -1, G_STRING  ,   /* Object 1  */
  NONE, STATE15, (LONG)"Datenbank:",
  0x0002, 0x0001, 0x000A, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2 TIDBNAME */
  NONE, STATE12|STATE15, (LONG)"________________________________________",
  0x000E, 0x0001, 0x0028, 0x0001,
  TITABLE ,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE15, (LONG)"Tabelle:",
  0x0002, 0x0003, 0x0008, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4 TITABLE */
  NONE, STATE12|STATE15, (LONG)"_________________________________",
  0x000E, 0x0003, 0x0021, 0x0001,
  TIRECS  ,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE15, (LONG)"Datens\204tze:",
  0x0002, 0x0005, 0x000B, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6 TIRECS */
  NONE, STATE15, (LONG)"__________",
  0x000E, 0x0005, 0x000A, 0x0001,
  TICOLS  ,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, STATE15, (LONG)"Felder:",
  0x0002, 0x0006, 0x0007, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8 TICOLS */
  NONE, STATE15, (LONG)"_____",
  0x000E, 0x0006, 0x0005, 0x0001,
  TIINXS  ,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, STATE15, (LONG)"Indizes:",
  0x0002, 0x0007, 0x0008, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10 TIINXS */
  NONE, STATE15, (LONG)"_____",
  0x000E, 0x0007, 0x0005, 0x0001,
  TISIZE  ,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, STATE15, (LONG)"Satzgr\224\236e:",
  0x0002, 0x0008, 0x000A, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12 TISIZE */
  NONE, STATE15, (LONG)"__________",
  0x000E, 0x0008, 0x000A, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, DRAW3D|STATE15, (LONG)"Spaltenname",
  0x0003, 0x000A, 0x000B, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, DRAW3D|STATE15, (LONG)"Typ",
  0x001C, 0x000A, 0x0003, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"Adresse",
  0x0023, 0x000A, 0x0007, 0x0001,
  TILIST  ,       -1,       -1, G_STRING  ,   /* Object 16  */
  NONE, DRAW3D|STATE14|STATE15, (LONG)"Gr\224\236e",
  0x002E, 0x000A, 0x0005, 0x0001,
  TIOK    ,       -1,       -1, G_BOX     ,   /* Object 17 TILIST */
  NONE, STATE13, (LONG)0x00FF1101L,
  0x0002, 0x000B, 0x0034, 0x0006,
  TIHELP  ,       -1,       -1, G_BUTTON  ,   /* Object 18 TIOK */
  SELECTABLE|DEFAULT|EXIT, WHITEBAK, (LONG)"~OK",
  0x0010, 0x0012, 0x000A, 0x0002,
         0,       -1,       -1, G_BUTTON  ,   /* Object 19 TIHELP */
  SELECTABLE|LASTOB|FLAGS14, WHITEBAK, (LONG)"~Hilfe",
  0x001D, 0x0012, 0x000A, 0x0002,
  
  /******** Tree 45 EMPTY ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|STATE15, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0040, 0x0005,
         0, EACTION , ENAME   , G_IBOX    ,   /* Object 1  */
  NONE, STATE13|STATE14|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0040, 0x0005,
  ENAME   ,       -1,       -1, G_STRING  ,   /* Object 2 EACTION */
  NONE, STATE12|STATE15, (LONG)"Action......................................................",
  0x0002, 0x0001, 0x003C, 0x0001,
         1,       -1,       -1, G_STRING  ,   /* Object 3 ENAME */
  LASTOB, STATE12|STATE15, (LONG)"____________________________________________________________",
  0x0002, 0x0003, 0x003C, 0x0001,
  
  /******** Tree 46 HELPMENU ****************************************************/
        -1,        1,        7, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         7,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1, MHINFO  , MHHELP  , G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x0020, 0x0301,
  MHFILE  ,       -1,       -1, G_TITLE   ,   /* Object 3 MHINFO */
  NONE, NORMAL, (LONG)" Info",
  0x0000, 0x0000, 0x0006, 0x0301,
  MHEDIT  ,       -1,       -1, G_TITLE   ,   /* Object 4 MHFILE */
  NONE, NORMAL, (LONG)" Datei",
  0x0006, 0x0000, 0x0007, 0x0301,
  MHHELP  ,       -1,       -1, G_TITLE   ,   /* Object 5 MHEDIT */
  NONE, NORMAL, (LONG)" Bearbeiten",
  0x000D, 0x0000, 0x000C, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 6 MHHELP */
  NONE, NORMAL, (LONG)" Hilfe",
  0x0019, 0x0000, 0x0007, 0x0301,
         0,        8,       18, G_IBOX    ,   /* Object 7  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0013,
        10, MHELPINF, MHELPINF, G_BOX     ,   /* Object 8  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0011, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 9 MHELPINF */
  NONE, NORMAL, (LONG)"  \232ber Hilfe...",
  0x0000, 0x0000, 0x0011, 0x0001,
        13, MHOPENDB, MHCLOSED, G_BOX     ,   /* Object 10  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0008, 0x0000, 0x001C, 0x0002,
  MHCLOSED,       -1,       -1, G_STRING  ,   /* Object 11 MHOPENDB */
  NONE, NORMAL, (LONG)"  Hilfe-DB \224ffnen...    ^O",
  0x0000, 0x0000, 0x001C, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 12 MHCLOSED */
  NONE, NORMAL, (LONG)"  Hilfe-DB schlie\236en... ^U",
  0x0000, 0x0001, 0x001C, 0x0001,
        18, MHUNDO  , MHPREV  , G_BOX     ,   /* Object 13  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000F, 0x0000, 0x0014, 0x0004,
        15,       -1,       -1, G_STRING  ,   /* Object 14 MHUNDO */
  NONE, NORMAL, (LONG)"  Zur\201ck        ^Z",
  0x0000, 0x0000, 0x0014, 0x0001,
  MHNEXT  ,       -1,       -1, G_STRING  ,   /* Object 15  */
  EDITABLE, DISABLED, (LONG)"--------------------",
  0x0000, 0x0001, 0x0014, 0x0001,
  MHPREV  ,       -1,       -1, G_STRING  ,   /* Object 16 MHNEXT */
  NONE, NORMAL, (LONG)"  N\204chstes Thema +",
  0x0000, 0x0002, 0x0014, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 17 MHPREV */
  NONE, NORMAL, (LONG)"  Voriges Thema  -",
  0x0000, 0x0003, 0x0014, 0x0001,
         7, MHUSEHLP, MHCONTEN, G_BOX     ,   /* Object 18  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x001B, 0x0000, 0x0016, 0x0002,
  MHCONTEN,       -1,       -1, G_STRING  ,   /* Object 19 MHUSEHLP */
  NONE, NORMAL, (LONG)"  Hilfe verwenden F1",
  0x0000, 0x0000, 0x0016, 0x0001,
        18,       -1,       -1, G_STRING  ,   /* Object 20 MHCONTEN */
  LASTOB, NORMAL, (LONG)"  Inhalt         ^F1",
  0x0000, 0x0001, 0x0016, 0x0001,
  
  /******** Tree 47 HABOUT ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0027, 0x0014,
         0,        2,       18, G_BOX     ,   /* Object 1  */
  NONE, OUTLINED|WHITEBAK|STATE15, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0027, 0x0014,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, DRAW3D|STATE11|STATE13|STATE15, (LONG)"HILFE",
  0x0010, 0x0001, 0x0007, 0x0002,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, STATE13|STATE15, (LONG)"Kontextsensitives Hilfesystem",
  0x0005, 0x0003, 0x001D, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, STATE13|STATE15, (LONG)"basierend auf dem",
  0x000B, 0x0004, 0x0011, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, STATE13|STATE15, (LONG)"relationalen Datenbanksystem",
  0x0006, 0x0005, 0x001C, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, STATE13|STATE15, (LONG)"PHOENIX",
  0x0010, 0x0006, 0x0007, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[119],
  0x0013, 0x0008, 0x0202, 0x0600,
         9,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[120],
  0x0009, 0x0009, 0x000A, 0x0600,
        10,       -1,       -1, G_TEXT    ,   /* Object 9  */
  NONE, NORMAL, (LONG)&rs_tedinfo[121],
  0x0016, 0x0009, 0x0609, 0x0600,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[122],
  0x0009, 0x000A, 0x0009, 0x0600,
        12,       -1,       -1, G_TEXT    ,   /* Object 11  */
  NONE, DRAW3D, (LONG)&rs_tedinfo[123],
  0x0014, 0x000A, 0x0600, 0x0600,
        13,       -1,       -1, G_TEXT    ,   /* Object 12  */
  NONE, NORMAL, (LONG)&rs_tedinfo[124],
  0x0016, 0x000A, 0x0009, 0x0600,
        14,       -1,       -1, G_TEXT    ,   /* Object 13  */
  NONE, NORMAL, (LONG)&rs_tedinfo[125],
  0x0011, 0x000B, 0x0006, 0x0600,
        15,       -1,       -1, G_TEXT    ,   /* Object 14  */
  NONE, NORMAL, (LONG)&rs_tedinfo[126],
  0x0007, 0x000C, 0x0419, 0x0600,
        16,       -1,       -1, G_TEXT    ,   /* Object 15  */
  NONE, NORMAL, (LONG)&rs_tedinfo[127],
  0x000E, 0x000D, 0x020B, 0x0600,
        17,       -1,       -1, G_TEXT    ,   /* Object 16  */
  NONE, NORMAL, (LONG)&rs_tedinfo[128],
  0x000D, 0x000E, 0x000C, 0x0600,
        18,       -1,       -1, G_TEXT    ,   /* Object 17  */
  NONE, NORMAL, (LONG)&rs_tedinfo[129],
  0x0011, 0x000F, 0x0205, 0x0600,
         1,       -1,       -1, G_BUTTON  ,   /* Object 18  */
  SELECTABLE|DEFAULT|EXIT|LASTOB, WHITEBAK, (LONG)"~OK",
  0x000E, 0x0011, 0x000A, 0x0002
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MENU     */
  &rs_object[60],   /* Tree  1 ABOUT    */
  &rs_object[72],   /* Tree  2 MOREINFO */
  &rs_object[86],   /* Tree  3 DESKTOP  */
  &rs_object[101],   /* Tree  4 USERIMG  */
  &rs_object[125],   /* Tree  5 ALERT    */
  &rs_object[140],   /* Tree  6 SELFILE  */
  &rs_object[156],   /* Tree  7 SELPATH  */
  &rs_object[167],   /* Tree  8 SELFONT  */
  &rs_object[189],   /* Tree  9 HELPINX  */
  &rs_object[230],   /* Tree 10 POPUPS   */
  &rs_object[269],   /* Tree 11 CONFIG   */
  &rs_object[295],   /* Tree 12 PARAMS   */
  &rs_object[342],   /* Tree 13 USERINTR */
  &rs_object[375],   /* Tree 14 OPENDB   */
  &rs_object[398],   /* Tree 15 BASEMENU */
  &rs_object[438],   /* Tree 16 MASKMENU */
  &rs_object[459],   /* Tree 17 DBICONS  */
  &rs_object[467],   /* Tree 18 DBINFO   */
  &rs_object[515],   /* Tree 19 NEWTABLE */
  &rs_object[535],   /* Tree 20 NEWFIELD */
  &rs_object[573],   /* Tree 21 NEWKEY   */
  &rs_object[596],   /* Tree 22 DOICONS  */
  &rs_object[611],   /* Tree 23 FORMATS  */
  &rs_object[625],   /* Tree 24 SELMASK  */
  &rs_object[642],   /* Tree 25 MASKICON */
  &rs_object[656],   /* Tree 26 DBPARAMS */
  &rs_object[672],   /* Tree 27 RELRULES */
  &rs_object[694],   /* Tree 28 SELFIELD */
  &rs_object[736],   /* Tree 29 SELFILL  */
  &rs_object[750],   /* Tree 30 SELLINE  */
  &rs_object[785],   /* Tree 31 SELGRID  */
  &rs_object[795],   /* Tree 32 SELSIZE  */
  &rs_object[805],   /* Tree 33 SELTEXT  */
  &rs_object[831],   /* Tree 34 OBJSIZE  */
  &rs_object[845],   /* Tree 35 PICSIZE  */
  &rs_object[863],   /* Tree 36 LINESIZE */
  &rs_object[877],   /* Tree 37 RBVALUES */
  &rs_object[887],   /* Tree 38 CBVALUES */
  &rs_object[895],   /* Tree 39 SELSUBM  */
  &rs_object[923],   /* Tree 40 SELBUTTO */
  &rs_object[956],   /* Tree 41 BACCESS  */
  &rs_object[984],   /* Tree 42 STDFORMA */
  &rs_object[1028],   /* Tree 43 MASKINFO */
  &rs_object[1066],   /* Tree 44 TBLINFO  */
  &rs_object[1086],   /* Tree 45 EMPTY    */
  &rs_object[1090],   /* Tree 46 HELPMENU */
  &rs_object[1111]    /* Tree 47 HABOUT   */
};
