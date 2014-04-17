/* MN_TOOLS.H
 * ================================================================
 * DESCRIPTION: structures and defines for menu.c
 * 
 * 04/01/92 cjg - added new structures ( MENU and MN_SET )
 *		- added scroll_flag field to the MENU_NODE structure
 */


/* STRUCTURES
 * ================================================================
 */


/* Structure for passing menu data */
typedef struct _menu
{
   OBJECT *mn_tree;		/* Object tree of the menu */
   WORD   mn_menu;		/* Parent of the menu items*/
   WORD   mn_item;		/* Starting menu item      */
   WORD   mn_scroll;		/* scroll flag for the menu*/
   WORD   mn_keystate;		/* Key State 		   */
}MENU;


/* Structure for the Menu Settings */
typedef struct _mn_set
{
   LONG   Display;		/* The display delay      */
   LONG   Drag;			/* The drag delay         */
   LONG   Delay;		/* The Arrow Delay        */
   LONG   Speed;		/* The scroll speed delay */
   WORD   Height;		/* The menu scroll height */
}MN_SET;



typedef struct _mrets
{
  WORD x;
  WORD y;
  WORD buttons;
  WORD kstate;
}MRETS;

#if 0
typedef struct fdbstr
{
	long		fd_addr;
	int		fd_w;
	int		fd_h;
	int		fd_wdwidth;
	int		fd_stand;
	int		fd_nplanes;
	int		fd_r1;
	int		fd_r2;
	int		fd_r3;
} FDB;
#endif

#if 0     /* Found in AES.H */
typedef struct _moblk
{
  WORD m_x;
  WORD m_y;
  WORD m_w;
  WORD m_h;
  WORD m_out;
}MOBLK;
#endif

/*
 * Object bitfield structures
 */
typedef struct sColorword
{
/*
#if HIBIT_1ST
	unsigned cborder : 4;
	unsigned ctext	 : 4;
	unsigned replace : 1;
	unsigned pattern : 3;
	unsigned cfill	 : 4;
#else
*/
	unsigned cfill	 : 4;
	unsigned pattern : 3;
	unsigned replace : 1;
	unsigned ctext	 : 4;
	unsigned cborder : 4;
/*#endif*/
} Colorword;


typedef struct sObInfo
{
	BYTE		letter;
	BYTE border;	/* signed */
	Colorword	c;
} ObInfo;




/* SubMenu Index Structure -
 * This is a structure used for attaching submenus to menu items.
 * The index number is stored in the extended object type of the object.
 * There can be a maximum of 255 ( 0 is invalid ) submenus attached to
 * a menu item for each process.
 */
typedef struct _index_info
{
    BOOLEAN  status;	      /* 0 - InActive, 1 - Active   */
    WORD     index;	      /* Index ID for this node     */
    OBJECT  *subtree;	      /* The OBJECT tree            */
    WORD     menu;	      /* The menu object ( parent ) */
    WORD     start_obj;	      /* The starting menu item     */
    BOOLEAN  scroll_flag;     /* TRUE - scroll if >18 items */
    WORD     count;	      /* The # of times this menu is attached. */
}INDEX_NODE, *INDEX_PTR;

#define INDEX_STATUS( ptr )    ptr->status
#define INDEX_ID( ptr )        ptr->index
#define INDEX_TREE( ptr )      ptr->subtree
#define INDEX_MENU( ptr )      ptr->menu
#define INDEX_OBJ( ptr )       ptr->start_obj
#define INDEX_FLAGSCROLL(ptr)  ptr->scroll_flag
#define INDEX_COUNT( ptr )     ptr->count


#define CMAX 		8
#define MIN_INDEX	128
#define MAX_INDEX	192


/* INDEX cluster structure
 * Index nodes are grouped into clusters of 8 nodes.
 */
typedef struct _cnode
{
    INDEX_NODE    ctable[ CMAX ];  /* First Cluster       */
    struct _cnode *cnext;          /* ptr to next cluster */
}CNODE, *CNODE_PTR;

#define CTABLE( ptr )   ptr->ctable
#define CNEXT( ptr )    ptr->cnext


/* Index Process Structure */
typedef struct _proc_node
{
    WORD	       pid;
    WORD	       num;		/* Number of nodes in use       */
    CNODE              cluster;		/* First CLUSTER_MAX group	*/
    struct _proc_node *pnext;		/* pointer to next process node */
}PNODE, *PNODE_PTR;

#define PID( ptr )	  ptr->pid
#define PCOUNT( ptr )	  ptr->num
#define PCLUSTER( ptr )   ptr->cluster
#define PNEXT( ptr )	  ptr->pnext



