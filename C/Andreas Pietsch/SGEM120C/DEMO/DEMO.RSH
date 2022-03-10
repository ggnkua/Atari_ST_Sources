/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "DEMO.H"

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
{ " Wei\236        ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 14, 1,
  " Wei\236        ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 14, 1,
  "------------------------------32",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 33, 1,
  "------------------------------32",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 33, 1,
  "------------------------------32",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 33, 1,
  "------------------------------32",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 33, 1,
  "------------------------------32",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 33, 1,
  "------------------------------32",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 33, 1,
  " Gr\201n        ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1380, 0, 0, 14, 1,
  " Blau        ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1480, 0, 0, 14, 1,
  " Cyan        ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1580, 0, 0, 14, 1,
  " Gelb        ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1680, 0, 0, 14, 1,
  " Magenta     ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1780, 0, 0, 14, 1,
  " Hellgrau    ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 14, 1,
  " Dunkelgrau  ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1980, 0, 0, 14, 1,
  " Hellrot     ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1A80, 0, 0, 14, 1,
  " Hellgr\201n    ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1B80, 0, 0, 14, 1,
  " Hellblau    ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1C80, 0, 0, 14, 1,
  " Hellcyan    ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1D80, 0, 0, 14, 1,
  " Hellgelb    ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1E80, 0, 0, 14, 1,
  " Hellmagenta ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1F80, 0, 0, 14, 1,
  "___",
  "Zahl zwischen 50 und 100: ___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 30,
  "___",
  "Zahl zwischen 90 und 200: ___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 30,
  "___",
  "Zahl zwischen 99 und 101: ___",
  "999",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 4, 30,
  "___________________________________",
  "Text 1: ___________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 36, 44,
  "___________________________________",
  "Text 2: ___________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 36, 44,
  "___________________________________",
  "Text 3: ___________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 36, 44,
  "___________________________________",
  "Text 4: ___________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 36, 44,
  "Laufzeit:",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 10, 1,
  "-----",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 6, 1,
  "s",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 2, 1
};

WORD RSBB0DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x80FF, 0xFF01, 0x8080, 0x0101, 
  0x80BF, 0xFD01, 0x80A0, 0x0501, 
  0x80A0, 0x0501, 0x80A0, 0x0501, 
  0x80A0, 0x0501, 0x80BF, 0xFD01, 
  0x8080, 0x0101, 0x80FF, 0xFF01, 
  0x8040, 0x0201, 0x8FFF, 0xFFF1, 
  0x8800, 0x0011, 0x8800, 0x0011, 
  0x8800, 0x3F91, 0x8800, 0x0011, 
  0x8800, 0x0011, 0x8FFF, 0xFFF1, 
  0x8200, 0x0041, 0x8200, 0x0041, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

WORD RSBB1DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x83FF, 0xFF01, 0x8220, 0x0481, 
  0x8220, 0x7441, 0x8220, 0x5441, 
  0x8220, 0x7441, 0x8220, 0x0441, 
  0x823F, 0xFC41, 0x8200, 0x0041, 
  0x827F, 0xFE41, 0x8240, 0x0241, 
  0x8240, 0x0241, 0x824F, 0xF241, 
  0x8240, 0x0241, 0x824F, 0xC241, 
  0x8340, 0x0241, 0x834F, 0xF241, 
  0x8240, 0x0241, 0x8240, 0x0241, 
  0x83FF, 0xFFC1, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

WORD RSBB2DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x83FE, 0x7FC1, 
  0x8062, 0x4601, 0x83E1, 0x87C1, 
  0x8060, 0x0601, 0x83E0, 0x07C1, 
  0x8060, 0x0601, 0x83E1, 0x87C1, 
  0x8062, 0x4601, 0x83E5, 0xA7C1, 
  0x8065, 0xA601, 0x83E2, 0x47C1, 
  0x8061, 0x8601, 0x83E0, 0x07C1, 
  0x8060, 0x0601, 0x83E0, 0x07C1, 
  0x8060, 0x0601, 0x83FF, 0xFFC1, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

WORD RSBB3DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0F81, 
  0x8000, 0x1F81, 0x8000, 0x0381, 
  0x8000, 0x0581, 0x8000, 0x0981, 
  0x8000, 0x1101, 0x8000, 0x2001, 
  0x8000, 0x4001, 0x8000, 0x8001, 
  0x8001, 0x0001, 0x8002, 0x0001, 
  0x8004, 0x0001, 0x8008, 0x0001, 
  0x80F0, 0x0001, 0x81F0, 0x0001, 
  0x81F0, 0x0001, 0x81F0, 0x0001, 
  0x80E0, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

