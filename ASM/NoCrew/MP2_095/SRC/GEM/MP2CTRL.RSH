/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "MP2CTRL.H"

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
{ "SONG: MPEGFILE",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, 0, 15, 1,
  "MPEG Audio",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -1, 11, 1,
  "Version 0.0000000000000",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 24, 1,
  "DSP decoder",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 12, 1,
  "Fredrik Noring",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 15, 1,
  "fredrik@noring.org",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1100, 0, 0, 19, 1,
  "GEM interface",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, 0, 14, 1,
  "Tomas Berndtsson",
  "\0",
  "\0",
  IBM  , 0, TE_RIGHT, 0x1100, 0, 0, 17, 1,
  "tomas@nocrew.pp.se",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1100, 0, 0, 19, 1,
  "http://noring.org/mp2/",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 23, 1,
  "\275 1996",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, 0, 7, 1,
  "NoCrew Laboratories",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, 0, 20, 1,
  "SONG: MPEGFILE",
  "\0",
  "\0",
  SMALL, 0, TE_LEFT , 0x1100, 0, 0, 15, 1,
  "MPEG Audio",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1100, 0, -1, 11, 1,
  "Version 0.0000000000000",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, -1, 24, 1,
  "DSP decoder",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1C00, 0, -1, 12, 1,
  "Fredrik Noring",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1100, 0, -1, 15, 1,
  "fredrik@noring.org",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1100, 0, 0, 19, 1,
  "GEM interface",
  "\0",
  "\0",
  IBM  , 0, TE_LEFT , 0x1C00, 0, 0, 14, 1,
  "Tomas Berndtsson",
  "\0",
  "\0",
  IBM  , 0, TE_RIGHT, 0x1100, 0, 0, 17, 1,
  "tomas@nocrew.pp.se",
  "\0",
  "\0",
  SMALL, 0, TE_RIGHT, 0x1100, 0, 0, 19, 1,
  "http://noring.org/mp2/",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1C00, 0, -1, 23, 1,
  "\275 1996",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, 0, 7, 1,
  "NoCrew Laboratories",
  "\0",
  "\0",
  SMALL, 0, TE_CNTR , 0x1100, 0, 0, 20, 1
};

RSIB0MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0180, 
  0x03C0, 0x07E0, 0x0FF0, 0x1FF8, 
  0x1FF8, 0x0000, 0x1FF8, 0x0000, 
  0x1FF8, 0x0000, 0x0000, 0x0000
};

RSIB0DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0180, 
  0x03C0, 0x07E0, 0x0FF0, 0x1FF8, 
  0x1FF8, 0x0000, 0x1FF8, 0x0000, 
  0x1FF8, 0x0000, 0x0000, 0x0000
};

RSIB1MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x1FF8, 
  0x1FF8, 0x1FF8, 0x1FF8, 0x1FF8, 
  0x1FF8, 0x1FF8, 0x1FF8, 0x1FF8, 
  0x1FF8, 0x0000, 0x0000, 0x0000
};

RSIB1DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x1FF8, 
  0x1FF8, 0x1FF8, 0x1FF8, 0x1FF8, 
  0x1FF8, 0x1FF8, 0x1FF8, 0x1FF8, 
  0x1FF8, 0x0000, 0x0000, 0x0000
};

RSIB2MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0600, 
  0x0700, 0x0780, 0x07C0, 0x07E0, 
  0x07E0, 0x07C0, 0x0780, 0x0700, 
  0x0600, 0x0000, 0x0000, 0x0000
};

RSIB2DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0600, 
  0x0700, 0x0780, 0x07C0, 0x07E0, 
  0x07E0, 0x07C0, 0x0780, 0x0700, 
  0x0600, 0x0000, 0x0000, 0x0000
};

RSIB3MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0E70, 
  0x0E70, 0x0E70, 0x0E70, 0x0E70, 
  0x0E70, 0x0E70, 0x0E70, 0x0E70, 
  0x0E70, 0x0000, 0x0000, 0x0000
};

RSIB3DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0E70, 
  0x0E70, 0x0E70, 0x0E70, 0x0E70, 
  0x0E70, 0x0E70, 0x0E70, 0x0E70, 
  0x0E70, 0x0000, 0x0000, 0x0000
};

