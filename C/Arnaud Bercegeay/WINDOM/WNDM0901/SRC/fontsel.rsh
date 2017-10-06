/* GEM Resource C Source */

#include "FONTSEL.H"

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
{ "__",
  " __ pts",
  "99",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 3, 8,
  "123456",
  "Id: ______",
  "999999",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 7, 11
};

static OBJECT rs_object[] =
{ 
  /******** Tree 0 FONTSEL ****************************************************/
        -1, FONT_DRAW       , IDFONT          , G_BOX             ,   /* Object 0  */
  FLAGS10, DRAW3D, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0024, 0x0011,
  FONT_OK         , FONT_USER       , FONT_USER       , G_BOX             ,   /* Object 1 FONT_DRAW */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0002, 0x0001, 0x0020, 0x0803,
  FONT_DRAW       ,       -1,       -1, G_IBOX            ,   /* Object 2 FONT_USER */
  NONE, NORMAL, (LONG)0x00FF1141L,
  0x0000, 0x0000, 0x0020, 0x0803,
  FONT_CANCEL     ,       -1,       -1, G_BUTTON          ,   /* Object 3 FONT_OK */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x000D, 0x000F, 0x0008, 0x0001,
         5,       -1,       -1, G_BUTTON          |0x1F00,   /* Object 4 FONT_CANCEL */
  SELECTABLE|EXIT|FLAGS9|FLAGS10|FLAGS11, NORMAL, (LONG)"Cancel",
  0x0402, 0x000F, 0x0008, 0x0001,
  FONT_SIZE       , FONT_DN         , FONT_BACK       , G_IBOX            ,   /* Object 5  */
  NONE, NORMAL, (LONG)0x00001101L,
  0x0002, 0x0006, 0x0420, 0x0008,
  FONT_UP         ,       -1,       -1, G_BOXCHAR         |0x0F00,   /* Object 6 FONT_DN */
  SELECTABLE|TOUCHEXIT, DRAW3D, (LONG) ((LONG)'\002' << 24)|0x00FF1100L,
  0x011E, 0x0104, 0x0002, 0x0F03,
  FONT_BACK       ,       -1,       -1, G_BOXCHAR         |0x0F00,   /* Object 7 FONT_UP */
  SELECTABLE|TOUCHEXIT, DRAW3D, (LONG) ((LONG)'\001' << 24)|0x00FF1100L,
  0x011E, 0x0000, 0x0002, 0x0004,
         5, FONT1           , FONT8           , G_BOX             ,   /* Object 8 FONT_BACK */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0000, 0x001E, 0x0008,
  FONT2           ,       -1,       -1, G_STRING          ,   /* Object 9 FONT1 */
  TOUCHEXIT, NORMAL, (LONG)"Font Name 1                   ",
  0x0000, 0x0000, 0x001E, 0x0001,
  FONT3           ,       -1,       -1, G_STRING          ,   /* Object 10 FONT2 */
  TOUCHEXIT, NORMAL, (LONG)"Font Name 2                   ",
  0x0000, 0x0001, 0x001E, 0x0001,
  FONT4           ,       -1,       -1, G_STRING          ,   /* Object 11 FONT3 */
  TOUCHEXIT, NORMAL, (LONG)"Font Name 3                   ",
  0x0000, 0x0002, 0x001E, 0x0001,
  FONT5           ,       -1,       -1, G_STRING          ,   /* Object 12 FONT4 */
  TOUCHEXIT, NORMAL, (LONG)"Font Name 4                   ",
  0x0000, 0x0003, 0x001E, 0x0001,
  FONT6           ,       -1,       -1, G_STRING          ,   /* Object 13 FONT5 */
  TOUCHEXIT, NORMAL, (LONG)"Font Name 5                   ",
  0x0000, 0x0004, 0x001E, 0x0001,
  FONT7           ,       -1,       -1, G_STRING          ,   /* Object 14 FONT6 */
  TOUCHEXIT, NORMAL, (LONG)"Font Name 6                   ",
  0x0000, 0x0005, 0x001E, 0x0001,
  FONT8           ,       -1,       -1, G_STRING          ,   /* Object 15 FONT7 */
  TOUCHEXIT, NORMAL, (LONG)"Font Name 7                   ",
  0x0000, 0x0006, 0x001E, 0x0001,
  FONT_BACK       ,       -1,       -1, G_STRING          ,   /* Object 16 FONT8 */
  TOUCHEXIT, NORMAL, (LONG)"Font Name 8                   ",
  0x0000, 0x0007, 0x001E, 0x0001,
  IDFONT          ,       -1,       -1, G_FBOXTEXT        ,   /* Object 17 FONT_SIZE */
  EDITABLE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0419, 0x000F, 0x0008, 0x0001,
         0,       -1,       -1, G_FTEXT           ,   /* Object 18 IDFONT */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[1],
  0x0002, 0x0005, 0x0407, 0x0600
};

static OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 FONTSEL          */
};
