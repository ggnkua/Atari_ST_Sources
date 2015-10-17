/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "POPUP.H"

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

static OBJECT rs_object[] =
{ 
  /******** Tree 0 POPUP ****************************************************/
        -1,        1, CODMAGEN        , G_BOX             ,   /* Object 0  */
  NONE, OUTLINED|DRAW3D, (LONG)0x00001180L,
  0x0000, 0x0000, 0x0010, 0x0010,
         2,       -1,       -1, G_BOX             ,   /* Object 1  */
  NONE, DRAW3D|WHITEBAK, (LONG)0x000111F0L,
  0x0000, 0x0000, 0x0001, 0x0001,
         3,       -1,       -1, G_BOX             ,   /* Object 2  */
  NONE, DRAW3D, (LONG)0x000111F1L,
  0x0000, 0x0001, 0x0001, 0x0001,
         4,       -1,       -1, G_BOX             ,   /* Object 3  */
  NONE, DRAW3D, (LONG)0x000111F2L,
  0x0000, 0x0002, 0x0001, 0x0001,
         5,       -1,       -1, G_BOX             ,   /* Object 4  */
  NONE, DRAW3D, (LONG)0x000111F3L,
  0x0000, 0x0003, 0x0001, 0x0001,
         6,       -1,       -1, G_BOX             ,   /* Object 5  */
  NONE, DRAW3D, (LONG)0x000111F4L,
  0x0000, 0x0004, 0x0001, 0x0001,
         7,       -1,       -1, G_BOX             ,   /* Object 6  */
  NONE, DRAW3D, (LONG)0x000111F5L,
  0x0000, 0x0005, 0x0001, 0x0001,
         8,       -1,       -1, G_BOX             ,   /* Object 7  */
  NONE, DRAW3D, (LONG)0x000111F6L,
  0x0000, 0x0006, 0x0001, 0x0001,
         9,       -1,       -1, G_BOX             ,   /* Object 8  */
  NONE, DRAW3D, (LONG)0x000111F7L,
  0x0000, 0x0007, 0x0001, 0x0001,
        10,       -1,       -1, G_BOX             ,   /* Object 9  */
  NONE, DRAW3D, (LONG)0x000111F8L,
  0x0000, 0x0008, 0x0001, 0x0001,
        11,       -1,       -1, G_BOX             ,   /* Object 10  */
  NONE, DRAW3D, (LONG)0x000111F9L,
  0x0000, 0x0009, 0x0001, 0x0001,
        12,       -1,       -1, G_BOX             ,   /* Object 11  */
  NONE, DRAW3D, (LONG)0x000111FAL,
  0x0000, 0x000A, 0x0001, 0x0001,
        13,       -1,       -1, G_BOX             ,   /* Object 12  */
  NONE, DRAW3D, (LONG)0x000111FBL,
  0x0000, 0x000B, 0x0001, 0x0001,
        14,       -1,       -1, G_BOX             ,   /* Object 13  */
  NONE, DRAW3D, (LONG)0x000111FCL,
  0x0000, 0x000C, 0x0001, 0x0001,
        15,       -1,       -1, G_BOX             ,   /* Object 14  */
  NONE, DRAW3D, (LONG)0x000111FDL,
  0x0000, 0x000D, 0x0001, 0x0001,
        16,       -1,       -1, G_BOX             ,   /* Object 15  */
  NONE, DRAW3D, (LONG)0x000111FEL,
  0x0000, 0x000E, 0x0001, 0x0001,
  COWHITE         ,       -1,       -1, G_BOX             ,   /* Object 16  */
  NONE, DRAW3D, (LONG)0x000111FFL,
  0x0000, 0x000F, 0x0001, 0x0001,
  COBLACK         ,       -1,       -1, G_STRING          |0x1700,   /* Object 17 COWHITE */
  SELECTABLE, DRAW3D, (LONG)" Wei\236        0",
  0x0001, 0x0000, 0x000F, 0x0001,
  CORED           ,       -1,       -1, G_STRING          |0x1700,   /* Object 18 COBLACK */
  SELECTABLE, DRAW3D, (LONG)" Schwarz     1",
  0x0001, 0x0001, 0x000F, 0x0001,
  COGREEN         ,       -1,       -1, G_STRING          |0x1700,   /* Object 19 CORED */
  SELECTABLE, DRAW3D, (LONG)" Rot         2",
  0x0001, 0x0002, 0x000F, 0x0001,
  COBLUE          ,       -1,       -1, G_STRING          |0x1700,   /* Object 20 COGREEN */
  SELECTABLE, DRAW3D, (LONG)" Gr\201n        3",
  0x0001, 0x0003, 0x000F, 0x0001,
  COCYAN          ,       -1,       -1, G_STRING          |0x1700,   /* Object 21 COBLUE */
  SELECTABLE, DRAW3D, (LONG)" Blau        4",
  0x0001, 0x0004, 0x000F, 0x0001,
  COYELLOW        ,       -1,       -1, G_STRING          |0x1700,   /* Object 22 COCYAN */
  SELECTABLE, DRAW3D, (LONG)" Zyan        5",
  0x0001, 0x0005, 0x000F, 0x0001,
  COMAGENT        ,       -1,       -1, G_STRING          |0x1700,   /* Object 23 COYELLOW */
  SELECTABLE, DRAW3D, (LONG)" Gelb        6",
  0x0001, 0x0006, 0x000F, 0x0001,
  COLGREY         ,       -1,       -1, G_STRING          |0x1700,   /* Object 24 COMAGENT */
  SELECTABLE, DRAW3D, (LONG)" Magenta     7",
  0x0001, 0x0007, 0x000F, 0x0001,
  CODGREY         ,       -1,       -1, G_STRING          |0x1700,   /* Object 25 COLGREY */
  SELECTABLE, DRAW3D, (LONG)" Hellgrau    8",
  0x0001, 0x0008, 0x000F, 0x0001,
  CODRED          ,       -1,       -1, G_STRING          |0x1700,   /* Object 26 CODGREY */
  SELECTABLE, DRAW3D, (LONG)" Dunkelgrau  9",
  0x0001, 0x0009, 0x000F, 0x0001,
  CODGREEN        ,       -1,       -1, G_STRING          |0x1700,   /* Object 27 CODRED */
  SELECTABLE, DRAW3D, (LONG)" Dunkelrot   A",
  0x0001, 0x000A, 0x000F, 0x0001,
  CODBLUE         ,       -1,       -1, G_STRING          |0x1700,   /* Object 28 CODGREEN */
  SELECTABLE, DRAW3D, (LONG)" Dunkelgr\201n  B",
  0x0001, 0x000B, 0x000F, 0x0001,
  CODCYAN         ,       -1,       -1, G_STRING          |0x1700,   /* Object 29 CODBLUE */
  SELECTABLE, DRAW3D, (LONG)" Dunkelblau  C",
  0x0001, 0x000C, 0x000F, 0x0001,
  CODYELLO        ,       -1,       -1, G_STRING          |0x1700,   /* Object 30 CODCYAN */
  SELECTABLE, DRAW3D, (LONG)" Dunkelzyan  D",
  0x0001, 0x000D, 0x000F, 0x0001,
  CODMAGEN        ,       -1,       -1, G_STRING          |0x1700,   /* Object 31 CODYELLO */
  SELECTABLE, DRAW3D, (LONG)" Dunkelgelb  E",
  0x0001, 0x000E, 0x000F, 0x0001,
         0,       -1,       -1, G_STRING          |0x1700,   /* Object 32 CODMAGEN */
  SELECTABLE|LASTOB, DRAW3D, (LONG)" Dnklmagenta F",
  0x0001, 0x000F, 0x000F, 0x0001
};

static OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 POPUP            */
};
