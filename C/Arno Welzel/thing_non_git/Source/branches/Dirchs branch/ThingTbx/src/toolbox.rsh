/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "TOOLBOX.H"

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
{ "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 41, 1,
  "\177 \001 \002 \003 \004 \005 \006 \007 \010 \011 \012 \013 \014 \015 \016 \017",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1,
  "\020 \021 \022 \023 \024 \025 \026 \027 \030 \031 \032 \033 \034 \035 \036 \037",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1,
  "\200 \201 \202 \203 \204 \205 \206 \207 \210 \211 \212 \213 \214 \215 \216 \217",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1,
  "\220 \221 \222 \223 \224 \225 \226 \227 \230 \231 \232 \233 \234 \235 \236 \237",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1,
  "\240 \241 \242 \243 \244 \245 \246 \247 \250 \251 \252 \253 \254 \255 \256 \257",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1,
  "\260 \261 \262 \263 \264 \265 \266 \267 \270 \271 \272 \273 \274 \275 \276 \277",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1,
  "\300 \301 \302 \303 \304 \305 \306 \307 \310 \311 \312 \313 \314 \315 \316 \317",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1,
  "\320 \321 \322 \323 \324 \325 \326 \327 \330 \331 \332 \333 \334 \335 \336 \337",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1,
  "\340 \341 \342 \343 \344 \345 \346 \347 \350 \351 \352 \353 \354 \355 \356 \357",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1,
  "\360 \361 \362 \363 \364 \365 \366 \367 \370 \371 \372 \373 \374 \375 \376 \377",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 32, 1
};

static WORD RSBB0DATA[] =
{ 0x3FFF, 0xFFFC, 0x7FFF, 0xFFFE, 
  0x7FFC, 0x3FFE, 0x7FF8, 0x1FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF8, 0x1FFE, 
  0x7FFC, 0x3FFE, 0x7FFF, 0xFFFE, 
  0x7FFF, 0xFFFE, 0x7FC0, 0x1FFE, 
  0x7F80, 0x0FFE, 0x7F80, 0x0FFE, 
  0x7FC0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7F80, 0x01FE, 
  0x7F00, 0x00FE, 0x7F00, 0x00FE, 
  0x7F80, 0x01FE, 0x7FFF, 0xFFFE, 
  0x3FFF, 0xFFFC, 0x0000, 0x0000
};

static WORD RSBB1DATA[] =
{ 0x3FFF, 0xFFFC, 0x7FFF, 0xFFFE, 
  0x7F80, 0x01FE, 0x7F00, 0x00FE, 
  0x7E00, 0x007E, 0x7E00, 0x007E, 
  0x7E00, 0x007E, 0x7E03, 0xC07E, 
  0x7E07, 0xC07E, 0x7F0F, 0x807E, 
  0x7FFF, 0x007E, 0x7FFE, 0x007E, 
  0x7FFC, 0x00FE, 0x7FF8, 0x01FE, 
  0x7FF8, 0x03FE, 0x7FF0, 0x07FE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x1FFE, 
  0x7FF0, 0x1FFE, 0x7FF8, 0x3FFE, 
  0x7FFF, 0xFFFE, 0x7FFF, 0xFFFE, 
  0x7FFC, 0x3FFE, 0x7FF8, 0x1FFE, 
  0x7FF0, 0x0FFE, 0x7FF0, 0x0FFE, 
  0x7FF0, 0x0FFE, 0x7FF8, 0x1FFE, 
  0x7FFC, 0x3FFE, 0x7FFF, 0xFFFE, 
  0x3FFF, 0xFFFC, 0x0000, 0x0000
};

static WORD RSBB2DATA[] =
{ 0x3FFF, 0xFFFC, 0x7FFF, 0xFFFE, 
  0x7FFE, 0x7FFE, 0x7FCC, 0x3FFE, 
  0x7F84, 0x33FE, 0x7984, 0x21FE, 
  0x7084, 0x21FE, 0x7084, 0x21FE, 
  0x7084, 0x21FE, 0x7084, 0x21FE, 
  0x7084, 0x21FE, 0x7084, 0x218E, 
  0x7084, 0x218E, 0x7084, 0x210E, 
  0x7084, 0x210E, 0x7084, 0x220E, 
  0x7000, 0x020E, 0x7000, 0x021E, 
  0x7000, 0x0C1E, 0x7000, 0x303E, 
  0x7800, 0xC03E, 0x7801, 0x007E, 
  0x7C01, 0x00FE, 0x7E01, 0x01FE, 
  0x7E00, 0x01FE, 0x7E00, 0x01FE, 
  0x7E00, 0x01FE, 0x7E00, 0x01FE, 
  0x7F00, 0x03FE, 0x7FFF, 0xFFFE, 
  0x3FFF, 0xFFFC, 0x0000, 0x0000
};

