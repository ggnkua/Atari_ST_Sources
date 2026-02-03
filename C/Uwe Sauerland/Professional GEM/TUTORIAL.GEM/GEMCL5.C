>>>>>>>>>>>>>>>>>>>>>>>>>>> Sample object trees <<<<<<<<<<<<<<<<<<<<<<<<

OBJECT rs_object[] = {
-1, 1, 3, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 18,12,  /* Tree # 1 */
2, -1, -1, G_STRING, NONE, NORMAL, 0x0L, 3,1, 12,1,     
3, -1, -1, G_BUTTON, 0x7, NORMAL, 0x1L, 5,9, 8,1,       
0, 4, 4, G_BOX, NONE, NORMAL, 0xFF1172L, 3,3, 12,5,
3, -1, -1, G_IMAGE, LASTOB, NORMAL, 0x0L, 3,1, 6,3,     
-1, 1, 6, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 23,12,  /* Tree # 2 */
2, -1, -1, G_TEXT, NONE, NORMAL, 0x0L, 0,1, 23,1,       
6, 3, 5, G_IBOX, NONE, NORMAL, 0x1100L, 6,3, 11,5,
4, -1, -1, G_BUTTON, 0x11, NORMAL, 0x5L, 0,0, 11,1,     
5, -1, -1, G_BUTTON, 0x11, NORMAL, 0x6L, 0,2, 11,1,     
2, -1, -1, G_BOXCHAR, 0x11, NORMAL, 0x43FF1400L, 0,4, 11,1,
0, -1, -1, G_BOXTEXT, 0x27, NORMAL, 0x1L, 5,9, 13,1,    
-1, 1, 3, G_BOX, NONE, OUTLINED, 0x21100L, 0,0, 32,11,  /* Tree # 3 */
2, -1, -1, G_ICON, NONE, NORMAL, 0x0L, 4,1, 6,4,        
3, -1, -1, G_FTEXT, EDITABLE, NORMAL, 0x2L, 12,2, 14,1, 
0, 4, 4, G_FBOXTEXT, 0xE, NORMAL, 0x3L, 3,5, 25,4,      
3, -1, -1, G_ICON, LASTOB, NORMAL, 0x1L, 1,0, 6,4};     
 
>>>>>>>>>>>>>>>>>>>>>>>>>> Object tree walk utility <<<<<<<<<<<<<<<<<<<<<<
 
        VOID
map_tree(tree, this, last, routine)
        LONG            tree;
        WORD            this, last;
        WORD            (*routine)();
        {
        WORD            tmp1;
 
        tmp1 = this;            /* Initialize to impossible value: */
                                /* TAIL won't point to self!       */
                                /* Look until final node, or off   */
                                /* the end of tree                 */ 
        while (this != last && this != NIL)
                                /* Did we 'pop' into this node     */
                                /* for the second time?            */
                if (LWGET(OB_TAIL(this)) != tmp1)
                        {
                        tmp1 = this;    /* This is a new node       */
                        this = NIL;
                                        /* Apply operation, testing  */
                                        /* for rejection of sub-tree */
                        if ((*routine)(tree, tmp1))
                                this = LWGET(OB_HEAD(tmp1));
                                        /* Subtree path not taken,   */
                                        /* so traverse right         */ 
                        if (this == NIL)
                                this = LWGET(OB_NEXT(tmp1));
                        }
                else                    /* Revisiting parent:        */
                                        /* No operation, move right  */
                        {
                        tmp1 = this;
                        this = LWGET(OB_NEXT(tmp1));
                        }
        }

>>>>>>>>>>>>>>>>>> Sample routine to use with map_tree() <<<<<<<<<<<<<<<
 
        VOID
undo_obj(tree, which, bit)      /* clear specified bit in object state  */
        LONG    tree;
        WORD    which, bit;
        {
        WORD    state;

        state = LWGET(OB_STATE(which));
        LWSET(OB_STATE(which), state & ~bit);
        }

        VOID
desel_obj(tree, which)          /* turn off selected bit of spcfd object*/
        LONG    tree;
        WORD    which;
        {
        undo_obj(tree, which, SELECTED);
        return (TRUE);
        }

>>>>>>>>>>>>>>>>>>>>>>>>>> Sample .ICN Files <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>>> Save everything between >>><<< lines as CLOCK.ICN <<<<<<<<<<<<<<
/* GEM Icon Definition: */
#define ICON_W 0x0030
#define ICON_H 0x0018
#define DATASIZE 0x0048
UWORD clock[DATASIZE] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x3FFC, 0x0000, 0x000F, 0xC003, 
  0xF000, 0x0078, 0x0180, 0x1E00, 
  0x0180, 0x0180, 0x0180, 0x0603, 
  0x0180, 0xC060, 0x1C00, 0x0006, 
  0x0038, 0x3000, 0x018C, 0x000C, 
  0x60C0, 0x0198, 0x0306, 0x6000, 
  0x01B0, 0x0006, 0x4000, 0x01E0, 
  0x0002, 0xC000, 0x01C0, 0x0003, 
  0xCFC0, 0x0180, 0x03F3, 0xC000, 
  0x0000, 0x0003, 0x4000, 0x0000, 
  0x0002, 0x6000, 0x0000, 0x0006, 
  0x60C0, 0x0000, 0x0306, 0x3000, 
  0x0000, 0x000C, 0x1C00, 0x0000, 
  0x0038, 0x0603, 0x0180, 0xC060, 
  0x0180, 0x0180, 0x0180, 0x0078, 
  0x0180, 0x1E00, 0x000F, 0xC003, 
  0xF000, 0x0000, 0x3FFC, 0x0000
};
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> End of CLOCK.ICN <<<<<<<<<<<<<<<<<<<<<<<<<<
>>>>>>>>> Save everything between >>>><<<<< lines as CLOCKM.ICN <<<<<<<<<<
/* GEM Icon Definition: */
#define ICON_W 0x0030
#define ICON_H 0x0018
#define DATASIZE 0x0048
UWORD clockm[DATASIZE] =
{ 0x0000, 0x0000, 0x0000, 0x0000, 
  0x7FFE, 0x0000, 0x001F, 0xFFFF, 
  0xFC00, 0x00FF, 0xFFFF, 0xFF00, 
  0x03FF, 0xFFFF, 0xFFC0, 0x0FFF, 
  0xFFFF, 0xFFF0, 0x3FFF, 0xFFFF, 
  0xFFFC, 0x7FFF, 0xFFFF, 0xFFFE, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF, 
  0xFFFF, 0xFFFF, 0xFFFF, 0x7FFF, 
  0xFFFF, 0xFFFE, 0x3FFF, 0xFFFF, 
  0xFFFC, 0x0FFF, 0xFFFF, 0xFFF0, 
  0x03FF, 0xFFFF, 0xFFC0, 0x00FF, 
  0xFFFF, 0xFF00, 0x001F, 0xFFFF, 
  0xF800, 0x0000, 0x7FFE, 0x0000
};
>>>>>>>>>>>>>>>>>>>>>>>>> End of CLOCKM.ICN <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
