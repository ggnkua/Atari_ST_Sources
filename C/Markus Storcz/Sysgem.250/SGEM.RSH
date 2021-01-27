/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "SGEM.H"

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

static TEDINFO rs_tedinfo[] =
{ "12345678",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 9, 1,
  "------------------------------------",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 37, 1,
  "----------------------------------------",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "----------------------------------------",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "Abbruch mit ESC",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1180, 0, -1, 16, 1
};

static WORD RSBB0DATA[] =
{ 0x3FFF, 0xFFFC, 0x4000, 0x0002, 
  0x8000, 0x0001, 0x8000, 0x0001, 
  0x8000, 0x0005, 0x8000, 0x0005, 
  0x83FE, 0x0005, 0x8202, 0x0005, 
  0x83FE, 0x0005, 0x8202, 0x0005, 
  0x8202, 0x0005, 0x820F, 0xF005, 
  0x8208, 0x1005, 0x820F, 0xF005, 
  0x8208, 0x1005, 0x8208, 0x1005, 
  0x8208, 0x1005, 0x8208, 0x7E05, 
  0x8208, 0x4205, 0x8208, 0x7E05, 
  0x83F8, 0x4205, 0x8008, 0x4205, 
  0x800F, 0xC7C5, 0x8000, 0x4445, 
  0x8000, 0x7C45, 0x8000, 0x0445, 
  0x8000, 0x07C5, 0x8000, 0x0005, 
  0x8000, 0x0005, 0x8FFF, 0xFFF9, 
  0x4000, 0x0002, 0x3FFF, 0xFFFC
};

static BITBLK rs_bitblk[] =
{ RSBB0DATA,   4,  32,   0,   0, 0x0001
};