RSIB4MASK[] =
{ 0x0000, 0x0000, 0x0180, 0x03C0, 
  0x03C0, 0x0180, 0x0000, 0x07E0, 
  0x03C0, 0x03C0, 0x03C0, 0x03C0, 
  0x03C0, 0x07E0, 0x0000, 0x0000
};

RSIB4DATA[] =
{ 0x0000, 0x0000, 0x0180, 0x03C0, 
  0x03C0, 0x0180, 0x0000, 0x07E0, 
  0x03C0, 0x03C0, 0x03C0, 0x03C0, 
  0x03C0, 0x07E0, 0x0000, 0x0000
};

RSIB5MASK[] =
{ 0x0000, 0x0600, 0x0300, 0x0180, 
  0x0FD0, 0x19B8, 0x1378, 0x363C, 
  0x301C, 0x301C, 0x301C, 0x1838, 
  0x1FF8, 0x0FF0, 0x03C0, 0x0000
};

RSIB5DATA[] =
{ 0x0000, 0x0600, 0x0300, 0x0180, 
  0x0FD0, 0x19B8, 0x1378, 0x363C, 
  0x301C, 0x301C, 0x301C, 0x1838, 
  0x1FF8, 0x0FF0, 0x03C0, 0x0000
};

RSIB6MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x30C0, 
  0x38E0, 0x3CF0, 0x3EF8, 0x3FFC, 
  0x3FFC, 0x3EF8, 0x3CF0, 0x38E0, 
  0x30C0, 0x0000, 0x0000, 0x0000
};

RSIB6DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x30C0, 
  0x38E0, 0x3CF0, 0x3EF8, 0x3FFC, 
  0x3FFC, 0x3EF8, 0x3CF0, 0x38E0, 
  0x30C0, 0x0000, 0x0000, 0x0000
};

RSIB7MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0C30, 
  0x0E30, 0x0F30, 0x0FB0, 0x0FF0, 
  0x0FF0, 0x0FB0, 0x0F30, 0x0E30, 
  0x0C30, 0x0000, 0x0000, 0x0000
};

RSIB7DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0C30, 
  0x0E30, 0x0F30, 0x0FB0, 0x0FF0, 
  0x0FF0, 0x0FB0, 0x0F30, 0x0E30, 
  0x0C30, 0x0000, 0x0000, 0x0000
};

RSIB8MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0C30, 
  0x0C70, 0x0CF0, 0x0DF0, 0x0FF0, 
  0x0FF0, 0x0DF0, 0x0CF0, 0x0C70, 
  0x0C30, 0x0000, 0x0000, 0x0000
};

RSIB8DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0C30, 
  0x0C70, 0x0CF0, 0x0DF0, 0x0FF0, 
  0x0FF0, 0x0DF0, 0x0CF0, 0x0C70, 
  0x0C30, 0x0000, 0x0000, 0x0000
};

RSIB9MASK[] =
{ 0x0000, 0x0180, 0x03C0, 0x07E0, 
  0x0000, 0x4452, 0xAD55, 0xA471, 
  0xA412, 0xA514, 0x4417, 0x0000, 
  0x07E0, 0x03C0, 0x0180, 0x0000
};

RSIB9DATA[] =
{ 0x0000, 0x0180, 0x03C0, 0x07E0, 
  0x0000, 0x4452, 0xAD55, 0xA471, 
  0xA412, 0xA514, 0x4417, 0x0000, 
  0x07E0, 0x03C0, 0x0180, 0x0000
};

RSIB10MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0180, 
  0x03C0, 0x07E0, 0x0FF0, 0x1FF8, 
  0x1FF8, 0x0000, 0x1FF8, 0x0000, 
  0x1FF8, 0x0000, 0x0000, 0x0000
};

RSIB10DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0180, 
  0x03C0, 0x07E0, 0x0FF0, 0x1FF8, 
  0x1FF8, 0x0000, 0x1FF8, 0x0000, 
  0x1FF8, 0x0000, 0x0000, 0x0000
};

RSIB11MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x1FF8, 
  0x1FF8, 0x1FF8, 0x1FF8, 0x1FF8, 
  0x1FF8, 0x1FF8, 0x1FF8, 0x1FF8, 
  0x1FF8, 0x0000, 0x0000, 0x0000
};

RSIB11DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x1FF8, 
  0x1FF8, 0x1FF8, 0x1FF8, 0x1FF8, 
  0x1FF8, 0x1FF8, 0x1FF8, 0x1FF8, 
  0x1FF8, 0x0000, 0x0000, 0x0000
};