/* Structure for popup and submenu nodes.
 * These are allocated when the menu is prepared to be displayed and
 * free'd when they are removed.
 * There can be a maximum of 32768 submenus displayed at any one time.
 */
typedef struct _menu_node
{
	UWORD   MenuID;	 	 /* Menu ID # 			  */
	OBJECT  *tree_ptr;	 /* Pointer to object tree data   */

        WORD	StartItem;	 /* Start Menu Item = Default == 1*/
	WORD    NumItems;	 /* Num Items in menu 		  */

	GRECT   rect;		 /* GRECT of Menu in pixels...    */
	WORD    offset;		 /* Offset into the menu ( SCROLL)*/

	WORD	Parent;		 /* Parent object in tree...	  */
	WORD	FirstChild;	 /* First object in tree...       */
	WORD    LastChild;	 /* Last object in tree...        */
	UWORD   LastFlag;   	 /* ObFlag of Last Child	  */

	WORD	TopObject;	 /* Top object in Scroll Menu...  */
	UWORD   TopState;   	 /* Top item's object state.      */
	UWORD	TopFlag;	 /* Top items object flag	  */
	BYTE    TopText[ 128 ];	 /* Top item's ObString()	  */

	WORD    BObject;    	 /* Bottom object in Scroll Menu  */
	UWORD   BState;	 	 /* Bottom item's object state    */
	UWORD   BFlag;		 /* Bottom item's object flag     */
	BYTE    BText[128]; 	 /* Bottom item's ObString()      */

	LONG    *buffer;	 /* Pointer to redraw buffer...   */
	struct _menu_node *mprev; /* Ptr to Previous SubMenu       */

	struct _menu_node *mnext; /* Ptr to Next Linked Menu_Node  */

	WORD    mscroll;	  /* scroll flag */
} MENU_NODE, *MENU_PTR;



/* DEFINES
 * ================================================================
 */
#define MMENU_ID( ptr )      ptr->MenuID
#define MTREE( ptr )         ptr->tree_ptr

#define MSTART_OBJ( ptr )    ptr->StartItem
#define MNUM_ITEMS( ptr )    ptr->NumItems

#define MXPOS( ptr )	     ptr->rect.g_x
#define MYPOS( ptr )	     ptr->rect.g_y
#define MWIDTH( ptr )        ptr->rect.g_w
#define MHEIGHT( ptr )       ptr->rect.g_h
#define MOBRECT( ptr )       ( *( GRECT *)&ptr->rect.g_x )

#define MOFFSET( ptr )	     ptr->offset

#define MPARENT( ptr )	     ptr->Parent
#define MFIRST_CHILD( ptr )  ptr->FirstChild
#define MLAST_CHILD( ptr )   ptr->LastChild
#define MLASTFLAG( ptr )     ptr->LastFlag

#define MTOP_OBJ( ptr )	     ptr->TopObject
#define MTOP_STATE( ptr )    ptr->TopState
#define MTOP_FLAG( ptr )     ptr->TopFlag
#define MTOP_TXT( ptr )	     ptr->TopText

#define MB_OBJ( ptr )        ptr->BObject
#define MB_STATE( ptr )      ptr->BState
#define MB_FLAG( ptr )	     ptr->BFlag
#define MB_TXT( ptr )        ptr->BText

#define MBUFFER( ptr )	     ptr->buffer
#define MPREV( ptr )	     ptr->mprev
#define MNEXT( ptr )	     ptr->mnext


#define MSCROLL( ptr )	     ptr->mscroll


/*
 * Object structure access macros ( `tree' must be declared OBJECT * )
 * ----------------------------------------------------------------------
 */
#define ObNext(obj) 	( tree[(obj)].ob_next )
#define ObHead(obj) 	( tree[(obj)].ob_head )
#define ObTail(obj) 	( tree[(obj)].ob_tail )
#define ObType(obj) 	( tree[(obj)].ob_type )
#define ObFlags(obj)	( tree[(obj)].ob_flags )
#define ObState(obj)	( tree[(obj)].ob_state )
#define ObSpec(obj) 	( tree[(obj)].ob_spec )
#define ObIndex(obj)    ( tree[(obj)].ob_spec )

/* ObSpecs for ObBOX, ObIBOX, ObBOXCHAR */
#define ObChar(obj) 	( (*(ObInfo *)&ObSpec(obj)).letter )
#define ObBorder(obj)	( (*(ObInfo *)&ObSpec(obj)).border )
#define ObCBorder(obj)	( (*(ObInfo *)&ObSpec(obj)).c.cborder )
#define ObCText(obj)	( (*(ObInfo *)&ObSpec(obj)).c.ctext )
#define ObReplace(obj)	( (*(ObInfo *)&ObSpec(obj)).c.replace )
#define ObPattern(obj)	( (*(ObInfo *)&ObSpec(obj)).c.pattern )
#define ObCFill(obj)	( (*(ObInfo *)&ObSpec(obj)).c.cfill )

