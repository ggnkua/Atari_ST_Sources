/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "PRIMGRAF.H"

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

WORD RSBB0DATA[] =
{ 0xFFFF, 0x8001, 0x8001, 0x8001, 
  0x9FF9, 0x9009, 0x9009, 0x9009, 
  0x9009, 0x9009, 0x9009, 0x9FF9, 
  0x8001, 0x8001, 0x8001, 0xFFFF
};

WORD RSBB1DATA[] =
{ 0xFFFF, 0x8001, 0x8001, 0x8001, 
  0x9FF9, 0x9FF9, 0x9FF9, 0x9FF9, 
  0x9FF9, 0x9FF9, 0x9FF9, 0x9FF9, 
  0x8001, 0x8001, 0x8001, 0xFFFF
};

WORD RSBB2DATA[] =
{ 0xFFFF, 0x8001, 0x83C1, 0x8C31, 
  0x9009, 0x9009, 0xA005, 0xA005, 
  0xA005, 0xA005, 0x9009, 0x9009, 
  0x8C31, 0x83C1, 0x8001, 0xFFFF
};

WORD RSBB3DATA[] =
{ 0xFFFF, 0x8001, 0x83C1, 0x8FF1, 
  0x9FF9, 0x9FF9, 0xBFFD, 0xBFFD, 
  0xBFFD, 0xBFFD, 0x9FF9, 0x9FF9, 
  0x8FF1, 0x83C1, 0x8001, 0xFFFF
};

WORD RSBB4DATA[] =
{ 0xFFFF, 0x8001, 0x800D, 0x801D, 
  0x8039, 0x8071, 0x80E1, 0x81C1, 
  0x8381, 0x8701, 0x8E01, 0x9C01, 
  0xB801, 0xB001, 0x8001, 0xFFFF
};

WORD RSBB5DATA[] =
{ 0xFFFF, 0x8001, 0xB001, 0xB801, 
  0x9C01, 0x8E01, 0x8701, 0x8381, 
  0x81C1, 0x80E1, 0x8071, 0x8039, 
  0x801D, 0x800D, 0x8001, 0xFFFF
};

WORD RSBB6DATA[] =
{ 0xFFFF, 0x8001, 0xB001, 0xB001, 
  0xB001, 0xB001, 0xB001, 0xB001, 
  0xB001, 0xB001, 0xB001, 0xB001, 
  0xB001, 0xB001, 0x8001, 0xFFFF
};

WORD RSBB7DATA[] =
{ 0xFFFF, 0x8001, 0x8181, 0x8181, 
  0x8181, 0x8181, 0x8181, 0x8181, 
  0x8181, 0x8181, 0x8181, 0x8181, 
  0x8181, 0x8181, 0x8001, 0xFFFF
};

WORD RSBB8DATA[] =
{ 0xFFFF, 0x8001, 0x800D, 0x800D, 
  0x800D, 0x800D, 0x800D, 0x800D, 
  0x800D, 0x800D, 0x800D, 0x800D, 
  0x800D, 0x800D, 0x8001, 0xFFFF
};

WORD RSBB9DATA[] =
{ 0xFFFF, 0x8001, 0xBFFD, 0xBFFD, 
  0x8001, 0x8001, 0x8001, 0x8001, 
  0x8001, 0x8001, 0x8001, 0x8001, 
  0x8001, 0x8001, 0x8001, 0xFFFF
};

WORD RSBB10DATA[] =
{ 0xFFFF, 0x8001, 0x8001, 0x8001, 
  0x8001, 0x8001, 0x8001, 0xBFFD, 
  0xBFFD, 0x8001, 0x8001, 0x8001, 
  0x8001, 0x8001, 0x8001, 0xFFFF
};

WORD RSBB11DATA[] =
{ 0xFFFF, 0x8001, 0x8001, 0x8001, 
  0x8001, 0x8001, 0x8001, 0x8001, 
  0x8001, 0x8001, 0x8001, 0x8001, 
  0xBFFD, 0xBFFD, 0x8001, 0xFFFF
};

