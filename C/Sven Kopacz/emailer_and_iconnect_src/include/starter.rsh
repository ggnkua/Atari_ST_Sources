/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "STARTER.H"

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

OBJECT rs_object[] =
{ 
  /******** Tree 0 CENTER ****************************************************/
        -1, CENTEROB        , CENTEROB        , G_BOX             ,   /* Object 0  */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0002, 0x0001,
         0,       -1,       -1, G_BOXCHAR         ,   /* Object 1 CENTEROB */
  LASTOB, NORMAL, (LONG) ((LONG)'\0' << 24)|0x00FF1100L,
  0x0000, 0x0000, 0x0002, 0x0001,
  
  /******** Tree 1 POPUP ****************************************************/
        -1, PSILENCE        , PSILENCE        , G_BOX             ,   /* Object 0 POPROOT */
  NONE, OUTLINED, (LONG)0x00021100L,
  0x0000, 0x0000, 0x0012, 0x0011,
  POPROOT         , P1              , P16             , G_BOX             ,   /* Object 1 PSILENCE */
  NONE, SHADOWED, (LONG)0x00FF1101L,
  0x0001, 0x0000, 0x000E, 0x0010,
  P2              ,       -1,       -1, G_STRING          ,   /* Object 2 P1 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0000, 0x000E, 0x0001,
  P3              ,       -1,       -1, G_STRING          ,   /* Object 3 P2 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0001, 0x000E, 0x0001,
  P4              ,       -1,       -1, G_STRING          ,   /* Object 4 P3 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0002, 0x000E, 0x0001,
  P5              ,       -1,       -1, G_STRING          ,   /* Object 5 P4 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0003, 0x000E, 0x0001,
  P6              ,       -1,       -1, G_STRING          ,   /* Object 6 P5 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0004, 0x000E, 0x0001,
  P7              ,       -1,       -1, G_STRING          ,   /* Object 7 P6 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0005, 0x000E, 0x0001,
  P8              ,       -1,       -1, G_STRING          ,   /* Object 8 P7 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0006, 0x000E, 0x0001,
  P9              ,       -1,       -1, G_STRING          ,   /* Object 9 P8 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0007, 0x000E, 0x0001,
  P10             ,       -1,       -1, G_STRING          ,   /* Object 10 P9 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0008, 0x000E, 0x0001,
  P11             ,       -1,       -1, G_STRING          ,   /* Object 11 P10 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x0009, 0x000E, 0x0001,
  P12             ,       -1,       -1, G_STRING          ,   /* Object 12 P11 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x000A, 0x000E, 0x0001,
  P13             ,       -1,       -1, G_STRING          ,   /* Object 13 P12 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x000B, 0x000E, 0x0001,
  P14             ,       -1,       -1, G_STRING          ,   /* Object 14 P13 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x000C, 0x000E, 0x0001,
  P15             ,       -1,       -1, G_STRING          ,   /* Object 15 P14 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x000D, 0x000E, 0x0001,
  P16             ,       -1,       -1, G_STRING          ,   /* Object 16 P15 */
  SELECTABLE, NORMAL, (LONG)"  123456789012",
  0x0000, 0x000E, 0x000E, 0x0001,
  PSILENCE        ,       -1,       -1, G_STRING          ,   /* Object 17 P16 */
  SELECTABLE|LASTOB, NORMAL, (LONG)"  123456789012",
  0x0000, 0x000F, 0x000E, 0x0001
};

OBJECT *res[] =
{ &rs_object[0],   /* Tree  0 CENTER           */
  &rs_object[2]    /* Tree  1 POPUP            */
};