/* TEDINFO access macros, for ObTEXT, ObBOXTEXT, ObFTEXT, ObFBOXTEXT */
#define _TE(obj)	( (TEDINFO *)ObSpec(obj) )
#define TedText(obj)	( _TE(obj)->te_ptext )
#define TedTemplate(obj)( _TE(obj)->te_ptmplt )
#define TedValid(obj)	( _TE(obj)->te_pvalid )
#define TedFont(obj)	( _TE(obj)->te_font )
#define TedJust(obj)	( _TE(obj)->te_just )

#define TedCBorder(obj) ( (*(Colorword *)&_TE(obj)->te_color).cborder )
#define TedCText(obj)	( (*(Colorword *)&_TE(obj)->te_color).ctext )
#define TedReplace(obj) ( (*(Colorword *)&_TE(obj)->te_color).replace )
#define TedPattern(obj) ( (*(Colorword *)&_TE(obj)->te_color).pattern )
#define TedCFill(obj)	( (*(Colorword *)&_TE(obj)->te_color).cfill )

#define TedBorder(obj)	( _TE(obj)->te_thickness )
#define TedLen(obj) 	( _TE(obj)->te_txtlen )
#define TedTempLen(obj) ( _TE(obj)->te_tmplen )

/* ICONBLK access for ObICON */
#define _IB(obj)	( (ICONBLK *)ObSpec(obj) )
#define IconMask(obj)	( _IB(obj)->ib_pmask )
#define IconData(obj)	( _IB(obj)->ib_pdata )
#define IconText(obj)	( _IB(obj)->ib_ptext )
#define IconFColor(obj) ( (*(IconInfo *)&_IB(obj)->ib_char).fcolor )
#define IconBColor(obj) ( (*(IconInfo *)&_IB(obj)->ib_char).bcolor )
#define IconChar(obj)	( (*(IconInfo *)&_IB(obj)->ib_char).letter )
#define IconRect(obj)	( *(GRECT *)&_IB(obj)->ib_xicon )
#define IconTRect(obj)	( *(GRECT *)&_IB(obj)->ib_xtext )

/* BITBLK access for ObIMAGE */
#define _BB(obj)	( (BITBLK *)ObSpec(obj) )
#define ImageData(obj)	( _BB(obj)->bi_pdata )
#define ImageWb(obj)	( _BB(obj)->bi_wb )
#define ImageH(obj) 	( _BB(obj)->bi_hl )
#define ImageColor(obj) ( _BB(obj)->bi_color )

/* String access for ObBUTTON, ObSTRING, ObTITLE */
#define ObString(obj)	( (char *)ObSpec(obj) )

/* Object extents */
#define ObX(obj)	( tree[(obj)].ob_x )
#define ObY(obj)	( tree[(obj)].ob_y )
#define ObW(obj)	( tree[(obj)].ob_width )
#define ObH(obj)	( tree[(obj)].ob_height )
#define ObRect(obj) 	( *(GRECT *)&tree[(obj)].ob_x )


/*
 * Object flags & states macros
 */
#define IsSelectable(obj)	( ObFlags(obj) & SELECTABLE )
#define IsDefault(obj)		( ObFlags(obj) & DEFAULT )
#define IsExit(obj) 		( ObFlags(obj) & EXIT )
#define IsEditable(obj) 	( ObFlags(obj) & EDITABLE )
#define IsRadio(obj)		( ObFlags(obj) & RBUTTON )
#define IsRButton(obj)		IsRadio(obj)
#define IsLast(obj) 		( ObFlags(obj) & LASTOB )
#define IsLastob(obj)		IsLast(obj)
#define IsTouchexit(obj)	( ObFlags(obj) & TOUCHEXIT )
#define IsHidden(obj)		( ObFlags(obj) & HIDETREE )
#define IsVisible(obj)		( !IsHidden(obj) )
#define IsIndirect(obj) 	( ObFlags(obj) & INDIRECT )
#define IsSubMenu(obj)		( ObFlags(obj) & SUBMENU )

#define IsSelected(obj) 	( ObState(obj) & SELECTED )
#define IsCrossed(obj)		( ObState(obj) & CROSSED )
#define IsChecked(obj)		( ObState(obj) & CHECKED )
#define IsDisabled(obj) 	( ObState(obj) & DISABLED )
#define IsEnabled(obj)		( !IsDisabled(obj) )
#define IsOutlined(obj) 	( ObState(obj) & OUTLINED )
#define IsShadowed(obj) 	( ObState(obj) & SHADOWED )
#define IsTed(obj)		( (ObType(obj) == G_TEXT)	|| \
				  (ObType(obj) == G_BOXTEXT)	|| \
				  (ObType(obj) == G_FTEXT)	|| \
				  (ObType(obj) == G_FBOXTEXT) )
