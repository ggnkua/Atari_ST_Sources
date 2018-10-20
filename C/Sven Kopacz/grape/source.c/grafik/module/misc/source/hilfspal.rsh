/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "HILFSPAL.H"

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

USERBLK rs_userblk[] =
{ 0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003,
  0L, 0x00000003
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 HILFSPAL ****************************************************/
        -1,        1,       32, G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00011100L,
  0x0000, 0x0000, 0x0011, 0x0004,
         2,       -1,       -1, G_USERDEF         ,   /* Object 1  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[0],
  0x0000, 0x0000, 0x0002, 0x0001,
         3,       -1,       -1, G_USERDEF         ,   /* Object 2  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[1],
  0x0002, 0x0000, 0x0002, 0x0001,
         4,       -1,       -1, G_USERDEF         ,   /* Object 3  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[2],
  0x0004, 0x0000, 0x0002, 0x0001,
         5,       -1,       -1, G_USERDEF         ,   /* Object 4  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[3],
  0x0006, 0x0000, 0x0002, 0x0001,
         6,       -1,       -1, G_USERDEF         ,   /* Object 5  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[4],
  0x0009, 0x0000, 0x0002, 0x0001,
         7,       -1,       -1, G_USERDEF         ,   /* Object 6  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[5],
  0x000B, 0x0000, 0x0002, 0x0001,
         8,       -1,       -1, G_USERDEF         ,   /* Object 7  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[6],
  0x000D, 0x0000, 0x0002, 0x0001,
         9,       -1,       -1, G_USERDEF         ,   /* Object 8  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[7],
  0x000F, 0x0000, 0x0002, 0x0001,
        10,       -1,       -1, G_USERDEF         ,   /* Object 9  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[8],
  0x0000, 0x0001, 0x0002, 0x0001,
        11,       -1,       -1, G_USERDEF         ,   /* Object 10  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[9],
  0x0002, 0x0001, 0x0002, 0x0001,
        12,       -1,       -1, G_USERDEF         ,   /* Object 11  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[10],
  0x0004, 0x0001, 0x0002, 0x0001,
        13,       -1,       -1, G_USERDEF         ,   /* Object 12  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[11],
  0x0006, 0x0001, 0x0002, 0x0001,
        14,       -1,       -1, G_USERDEF         ,   /* Object 13  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[12],
  0x0009, 0x0001, 0x0002, 0x0001,
        15,       -1,       -1, G_USERDEF         ,   /* Object 14  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[13],
  0x000B, 0x0001, 0x0002, 0x0001,
        16,       -1,       -1, G_USERDEF         ,   /* Object 15  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[14],
  0x000D, 0x0001, 0x0002, 0x0001,
        17,       -1,       -1, G_USERDEF         ,   /* Object 16  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[15],
  0x000F, 0x0001, 0x0002, 0x0001,
        18,       -1,       -1, G_USERDEF         ,   /* Object 17  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[16],
  0x0000, 0x0002, 0x0002, 0x0001,
        19,       -1,       -1, G_USERDEF         ,   /* Object 18  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[17],
  0x0002, 0x0002, 0x0002, 0x0001,
        20,       -1,       -1, G_USERDEF         ,   /* Object 19  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[18],
  0x0004, 0x0002, 0x0002, 0x0001,
        21,       -1,       -1, G_USERDEF         ,   /* Object 20  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[19],
  0x0006, 0x0002, 0x0002, 0x0001,
        22,       -1,       -1, G_USERDEF         ,   /* Object 21  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[20],
  0x0009, 0x0002, 0x0002, 0x0001,
        23,       -1,       -1, G_USERDEF         ,   /* Object 22  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[21],
  0x000B, 0x0002, 0x0002, 0x0001,
        24,       -1,       -1, G_USERDEF         ,   /* Object 23  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[22],
  0x000D, 0x0002, 0x0002, 0x0001,
        25,       -1,       -1, G_USERDEF         ,   /* Object 24  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[23],
  0x000F, 0x0002, 0x0002, 0x0001,
        26,       -1,       -1, G_USERDEF         ,   /* Object 25  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[24],
  0x0000, 0x0003, 0x0002, 0x0001,
        27,       -1,       -1, G_USERDEF         ,   /* Object 26  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[25],
  0x0002, 0x0003, 0x0002, 0x0001,
        28,       -1,       -1, G_USERDEF         ,   /* Object 27  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[26],
  0x0004, 0x0003, 0x0002, 0x0001,
        29,       -1,       -1, G_USERDEF         ,   /* Object 28  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[27],
  0x0006, 0x0003, 0x0002, 0x0001,
        30,       -1,       -1, G_USERDEF         ,   /* Object 29  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[28],
  0x0009, 0x0003, 0x0002, 0x0001,
        31,       -1,       -1, G_USERDEF         ,   /* Object 30  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[29],
  0x000B, 0x0003, 0x0002, 0x0001,
        32,       -1,       -1, G_USERDEF         ,   /* Object 31  */
  TOUCHEXIT, NORMAL, (LONG)&rs_userblk[30],
  0x000D, 0x0003, 0x0002, 0x0001,
         0,       -1,       -1, G_USERDEF         ,   /* Object 32  */
  LASTOB|TOUCHEXIT, NORMAL, (LONG)&rs_userblk[31],
  0x000F, 0x0003, 0x0002, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 HILFSPAL         */
};
