/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "COGITO.H"

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
{ "Einpacken",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 10, 1,
  "Auspacken",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 10, 1,
  "Inhalt",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 1,
  "Optionen",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 9, 1,
  " Parameter ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 12, 1,
  "???",
  "Packer   : ___",
  "xxx",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 4, 15,
  "________________",
  "Einpacken: ________________",
  "XXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 17, 28,
  "________________",
  "Auspacken: ________________",
  "XXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 17, 28,
  "________________",
  "Inhalt   : ________________",
  "XXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 17, 28,
  "???",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 4, 1,
  " Programm ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 11, 1,
  "________________",
  "Einpacken: ________________",
  "XXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 17, 28,
  "________________",
  "Auspacken: ________________",
  "XXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 17, 28,
  "________________",
  "Inhalt   : ________________",
  "XXXXXXXXXXXXXXXX",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 17, 28,
  "INFO",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1180, 0, -1, 5, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 PACKMENU ****************************************************/
        -1,        1,        6, G_IBOX    ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0000, 0x0050, 0x0019,
         6,        2,        2, G_BOX     ,   /* Object 1  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0050, 0x0201,
         1,        3,        5, G_IBOX    ,   /* Object 2  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0002, 0x0000, 0x0019, 0x0301,
         4,       -1,       -1, G_TITLE   ,   /* Object 3  */
  NONE, NORMAL, (LONG)" COGITO",
  0x0000, 0x0000, 0x0008, 0x0301,
         5,       -1,       -1, G_TITLE   ,   /* Object 4  */
  NONE, NORMAL, (LONG)" Datei",
  0x0008, 0x0000, 0x0007, 0x0301,
         2,       -1,       -1, G_TITLE   ,   /* Object 5  */
  NONE, NORMAL, (LONG)" Optionen",
  0x000F, 0x0000, 0x000A, 0x0301,
         0,        7,       20, G_IBOX    ,   /* Object 6  */
  NONE, NORMAL, (LONG)0x00000000L,
  0x0000, 0x0301, 0x0050, 0x0017,
        16, MENUABOUT,       15, G_BOX     ,   /* Object 7  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x0002, 0x0000, 0x0014, 0x0008,
         9,       -1,       -1, G_STRING  ,   /* Object 8 MENUABOUT */
  NONE, NORMAL, (LONG)"  Cogito Info... ^I ",
  0x0000, 0x0000, 0x0014, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, DISABLED, (LONG)"--------------------",
  0x0000, 0x0001, 0x0014, 0x0001,
        11,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"  Desk Accessory 1 ",
  0x0000, 0x0002, 0x0014, 0x0001,
        12,       -1,       -1, G_STRING  ,   /* Object 11  */
  NONE, NORMAL, (LONG)"  Desk Accessory 2 ",
  0x0000, 0x0003, 0x0014, 0x0001,
        13,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"  Desk Accessory 3 ",
  0x0000, 0x0004, 0x0014, 0x0001,
        14,       -1,       -1, G_STRING  ,   /* Object 13  */
  NONE, NORMAL, (LONG)"  Desk Accessory 4 ",
  0x0000, 0x0005, 0x0014, 0x0001,
        15,       -1,       -1, G_STRING  ,   /* Object 14  */
  NONE, NORMAL, (LONG)"  Desk Accessory 5 ",
  0x0000, 0x0006, 0x0014, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 15  */
  NONE, NORMAL, (LONG)"  Desk Accessory 6 ",
  0x0000, 0x0007, 0x0014, 0x0001,
        20, MENUSAVE, MENUQUIT, G_BOX     ,   /* Object 16  */
  NONE, NORMAL, (LONG)0x00FF1100L,
  0x000A, 0x0000, 0x0015, 0x0003,
        18,       -1,       -1, G_STRING  ,   /* Object 17 MENUSAVE */
  NONE, NORMAL, (LONG)"  Einst. sichern  ^S ",
  0x0000, 0x0000, 0x0015, 0x0001,
  MENUQUIT,       -1,       -1, G_STRING  ,   /* Object 18  */
  NONE, DISABLED, (LONG)"---------------------",
  0x0000, 0x0001, 0x0015, 0x0001,
        16,       -1,       -1, G_STRING  ,   /* Object 19 MENUQUIT */
  NONE, NORMAL, (LONG)"  Beenden         ^Q ",
  0x0000, 0x0002, 0x0015, 0x0001,
         6, MENUORDNER, MENUOPT , G_BOX     ,   /* Object 20  */
  NONE, NORMAL, (LONG)0x00FF1000L,
  0x0011, 0x0000, 0x0019, 0x0006,
  MENUALLES,       -1,       -1, G_STRING  ,   /* Object 21 MENUORDNER */
  NONE, NORMAL, (LONG)"  Ordner erzeugen     \007O ",
  0x0000, 0x0000, 0x0019, 0x0001,
  MENUTASTE,       -1,       -1, G_STRING  ,   /* Object 22 MENUALLES */
  NONE, NORMAL, (LONG)"  Alles auspacken     \007A ",
  0x0000, 0x0001, 0x0019, 0x0001,
  MENUMERKEN,       -1,       -1, G_STRING  ,   /* Object 23 MENUTASTE */
  NONE, NORMAL, (LONG)"  Auf Taste warten    \007T ",
  0x0000, 0x0002, 0x0019, 0x0001,
        25,       -1,       -1, G_STRING  ,   /* Object 24 MENUMERKEN */
  NONE, NORMAL, (LONG)"  Einstellung merken  \007M ",
  0x0000, 0x0003, 0x0019, 0x0001,
  MENUOPT ,       -1,       -1, G_STRING  ,   /* Object 25  */
  NONE, DISABLED, (LONG)"-------------------------",
  0x0000, 0x0004, 0x0019, 0x0001,
        20,       -1,       -1, G_STRING  ,   /* Object 26 MENUOPT */
  LASTOB, NORMAL, (LONG)"  Switches setzen...  \007S ",
  0x0000, 0x0005, 0x0019, 0x0001,
  
  /******** Tree 1 PACKDIAL ****************************************************/
        -1, PACKZOO , PACKGREY, G_BOX     ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0015, 0x000F,
  PACKLZH ,       -1,       -1, G_BUTTON  ,   /* Object 1 PACKZOO */
  SELECTABLE|RBUTTON|FLAGS9, NORMAL, (LONG)"ZOO",
  0x0002, 0x0001, 0x0005, 0x0001,
  PACKZIP ,       -1,       -1, G_BUTTON  ,   /* Object 2 PACKLZH */
  SELECTABLE|RBUTTON|FLAGS9, NORMAL, (LONG)"LZH",
  0x0008, 0x0001, 0x0005, 0x0001,
  PACKARJ ,       -1,       -1, G_BUTTON  ,   /* Object 3 PACKZIP */
  SELECTABLE|RBUTTON|FLAGS9, NORMAL, (LONG)"ZIP",
  0x000E, 0x0001, 0x0005, 0x0001,
  PACKARC ,       -1,       -1, G_BUTTON  ,   /* Object 4 PACKARJ */
  SELECTABLE|RBUTTON|FLAGS9, NORMAL, (LONG)"ARJ",
  0x0002, 0x0003, 0x0005, 0x0001,
  PACKXY2 ,       -1,       -1, G_BUTTON  ,   /* Object 5 PACKARC */
  SELECTABLE|RBUTTON|FLAGS9, NORMAL, (LONG)"ARC",
  0x0008, 0x0003, 0x0005, 0x0001,
  PACKGREY,       -1,       -1, G_BUTTON  ,   /* Object 6 PACKXY2 */
  SELECTABLE|RBUTTON|FLAGS9, DISABLED, (LONG)"XY2",
  0x000E, 0x0003, 0x0005, 0x0001,
         0, PACKEIN , PACKOPT , G_BOX     ,   /* Object 7 PACKGREY */
  FLAGS9|FLAGS10, NORMAL, (LONG)0x00011141L,
  0x0002, 0x0005, 0x0011, 0x0009,
  PACKAUS ,       -1,       -1, G_BOXTEXT ,   /* Object 8 PACKEIN */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[0],
  0x0002, 0x0001, 0x000D, 0x0001,
  PACKINHALT,       -1,       -1, G_BOXTEXT ,   /* Object 9 PACKAUS */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x0002, 0x0003, 0x000D, 0x0001,
  PACKOPT ,       -1,       -1, G_BOXTEXT ,   /* Object 10 PACKINHALT */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[2],
  0x0002, 0x0005, 0x000D, 0x0001,
  PACKGREY,       -1,       -1, G_BOXTEXT ,   /* Object 11 PACKOPT */
  SELECTABLE|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)&rs_tedinfo[3],
  0x0002, 0x0007, 0x000D, 0x0001,
  
  /******** Tree 2 SET2DIAL ****************************************************/
        -1,        1, SET2OK  , G_BOX     ,   /* Object 0  */
  FLAGS10, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0021, 0x0010,
         2,       -1,       -1, G_BUTTON  ,   /* Object 1  */
  NONE, SHADOWED, (LONG)"Einstellungen",
  0x0003, 0x0001, 0x0011, 0x0001,
  SET2TYP ,        3,        9, G_BOX     ,   /* Object 2  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0003, 0x0003, 0x001B, 0x0005,
  SET2PACKEIN,       -1,       -1, G_TEXT    |0x0100,   /* Object 3  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[4],
  0x0001, 0x0000, 0x000B, 0x0001,
         5,       -1,       -1, G_BOXCHAR |0x0300,   /* Object 4 SET2PACKEIN */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'\0' << 24)|0x00011180L,
  0x0002, 0x0001, 0x0002, 0x0001,
  SET2PACKAUS,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"Einpacken",
  0x0005, 0x0001, 0x0009, 0x0001,
         7,       -1,       -1, G_BOXCHAR |0x0300,   /* Object 6 SET2PACKAUS */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'\0' << 24)|0x00011180L,
  0x0002, 0x0002, 0x0002, 0x0001,
  SET2SHOW,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"Auspacken",
  0x0005, 0x0002, 0x0009, 0x0001,
         9,       -1,       -1, G_BOXCHAR |0x0300,   /* Object 8 SET2SHOW */
  SELECTABLE|RBUTTON, NORMAL, (LONG) ((LONG)'\0' << 24)|0x00011180L,
  0x0002, 0x0003, 0x0002, 0x0001,
         2,       -1,       -1, G_STRING  ,   /* Object 9  */
  NONE, NORMAL, (LONG)"Inhalt zeigen",
  0x0005, 0x0003, 0x000D, 0x0001,
  SET2EIN ,       -1,       -1, G_FTEXT   ,   /* Object 10 SET2TYP */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[5],
  0x0003, 0x0009, 0x000E, 0x0001,
  SET2AUS ,       -1,       -1, G_FTEXT   ,   /* Object 11 SET2EIN */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[6],
  0x0003, 0x000A, 0x001B, 0x0001,
  SET2INHALT,       -1,       -1, G_FTEXT   ,   /* Object 12 SET2AUS */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[7],
  0x0003, 0x000B, 0x001B, 0x0001,
  SET2OK  ,       -1,       -1, G_FTEXT   ,   /* Object 13 SET2INHALT */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[8],
  0x0003, 0x000C, 0x001B, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 14 SET2OK */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x0015, 0x000E, 0x0009, 0x0001,
  
  /******** Tree 3 SETDIAL ****************************************************/
        -1,        1, SETOK   , G_BOX     ,   /* Object 0  */
  FLAGS10, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0021, 0x0010,
  SETTYP  ,       -1,       -1, G_BUTTON  ,   /* Object 1  */
  NONE, SHADOWED, (LONG)"Einstellungen",
  0x0003, 0x0001, 0x0011, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2 SETTYP */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[9],
  0x001B, 0x0001, 0x0003, 0x0001,
  SETEIN  ,        4,       12, G_BOX     ,   /* Object 3  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0003, 0x0003, 0x001B, 0x0006,
  SETORDNER,       -1,       -1, G_TEXT    |0x0100,   /* Object 4  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[10],
  0x0001, 0x0000, 0x000A, 0x0001,
         6,       -1,       -1, G_BOXCHAR |0x0300,   /* Object 5 SETORDNER */
  SELECTABLE, NORMAL, (LONG) ((LONG)'\0' << 24)|0x00011100L,
  0x0002, 0x0001, 0x0002, 0x0001,
  SETALLES,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"Ordner erzeugen",
  0x0005, 0x0001, 0x000F, 0x0001,
         8,       -1,       -1, G_BOXCHAR |0x0300,   /* Object 7 SETALLES */
  SELECTABLE, NORMAL, (LONG) ((LONG)'\0' << 24)|0x00011100L,
  0x0002, 0x0002, 0x0002, 0x0001,
  SETTASTE,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"Alles auspacken",
  0x0005, 0x0002, 0x000F, 0x0001,
        10,       -1,       -1, G_BOXCHAR |0x0300,   /* Object 9 SETTASTE */
  SELECTABLE, NORMAL, (LONG) ((LONG)'\0' << 24)|0x00011100L,
  0x0002, 0x0003, 0x0002, 0x0001,
  SETMERKEN,       -1,       -1, G_STRING  ,   /* Object 10  */
  NONE, NORMAL, (LONG)"Auf Taste warten",
  0x0005, 0x0003, 0x0010, 0x0001,
        12,       -1,       -1, G_BOXCHAR |0x0300,   /* Object 11 SETMERKEN */
  SELECTABLE, NORMAL, (LONG) ((LONG)'\0' << 24)|0x00011180L,
  0x0002, 0x0004, 0x0002, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 12  */
  NONE, NORMAL, (LONG)"Einstellungen merken",
  0x0005, 0x0004, 0x0014, 0x0001,
  SETAUS  ,       -1,       -1, G_FTEXT   ,   /* Object 13 SETEIN */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[11],
  0x0003, 0x000A, 0x001B, 0x0001,
  SETINHALT,       -1,       -1, G_FTEXT   ,   /* Object 14 SETAUS */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[12],
  0x0003, 0x000B, 0x001B, 0x0001,
  SETINFO ,       -1,       -1, G_FTEXT   ,   /* Object 15 SETINHALT */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[13],
  0x0003, 0x000C, 0x001B, 0x0001,
  SETSAVE ,       -1,       -1, G_BOXTEXT ,   /* Object 16 SETINFO */
  SELECTABLE|EXIT, OUTLINED|SHADOWED, (LONG)&rs_tedinfo[14],
  0x0003, 0x000E, 0x0005, 0x0001,
  SETOK   ,       -1,       -1, G_BUTTON  ,   /* Object 17 SETSAVE */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Sichern",
  0x000C, 0x000E, 0x0008, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 18 SETOK */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x0016, 0x000E, 0x0008, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 PACKMENU */
  &rs_object[27],   /* Tree  1 PACKDIAL */
  &rs_object[39],   /* Tree  2 SET2DIAL */
  &rs_object[54]    /* Tree  3 SETDIAL  */
};