#define IsG_String(obj)		( ( ObType(obj) & 0x00FF ) == G_STRING )

#define ActiveTree( newtree )	( tree = newtree )
#define IsActiveTree( newtree ) ( tree == newtree )

/*
 * Object flags & states manipulation macros.
 * NOTE: These do not affect the visual appearance of the object.
 */
#define MakeSelectable(obj) 	( ObFlags(obj) |= SELECTABLE )
#define MakeDefault(obj)	( ObFlags(obj) |= DEFAULT )
#define MakeExit(obj)		( ObFlags(obj) |= EXIT )
#define MakeEditable(obj)	( ObFlags(obj) |= EDITABLE )
#define MakeRadio(obj)		( ObFlags(obj) |= RBUTTON )
#define MakeRButton(obj)	MakeRadio(obj)
#define MakeLast(obj)		( ObFlags(obj) |= LASTOB )
#define MakeLastob(obj) 	MakeLast(obj)
#define MakeTouchexit(obj)	( ObFlags(obj) |= TOUCHEXIT )
#define HideObj(obj)		( ObFlags(obj) |= HIDETREE )
#define MakeHidden(obj) 	HideObj(obj)
#define MakeHidetree(obj)	HideObj(obj)
#define MakeIndirect(obj)	( ObFlags(obj) |= INDIRECT )
#define MakeSubMenu(obj)	( ObFlags(obj) |= SUBMENU )

#define NoSelect(obj)		( ObFlags(obj) &= ~SELECTABLE )
#define NoDefault(obj)		( ObFlags(obj) &= ~DEFAULT )
#define NoExit(obj) 		( ObFlags(obj) &= ~EXIT )
#define NoEdit(obj) 		( ObFlags(obj) &= ~EDITABLE )
#define NoRadio(obj)		( ObFlags(obj) &= ~RBUTTON )
#define NoRButton(obj)		NoRadio(obj)
#define NoLast(obj) 		( ObFlags(obj) &= ~LASTOB )
#define NoLastob(obj)		NoLast(obj)
#define NoTouchexit(obj)	( ObFlags(obj) &= ~TOUCHEXIT )
#define ShowObj(obj)		( ObFlags(obj) &= ~HIDETREE )
#define NoHidetree(obj) 	ShowObj(obj)
#define NoIndirect(obj) 	( ObFlags(obj) &= ~INDIRECT )
#define NoSubMenu(obj)		( ObFlags(obj) &= ~SUBMENU )

#define SelectObj(obj)		( ObState(obj) |= SELECTED )
#define CrossObj(obj)		( ObState(obj) |= CROSSED )
#define CheckObj(obj)		( ObState(obj) |= CHECKED )
#define DisableObj(obj) 	( ObState(obj) |= DISABLED )
#define OutlineObj(obj) 	( ObState(obj) |= OUTLINED )
#define ShadowObj(obj)		( ObState(obj) |= SHADOWED )
#define Select(obj)		( ObState(obj) |= SELECTED )
#define Disable(obj)		( ObState(obj) |= DISABLED )

#define DeselectObj(obj)	( ObState(obj) &= ~SELECTED )
#define UnCrossObj(obj) 	( ObState(obj) &= ~CROSSED )
#define UnCheckObj(obj) 	( ObState(obj) &= ~CHECKED )
#define EnableObj(obj)		( ObState(obj) &= ~DISABLED )
#define NoOutlineObj(obj)	( ObState(obj) &= ~OUTLINED )
#define NoShadowObj(obj)	( ObState(obj) &= ~SHADOWED )
#define Deselect(obj)		( ObState(obj) &= ~SELECTED )
#define Enable(obj)		( ObState(obj) &= ~DISABLED )
#define SetNormal(obj)		( ObState(obj) = NORMAL	   )

#define NO_ARROW	(-1)
#define UP_ARROW	0
#define DOWN_ARROW	1
#define TIME_SAMPLE		150L

#define INIT_MAX_HEIGHT 16
#define MIN_HEIGHT	5

#define INIT_ARROW_DELAY	250L
#define INIT_SCROLL_DELAY	0L

#define MENU_MAX	32767
#define MAX_LEVEL	4


#define RIGHT_ARROW		0x03
#define ARROW_OFFSET		2
#define INIT_DRAG_DELAY		10000L
#define INIT_DISPLAY_DELAY	200L


/* these are defined or should have been defined in gemlib etc */
#define BEG_MCTRL	3
#define END_MCTRL	2
