/* GEM Resource C Source */

#include <portab.h>
#include "aes.h"
#include "MLINES.H"

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

statique TEDINFO rs_tedinfo[] =
{ "             texte 1                 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 38, 1,
  "             texte 1                 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 38, 1,
  "             texte 1                 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 38, 1,
  "             texte 1                 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 38, 1,
  "             texte 1                 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 38, 1,
  "             texte 1                 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 38, 1,
  "             texte 1                 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 38, 1,
  "             texte 1                 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 38, 1,
  "             texte 1                 ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 38, 1
};

statique OBJECT rs_object[] =
{ 
  /******** Tree 0 FORM_MLINES ****************************************************/
        -1, PROG_TITRE1, MLINES_CANCEL, G_BOX     ,   /* Object 0  */
  FLAGS9, NORMAL, (LONG)0x00011100L,
  0x0000, 0x0000, 0x0425, 0x000B,
         2,       -1,       -1, G_TEXT    ,   /* Object 1 PROG_TITRE1 */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[0],
  0x0400, 0x0800, 0x0025, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x0400, 0x0801, 0x0025, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[2],
  0x0000, 0x0802, 0x0025, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[3],
  0x0400, 0x0802, 0x0025, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[4],
  0x0400, 0x0803, 0x0025, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[5],
  0x0400, 0x0804, 0x0025, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[6],
  0x0400, 0x0805, 0x0025, 0x0001,
         9,       -1,       -1, G_TEXT    ,   /* Object 8  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[7],
  0x0400, 0x0806, 0x0025, 0x0001,
  MLINES_OK,       -1,       -1, G_TEXT    ,   /* Object 9  */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[8],
  0x0400, 0x0807, 0x0025, 0x0001,
  MLINES_CANCEL,       -1,       -1, G_BUTTON  ,   /* Object 10 MLINES_OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x0406, 0x0009, 0x0408, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 11 MLINES_CANCEL */
  SELECTABLE|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)" Annuler ",
  0x0417, 0x0009, 0x0009, 0x0001
};

statique OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 FORM_MLINES */
};