RSIB12MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0600, 
  0x0700, 0x0780, 0x07C0, 0x07E0, 
  0x07E0, 0x07C0, 0x0780, 0x0700, 
  0x0600, 0x0000, 0x0000, 0x0000
};

RSIB12DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0600, 
  0x0700, 0x0780, 0x07C0, 0x07E0, 
  0x07E0, 0x07C0, 0x0780, 0x0700, 
  0x0600, 0x0000, 0x0000, 0x0000
};

RSIB13MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0E70, 
  0x0E70, 0x0E70, 0x0E70, 0x0E70, 
  0x0E70, 0x0E70, 0x0E70, 0x0E70, 
  0x0E70, 0x0000, 0x0000, 0x0000
};

RSIB13DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0E70, 
  0x0E70, 0x0E70, 0x0E70, 0x0E70, 
  0x0E70, 0x0E70, 0x0E70, 0x0E70, 
  0x0E70, 0x0000, 0x0000, 0x0000
};

RSIB14MASK[] =
{ 0x0000, 0x0180, 0x03C0, 0x03C0, 
  0x0180, 0x0000, 0x07E0, 0x03C0, 
  0x03C0, 0x03C0, 0x03C0, 0x03C0, 
  0x03C0, 0x07E0, 0x0000, 0x0000
};

RSIB14DATA[] =
{ 0x0000, 0x0180, 0x03C0, 0x03C0, 
  0x0180, 0x0000, 0x07E0, 0x03C0, 
  0x03C0, 0x03C0, 0x03C0, 0x03C0, 
  0x03C0, 0x07E0, 0x0000, 0x0000
};

RSIB15MASK[] =
{ 0x0000, 0x0600, 0x0300, 0x0180, 
  0x0FD0, 0x19B8, 0x1378, 0x363C, 
  0x301C, 0x301C, 0x301C, 0x1838, 
  0x1FF8, 0x0FF0, 0x03C0, 0x0000
};

RSIB15DATA[] =
{ 0x0000, 0x0600, 0x0300, 0x0180, 
  0x0FD0, 0x19B8, 0x1378, 0x363C, 
  0x301C, 0x301C, 0x301C, 0x1838, 
  0x1FF8, 0x0FF0, 0x03C0, 0x0000
};

RSIB16MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x30C0, 
  0x38E0, 0x3CF0, 0x3EF8, 0x3FFC, 
  0x3FFC, 0x3EF8, 0x3CF0, 0x38E0, 
  0x30C0, 0x0000, 0x0000, 0x0000
};

RSIB16DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x30C0, 
  0x38E0, 0x3CF0, 0x3EF8, 0x3FFC, 
  0x3FFC, 0x3EF8, 0x3CF0, 0x38E0, 
  0x30C0, 0x0000, 0x0000, 0x0000
};

RSIB17MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0C30, 
  0x0E30, 0x0F30, 0x0FB0, 0x0FF0, 
  0x0FF0, 0x0FB0, 0x0F30, 0x0E30, 
  0x0C30, 0x0000, 0x0000, 0x0000
};

RSIB17DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0C30, 
  0x0E30, 0x0F30, 0x0FB0, 0x0FF0, 
  0x0FF0, 0x0FB0, 0x0F30, 0x0E30, 
  0x0C30, 0x0000, 0x0000, 0x0000
};

RSIB18MASK[] =
{ 0x0000, 0x0000, 0x0000, 0x0C30, 
  0x0C70, 0x0CF0, 0x0DF0, 0x0FF0, 
  0x0FF0, 0x0DF0, 0x0CF0, 0x0C70, 
  0x0C30, 0x0000, 0x0000, 0x0000
};

RSIB18DATA[] =
{ 0x0000, 0x0000, 0x0000, 0x0C30, 
  0x0C70, 0x0CF0, 0x0DF0, 0x0FF0, 
  0x0FF0, 0x0DF0, 0x0CF0, 0x0C70, 
  0x0C30, 0x0000, 0x0000, 0x0000
};

RSIB19MASK[] =
{ 0x0000, 0x0180, 0x03C0, 0x07E0, 
  0x0000, 0x4452, 0xAD55, 0xA471, 
  0xA412, 0xA514, 0x4417, 0x0000, 
  0x07E0, 0x03C0, 0x0180, 0x0000
};

