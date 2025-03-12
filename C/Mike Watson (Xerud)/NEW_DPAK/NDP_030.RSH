/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "NDP_030.H"

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
{ "Filename      :",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1108, 0, -1, 16, 1,
  "Filetype      :",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1108, 0, -1, 16, 1,
  "Packed size   :",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1108, 0, -1, 16, 1,
  "UnPacked size :",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1108, 0, -1, 16, 1,
  "Free Ram      :",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1108, 0, -1, 16, 1,
  "\2751993 Sinister Developments",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 28, 1,
  "File_info     : ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 17, 1,
  "Recursive Batchmode",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 20, 1,
  "Specify Save Path",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 18, 1,
  "Save during batch",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 18, 1,
  "Batch Report",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 13, 1,
  "C:\134DUMP.TXT",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1178, 0, 1, 12, 1,
  "REPORT FILENAME",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 16, 1,
  "Coded by Mike Watson using PURE C, DEVPAC3 & INTERFACE",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 55, 1,
  "Depack code by the authors of the respective packers",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 53, 1,
  "All correspondence to: Mike Watson",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -1, 35, 1,
  "42 Gilmore Place",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 17, 1,
  "Edinburgh,EH3 9NQ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1130, 0, -1, 18, 1,
  "SCOTLAND",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 9, 1,
  "I CANNOT DETERMINE THE VERSION OF ICE",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 38, 1,
  "WHICH CREATED THIS FILE. PLEASE CHOOSE",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 39, 1,
  "A SUITABLE VERSION OR CANCEL TO QUIT.",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 38, 1,
  "PACK ICE FILE CLASH!!",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 22, 1,
  "I CANNOT DETERMINE THE PACKER THAT",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 35, 1,
  "CREATED THIS FILE. PLEASE CHOOSE A",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 35, 1,
  "SUITABLE PACKER OR CANCEL TO QUIT.",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 35, 1,
  "ATOM FILE CLASH",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 16, 1,
  "I CANNOT DETERMINE THE VERSION OF THE",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 38, 1,
  "POMPEY PACKER THAT CREATED THIS FILE.",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 38, 1,
  "CHOOSE A SUITABLE VERSION OR CANCEL TO",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 39, 1,
  "TEXT",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1181, 0, 0, 5, 1,
  "QUIT!",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 6, 1,
  "POMPEY PACKER CLASH",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 20, 1,
  "I CANNOT DETERMINE THE VERSION OF THE",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 38, 1,
  "RNC PACKER THAT CREATED THIS FILE.",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 35, 1,
  "CHOOSE A SUITABLE VERSION OR CANCEL TO",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 39, 1,
  "TEXT",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1181, 0, 0, 5, 1,
  "QUIT!",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 6, 1,
  "RNC-1 PACKER CLASH",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1101, 0, 0, 19, 1
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 MAIN_MENU ****************************************************/
        -1, STATS_BOX, FILE_THINGS_BOX, G_BOX     |0x0100,   /* Object 0 MAIN_MEN_BOX */
  FLAGS9, NORMAL, (LONG)0x000011FDL,
  0x0000, 0x0000, 0x003B, 0x000B,
  BUTT_BOX,        2, MENU_FRAM, G_BOX     |0x0100,   /* Object 1 STATS_BOX */
  FLAGS9, NORMAL, (LONG)0x00FF11F8L,
  0x0001, 0x0001, 0x001C, 0x0005,
  MENU_FNAME,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x0000, 0x000F, 0x0001,
         4,       -1,       -1, G_STRING  ,   /* Object 3 MENU_FNAME */
  NONE, NORMAL, (LONG)"____________",
  0x0010, 0x0000, 0x000C, 0x0001,
  MENU_FTYPE,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0000, 0x0001, 0x000F, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5 MENU_FTYPE */
  NONE, NORMAL, (LONG)"____________",
  0x0010, 0x0001, 0x000C, 0x0001,
  MENU_PAKSIZE,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0000, 0x0002, 0x000F, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7 MENU_PAKSIZE */
  NONE, NORMAL, (LONG)"____________",
  0x0010, 0x0002, 0x000C, 0x0001,
  MENU_UNPAKSIZE,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0000, 0x0003, 0x000F, 0x0001,
        10,       -1,       -1, G_STRING  ,   /* Object 9 MENU_UNPAKSIZE */
  NONE, NORMAL, (LONG)"____________",
  0x0010, 0x0003, 0x000C, 0x0001,
  MENU_FRAM,       -1,       -1, G_TEXT    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0000, 0x0004, 0x000F, 0x0001,
  STATS_BOX,       -1,       -1, G_STRING  ,   /* Object 11 MENU_FRAM */
  NONE, NORMAL, (LONG)"____________",
  0x0010, 0x0004, 0x000C, 0x0001,
  FILE_THINGS_BOX, LOAD_BUTT, SINISTERD1992, G_BOX     |0x0100,   /* Object 12 BUTT_BOX */
  FLAGS9, NORMAL, (LONG)0x00FF11F8L,
  0x001E, 0x0001, 0x001C, 0x0005,
  PREFS_BUTT,       -1,       -1, G_BUTTON  |0x0100,   /* Object 13 LOAD_BUTT */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"LOAD",
  0x0001, 0x0400, 0x0008, 0x0001,
  EXIT_BUTT,       -1,       -1, G_BUTTON  |0x0100,   /* Object 14 PREFS_BUTT */
  SELECTABLE|EXIT|FLAGS9, DRAW3D, (LONG)"PREFS",
  0x000A, 0x0400, 0x0008, 0x0001,
  SAVE_BUTT,       -1,       -1, G_BUTTON  |0x0100,   /* Object 15 EXIT_BUTT */
  SELECTABLE|EXIT|FLAGS9, DRAW3D, (LONG)"EXIT",
  0x0013, 0x0400, 0x0008, 0x0001,
  INFO_BUTT,       -1,       -1, G_BUTTON  |0x0100,   /* Object 16 SAVE_BUTT */
  SELECTABLE|EXIT|FLAGS9, DISABLED|DRAW3D, (LONG)"SAVE",
  0x0001, 0x0402, 0x0008, 0x0001,
  SINISTERD1992,       -1,       -1, G_BUTTON  |0x0100,   /* Object 17 INFO_BUTT */
  SELECTABLE|EXIT|FLAGS9, DRAW3D, (LONG)"INFO",
  0x000A, 0x0402, 0x0008, 0x0001,
  BUTT_BOX,       -1,       -1, G_TEXT    ,   /* Object 18 SINISTERD1992 */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0001, 0x0004, 0x001B, 0x0001,
  MAIN_MEN_BOX,       20, FINFO3  , G_BOX     |0x0100,   /* Object 19 FILE_THINGS_BOX */
  FLAGS9, NORMAL, (LONG)0x00FF11F8L,
  0x0001, 0x0007, 0x0039, 0x0003,
  FINFO1  ,       -1,       -1, G_TEXT    ,   /* Object 20  */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0000, 0x0000, 0x0010, 0x0001,
  FINFO2  ,       -1,       -1, G_STRING  ,   /* Object 21 FINFO1 */
  NONE, NORMAL, (LONG)"________________________________________",
  0x0010, 0x0000, 0x0028, 0x0001,
  FINFO3  ,       -1,       -1, G_STRING  ,   /* Object 22 FINFO2 */
  NONE, NORMAL, (LONG)"________________________________________",
  0x0010, 0x0001, 0x0028, 0x0001,
  FILE_THINGS_BOX,       -1,       -1, G_STRING  ,   /* Object 23 FINFO3 */
  LASTOB, NORMAL, (LONG)"________________________________________",
  0x0010, 0x0002, 0x0028, 0x0001,
  
  /******** Tree 1 PREFERENCES ****************************************************/
        -1, PREF_OK ,        4, G_BOX     |0x0100,   /* Object 0  */
  FLAGS9, NORMAL, (LONG)0x000011FDL,
  0x0000, 0x0000, 0x0038, 0x0009,
  PREF_CANCEL,       -1,       -1, G_BUTTON  |0x0100,   /* Object 1 PREF_OK */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"OK",
  0x002F, 0x0001, 0x0008, 0x0001,
  PREF_SAVE,       -1,       -1, G_BUTTON  |0x0100,   /* Object 2 PREF_CANCEL */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"Cancel",
  0x002F, 0x0003, 0x0008, 0x0001,
         4,       -1,       -1, G_BUTTON  |0x0100,   /* Object 3 PREF_SAVE */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"Save",
  0x002F, 0x0005, 0x0008, 0x0001,
         0,        5, BATCHREPT_BUTTON, G_BOX     |0x0100,   /* Object 4  */
  FLAGS9, NORMAL, (LONG)0x00011178L,
  0x0001, 0x0001, 0x002D, 0x0007,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[7],
  0x0004, 0x0001, 0x0013, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[8],
  0x001A, 0x0001, 0x0011, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[9],
  0x0004, 0x0003, 0x0011, 0x0001,
  DUMP_NAME,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[10],
  0x001A, 0x0003, 0x000C, 0x0001,
        10,       -1,       -1, G_BOXTEXT |0x0100,   /* Object 9 DUMP_NAME */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)&rs_tedinfo[11],
  0x0002, 0x0005, 0x0027, 0x0001,
  RECURSIVE_BUTTON,       -1,       -1, G_TEXT    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[12],
  0x0002, 0x0006, 0x000F, 0x0001,
  SAVEPATH_BUTTON,       -1,       -1, G_BOX     |0x0100,   /* Object 11 RECURSIVE_BUTTON */
  SELECTABLE|FLAGS9, SELECTED, (LONG)0x00FF1178L,
  0x0002, 0x0001, 0x0001, 0x0001,
  BATCHSAVE_BUTTON,       -1,       -1, G_BOX     |0x0100,   /* Object 12 SAVEPATH_BUTTON */
  SELECTABLE|FLAGS9, SELECTED, (LONG)0x00FF1178L,
  0x0018, 0x0001, 0x0001, 0x0001,
  BATCHREPT_BUTTON,       -1,       -1, G_BOX     |0x0100,   /* Object 13 BATCHSAVE_BUTTON */
  SELECTABLE|FLAGS9, SELECTED, (LONG)0x00FF1178L,
  0x0002, 0x0003, 0x0001, 0x0001,
         4,       -1,       -1, G_BOX     |0x0100,   /* Object 14 BATCHREPT_BUTTON */
  SELECTABLE|LASTOB|FLAGS9, SELECTED, (LONG)0x00FF1178L,
  0x0018, 0x0003, 0x0001, 0x0001,
  
  /******** Tree 2 INFORMATION ****************************************************/
        -1,        1, INFO_EXIT, G_BOX     |0x0100,   /* Object 0  */
  FLAGS9, NORMAL, (LONG)0x000011FDL,
  0x0000, 0x0000, 0x0038, 0x000A,
  INFO_EXIT,        2,        7, G_BOX     |0x0100,   /* Object 1  */
  FLAGS9, NORMAL, (LONG)0x00FF11F8L,
  0x0001, 0x0001, 0x0036, 0x0006,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[13],
  0x0000, 0x0000, 0x0036, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[14],
  0x0000, 0x0001, 0x0034, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[15],
  0x000A, 0x0002, 0x0022, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[16],
  0x0021, 0x0003, 0x0010, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[17],
  0x0021, 0x0004, 0x0011, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[18],
  0x0021, 0x0005, 0x0008, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x0100,   /* Object 8 INFO_EXIT */
  SELECTABLE|EXIT|LASTOB|FLAGS9, NORMAL, (LONG)"KEWL!",
  0x0018, 0x0008, 0x0008, 0x0001,
  
  /******** Tree 3 PACK_ICE_CLASH ****************************************************/
        -1, V2_2_BUTT, ICE_PISS_OFF, G_BOX     |0x0100,   /* Object 0  */
  FLAGS9, OUTLINED|SHADOWED, (LONG)0x000111FDL,
  0x0000, 0x0000, 0x0028, 0x000A,
         0,       -1,       -1, G_BUTTON  |0x0100,   /* Object 1 ICE_PISS_OFF */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"CANCEL",
  0x0018, 0x0008, 0x0008, 0x0001,
  ICE_PISS_OFF,        3, ICE_FNAME, G_BOX     |0x0100,   /* Object 2  */
  FLAGS9, NORMAL, (LONG)0x000111F8L,
  0x0001, 0x0001, 0x0026, 0x0006,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[19],
  0x0000, 0x0002, 0x0025, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[20],
  0x0000, 0x0003, 0x0026, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[21],
  0x0000, 0x0004, 0x0025, 0x0001,
  ICE_FNAME,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[22],
  0x0009, 0x0000, 0x0015, 0x0001,
         2,       -1,       -1, G_STRING  ,   /* Object 7 ICE_FNAME */
  NONE, NORMAL, (LONG)"xxxxxxxx.xxx",
  0x000D, 0x0001, 0x000C, 0x0001,
         2,       -1,       -1, G_BUTTON  |0x0100,   /* Object 8 V2_BUTT */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"V2.0",
  0x0009, 0x0008, 0x0006, 0x0001,
  V2_BUTT ,       -1,       -1, G_BUTTON  |0x0100,   /* Object 9 V2_2_BUTT */
  SELECTABLE|EXIT|LASTOB|FLAGS9, NORMAL, (LONG)"V2.2",
  0x0010, 0x0008, 0x0006, 0x0001,
  
  /******** Tree 4 ATOM_CLASH ****************************************************/
        -1, THUN_BUTT2, V3_1_BUTT, G_BOX     |0x0100,   /* Object 0  */
  FLAGS9, OUTLINED|SHADOWED, (LONG)0x000111FDL,
  0x0000, 0x0000, 0x0025, 0x000D,
  V3_3_BUTT,       -1,       -1, G_BUTTON  |0x0100,   /* Object 1 THUN_BUTT2 */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"Thunder v2",
  0x0001, 0x000B, 0x000C, 0x0001,
         3,       -1,       -1, G_BUTTON  |0x0100,   /* Object 2 V3_3_BUTT */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"Atomic v3.3",
  0x000E, 0x0009, 0x040C, 0x0001,
  PISS_OFF_ATOM,        4, ATOM_FNAME, G_BOX     |0x0100,   /* Object 3  */
  FLAGS9, NORMAL, (LONG)0x000111F8L,
  0x0001, 0x0001, 0x0023, 0x0005,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[23],
  0x0000, 0x0002, 0x0022, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[24],
  0x0000, 0x0003, 0x0022, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[25],
  0x0000, 0x0004, 0x0022, 0x0001,
  ATOM_FNAME,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[26],
  0x000A, 0x0000, 0x000F, 0x0001,
         3,       -1,       -1, G_STRING  ,   /* Object 8 ATOM_FNAME */
  NONE, NORMAL, (LONG)"xxxxxxxx.xxx",
  0x000C, 0x0001, 0x000C, 0x0001,
  THUN_BUTT11,       -1,       -1, G_BUTTON  |0x0100,   /* Object 9 PISS_OFF_ATOM */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"CANCEL",
  0x001C, 0x0007, 0x0407, 0x0001,
  THUN_BUTT1,       -1,       -1, G_BUTTON  |0x0100,   /* Object 10 THUN_BUTT11 */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"Thunder v1.1",
  0x0001, 0x0009, 0x000C, 0x0001,
  V3_1_BUTT,       -1,       -1, G_BUTTON  |0x0100,   /* Object 11 THUN_BUTT1 */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"Thunder v1",
  0x0001, 0x0007, 0x000C, 0x0001,
         0,       -1,       -1, G_BUTTON  |0x0100,   /* Object 12 V3_1_BUTT */
  SELECTABLE|EXIT|LASTOB|FLAGS9, NORMAL, (LONG)"Atomic v3.1",
  0x000E, 0x0007, 0x040C, 0x0001,
  
  /******** Tree 5 POMPEY_CLASH ****************************************************/
        -1, V1_9_BUTT, POMPEY_PISS_OFF, G_BOX     |0x0100,   /* Object 0  */
  FLAGS9, OUTLINED|SHADOWED, (LONG)0x0001117DL,
  0x0000, 0x0000, 0x0029, 0x000A,
         0,       -1,       -1, G_BUTTON  |0x0100,   /* Object 1 POMPEY_PISS_OFF */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"CANCEL",
  0x0020, 0x0008, 0x0008, 0x0001,
  POMPEY_PISS_OFF,        3, POMPEY_FNAME, G_BOX     |0x0100,   /* Object 2  */
  FLAGS9, NORMAL, (LONG)0x000111F8L,
  0x0001, 0x0001, 0x0027, 0x0006,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[27],
  0x0000, 0x0002, 0x0025, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[28],
  0x0000, 0x0003, 0x0025, 0x0001,
         7,        6,        6, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[29],
  0x0000, 0x0004, 0x0026, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[30],
  0x0000, 0x0001, 0x0004, 0x0100,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[31],
  0x0000, 0x0005, 0x0005, 0x0001,
  POMPEY_FNAME,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[32],
  0x000A, 0x0000, 0x0013, 0x0001,
         2,       -1,       -1, G_STRING  ,   /* Object 9 POMPEY_FNAME */
  NONE, NORMAL, (LONG)"xxxxxxxx.xxx",
  0x000E, 0x0001, 0x000C, 0x0001,
         2,       -1,       -1, G_BUTTON  |0x0100,   /* Object 10 V1_5_BUTT */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"V1.5",
  0x0001, 0x0008, 0x0006, 0x0001,
  V1_5_BUTT,       -1,       -1, G_BUTTON  |0x0100,   /* Object 11 V1_9_BUTT */
  SELECTABLE|EXIT|LASTOB|FLAGS9, NORMAL, (LONG)"V1.9",
  0x0009, 0x0008, 0x0006, 0x0001,
  
  /******** Tree 6 RNC_CLASH ****************************************************/
        -1, TYPE2_BUTT, RNC_BYE , G_BOX     |0x0100,   /* Object 0  */
  FLAGS9, OUTLINED|SHADOWED, (LONG)0x0001117DL,
  0x0000, 0x0000, 0x0029, 0x000A,
         0,       -1,       -1, G_BUTTON  |0x0100,   /* Object 1 RNC_BYE */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"CANCEL",
  0x001F, 0x0008, 0x0008, 0x0001,
  RNC_BYE ,        3, RNC_FNAME, G_BOX     |0x0100,   /* Object 2  */
  FLAGS9, NORMAL, (LONG)0x000111F8L,
  0x0001, 0x0001, 0x0027, 0x0006,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[33],
  0x0000, 0x0002, 0x0025, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[34],
  0x0000, 0x0003, 0x0022, 0x0001,
         7,        6,        6, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[35],
  0x0000, 0x0004, 0x0026, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[36],
  0x0000, 0x0001, 0x0004, 0x0100,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[37],
  0x0000, 0x0005, 0x0005, 0x0001,
  RNC_FNAME,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[38],
  0x000B, 0x0100, 0x0012, 0x0001,
         2,       -1,       -1, G_STRING  ,   /* Object 9 RNC_FNAME */
  NONE, NORMAL, (LONG)"xxxxxxxx.xxx",
  0x000E, 0x0001, 0x000C, 0x0001,
         2,       -1,       -1, G_BUTTON  |0x0100,   /* Object 10 TYPE1_BUTT */
  SELECTABLE|EXIT|FLAGS9, NORMAL, (LONG)"TYPE 1",
  0x0001, 0x0008, 0x0006, 0x0001,
  TYPE1_BUTT,       -1,       -1, G_BUTTON  |0x0100,   /* Object 11 TYPE2_BUTT */
  SELECTABLE|EXIT|LASTOB|FLAGS9, NORMAL, (LONG)"TYPE 2",
  0x0009, 0x0008, 0x0006, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 MAIN_MENU */
  &rs_object[24],   /* Tree  1 PREFERENCES */
  &rs_object[39],   /* Tree  2 INFORMATION */
  &rs_object[48],   /* Tree  3 PACK_ICE_CLASH */
  &rs_object[58],   /* Tree  4 ATOM_CLASH */
  &rs_object[71],   /* Tree  5 POMPEY_CLASH */
  &rs_object[83]    /* Tree  6 RNC_CLASH */
};