WORD RSBB4DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8202, 0x0801, 0x80FC, 0x4041, 
  0x8102, 0x1201, 0x8102, 0xA521, 
  0x8102, 0x0881, 0x8102, 0xD081, 
  0x8102, 0x2041, 0x8102, 0x6041, 
  0x8102, 0x8041, 0x81C2, 0xC081, 
  0x8032, 0x7F01, 0x821C, 0x8441, 
  0x8047, 0xFD01, 0x8048, 0x0241, 
  0x8110, 0x0C01, 0x82A0, 0x3841, 
  0x8040, 0xF101, 0x8287, 0x8441, 
  0x81FE, 0x2121, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

WORD RSBB5DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x7001, 
  0x82D9, 0xACC1, 0x8002, 0x2201, 
  0x8354, 0x0141, 0x8005, 0x9501, 
  0x82EA, 0x5481, 0x800A, 0x5481, 
  0x83CA, 0x5481, 0x8005, 0x9501, 
  0x8004, 0x0141, 0x8006, 0x3201, 
  0x800F, 0xCCC1, 0x801C, 0x7001, 
  0x8038, 0x0341, 0x8070, 0x0001, 
  0x80E0, 0x0DC1, 0x81C0, 0x0001, 
  0x8080, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

WORD RSBB6DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x7801, 
  0x8380, 0x4001, 0x8400, 0x7001, 
  0x8400, 0x71E1, 0x841C, 0x4021, 
  0x8412, 0x79E1, 0x8392, 0x0101, 
  0x8012, 0x01E1, 0x8012, 0x0001, 
  0x801C, 0x00C1, 0x8000, 0x00C1, 
  0x8000, 0x0001, 0x8FFF, 0xFFF1, 
  0x8800, 0x0011, 0x8800, 0x0011, 
  0x8800, 0x0011, 0x8800, 0x1991, 
  0x8800, 0x0011, 0x8FFF, 0xFFF1, 
  0x8200, 0x0041, 0x8200, 0x0041, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

WORD RSBB7DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8007, 0xFF81, 0x8004, 0x0081, 
  0x80E4, 0x0081, 0x8114, 0x0081, 
  0x8114, 0x0081, 0x8114, 0x0081, 
  0x80E4, 0x0081, 0x8004, 0x0081, 
  0x8004, 0x0081, 0x8007, 0xFF81, 
  0x8000, 0x0001, 0x81FF, 0x8001, 
  0x8101, 0x0081, 0x8106, 0x3881, 
  0x8108, 0x4481, 0x8130, 0x8281, 
  0x8140, 0x4481, 0x8180, 0x3881, 
  0x8100, 0x0081, 0x8000, 0x0081, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

WORD RSBB8DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x800C, 0x0001, 0x800C, 0x0001, 
  0x801E, 0x7C01, 0x801E, 0x3E01, 
  0x800C, 0x1F01, 0x801E, 0x0F81, 
  0x801E, 0x07C1, 0x8033, 0x0BE1, 
  0x8033, 0x11E1, 0x806D, 0xA2E1, 
  0x83FF, 0xC441, 0x80CC, 0x8801, 
  0x80C1, 0x1001, 0x8182, 0x2001, 
  0x8184, 0x6001, 0x8308, 0xB001, 
  0x8311, 0x3001, 0x8622, 0x1801, 
  0x863C, 0x1C01, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

