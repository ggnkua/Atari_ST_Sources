/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "EGLIBTST.H"

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

static  TEDINFO rs_tedinfo[] =
{ "EGlib DEMO",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -1, 11, 1,
  "Programme de d\202monstration",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 27, 1,
  "de la biblioth\212que GEM",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 23, 1,
  "fmanomxxxx",
  "Nom:    __________",
  "XXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 11, 19,
  "fmaprenomx",
  "Pr\202nom: __________",
  "XXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 11, 19,
  "aG",
  "Age:    __",
  "99",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 3, 11
};

static  OBJECT rs_object[] =
{ 
  /******** Tree 0 FINFO ****************************************************/
        -1,        1,        3, G_BOX             ,   /* Object 0  */
  NONE, WHITEBAK, (LONG)0x00FF1180L,
  0x0000, 0x0000, 0x0022, 0x0008,
         3,        2,        2, G_IBOX            ,   /* Object 1  */
  NONE, DRAW3D|WHITEBAK, (LONG)0x00FF1100L,
  0x0001, 0x0001, 0x0020, 0x0003,
         1,       -1,       -1, G_TEXT            |0x1800,   /* Object 2  */
  NONE, STATE10|STATE13, (LONG)&rs_tedinfo[0],
  0x0001, 0x0000, 0x001E, 0x0003,
         0,        4,        5, G_IBOX            ,   /* Object 3  */
  NONE, DRAW3D|WHITEBAK, (LONG)0x00FF1100L,
  0x0001, 0x0005, 0x0020, 0x0002,
         5,       -1,       -1, G_TEXT            ,   /* Object 4  */
  NONE, WHITEBAK, (LONG)&rs_tedinfo[1],
  0x0001, 0x0000, 0x001E, 0x0001,
         3,       -1,       -1, G_TEXT            ,   /* Object 5  */
  LASTOB, WHITEBAK, (LONG)&rs_tedinfo[2],
  0x0001, 0x0001, 0x001E, 0x0001,
  
  /******** Tree 1 PINFO ****************************************************/
        -1, PMAIN           , PQUIT           , G_BOX             ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x000C, 0x0004,
  PLIB            ,       -1,       -1, G_STRING          ,   /* Object 1 PMAIN */
  SELECTABLE, NORMAL, (LONG)"  Open Main",
  0x0000, 0x0000, 0x000C, 0x0001,
         3,       -1,       -1, G_STRING          ,   /* Object 2 PLIB */
  SELECTABLE, NORMAL, (LONG)"  EGlib",
  0x0000, 0x0001, 0x000C, 0x0001,
  PQUIT           ,       -1,       -1, G_STRING          ,   /* Object 3  */
  NONE, DISABLED, (LONG)"------------",
  0x0000, 0x0002, 0x000C, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 4 PQUIT */
  SELECTABLE|LASTOB, NORMAL, (LONG)"  Quit",
  0x0000, 0x0003, 0x000C, 0x0001,
  
  /******** Tree 2 MENU ****************************************************/
        -1,        1,        5, G_IBOX            ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         5,        2,        2, G_BOX             ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1,        3,        4, G_IBOX            ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x000C, 0x0301,
         4,       -1,       -1, G_TITLE           ,   /* Object 3  */
  NONE, NORMAL, (LONG)" Test",
  0x0000, 0x0000, 0x0006, 0x0301,
         2,       -1,       -1, G_TITLE           ,   /* Object 4  */
  NONE, NORMAL, (LONG)" File",
  0x0006, 0x0000, 0x0006, 0x0301,
         0,        6,       15, G_IBOX            ,   /* Object 5  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0017,
        15, MINFO           ,       14, G_BOX             ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0013, 0x0008,
         8,       -1,       -1, G_STRING          ,   /* Object 7 MINFO */
  NONE, NORMAL, (LONG)"  Informations  ^I ",
  0x0000, 0x0000, 0x0013, 0x0001,
         9,       -1,       -1, G_STRING          ,   /* Object 8  */
  NONE, DISABLED, (LONG)"-------------------",
  0x0000, 0x0001, 0x0013, 0x0001,
        10,       -1,       -1, G_STRING          ,   /* Object 9  */
  NONE, NORMAL, (LONG)"  Accessory 1  ",
  0x0000, 0x0002, 0x0013, 0x0001,
        11,       -1,       -1, G_STRING          ,   /* Object 10  */
  NONE, NORMAL, (LONG)"  Accessory 2  ",
  0x0000, 0x0003, 0x0013, 0x0001,
        12,       -1,       -1, G_STRING          ,   /* Object 11  */
  NONE, NORMAL, (LONG)"  Accessory 3  ",
  0x0000, 0x0004, 0x0013, 0x0001,
        13,       -1,       -1, G_STRING          ,   /* Object 12  */
  NONE, NORMAL, (LONG)"  Accessory 4  ",
  0x0000, 0x0005, 0x0013, 0x0001,
        14,       -1,       -1, G_STRING          ,   /* Object 13  */
  NONE, NORMAL, (LONG)"  Accessory 5  ",
  0x0000, 0x0006, 0x0013, 0x0001,
         6,       -1,       -1, G_STRING          ,   /* Object 14  */
  NONE, NORMAL, (LONG)"  Accessory 6  ",
  0x0000, 0x0007, 0x0013, 0x0001,
         5, MMAIN           , MQUIT           , G_BOX             ,   /* Object 15  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0008, 0x0000, 0x0010, 0x0004,
  MLIB            ,       -1,       -1, G_STRING          ,   /* Object 16 MMAIN */
  NONE, NORMAL, (LONG)"  Open Main  ^O ",
  0x0000, 0x0000, 0x0010, 0x0001,
        18,       -1,       -1, G_STRING          ,   /* Object 17 MLIB */
  NONE, NORMAL, (LONG)"  Eglib      ^E ",
  0x0000, 0x0001, 0x0010, 0x0001,
  MQUIT           ,       -1,       -1, G_STRING          ,   /* Object 18  */
  NONE, DISABLED, (LONG)"----------------",
  0x0000, 0x0002, 0x0010, 0x0001,
        15,       -1,       -1, G_STRING          ,   /* Object 19 MQUIT */
  LASTOB, NORMAL, (LONG)"  Quit       ^Q ",
  0x0000, 0x0003, 0x0010, 0x0001,
  
  /******** Tree 3 POPUP ****************************************************/
        -1,        1,        4, G_BOX             ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0008, 0x0004,
         2,       -1,       -1, G_STRING          ,   /* Object 1  */
  SELECTABLE, NORMAL, (LONG)"  Atari",
  0x0000, 0x0000, 0x0008, 0x0001,
         3,       -1,       -1, G_STRING          ,   /* Object 2  */
  SELECTABLE, NORMAL, (LONG)"  Amiga",
  0x0000, 0x0001, 0x0008, 0x0001,
         4,       -1,       -1, G_STRING          ,   /* Object 3  */
  SELECTABLE, NORMAL, (LONG)"  PC",
  0x0000, 0x0002, 0x0008, 0x0001,
         0,       -1,       -1, G_STRING          ,   /* Object 4  */
  SELECTABLE|LASTOB, NORMAL, (LONG)"  Mac",
  0x0000, 0x0003, 0x0008, 0x0001,
  
  /******** Tree 4 FMAIN ****************************************************/
        -1,        1,       17, G_BOX             ,   /* Object 0  */
  NONE, WHITEBAK, (LONG)0x00FF1180L,
  0x0000, 0x0000, 0x0027, 0x0013,
        15,        2, FMAMCH          , G_IBOX            ,   /* Object 1  */
  NONE, DRAW3D|WHITEBAK, (LONG)0x00FF1180L,
  0x0001, 0x0001, 0x0025, 0x000D,
  FMANOM          ,        3,        6, G_IBOX            ,   /* Object 2  */
  NONE, OUTLINED|WHITEBAK, (LONG)0x00FC1180L,
  0x0001, 0x0001, 0x000E, 0x0006,
         4,       -1,       -1, G_BUTTON          |0x0100,   /* Object 3  */
  SELECTABLE, SELECTED|DRAW3D, (LONG)"BE[PC",
  0x0001, 0x0001, 0x000C, 0x0001,
         5,       -1,       -1, G_BUTTON          |0x0100,   /* Object 4  */
  SELECTABLE, SELECTED|DRAW3D, (LONG)"B[ac",
  0x0001, 0x0002, 0x000C, 0x0001,
         6,       -1,       -1, G_BUTTON          |0x0100,   /* Object 5  */
  SELECTABLE, SELECTED|DRAW3D, (LONG)"[DEUG",
  0x0001, 0x0003, 0x000C, 0x0001,
         2,       -1,       -1, G_BUTTON          |0x0100,   /* Object 6  */
  SELECTABLE, DRAW3D, (LONG)"[License",
  0x0001, 0x0004, 0x000C, 0x0001,
  FMAPRE          ,       -1,       -1, G_FBOXTEXT        ,   /* Object 7 FMANOM */
  EDITABLE, OUTLINED|WHITEBAK, (LONG)&rs_tedinfo[3],
  0x0011, 0x0001, 0x0013, 0x0001,
  FMAAGE          ,       -1,       -1, G_FBOXTEXT        ,   /* Object 8 FMAPRE */
  EDITABLE, DRAW3D, (LONG)&rs_tedinfo[4],
  0x0011, 0x0003, 0x0013, 0x0001,
        10,       -1,       -1, G_FBOXTEXT        ,   /* Object 9 FMAAGE */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0011, 0x0005, 0x0013, 0x0001,
        13,       11,       12, G_IBOX            ,   /* Object 10  */
  NONE, OUTLINED|WHITEBAK, (LONG)0x00FC1180L,
  0x0001, 0x0008, 0x000E, 0x0004,
        12,       -1,       -1, G_BUTTON          |0x0200,   /* Object 11  */
  SELECTABLE|RBUTTON, SELECTED|DRAW3D, (LONG)"[Homme",
  0x0001, 0x0001, 0x000C, 0x0001,
        10,       -1,       -1, G_BUTTON          |0x0200,   /* Object 12  */
  SELECTABLE|RBUTTON, DRAW3D, (LONG)"[Femme",
  0x0001, 0x0002, 0x000C, 0x0001,
  FMAMCH          ,       -1,       -1, G_STRING          ,   /* Object 13  */
  NONE, WHITEBAK, (LONG)"Machine:",
  0x0011, 0x0007, 0x0008, 0x0001,
         1,       -1,       -1, G_BUTTON          |0x0300,   /* Object 14 FMAMCH */
  SELECTABLE, DRAW3D, (LONG)"NMachine",
  0x001A, 0x0007, 0x000A, 0x0001,
        16,       -1,       -1, G_BUTTON          ,   /* Object 15  */
  SELECTABLE|DEFAULT, NORMAL, (LONG)"B[outon Normal",
  0x0002, 0x000F, 0x0010, 0x0001,
        17,       -1,       -1, G_BUTTON          ,   /* Object 16  */
  SELECTABLE|DEFAULT, WHITEBAK, (LONG)"Bou[ton Relief",
  0x0015, 0x000F, 0x0010, 0x0001,
         0,       -1,       -1, G_BUTTON          ,   /* Object 17  */
  SELECTABLE|DEFAULT|LASTOB, DRAW3D, (LONG)"Bouto[n en 3D",
  0x000B, 0x0011, 0x0010, 0x0001
};

static  OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 FINFO            */
  &rs_object[6],   /* Tree  1 PINFO            */
  &rs_object[11],   /* Tree  2 MENU             */
  &rs_object[31],   /* Tree  3 POPUP            */
  &rs_object[36]    /* Tree  4 FMAIN            */
};
