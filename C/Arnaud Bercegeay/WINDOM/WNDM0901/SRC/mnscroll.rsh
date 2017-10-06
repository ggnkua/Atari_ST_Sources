/* GEM Resource C Source */

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
  /******** Tree 0 MNSCROLL ****************************************************/
        -1, MENULF          , MENURT          , G_BOX             ,   /* Object 0  */
  NONE, NORMAL, (LONG)0x00001100L,
  0x0000, 0x0000, 0x0002, 0x0901,
  MENURT          ,       -1,       -1, G_BOXCHAR         ,   /* Object 1 MENULF */
  NONE, NORMAL, (LONG) ((LONG)'\004' << 24)|0x00FF1100L,
  0x0000, 0x0000, 0x0001, 0x0201,
         0,       -1,       -1, G_BOXCHAR         ,   /* Object 2 MENURT */
  LASTOB, NORMAL, (LONG) ((LONG)'\003' << 24)|0x00FF1100L,
  0x0001, 0x0000, 0x0001, 0x0201
};

static OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 MNSCROLL         */
};
