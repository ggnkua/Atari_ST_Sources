/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "STD.H"

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
{ " DSP!",
  "\0",
  "\0",
  IBM  , 0, TE_RIGHT, 0x1280, 0, -1, 6, 1,
  "                    texte 1                       ",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 51, 1,
  "                    texte 2                       ",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 51, 1,
  "                    texte 3                       ",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 51, 1,
  "0%",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, 0, 3, 1,
  "100%",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1180, 0, 0, 5, 1,
  "000",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1180, 0, 0, 4, 1,
  "%",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, 0, 2, 1,
  " 030!",
  "\0",
  "\0",
  IBM  , 0, TE_RIGHT, 0x1280, 0, -1, 6, 1,
  "    001/100       ",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 19, 1,
  "FPU!",
  "\0",
  "\0",
  IBM  , 0, TE_RIGHT, 0x1280, 0, -1, 5, 1,
  "12:34(012h40m)",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1180, 0, -1, 15, 1,
  "texte1             ",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 20, 1,
  "0123456789abcdefghijk",
  "_____________________",
  "XXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 22, 22,
  "\0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
  "_________________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 66, 66,
  "\0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
  "_________________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 66, 66,
  "\0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
  "_________________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 66, 66,
  "\0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
  "_________________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 66, 66,
  "\0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
  "_________________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 66, 66,
  "\0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
  "_________________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 66, 66,
  "\0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
  "_________________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 66, 66,
  "\0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000",
  "_________________________________________________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 66, 66,
  "      Find Pattern       ",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 26, 1,
  "Hexadecimal data:      ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 24, 1,
  "________________________",
  "________________________",
  "NNNNNNNNNNNNNNNNNNNNNNNN",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 25, 25,
  "ASCII string:",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 14, 1,
  "________________________\000\000\000",
  "___________________________",
  "XXXXXXXXXXXXXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 28, 28,
  "Case sensitive           ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 26, 1,
  "Count              ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  "Wrap around",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 12, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 FORM_PROG ****************************************************/
        -1, PROG_DSPON, PROG_REMAIN, G_BOX     ,   /* Object 0  */
  FLAGS9, NORMAL, (LONG)0x00011100L,
  0x0000, 0x0000, 0x0028, 0x0005,
  PROG_TITRE1,       -1,       -1, G_TEXT    ,   /* Object 1 PROG_DSPON */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[0],
  0x0422, 0x0800, 0x0005, 0x0001,
  PROG_TITRE2,       -1,       -1, G_TEXT    ,   /* Object 2 PROG_TITRE1 */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x0001, 0x0801, 0x0426, 0x0600,
  PROG_TITRE3,       -1,       -1, G_TEXT    ,   /* Object 3 PROG_TITRE2 */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[2],
  0x0001, 0x0002, 0x0426, 0x0600,
  PROG_TOTALPC,       -1,       -1, G_TEXT    ,   /* Object 4 PROG_TITRE3 */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[3],
  0x0001, 0x0802, 0x0426, 0x0600,
         7, PROG_PC , PROG_PC , G_BOX     ,   /* Object 5 PROG_TOTALPC */
  FLAGS10, NORMAL, (LONG)0x00FE1181L,
  0x0001, 0x0803, 0x0426, 0x0800,
  PROG_TOTALPC,       -1,       -1, G_BOX     ,   /* Object 6 PROG_PC */
  NONE, NORMAL, (LONG)0x00001174L,
  0x0000, 0x0000, 0x041F, 0x0800,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[4],
  0x0001, 0x0804, 0x0401, 0x0800,
  PROG_TPC,       -1,       -1, G_TEXT    ,   /* Object 8  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[5],
  0x0424, 0x0804, 0x0003, 0x0800,
        10,       -1,       -1, G_TEXT    ,   /* Object 9 PROG_TPC */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[6],
  0x0012, 0x0804, 0x0202, 0x0800,
  PROG_030,       -1,       -1, G_TEXT    ,   /* Object 10  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[7],
  0x0414, 0x0804, 0x0600, 0x0800,
  PROG_TPCTXT,       -1,       -1, G_TEXT    ,   /* Object 11 PROG_030 */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[8],
  0x0400, 0x0800, 0x0005, 0x0001,
  PROG_FPU,       -1,       -1, G_TEXT    ,   /* Object 12 PROG_TPCTXT */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[9],
  0x040D, 0x0003, 0x040D, 0x0600,
  PROG_REMAIN,       -1,       -1, G_TEXT    ,   /* Object 13 PROG_FPU */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[10],
  0x0412, 0x0800, 0x0005, 0x0001,
         0,       -1,       -1, G_TEXT    ,   /* Object 14 PROG_REMAIN */
  LASTOB|FLAGS10, NORMAL, (LONG)&rs_tedinfo[11],
  0x041C, 0x0E02, 0x020B, 0x0600,
  
  /******** Tree 1 FORM_INPUT ****************************************************/
        -1, INPUT_TITLE, INPUT_CANCEL, G_BOX     ,   /* Object 0  */
  FLAGS9, NORMAL, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0417, 0x0008,
  INPUT_TEXT,       -1,       -1, G_TEXT    ,   /* Object 1 INPUT_TITLE */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[12],
  0x0002, 0x0001, 0x0013, 0x0001,
  INPUT_OK,       -1,       -1, G_FTEXT   ,   /* Object 2 INPUT_TEXT */
  NONE, OUTLINED, (LONG)&rs_tedinfo[13],
  0x0401, 0x0003, 0x0015, 0x0001,
  INPUT_CANCEL,       -1,       -1, G_BUTTON  ,   /* Object 3 INPUT_OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x0002, 0x0006, 0x0008, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 4 INPUT_CANCEL */
  SELECTABLE|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)" Annuler ",
  0x000D, 0x0006, 0x0009, 0x0001,
  
  /******** Tree 2 FORM_MLINES ****************************************************/
        -1, MLINES_FIRSTMSG, MLINES_TEMPLATES, G_BOX     ,   /* Object 0  */
  FLAGS9, NORMAL, (LONG)0x00011100L,
  0x0000, 0x0000, 0x0442, 0x080A,
         2,       -1,       -1, G_FTEXT   ,   /* Object 1 MLINES_FIRSTMSG */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[14],
  0x0400, 0x0800, 0x0041, 0x0001,
         3,       -1,       -1, G_FTEXT   ,   /* Object 2  */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[15],
  0x0400, 0x0801, 0x0041, 0x0001,
         4,       -1,       -1, G_FTEXT   ,   /* Object 3  */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[16],
  0x0400, 0x0802, 0x0041, 0x0001,
         5,       -1,       -1, G_FTEXT   ,   /* Object 4  */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[17],
  0x0400, 0x0803, 0x0041, 0x0001,
         6,       -1,       -1, G_FTEXT   ,   /* Object 5  */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[18],
  0x0400, 0x0804, 0x0041, 0x0001,
         7,       -1,       -1, G_FTEXT   ,   /* Object 6  */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[19],
  0x0400, 0x0805, 0x0041, 0x0001,
  MLINES_LASTMSG,       -1,       -1, G_FTEXT   ,   /* Object 7  */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[20],
  0x0400, 0x0806, 0x0041, 0x0001,
  MLINES_OK,       -1,       -1, G_FTEXT   ,   /* Object 8 MLINES_LASTMSG */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[21],
  0x0400, 0x0807, 0x0041, 0x0001,
  MLINES_CANCEL,       -1,       -1, G_BUTTON  ,   /* Object 9 MLINES_OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x0409, 0x0E08, 0x0408, 0x0001,
  MLINES_TEMPLATES,       -1,       -1, G_BUTTON  ,   /* Object 10 MLINES_CANCEL */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)" Annuler ",
  0x0033, 0x0F08, 0x0009, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 11 MLINES_TEMPLATES */
  SELECTABLE|LASTOB|TOUCHEXIT|FLAGS9|FLAGS10, NORMAL, (LONG)" Templates... ",
  0x041C, 0x0E08, 0x000E, 0x0001,
  
  /******** Tree 3 FORM_SPATTERN ****************************************************/
        -1, SP_TITLE, SP_WRAPAROUND, G_BOX     ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0021, 0x080C,
  SP_HEXLABEL,       -1,       -1, G_TEXT    ,   /* Object 1 SP_TITLE */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[22],
  0x0004, 0x0800, 0x0019, 0x0001,
  SP_HEX  ,       -1,       -1, G_TEXT    ,   /* Object 2 SP_HEXLABEL */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[23],
  0x0004, 0x0002, 0x0018, 0x0001,
  SP_HEXT ,       -1,       -1, G_BOX     ,   /* Object 3 SP_HEX */
  SELECTABLE, SELECTED, (LONG)0x00FF1100L,
  0x0401, 0x0802, 0x0001, 0x0800,
  SP_STRLABEL,       -1,       -1, G_FTEXT   ,   /* Object 4 SP_HEXT */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[24],
  0x0004, 0x0003, 0x0018, 0x0001,
  SP_STRING,       -1,       -1, G_TEXT    ,   /* Object 5 SP_STRLABEL */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[25],
  0x0004, 0x0A04, 0x000D, 0x0001,
  SP_STRT ,       -1,       -1, G_BOX     ,   /* Object 6 SP_STRING */
  SELECTABLE, NORMAL, (LONG)0x00FF1100L,
  0x0401, 0x0005, 0x0001, 0x0800,
  SP_STRCAPS,       -1,       -1, G_FTEXT   ,   /* Object 7 SP_STRT */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[26],
  0x0004, 0x0805, 0x001B, 0x0001,
  SP_BSTRCAPS,       -1,       -1, G_TEXT    ,   /* Object 8 SP_STRCAPS */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[27],
  0x0006, 0x0C06, 0x0019, 0x0001,
  SP_COUNT,       -1,       -1, G_BOX     ,   /* Object 9 SP_BSTRCAPS */
  SELECTABLE, NORMAL, (LONG)0x00FF1100L,
  0x0004, 0x0007, 0x0001, 0x0800,
  SP_BCOUNT,       -1,       -1, G_TEXT    ,   /* Object 10 SP_COUNT */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[28],
  0x0403, 0x0E07, 0x0013, 0x0001,
  SP_OK   ,       -1,       -1, G_BOX     ,   /* Object 11 SP_BCOUNT */
  SELECTABLE, NORMAL, (LONG)0x00FF1100L,
  0x0401, 0x0208, 0x0001, 0x0800,
  SP_CANCEL,       -1,       -1, G_BUTTON  ,   /* Object 12 SP_OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x0404, 0x000B, 0x000B, 0x0001,
  SP_BWRAPAROUND,       -1,       -1, G_BUTTON  ,   /* Object 13 SP_CANCEL */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"   Cancel   ",
  0x0412, 0x000B, 0x000C, 0x0001,
  SP_WRAPAROUND,       -1,       -1, G_BOX     ,   /* Object 14 SP_BWRAPAROUND */
  SELECTABLE, NORMAL, (LONG)0x00FF1100L,
  0x0401, 0x0809, 0x0001, 0x0800,
         0,       -1,       -1, G_TEXT    ,   /* Object 15 SP_WRAPAROUND */
  LASTOB|FLAGS10, NORMAL, (LONG)&rs_tedinfo[29],
  0x0004, 0x0209, 0x000B, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 FORM_PROG */
  &rs_object[15],   /* Tree  1 FORM_INPUT */
  &rs_object[20],   /* Tree  2 FORM_MLINES */
  &rs_object[32]    /* Tree  3 FORM_SPATTERN */
};
