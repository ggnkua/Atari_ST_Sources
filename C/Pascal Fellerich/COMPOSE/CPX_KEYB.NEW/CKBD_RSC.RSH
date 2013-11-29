/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "CKBD_RSC.H"

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
{ "?",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1074, 0, -1, 2, 1,
  "?",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "?",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "?",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "?",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "?",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 2, 1,
  "?",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1074, 0, -1, 2, 1,
  "\2751994-96 by",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 12, 1,
  "Pascal",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 7, 1,
  "Fellerich",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 10, 1,
  "Fellerich",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 10, 1,
  "Pascal",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 7, 1,
  "\2751994-96 by",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 12, 1,
  "?",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1074, 0, -1, 2, 1,
  "123456789ABCDEF",
  "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _",
  "XXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1280, 0, -1, 16, 30
};

RSBB0DATA[] =
{ 0x0000, 0x7FFE, 0x4002, 0x4002, 
  0x4002, 0x4002, 0x4002, 0x4002, 
  0x4002, 0x4002, 0x4002, 0x4002, 
  0x4002, 0x4002, 0x7FFE, 0x0000
};

RSBB1DATA[] =
{ 0x0000, 0x7FFE, 0x6006, 0x500A, 
  0x4812, 0x4422, 0x4242, 0x4182, 
  0x4182, 0x4242, 0x4422, 0x4812, 
  0x500A, 0x6006, 0x7FFE, 0x0000
};

RSBB2DATA[] =
{ 0x0000, 0x03C0, 0x0C30, 0x1008, 
  0x2004, 0x2004, 0x4002, 0x4002, 
  0x4002, 0x4002, 0x2004, 0x2004, 
  0x1008, 0x0C30, 0x03C0, 0x0000
};

