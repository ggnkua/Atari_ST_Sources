/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "ACCTEST.H"

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
  /******** Tree 0 MAIN ****************************************************/
  {      -1,        1,        2, G_BOX             ,   /* Object 0  */
   NONE, OUTLINED, {(LONG)0x00021100L},
   0x0000, 0x0000, 0x0028, 0x0009 },
  {      2,       -1,       -1, G_STRING          ,   /* Object 1  */
   NONE, NORMAL, {(LONG)"BaS_gcc interface info"},
   0x0001, 0x0001, 0x0016, 0x0001 },
  {      0,       -1,       -1, G_BUTTON          ,   /* Object 2  */
   SELECTABLE|DEFAULT|EXIT|LASTOB, NORMAL, {(LONG)" OK "},
   0x001F, 0x0007, 0x0008, 0x0001 }
};

static OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 MAIN             */
};