static OBJECT rs_object[] =
{ 
  /******** Tree 0 MAIN_ICON ****************************************************/
        -1, IC_BX           , IC_BX           , G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0015, 0x0807,
         0, IC_IC           , IC_TX           , G_IBOX            ,   /* Object 1 IC_BX */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0007, 0x0002, 0x0006, 0x0A02,
  IC_TX           ,       -1,       -1, G_IMAGE           ,   /* Object 2 IC_IC */
  NONE, NORMAL, (LONG)&rs_bitblk[0],
  0x0001, 0x0000, 0x0004, 0x0002,
  IC_BX           ,       -1,       -1, G_TEXT            ,   /* Object 3 IC_TX */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x0202, 0x0006, 0x0800,
  
  /******** Tree 1 MAIN_TREE ****************************************************/
        -1, MA_BOX          , MA_DN           , G_BOX             ,   /* Object 0 MA_MAIN */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0434, 0x0008,
  MA_UP           ,       -1,       -1, G_BOX             |0x0700,   /* Object 1 MA_BOX */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0000, 0x0028, 0x0008,
  MA_HIDE         ,       -1,       -1, G_BOXCHAR         |0x0A00,   /* Object 2 MA_UP */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'\001' << 24)|0x00FF1100L,
  0x0428, 0x0000, 0x0002, 0x0001,
  MA_DN           , MA_SHOW         , MA_SHOW         , G_BOX             |0x0900,   /* Object 3 MA_HIDE */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0428, 0x0801, 0x0002, 0x0005,
  MA_HIDE         ,       -1,       -1, G_BOX             |0x0800,   /* Object 4 MA_SHOW */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0001, 0x0002, 0x0002,
  MA_MAIN         ,       -1,       -1, G_BOXCHAR         |0x0700,   /* Object 5 MA_DN */
  LASTOB|TOUCHEXIT, NORMAL, (LONG) ((LONG)'\002' << 24)|0x00FF1100L,
  0x0428, 0x0007, 0x0002, 0x0001,
  
  /******** Tree 2 MSG ****************************************************/
        -1, MS_TXT          , MS_TXT          , G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0027, 0x0002,
         0,       -1,       -1, G_TEXT            ,   /* Object 1 MS_TXT */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[1],
  0x0401, 0x0800, 0x0024, 0x0001,
  
  /******** Tree 3 CYCLE ****************************************************/
        -1, CY_BOX          , CY_OK           , G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x042F, 0x080A,
  CY_UP           ,       -1,       -1, G_BOX             |0x0700,   /* Object 1 CY_BOX */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0401, 0x0001, 0x002A, 0x0007,
  CY_HIDE         ,       -1,       -1, G_BOXCHAR         |0x0A00,   /* Object 2 CY_UP */
  NONE, NORMAL, (LONG) ((LONG)'C' << 24)|0x00FF1100L,
  0x002C, 0x0001, 0x0002, 0x0001,
  CY_DN           , CY_SHOW         , CY_SHOW         , G_BOX             |0x0900,   /* Object 3 CY_HIDE */
  NONE, NORMAL, (LONG)0x00FF1111L,
  0x002C, 0x0802, 0x0002, 0x0004,
  CY_HIDE         ,       -1,       -1, G_BOX             |0x0800,   /* Object 4 CY_SHOW */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0800, 0x0002, 0x0002,
  CY_ABORT        ,       -1,       -1, G_BOXCHAR         |0x0700,   /* Object 5 CY_DN */
  NONE, NORMAL, (LONG) ((LONG)'C' << 24)|0x00FF1100L,
  0x002C, 0x0007, 0x0002, 0x0001,
  CY_OK           ,       -1,       -1, G_BUTTON          ,   /* Object 6 CY_ABORT */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"[Abbruch",
  0x0401, 0x0009, 0x0009, 0x0001,
         0,       -1,       -1, G_BUTTON          ,   /* Object 7 CY_OK */
  SELECTABLE|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"[OK",
  0x0025, 0x0009, 0x0009, 0x0001,
  
  /******** Tree 4 FONTSEL ****************************************************/
        -1, FO_FBOX         , FO_OK           , G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0442, 0x0811,
  FO_BOX          ,       -1,       -1, G_BOX             |0x0700,   /* Object 1 FO_FBOX */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0401, 0x0001, 0x043F, 0x0005,
  FO_UP           ,       -1,       -1, G_BOX             |0x0700,   /* Object 2 FO_BOX */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0401, 0x0806, 0x002A, 0x0008,
  FO_BOX3         ,       -1,       -1, G_BOXCHAR         |0x0C00,   /* Object 3 FO_UP */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'\001' << 24)|0x00FF1100L,
  0x002C, 0x0806, 0x0002, 0x0001,
  FO_UP3          ,       -1,       -1, G_BOX             |0x0700,   /* Object 4 FO_BOX3 */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0031, 0x0806, 0x0004, 0x0008,
  FO_BOX2         ,       -1,       -1, G_BOXCHAR         |0x0C00,   /* Object 5 FO_UP3 */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'\001' << 24)|0x00FF1100L,
  0x0435, 0x0806, 0x0002, 0x0001,
  FO_UP2          ,       -1,       -1, G_BOX             |0x0700,   /* Object 6 FO_BOX2 */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x043A, 0x0806, 0x0004, 0x0008,
  FO_HIDE         ,       -1,       -1, G_BOXCHAR         |0x0C00,   /* Object 7 FO_UP2 */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'\001' << 24)|0x00FF1100L,
  0x003F, 0x0806, 0x0002, 0x0001,
  FO_HIDE3        , FO_SHOW         , FO_SHOW         , G_BOX             |0x0900,   /* Object 8 FO_HIDE */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x002C, 0x0008, 0x0002, 0x0005,
  FO_HIDE         ,       -1,       -1, G_BOX             |0x0800,   /* Object 9 FO_SHOW */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0001, 0x0002, 0x0002,
  FO_HIDE2        , FO_SHOW3        , FO_SHOW3        , G_BOX             |0x0900,   /* Object 10 FO_HIDE3 */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x0435, 0x0008, 0x0002, 0x0005,
  FO_HIDE3        ,       -1,       -1, G_BOX             |0x0800,   /* Object 11 FO_SHOW3 */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0001, 0x0002, 0x0002,
  FO_DN           , FO_SHOW2        , FO_SHOW2        , G_BOX             |0x0900,   /* Object 12 FO_HIDE2 */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1111L,
  0x003F, 0x0008, 0x0002, 0x0005,
  FO_HIDE2        ,       -1,       -1, G_BOX             |0x0800,   /* Object 13 FO_SHOW2 */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0001, 0x0002, 0x0002,
  FO_DN3          ,       -1,       -1, G_BOXCHAR         |0x0C00,   /* Object 14 FO_DN */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'\002' << 24)|0x00FF1100L,
  0x002C, 0x080D, 0x0002, 0x0001,
  FO_DN2          ,       -1,       -1, G_BOXCHAR         |0x0C00,   /* Object 15 FO_DN3 */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'\002' << 24)|0x00FF1100L,
  0x0435, 0x080D, 0x0002, 0x0001,
  FO_HELP         ,       -1,       -1, G_BOXCHAR         |0x0C00,   /* Object 16 FO_DN2 */
  TOUCHEXIT, NORMAL, (LONG) ((LONG)'\002' << 24)|0x00FF1100L,
  0x003F, 0x080D, 0x0002, 0x0001,
  FO_SYSTEM       ,       -1,       -1, G_BUTTON          |0x0200,   /* Object 17 FO_HELP */
  SELECTABLE|FLAGS9|FLAGS10, NORMAL, (LONG)"HILFE",
  0x0401, 0x080F, 0x0007, 0x0001,
  FO_ABORT        ,       -1,       -1, G_BUTTON          ,   /* Object 18 FO_SYSTEM */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Sys[tem",
  0x0023, 0x080F, 0x0009, 0x0001,
  FO_OK           ,       -1,       -1, G_BUTTON          ,   /* Object 19 FO_ABORT */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"[Abbruch",
  0x042D, 0x080F, 0x0009, 0x0001,
         0,       -1,       -1, G_BUTTON          ,   /* Object 20 FO_OK */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"[OK",
  0x0038, 0x080F, 0x0009, 0x0001,
  
  /******** Tree 5 STATUS ****************************************************/
        -1, ST_TXT1         , ST_ESC          , G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x002A, 0x0805,
  ST_TXT2         ,       -1,       -1, G_TEXT            ,   /* Object 1 ST_TXT1 */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0001, 0x0800, 0x0028, 0x0001,
  ST_HIDE         ,       -1,       -1, G_TEXT            ,   /* Object 2 ST_TXT2 */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0001, 0x0801, 0x0028, 0x0001,
  ST_ESC          , ST_SHOW         , ST_SHOW         , G_BOX             |0x3300,   /* Object 3 ST_HIDE */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0001, 0x0803, 0x0028, 0x0001,
  ST_HIDE         ,       -1,       -1, G_BOX             |0x3400,   /* Object 4 ST_SHOW */
  NONE, NORMAL, (LONG)0x00001172L,
  0x0000, 0x0000, 0x0008, 0x0001,
         0,       -1,       -1, G_TEXT            ,   /* Object 5 ST_ESC */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[4],
  0x040F, 0x0804, 0x020B, 0x0001
};

static OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MAIN_ICON        */
  &rs_object[4],   /* Tree  1 MAIN_TREE        */
  &rs_object[10],   /* Tree  2 MSG              */
  &rs_object[12],   /* Tree  3 CYCLE            */
  &rs_object[20],   /* Tree  4 FONTSEL          */
  &rs_object[41]    /* Tree  5 STATUS           */
};