static BITBLK rs_bitblk[] =
{ RSBB0DATA,   4,  32,   0,   0, 0x0001,
  RSBB1DATA,   4,  32,   0,   0, 0x0001,
  RSBB2DATA,   4,  32,   0,   0, 0x0001
};

static OBJECT rs_object[] =
{ 
  /******** Tree 0 POP_LIST ****************************************************/
        -1, POPLISTBOX, POPLISTDOWN, G_BOX     |0x0F00,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x012A, 0x000A,
  POPLISTUP,        2, POPLISTLINE, G_BOX     ,   /* Object 1 POPLISTBOX */
  NONE, NORMAL, (LONG)0x00001101L,
  0x0000, 0x0000, 0x0028, 0x000A,
         3,       -1,       -1, G_TEXT    |0x1900,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[0],
  0x0000, 0x0000, 0x0028, 0x0001,
         4,       -1,       -1, G_TEXT    |0x1900,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[1],
  0x0000, 0x0001, 0x0028, 0x0001,
         5,       -1,       -1, G_TEXT    |0x1900,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[2],
  0x0000, 0x0002, 0x0028, 0x0001,
         6,       -1,       -1, G_TEXT    |0x1900,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[3],
  0x0000, 0x0003, 0x0028, 0x0001,
         7,       -1,       -1, G_TEXT    |0x1900,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[4],
  0x0000, 0x0004, 0x0028, 0x0001,
         8,       -1,       -1, G_TEXT    |0x1900,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[5],
  0x0000, 0x0005, 0x0028, 0x0001,
         9,       -1,       -1, G_TEXT    |0x1900,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[6],
  0x0000, 0x0006, 0x0028, 0x0001,
        10,       -1,       -1, G_TEXT    |0x1900,   /* Object 9  */
  NONE, NORMAL, (LONG)&rs_tedinfo[7],
  0x0000, 0x0007, 0x0028, 0x0001,
        11,       -1,       -1, G_TEXT    |0x1900,   /* Object 10  */
  NONE, NORMAL, (LONG)&rs_tedinfo[8],
  0x0000, 0x0008, 0x0028, 0x0001,
  POPLISTLINE,       -1,       -1, G_TEXT    |0x1900,   /* Object 11  */
  NONE, NORMAL, (LONG)&rs_tedinfo[9],
  0x0000, 0x0009, 0x0028, 0x0001,
  POPLISTBOX,       -1,       -1, G_BOX     ,   /* Object 12 POPLISTLINE */
  NONE, NORMAL, (LONG)0x00001171L,
  0x0027, 0x0000, 0x0001, 0x000A,
  POPLISTSBAR,       -1,       -1, G_BUTTON  |0x1200,   /* Object 13 POPLISTUP */
  TOUCHEXIT, NORMAL, (LONG)"\001",
  0x0128, 0x0000, 0x0002, 0x0001,
  POPLISTDOWN, POPLISTSLIDER, POPLISTSLIDER, G_BOX     ,   /* Object 14 POPLISTSBAR */
  TOUCHEXIT, NORMAL, (LONG)0x00FF1141L,
  0x0128, 0x0101, 0x0002, 0x0008,
  POPLISTSBAR,       -1,       -1, G_BUTTON  |0x1200,   /* Object 15 POPLISTSLIDER */
  TOUCHEXIT, NORMAL, (LONG)"\0",
  0x0000, 0x0000, 0x0002, 0x0002,
         0,       -1,       -1, G_BUTTON  |0x1200,   /* Object 16 POPLISTDOWN */
  LASTOB|TOUCHEXIT, NORMAL, (LONG)"\002",
  0x0028, 0x0009, 0x0002, 0x0001,
  
  /******** Tree 1 CHARTAB ****************************************************/
        -1,        1,       10, G_BOX     ,   /* Object 0  */
  NONE, SHADOWED, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0020, 0x000A,
         2,       -1,       -1, G_TEXT    ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_tedinfo[10],
  0x0000, 0x0000, 0x0020, 0x0001,
         3,       -1,       -1, G_TEXT    ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_tedinfo[11],
  0x0000, 0x0001, 0x0020, 0x0001,
         4,       -1,       -1, G_TEXT    ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_tedinfo[12],
  0x0000, 0x0002, 0x0020, 0x0001,
         5,       -1,       -1, G_TEXT    ,   /* Object 4  */
  NONE, NORMAL, (LONG)&rs_tedinfo[13],
  0x0000, 0x0003, 0x0020, 0x0001,
         6,       -1,       -1, G_TEXT    ,   /* Object 5  */
  NONE, NORMAL, (LONG)&rs_tedinfo[14],
  0x0000, 0x0004, 0x0020, 0x0001,
         7,       -1,       -1, G_TEXT    ,   /* Object 6  */
  NONE, NORMAL, (LONG)&rs_tedinfo[15],
  0x0000, 0x0005, 0x0020, 0x0001,
         8,       -1,       -1, G_TEXT    ,   /* Object 7  */
  NONE, NORMAL, (LONG)&rs_tedinfo[16],
  0x0000, 0x0006, 0x0020, 0x0001,
         9,       -1,       -1, G_TEXT    ,   /* Object 8  */
  NONE, NORMAL, (LONG)&rs_tedinfo[17],
  0x0000, 0x0007, 0x0020, 0x0001,
        10,       -1,       -1, G_TEXT    ,   /* Object 9  */
  NONE, NORMAL, (LONG)&rs_tedinfo[18],
  0x0000, 0x0008, 0x0020, 0x0001,
         0,       -1,       -1, G_TEXT    ,   /* Object 10  */
  LASTOB, NORMAL, (LONG)&rs_tedinfo[19],
  0x0000, 0x0009, 0x0020, 0x0001,
  
  /******** Tree 2 ALERT ****************************************************/
        -1,        1,       11, G_BOX     |0x0F00,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x004A, 0x000A,
         2,       -1,       -1, G_IMAGE   ,   /* Object 1  */
  NONE, NORMAL, (LONG)&rs_bitblk[0],
  0x0002, 0x0001, 0x0004, 0x0002,
         3,       -1,       -1, G_IMAGE   ,   /* Object 2  */
  NONE, NORMAL, (LONG)&rs_bitblk[1],
  0x0002, 0x0003, 0x0004, 0x0002,
         4,       -1,       -1, G_IMAGE   ,   /* Object 3  */
  NONE, NORMAL, (LONG)&rs_bitblk[2],
  0x0002, 0x0005, 0x0004, 0x0002,
         5,       -1,       -1, G_STRING  ,   /* Object 4  */
  NONE, NORMAL, (LONG)"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  0x0008, 0x0001, 0x0028, 0x0001,
         6,       -1,       -1, G_STRING  ,   /* Object 5  */
  NONE, NORMAL, (LONG)"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  0x0008, 0x0002, 0x0028, 0x0001,
         7,       -1,       -1, G_STRING  ,   /* Object 6  */
  NONE, NORMAL, (LONG)"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  0x0008, 0x0003, 0x0028, 0x0001,
         8,       -1,       -1, G_STRING  ,   /* Object 7  */
  NONE, NORMAL, (LONG)"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  0x0008, 0x0004, 0x0028, 0x0001,
         9,       -1,       -1, G_STRING  ,   /* Object 8  */
  NONE, NORMAL, (LONG)"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
  0x0008, 0x0005, 0x0028, 0x0001,
        10,       -1,       -1, G_BUTTON  ,   /* Object 9  */
  SELECTABLE|EXIT, WHITEBAK|STATE8|STATE9|STATE10|STATE11|STATE12|STATE13|STATE14, (LONG)"AAAAAAAAAAAAAAAAAAAA",
  0x0008, 0x0008, 0x0014, 0x0001,
        11,       -1,       -1, G_BUTTON  ,   /* Object 10  */
  SELECTABLE|EXIT, WHITEBAK|STATE8|STATE9|STATE10|STATE11|STATE12|STATE13|STATE14, (LONG)"AAAAAAAAAAAAAAAAAAAA",
  0x001E, 0x0008, 0x0014, 0x0001,
         0,       -1,       -1, G_BUTTON  ,   /* Object 11  */
  SELECTABLE|EXIT|LASTOB, WHITEBAK|STATE8|STATE9|STATE10|STATE11|STATE12|STATE13|STATE14, (LONG)"AAAAAAAAAAAAAAAAAAAA",
  0x0034, 0x0008, 0x0014, 0x0001
};

static OBJECT *rs_trindex[] =
{ &rs_object[0],   /* Tree  0 POP_LIST */
  &rs_object[17],   /* Tree  1 CHARTAB  */
  &rs_object[28]    /* Tree  2 ALERT    */
};