BITBLK rs_bitblk[] =
{ RSBB0DATA,   2,  16,   0,   0, 0x0001,
  RSBB1DATA,   2,  16,   0,   0, 0x0001,
  RSBB2DATA,   2,  16,   0,   0, 0x0001,
  RSBB3DATA,   2,  16,   0,   0, 0x0001,
  RSBB4DATA,   2,  16,   0,   0, 0x0001,
  RSBB5DATA,   2,  16,   0,   0, 0x0001,
  RSBB6DATA,   2,  16,   0,   0, 0x0001,
  RSBB7DATA,   2,  16,   0,   0, 0x0001,
  RSBB8DATA,   2,  16,   0,   0, 0x0001,
  RSBB9DATA,   2,  16,   0,   0, 0x0001,
  RSBB10DATA,   2,  16,   0,   0, 0x0001,
  RSBB11DATA,   2,  16,   0,   0, 0x0001
};

USERBLK rs_userblk[] =
{ 0L, 0x00000003
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 PRIMGRAF ****************************************************/
        -1, V1              , GO              , G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x001D, 0x0004,
  V2              ,       -1,       -1, G_IMAGE           ,   /* Object 1 V1 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[0],
  0x0001, 0x0800, 0x0002, 0x0001,
  V3              ,       -1,       -1, G_IMAGE           ,   /* Object 2 V2 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[1],
  0x0003, 0x0800, 0x0002, 0x0001,
  V4              ,       -1,       -1, G_IMAGE           ,   /* Object 3 V3 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[2],
  0x0006, 0x0800, 0x0002, 0x0001,
  V5              ,       -1,       -1, G_IMAGE           ,   /* Object 4 V4 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[3],
  0x0008, 0x0800, 0x0002, 0x0001,
  V6              ,       -1,       -1, G_IMAGE           ,   /* Object 5 V5 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[4],
  0x000B, 0x0800, 0x0002, 0x0001,
         7,       -1,       -1, G_IMAGE           ,   /* Object 6 V6 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[5],
  0x000D, 0x0800, 0x0002, 0x0001,
  COL1            ,       -1,       -1, G_STRING          ,   /* Object 7  */
  NONE, NORMAL, (LONG)"Farbe:",
  0x0011, 0x0800, 0x0006, 0x0001,
  V7              ,       -1,       -1, G_USERDEF         ,   /* Object 8 COL1 */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[0],
  0x0018, 0x0800, 0x0002, 0x0001,
  V8              ,       -1,       -1, G_IMAGE           ,   /* Object 9 V7 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[6],
  0x0001, 0x0002, 0x0002, 0x0001,
  V9              ,       -1,       -1, G_IMAGE           ,   /* Object 10 V8 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[7],
  0x0003, 0x0002, 0x0002, 0x0001,
  V10             ,       -1,       -1, G_IMAGE           ,   /* Object 11 V9 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[8],
  0x0005, 0x0002, 0x0002, 0x0001,
  V11             ,       -1,       -1, G_IMAGE           ,   /* Object 12 V10 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[9],
  0x0009, 0x0002, 0x0002, 0x0001,
  V12             ,       -1,       -1, G_IMAGE           ,   /* Object 13 V11 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[10],
  0x000B, 0x0002, 0x0002, 0x0001,
  GO              ,       -1,       -1, G_IMAGE           ,   /* Object 14 V12 */
  SELECTABLE|EXIT|RBUTTON|TOUCHEXIT, NORMAL, (LONG)&rs_bitblk[11],
  0x000D, 0x0002, 0x0002, 0x0001,
         0,       -1,       -1, G_BUTTON          ,   /* Object 15 GO */
  SELECTABLE|DEFAULT|EXIT|LASTOB|FLAGS9|FLAGS10, NORMAL, (LONG)"Ausf\201hren",
  0x0011, 0x0802, 0x000A, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 PRIMGRAF         */
};
