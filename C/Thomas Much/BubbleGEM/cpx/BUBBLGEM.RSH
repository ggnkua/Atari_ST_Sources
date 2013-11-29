/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "BUBBLGEM.H"

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
{ "COPYRIGHT \2751998-04-28 THOMAS MUCH",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 34, 1,
  "1234",
  "auf:____ms",
  "XXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 11,
  "5678",
  " zu:____ms",
  "XXXX",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 5, 11
};

WORD RSBB0DATA[] =
{ 0x0000, 0x03C0, 0x0C30, 0x1008, 
  0x23C4, 0x27E4, 0x4FF2, 0x4FF2, 
  0x4FF2, 0x4FF2, 0x27E4, 0x23C4, 
  0x1008, 0x0C30, 0x03C0, 0x0000
};

WORD RSBB1DATA[] =
{ 0x0000, 0x03C0, 0x0C30, 0x1008, 
  0x2004, 0x2004, 0x4002, 0x4002, 
  0x4002, 0x4002, 0x2004, 0x2004, 
  0x1008, 0x0C30, 0x03C0, 0x0000
};

WORD RSBB2DATA[] =
{ 0x0000, 0x07E0, 0x1818, 0x2004, 
  0x2004, 0x2004, 0x1818, 0x07E0
};

WORD RSBB3DATA[] =
{ 0x0000, 0x07E0, 0x1818, 0x23C4, 
  0x27E4, 0x23C4, 0x1818, 0x07E0
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,   2,  16,   0,   0, 0x0001,
  RSBB1DATA,   2,  16,   0,   0, 0x0001,
  RSBB2DATA,   2,   8,   0,   0, 0x0001,
  RSBB3DATA,   2,   8,   0,   0, 0x0001
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 BGMAIN ****************************************************/
        -1, BGMFRAME        , BGMOK           , G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0020, 0x000B,
  BGMSAVE         ,        2, BGMTOPONLY      , G_BUTTON          ,   /* Object 1 BGMFRAME */
  FLAGS10, WHITEBAK|STATE9|STATE10|STATE11|STATE12|STATE13|STATE14|STATE15, (LONG)" BubbleGEM-Konfiguration ",
  0x0001, 0x0800, 0x001E, 0x0008,
  BGMBUBBLES      ,       -1,       -1, G_TEXT            ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x0001, 0x001E, 0x0001,
  BGMOPEN         ,       -1,       -1, G_BUTTON          ,   /* Object 3 BGMBUBBLES */
  SELECTABLE|RBUTTON|FLAGS9|FLAGS10, WHITEBAK|STATE14|STATE15, (LONG)"Sprechblasen",
  0x0002, 0x0002, 0x000F, 0x0001,
  BGMWINSTYLE     ,       -1,       -1, G_FTEXT           ,   /* Object 4 BGMOPEN */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x0013, 0x0002, 0x000B, 0x0001,
  BGMCLOSE        ,       -1,       -1, G_BUTTON          ,   /* Object 5 BGMWINSTYLE */
  SELECTABLE|RBUTTON|FLAGS9|FLAGS10, WHITEBAK|STATE14|STATE15, (LONG)"Windows-Stil",
  0x0002, 0x0003, 0x000F, 0x0001,
  BGMFONTCHANGED  ,       -1,       -1, G_FTEXT           ,   /* Object 6 BGMCLOSE */
  EDITABLE|FLAGS10, NORMAL, (LONG)&rs_tedinfo[2],
  0x0013, 0x0003, 0x000B, 0x0001,
  BGMSENDKEY      ,       -1,       -1, G_BUTTON          ,   /* Object 7 BGMFONTCHANGED */
  SELECTABLE|FLAGS9|FLAGS10, WHITEBAK|STATE14|STATE15, (LONG)"Font-Protokoll beachten",
  0x0002, 0x0804, 0x001A, 0x0001,
  BGMDEMON        ,       -1,       -1, G_BUTTON          ,   /* Object 8 BGMSENDKEY */
  SELECTABLE|FLAGS9|FLAGS10, WHITEBAK|STATE14|STATE15, (LONG)"AV_SENDKEY verschicken",
  0x0002, 0x0805, 0x001A, 0x0001,
  BGMTOPONLY      ,       -1,       -1, G_BUTTON          ,   /* Object 9 BGMDEMON */
  SELECTABLE|FLAGS9|FLAGS10, WHITEBAK|STATE14|STATE15, (LONG)"Hilfe-D\204mon",
  0x0002, 0x0806, 0x000F, 0x0001,
  BGMFRAME        ,       -1,       -1, G_BUTTON          ,   /* Object 10 BGMTOPONLY */
  SELECTABLE|FLAGS9|FLAGS10, WHITEBAK|STATE14|STATE15, (LONG)"nur Top",
  0x0012, 0x0806, 0x000A, 0x0001,
  BGMCANCEL       ,       -1,       -1, G_BUTTON          ,   /* Object 11 BGMSAVE */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Sichern",
  0x0201, 0x0809, 0x0008, 0x0101,
  BGMOK           ,       -1,       -1, G_BUTTON          ,   /* Object 12 BGMCANCEL */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Abbruch",
  0x060C, 0x0809, 0x0008, 0x0101,
         0,       -1,       -1, G_BUTTON          ,   /* Object 13 BGMOK */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"OK",
  0x0616, 0x0809, 0x0008, 0x0101,
  
  /******** Tree 1 IMAGE_DIALOG ****************************************************/
        -1, RADIO_SLCT      , RADIO_M_SLCT    , G_BOX             ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0034, 0x0009,
  RADIO_DESLCT    ,       -1,       -1, G_IMAGE           ,   /* Object 1 RADIO_SLCT */
  NONE, NORMAL, (LONG)&rs_bitblk[0],
  0x0005, 0x0001, 0x0002, 0x0001,
  RADIO_M_DESLCT  ,       -1,       -1, G_IMAGE           ,   /* Object 2 RADIO_DESLCT */
  NONE, NORMAL, (LONG)&rs_bitblk[1],
  0x0002, 0x0001, 0x0002, 0x0001,
  RADIO_M_SLCT    ,       -1,       -1, G_IMAGE           ,   /* Object 3 RADIO_M_DESLCT */
  NONE, NORMAL, (LONG)&rs_bitblk[2],
  0x0002, 0x0003, 0x0002, 0x0800,
         0,       -1,       -1, G_IMAGE           ,   /* Object 4 RADIO_M_SLCT */
  LASTOB, NORMAL, (LONG)&rs_bitblk[3],
  0x0005, 0x0003, 0x0002, 0x0800
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 BGMAIN           */
  &rs_object[14]    /* Tree  1 IMAGE_DIALOG     */
};