RSBB3DATA[] =
{ 0x0000, 0x03C0, 0x0C30, 0x1188, 
  0x27E4, 0x2FF4, 0x4FF2, 0x5FFA, 
  0x5FFA, 0x4FF2, 0x2FF4, 0x27E4, 
  0x1188, 0x0C30, 0x03C0, 0x0000
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,   2,  16,   0,   0, 0x0001,
  RSBB1DATA,   2,  16,   0,   0, 0x0001,
  RSBB2DATA,   2,  16,   0,   0, 0x0001,
  RSBB3DATA,   2,  16,   0,   0, 0x0001
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 MAIN ****************************************************/
        -1, M_TITLE ,       17, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1149L,
  0x0000, 0x0000, 0x0020, 0x000B,
         2,       -1,       -1, G_BOXTEXT ,   /* Object 1 M_TITLE */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x0000, 0x0020, 0x0B00,
  M_SETUP , M_COMPOSE, M_ALTNNN, G_BOX     ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0C00, 0x0010, 0x0C04,
  M_DEADKEY,       -1,       -1, G_BUTTON  |0x0100,   /* Object 3 M_COMPOSE */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"Compose",
  0x0001, 0x0400, 0x000E, 0x0001,
  M_EXTKEY,       -1,       -1, G_BUTTON  |0x0100,   /* Object 4 M_DEADKEY */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"Deadkey",
  0x0001, 0x0501, 0x000E, 0x0001,
  M_ALTNNN,       -1,       -1, G_BUTTON  |0x0100,   /* Object 5 M_EXTKEY */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"Extkey",
  0x0001, 0x0602, 0x000E, 0x0001,
         2,       -1,       -1, G_BUTTON  |0x0100,   /* Object 6 M_ALTNNN */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"ALT-<nnn>",
  0x0001, 0x0703, 0x000E, 0x0001,
  M_LANGTITLE,       -1,       -1, G_BUTTON  ,   /* Object 7 M_SETUP */
  SELECTABLE|EXIT, NORMAL, (LONG)"?",
  0x0011, 0x0201, 0x000E, 0x0001,
  M_LANGUAGE,       -1,       -1, G_BUTTON  ,   /* Object 8 M_LANGTITLE */
  NONE, NORMAL, (LONG)"?",
  0x0110, 0x0A02, 0x070F, 0x0001,
        10,       -1,       -1, G_BOXTEXT ,   /* Object 9 M_LANGUAGE */
  TOUCHEXIT, SHADOWED, (LONG)&rs_tedinfo[1],
  0x0011, 0x0204, 0x000E, 0x0001,
        15, M_TABLEACTIVE, M_TABNAME, G_BOX     ,   /* Object 10  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0905, 0x0020, 0x0603,
  M_TABVALID,       -1,       -1, G_BOXTEXT ,   /* Object 11 M_TABLEACTIVE */
  TOUCHEXIT, SHADOWED, (LONG)&rs_tedinfo[2],
  0x000D, 0x0002, 0x0012, 0x0001,
  M_USEDTABLE,       -1,       -1, G_STRING  ,   /* Object 12 M_TABVALID */
  NONE, NORMAL, (LONG)"?",
  0x0001, 0x0002, 0x000B, 0x0001,
  M_TABNAME,       -1,       -1, G_BOXTEXT ,   /* Object 13 M_USEDTABLE */
  TOUCHEXIT, SHADOWED, (LONG)&rs_tedinfo[3],
  0x000D, 0x0800, 0x0012, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 14 M_TABNAME */
  NONE, NORMAL, (LONG)"?",
  0x0001, 0x0800, 0x000B, 0x0001,
        17, M_SAVE  , M_SAVE  , G_BOX     ,   /* Object 15  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0109, 0x020A, 0x0F01,
        15,       -1,       -1, G_BUTTON  ,   /* Object 16 M_SAVE */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"?",
  0x0101, 0x0700, 0x0008, 0x0001,
         0, M_OK    , M_ABORT , G_BOX     ,   /* Object 17  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x040A, 0x0109, 0x0415, 0x0F01,
  M_ABORT ,       -1,       -1, G_BUTTON  ,   /* Object 18 M_OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"?",
  0x0301, 0x0700, 0x0008, 0x0001,
        17,       -1,       -1, G_BUTTON  ,   /* Object 19 M_ABORT */
  SELECTABLE|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"?",
  0x000C, 0x0700, 0x0008, 0x0001,
  
  /******** Tree 1 CC_CFG ****************************************************/
        -1,        1, C_CCCTITLE, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1141L,
  0x0000, 0x0000, 0x0020, 0x000B,
        16, C_CMODE ,       15, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0F00, 0x0020, 0x0008,
  C_COMPMODE,       -1,       -1, G_STRING  ,   /* Object 2 C_CMODE */
  NONE, NORMAL, (LONG)"?",
  0x0001, 0x0800, 0x0010, 0x0001,
  C_CORDER,       -1,       -1, G_BOXTEXT ,   /* Object 3 C_COMPMODE */
  TOUCHEXIT, SHADOWED, (LONG)&rs_tedinfo[4],
  0x0012, 0x0800, 0x000C, 0x0001,
  C_COMPORDER,       -1,       -1, G_STRING  ,   /* Object 4 C_CORDER */
  NONE, NORMAL, (LONG)"?",
  0x0001, 0x0002, 0x0010, 0x0001,
  C_DELAY ,       -1,       -1, G_BOXTEXT ,   /* Object 5 C_COMPORDER */
  TOUCHEXIT, SHADOWED, (LONG)&rs_tedinfo[5],
  0x0012, 0x0002, 0x000C, 0x0001,
  C_TIMEOUT,       -1,       -1, G_STRING  ,   /* Object 6 C_DELAY */
  NONE, NORMAL, (LONG)"?",
  0x0001, 0x0004, 0x000C, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7 C_TIMEOUT */
  NONE, NORMAL, (LONG)"?",
  0x0001, 0x0805, 0x000C, 0x0001,
         9,       -1,       -1, G_BOX     ,   /* Object 8  */
  NONE, NORMAL, (LONG)0x00FF1111L,
  0x0010, 0x0004, 0x000C, 0x0001,
        10,       -1,       -1, G_BOXCHAR ,   /* Object 9  */
  NONE, NORMAL, (LONG) ((LONG)'\004' << 24)|0x00FF1100L,
  0x000E, 0x0004, 0x0002, 0x0001,
        11,       -1,       -1, G_BOXCHAR ,   /* Object 10  */
  NONE, NORMAL, (LONG) ((LONG)'\003' << 24)|0x00FF1100L,
  0x001C, 0x0004, 0x0002, 0x0001,
        12,       -1,       -1, G_BUTTON  ,   /* Object 11  */
  SELECTABLE, NORMAL, (LONG)"0.00",
  0x0011, 0x0004, 0x0005, 0x0001,
        13,       -1,       -1, G_BOXCHAR ,   /* Object 12  */
  NONE, NORMAL, (LONG) ((LONG)'\004' << 24)|0x00FF1100L,
  0x000E, 0x0805, 0x0002, 0x0001,
        14,       -1,       -1, G_BOX     ,   /* Object 13  */
  NONE, NORMAL, (LONG)0x00FF1111L,
  0x0010, 0x0805, 0x000C, 0x0001,
        15,       -1,       -1, G_BOXCHAR ,   /* Object 14  */
  NONE, NORMAL, (LONG) ((LONG)'\003' << 24)|0x00FF1100L,
  0x001C, 0x0805, 0x0002, 0x0001,
         1,       -1,       -1, G_BUTTON  ,   /* Object 15  */
  SELECTABLE, NORMAL, (LONG)"0.00",
  0x0011, 0x0805, 0x0005, 0x0001,
        17,       23,       21, G_BOX     ,   /* Object 16  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0109, 0x020A, 0x0F01,
  C_CCCTITLE, C_OK    , C_ABORT , G_BOX     ,   /* Object 17  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x040A, 0x0109, 0x0415, 0x0F01,
  C_ABORT ,       -1,       -1, G_BUTTON  ,   /* Object 18 C_OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"?",
  0x0301, 0x0700, 0x0008, 0x0001,
        17,       -1,       -1, G_BUTTON  ,   /* Object 19 C_ABORT */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"?",
  0x000C, 0x0700, 0x0008, 0x0001,
         0,       -1,       -1, G_BOXTEXT ,   /* Object 20 C_CCCTITLE */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0000, 0x0000, 0x0020, 0x0E00,
        16,       -1,       -1, G_TEXT    ,   /* Object 21  */
  NONE, NORMAL, (LONG)&rs_tedinfo[7],
  0x0001, 0x0300, 0x0208, 0x0800,
        21,       -1,       -1, G_TEXT    ,   /* Object 22  */
  NONE, NORMAL, (LONG)&rs_tedinfo[8],
  0x0001, 0x0B00, 0x0404, 0x0800,
        22,       -1,       -1, G_TEXT    ,   /* Object 23  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[9],
  0x0001, 0x0301, 0x0606, 0x0800,
  
  /******** Tree 2 DK_CFG ****************************************************/
        -1,        1,        9, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1141L,
  0x0000, 0x0000, 0x0020, 0x000B,
         5,        2,        4, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0109, 0x020A, 0x0F01,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[10],
  0x0001, 0x0301, 0x0606, 0x0800,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[11],
  0x0001, 0x0B00, 0x0404, 0x0800,
         1,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[12],
  0x0001, 0x0300, 0x0208, 0x0800,
  C_DKTITLE, D_OK    , D_ABORT , G_BOX     ,   /* Object 5  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x040A, 0x0109, 0x0415, 0x0F01,
  D_ABORT ,       -1,       -1, G_BUTTON  ,   /* Object 6 D_OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"?",
  0x0301, 0x0700, 0x0008, 0x0001,
         5,       -1,       -1, G_BUTTON  ,   /* Object 7 D_ABORT */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"?",
  0x000C, 0x0700, 0x0008, 0x0001,
         9,       -1,       -1, G_BOXTEXT ,   /* Object 8 C_DKTITLE */
  NONE, NORMAL, (LONG)&rs_tedinfo[13],
  0x0000, 0x0000, 0x0020, 0x0E00,
         0, C_VALIDKEYS, C_DEADKEYS, G_BOX     ,   /* Object 9  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0801, 0x0020, 0x0703,
  C_DEADKEYS,       -1,       -1, G_STRING  ,   /* Object 10 C_VALIDKEYS */
  NONE, NORMAL, (LONG)"?",
  0x0001, 0x0800, 0x001E, 0x0001,
         9,       -1,       -1, G_FBOXTEXT,   /* Object 11 C_DEADKEYS */
  EDITABLE|LASTOB, NORMAL, (LONG)&rs_tedinfo[14],
  0x0001, 0x0002, 0x061D, 0x0201,
  
  /******** Tree 3 IMAGES ****************************************************/
        -1, SELBUTTON_NORM, RADIOBUT_SEL, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0010, 0x0003,
  SELBUTTON_SELECT,       -1,       -1, G_IMAGE   ,   /* Object 1 SELBUTTON_NORM */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[0],
  0x0002, 0x0001, 0x0002, 0x0001,
  RADIOBUT_NORM,       -1,       -1, G_IMAGE   ,   /* Object 2 SELBUTTON_SELECT */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[1],
  0x0005, 0x0001, 0x0002, 0x0001,
  RADIOBUT_SEL,       -1,       -1, G_IMAGE   ,   /* Object 3 RADIOBUT_NORM */
  TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[2],
  0x0009, 0x0001, 0x0002, 0x0001,
         0,       -1,       -1, G_IMAGE   ,   /* Object 4 RADIOBUT_SEL */
  LASTOB|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[3],
  0x000C, 0x0001, 0x0002, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MAIN     */
  &rs_object[20],   /* Tree  1 CC_CFG   */
  &rs_object[44],   /* Tree  2 DK_CFG   */
  &rs_object[56]    /* Tree  3 IMAGES   */
};
