/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "INTERNAL.H"

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
{ " Close window     ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 19, 1,
  " Iconify window   ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 19, 1,
  "  Cycle windows    ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  "  Bring to front   ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  "-------------------",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  "  Change priority  ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  "  Backgroundable   ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  "  Always on top    ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  "-------------------",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  " Maximize window  ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 19, 1,
  " Minimize window  ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 19, 1,
  " What\047s this ???",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 17, 1,
  "-------------------",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  " Close window   ^U",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 19, 1,
  " Cycle windows  ^W",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 19, 1,
  "-------------------",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  " Close all",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 11, 1,
  " Redraw window",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 15, 1,
  " Redraw all windows",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  " Quick exit        ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  " Uniconify window",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 18, 1,
  " Put on desktop ",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 17, 1,
  "-------------------",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 20, 1,
  " Close icon window",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, -1, 19, 1,
  "12345678901234567890123456789012",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1180, 0, 0, 33, 1,
  "OK",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -3, 3, 1,
  "\0",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, 2, 1, 1,
  "Button",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 1,
  "Button",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 1,
  "Button",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 7, 1
};

static WORD RSBB0DATA[] =
{ 0x007F, 0xFC00, 0x01FF, 0xFF00, 
  0x03FF, 0xFF80, 0x07FF, 0xFFC0, 
  0x07E0, 0x0FC0, 0x07C0, 0x07C0, 
  0x07C0, 0x07C0, 0x0380, 0x0FC0, 
  0x0000, 0x0F80, 0x0000, 0x1F80, 
  0x0000, 0x3F00, 0x0000, 0x7E00, 
  0x0000, 0xFC00, 0x0001, 0xF800, 
  0x0003, 0xF000, 0x0007, 0xE000, 
  0x0007, 0xC000, 0x000F, 0xC000, 
  0x000F, 0x8000, 0x000F, 0x8000, 
  0x000F, 0x8000, 0x000F, 0x8000, 
  0x0007, 0x0000, 0x0000, 0x0000, 
  0x0000, 0x0000, 0x000F, 0x8000, 
  0x001F, 0xC000, 0x001F, 0xC000, 
  0x001F, 0xC000, 0x000F, 0x8000
};

static WORD RSBB1DATA[] =
{ 0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF
};

static BITBLK rs_bitblk[] =
{ RSBB0DATA,   4,  30,   0,   0, 0x0001,
  RSBB1DATA,   4,  32,   0,   0, 0x0001
};

