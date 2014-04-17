/* FILE: POP_HEAD.H
 * =====================================================================
 * Date: February 5, 1991
 * DESCRIPTION: Structures for the POPUP Routines
 */



/* TYPE DEFINE STRUCTURES
 * ======================================================================
 */

/* Command Structure
 * ======================================================================
 * One node is allocated for each existing menu item in a menulist entry.
 */
typedef struct _cmdchar
{
  int  state;		/* ob_state of this menu item     */
  char keyflag[2];	/* KEYCODE for hotkey - /!#%^&*~  */
  int  submenu;		/* menuid of the items submenu.   */
} CmdChar, *CmdCharPtr;

#define CmdState( ptr )   ptr.state
#define CmdSubMenu( ptr ) ptr.submenu
#define CmdFlag( ptr )    ptr.keyflag[0]


/* MenuList Structure
 * ======================================================================
 * There is one MenuList Node for each active popup/submenu.
 */
typedef struct _pop_node
{
	int	MenuID;		 /* Menu ID # 			  */
        int	PopUpItem;	 /* Initial Item: 		  */
	int	width;		 /* width in characters...	  */
	int     height;		 /* height in chars.              */
	GRECT   rect;		 /* GRECT of area in pixels...    */
	int	num_items;	 /* # of items in menu	          */
	int     offset;		 /* Offset into the menu          */
	int	FirstObj;	 /* First object in tree...       */
	int     LastObj;	 /* Last object in tree...        */
	OBJECT  *obj_ptr;	 /* pointer to object data        */
	char    *text_ptr;	 /* ptr to unrefined text data    */
	char    *textbuff;	 /* ptr to refined text data buf  */
	long    textbuffsize;	 /* Size of text malloc area...   */
	long	*mem_ptr;	 /* Pointer to overlay memory     */
	CmdChar *CharPtr;	 /* Pointer to state memory       */
				 /* for each text entry 	  */
	struct _pop_node *pprev; /* Pointer to prev popup menu    */
} POP_NODE, *POP_PTR;
 
#define PMENUID( ptr )	   ptr->MenuID  
#define PWIDTH( ptr )      ptr->width
#define PHEIGHT( ptr )     ptr->height

#define PNUM( ptr )	   ptr->num_items
#define POBJECT( ptr )     ptr->obj_ptr
#define PMEM( ptr )	   ptr->mem_ptr
#define PTEXT( ptr )	   ptr->text_ptr
#define PPREV( ptr ) 	   ptr->pprev

#define PXPOS( ptr )	   ptr->rect.g_x
#define PYPOS( ptr )	   ptr->rect.g_y
#define PIX_WIDTH( ptr )   ptr->rect.g_w
#define PIX_HEIGHT( ptr )  ptr->rect.g_h
#define PObRect( ptr )     ( *( GRECT *)&ptr->rect.g_x )

#define PFIRST( ptr )      ptr->FirstObj
#define PLAST( ptr )	   ptr->LastObj

#define PTEXTBUFFSIZE(ptr) ptr->textbuffsize
#define PTEXTBUFF( ptr)    ptr->textbuff

#define PopUpItem( ptr )   ptr->PopUpItem
#define POFFSET( ptr )     ptr->offset
#define PCmdChar( ptr )    ( CmdCharPtr )ptr->CharPtr





