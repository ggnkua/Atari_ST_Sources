>>>>>>>>>>>>>>>>>>>>>> Download file for GEM column #7 <<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>>>>>>>>>>>>>>>>>>>> Sample Menu Tree <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

-1, 1, 6, G_IBOX, NONE, NORMAL, 0x0L, 0,0, 80,25,       /* ROOT */
6, 2, 2, G_BOX, NONE, NORMAL, 0x1100L, 0,0, 80,513,     /* THE BAR */
1, 3, 5, G_IBOX, NONE, NORMAL, 0x0L, 2,0, 20,769,       /* THE ACTIVE */
4, -1, -1, G_TITLE, NONE, NORMAL, 0x0L, 0,0, 6,769,     /* Title #1 */
5, -1, -1, G_TITLE, NONE, NORMAL, 0x1L, 6,0, 6,769,     /* Title #2 */
2, -1, -1, G_TITLE, NONE, NORMAL, 0x2L, 12,0, 8,769,    /* Title #3 */
0, 7, 22, G_IBOX, NONE, NORMAL, 0x0L, 0,769, 80,19,     /* THE SCREEN */
16, 8, 15, G_BOX, NONE, NORMAL, 0xFF1100L, 2,0, 20,8,   /* Drop-down #1 */
9, -1, -1, G_STRING, NONE, NORMAL, 0x3L, 0,0, 19,1,     /* About... entry */
10, -1, -1, G_STRING, NONE, DISABLED, 0x4L, 0,1, 20,1,
11, -1, -1, G_STRING, NONE, NORMAL, 0x5L, 0,2, 20,1,    /* Desk acc entries */
12, -1, -1, G_STRING, NONE, NORMAL, 0x6L, 0,3, 20,1,
13, -1, -1, G_STRING, NONE, NORMAL, 0x7L, 0,4, 20,1,
14, -1, -1, G_STRING, NONE, NORMAL, 0x8L, 0,5, 20,1,
15, -1, -1, G_STRING, NONE, NORMAL, 0x9L, 0,6, 20,1,
7, -1, -1, G_STRING, NONE, NORMAL, 0xAL, 0,7, 20,1,
22, 17, 21, G_BOX, NONE, NORMAL, 0xFF1100L, 8,0, 13,5,  /* Drop-down #2 */
18, -1, -1, G_STRING, NONE, NORMAL, 0xBL, 0,0, 13,1,
19, -1, -1, G_STRING, NONE, DISABLED, 0xCL, 0,1, 13,1,
20, -1, -1, G_STRING, NONE, NORMAL, 0xDL, 0,4, 13,1,
21, -1, -1, G_STRING, NONE, NORMAL, 0xEL, 0,2, 13,1,
16, -1, -1, G_STRING, NONE, DISABLED, 0xFL, 0,3, 13,1,
6, 23, 25, G_BOX, NONE, NORMAL, 0xFF1100L, 14,0, 26,3,  /* Drop down #3 */
24, -1, -1, G_STRING, NONE, NORMAL, 0x10L, 0,2, 26,1,
25, -1, -1, G_STRING, NONE, NORMAL, 0x11L, 0,0, 26,1,
22, -1, -1, G_STRING, LASTOB, DISABLED, 0x12L, 0,1, 26,1

>>>>>>>>>>>>>>>>>>>>>>>> Menu enable/disable utility <<<<<<<<<<<<<<<<<<<<<<

/*------------------------------*/
/*      undo_obj                */
/*------------------------------*/
        VOID
undo_obj(tree, which, bit)
        LONG    tree;
        WORD    which;
        UWORD   bit;
        {
        WORD    state;

        state = LWGET(OB_STATE(which));
        LWSET(OB_STATE(which), state & ~bit);
        }

/*------------------------------*/
/*      enab_obj                */
/*------------------------------*/
        WORD
enab_obj(tree, which)
        LONG    tree;
        WORD    which;
        {
        undo_obj(tree, which, (UWORD) DISABLED);
        return (TRUE);
        }

/*------------------------------*/
/*      do_obj                  */
/*------------------------------*/
        VOID
do_obj(tree, which, bit)
        LONG    tree;
        WORD    which;
        UWORD   bit;
        {
        WORD    state;

        state = LWGET(OB_STATE(which));
        LWSET(OB_STATE(which), state | bit);
        }

/*------------------------------*/
/*      disab_obj               */
/*------------------------------*/
        WORD
disab_obj(tree, which)
        LONG    tree;
        WORD    which;
        {
        do_obj(tree, which, (UWORD) DISABLED);
        return (TRUE);
        }

/*------------------------------*/
/*      set_menu                */
/*------------------------------*/
        VOID
set_menu(tree, change)                  /* change[0] TRUE selects all entries*/
        LONG    tree;                   /* FALSE deselects all.  Change list */
        WORD    *change;                /* of items is then toggled.         */
        {
        WORD    dflt, screen, drop, obj;

        dflt = *change++;                       /* What is default?   */
        screen = LWGET(OB_TAIL(ROOT));          /* Get SCREEN         */
        drop = LWGET(OB_HEAD(screen));          /* Get DESK drop-down */
                                                /* and skip it        */
        for (; (drop = LWGET(OB_NEXT(drop))) != screen; )
                {
                obj = LWGET(OB_HEAD(drop));
                if (obj != NIL)
                if (dflt)
                        map_tree(tree, obj, drop, enab_obj);
                else
                        map_tree(tree, obj, drop, disab_obj);
                }

        for (; *change; change++)
                if (dflt)
                        disab_obj(tree, *change);
                else
                        enab_obj(tree, *change);
        }

>>>>>>>>>>>>>>>>>>>>> Definitions used in this article <<<<<<<<<<<<<<<<<<<<<<

#define ROOT 0

#define G_IBOX    25
#define G_STRING  28
#define G_TITLE   32

#define R_TREE     0

#define MN_SELECTED 10

#define CHECKED   0x4
#define DISABLED  0x8

#define OB_NEXT(x) (tree + (x) * sizeof(OBJECT) + 0)
#define OB_HEAD(x) (tree + (x) * sizeof(OBJECT) + 2)
#define OB_TAIL(x) (tree + (x) * sizeof(OBJECT) + 4)
#define OB_TYPE(x) (tree + (x) * sizeof(OBJECT) + 6)
#define OB_FLAGS(x) (tree + (x) * sizeof(OBJECT) + 8)
#define OB_STATE(x) (tree + (x) * sizeof(OBJECT) + 10)
#define OB_SPEC(x) (tree + (x) * sizeof(OBJECT) + 12)
#define OB_X(x) (tree + (x) * sizeof(OBJECT) + 16)
#define OB_Y(x) (tree + (x) * sizeof(OBJECT) + 18)
#define OB_WIDTH(x) (tree + (x) * sizeof(OBJECT) + 20)
#define OB_HEIGHT(x) (tree + (x) * sizeof(OBJECT) + 22)

#define M_OFF     256
#define M_ON      257