static OBJECT rs_object[] =
{ 
  /******** Tree 0 WINPOP ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001143L,
  0x0000, 0x0000, 0x0412, 0x0402,
         0, WPCLOSE , WPICON  , G_BOX     ,   /* Object 1  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0100, 0x0100, 0x0012, 0x0002,
  WPICON  ,       -1,       -1, G_TEXT    ,   /* Object 2 WPCLOSE */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x0000, 0x0012, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 3 WPICON */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)&rs_tedinfo[1],
  0x0000, 0x0001, 0x0012, 0x0001,
  
  /******** Tree 1 CASCPOP ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001143L,
  0x0000, 0x0000, 0x0413, 0x0407,
         0, WPCASC  , WPPRIO  , G_BOX     ,   /* Object 1  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0100, 0x0100, 0x0013, 0x0007,
  WPPTB   ,       -1,       -1, G_TEXT    ,   /* Object 2 WPCASC */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[2],
  0x0000, 0x0002, 0x0013, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3 WPPTB */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[3],
  0x0000, 0x0003, 0x0013, 0x0001,
  WPAOT   ,       -1,       -1, G_TEXT    |0x2800,   /* Object 4  */
  NONE, DISABLED, (LONG)&rs_tedinfo[4],
  0x0000, 0x0004, 0x0013, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 5 WPPRIO */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[5],
  0x0000, 0x0005, 0x0013, 0x0001,
  WPPRIO  ,       -1,       -1, G_TEXT    ,   /* Object 6 WPBEVENT */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[6],
  0x0000, 0x0006, 0x0013, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7 WPAOT */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[7],
  0x0000, 0x0000, 0x0013, 0x0001,
  WPBEVENT,       -1,       -1, G_TEXT    |0x2800,   /* Object 8  */
  LASTOB, DISABLED, (LONG)&rs_tedinfo[8],
  0x0000, 0x0001, 0x0013, 0x0001,
  
  /******** Tree 2 FULLPOP ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001143L,
  0x0000, 0x0000, 0x0412, 0x0402,
         0, WPMAX   , WPMIN   , G_BOX     ,   /* Object 1  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0100, 0x0100, 0x0012, 0x0002,
  WPMIN   ,       -1,       -1, G_TEXT    ,   /* Object 2 WPMAX */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[9],
  0x0000, 0x0000, 0x0012, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 3 WPMIN */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)&rs_tedinfo[10],
  0x0000, 0x0001, 0x0012, 0x0001,
  
  /******** Tree 3 RTPOP ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001143L,
  0x0000, 0x0000, 0x0413, 0x0409,
         0, WHATIS  , FORCEXIT, G_BOX     ,   /* Object 1  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0100, 0x0100, 0x0013, 0x0009,
         3,       -1,       -1, G_TEXT    ,   /* Object 2 WHATIS */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[11],
  0x0000, 0x0000, 0x0013, 0x0001,
  CLOSEWIN,       -1,       -1, G_TEXT    |0x2800,   /* Object 3  */
  NONE, DISABLED, (LONG)&rs_tedinfo[12],
  0x0000, 0x0001, 0x0013, 0x0001,
  CYCLEWIN,       -1,       -1, G_TEXT    ,   /* Object 4 CLOSEWIN */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[13],
  0x0000, 0x0002, 0x0013, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5 CYCLEWIN */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[14],
  0x0000, 0x0003, 0x0013, 0x0001,
  CLOSEALL,       -1,       -1, G_TEXT    |0x2800,   /* Object 6  */
  NONE, DISABLED, (LONG)&rs_tedinfo[15],
  0x0000, 0x0007, 0x0013, 0x0001,
  REDRWIN ,       -1,       -1, G_TEXT    ,   /* Object 7 CLOSEALL */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[16],
  0x0000, 0x0004, 0x0013, 0x0001,
  REDRALL ,       -1,       -1, G_TEXT    ,   /* Object 8 REDRWIN */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[17],
  0x0000, 0x0005, 0x0013, 0x0001,
  FORCEXIT,       -1,       -1, G_TEXT    ,   /* Object 9 REDRALL */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[18],
  0x0000, 0x0006, 0x0013, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 10 FORCEXIT */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)&rs_tedinfo[19],
  0x0000, 0x0008, 0x0013, 0x0001,
  
  /******** Tree 4 ICONPOP ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001143L,
  0x0000, 0x0000, 0x0413, 0x0404,
         0, UNICON  , CLOICON , G_BOX     ,   /* Object 1  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0100, 0x0100, 0x0013, 0x0004,
  PODICON ,       -1,       -1, G_TEXT    ,   /* Object 2 UNICON */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[20],
  0x0000, 0x0000, 0x0013, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3 PODICON */
  SELECTABLE|EXIT, NORMAL, (LONG)&rs_tedinfo[21],
  0x0000, 0x0001, 0x0013, 0x0001,
  CLOICON ,       -1,       -1, G_TEXT    |0x2800,   /* Object 4  */
  NONE, DISABLED, (LONG)&rs_tedinfo[22],
  0x0000, 0x0002, 0x0013, 0x0001,
         1,       -1,       -1, G_TEXT    ,   /* Object 5 CLOICON */
  SELECTABLE|EXIT|LASTOB, NORMAL, (LONG)&rs_tedinfo[23],
  0x0000, 0x0003, 0x0013, 0x0001,
  
  /******** Tree 5 HELPWIN ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001143L,
  0x0000, 0x0000, 0x0426, 0x010A,
         0, HELPTITL, HELPOK  , G_BOX     ,   /* Object 1  */
  FLAGS10, SHADOWED, (LONG)0x00FF1100L,
  0x0100, 0x0100, 0x0026, 0x050A,
  HELPWORK,       -1,       -1, G_TEXT    ,   /* Object 2 HELPTITL */
  NONE, NORMAL, (LONG)&rs_tedinfo[24],
  0x0400, 0x0300, 0x0020, 0x0001,
         4,       -1,       -1, G_BOX     |0x1400,   /* Object 3 HELPWORK */
  FLAGS9|FLAGS10, DRAW3D|WHITEBAK, (LONG)0x00FF1100L,
  0x0300, 0x0601, 0x0620, 0x0408,
  HELPOK  ,       -1,       -1, G_IMAGE   ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_bitblk[0],
  0x0721, 0x0200, 0x0004, 0x0603,
         1,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 5 HELPOK */
  SELECTABLE|EXIT|LASTOB|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[25],
  0x0721, 0x0607, 0x0403, 0x0202,
  
  /******** Tree 6 LISTBOX ****************************************************/
        -1, LBUP    , LBTEXT7 , G_BOX     |0x1200,   /* Object 0  */
  FLAGS9|FLAGS10, SHADOWED|DRAW3D, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0720, 0x0108,
  LBVERTRK,       -1,       -1, G_BOXCHAR |0x6600,   /* Object 1 LBUP */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG) ((LONG)'\001' << 24)|0x00FF1100L,
  0x011E, 0x0000, 0x0602, 0x0001,
  LBHORTRK, LBVERSL , LBVERSL , G_BOX     |0x6800,   /* Object 2 LBVERTRK */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1141L,
  0x011E, 0x0101, 0x0602, 0x0604,
  LBVERTRK,       -1,       -1, G_BOX     |0x6900,   /* Object 3 LBVERSL */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0602, 0x0503,
  LBDOWN  , LBHORSL , LBHORSL , G_BOX     |0x6800,   /* Object 4 LBHORTRK */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1141L,
  0x0003, 0x0107, 0x0018, 0x0001,
  LBHORTRK,       -1,       -1, G_BOX     |0x6900,   /* Object 5 LBHORSL */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0516, 0x0001,
  LBLEFT  ,       -1,       -1, G_BOXCHAR |0x6700,   /* Object 6 LBDOWN */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG) ((LONG)'\002' << 24)|0x00FF1100L,
  0x011E, 0x0006, 0x0602, 0x0001,
  LBRIGHT ,       -1,       -1, G_BOXCHAR |0x6400,   /* Object 7 LBLEFT */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG) ((LONG)'\004' << 24)|0x00FF1100L,
  0x0000, 0x0107, 0x0702, 0x0001,
  LBTEXT1 ,       -1,       -1, G_BOXCHAR |0x6500,   /* Object 8 LBRIGHT */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG) ((LONG)'\003' << 24)|0x00FF1100L,
  0x011B, 0x0107, 0x0702, 0x0001,
  LBTEXT2 ,       -1,       -1, G_STRING  ,   /* Object 9 LBTEXT1 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0000, 0x001E, 0x0001,
  LBTEXT3 ,       -1,       -1, G_STRING  ,   /* Object 10 LBTEXT2 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0001, 0x001E, 0x0001,
  LBTEXT4 ,       -1,       -1, G_STRING  ,   /* Object 11 LBTEXT3 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0002, 0x001E, 0x0001,
  LBTEXT5 ,       -1,       -1, G_STRING  ,   /* Object 12 LBTEXT4 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0003, 0x001E, 0x0001,
  LBTEXT6 ,       -1,       -1, G_STRING  ,   /* Object 13 LBTEXT5 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0004, 0x001E, 0x0001,
  LBTEXT7 ,       -1,       -1, G_STRING  ,   /* Object 14 LBTEXT6 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0005, 0x001E, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 15 LBTEXT7 */
  SELECTABLE|LASTOB|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0006, 0x001E, 0x0001,
  
  /******** Tree 7 POPUP ****************************************************/
        -1, PUUP    , PUTEXT10, G_BOX     ,   /* Object 0  */
  FLAGS9|FLAGS10, SHADOWED|DRAW3D, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0021, 0x000A,
  PUVERTRK,       -1,       -1, G_BOXCHAR |0x6600,   /* Object 1 PUUP */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG) ((LONG)'\001' << 24)|0x00FF1100L,
  0x011E, 0x0000, 0x0602, 0x0001,
  PUDOWN  , PUVERSL , PUVERSL , G_BOX     |0x6800,   /* Object 2 PUVERTRK */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1141L,
  0x011E, 0x0101, 0x0602, 0x0607,
  PUVERTRK,       -1,       -1, G_BOX     |0x6900,   /* Object 3 PUVERSL */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0602, 0x0307,
  PUTEXT1 ,       -1,       -1, G_BOXCHAR |0x6700,   /* Object 4 PUDOWN */
  SELECTABLE|TOUCHEXIT|FLAGS9|FLAGS10, DRAW3D, (LONG) ((LONG)'\002' << 24)|0x00FF1100L,
  0x011E, 0x0009, 0x0602, 0x0001,
  PUTEXT2 ,       -1,       -1, G_STRING  ,   /* Object 5 PUTEXT1 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0000, 0x001E, 0x0001,
  PUTEXT3 ,       -1,       -1, G_STRING  ,   /* Object 6 PUTEXT2 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0001, 0x001E, 0x0001,
  PUTEXT4 ,       -1,       -1, G_STRING  ,   /* Object 7 PUTEXT3 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0002, 0x001E, 0x0001,
  PUTEXT5 ,       -1,       -1, G_STRING  ,   /* Object 8 PUTEXT4 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0003, 0x001E, 0x0001,
  PUTEXT6 ,       -1,       -1, G_STRING  ,   /* Object 9 PUTEXT5 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0004, 0x001E, 0x0001,
  PUTEXT7 ,       -1,       -1, G_STRING  ,   /* Object 10 PUTEXT6 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0005, 0x001E, 0x0001,
  PUTEXT8 ,       -1,       -1, G_STRING  ,   /* Object 11 PUTEXT7 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0006, 0x001E, 0x0001,
  PUTEXT9 ,       -1,       -1, G_STRING  ,   /* Object 12 PUTEXT8 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0007, 0x001E, 0x0001,
  PUTEXT10,       -1,       -1, G_STRING  ,   /* Object 13 PUTEXT9 */
  SELECTABLE|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0008, 0x001E, 0x0001,
         0,       -1,       -1, G_STRING  ,   /* Object 14 PUTEXT10 */
  SELECTABLE|LASTOB|TOUCHEXIT, NORMAL, (LONG)"123456789012345678901234567890",
  0x0000, 0x0009, 0x001E, 0x0001,
  
  /******** Tree 8 ALERTBOX ****************************************************/
        -1,        1,        1, G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001143L,
  0x0000, 0x0000, 0x062E, 0x0008,
         0, ALICON  , ALBUT3  , G_BOXTEXT |0x1200,   /* Object 1  */
  FLAGS9|FLAGS10, OUTLINED|DRAW3D, (LONG)&rs_tedinfo[26],
  0x0300, 0x0300, 0x002E, 0x0207,
  ALLINE1 ,       -1,       -1, G_IMAGE   ,   /* Object 2 ALICON */
  NONE, NORMAL, (LONG)&rs_bitblk[1],
  0x0700, 0x0001, 0x0004, 0x0004,
  ALLINE2 ,       -1,       -1, G_STRING  ,   /* Object 3 ALLINE1 */
  NONE, NORMAL, (LONG)"1234567890123456789012345678901234567890",
  0x0405, 0x0400, 0x0028, 0x0001,
  ALLINE3 ,       -1,       -1, G_STRING  ,   /* Object 4 ALLINE2 */
  NONE, NORMAL, (LONG)"1234567890123456789012345678901234567890",
  0x0405, 0x0401, 0x0028, 0x0001,
  ALLINE4 ,       -1,       -1, G_STRING  ,   /* Object 5 ALLINE3 */
  NONE, NORMAL, (LONG)"1234567890123456789012345678901234567890",
  0x0405, 0x0402, 0x0028, 0x0001,
  ALLINE5 ,       -1,       -1, G_STRING  ,   /* Object 6 ALLINE4 */
  NONE, NORMAL, (LONG)"1234567890123456789012345678901234567890",
  0x0405, 0x0403, 0x0028, 0x0001,
  ALBUT1  ,       -1,       -1, G_STRING  ,   /* Object 7 ALLINE5 */
  NONE, NORMAL, (LONG)"1234567890123456789012345678901234567890",
  0x0405, 0x0404, 0x0028, 0x0001,
  ALBUT2  ,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 8 ALBUT1 */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[27],
  0x050B, 0x0605, 0x0008, 0x0001,
  ALBUT3  ,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 9 ALBUT2 */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[28],
  0x0314, 0x0605, 0x0008, 0x0001,
         1,       -1,       -1, G_BOXTEXT |0x1200,   /* Object 10 ALBUT3 */
  SELECTABLE|EXIT|LASTOB|FLAGS9|FLAGS10, DRAW3D, (LONG)&rs_tedinfo[29],
  0x001D, 0x0605, 0x0008, 0x0001,
  
  /******** Tree 9 VIRT ****************************************************/
        -1, VDESK1  , VDESK7  , G_BOX     ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00FF1101L,
  0x0000, 0x0000, 0x0418, 0x0109,
  VDESK2  ,       -1,       -1, G_BOX     ,   /* Object 1 VDESK1 */
  NONE, NORMAL, (LONG)0x00FF1172L,
  0x0000, 0x0000, 0x0008, 0x0702,
  VDESK3  ,       -1,       -1, G_BOX     ,   /* Object 2 VDESK2 */
  NONE, NORMAL, (LONG)0x00FF1172L,
  0x0208, 0x0000, 0x0008, 0x0702,
  VDESK4  ,       -1,       -1, G_BOX     ,   /* Object 3 VDESK3 */
  NONE, NORMAL, (LONG)0x00FF1172L,
  0x0410, 0x0000, 0x0008, 0x0702,
  VDESK5  ,       -1,       -1, G_BOX     ,   /* Object 4 VDESK4 */
  NONE, NORMAL, (LONG)0x00FF1172L,
  0x0000, 0x0103, 0x0008, 0x0702,
  VDESK6  ,       -1,       -1, G_BOX     ,   /* Object 5 VDESK5 */
  NONE, NORMAL, (LONG)0x00FF1172L,
  0x0208, 0x0103, 0x0008, 0x0702,
  VDESK8  ,       -1,       -1, G_BOX     ,   /* Object 6 VDESK6 */
  NONE, NORMAL, (LONG)0x00FF1172L,
  0x0410, 0x0103, 0x0008, 0x0702,
  VDESK9  ,       -1,       -1, G_BOX     ,   /* Object 7 VDESK8 */
  NONE, NORMAL, (LONG)0x00FF1172L,
  0x0208, 0x0206, 0x0008, 0x0702,
  VDESK7  ,       -1,       -1, G_BOX     ,   /* Object 8 VDESK9 */
  NONE, NORMAL, (LONG)0x00FF1172L,
  0x0410, 0x0206, 0x0008, 0x0702,
         0,       -1,       -1, G_BOX     ,   /* Object 9 VDESK7 */
  LASTOB, NORMAL, (LONG)0x00FF1172L,
  0x0000, 0x0206, 0x0008, 0x0702
};

static OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 WINPOP   */
  &rs_object[4],   /* Tree  1 CASCPOP  */
  &rs_object[13],   /* Tree  2 FULLPOP  */
  &rs_object[17],   /* Tree  3 RTPOP    */
  &rs_object[28],   /* Tree  4 ICONPOP  */
  &rs_object[34],   /* Tree  5 HELPWIN  */
  &rs_object[40],   /* Tree  6 LISTBOX  */
  &rs_object[56],   /* Tree  7 POPUP    */
  &rs_object[71],   /* Tree  8 ALERTBOX */
  &rs_object[82]    /* Tree  9 VIRT     */
};
