/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "SW_DIFF.H"

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
  /******** Tree 0 SW_KONVERT ****************************************************/
        -1, GO              , DIFF3           , G_BOX             ,   /* Object 0  */
  FLAGS10, NORMAL, (LONG)0x00FF1100L,
  0x0000, 0x0000, 0x0024, 0x0004,
  DIFF1           ,       -1,       -1, G_BUTTON          ,   /* Object 1 GO */
  SELECTABLE|DEFAULT|EXIT|FLAGS9|FLAGS10, NORMAL, (LONG)"Ausf\201hren",
  0x0017, 0x0002, 0x000A, 0x0001,
  DIFF2           ,       -1,       -1, G_BUTTON          ,   /* Object 2 DIFF1 */
  SELECTABLE|RBUTTON|TOUCHEXIT|FLAGS9, WHITEBAK|STATE14|STATE15, (LONG)"Verteilung 50/50",
  0x0001, 0x0001, 0x0013, 0x0001,
  DIFF3           ,       -1,       -1, G_BUTTON          ,   /* Object 3 DIFF2 */
  SELECTABLE|RBUTTON|TOUCHEXIT|FLAGS9, WHITEBAK|STATE14|STATE15, (LONG)"Verteilung 1/3",
  0x0001, 0x0002, 0x0011, 0x0001,
         0,       -1,       -1, G_BUTTON          ,   /* Object 4 DIFF3 */
  SELECTABLE|RBUTTON|LASTOB|TOUCHEXIT|FLAGS9, WHITEBAK|STATE14|STATE15, (LONG)"Floyd-Steinberg",
  0x0001, 0x0003, 0x0012, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 SW_KONVERT       */
};