RSIB19DATA[] =
{ 0x0000, 0x0180, 0x03C0, 0x07E0, 
  0x0000, 0x4452, 0xAD55, 0xA471, 
  0xA412, 0xA514, 0x4417, 0x0000, 
  0x07E0, 0x03C0, 0x0180, 0x0000
};

ICONBLK rs_iconblk[] =
{ RSIB0MASK, RSIB0DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB1MASK, RSIB1DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB2MASK, RSIB2DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB3MASK, RSIB3DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB4MASK, RSIB4DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB5MASK, RSIB5DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB6MASK, RSIB6DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB7MASK, RSIB7DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB8MASK, RSIB8DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB9MASK, RSIB9DATA, "\0", 0x1000|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB10MASK, RSIB10DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB11MASK, RSIB11DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB12MASK, RSIB12DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB13MASK, RSIB13DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB14MASK, RSIB14DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB15MASK, RSIB15DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB16MASK, RSIB16DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB17MASK, RSIB17DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB18MASK, RSIB18DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8,
  RSIB19MASK, RSIB19DATA, "\0", 0x1800|'\0',
    0,   0,   0,   0,  16,  16,   0,   0,   0,   8
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 FORM_CTRL1 ****************************************************/
        -1, CTRL_LOAD, CTRL_TIME, G_BOX     |0x0100,   /* Object 0 CTRL_FIRST */
  FLAGS9|FLAGS10|FLAGS14|FLAGS15, NORMAL, (LONG)0x00021188L,
  0x0000, 0x0000, 0x040C, 0x0403,
  CTRL_STOP,        2,        2, G_BOX     |0x0100,   /* Object 1 CTRL_LOAD */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001170L,
  0x0200, 0x0202, 0x0002, 0x0001,
  CTRL_LOAD,       -1,       -1, G_ICON    ,   /* Object 2  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[0],
  0x0000, 0x0000, 0x0002, 0x0001,
  CTRL_PLAY,        4,        4, G_BOX     |0x0100,   /* Object 3 CTRL_STOP */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001170L,
  0x0205, 0x0202, 0x0002, 0x0001,
  CTRL_STOP,       -1,       -1, G_ICON    ,   /* Object 4  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[1],
  0x0000, 0x0000, 0x0002, 0x0001,
  CTRL_PAUSE,        6,        6, G_BOX     |0x0100,   /* Object 5 CTRL_PLAY */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001170L,
  0x0602, 0x0E00, 0x0002, 0x0001,
  CTRL_PLAY,       -1,       -1, G_ICON    ,   /* Object 6  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[2],
  0x0000, 0x0000, 0x0002, 0x0001,
  CTRL_INFO,        8,        8, G_BOX     |0x0100,   /* Object 7 CTRL_PAUSE */
  SELECTABLE|EXIT|FLAGS9|FLAGS10|FLAGS15, NORMAL, (LONG)0x00001170L,
  0x0602, 0x0202, 0x0002, 0x0001,
  CTRL_PAUSE,       -1,       -1, G_ICON    ,   /* Object 8  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[3],
  0x0000, 0x0000, 0x0002, 0x0001,
  CTRL_LOOP,       10,       10, G_BOX     ,   /* Object 9 CTRL_INFO */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001170L,
  0x020A, 0x0E00, 0x0002, 0x0001,
  CTRL_INFO,       -1,       -1, G_ICON    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_iconblk[4],
  0x0000, 0x0000, 0x0002, 0x0001,
  CTRL_FF ,       12,       12, G_BOX     ,   /* Object 11 CTRL_LOOP */
  SELECTABLE|EXIT|FLAGS9|FLAGS10|FLAGS15, NORMAL, (LONG)0x00001170L,
  0x0607, 0x0202, 0x0002, 0x0001,
  CTRL_LOOP,       -1,       -1, G_ICON    ,   /* Object 12  */
  NONE, NORMAL, (LONG)&rs_iconblk[5],
  0x0000, 0x0000, 0x0002, 0x0001,
  CTRL_NEXT,       14,       14, G_BOX     |0x0100,   /* Object 13 CTRL_FF */
  SELECTABLE|EXIT|FLAGS9|FLAGS10|FLAGS15, NORMAL, (LONG)0x00001170L,
  0x0205, 0x0E00, 0x0002, 0x0001,
  CTRL_FF ,       -1,       -1, G_ICON    ,   /* Object 14  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[6],
  0x0000, 0x0000, 0x0002, 0x0001,
  CTRL_PREV,       16,       16, G_BOX     |0x0100,   /* Object 15 CTRL_NEXT */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001170L,
  0x0607, 0x0E00, 0x0002, 0x0001,
  CTRL_NEXT,       -1,       -1, G_ICON    ,   /* Object 16  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[7],
  0x0000, 0x0000, 0x0002, 0x0001,
  CTRL_FNAME_BOX,       18,       18, G_BOX     |0x0100,   /* Object 17 CTRL_PREV */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001170L,
  0x0200, 0x0E00, 0x0002, 0x0001,
  CTRL_PREV,       -1,       -1, G_ICON    ,   /* Object 18  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[8],
  0x0000, 0x0000, 0x0002, 0x0001,
  CTRL_FILENAME,       -1,       -1, G_BOX     ,   /* Object 19 CTRL_FNAME_BOX */
  FLAGS9|FLAGS10, NORMAL, (LONG)0x00001170L,
  0x0200, 0x0200, 0x000C, 0x0800,
  CTRL_TIME,       -1,       -1, G_TEXT    ,   /* Object 20 CTRL_FILENAME */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0001, 0x0200, 0x040A, 0x0800,
  CTRL_FIRST,       22,       22, G_BOX     ,   /* Object 21 CTRL_TIME */
  SELECTABLE|EXIT|FLAGS9|FLAGS10|FLAGS15, NORMAL, (LONG)0x00001170L,
  0x020A, 0x0202, 0x0002, 0x0001,
  CTRL_TIME,       -1,       -1, G_ICON    ,   /* Object 22  */
  LASTOB, NORMAL, (LONG)&rs_iconblk[9],
  0x0000, 0x0000, 0x0002, 0x0001,
  
  /******** Tree 1 FORM_INFO1 ****************************************************/
        -1,        1,       11, G_BOX     ,   /* Object 0 INFO_FIRST */
  NONE, NORMAL, (LONG)0x00011100L,
  0x0000, 0x0000, 0x0014, 0x000B,
  INFO_VERSION,       -1,       -1, G_TEXT    ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0000, 0x0800, 0x0014, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2 INFO_VERSION */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0000, 0x0601, 0x0014, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0001, 0x0B03, 0x000B, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0003, 0x0C04, 0x000E, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0003, 0x0A05, 0x040D, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0001, 0x0E06, 0x000D, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[7],
  0x0003, 0x0E07, 0x0010, 0x0401,
         9,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[8],
  0x0003, 0x0E08, 0x040D, 0x0001,
        10,       -1,       -1, G_TEXT    ,   /* Object 9  */
  NONE, NORMAL, (LONG)&rs_tedinfo[9],
  0x0000, 0x000A, 0x0014, 0x0001,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[10],
  0x0000, 0x0002, 0x0014, 0x0001,
  INFO_FIRST,       -1,       -1, G_TEXT    ,   /* Object 11  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[11],
  0x0000, 0x0802, 0x0014, 0x0001,
  
  /******** Tree 2 FORM_CTRL4 ****************************************************/
        -1,        1,       21, G_BOX     |0x0100,   /* Object 0  */
  FLAGS9|FLAGS10|FLAGS14|FLAGS15, NORMAL, (LONG)0x000211F8L,
  0x0000, 0x0000, 0x040C, 0x0403,
         3,        2,        2, G_BOX     |0x0100,   /* Object 1  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001178L,
  0x0200, 0x0202, 0x0002, 0x0001,
         1,       -1,       -1, G_ICON    ,   /* Object 2  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[10],
  0x0000, 0x0000, 0x0002, 0x0001,
         5,        4,        4, G_BOX     |0x0100,   /* Object 3  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001178L,
  0x0205, 0x0202, 0x0002, 0x0001,
         3,       -1,       -1, G_ICON    ,   /* Object 4  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[11],
  0x0000, 0x0000, 0x0002, 0x0001,
         7,        6,        6, G_BOX     |0x0100,   /* Object 5  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001178L,
  0x0602, 0x0E00, 0x0002, 0x0001,
         5,       -1,       -1, G_ICON    ,   /* Object 6  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[12],
  0x0000, 0x0000, 0x0002, 0x0001,
         9,        8,        8, G_BOX     |0x0100,   /* Object 7  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10|FLAGS15, NORMAL, (LONG)0x00001178L,
  0x0602, 0x0202, 0x0002, 0x0001,
         7,       -1,       -1, G_ICON    ,   /* Object 8  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[13],
  0x0000, 0x0000, 0x0002, 0x0001,
        11,       10,       10, G_BOX     ,   /* Object 9  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001178L,
  0x020A, 0x0E00, 0x0002, 0x0001,
         9,       -1,       -1, G_ICON    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_iconblk[14],
  0x0000, 0x0000, 0x0002, 0x0001,
        13,       12,       12, G_BOX     ,   /* Object 11  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10|FLAGS15, NORMAL, (LONG)0x00001178L,
  0x0607, 0x0202, 0x0002, 0x0001,
        11,       -1,       -1, G_ICON    ,   /* Object 12  */
  NONE, NORMAL, (LONG)&rs_iconblk[15],
  0x0000, 0x0000, 0x0002, 0x0001,
        15,       14,       14, G_BOX     |0x0100,   /* Object 13  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10|FLAGS15, NORMAL, (LONG)0x00001178L,
  0x0205, 0x0E00, 0x0002, 0x0001,
        13,       -1,       -1, G_ICON    ,   /* Object 14  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[16],
  0x0000, 0x0000, 0x0002, 0x0001,
        17,       16,       16, G_BOX     |0x0100,   /* Object 15  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001178L,
  0x0607, 0x0E00, 0x0002, 0x0001,
        15,       -1,       -1, G_ICON    ,   /* Object 16  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[17],
  0x0000, 0x0000, 0x0002, 0x0001,
        19,       18,       18, G_BOX     |0x0100,   /* Object 17  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)0x00001178L,
  0x0200, 0x0E00, 0x0002, 0x0001,
        17,       -1,       -1, G_ICON    ,   /* Object 18  */
  FLAGS12, NORMAL, (LONG)&rs_iconblk[18],
  0x0000, 0x0000, 0x0002, 0x0001,
        20,       -1,       -1, G_BOX     ,   /* Object 19  */
  FLAGS9|FLAGS10, NORMAL, (LONG)0x00001178L,
  0x0200, 0x0200, 0x000C, 0x0800,
        21,       -1,       -1, G_TEXT    ,   /* Object 20  */
  NONE, NORMAL, (LONG)&rs_tedinfo[12],
  0x0001, 0x0200, 0x040A, 0x0800,
         0,       22,       22, G_BOX     ,   /* Object 21  */
  SELECTABLE|EXIT|FLAGS9|FLAGS10|FLAGS15, NORMAL, (LONG)0x00001178L,
  0x020A, 0x0202, 0x0002, 0x0001,
        21,       -1,       -1, G_ICON    ,   /* Object 22  */
  LASTOB, NORMAL, (LONG)&rs_iconblk[19],
  0x0000, 0x0000, 0x0002, 0x0001,
  
  /******** Tree 3 FORM_INFO4 ****************************************************/
        -1,        1,       11, G_BOX     ,   /* Object 0  */
  FLAGS9|FLAGS10, NORMAL, (LONG)0x00011178L,
  0x0000, 0x0000, 0x0014, 0x000B,
         2,       -1,       -1, G_TEXT    ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_tedinfo[13],
  0x0000, 0x0800, 0x0014, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[14],
  0x0000, 0x0601, 0x0014, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[15],
  0x0001, 0x0B03, 0x000B, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[16],
  0x0003, 0x0C04, 0x000E, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[17],
  0x0003, 0x0A05, 0x040D, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[18],
  0x0001, 0x0E06, 0x000D, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[19],
  0x0003, 0x0E07, 0x0010, 0x0401,
         9,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[20],
  0x0003, 0x0E08, 0x040D, 0x0001,
        10,       -1,       -1, G_TEXT    ,   /* Object 9  */
  NONE, NORMAL, (LONG)&rs_tedinfo[21],
  0x0000, 0x000A, 0x0014, 0x0001,
        11,       -1,       -1, G_TEXT    ,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[22],
  0x0000, 0x0002, 0x0014, 0x0001,
         0,       -1,       -1, G_TEXT    ,   /* Object 11  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[23],
  0x0000, 0x0802, 0x0014, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 FORM_CTRL1 */
  &rs_object[23],   /* Tree  1 FORM_INFO1 */
  &rs_object[35],   /* Tree  2 FORM_CTRL4 */
  &rs_object[58]    /* Tree  3 FORM_INFO4 */
};