WORD RSBB9DATA[] =
{ 0xFFFF, 0xFFFF, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x87FE, 0x0001, 
  0x87FE, 0x0001, 0x8402, 0x0001, 
  0x84F2, 0x4001, 0x8412, 0x2001, 
  0x84F2, 0x1401, 0x8482, 0x0C01, 
  0x84F2, 0x1C01, 0x8402, 0x0001, 
  0x8462, 0x0001, 0x8402, 0x0F01, 
  0x87FE, 0x7FE1, 0x8000, 0x7FE1, 
  0x8000, 0x4021, 0x8040, 0x55A1, 
  0x8020, 0x4021, 0x8014, 0x5BA1, 
  0x800C, 0x4021, 0x801C, 0x56A1, 
  0x8000, 0x4021, 0x8000, 0x5261, 
  0x8000, 0x7FE1, 0x8000, 0x0001, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0001, 0xFFFF, 0xFFFF
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,   4,  32,   0,   0, 0x0009,
  RSBB1DATA,   4,  32,   0,   0, 0x0009,
  RSBB2DATA,   4,  32,   0,   0, 0x0009,
  RSBB3DATA,   4,  32,   0,   0, 0x0009,
  RSBB4DATA,   4,  32,   0,   0, 0x0009,
  RSBB5DATA,   4,  32,   0,   0, 0x0009,
  RSBB6DATA,   4,  32,   0,   0, 0x0009,
  RSBB7DATA,   4,  32,   0,   0, 0x0009,
  RSBB8DATA,   4,  32,   0,   0, 0x0009,
  RSBB9DATA,   4,  32,   0,   0, 0x0009
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 MENUE1 ****************************************************/
        -1,        1,        5, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         5,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1,        3,        4, G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x000F, 0x0301,
         4,       -1,       -1, G_TITLE   ,   /* Object 3  */
  NONE, NORMAL, (LONG)" SysGem",
  0x0000, 0x0000, 0x0008, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 4  */
  NONE, NORMAL, (LONG)" Datei",
  0x0008, 0x0000, 0x0007, 0x0301,
         0,        6,       15, G_IBOX    ,   /* Object 5  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0017,
        15, ME_INFO ,       14, G_BOX     ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0015, 0x0008,
         8,       -1,       -1, G_STRING  ,   /* Object 7 ME_INFO */
  NONE, NORMAL, (LONG)"  Programminfo... ^I ",
  0x0000, 0x0000, 0x0015, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, DISABLED, (LONG)"---------------------",
  0x0000, 0x0001, 0x0015, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"  Desk Accessory 1 ",
  0x0000, 0x0002, 0x0015, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"  Desk Accessory 2 ",
  0x0000, 0x0003, 0x0015, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"  Desk Accessory 3 ",
  0x0000, 0x0004, 0x0015, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"  Desk Accessory 4 ",
  0x0000, 0x0005, 0x0015, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"  Desk Accessory 5 ",
  0x0000, 0x0006, 0x0015, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"  Desk Accessory 6 ",
  0x0000, 0x0007, 0x0015, 0x0001,
         5, ME_EDIT , ME_QUIT , G_BOX     ,   /* Object 15  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000A, 0x0000, 0x0011, 0x0003,
        17,       -1,       -1, G_STRING  ,   /* Object 16 ME_EDIT */
  NONE, NORMAL, (LONG)"  Editfelder  ^E ",
  0x0000, 0x0000, 0x0011, 0x0001,
  ME_QUIT ,       -1,       -1, G_STRING  ,   /* Object 17  */
  NONE, DISABLED, (LONG)"-----------------",
  0x0000, 0x0001, 0x0011, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 18 ME_QUIT */
  LASTOB, NORMAL, (LONG)"  Ende        ^Q ",
  0x0000, 0x0002, 0x0011, 0x0001,
  
  /******** Tree 1 M2MENU ****************************************************/
        -1,        1,        5, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         5,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1,        3,        4, G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x000F, 0x0301,
         4,       -1,       -1, G_TITLE   ,   /* Object 3  */
  NONE, NORMAL, (LONG)" SysGem",
  0x0000, 0x0000, 0x0008, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 4  */
  NONE, NORMAL, (LONG)" Datei",
  0x0008, 0x0000, 0x0007, 0x0301,
         0,        6,        8, G_IBOX    ,   /* Object 5  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0017,
         8, M2_INFO , M2_INFO , G_BOX     ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0015, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 7 M2_INFO */
  NONE, NORMAL, (LONG)"  Programminfo... ^I ",
  0x0000, 0x0000, 0x0015, 0x0001,
         5, M2_QUIT , M2_QUIT , G_BOX     ,   /* Object 8  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000A, 0x0000, 0x000E, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 9 M2_QUIT */
  LASTOB, NORMAL, (LONG)"  Beenden  ^Q ",
  0x0000, 0x0000, 0x000E, 0x0001,
  
  /******** Tree 2 MAIN ****************************************************/
        -1,        1, MA_DN   , G_BOX     ,   /* Object 0  */
  FLAGS9|FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0437, 0x000D,
        12, MA_SYS  , MA_WRT  , G_BOX     ,   /* Object 1  */
  FLAGS9|FLAGS10, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0000, 0x0437, 0x0003,
  MA_LAUF ,       -1,       -1, G_IMAGE   ,   /* Object 2 MA_SYS */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[0],
  0x0401, 0x0800, 0x0004, 0x0002,
  MA_MEM  ,       -1,       -1, G_IMAGE   ,   /* Object 3 MA_LAUF */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[1],
  0x0406, 0x0800, 0x0004, 0x0002,
  MA_VEK  ,       -1,       -1, G_IMAGE   ,   /* Object 4 MA_MEM */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[2],
  0x040B, 0x0800, 0x0004, 0x0002,
  MA_COOK ,       -1,       -1, G_IMAGE   ,   /* Object 5 MA_VEK */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[3],
  0x0410, 0x0800, 0x0004, 0x0002,
  MA_XBRA ,       -1,       -1, G_IMAGE   ,   /* Object 6 MA_COOK */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[4],
  0x0415, 0x0800, 0x0004, 0x0002,
  MA_HD   ,       -1,       -1, G_IMAGE   ,   /* Object 7 MA_XBRA */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[5],
  0x041A, 0x0800, 0x0004, 0x0002,
  MA_GRAF ,       -1,       -1, G_IMAGE   ,   /* Object 8 MA_HD */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[6],
  0x041F, 0x0800, 0x0004, 0x0002,
  MA_SGEM ,       -1,       -1, G_IMAGE   ,   /* Object 9 MA_GRAF */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[7],
  0x0424, 0x0800, 0x0004, 0x0002,
  MA_WRT  ,       -1,       -1, G_IMAGE   ,   /* Object 10 MA_SGEM */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[8],
  0x0429, 0x0800, 0x0004, 0x0002,
         1,       -1,       -1, G_IMAGE   ,   /* Object 11 MA_WRT */
  SELECTABLE|EXIT|FLAGS10, NORMAL, (LONG)&rs_bitblk[9],
  0x0432, 0x0800, 0x0004, 0x0002,
  MA_POP1 ,       13,       14, G_BUTTON  |0x1400,   /* Object 12  */
  NONE, CHECKED, (LONG)" RADIO ",
  0x0401, 0x0004, 0x040E, 0x0803,
        14,       -1,       -1, G_BUTTON  |0x1200,   /* Object 13  */
  SELECTABLE|RBUTTON, SELECTED, (LONG)"Radio [1",
  0x0001, 0x0001, 0x040C, 0x0001,
        12,       -1,       -1, G_BUTTON  |0x1200,   /* Object 14  */
  SELECTABLE|RBUTTON, NORMAL, (LONG)"Radio [2",
  0x0001, 0x0002, 0x040C, 0x0001,
  MA_POP2 ,       -1,       -1, G_BOXTEXT ,   /* Object 15 MA_POP1 */
  TOUCHEXIT|FLAGS9|FLAGS10, SHADOWED, (LONG)&rs_tedinfo[0],
  0x0413, 0x0004, 0x000D, 0x0001,
  MA_LIST1,       -1,       -1, G_BOXCHAR ,   /* Object 16 MA_POP2 */
  TOUCHEXIT|FLAGS9|FLAGS10, SHADOWED, (LONG) ((LONG)'O' << 24)|0x00FF1100L,
  0x0520, 0x0004, 0x0002, 0x0001,
  MA_LIST2,       -1,       -1, G_BOXTEXT ,   /* Object 17 MA_LIST1 */
  TOUCHEXIT|FLAGS9|FLAGS10, SHADOWED, (LONG)&rs_tedinfo[1],
  0x0426, 0x0004, 0x000D, 0x0001,
  MA_BOX  ,       -1,       -1, G_BOXCHAR ,   /* Object 18 MA_LIST2 */
  TOUCHEXIT|FLAGS9|FLAGS10, SHADOWED, (LONG) ((LONG)'\360' << 24)|0x00FF1100L,
  0x0533, 0x0004, 0x0002, 0x0001,
  MA_UP   ,       20,       25, G_BOX     ,   /* Object 19 MA_BOX */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0413, 0x0006, 0x0020, 0x0006,
        21,       -1,       -1, G_TEXT    ,   /* Object 20  */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0000, 0x0000, 0x0020, 0x0001,
        22,       -1,       -1, G_TEXT    ,   /* Object 21  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0000, 0x0001, 0x0020, 0x0001,
        23,       -1,       -1, G_TEXT    ,   /* Object 22  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0000, 0x0002, 0x0020, 0x0001,
        24,       -1,       -1, G_TEXT    ,   /* Object 23  */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0000, 0x0003, 0x0020, 0x0001,
        25,       -1,       -1, G_TEXT    ,   /* Object 24  */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0000, 0x0004, 0x0020, 0x0001,
  MA_BOX  ,       -1,       -1, G_TEXT    ,   /* Object 25  */
  NONE, NORMAL, (LONG)&rs_tedinfo[7],
  0x0000, 0x0005, 0x0020, 0x0001,
  MA_HIDE ,       -1,       -1, G_BOXCHAR ,   /* Object 26 MA_UP */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'\001' << 24)|0x00FF1100L,
  0x0034, 0x0006, 0x0002, 0x0001,
        29, MA_SHOW , MA_SHOW , G_BOX     ,   /* Object 27 MA_HIDE */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0034, 0x0807, 0x0002, 0x0003,
  MA_HIDE ,       -1,       -1, G_BOX     ,   /* Object 28 MA_SHOW */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0800, 0x0002, 0x0801,
  MA_DN   ,       30,       31, G_BUTTON  |0x1400,   /* Object 29  */
  NONE, CHECKED, (LONG)" SELECT ",
  0x0401, 0x0808, 0x040E, 0x0803,
        31,       -1,       -1, G_BUTTON  |0x1200,   /* Object 30  */
  SELECTABLE, SELECTED, (LONG)"Select [4",
  0x0001, 0x0001, 0x040C, 0x0001,
        29,       -1,       -1, G_BUTTON  |0x1200,   /* Object 31  */
  SELECTABLE, NORMAL, (LONG)"Select [5",
  0x0001, 0x0002, 0x040C, 0x0001,
         0,       -1,       -1, G_BOXCHAR ,   /* Object 32 MA_DN */
  LASTOB|TOUCHEXIT, NORMAL, (LONG) ((LONG)'\002' << 24)|0x00FF1100L,
  0x0034, 0x000B, 0x0002, 0x0001,
  
  /******** Tree 3 SPOPUP ****************************************************/
        -1, SP_1    , SP_16   , G_BOX     ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x000D, 0x0010,
         2,       -1,       -1, G_STRING  ,   /* Object 1 SP_1 */
  SELECTABLE, NORMAL, (LONG)" Wei\236        ",
  0x0000, 0x0000, 0x000D, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  SELECTABLE, NORMAL, (LONG)" Schwarz     ",
  0x0000, 0x0001, 0x000D, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  SELECTABLE, NORMAL, (LONG)" Rot         ",
  0x0000, 0x0002, 0x000D, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[8],
  0x0000, 0x0003, 0x000D, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[9],
  0x0000, 0x0004, 0x000D, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[10],
  0x0000, 0x0005, 0x000D, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[11],
  0x0000, 0x0006, 0x000D, 0x0001,
         9,       -1,       -1, G_TEXT    ,   /* Object 8  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[12],
  0x0000, 0x0007, 0x000D, 0x0001,
        10,       -1,       -1, G_TEXT    ,   /* Object 9  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[13],
  0x0000, 0x0008, 0x000D, 0x0001,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[14],
  0x0000, 0x0009, 0x000D, 0x0001,
        12,       -1,       -1, G_TEXT    ,   /* Object 11  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[15],
  0x0000, 0x000A, 0x000D, 0x0001,
        13,       -1,       -1, G_TEXT    ,   /* Object 12  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[16],
  0x0000, 0x000B, 0x000D, 0x0001,
        14,       -1,       -1, G_TEXT    ,   /* Object 13  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[17],
  0x0000, 0x000C, 0x000D, 0x0001,
        15,       -1,       -1, G_TEXT    ,   /* Object 14  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[18],
  0x0000, 0x000D, 0x000D, 0x0001,
  SP_16   ,       -1,       -1, G_TEXT    ,   /* Object 15  */
  SELECTABLE, NORMAL, (LONG)&rs_tedinfo[19],
  0x0000, 0x000E, 0x000D, 0x0001,
         0,       -1,       -1, G_TEXT    ,   /* Object 16 SP_16 */
  SELECTABLE|LASTOB, NORMAL, (LONG)&rs_tedinfo[20],
  0x0000, 0x000F, 0x000D, 0x0001,
  
  /******** Tree 4 SGINFO ****************************************************/
        -1,        1,       11, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x041C, 0x0010,
         5,        2,        4, G_BUTTON  |0x1400,   /* Object 1  */
  NONE, CHECKED, (LONG)" (C) 1994 BY ",
  0x0301, 0x0E00, 0x0419, 0x0004,
         3,       -1,       -1, G_STRING  ,   /* Object 2  */
  NONE, NORMAL, (LONG)"Andreas Pietsch",
  0x0401, 0x0800, 0x000F, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3  */
  NONE, NORMAL, (LONG)"Schillerstrasse 24",
  0x0401, 0x0801, 0x0012, 0x0001,
         1,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"56727 Mayen, FRG",
  0x0401, 0x0802, 0x0010, 0x0001,
        10,        6,        9, G_BUTTON  |0x1400,   /* Object 5  */
  NONE, CHECKED, (LONG)" E-MAIL ",
  0x0401, 0x0006, 0x0419, 0x0005,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"Voice    +49-2651-48833",
  0x0401, 0x0800, 0x0017, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"Fax      +49-2651-43344",
  0x0401, 0x0801, 0x0017, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"Maus     WI2",
  0x0401, 0x0802, 0x000C, 0x0001,
         5,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"Internet @wi2.maus.de",
  0x0401, 0x0803, 0x0015, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"SysGem ist Keyware!",
  0x0005, 0x000C, 0x0013, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x1200,   /* Object 11  */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)"[SysGem",
  0x0409, 0x000E, 0x000A, 0x0401,
  
  /******** Tree 5 SEDIT ****************************************************/
        -1,        1,       10, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x043E, 0x000C,
  SE_Z50_100,       -1,       -1, G_STRING  |0x1300,   /* Object 1  */
  NONE, SHADOWED, (LONG)"Editfelder mal komfortabel",
  0x0002, 0x0001, 0x003B, 0x0001,
  SE_Z90_200,       -1,       -1, G_FTEXT   ,   /* Object 2 SE_Z50_100 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[21],
  0x0002, 0x0003, 0x001D, 0x0001,
  SE_Z99_101,       -1,       -1, G_FTEXT   ,   /* Object 3 SE_Z90_200 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[22],
  0x0002, 0x0004, 0x001D, 0x0001,
         5,       -1,       -1, G_FTEXT   ,   /* Object 4 SE_Z99_101 */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[23],
  0x0002, 0x0005, 0x001D, 0x0001,
         6,       -1,       -1, G_FTEXT   ,   /* Object 5  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[24],
  0x0002, 0x0007, 0x002B, 0x0001,
  SE_CLR  ,       -1,       -1, G_FTEXT   ,   /* Object 6  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[25],
  0x0002, 0x0008, 0x002B, 0x0001,
         8,       -1,       -1, G_BUTTON  |0x1200,   /* Object 7 SE_CLR */
  SELECTABLE|EXIT, NORMAL, (LONG)"[Clear",
  0x0432, 0x0807, 0x000A, 0x0401,
         9,       -1,       -1, G_FTEXT   ,   /* Object 8  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[26],
  0x0002, 0x0009, 0x002B, 0x0001,
        10,       -1,       -1, G_FTEXT   ,   /* Object 9  */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[27],
  0x0002, 0x000A, 0x002B, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x1200,   /* Object 10  */
  SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, (LONG)"[Ok",
  0x0432, 0x0809, 0x000A, 0x0401,
  
  /******** Tree 6 TOOLS ****************************************************/
        -1, TO_SORT , TO_SORT , G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1180L,
  0x0000, 0x0000, 0x003A, 0x0E02,
         0,       -1,       -1, G_BUTTON  |0x1200,   /* Object 1 TO_SORT */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)"[Sortieren",
  0x0401, 0x0C00, 0x000C, 0x0601,
  
  /******** Tree 7 BITS ****************************************************/
        -1,        1,        3, G_BOX     ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0012, 0x0002,
  BI_SEC  ,       -1,       -1, G_TEXT    ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_tedinfo[28],
  0x0001, 0x0800, 0x0009, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2 BI_SEC */
  NONE, NORMAL, (LONG)&rs_tedinfo[29],
  0x040A, 0x0800, 0x0005, 0x0001,
         0,       -1,       -1, G_TEXT    ,   /* Object 3  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[30],
  0x0010, 0x0800, 0x0001, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MENUE1   */
  &rs_object[19],   /* Tree  1 M2MENU   */
  &rs_object[29],   /* Tree  2 MAIN     */
  &rs_object[62],   /* Tree  3 SPOPUP   */
  &rs_object[79],   /* Tree  4 SGINFO   */
  &rs_object[91],   /* Tree  5 SEDIT    */
  &rs_object[102],   /* Tree  6 TOOLS    */
  &rs_object[104]    /* Tree  7 BITS     */
};
